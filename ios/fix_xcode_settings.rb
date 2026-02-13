require 'xcodeproj'

# Open the Xcode project
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the Runner target
target = project.targets.find { |t| t.name == 'Runner' }

# Add EXCLUDED_ARCHS for simulator to all build configurations
target.build_configurations.each do |config|
  config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
  puts "Set EXCLUDED_ARCHS for #{config.name}"
end

# Save the project
project.save

puts "Successfully updated Xcode project settings"
