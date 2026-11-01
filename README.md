# Portfolio

Michael Edwards’s portfolio site runs on WordPress and Roots Bedrock, with the Obel theme and Aeon and Rune plugins. It is aimed at potential employers and includes pages for About, Work, Projects and Contact, plus writing published as Posts.

## Projects

Keep four separate repositories as neighbours:

```text
portfolio/                 # directory only; do not initialise a parent repository
  portfolio/               # Bedrock, Docker, Make and site workflows
  obel/                    # hybrid PHP theme, theme.json, patterns, Gutenberg
  aeon/                    # regular functionality plugin
  rune/                    # regular blocks plugin
```

The `portfolio` repository is private. The `obel`, `aeon` and `rune` repositories are public.

About, Work, Projects and Contact are WordPress Pages. Individual work and project entries are child Pages, and writing uses Posts. Obel supplies the block theme, responsive layouts, colour modes and archives. Aeon handles WordPress settings, SEO metadata and contact submissions. Rune supplies the editable Contact form block and the editor canvas colour preview. Each package README describes its features and development setup.

The product names reflect their separate roles: Obel is a shortened form of *obelisk*, suggesting a lasting structural foundation; Aeon comes from Greek *aiōn*, an age or extended passage of time, pointing to continuity and change; Rune refers to symbolic writing, echoing how reusable blocks combine into larger expressions. Together they suggest structure, continuity and expression. This is naming context, not a feature specification.

The four working copies are in `/Users/smededwards/Sites/portfolio`, each with its own Git history. Their repositories are [portfolio](https://github.com/smededwards/portfolio), [Obel](https://github.com/smededwards/obel), [Aeon](https://github.com/smededwards/aeon) and [Rune](https://github.com/smededwards/rune). Bedrock's upstream MIT licence is in `LICENSE.md`; the custom packages use GPL-2.0-or-later.

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

`mkcert -install` adds its CA to the host trust store and may ask for administrator authentication. Add the host entry and install the certificate manually. Certificates, private keys, passwords and salts are ignored. Keep the mkcert root private key secret. Browsers require HTTPS for `.dev` sites.

Local WordPress runs at `https://smededwards.dev`; production runs at `https://smededwards.com` on Cloudways. To change the local hostname, update `LOCAL_HOST`, `WP_HOME` and `WP_SITEURL` in `.env`, then regenerate the nginx configuration, issue a matching certificate and update `/etc/hosts`. For an existing database, export it before using WP-CLI search-replace.

```sh
make setup
# Choose a unique password and real local admin email; password is not saved in Git.
read -s ADMIN_PASSWORD
export ADMIN_PASSWORD
make install ADMIN_USER=smede ADMIN_EMAIL=you@example.com
unset ADMIN_PASSWORD
```

`make configure` creates random local database passwords and WordPress salts if `.env` does not exist, then checks the configured URL, hostname and HTTPS port. `make setup` resolves the local Composer manifest, installs locked Node dependencies for Aeon, Obel and Rune, builds their assets and starts the services. It leaves the database untouched. `make install` creates a new site, removes WordPress starter content, activates Obel, Aeon and Rune, and sets permalinks. If a database is already installed, it preserves its content and exits. If installation stops partway through, inspect the database before completing setup manually.

The local administrator is `smede` (`admin@example.test`). Its generated password is in the ignored file `.local/admin-password` (mode 0600). Read it locally to sign in, then change the email and password with WP-CLI. This workspace already has an installed site.

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
make watch PACKAGE=aeon       # also supports PACKAGE=obel or PACKAGE=rune
make check
make db-export FILE=backups/before-change.sql
make db-import FILE=backups/before-change.sql
```

Run `make help` to see the available commands. Pass WP-CLI arguments through `ARGS`. Production Composer commands use `composer.json` and `composer.lock`; local overrides use the ignored `composer.local.json` and `composer.local.lock`. The local manifest links the `dev-main` package copies without changing production dependencies. After running production `composer install` in an active local site, run `make composer-local` to restore those links.

All PHP services mount the parent directory at `/workspace`, so Composer links resolve in the PHP, CLI and nginx containers. Edit PHP and templates directly; Node watches the package assets. Obel uses `@wordpress/scripts` for frontend and editor bundles, loading each stylesheet and script in its relevant context. Rune discovers block entries and registers compiled `build/*/block.json` files. Its general-purpose entry remains unused until a feature needs it.

The database is in the named `smededwards-portfolio_database` volume. Uploads are in ignored `portfolio/web/app/uploads`. Ordinary stops and rebuilds preserve both. Backups are ignored; copy important backups off this machine separately. The only reset command is deliberately explicit:

```sh
make reset CONFIRM=destroy
```

This deletes the local database volume and uploads. Use it only when you intend to reset the site.

## Checks and dependency updates

Each package has its own Composer lock, WPCS configuration and push/PR CI. Aeon, Obel and Rune also have npm locks, JavaScript and SCSS checks, and production builds. Site checks use PSR-12 for Bedrock configuration, WPCS for the custom mu-plugin and PHP syntax checks for project code.

`make check` checks the assembled local working copies. Site CI runs on pushes and pull requests. It installs the package versions in the production lock, runs the coding-standard checks and builds package assets.

To intentionally update package dependencies inside containers, use `docker compose run --rm -w /workspace/obel node npm install`, or `docker compose run --rm tools composer -d ../obel update`. Review and commit the changed locks. Routine installs use `npm ci` / `composer install`.

Runtime versions are set in `compose.yaml`, the Dockerfile and workflows. The containers use PHP 8.4, MariaDB 10.11 and Node 24 LTS for WordPress Scripts 37. Image digests pin container contents. Review PHP, database, host and Docker dependency versions when updating the development environment.

## Package releases and production dependencies

The production Composer manifest installs tagged releases of Obel, Aeon and Rune from GitHub. `composer.lock` records the exact versions and source commits. Check `composer.json` and `composer.lock` for the current releases.

For subsequent releases:

1. Make package changes in a PR using Conventional Commits. Merge after package CI passes and the changes are reviewed.
2. Create and push the next semantic version tag in the package repository. Composer reads versions from Git tags, so do not add a `version` field to `composer.json`.
3. In a clean site checkout or container, update the requirement range if needed and run `composer update smededwards/obel` (or the package being updated). Review the tag and source reference, then commit the production lock in a site PR.
4. After both site CI jobs pass, run **Assemble deployment candidate** for the intended site ref. It creates a code-only artifact for manual deployment to Cloudways.

Site CI builds package assets; source repositories ignore the generated files. Package releases include the source and dependency locks needed for those builds. Local development uses a separate ignored path manifest and lock to load neighbouring working copies. Keep these local files separate from the production manifest and lock. Run `make release-check` to confirm the production lock uses tagged releases.

## Cloudways deployment

The production site runs on Cloudways at `https://smededwards.com`. Changes are reviewed through GitHub and deployment is manual. The **Assemble deployment candidate** workflow creates a code-only artifact; it does not deploy the site. Before automating deployment, confirm these hosting details:

- Actual PHP version/extensions and database engine/version.
- Application path, SSH/SFTP user and host-key verification, and permission to use an atomic release-directory switch.
- Public document root set to `<release>/web`, not the repository root.
- Persistent shared `.env`, `web/app/uploads`, writable cache/log paths, and their symlinks in each release.
- Bedrock nginx rewrites, HTTPS/proxy behaviour, production domain/certificate, SMTP and cron requirements.
- Database backup/migration procedure, maintenance handling, retention and tested rollback.

Store the production `.env`, uploads and database separately from application code. An automated deployment should upload to a fresh release directory, attach shared paths, validate the release, switch to it and retain the previous release for rollback. Avoid `rsync --delete` against the Cloudways application root. The deployment tarball excludes environment files, uploads and caches. Hosting credentials and server paths are kept outside this repository.

## References

- [Bedrock installation](https://roots.io/bedrock/docs/installation/)
- [WordPress scripts and Webpack](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-scripts/)
- [Node release support](https://nodejs.org/en/about/previous-releases)
- [Cloudways PHP compatibility](https://support.cloudways.com/en/articles/5121577-php-compatibility-on-cloudways-platform)
- [Cloudways database support](https://support.cloudways.com/en/articles/11721533-what-types-of-databases-does-cloudways-support)

See `VERIFICATION.md` for local setup checks and any remaining manual steps.

## Contribution conventions

Use Conventional Commit subjects and PR titles, such as `feat(theme): add navigation` or `fix(blocks): correct editor styles`. The first commit is the exception and must be titled `Initial Commit`. PR CI checks the title and commits. See `AGENTS.md` for details.

## Query Monitor

Query Monitor is a Composer development dependency. Local setup installs it; `composer install --no-dev` omits it. It is active on the current local site. On a fresh database, activate it with `make wp ARGS="plugin activate query-monitor"`. Signed-in administrators can use its toolbar menu to inspect queries, PHP errors, hooks and HTTP requests. Development configuration enables `SAVEQUERIES` and `WP_DEBUG`.

## Breeze

Breeze is a production Composer dependency. The local Composer manifest excludes it, so the plugin is not installed in local development.
