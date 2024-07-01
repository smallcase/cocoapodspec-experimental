#!/bin/sh
set -e

scheme="${SC_ASSEMBLE_SCHEME:-SmartInvesting}"

if [ -d ".build" ]; then
    find .build -mindepth 1 -delete
else
    echo ".build directory does not exist"
fi

xcodebuild \
  -workspace SmartInvesting.xcworkspace \
  -scheme $scheme \
  clean