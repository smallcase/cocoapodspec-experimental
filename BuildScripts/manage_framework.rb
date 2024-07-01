#!/usr/bin/env ruby

require 'optparse'
require 'xcodeproj'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: manage_framework.rb [options]"

  opts.on("-r", "--remove", "Remove the framework") do
    options[:remove] = true
  end

  opts.on("-a", "--add", "Add the framework") do
    options[:add] = true
  end

  opts.on("-fNAME", "--framework=NAME", "Name of the framework") do |name|
    options[:framework] = name
  end
  
  opts.on("-fpPATH", "--frameworkPath=PATH", "Path to the framework") do |fpath|
    options[:framework_path] = fpath
  end

  opts.on("-pPATH", "--project=PATH", "Path to the Xcode project") do |path|
    options[:project] = path
  end
  
  opts.on("-tTARGET", "--target=TARGET", "Target") do |target|
    options[:target] = target
  end
end.parse!

puts options

valid_add_command = !options[:framework].nil? && !options[:framework_path].nil?
valid_remove_command = !options[:framework].nil?

puts valid_add_command
puts valid_remove_command

raise OptionParser::MissingArgument if options[:project].nil? || options[:target].nil? || options[:add] && !valid_add_command || options[:remove] && !valid_remove_command

project_path = options[:project]
framework_name = options[:framework]
framework_path = options[:framework_path]

project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == options[:target] }

# Find the "Link Binary With Libraries" build phase
link_phase = target.build_phases.find { |phase| phase.is_a?(Xcodeproj::Project::Object::PBXFrameworksBuildPhase) }
# next unless link_phase

link_phase_file_reference = link_phase.files_references.find { |file| file.path.include?(framework_name) }

if options[:remove] && link_phase_file_reference
  link_phase.remove_file_reference(link_phase_file_reference)
  
  target.build_phases.select { |phase| phase.display_name == "Embed Frameworks" }.each do |embed_phase|
    embed_phase_file_reference = embed_phase.files_references.find { |file| file.path.include?(framework_name) }
    embed_phase.remove_file_reference(embed_phase_file_reference)
  end
  puts "Removed #{framework_name} from #{target.name}"
elsif options[:add] && link_phase_file_reference.nil?
  new_file = project.frameworks_group.new_file(framework_path)
  build_file = target.frameworks_build_phase.add_file_reference(new_file)
  link_phase.add_file_reference(new_file, true)
  target.build_phases.select { |phase| phase.display_name == "Embed Frameworks" }.each do |embed_phase|
    embed_file = embed_phase.add_file_reference(new_file, true)
    embed_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
  end
  puts "Added #{framework_name} to #{target.name}"
end

project.save
