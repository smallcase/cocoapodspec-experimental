#!/bin/sh
set -e

scheme="${BITRISE_SCHEME:-release}"

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme $scheme \
  -destination "generic/platform=iOS Simulator" \
  build

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme $scheme \
  -destination "generic/platform=iOS" \
  build