#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

log_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
log() { local level="$1"; shift; printf '{"ts":"%s","level":"%s","msg":"%s"}\n' "$(log_ts)" "$level" "$*" >&2; }
info(){ log INFO "$*"; }
warn(){ log WARN "$*"; }
error(){ log ERROR "$*"; }
