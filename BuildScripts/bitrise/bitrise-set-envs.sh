#!/bin/bash

# THIS SCRIPT IS ONLY MEANT TO BE RUN FROM INSIDE BITRISE
# IT USES THE $ENV_FILE ENV Variable from .bitrise.secrets.yml

# Fail if any commands fail
set -e
# Make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# Debug log
set -x

# Define the path to your properties file
env_file="$ENV_FILE"

# Check if the properties file exists
if [[ ! -f "$env_file" ]]; then
    echo "Properties file not found: $env_file"
else
    # Read the properties file line by line and set environment variables
    while read -r line || [[ -n "$line" ]]; do
        if [[ $line != \#* && $line != '' ]]; then # Skip comments and empty lines
            key=$(echo "$line" | cut -d '=' -f 1)
            value=$(echo "$line" | cut -d '=' -f 2-)
            envman add --key "$key" --value "$value"
            export "$key=$value"
        fi
    done <$env_file
fi

# Loop through all environment variables
for var in $(env | grep -o '^OVERRIDE_[^=]*'); do
    # Extract the base variable name by removing the 'OVERRIDE_' prefix
    base_var=${var#OVERRIDE_}

    # Get the value of the OVERRIDE_ variable
    override_value=$(eval echo \$$var)

    echo "Overriding $base_var with $override_value"
    envman add --key "$base_var" --value "$override_value"
    export "$base_var=$override_value"
done

printenv | sort
