# Verification — 25 October 2026

## Follow-up: tagged package integration

OBEL, AEON and RUNE now have public `v0.1.0` tags on the exact initial commits that passed package CI. The site production manifest references their public VCS repositories, and its production lock records the three exact release commits. Existing Bedrock/dependency versions were preserved.

An isolated container checkout, with no GitHub credentials, downloaded all three tagged archives successfully. Strict Composer validation, the release gate, site PHP coding standards and PHP syntax checks passed there. The release packages are real directories in that checkout; the running local site retains symlinks to the neighbouring working copies. Refreshing the local overrides also succeeded without changing the production lock.

The site CI bootstrap condition has been removed. Both Bedrock and assembled-package checks run automatically for the integration PR, alongside Conventional Commit validation. The manual artifact workflow can now package tagged dependencies; it still has no Cloudways upload or activation step. CI and artifact results are available on the integration PR and its Actions runs.

The implementation-run results below are historical and describe the earlier bootstrap state.

## Follow-up: trusted HTTPS setup

Homebrew mkcert 1.4.4 is now installed. A certificate for `smededwards.dev` was generated, and mkcert confirmed that its CA is installed in the macOS system trust store. `/usr/bin/curl --resolve smededwards.dev:443:127.0.0.1` returned HTTP 200 with normal system certificate validation. Services are now running. Firefox trust is not configured (NSS certutil is absent).

The user added the `/etc/hosts` entry manually. Both the homepage and WordPress login now return HTTP 200 using normal hostname resolution and system certificate validation. An additional `<www.smededwards.dev>` hosts entry includes literal angle brackets and is unnecessary for the configured hostname. A backup from before these changes is saved at ignored `.local/hosts.before-portfolio-20261025`. The original implementation-run results below describe the earlier state.

## Implemented

Four independent local repositories at `/Users/smededwards/Sites/portfolio/{site,obel,aeon,rune}`. The site derives from official Bedrock 1.31.7. No parent repository, remote repositories, release tags or production deployment were created.

The installed local site has OBEL active, AEON/RUNE active as regular plugins, zero posts/pages and zero comments. No portfolio design or custom blocks have been invented.

## Passed locally

- Docker PHP-FPM/tools image build, with Composer 2.8.12, WP-CLI 2.12.0 and PHP 8.4.27.
- Complete `make check`: PHP syntax checks; Bedrock PSR-12 checks; WPCS for custom PHP; JavaScript lint; SCSS lint; OBEL and RUNE production asset builds.
- Strict Composer validation for all four projects and the isolated local manifest; independent Composer locks, plus npm locks for OBEL and RUNE.
- Local package symlinks resolve to `/workspace/obel`, `/workspace/aeon` and `/workspace/rune` inside the PHP/tools mount layout.
- Regenerating local Composer configuration leaves production `composer.json` and `composer.lock` byte-for-byte unchanged.
- First WordPress installation succeeds, removes starter content and activates the intended packages. Repeating installation exits without altering existing content.
- HTTPS homepage returns 200 and frontend CSS returns 200; HTTP redirects with 301. Verification used `curl --resolve` and an explicitly trusted temporary certificate, not host-wide certificate trust.
- Development `wp_mail` delivery is captured by Mailpit, including after final image recreation.
- WP-CLI database export and reimport of the freshly generated local database succeed.
- A temporary database option and upload marker survive normal container recreation. Both markers were removed afterwards. The PHP-FPM runtime user can write uploads.
- Final nginx 1.30.6 and MariaDB 10.11.19 images were checked against their official registry metadata and pinned by digest. PHP, Composer, Node and Mailpit are also pinned by digest. The final homepage was checked after image recreation.
- Compose configuration and all five GitHub workflow YAML files parse successfully.
- `make reset` without the explicit confirmation fails before any destructive operation.
- Release check correctly rejects the bootstrap production lock because real tagged OBEL/AEON/RUNE releases do not yet exist.
- Git ignores local environments, certificates/private keys, generated local Composer files, passwords, backups and uploads. `git diff --check` passes.

Verification logs are retained in ignored `site/.local/verification-logs`. The initial local administrator is `smede`, email `admin@example.test`; its generated password is in ignored `site/.local/admin-password`, mode 0600. No password was printed in the verification output.

## Resolved environment issues

Docker Desktop initially was stopped. Its VM disk was then full, causing misleading Debian package signature errors. With authorisation, unused build cache was cleared (11.86 GB); no existing images, containers or database volumes were deleted. The PHP image then built successfully. Existing unrelated WordPress services were left alone. The new Compose project uses `smededwards-portfolio` to avoid an older `portfolio` project name.

Initial lint runs before the Node installation completed could not find `wp-scripts`; both packages were rerun successfully after installation. PHP template spacing and a strict Composer constraint warning were corrected before the complete successful `make check` run. npm emitted dependency deprecation notices from the WordPress scripts dependency tree; installed tooling still passed the required checks. Composer reported no dependency vulnerability advisories during resolution.

## Remaining manual or unverified steps

- Install mkcert on the host, trust its local CA, create certificates for the chosen hostname and add the hosts-file entry. None of those host changes were made or claimed as verified. The temporary verification certificate was removed.
- Services were stopped after verification, preserving the database volume, uploads and local working files. After completing host HTTPS setup, run `make up`. There is no need to reinstall WordPress.
- Development watch commands are provided but were not separately exercised; production builds were exercised.
- GitHub Actions have not run remotely because no remote repositories were created. The assembled site CI job remains explicitly gated until real package repositories/tags exist and production dependencies are added.
- First package releases, production Composer integration and its resulting full release lock require the actual separately authorised public repositories. The current production lock is an honest Bedrock-only bootstrap; local development uses the ignored path manifest and separate lock.
- The manual deployment workflow assembles an artifact only and intentionally blocks in bootstrap state. Cloudways credentials, paths, runtime support, public document root, shared environment/uploads, transport and rollback remain unconfirmed and untested.
- `smededwards.dev` is a local hostname preference, not an owned production domain. `local.smededwards.com` is the documented fallback.
