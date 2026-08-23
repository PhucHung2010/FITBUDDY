#!/usr/bin/env ruby
# ============================================================================
# sync_video_resources.rb
# ============================================================================
# Automatically syncs the VIDEO/ folder with the Xcode project.
# - Adds new files found on disk but missing from the project
# - Removes references to files no longer on disk
#
# Usage:
#   ruby sync_video_resources.rb
#
# Requirements:
#   gem install xcodeproj   (already included with CocoaPods)
# ============================================================================

require 'xcodeproj'
require 'pathname'

# ── Configuration ──────────────────────────────────────────────────────
PROJECT_PATH = File.expand_path('../FitBuddy.xcodeproj', __FILE__)
VIDEO_DIR    = File.expand_path('../FitBuddy/VIDEO', __FILE__)
TARGET_NAME  = 'FitBuddy'

# File extensions to sync
VIDEO_EXTENSIONS = %w[.mov .MOV .mp4 .mp3 .m4v .avi .wav .m4a].freeze

# ── Open project ───────────────────────────────────────────────────────
project = Xcodeproj::Project.open(PROJECT_PATH)
target  = project.targets.find { |t| t.name == TARGET_NAME }

unless target
  puts "❌ Target '#{TARGET_NAME}' not found!"
  puts "   Available targets: #{project.targets.map(&:name).join(', ')}"
  exit 1
end

# ── Find the VIDEO group in the project ────────────────────────────────
video_group = project.main_group.find_subpath('FitBuddy/VIDEO', false)

unless video_group
  puts "📁 VIDEO group not found, creating it..."
  fitbuddy_group = project.main_group.find_subpath('FitBuddy', false)
  unless fitbuddy_group
    puts "❌ Cannot find FitBuddy group in project!"
    exit 1
  end
  video_group = fitbuddy_group.new_group('VIDEO', 'VIDEO')
end

# ── Gather current state ──────────────────────────────────────────────
# Files currently on disk
disk_files = Dir.glob(File.join(VIDEO_DIR, '*'))
               .select { |f| File.file?(f) && VIDEO_EXTENSIONS.include?(File.extname(f)) }
               .map { |f| File.basename(f) }
               .sort

# Files currently referenced in Xcode project (in the VIDEO group)
project_files = video_group.files
                           .map { |f| f.path }
                           .compact
                           .sort

puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "🎬 FitBuddy Video Resource Sync"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts ""
puts "📂 VIDEO directory: #{VIDEO_DIR}"
puts "📦 Xcode project:   #{PROJECT_PATH}"
puts ""
puts "Files on disk:      #{disk_files.count}"
puts "Files in project:   #{project_files.count}"
puts ""

# ── Files to ADD (on disk but not in project) ─────────────────────────
to_add = disk_files - project_files

# ── Files to REMOVE (in project but not on disk) ─────────────────────
to_remove = project_files - disk_files

if to_add.empty? && to_remove.empty?
  puts "✅ Everything is already in sync! No changes needed."
  exit 0
end

# ── Add new files ─────────────────────────────────────────────────────
unless to_add.empty?
  puts "➕ Adding #{to_add.count} file(s):"
  to_add.each do |filename|
    file_path = File.join(VIDEO_DIR, filename)
    file_ref = video_group.new_reference(filename)
    target.resources_build_phase.add_file_reference(file_ref)
    puts "   ✅ #{filename}"
  end
  puts ""
end

# ── Remove stale references ───────────────────────────────────────────
unless to_remove.empty?
  puts "➖ Removing #{to_remove.count} stale reference(s):"
  to_remove.each do |filename|
    file_ref = video_group.files.find { |f| f.path == filename }
    if file_ref
      # Remove from build phase first
      target.resources_build_phase.files.each do |build_file|
        if build_file.file_ref == file_ref
          build_file.remove_from_project
          break
        end
      end
      # Remove file reference from group
      file_ref.remove_from_project
      puts "   🗑️  #{filename}"
    end
  end
  puts ""
end

# ── Save ──────────────────────────────────────────────────────────────
project.save
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "🎉 Project saved! Open Xcode and build (⌘B)."
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
