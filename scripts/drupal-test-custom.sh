#!/usr/bin/env bash

set -euo pipefail

custom_dir="${CUSTOM_DIR:-web/modules/custom}"

if [ ! -d "$custom_dir" ]; then
  echo "No custom Drupal module directory found at $custom_dir; baseline application assertions passed."
  exit 0
fi

if ! find "$custom_dir" -type f \( -path '*/tests/src/*' -o -name '*Test.php' \) | grep -q .; then
  echo "No custom Drupal tests found under $custom_dir; baseline application assertions passed."
  exit 0
fi

if [ ! -x vendor/bin/phpunit ]; then
  echo 'vendor/bin/phpunit was not found in the Drupal container' >&2
  exit 1
fi

s6-setuidgid nginx php vendor/bin/phpunit -c phpunit.unit.xml --debug "$custom_dir"
