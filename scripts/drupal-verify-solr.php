<?php

declare(strict_types=1);

$server = \Drupal::entityTypeManager()
    ->getStorage('search_api_server')
    ->load('default_solr_server');

print json_encode([
    'exists' => $server !== null,
    'enabled' => $server ? (bool) $server->status() : false,
    'available' => $server ? (bool) $server->isAvailable() : false,
], JSON_THROW_ON_ERROR);
