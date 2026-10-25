# Portfolio development foundation

A minimal WordPress portfolio foundation using the official Roots Bedrock 1.31.7 scaffold. No portfolio design, sample content or custom blocks have been added.

## Projects

Keep four separate repositories as neighbours:

```text
portfolio/                 # directory only; do not initialise a parent repository
  portfolio/                    # Bedrock, Docker, Make and site workflows
  obel/                    # hybrid PHP theme, theme.json, patterns, Gutenberg
  aeon/                    # regular functionality plugin
  rune/                    # regular blocks plugin
```

GitHub visibility: `portfolio` (the `portfolio` working copy) is private; `obel`, `aeon` and `rune` are public.

The working copies live at `/Users/smededwards/Sites/portfolio`. Each project has independent Git metadata. No GitHub repositories have been created. Bedrock's upstream MIT licence remains in `LICENSE.md`; custom packages declare GPL-2.0-or-later.

## First run

Install Docker Desktop and GNU Make / macOS Make. Composer, WP-CLI and Node run inside containers. For certificate trust, install [mkcert](https://github.com/FiloSottile/mkcert#installation) on the host (and NSS if using Firefox).

From `portfolio`:

```sh
make configure
# Edit .env if changing hostname or ports, then run make configure again.
mkcert -install
mkcert -cert-file .docker/certs/local.pem -key-file .docker/certs/local-key.pem smededwards.dev
```

Add this line to `/etc/hosts` using your normal administrator process:

```text
127.0.0.1 smededwards.dev
```

`mkcert -install` modifies the host trust store and may require administrator authentication. These host steps are manual; do not assume they have been completed. Certificates, private keys, passwords and salts are ignored. Never share the mkcert root private key. `.dev` requires HTTPS in browsers.

The preferred hostname is `smededwards.dev`, which you do **not** currently own. A hosts entry only overrides your computer; it does not establish ownership. Do not use it publicly unless acquired. The fallback is `local.smededwards.com`: change `LOCAL_HOST`, `WP_HOME`, `WP_SITEURL` together in `.env`, regenerate the nginx configuration, issue the matching certificate and use the matching hosts entry. If WordPress is already installed, use WP-CLI search-replace after exporting the database. No public DNS change is necessary for local use.

```sh
make setup
# Choose a unique password and real local admin email; password is not saved in Git.
read -s ADMIN_PASSWORD
export ADMIN_PASSWORD
make install ADMIN_USER=smede ADMIN_EMAIL=you@example.com
unset ADMIN_PASSWORD
```

`make configure` generates random local database passwords and WordPress salts only when `.env` is absent. It validates the URL against the configured hostname and HTTPS port. `make setup` resolves the local Composer manifest, installs locked Node dependencies, builds assets and starts services; it does not install or reset a database. `make install` creates an empty site, removes only WordPress-generated starter posts/pages/comments, activates Obel, Aeon and Rune, and sets permalinks. On an installed database it preserves content and exits. If interrupted after core installation, inspect the database before manually completing activation/cleanup.

The initial local administrator is `smede`, with email `admin@example.test`; its generated password is stored in ignored `.local/admin-password` (mode 0600). Read that file locally to sign in, then set your preferred email/password using WP-CLI. The installation has already been performed in this workspace.

The site opens at `https://smededwards.dev`; admin is `/wp/wp-admin/`. Mailpit is at `http://localhost:8025`. Database and PHP ports are private to Docker. HTTP and HTTPS bind to localhost. Change `HTTP_PORT`, `HTTPS_PORT` and `MAILPIT_PORT` if another local tool occupies them; include a nonstandard HTTPS port in both WordPress URLs.

## Daily work

```sh
make up
make down
make logs ARGS=php
make wp ARGS='plugin list'
make wp ARGS='user list'
make composer ARGS='validate --strict'
make composer-local
make assets-install
make assets-build
make watch PACKAGE=obel       # another terminal for PACKAGE=rune
make check
make db-export FILE=backups/before-change.sql
make db-import FILE=backups/before-change.sql
```

`make help` lists commands. WP-CLI accepts arbitrary arguments through `ARGS`. Production Composer commands use `composer.json` and `composer.lock`; local overrides use ignored `composer.local.json` and `composer.local.lock`. Local resolution adds `dev-main` path dependencies without changing the production manifest or lock. Never run production `composer install` over an active local installation without subsequently running `make composer-local` to restore local packages.

All PHP services mount the same parent directory at `/workspace`, including the three neighbouring packages. Composer's symlinks therefore resolve in PHP, CLI and nginx containers. Edit PHP/templates directly; Node watches assets on demand. Obel extends `@wordpress/scripts` defaults for frontend/editor bundles, loads frontend CSS/JS on the frontend, editor CSS through editor styles and editor JS through the editor hook. Rune preserves automatic block entry discovery and registers future compiled `build/*/block.json` metadata, allowing future blocks to declare editor/frontend assets. Its reserved entry is not enqueued until there is a real feature requiring it.

The database is in the named `smededwards-portfolio_database` volume. Uploads are in ignored `portfolio/web/app/uploads`. Ordinary stops and rebuilds preserve both. Backups are ignored; copy important backups off this machine separately. The only reset command is deliberately explicit:

```sh
make reset CONFIRM=destroy
```

It deletes the local database volume and uploads. Do not use it for routine rebuilds.

## Checks and dependency updates

Each package has its own Composer lock, WPCS configuration and push/PR CI. Obel and Rune also have npm locks, JS/SCSS checks and production builds. The site uses PSR-12 for upstream Bedrock configuration and WPCS for its custom mu-plugin. PHP syntax checks exclude installed dependencies. No behavioural tests have been invented for empty scaffolds.

`make check` checks the assembled local working copies. The site CI checks Bedrock automatically. Its assembled job is gated by repository variable `PACKAGES_PUBLISHED=true` until all three real repositories, initial tags and production requirements exist. That gate is explicit bootstrap status, not a claim that remote assembly has passed. When enabled it installs tagged packages, checks their standards and builds their assets.

To intentionally update package dependencies inside containers, use `docker compose run --rm -w /workspace/obel node npm install`, or `docker compose run --rm tools composer -d ../obel update`. Review and commit the changed locks. Routine installs use `npm ci` / `composer install`.

Runtime pins are in `compose.yaml`, Dockerfile and workflows. PHP 8.4 is selected to match the current Cloudways direction; MariaDB 10.11 is supported there. Node 24 LTS satisfies WordPress scripts 37 requirements. Container image digests pin the verified image contents; PHP and database pins can be changed to match the actual hosting platform later. Host packages and Docker's internal apt dependencies should be refreshed deliberately for security updates.

## First releases and production dependencies

The committed production lock initially contains Bedrock only. It deliberately does not claim unreleased custom packages exist. Local development works using the isolated path manifest. The manual deployment workflow and `make release-check` fail closed until all three packages are installed from real semantic version tags.

After publishing the private site repository and the three public package repositories:

1. Publish `obel`, `aeon` and `rune` as independent public repositories. Confirm checks pass and create first real tags such as `v0.1.0`.
2. Add three Composer VCS repositories with their actual GitHub URLs to the site's **production** `composer.json`. Add `smededwards/obel`, `smededwards/aeon`, `smededwards/rune` to `require`, using actual tagged versions. Do not add a `version` field to the package manifests; Composer reads Git tags.
3. In a clean checkout or container, run `composer update` against the production manifest. Commit its exact `composer.lock`, with no `path` repositories or `dev-*` versions. Check package source exports include package.json, package-lock.json, sources and build configuration.
4. Set `PACKAGES_PUBLISHED=true` in the site repository and verify the assembled job on a push/PR. Run the manual **Assemble deployment candidate** workflow; it installs production Composer dependencies, builds assets and uploads a code-only tarball.

Build output is ignored in source repositories and compiled by site CI. Package release tags must retain the build source and locks. `composer.lock` identifies package commits; package npm locks identify asset dependencies.

## Cloudways deployment foundation

The manual workflow currently assembles an artifact only. There is no upload, SSH, remote deletion or production deployment configured. Confirm these hosting requirements before enabling transport:

- Actual PHP version/extensions and database engine/version.
- Application path, SSH/SFTP user and host-key verification, and permission to use an atomic release-directory switch.
- Public document root set to `<release>/web`, not the repository root.
- Persistent shared `.env`, `web/app/uploads`, writable cache/log paths, and their symlinks in each release.
- Bedrock nginx rewrites, HTTPS/proxy behaviour, production domain/certificate, SMTP and cron requirements.
- Database backup/migration procedure, maintenance handling, retention and tested rollback.

Keep production `.env`, uploads and database outside code replacement. Upload the candidate into a fresh release directory, attach shared paths, validate before switching the active release, and retain the previous release for rollback. Do not blindly rsync-delete a Cloudways application root. The deployment tarball excludes environment files, uploads and caches. No hosting credentials or supported paths have been invented.

## References

- [Bedrock installation](https://roots.io/bedrock/docs/installation/)
- [WordPress scripts and Webpack](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-scripts/)
- [Node release support](https://nodejs.org/en/about/previous-releases)
- [Cloudways PHP compatibility](https://support.cloudways.com/en/articles/5121577-php-compatibility-on-cloudways-platform)
- [Cloudways database support](https://support.cloudways.com/en/articles/11721533-what-types-of-databases-does-cloudways-support)

The initial verification run used a temporary certificate, which was removed. In the follow-up setup, mkcert was installed, a new certificate was generated, macOS system trust was installed and normal certificate validation returned HTTP 200. Services are now running. The user has added the hosts-file entry; the homepage and login both return HTTP 200 using normal hostname resolution. Firefox trust has not been configured.

See `VERIFICATION.md` for checks actually run and remaining manual steps.

## Contribution conventions

Use Conventional Commit subjects and PR titles, for example `feat(theme): add navigation` or `fix(blocks): correct editor styles`. The repository's first commit is the explicit exception: `Initial Commit`. PR CI validates titles and every commit in the PR. See `AGENTS.md` for repository guidance.
