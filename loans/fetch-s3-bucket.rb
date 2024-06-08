require 'optparse'
require 'json'

podspec_path = "SCLoans.podspec.json"

options = { is_internal: false }

  OptionParser.new do |opts|
    opts.banner = "Usage: ruby chore-release.rb [options]"
  
    opts.on("-i", "--internal", "Specifies if the release script should be run for an internal release.") do |f|
      options[:is_internal] = true
    end
  end.parse!

if options[:is_internal]
    podspec_path = "internal/SCLoans-internal.podspec.json"
end

json_data = File.read(podspec_path)
parsed_json = JSON.parse(json_data)

s3_url = parsed_json['source']['http']
s3_dir = s3_url.gsub("https://", "").gsub("Loans.xcframework.zip", "")

puts s3_dir