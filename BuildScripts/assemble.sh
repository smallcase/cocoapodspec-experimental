#!/bin/sh
set -e

scheme="${BITRISE_SCHEME:-release}"

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme "SCGatewayXcFramework" \
  -destination "generic/platform=iOS" \
  SC_XC_FRAMEWORKS_OUT_DIR="$(pwd)/.build/Frameworks/$scheme" \
  build

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme "LoansXCFramework" \
  -destination "generic/platform=iOS" \
  SC_XC_FRAMEWORKS_OUT_DIR="$(pwd)/.build/Frameworks/$scheme" \
  build

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme $scheme \
  -destination "generic/platform=iOS" \
  USE_XC_FRAMEWORKS=YES \
  SCG_XCF_PATH=".build/Frameworks/$scheme/xcframeworks/SCGateway.xcframework" \
  LOANS_XCF_PATH=".build/Frameworks/$scheme/xcframeworks/Loans.xcframework" \
  build


# # Define the path to the archives directory
archives_dir_default=./.build/Archives
archives_dir="${SC_ARCHIVE_DIR:-$archives_dir_default}"
archivePath="$archives_dir/$scheme/SmartInvesting.xcarchive"

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
  -exportPath ./.build/Products/$scheme/SmartInvesting/ \
  -exportOptionsPlist './ExportOptions.plist'