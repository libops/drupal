#!/usr/bin/env bash
# shellcheck shell=bash

# This file generates secrets for files that do not exist yet, it will not
# overwrite existing secrets files.
set -euf -o pipefail

PROGDIR=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
readonly PROGDIR

# Drupal salt is a special case, treat it as such.
SALT_FILE="${PROGDIR}/secrets/DRUPAL_DEFAULT_SALT"
readonly SALT_FILE
if [ ! -f "${SALT_FILE}" ]; then
  echo "Creating: ${SALT_FILE}" >&2
  (grep -ao '[A-Za-z0-9_-]' </dev/urandom || true) | head -74 | tr -d '\n' >"${SALT_FILE}"
fi

# The snippet below list all the secret files referenced by the docker-compose.yml file.
# For each it will generate a random password.
readonly CHARACTERS='[A-Za-z0-9]'
readonly LENGTH=32

declare -a SECRETS
while IFS= read -r line; do
  SECRETS+=("$line")
done < \
  <(
    yq -r '.secrets[].file' "${PROGDIR}/docker-compose.yml" | uniq
  )

for secret in "${SECRETS[@]}"; do
  if [ ! -f "${secret}" ]; then
    echo "Creating: ${secret}" >&2
    (grep -ao "${CHARACTERS}" </dev/urandom || true) | head "-${LENGTH}" | tr -d '\n' > "${secret}"
  fi
done
