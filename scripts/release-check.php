<?php
// Refuse to package the bootstrap state or development dependencies.
$lock = json_decode(file_get_contents(__DIR__ . '/../composer.lock'), true, 512, JSON_THROW_ON_ERROR);
$config = json_decode(file_get_contents(__DIR__ . '/../composer.json'), true, 512, JSON_THROW_ON_ERROR);
foreach ($config['repositories'] as $repository) {
    if ($repository['type'] === 'path') {
        throw new RuntimeException('Production cannot use path repositories');
    }
}
foreach (['obel', 'aeon', 'rune'] as $name) {
    $matches = array_values(array_filter($lock['packages'], static fn ($package) => $package['name'] === "smededwards/$name"));
    if (count($matches) !== 1 || !preg_match('/^v?\d+\.\d+\.\d+$/D', $matches[0]['version']) || ($matches[0]['dist']['type'] ?? '') === 'path') {
        throw new RuntimeException("Release blocked: $name needs a real tagged release in composer.lock");
    }
}
fwrite(STDOUT, "Tagged release dependencies verified.\n");
