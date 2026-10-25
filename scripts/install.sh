#!/bin/sh
set -eu
if wp core is-installed; then
  echo 'Already installed; existing content was preserved.'
  exit 0
fi
: "${ADMIN_PASSWORD:?Set ADMIN_PASSWORD for the first installation}"
wp core install --url="$(php -r '$e=parse_ini_file(".env",false,INI_SCANNER_RAW);echo $e["WP_HOME"];')" --title=Portfolio --admin_user="${ADMIN_USER:-admin}" --admin_email="${ADMIN_EMAIL:-admin@example.test}" --admin_password="$ADMIN_PASSWORD" --skip-email
wp eval 'foreach (get_posts(["post_type"=>["post","page"],"post_status"=>"any","numberposts"=>-1]) as $p) { wp_delete_post($p->ID,true); } foreach (get_comments(["status"=>"all"]) as $c) { wp_delete_comment($c->comment_ID,true); }'
wp theme activate obel
wp plugin activate aeon rune
wp rewrite structure '/%postname%/'
