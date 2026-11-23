<?php
/**
 * Route development mail to Mailpit.
 *
 * @package Portfolio
 */

if ( WP_ENV !== 'development' ) {
	return;
}
add_action(
	'phpmailer_init',
	static function ( $mailer ): void {
		$mailer->isSMTP();
		$mailer->Host        = 'mailpit'; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase
		$mailer->Port        = 1025; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase
		$mailer->SMTPAuth    = false; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase
		$mailer->SMTPAutoTLS = false; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase
	}
);
