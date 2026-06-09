#!/usr/bin/env bash

set -euo pipefail

service="${DRUPAL_SERVICE:-drupal}"
custom_dir="${DRUPAL_CUSTOM_DIR:-web/modules/custom}"

docker compose up --remove-orphans -d "${service}"

docker compose exec -T \
  -e CUSTOM_DIR="${custom_dir}" \
  -e RUN_PHPCBF="${RUN_PHPCBF:-0}" \
  "${service}" \
  bash -lc '
    set -euo pipefail

    if [ ! -d "${CUSTOM_DIR}" ]; then
      echo "No custom Drupal module directory found at ${CUSTOM_DIR}; skipping Drupal code lint."
      exit 0
    fi

    if ! find "${CUSTOM_DIR}" -type f \( -name "*.module" -o -name "*.php" -o -name "*.inc" \) | grep -q .; then
      echo "No custom Drupal PHP files found under ${CUSTOM_DIR}; skipping Drupal code lint."
      exit 0
    fi

    cp web/core/phpcs.xml.dist . 2>/dev/null || true

    if [ "${RUN_PHPCBF}" = "1" ]; then
      if [ ! -x vendor/bin/phpcbf ]; then
        echo "vendor/bin/phpcbf was not found in the Drupal container" >&2
        exit 1
      fi

      php vendor/bin/phpcbf \
        -n \
        --standard=Drupal,DrupalPractice \
        --extensions=module,php,inc \
        "${CUSTOM_DIR}" || true
    fi

    if [ ! -x vendor/bin/phpcs ]; then
      echo "vendor/bin/phpcs was not found in the Drupal container" >&2
      exit 1
    fi

    php vendor/bin/phpcs \
      -n \
      --standard=Drupal,DrupalPractice \
      --extensions=module,php,inc \
      "${CUSTOM_DIR}"

    echo "PHP codesniff passed"
  '
