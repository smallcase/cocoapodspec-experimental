# THIS SCRIPT IS ONLY MEANT TO BE RUN FROM INSIDE XCODE BUILD PHASES
# IT USES XCODE SPECIFIC ENV VARIABLES

SCG="SCGateway"
LOANS="Loans"

SCG_F_PATH="$TARGET_BUILD_DIR/$SCG.framework"
LOANS_F_PATH="$TARGET_BUILD_DIR/$LOANS.framework"

SCG_XCF_PATH="$SRCROOT/.build/Products/$SCG.xcframework"
LOANS_XCF_PATH="$SRCROOT/.build/Products/$LOANS.xcframework"

if [ "$USE_XC_FRAMEWORKS" == "YES" ]; then
    echo "Linking and Embedding XCFrameworks..."
    
    cd $BUILD_DIR
    
    xcodebuild -create-xcframework \
    -framework "Debug-iphoneos/$SCG.framework" \
    -framework "Debug-iphonesimulator/$SCG.framework" \
    -output "$SCG_XCF_PATH"
    
    cd "$SCG_XCF_PATH"
    find . -name "*.swiftinterface" -exec sed -i -e "s/$SCG\.//g" {} \;
    
    cd $BUILD_DIR
    
    xcodebuild -create-xcframework \
    -framework "Debug-iphoneos/$LOANS.framework" \
    -framework "Debug-iphonesimulator/$LOANS.framework" \
    -output "$LOANS_XCF_PATH"
    
    cd "$LOANS_XCF_PATH"
    find . -name "*.swiftinterface" -exec sed -i -e "s/$LOANS\.//g" {} \;
    
    cd "$SRCROOT"
    manage_framework_script="BuildScripts/manage_framework.rb"
    
    ruby $manage_framework_script --remove --framework="$SCG.framework" --project="$PROJECT_FILE_PATH" --target="$TARGET_NAME"
    ruby $manage_framework_script --remove --framework="$LOANS.framework" --project="$PROJECT_FILE_PATH" --target="$TARGET_NAME"
    
    ruby $manage_framework_script --add --framework="$SCG.xcframework" --frameworkPath="$SCG_XCF_PATH" --project="$PROJECT_FILE_PATH" --target="$TARGET_NAME"
    ruby $manage_framework_script --add --framework="$LOANS.xcframework" --frameworkPath="$LOANS_XCF_PATH" --project="$PROJECT_FILE_PATH" --target="$TARGET_NAME"
fi