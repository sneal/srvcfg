#!/usr/bin/env bash

SERVICE_KEY_FILE=$1
if [ ! -f "$SERVICE_KEY_FILE" ]; then
  echo "Service key file '$SERVICE_KEY_FILE' not found!"
  exit 1
fi

SECRET=$2
if [ -z "$SECRET" ]; then
  echo "You must provide a value to encrypt"
  exit 1
fi

# Read out the URIs and creds from the service key json file
CONFIG_SERVER_URI=$(cat $SERVICE_KEY_FILE | jq -r .uri)
CONFIG_SERVER_USER=$(cat $SERVICE_KEY_FILE | jq -r .client_id)
CONFIG_SERVER_PASS=$(cat $SERVICE_KEY_FILE | jq -r .client_secret)
UAA_URI=$(cat $SERVICE_KEY_FILE | jq -r .access_token_uri)

# Get the OAUTH token from the UAA
TOKEN=$(curl -s -k $UAA_URI -u $CONFIG_SERVER_USER:$CONFIG_SERVER_PASS -d grant_type=client_credentials | jq -r .access_token)

# Submit the secret to the config server's encrypt endpoint
curl -s -H "Authorization: bearer $TOKEN" -H "Accept: application/json" $CONFIG_SERVER_URI/encrypt -d "$SECRET"

echo ''
