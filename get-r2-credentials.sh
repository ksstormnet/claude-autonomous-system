#!/bin/bash
# Standalone R2 credential retrieval script
# This script can be run independently to test 1Password integration
set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

# Load service account token from shell configuration
if [[ -f ~/.bashrc ]] && grep -q "OP_SERVICE_ACCOUNT_TOKEN" ~/.bashrc; then
    eval $(grep "OP_SERVICE_ACCOUNT_TOKEN" ~/.bashrc)
    log "✓ Service account token loaded from ~/.bashrc"
fi

# Verify token is set
if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    error "OP_SERVICE_ACCOUNT_TOKEN not set. Please run:
export OP_SERVICE_ACCOUNT_TOKEN=your-token"
fi

# Test 1Password authentication
log "Testing 1Password authentication..."
if ! op whoami &>/dev/null; then
    error "1Password authentication failed. Error details:
$(op whoami 2>&1)"
fi

log "✓ 1Password authenticated as: $(op whoami)"

# Retrieve R2 credentials from Desktop Credentials vault
log "Retrieving R2 credentials from Desktop Credentials vault..."

access_key=$(op item get "R2-Claude-System" --vault="Desktop Credentials" --field="access-key" 2>/dev/null) || {
    error "Failed to retrieve access-key. Please ensure:
1. R2-Claude-System item exists in Desktop Credentials vault
2. Service account has access to Desktop Credentials vault
3. Item has 'access-key' field"
}

secret_key=$(op item get "R2-Claude-System" --vault="Desktop Credentials" --field="secret-key" 2>/dev/null) || {
    error "Failed to retrieve secret-key from R2-Claude-System item"
}

# Endpoint is optional, use default if not found
if endpoint_url=$(op item get "R2-Claude-System" --vault="Desktop Credentials" --field="endpoint" 2>/dev/null); then
    log "✓ Custom endpoint retrieved: $endpoint_url"
else
    endpoint_url="https://54919652c0ba9b83cb0ae04cb5ea90f3.r2.cloudflarestorage.com"
    log "✓ Using default endpoint: $endpoint_url"
fi

# Export credentials to current session
export AWS_ACCESS_KEY_ID="$access_key"
export AWS_SECRET_ACCESS_KEY="$secret_key"
export AWS_ENDPOINT_URL="$endpoint_url"

log "✓ R2 credentials successfully retrieved and exported"
log "Access Key: ${access_key:0:10}..."
log "Secret Key: ${secret_key:0:10}..."
log "Endpoint: $endpoint_url"

# Test Wrangler R2 operation
log "Testing Cloudflare R2 access..."
if CLOUDFLARE_ACCOUNT_ID="54919652c0ba9b83cb0ae04cb5ea90f3" npx wrangler r2 bucket list &>/dev/null; then
    log "✓ Wrangler R2 access successful"
else
    log "⚠ Wrangler R2 access test failed (credentials may still work for deployment)"
fi

log "✓ Credential retrieval complete - ready for deployment"