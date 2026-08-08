#!/usr/bin/env bash

set -euo pipefail

docker compose run --rm -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" init

service="${DRUPAL_SERVICE:-drupal}"
custom_dir="${DRUPAL_CUSTOM_DIR:-web/modules/custom}"

docker compose up --remove-orphans --wait --wait-timeout "${COMPOSE_WAIT_TIMEOUT:-900}" -d
sitectl healthcheck --persist --timeout "${SITECTL_HEALTHCHECK_TIMEOUT:-10m}"
sitectl verify --strict

docker compose exec -T \
  -e CUSTOM_DIR="${custom_dir}" \
  "${service}" \
  bash -lc '
    set -euo pipefail

    if [ ! -d "${CUSTOM_DIR}" ]; then
      echo "No custom Drupal module directory found at ${CUSTOM_DIR}; baseline application assertions passed."
      exit 0
    fi

    if ! find "${CUSTOM_DIR}" -type f \( -path "*/tests/src/*" -o -name "*Test.php" \) | grep -q .; then
      echo "No custom Drupal tests found under ${CUSTOM_DIR}; baseline application assertions passed."
      exit 0
    fi

    if [ ! -x vendor/bin/phpunit ]; then
      echo "vendor/bin/phpunit was not found in the Drupal container" >&2
      exit 1
    fi

    su nginx -s /bin/bash -c "php vendor/bin/phpunit -c phpunit.unit.xml --debug ${CUSTOM_DIR}"
  '
