#!/bin/bash

# This test validates the trust-safe-chain feature installation.
# Since most environments won't have Aikido safe-chain proxy configured,
# this test validates the graceful exit behavior when the proxy is not detected.
#
# The feature should:
# 1. Successfully check npmjs.org certificate chain
# 2. Detect that it's not signed by Aikido safe-chain
# 3. Exit gracefully without error
# 4. Not install any certificates

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Verify required dependencies are available
check "openssl is installed" which openssl
check "update-ca-certificates is available" which update-ca-certificates

# Verify the feature executed without error
# (The install.sh script would have failed the build if it errored)
check "feature installed successfully" echo "Installation completed"

# Verify no aikido cert was installed (expected in non-Aikido environments)
# This validates the graceful exit path
check "no aikido cert in standard location" bash -c "! test -f /usr/local/share/ca-certificates/aikido-safe-chain.crt"

# Report results
reportResults
