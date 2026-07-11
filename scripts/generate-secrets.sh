#!/usr/bin/env bash
# shellcheck shell=bash

# This file generates secrets for files that do not exist yet, it will not
# overwrite existing secrets files.
set -euf -o pipefail

umask 077

PROGDIR=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
readonly PROGDIR
install -d -m 0700 "${PROGDIR}/secrets"

# Drupal salt is a special case, treat it as such.
SALT_FILE="${PROGDIR}/secrets/DRUPAL_DEFAULT_SALT"
readonly SALT_FILE
if [ ! -s "${SALT_FILE}" ]; then
  echo "Creating: ${SALT_FILE}" >&2
  (grep -ao '[A-Za-z0-9_-]' </dev/urandom || true) | head -74 | tr -d '\n' >"${SALT_FILE}"
fi
chmod 0600 "${SALT_FILE}"

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
  case "${secret}" in
    ./*) secret="${PROGDIR}/${secret#./}" ;;
  esac
  case "${secret}" in
    "${PROGDIR}"/certs/*) continue ;;
  esac
  if [ ! -s "${secret}" ]; then
    echo "Creating: ${secret}" >&2
    install -d -m 0700 "$(dirname -- "${secret}")"
    (grep -ao "${CHARACTERS}" </dev/urandom || true) | head "-${LENGTH}" | tr -d '\n' >"${secret}"
  fi
  chmod 0600 "${secret}"
done
