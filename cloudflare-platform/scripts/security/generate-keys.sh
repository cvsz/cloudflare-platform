#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

mkdir -p secrets

openssl rand -hex 64 > secrets/jwt.secret
openssl rand -base64 64 > secrets/session.secret
openssl rand -hex 48 > secrets/webhook.secret

chmod 600 secrets/*
