#!/usr/bin/env bash

set -euo pipefail

require_regular_file() {
  local path="$1"

  if [ ! -f "${path}" ] || [ -L "${path}" ]; then
    echo "This checkout is missing a required Drupal template file (${path}); migrate it to template v1.2.0 or newer before deploying" >&2
    exit 1
  fi
}

require_executable_file() {
  local path="$1"

  require_regular_file "${path}"
  if [ ! -x "${path}" ]; then
    echo "This checkout has a non-executable Drupal template program (${path}); restore it from template v1.2.0 or newer before deploying" >&2
    exit 1
  fi
}

require_executable_file "${BASH_SOURCE[0]}"
require_regular_file compose.yaml
require_executable_file scripts/drupal-wait-installed.sh
require_executable_file scripts/drupal-rollout-migrate.sh
require_regular_file scripts/drupal-verify-cron-queue.php
require_regular_file scripts/drupal-verify-solr.php
require_regular_file scripts/drupal-verify-config-drift.php
