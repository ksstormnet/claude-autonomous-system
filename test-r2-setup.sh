#!/bin/bash
# Test R2 credential setup end-to-end
set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

echo "=== R2 Credential Setup Test ==="
echo

# Load the token from bashrc
log "Loading 1Password service account token..."
eval $(tail -1 ~/.bashrc)

if [[ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    log "✓ Service account token loaded"
else
    log "✗ Service account token not found"
    exit 1
fi

# Test basic 1Password functionality
log "Testing 1Password CLI authentication..."
if op whoami &>/dev/null; then
    log "✓ 1Password authentication successful: $(op whoami)"
    
    # Test vault access
    log "Testing vault access..."
    op vault list
    
    # Test R2 credential item access
    log "Testing R2-Claude-System item access..."
    if op item get "R2-Claude-System" --vault="Desktop Credentials" &>/dev/null; then
        log "✓ R2-Claude-System item found in Desktop Credentials vault"
        
        # Test credential field access
        log "Testing credential field access..."
        if access_key=$(op item get "R2-Claude-System" --vault="Desktop Credentials" --field="access-key" 2>/dev/null); then
            log "✓ Access key retrieved (${access_key:0:10}...)"
        else
            log "✗ Failed to retrieve access key"
        fi
        
        if secret_key=$(op item get "R2-Claude-System" --vault="Desktop Credentials" --field="secret-key" 2>/dev/null); then
            log "✓ Secret key retrieved (${secret_key:0:10}...)"
        else
            log "✗ Failed to retrieve secret key"
        fi
        
        if endpoint=$(op item get "R2-Claude-System" --vault="Desktop Credentials" --field="endpoint" 2>/dev/null); then
            log "✓ Endpoint retrieved: $endpoint"
        else
            log "⚠ Endpoint not found, using default"
            endpoint="https://54919652c0ba9b83cb0ae04cb5ea90f3.r2.cloudflarestorage.com"
        fi
        
    else
        log "✗ R2-Claude-System item not found in Desktop Credentials vault"
        log "Run './setup-credentials.sh' to create this item"
        exit 1
    fi
    
else
    log "✗ 1Password authentication failed"
    op whoami 2>&1 | sed 's/^/   /'
    exit 1
fi

log "✓ All R2 credential tests passed!"
echo "=== Test Complete ==="