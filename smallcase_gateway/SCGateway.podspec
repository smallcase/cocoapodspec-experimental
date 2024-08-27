plist_path = ENV.fetch('SCG_PLIST', 'SCGateway/Helpers/Info.plist')
version_key = ENV.fetch('VERSION_KEY', 'CFBundleShortVersionString')
version=%x[/usr/libexec/PlistBuddy -c "Print :#{version_key}" #{plist_path}].strip

version_code_key = ENV.fetch('VERSION_CODE_KEY', 'CFBundleVersion')
version_code=%x[/usr/libexec/PlistBuddy -c "Print :#{version_code_key}" #{plist_path}].strip

pod_name = "SCGateway"
remix = ENV.fetch('REMIX', 'remix')
scheme = ENV.fetch('BITRISE_SCHEME', '')

name = pod_name
aws_bucket="scdk_ios_xcode_12" # Prod bucket
source_target_dir = version

is_prod_build = ENV.fetch('COCOA_REPO', '') == 'trunk'
if !is_prod_build
    name = "#{pod_name}-#{remix}"
    version= [version, version_code, scheme].reject(&:empty?).join('-')
    aws_bucket="scgateway_internal" # Set to internal bucket
    source_target_dir = [remix, version].reject(&:empty?).join('/')
end

Pod::Spec.new do |spec|
    spec.name         = "#{name}"
    spec.version      = "#{version}"
    spec.summary      = "Setup smallcase Gateway iOS SDK to allow your users to transact in stocks, ETFs & smallcases, and much more"
    spec.description  = "Gateway offers a unified set of APIs & SDKs to bring seamless trading & investing experience in your app or website."

    spec.homepage     = "https://developers.gateway.smallcase.com/docs/ios-integration"
    spec.license      = "MIT"
    spec.author       = { "gatewaytech" => "gatewaytech@smallcase.com" }
    spec.platform     = :ios

    spec.ios.deployment_target = "12.0"
    spec.swift_versions = ["5.10"]

    spec.vendored_framework = 'SCGateway.xcframework'
    spec.source ={ :http => "https://gateway.smallcase.com/#{aws_bucket}/#{source_target_dir}/SCGateway.xcframework.zip"}  

    spec.dependency "Mixpanel-swift", "~> 4.2.5"
end