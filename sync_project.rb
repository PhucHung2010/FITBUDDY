#!/usr/bin/env ruby
# ============================================================================
# sync_project.rb
# ============================================================================
# Automatically syncs ALL files in the FitBuddy/ source folder with the
# Xcode project file (.xcodeproj/project.pbxproj).
#
# What it does:
#   ✅ Adds new .swift files → Sources build phase
#   ✅ Adds new resource files (.mp4, .mov, .mp3, .plist, etc.) → Resources build phase
#   ✅ Removes stale references (files deleted from disk)
#   ✅ Creates missing group hierarchy to match folder structure
#   ✅ Skips .DS_Store, .xcassets internals, .xcdatamodeld internals, Preview Content
#
# Usage:
#   ruby sync_project.rb
#
# Requirements:
#   gem install xcodeproj   (already included with CocoaPods)
# ============================================================================

require 'xcodeproj'
require 'pathname'
require 'set'

# ── Configuration ──────────────────────────────────────────────────────
SCRIPT_DIR   = File.dirname(File.expand_path(__FILE__))
PROJECT_PATH = File.join(SCRIPT_DIR, 'FitBuddy.xcodeproj')
SOURCE_DIR   = File.join(SCRIPT_DIR, 'FitBuddy')
TARGET_NAME  = 'FitBuddy'

# Extensions that go into Sources build phase
SOURCE_EXTENSIONS = Set.new(%w[.swift])

# Extensions that go into Resources build phase
RESOURCE_EXTENSIONS = Set.new(%w[
  .mov .MOV .mp4 .m4v .avi
  .mp3 .wav .m4a .aac
  .plist .json .txt .csv .md
  .png .jpg .jpeg .gif .svg .pdf .webp
  .ttf .otf
  .storyboard .xib
  .html .css .js
])

# Directories/patterns to skip entirely
SKIP_PATTERNS = [
  '**/.DS_Store',
  '**/.git/**',
  '**/build/**',
  '**/*.xcassets/**',       # xcassets are managed internally
  '**/*.xcdatamodeld/**',   # Core Data models managed internally
  '**/Preview Content/**',
]

# Skip these directory NAMES entirely during scanning
# (only keep gifs_1080x1080 to avoid duplicate filenames across resolutions)
SKIP_DIRS = Set.new(%w[gifs_180x180 gifs_360x360 gifs_720x720])

# Files/dirs to skip at the root level of scanning
SKIP_FILES = Set.new(%w[.DS_Store])

# Special directories that should be added as folder references (not groups)
FOLDER_REF_DIRS = Set.new(%w[.xcassets .xcdatamodeld])

# ── Helper: collect all disk files recursively ────────────────────────
def collect_disk_files(dir, relative_to)
  files = []
  return files unless File.directory?(dir)

  Dir.entries(dir).sort.each do |entry|
    next if entry == '.' || entry == '..'
    next if SKIP_FILES.include?(entry)

    full_path = File.join(dir, entry)
    rel_path  = Pathname.new(full_path).relative_path_from(Pathname.new(relative_to)).to_s

    if File.directory?(full_path)
      ext = File.extname(entry)
      # Skip directories that are managed internally
      next if FOLDER_REF_DIRS.include?(ext)
      next if entry == 'Preview Content'
      next if SKIP_DIRS.include?(entry)

      files += collect_disk_files(full_path, relative_to)
    else
      ext = File.extname(entry)
      if SOURCE_EXTENSIONS.include?(ext) || RESOURCE_EXTENSIONS.include?(ext)
        files << rel_path
      end
    end
  end

  files
end

# ── Helper: collect all files referenced in a group (recursively) ─────
def collect_project_files(group, prefix = '')
  files = {}
  group.children.each do |child|
    if child.is_a?(Xcodeproj::Project::Object::PBXGroup) && !child.is_a?(Xcodeproj::Project::Object::PBXVariantGroup)
      child_path = prefix.empty? ? (child.path || child.name || '') : File.join(prefix, child.path || child.name || '')
      files.merge!(collect_project_files(child, child_path))
    elsif child.is_a?(Xcodeproj::Project::Object::PBXFileReference)
      file_path = prefix.empty? ? child.path : File.join(prefix, child.path)
      files[file_path] = child
    end
  end
  files
end

# ── Helper: find or create group hierarchy ────────────────────────────
def find_or_create_group(root_group, relative_dir)
  return root_group if relative_dir.nil? || relative_dir.empty? || relative_dir == '.'

  parts = relative_dir.split('/')
  current_group = root_group

  parts.each do |part|
    child = current_group.children.find { |c|
      c.is_a?(Xcodeproj::Project::Object::PBXGroup) &&
      (c.path == part || c.name == part)
    }

    if child
      current_group = child
    else
      current_group = current_group.new_group(part, part)
    end
  end

  current_group
end

# ── Main ──────────────────────────────────────────────────────────────
puts ""
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "🔄 FitBuddy Project Sync"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts ""

# Open project
project = Xcodeproj::Project.open(PROJECT_PATH)
target  = project.targets.find { |t| t.name == TARGET_NAME }

unless target
  puts "❌ Target '#{TARGET_NAME}' not found!"
  puts "   Available: #{project.targets.map(&:name).join(', ')}"
  exit 1
end

# Find FitBuddy main group
main_group = project.main_group.find_subpath('FitBuddy', false)
unless main_group
  puts "❌ Cannot find 'FitBuddy' group in project!"
  exit 1
end

puts "📂 Source directory:  #{SOURCE_DIR}"
puts "📦 Xcode project:    #{PROJECT_PATH}"
puts "🎯 Target:           #{TARGET_NAME}"
puts ""

# ── Gather files ──────────────────────────────────────────────────────
disk_files    = collect_disk_files(SOURCE_DIR, SOURCE_DIR).sort
project_files = collect_project_files(main_group)

disk_set    = Set.new(disk_files)
project_set = Set.new(project_files.keys)

to_add    = (disk_set - project_set).to_a.sort
to_remove = (project_set - disk_set).to_a.sort

# Filter out special files from removal (xcassets, xcdatamodeld contents, etc.)
to_remove.reject! { |f|
  f.include?('.xcassets') ||
  f.include?('.xcdatamodeld') ||
  f.include?('Preview Content')
}

puts "📊 Files on disk:       #{disk_files.count}"
puts "📊 Files in project:    #{project_files.count}"
puts "➕ To add:              #{to_add.count}"
puts "➖ To remove:           #{to_remove.count}"
puts ""

if to_add.empty? && to_remove.empty?
  puts "✅ Everything is already in sync! No changes needed."
  puts ""
  exit 0
end

# ── Add new files ─────────────────────────────────────────────────────
added_sources   = 0
added_resources = 0

unless to_add.empty?
  puts "➕ Adding #{to_add.count} file(s):"
  puts ""

  to_add.each do |rel_path|
    dir_part  = File.dirname(rel_path)
    file_name = File.basename(rel_path)
    ext       = File.extname(file_name)

    # Find or create the group hierarchy
    group = find_or_create_group(main_group, dir_part)

    # Add file reference
    file_ref = group.new_reference(file_name)

    # Add to appropriate build phase
    if SOURCE_EXTENSIONS.include?(ext)
      target.source_build_phase.add_file_reference(file_ref)
      added_sources += 1
      puts "   📝 #{rel_path}  → Sources"
    elsif RESOURCE_EXTENSIONS.include?(ext)
      target.resources_build_phase.add_file_reference(file_ref)
      added_resources += 1
      puts "   📦 #{rel_path}  → Resources"
    end
  end
  puts ""
end

# ── Remove stale references ───────────────────────────────────────────
removed = 0

unless to_remove.empty?
  puts "➖ Removing #{to_remove.count} stale reference(s):"
  puts ""

  to_remove.each do |rel_path|
    file_ref = project_files[rel_path]
    next unless file_ref

    # Remove from all build phases
    target.build_phases.each do |phase|
      phase.files.each do |build_file|
        if build_file.file_ref == file_ref
          build_file.remove_from_project
        end
      end
    end

    # Remove file reference
    file_ref.remove_from_project
    removed += 1
    puts "   🗑️  #{rel_path}"
  end
  puts ""
end

# ── Clean up empty groups ─────────────────────────────────────────────
def remove_empty_groups(group)
  group.children.select { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) }.each do |child|
    remove_empty_groups(child)
    if child.children.empty?
      child.remove_from_project
    end
  end
end

remove_empty_groups(main_group)

# ── Save ──────────────────────────────────────────────────────────────
project.save

puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "🎉 Sync complete!"
puts "   📝 Sources added:    #{added_sources}"
puts "   📦 Resources added:  #{added_resources}"
puts "   🗑️  Removed:          #{removed}"
puts ""
puts "   Open Xcode → Clean (⌘⇧K) → Build (⌘B)"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
