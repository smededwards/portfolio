ARG PHP_IMAGE=php:8.4-fpm-bookworm@sha256:df5a5113e1179ddf4560cd15727eb3812f6457829756d2a96c6c11bb4c250089
ARG COMPOSER_IMAGE=composer:2.8.12@sha256:5248900ab8b5f7f880c2d62180e40960cd87f60149ec9a1abfd62ac72a02577c
FROM ${COMPOSER_IMAGE} AS composer
FROM ${PHP_IMAGE}
RUN apt-get update && apt-get install -y --no-install-recommends git unzip default-mysql-client libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libonig-dev libxml2-dev curl ca-certificates && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install mysqli pdo_mysql zip gd mbstring xml && rm -rf /var/lib/apt/lists/*
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
ARG WP_CLI_VERSION=2.12.0
ADD https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp
ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /workspace/portfolio
