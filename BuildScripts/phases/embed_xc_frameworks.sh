# THIS SCRIPT IS ONLY MEANT TO BE RUN FROM INSIDE XCODE BUILD PHASES
# IT USES XCODE SPECIFIC ENV VARIABLES

SCG="SCGateway"
LOANS="Loans"

if [ "$USE_XC_FRAMEWORKS" == "YES" ]; then
    
    cd "$SRCROOT"
    manage_framework_script="BuildScripts/manage_framework.rb"
    
    ruby $manage_framework_script --remove --framework="$SCG.framework" --project="$PROJECT_FILE_PATH" --target="$TARGET_NAME"
    ruby $manage_framework_script --remove --framework="$LOANS.framework" --project="$PROJECT_FILE_PATH" --target="$TARGET_NAME"
    
    ruby $manage_framework_script --add --framework="$SCG.xcframework" --frameworkPath="$SCG_XCF_PATH" --project="$PROJECT_FILE_PATH" --target="$TARGET_NAME"
    ruby $manage_framework_script --add --framework="$LOANS.xcframework" --frameworkPath="$LOANS_XCF_PATH" --project="$PROJECT_FILE_PATH" --target="$TARGET_NAME"
fi