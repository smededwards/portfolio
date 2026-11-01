<?php
// Generate local-only configuration. Run in the tools container.
$root = dirname(__DIR__);
if (!file_exists("$root/.env")) {
    $env = file_get_contents("$root/.env.example");
    $env = preg_replace_callback('/=GENERATE/', static fn () => '=' . bin2hex(random_bytes(32)), $env);
    $env .= "\nLOCAL_UID=" . (getenv("LOCAL_UID") ?: 501) . "\nLOCAL_GID=" . (getenv("LOCAL_GID") ?: 20) . "\n";
    file_put_contents("$root/.env", $env);
    chmod("$root/.env", 0600);
}
$env = parse_ini_file("$root/.env", false, INI_SCANNER_RAW);
$host = $env['LOCAL_HOST'];
if (!preg_match('/^[a-zA-Z0-9.-]+$/D', $host)) {
    throw new RuntimeException('LOCAL_HOST must be a hostname');
}
$port = (int) ($env['HTTPS_PORT'] ?? 443);
$url = 'https://' . $host . ($port === 443 ? '' : ':' . $port);
if ($env['WP_HOME'] !== $url || $env['WP_SITEURL'] !== "$url/wp") {
    throw new RuntimeException('Align WP_HOME and WP_SITEURL with LOCAL_HOST and HTTPS_PORT in .env');
}
@mkdir("$root/.docker/certs", 0700, true);
@mkdir("$root/backups", 0700, true);
$template = file_get_contents("$root/docker/nginx.conf.template");
file_put_contents("$root/.docker/nginx.conf", str_replace(['__HOST__', '__PORT__'], [$host, $port === 443 ? '' : ':' . $port], $template));
fwrite(STDOUT, "Local configuration prepared. Supply trusted certificates before starting nginx.\n");
