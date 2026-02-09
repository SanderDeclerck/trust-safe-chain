
# Aikido Trust Safe-Chain (trust-safe-chain)

Automatically installs Aikido safe-chain proxy SSL certificates to the system trust store when detected

## Example Usage

```json
"features": {
    "ghcr.io/SanderDeclerck/trust-safe-chain/trust-safe-chain:1": {}
}
```



## Installation Details

The feature performs the following operations during container build:

1. Creates a temporary directory for certificate processing
2. Uses `openssl s_client` to connect to registry.npmjs.org and capture the certificate chain
3. Extracts individual certificates from the chain
4. Identifies the root certificate
5. Validates the issuer matches "O = Aikido safe-chain proxy, CN = aikidosafechain.com"
6. If validated, installs to `/usr/local/share/ca-certificates/aikido-safe-chain.crt`
7. Updates the system trust store via `update-ca-certificates`
8. Cleans up temporary files

## Troubleshooting

If npm/yarn commands fail with SSL errors after installation:

1. Verify the certificate was installed:
   ```bash
   ls -l /usr/local/share/ca-certificates/aikido-safe-chain.crt
   ```

2. Check if the system trust store was updated:
   ```bash
   update-ca-certificates --verbose
   ```

3. Verify the certificate is trusted:
   ```bash
   openssl s_client -connect registry.npmjs.org:443 -CApath /etc/ssl/certs
   ```

## Security Considerations

This feature only installs certificates when:
- The certificate chain is successfully retrieved from registry.npmjs.org
- The root certificate issuer exactly matches "O = Aikido safe-chain proxy, CN = aikidosafechain.com"

The feature will NOT install certificates if:
- The issuer doesn't match (prevents installing incorrect certificates)
- The connection to npmjs fails
- The certificate chain cannot be parsed


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/SanderDeclerck/trust-safe-chain/blob/main/src/trust-safe-chain/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
