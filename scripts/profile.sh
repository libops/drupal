#!/usr/bin/env bash

set -euf -o pipefail

RESET=""
RED=""
GREEN=""
BLUE=""
YELLOW=""
if command -v tput >/dev/null 2>&1 && [ -n "${TERM:-}" ]; then
    RESET="$(tput sgr0 2>/dev/null || true)"
    RED="$(tput setaf 9 2>/dev/null || true)"
    GREEN="$(tput setaf 2 2>/dev/null || true)"
    BLUE="$(tput setaf 6 2>/dev/null || true)"
    YELLOW="$(tput setaf 3 2>/dev/null || true)"
fi
readonly RESET RED GREEN BLUE YELLOW
# Export color codes for use by sourcing scripts
export RESET RED GREEN BLUE YELLOW

# Alias for echo -e to avoid shellcheck warnings about printf format strings
# shellcheck disable=SC2039,SC3044
echo_e() {
    echo -e "$@"
}

is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null || false
}

DEVELOPMENT_ENVIRONMENT="${DEVELOPMENT_ENVIRONMENT:-false}"
export DEVELOPMENT_ENVIRONMENT

status_dev() {
    [ "${STATUS_DEV:-false}" = "true" ]
}

is_docker_rootless() {
    status_dev || docker info -f "{{println .SecurityOptions}}" | grep -qi rootless
}

is_dev_mode() {
    status_dev || [ "${DEVELOPMENT_ENVIRONMENT:-}" = "true" ]
}

compose_env_value() {
    local service="$1"
    local key="$2"

    docker compose config 2>/dev/null | awk -v service="${service}:" -v key="${key}:" '
        $1 == service { in_service=1; in_env=0; next }
        in_service && /^[[:space:]]{2}[[:alnum:]_-]+:/ && $1 != service { in_service=0; in_env=0 }
        in_service && $1 == "environment:" { in_env=1; next }
        in_service && in_env && $1 == key {
            sub("^[[:space:]]*" key "[[:space:]]*", "")
            gsub(/^"|"$/, "")
            print
            exit
        }
    '
}

site_url() {
    local configured="${SITE_URL:-}"

    if [ -n "$configured" ]; then
        printf '%s\n' "$configured"
        return
    fi

    local hostnames hostname scheme
    hostnames="$(compose_env_value drupal INGRESS_HOSTNAMES || true)"
    hostname="${hostnames%%,*}"
    hostname="${hostname//[[:space:]]/}"
    scheme="$(compose_env_value drupal INGRESS_SCHEME || true)"
    printf '%s://%s\n' "${scheme:-http}" "${hostname:-localhost}"
}
