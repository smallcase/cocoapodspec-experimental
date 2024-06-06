#!/bin/sh
set -e

find .build -mindepth 1 -delete

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


# # Define the path to the archives directory
archives_dir=./.build/Products/Archives
archivePath="$archives_dir/SmartInvesting.xcarchive"

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme SmartInvesting \
  -destination 'generic/platform=iOS' \
  -archivePath "$archivePath" \
  archive

git restore .
git clean -f
git clean -fd


# Find the latest archive directory
latest_archive=$(ls -t "$archives_dir" | head -n 1)
latest_archive_path="$archives_dir/$latest_archive/$(ls -t "$archives_dir/$latest_archive" | head -n 1)"

xcodebuild \
  -exportArchive \
  -archivePath "$archivePath" \
  -exportPath ./.build/Products/SmartInvesting/ \
  -exportOptionsPlist './ExportOptions.plist'