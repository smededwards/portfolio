#!/bin/sh
set -eu
find config scripts web/index.php web/wp-config.php web/app/mu-plugins/local-mail.php -type f -name '*.php' -print0 | xargs -0 -n 1 php -l
for package in ../obel ../aeon ../rune; do
  if [ -d "$package" ]; then
    find "$package" -path '*/vendor' -prune -o -path '*/node_modules' -prune -o -path '*/build' -prune -o -name '*.php' -print0 | xargs -0 -n 1 php -l
  fi
done
