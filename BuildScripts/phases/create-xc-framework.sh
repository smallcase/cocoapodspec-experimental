#! /bin/sh -e

# THIS SCRIPT IS ONLY MEANT TO BE RUN FROM INSIDE XCODE BUILD PHASES
# IT USES XCODE SPECIFIC ENV VARIABLES
set -e

export LANG=en_US.UTF-8

# This script demonstrates archive and create action on frameworks and libraries
# Release dir path
DEFAULT_OUTPUT_DIR_PATH="${PROJECT_DIR}/.build"
OUTPUT_DIR_PATH="${SC_XC_FRAMEWORKS_OUT_DIR:-${DEFAULT_OUTPUT_DIR_PATH}}"

function archivePathSimulator {
  local DIR=${OUTPUT_DIR_PATH}/archives/"${1}-SIMULATOR"
  echo "${DIR}"
}

function archivePathDevice {
  local DIR=${OUTPUT_DIR_PATH}/archives/"${1}-DEVICE"
  echo "${DIR}"
}

# Build workspace to include cocoapod dependency
function archive {
    echo "▸ Starts archiving the scheme: ${1} for destination: ${2};\n▸ Archive path: ${3}.xcarchive"
    xcodebuild archive \
    -workspace "${PROJECT_NAME}.xcworkspace" \
    -scheme ${1} \
    -destination "${2}" \
    -archivePath "${3}" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES 
    # | xcpretty
}

# Builds archive for iOS simulator & device + macOS
function buildArchive {
  SCHEME=${1}

  archive $SCHEME "generic/platform=iOS Simulator" $(archivePathSimulator $SCHEME)
  archive $SCHEME "generic/platform=iOS" $(archivePathDevice $SCHEME)
}

# Creates xc framework
function createXCFramework {
  FRAMEWORK_ARCHIVE_PATH_POSTFIX=".xcarchive/Products/Library/Frameworks"
  FRAMEWORK_SIMULATOR_DIR="$(archivePathSimulator $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"
  FRAMEWORK_DEVICE_DIR="$(archivePathDevice $1)${FRAMEWORK_ARCHIVE_PATH_POSTFIX}"
  xcodebuild -create-xcframework \
            -framework ${FRAMEWORK_SIMULATOR_DIR}/${1}.framework \
            -framework ${FRAMEWORK_DEVICE_DIR}/${1}.framework \
            -output ${OUTPUT_DIR_PATH}/xcframeworks/${1}.xcframework
}

# Check if the required arguments are provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <Framework name>"
  exit 1
fi

#### Dynamic Framework ####

DYNAMIC_FRAMEWORK="$1"

echo "▸ Archive $DYNAMIC_FRAMEWORK"
buildArchive ${DYNAMIC_FRAMEWORK}

echo "▸ Create $DYNAMIC_FRAMEWORK.xcframework"
createXCFramework ${DYNAMIC_FRAMEWORK}

cd "$OUTPUT_DIR_PATH/xcframeworks/$DYNAMIC_FRAMEWORK.xcframework"

find . -name "*.swiftinterface" -exec sed -i -e "s/$DYNAMIC_FRAMEWORK\.//g" {} \;