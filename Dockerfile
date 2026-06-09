FROM islandora/drupal:6.4.3@sha256:0a4b11d1412eb78db33cf532874fb44b6c6f00e1de34c5cb8792a3cb97386bb0

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
