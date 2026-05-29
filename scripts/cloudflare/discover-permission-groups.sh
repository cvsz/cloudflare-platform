#!/usr/bin/env bash
set -eo pipefail

CACHE_DIR=".cache/cloudflare-permissions"
CACHE_FILE="${CACHE_DIR}/permissions.json"
CACHE_EXPIRY=86400 # 24 hours

usage() {
    echo "Usage: $0 [--refresh] [--json]"
    exit 1
}

REFRESH=0
JSON_OUT=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --refresh) REFRESH=1 ;;
        --json) JSON_OUT=1 ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

if [ -z "${CLOUDFLARE_BOOTSTRAP_TOKEN:-}" ]; then
    echo "Error: CLOUDFLARE_BOOTSTRAP_TOKEN environment variable is not set." >&2
    exit 1
fi

mkdir -p "$CACHE_DIR"

fetch_permissions() {
    # Using Cloudflare API to fetch User permission groups
    # Endpoint: GET https://api.cloudflare.com/client/v4/user/tokens/permission_groups
    local response
    response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/permission_groups" \
        -H "Authorization: Bearer ${CLOUDFLARE_BOOTSTRAP_TOKEN}" \
        -H "Content-Type: application/json")
    
    local success
    success=$(echo "$response" | jq -r '.success')
    
    if [ "$success" != "true" ]; then
        echo "Error fetching permissions from Cloudflare API." >&2
        echo "$response" | jq -r '.errors[] | .message' >&2
        exit 1
    fi
    
    echo "$response" > "$CACHE_FILE"
}

if [ "$REFRESH" -eq 1 ] || [ ! -f "$CACHE_FILE" ]; then
    fetch_permissions
else
    # Check if cache is older than 24 hours
    if test "$(find "$CACHE_FILE" -mmin +1440)"; then
        fetch_permissions
    fi
fi

if [ "$JSON_OUT" -eq 1 ]; then
    cat "$CACHE_FILE"
else
    echo "Cloudflare IAM Permission Groups mapped dynamically:"
    jq -r '.result[] | "\(.id) \(.name)"' < "$CACHE_FILE"
fi
