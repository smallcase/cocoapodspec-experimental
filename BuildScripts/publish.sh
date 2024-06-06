#!/bin/sh
set -e

xc_framework_path=".build/Products/Loans.xcframework"
xc_framework_path_zip="$xc_framework_path.zip"
podspec_path="loans/internal/SCLoans-internal.podspec.json"
repo_name="smallcase-cocoapodspecs-internal"
repo_url="https://github.com/smallcase/cocoapodspec-internal.git"

# Extract the s3 source url from the podspec
s3_url=$(grep '"http"' $podspec_path | awk -F': ' '{print $2}' | tr -d '",')
# Remove https:// & the framework.zip parts of the url. Replaces these with empty string to remove them from the url.
# Using the | delimeter instead of /
s3_dir=$($s3_url | sed "s|https://||" | sed "s|$xc_framework_path_zip||")

zip -r "$xc_framework_path_zip" "$xc_framework_path"
aws s3 cp "$xc_framework_path_zip" s3://$s3_dir

if [ "$repo_name" != "trunk" ]
    pod repo add "$repo_name" "$repo_url"
fi
pod spec lint "$podspec_path" --allow-warnings
pod repo push $repo_name "$podspec_path" --allow-warnings