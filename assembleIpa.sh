#!/bin/sh
set -e

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme SmartInvesting \
  clean

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme SmartInvesting \
  -destination "generic/platform=iOS Simulator" \
  build

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme SmartInvesting \
  -destination "generic/platform=iOS" \
  USE_XC_FRAMEWORKS=YES \
  build

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme SmartInvesting \
  -destination 'generic/platform=iOS' \
  archive

git restore .
git clean -f
git clean -fd

# # Define the path to the archives directory
archives_dir=~/Library/Developer/Xcode/Archives

# Find the latest archive directory
latest_archive=$(ls -t "$archives_dir" | head -n 1)
latest_archive_path="$archives_dir/$latest_archive/$(ls -t "$archives_dir/$latest_archive" | head -n 1)"

xcodebuild \
  -exportArchive \
  -archivePath "$latest_archive_path" \
  -exportPath ./Products/SmartInvesting/ \
  -exportOptionsPlist './ExportOptions.plist'