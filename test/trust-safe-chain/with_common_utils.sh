#!/bin/bash

# Test the trust-safe-chain feature with common-utils installed first.
# This validates that the installsAfter dependency works correctly.

set -e

source dev-container-features-test-lib

# Verify common-utils tools are available
check "git is installed" which git

# Verify trust-safe-chain dependencies
check "openssl is installed" which openssl
check "update-ca-certificates is available" which update-ca-certificates

# Verify successful installation
check "feature installed successfully" echo "Installation completed"

reportResults
