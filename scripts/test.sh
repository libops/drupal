#!/usr/bin/env bash

set -euo pipefail

bash scripts/sitectl-rollout-preflight.sh
docker compose run --rm -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" init

service="${DRUPAL_SERVICE:-drupal}"
custom_dir="${DRUPAL_CUSTOM_DIR:-web/modules/custom}"

docker compose up --remove-orphans --wait --wait-timeout "${COMPOSE_WAIT_TIMEOUT:-900}" -d
sitectl healthcheck --persist --timeout "${SITECTL_HEALTHCHECK_TIMEOUT:-10m}"
sitectl verify --strict

docker compose exec -T \
  -e CUSTOM_DIR="${custom_dir}" \
  "${service}" \
  /usr/local/lib/sitectl/drupal-test-custom.sh
