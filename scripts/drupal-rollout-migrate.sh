#!/usr/bin/env sh

set -eu

cd /var/www/drupal

/var/www/drupal/vendor/bin/drush updb -y
/var/www/drupal/vendor/bin/drush cr
