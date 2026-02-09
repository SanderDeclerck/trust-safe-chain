#!/bin/sh

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo "${BOLD}Checking npmjs.org certificate chain...${RESET}"

# 1. Create temp dir
TEMP_DIR=$(mktemp -d)
SSL_OUTPUT="$TEMP_DIR/tls-output.txt"
echo "${BLUE}Using temporary directory: ${TEMP_DIR}${RESET}"

# 2. Store cert chain 
echo "${BLUE}Fetching certificate chain from registry.npmjs.org...${RESET}"
echo | openssl s_client -connect registry.npmjs.org:443 -servername registry.npmjs.org -showcerts 2>/dev/null > $SSL_OUTPUT

# 3. Split certificates into separate files
echo "${BLUE}Extracting certificates...${RESET}"
LAST_CERT=$(awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {
    if (/BEGIN CERTIFICATE/) {
        cert_count++
        filename = sprintf("'"$TEMP_DIR"'/cert-%d.pem", cert_count)
    }
    print > filename
}
END {
    print filename
}' "$SSL_OUTPUT")

echo "${BLUE}Found root certificate: ${LAST_CERT}${RESET}"

# 4. Check the issuer
ISSUER=$(openssl x509 -in "$LAST_CERT" -noout -issuer)
echo "${BLUE}Root certificate issuer: ${ISSUER}${RESET}"

# Check if the issuer contains both key identifiers (more robust than exact match)
if ! echo "$ISSUER" | grep -q "Aikido safe-chain proxy" || ! echo "$ISSUER" | grep -q "aikidosafechain.com"; then
    echo "${YELLOW}The certificate of npmjs is not signed by aikido safe-chain, nothing to do here${RESET}"
    rm -rf $TEMP_DIR
    exit 0
fi

# 5. Copy to trusted certificates
echo "${GREEN}Certificate is signed by Aikido safe-chain proxy, installing...${RESET}"
echo "${BLUE}Installing to: /usr/local/share/ca-certificates/aikido-safe-chain.crt${RESET}"
cp "$LAST_CERT" /usr/local/share/ca-certificates/aikido-safe-chain.crt
update-ca-certificates
echo "${GREEN}✓ Certificate successfully installed to system trust store${RESET}"

# 6. Cleanup
echo "${BLUE}Cleaning up temporary files...${RESET}"
rm -rf $TEMP_DIR

echo "${GREEN}${BOLD}Done!${RESET}"
