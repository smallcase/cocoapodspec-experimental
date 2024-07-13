#!/usr/bin/env bash
# THIS SCRIPT IS ONLY MEANT TO BE RUN FROM INSIDE BITRISE WORKFLOWS
# IT USES BITRISE SPECIFIC ENV VARIABLES
set -e
set -o pipefail
set -x

create_pod() {
    local should_release="$1"
    local spec_path="$2"
    local framework_path="$3"

    local name=$(pod ipc spec "$spec_path" | jq -r '.name')
    local deploy_json_spec_path=".build/podspecs/$name.podspec.json"

    mkdir -p "$(dirname "$deploy_json_spec_path")"
    pod ipc spec "$spec_path" >"$deploy_json_spec_path"

    # Create an indexed array for the pod
    local pod=("$name" "$should_release" "$spec_path" "$framework_path" "$deploy_json_spec_path")

    # Return the pod array
    echo "${pod[@]}"
}

pods=()

scheme="$BITRISE_SCHEME"
SCG_XC_FRAMEWORK_PATH=${SCG_XC_FRAMEWORK_PATH:-".build/Frameworks/$scheme/xcframeworks/SCGateway.xcframework"}
LOANS_XC_FRAMEWORK_PATH=${LOANS_XC_FRAMEWORK_PATH:-".build/Frameworks/$scheme/xcframeworks/Loans.xcframework"}

pods+=("$(create_pod "$RELEASE_SCG" "$SCG_PODSPEC" "$SCG_XC_FRAMEWORK_PATH")")
pods+=("$(create_pod "$RELEASE_LOANS" "$LOANS_PODSPEC" "$LOANS_XC_FRAMEWORK_PATH")")

# Prints the array
# echo ${pods[@]}
# Count of array
# echo ${#pods[@]}

repo="$COCOA_REPO"
repo_url="$COCOA_REPO_URL"

for pod_data in "${pods[@]}"; do
    # Split the pod_data string into an array and assign to pod
    IFS=' ' read -r -a pod <<<"$pod_data"

    # echo "Pod name: ${pod[0]}"
    # echo "Should release pod: ${pod[1]}"
    # echo "Spec source: ${pod[2]}"
    # echo "Framework path: ${pod[3]}"
    # echo "Deploy spec path: ${pod[4]}"

    if [[ "${pod[1]}" == "true" ]]; then
        echo "Releasing ${pod[0]} with spec source at ${pod[2]} and created deploy spec at ${pod[4]}"
        cat "${pod[4]}"
        $SCLI_PATH cocoapodDeploy --cocoapodDeploy.framework "${pod[3]}" --cocoapodDeploy.podspec "${pod[4]}" --cocoapodDeploy.repo "$repo" --cocoapodDeploy.repoUrl "$repo_url"
    else
        echo "Skipping release for ${pod[0]}"
    fi
done
