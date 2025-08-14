#!/bin/bash
# Test Cloudflare MCP R2 operations
set -euo pipefail

echo "Testing Cloudflare MCP R2 integration..."

# This script will use Claude Code's Cloudflare MCP to:
# 1. List R2 bucket contents
# 2. Upload a test file
# 3. Download and verify

# Create test file
echo "Test file for CF MCP R2 operations" > /tmp/test-cf-r2.txt

echo "Created test file: /tmp/test-cf-r2.txt"
echo "Ready to test CF MCP operations manually through Claude"