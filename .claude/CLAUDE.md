# Claude Code Runtime Instructions

## Repository Scope
This repository provisions Cloudflare-native enterprise infrastructure with OpenTofu/Terraform, bash automation, and policy-centric guardrails.

## Non-Negotiable Security Controls
- Validate required runtime variables before every write operation.
- Use dedicated API tokens; reject shared global tokens.
- Enforce MFA/WebAuthn/mTLS controls for finance workloads.
- Keep scripts idempotent and rollback-capable.

## Execution Order
1. `make -C zeaz-platform validate`
2. `make -C zeaz-platform plan-tier`
3. `make -C zeaz-platform mcp-config`
4. `make -C zeaz-platform plan`
5. `make -C zeaz-platform apply`
6. `make -C zeaz-platform drift`

## MCP and AI Tooling
Use `.mcp.json` endpoints for Cloudflare-compatible MCP workflows and only execute allowlisted commands from `zeaz-platform/scripts/ai/bootstrap-agents.sh`.


## MCP Runtime
- Regenerate local MCP config with `make -C zeaz-platform mcp-config` after token rotation.
