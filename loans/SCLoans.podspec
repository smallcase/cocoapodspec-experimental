plist_path = ENV.fetch('LOANS_PLIST', 'Loans/Info.plist')
version_key = ENV.fetch('VERSION_KEY', 'CFBundleShortVersionString')
version=%x[/usr/libexec/PlistBuddy -c "Print :#{version_key}" #{plist_path}].strip

version_code_key = ENV.fetch('VERSION_CODE_KEY', 'CFBundleVersion')
version_code=%x[/usr/libexec/PlistBuddy -c "Print :#{version_code_key}" #{plist_path}].strip

pod_name = "SCLoans"
remix = ENV.fetch('REMIX', '')
scheme = ENV.fetch('BITRISE_SCHEME', '')

name = pod_name
aws_bucket="ios_sdk_loans" # Prod bucket
source_target_dir = version

is_prod_build = ENV.fetch('COCOA_REPO', '') == 'trunk'
if !is_prod_build
    name = "#{pod_name}-#{remix}"
    version= [version, version_code, scheme].reject(&:empty?).join('-')
    aws_bucket="loans_internal" # Set to internal bucket
    source_target_dir = [remix, version].reject(&:empty?).join('/')
end

Pod::Spec.new do |spec|
    spec.name         = "#{name}"
    spec.version      = "#{version}"
    spec.summary      = "Setup smallcase Loans iOS SDK to allow your users to apply for various types of Loans"
    spec.description  = "smallcase Gateway offers a unified set of APIs & SDKs to bring seamless borrowing experience in your app or website."

    spec.homepage     = "https://developers.gateway.smallcase.com/docs/ios-integration"
    spec.license      = "MIT"
    spec.author       = { "gatewaytech" => "gatewaytech@smallcase.com" }
    spec.platform     = :ios

    spec.ios.deployment_target = "14.0"
    spec.swift_versions = ["5.10"]

    spec.vendored_framework = 'Loans.xcframework'
    spec.source ={ :http => "https://gateway.smallcase.com/#{aws_bucket}/#{source_target_dir}/Loans.xcframework.zip"}  

    spec.dependency "Mixpanel-swift", "~> 4.2.5"
end