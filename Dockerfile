ARG BASE_IMAGE=libops/drupal:nginx-1.30.3-php84
FROM ${BASE_IMAGE}

ARG TARGETARCH

WORKDIR /var/www/drupal

COPY --link composer.json composer.lock /var/www/drupal/

RUN mkdir -p /var/www/drupal/assets && \
    cp /usr/share/drupal/default_settings.txt /var/www/drupal/assets/default_settings.txt

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
    DRUPAL_DEFAULT_ACCOUNT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_ACCOUNT_NAME=admin \
    DRUPAL_DEFAULT_CONFIGDIR=/var/www/drupal/config/sync \
    DRUPAL_DEFAULT_INSTALL_EXISTING_CONFIG=true \
    DRUPAL_DEFAULT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_LOCALE=en \
    DRUPAL_DEFAULT_NAME=Drupal \
    DRUPAL_DEFAULT_PROFILE=minimal \
    DRUPAL_DEFAULT_SUBDIR=default \
    INGRESS_HOSTNAMES=localhost \
    INGRESS_SCHEME=http \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000

RUN chown -R nginx:nginx /var/www/drupal
