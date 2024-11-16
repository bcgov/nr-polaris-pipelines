#!/usr/bin/env bash
export GENERATED_JWT="${GENERATED_JWT}"
export INSTALLATION_ID="${INSTALLATION_ID}"
github_api_url="https://api.github.com/app/installations/${INSTALLATION_ID}/access_tokens"
tokens=$(curl -s -X POST \
    -H "Authorization: Bearer ${GENERATED_JWT}" \
    -H "Accept: application/vnd.github.v3+json" \
    "${github_api_url}" )

# extract the token, more information about expiry for example is present as well:
# this token can be used to call the API's or used in a Git clone call using https
token=$(echo "$tokens" | jq -r '.token')
echo "${token}"
