<?php

declare(strict_types=1);

$active = \Drupal::service('config.storage');
$directory = \Drupal\Core\Site\Settings::get('config_sync_directory');
$result = [];

if (is_string($directory) && $directory !== '') {
    $sync = new \Drupal\Core\Config\FileStorage($directory);
    $names = array_unique(array_merge($active->listAll(), $sync->listAll()));
    sort($names);

    foreach ($names as $name) {
        $activeData = $active->read($name);
        $syncData = $sync->read($name);
        if (!is_array($activeData) || !is_array($syncData) || $activeData === $syncData) {
            continue;
        }

        $keys = array_unique(array_merge(array_keys($activeData), array_keys($syncData)));
        sort($keys);
        foreach ($keys as $key) {
            if (
                !array_key_exists($key, $activeData)
                || !array_key_exists($key, $syncData)
                || $activeData[$key] !== $syncData[$key]
            ) {
                $result[$name][] = $key;
            }
        }
    }
}

print json_encode($result, JSON_THROW_ON_ERROR);
