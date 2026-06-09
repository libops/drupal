FROM islandora/drupal:6.3.10@sha256:aad9c52d0e646f5b553e8d2f38008d9d531764ca2c6be021e9d47aed10c515d9

ARG TARGETARCH

COPY assets /var/www/drupal/assets
COPY recipes /var/www/drupal/recipes
COPY web /var/www/drupal/web
COPY composer.json composer.lock /var/www/drupal/

RUN --mount=type=cache,id=custom-drupal-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install && \
    chown -R nginx:nginx . && \
    cleanup.sh

COPY config /var/www/drupal/config

COPY --link rootfs /
