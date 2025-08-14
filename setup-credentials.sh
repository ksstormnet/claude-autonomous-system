#!/bin/bash
# Setup script for securely storing R2 credentials in 1Password
set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

# Check if 1Password CLI is available
if ! command -v op &> /dev/null; then
    log "1Password CLI not found. Please install it first:"
    echo "curl -sSfL https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg"
    echo "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list"
    echo "sudo apt update && sudo apt install 1password-cli"
    exit 1
fi

log "Setting up secure R2 credentials in 1Password..."

# Check authentication
if ! op whoami &>/dev/null; then
    log "Please authenticate with 1Password first:"
    echo "Option 1: Desktop integration - Ensure 1Password app is running with CLI integration enabled"
    echo "Option 2: Manual signin - op signin --account your-account.1password.com"
    echo "Option 3: Service account - export OP_SERVICE_ACCOUNT_TOKEN=your-token"
    error "1Password authentication required"
fi

log "Current 1Password account: $(op whoami)"

# Collect R2 credentials securely
echo "Please enter your Cloudflare R2 credentials:"
echo -n "R2 Access Key ID: "
read -r access_key

echo -n "R2 Secret Access Key: "
read -rs secret_key
echo

echo -n "R2 Endpoint URL (optional, press Enter for default): "
read -r endpoint_url

if [[ -z "$endpoint_url" ]]; then
    endpoint_url="https://54919652c0ba9b83cb0ae04cb5ea90f3.r2.cloudflarestorage.com"
fi

# Create 1Password item
log "Creating 1Password item 'R2-Claude-System'..."

# Check if item already exists
if op item get "R2-Claude-System" &>/dev/null; then
    log "Item 'R2-Claude-System' already exists. Updating..."
    op item edit "R2-Claude-System" \
        "access-key[password]=$access_key" \
        "secret-key[password]=$secret_key" \
        "endpoint[url]=$endpoint_url"
else
    log "Creating new item 'R2-Claude-System'..."
    op item create \
        --category="API Credential" \
        --title="R2-Claude-System" \
        "access-key[password]=$access_key" \
        "secret-key[password]=$secret_key" \
        "endpoint[url]=$endpoint_url"
fi

# Clear sensitive variables
unset access_key secret_key endpoint_url

log "✓ R2 credentials securely stored in 1Password"
log "✓ You can now run './deploy.sh' to deploy the system"

# Test retrieval
log "Testing credential retrieval..."
if op item get "R2-Claude-System" --field="access-key" &>/dev/null; then
    log "✓ Credential retrieval test successful"
else
    error "Failed to retrieve credentials from 1Password"
fi

log "Setup complete!"