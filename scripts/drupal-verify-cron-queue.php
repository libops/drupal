<?php

declare(strict_types=1);

$cron = \Drupal::service('cron');
$workers = \Drupal::service('plugin.manager.queue_worker')->getDefinitions();

print json_encode([
    'cron' => $cron !== null,
    'queue_workers' => count($workers),
], JSON_THROW_ON_ERROR);
