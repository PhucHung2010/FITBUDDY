require 'xcodeproj'
project_path = 'FitBuddy.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main FitBuddy group
app_group = project.main_group.find_subpath('FitBuddy', false)

# Create the SOCIAL group if it doesn't exist
social_group = app_group.find_subpath('SOCIAL', false)
if social_group.nil?
  social_group = app_group.new_group('SOCIAL')
  social_group.set_source_tree('<group>')
  social_group.set_path('SOCIAL')
end

# Find the main target
target = project.targets.first

# Add files to the group and target
files_to_add = [
  'SocialModels.swift',
  'SocialManager.swift',
  'UserSearchView.swift',
  'PublicProfileView.swift',
  'ChatListView.swift',
  'ChatRoomView.swift'
]

files_to_add.each do |file_name|
  file_path = File.join('SOCIAL', file_name)
  # Check if file is already in the group to avoid duplicates
  existing_ref = social_group.files.find { |f| f.path == file_name || (f.path && f.path.include?(file_name)) }
  if existing_ref.nil?
    file_ref = social_group.new_file(file_name)
    target.add_file_references([file_ref])
    puts "Added #{file_name} to Xcode project."
  else
    puts "#{file_name} already in Xcode project."
  end
end

project.save
puts "Successfully saved project.pbxproj"
