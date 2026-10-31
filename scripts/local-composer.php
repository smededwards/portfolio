<?php
/** Keep local path overrides and lock isolated from the deployment manifest. */
$root = dirname(__DIR__);
$config = json_decode(file_get_contents("$root/composer.json"), true, 512, JSON_THROW_ON_ERROR);
foreach (['obel', 'aeon', 'rune'] as $name) {
    if (!file_exists("$root/../$name/composer.json")) {
        throw new RuntimeException("Missing neighbouring package: $name");
    }
    $config['require']["smededwards/$name"] = 'dev-main';
}

// Keep production-only plugins out of the local development installation.
unset($config['require']['wp-plugin/breeze']);

array_unshift($config['repositories'], ['type' => 'path', 'url' => '../*', 'options' => ['symlink' => true, 'versions' => ['smededwards/obel' => 'dev-main', 'smededwards/aeon' => 'dev-main', 'smededwards/rune' => 'dev-main']]]);
file_put_contents("$root/composer.local.json", json_encode($config, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n");
