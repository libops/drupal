#!/usr/bin/env bash

set -euo pipefail

docker compose run --rm -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" init

service="${DRUPAL_SERVICE:-drupal}"
custom_dir="${DRUPAL_CUSTOM_DIR:-web/modules/custom}"

docker compose up --remove-orphans -d "${service}"

docker compose exec -T \
  -e CUSTOM_DIR="${custom_dir}" \
  -e RUN_PHPCBF="${RUN_PHPCBF:-0}" \
  "${service}" \
  /usr/local/lib/sitectl/drupal-lint-custom.sh
