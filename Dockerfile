ARG BASE_IMAGE=libops/drupal:php84
FROM ${BASE_IMAGE}

ARG TARGETARCH

ENV \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_MEMORY_LIMIT=-1
WORKDIR /var/www/drupal

COPY --link composer.json composer.lock /var/www/drupal/
COPY --link assets/ /var/www/drupal/assets/

RUN --mount=type=cache,id=custom-drupal-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/drupal --no-interaction --no-progress --prefer-dist --no-dev --optimize-autoloader && \
    cleanup.sh

COPY --link config/ /var/www/drupal/config/
COPY --link web/modules/custom/ /var/www/drupal/web/modules/custom/
COPY --link web/themes/custom/ /var/www/drupal/web/themes/custom/
COPY --link rootfs/opt/ /opt/

ENV \
    DB_HOST=mariadb \
    DB_PORT=3306 \
    DB_NAME=drupal \
    DB_USER=drupal \
    DB_PASSWORD=changeme \
    DRUPAL_DEFAULT_ACCOUNT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_ACCOUNT_NAME=admin \
    DRUPAL_DEFAULT_ACCOUNT_PASSWORD=password \
    DRUPAL_DEFAULT_CONFIGDIR=/var/www/drupal/config/sync \
    DRUPAL_DEFAULT_INSTALL_EXISTING_CONFIG=true \
    DRUPAL_DEFAULT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_LOCALE=en \
    DRUPAL_DEFAULT_NAME=Drupal \
    DRUPAL_DEFAULT_PROFILE=minimal \
    DRUPAL_DEFAULT_SALT=9PPaL0CxZAIcq6h5wxgDGlCZrp7JdT_x7v9gVzpdbUjMt1PqDz3uD0Zy-i16DuJ1-Htfshhqeg \
    DRUPAL_DEFAULT_SUBDIR=default \
    DRUPAL_ENABLE_HTTPS=false \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000

RUN chown -R nginx:nginx /var/www/drupal
