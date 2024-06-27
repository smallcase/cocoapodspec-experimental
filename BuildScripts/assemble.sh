#!/bin/sh
set -e

scheme="${SC_ASSEMBLE_SCHEME:-SmartInvesting}"

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme $scheme \
  -destination "generic/platform=iOS Simulator" \
  build

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme $scheme \
  -destination "generic/platform=iOS" \
  USE_XC_FRAMEWORKS=YES \
  build


# # Define the path to the archives directory
archives_dir_default=./.build/Archives
archives_dir="${SC_ARCHIVE_DIR:-$archives_dir_default}"
archivePath="$archives_dir/$SC_ASSEMBLE_SCHEME/SmartInvesting.xcarchive"

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme $scheme \
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
  -exportPath ./.build/Products/$SC_ASSEMBLE_SCHEME/SmartInvesting/ \
  -exportOptionsPlist './ExportOptions.plist'