#!/usr/bin/env ruby

require 'cocoapods-core'
require 'optparse'
require 'json'

# VARIBALES

plist_path = "SCGateway/Helpers/Info.plist"

# METHODS

def fetch_plist_value(plist_path, key)
    # Construct the PlistBuddy command to read the value for the given key
    command = "/usr/libexec/PlistBuddy -c 'Print :#{key}' #{plist_path}"
  
    # Execute the command and capture the output
    value = `#{command}`.chomp
  
    puts "Value for key '#{key}' in '#{plist_path}': #{value}"
  
    # Return the value
    value
  end

  def set_plist_value(plist_path, key, value)
    # Construct the PlistBuddy command to read the value for the given key
    command = "/usr/libexec/PlistBuddy -c 'Set :#{key} #{value}' #{plist_path}"

    # Execute the command
    system(command)
  
    puts "Set value for key '#{key}' in '#{plist_path}': #{value}"
  
    # Return the value
    value
  end

  def update_podspec(podspec_path, new_version, source)
    # Read the contents of the podspec JSON file
    podspec_content = File.read(podspec_path)
  
    # Parse the JSON content into a hash
    podspec_hash = JSON.parse(podspec_content)
  
    # Update the version in the hash
    podspec_hash['version'] = new_version
    podspec_hash['source']['http'] = source
  
    # Convert the updated hash back to JSON
    modified_podspec_content = JSON.pretty_generate(podspec_hash)
  
    # Write the modified JSON content back to the podspec file
    File.open(podspec_path, "w") { |file| file.puts modified_podspec_content }
  
    puts "Podspec version updated to #{new_version}"
  end

  def git_commit_and_tag(commit_message, tag_name)
    # Git commit
    system("git add .")
    system("git commit -m '#{commit_message}'")
  
    # Git tag
    system("git tag #{tag_name}")

    system("git checkout #{tag_name}")
  
    puts "Committed changes with message '#{commit_message}' and created tag '#{tag_name}'"
  end

# VARIBALES

plist_path = "SCGateway/Helpers/Info.plist"
podspec_path = "SCGateway.podspec.json"
aws_bucket = "scdk_ios_xcode_12"
commit_message = "chore(release): "

  # START OF SCRIPT

  options = { is_internal: false }

  OptionParser.new do |opts|
    opts.banner = "Usage: ruby chore-release.rb [options]"
  
    opts.on("-i", "--internal", "Specifies if the release script should be run for an internal release.") do |f|
      options[:is_internal] = true
    end
  end.parse!

  scgateway_version = fetch_plist_value(plist_path, "SCGatewayVersion")
  tag_name = "v#{scgateway_version}"
  commit_message = "chore(release): #{tag_name}"

  if options[:is_internal]
    podspec_path = "internal/SCGateway-internal.podspec.json"
    aws_bucket = "scgateway_internal"
    tag_name = "#{tag_name}-internal"
    commit_message = "chore(release): #{tag_name}"
    puts "This is an internal release!"
  end
  

  set_plist_value(plist_path, "CFBundleShortVersionString", scgateway_version)
  update_podspec(podspec_path, scgateway_version, "https://gateway.smallcase.com/#{aws_bucket}/#{scgateway_version}/SCGateway.xcframework.zip")
  git_commit_and_tag(commit_message, tag_name)



