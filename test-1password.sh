#!/bin/bash
# Test script for 1Password CLI integration
set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

echo "=== 1Password CLI Integration Test ==="
echo

# Test 1: Check CLI installation
echo "1. Testing 1Password CLI installation:"
if command -v op &> /dev/null; then
    echo "   ✓ 1Password CLI version: $(op --version)"
else
    echo "   ✗ 1Password CLI not found"
    exit 1
fi
echo

# Test 2: Check environment variable
echo "2. Checking service account token:"
if [[ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    echo "   ✓ Service account token is set"
    echo "   Token starts with: ${OP_SERVICE_ACCOUNT_TOKEN:0:10}..."
else
    echo "   ✗ OP_SERVICE_ACCOUNT_TOKEN not set"
    echo "   To set: export OP_SERVICE_ACCOUNT_TOKEN=your-token"
    exit 1
fi
echo

# Test 3: Test authentication
echo "3. Testing 1Password authentication:"
if op whoami &>/dev/null; then
    echo "   ✓ Authentication successful: $(op whoami)"
else
    echo "   ✗ Authentication failed"
    echo "   Error details:"
    op whoami 2>&1 | sed 's/^/   /'
    echo
    echo "   Possible solutions:"
    echo "   - Verify service account has proper permissions"
    echo "   - Check service account was created for correct 1Password account"
    echo "   - Try recreating the service account"
fi
echo

# Test 4: Test vault access
echo "4. Testing vault access:"
if op vault list &>/dev/null; then
    echo "   ✓ Vault access successful:"
    op vault list | sed 's/^/   /'
else
    echo "   ✗ Vault access failed"
    echo "   This may be due to service account permissions"
fi
echo

# Test 5: Test item access (if R2 credentials exist)
echo "5. Testing R2 credential item access:"
if op item get "R2-Claude-System" --vault="Desktop Credentials" &>/dev/null; then
    echo "   ✓ R2-Claude-System item found in Desktop Credentials vault"
    echo "   ✓ Can access item fields"
else
    echo "   ✗ R2-Claude-System item not found or accessible in Desktop Credentials vault"
    echo "   You may need to:"
    echo "   - Create the R2-Claude-System item in Desktop Credentials vault"
    echo "   - Grant service account access to the Desktop Credentials vault"
    echo "   - Run: ./setup-credentials.sh"
fi
echo

echo "=== Test Complete ==="