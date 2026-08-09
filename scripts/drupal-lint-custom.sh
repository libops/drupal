#!/usr/bin/env bash

set -euo pipefail

custom_dir="${CUSTOM_DIR:-web/modules/custom}"

if [ ! -d "$custom_dir" ]; then
  echo "No custom Drupal module directory found at $custom_dir; skipping Drupal code lint."
  exit 0
fi

if ! find "$custom_dir" -type f \( -name '*.module' -o -name '*.php' -o -name '*.inc' \) | grep -q .; then
  echo "No custom Drupal PHP files found under $custom_dir; skipping Drupal code lint."
  exit 0
fi

cp web/core/phpcs.xml.dist . 2>/dev/null || true

if [ "${RUN_PHPCBF:-0}" = "1" ]; then
  if [ ! -x vendor/bin/phpcbf ]; then
    echo 'vendor/bin/phpcbf was not found in the Drupal container' >&2
    exit 1
  fi

  php vendor/bin/phpcbf \
    -n \
    --standard=Drupal,DrupalPractice \
    --extensions=module,php,inc \
    "$custom_dir" || true
fi

if [ ! -x vendor/bin/phpcs ]; then
  echo 'vendor/bin/phpcs was not found in the Drupal container' >&2
  exit 1
fi

php vendor/bin/phpcs \
  -n \
  --standard=Drupal,DrupalPractice \
  --extensions=module,php,inc \
  "$custom_dir"

echo 'PHP codesniff passed'
