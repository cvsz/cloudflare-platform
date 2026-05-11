# Cosign Signing

`sign-artifacts.sh` supports:

1. Key-based signing if `COSIGN_KEY` is set.
2. Keyless signing if `COSIGN_EXPERIMENTAL=1` and OIDC ambient identity is available.
3. Safe skip mode when `COSIGN_OPTIONAL=true`.
