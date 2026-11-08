# Repository conventions

- Implement changes in this repository by default. During iteration, run only the checks relevant to the files changed; defer Ponytail and the final review until the user asks to open a PR. Wait for explicit code approval before committing or pushing substantive work. Lint-only fixes to an already-open PR may be pushed directly.
- Use lowercase, hyphenated WordPress-style PHP filenames. For class files, convert every CamelCase boundary to a hyphen, such as `DefaultFeaturedImage` → `class-default-featured-image.php`; add only narrow PHPCS exceptions when its filename sniff cannot infer the boundary. Organise PHP classes in responsibility-based directories directly under the project root, without a PHP `src/` wrapper. Use namespaces and separate classes for new custom PHP functionality, with Composer classmap autoloading where needed.
- Keep custom PHP runtime behaviour in namespaced classes. Limit plugin/theme entry files to bootstrap, autoloading and fallback notices; use an adapter only where a WordPress or tooling contract requires a global callback.
- Use sentence case for package names: Aeon, Obel and Rune. Keep lowercase code identifiers and package slugs unchanged.
- Use Title Case for website content headings and SEO title overrides, including brand names such as WordPress.
- Use Title Case for user-facing names, titles and headings, keeping short articles and conjunctions such as “a”, “and”, “in” and “the” lowercase. Use sentence case for user-facing descriptions and explanatory text.
- Use Title Case for user-facing selectable options and button labels as well as names, titles and headings; keep short articles and conjunctions such as “a”, “and”, “in” and “the” lowercase. Use sentence case for user-facing descriptions and explanatory text.
- Use `FrontEnd`, `BackEnd` and `FullStack` in compound code identifiers when needed. Use `front-end`, `back-end` and `full-stack` in prose, and `Front-End`, `Back-End` and `Full-Stack` in title case. Preserve established technical identifiers and paths unless a deliberate rename is part of the task.
- Format HTML with visible nesting and consistent indentation. Keep short, simple elements such as `<input>` on one line; wrap longer attribute lists only when it improves readability.
- Prefer full ternary and null coalescing (`??`) expressions for simple value selection and defaults. Use shorthand ternary (`?:`) only where the repository's coding standard permits it. Use explicit conditionals for side effects, multiple branches, nested conditions or lower readability.
- Use Conventional Commits for every new commit and PR title: `type(scope): description`, with an optional scope and optional `!` for breaking changes.
- Accepted types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- The sole exception is the repository's first commit, whose subject is exactly `Initial Commit`.
- Keep PR descriptions focused on the core premise and features, using one short paragraph or a few brief bullets. Omit implementation inventories, validation commands and work logs unless necessary for review. Use British English in documentation.
- Never commit secrets, certificates, local environment files, uploads or generated dependency directories.
- After changing Composer path packages, namespaces, class locations or Composer metadata, run `make composer-local` and a read-only WordPress bootstrap check so the local autoloader reflects the source tree.
- Run the local portfolio through the shared Traefik proxy documented in `README.md` when it is used alongside other Docker projects. Keep host ports 80 and 443 owned by Traefik, and do not reintroduce direct nginx bindings for those ports.
- Process adaptive Work featured images as light/dark pairs. Keep matching `*-light.svg` and `*-dark.svg` files with the same base filename in uploads; Obel derives the dark URL by replacing `-light.svg` with `-dark.svg`, so database usage checks alone can wrongly classify the dark companion as unused. Before cleanup, check assigned light-image names and preserve each matching dark file. For new company cards, use relevant company imagery under the portfolio gold overlay and centre the adaptive wordmark; do not bake a second logo into the background. Register both variants in the Media Library and verify the card in both colour modes.
- Before permanently deleting Media Library files, run a dry-run usage check, review filename-derived dependencies such as adaptive light/dark pairs, and obtain explicit approval for the final deletion.

## Engineering principles

Apply these principles while planning, implementing and reviewing every change across PHP, JavaScript, SCSS, templates, configuration and documentation. Before considering work complete, check it against each principle:

- **KISS:** Choose the simplest clear solution that meets the requirement; avoid needless layers and cleverness.
- **DRY:** Keep each piece of knowledge and behaviour in one appropriate place. Share genuine common logic, but do not create abstractions for superficial similarities.
- **SOLID:** Keep responsibilities focused, dependencies clear and interfaces small. Use extension points and abstractions where they improve maintainability, not as a goal in themselves.
- **YAGNI:** Build for current requirements and agreed plans. Avoid speculative features, configuration and generalisation.

## Branch and release workflow

- Create focused feature branches from the latest `dev`; target feature PRs at `dev` and squash-merge using their Conventional Commit titles.
- Release connected batches through a `dev` to `main` PR using a merge commit with a Conventional Commit subject. Preserve feature history and fast-forward `dev` to released `main` before new work.
- Version each repository independently. Tag only the approved release commit on `main`; published tags are immutable. Releases and deployments require explicit agreement.
- Track the work merged into each repository's `dev` branch and proactively recommend a semantic version bump when a substantive release batch has accumulated. Base the recommendation on the changes' impact, not a fixed PR or feature count, and explain the proposed bump before preparing release metadata.
- Follow SemVer independently for this repository. The next planned release is `0.3.0`; recommend `1.0.0` when the local/production workflow and package release process are stable enough to support compatibility guarantees.
- Require every PR to have one `type:*` label, one or more `area:*` labels, one `semver:*` impact label and a release milestone before merge. Use `semver:major`, `semver:minor`, `semver:patch` or `semver:none`; the highest applicable impact determines the eventual release bump.
- Name release milestones `Release: vX.Y.Z`; name larger non-release targets `Initiative: <Name>` and maintenance targets `Maintenance: <Name>`.
- Maintain a `CHANGELOG.md` with an `Unreleased` section. Move it into a dated version section during release preparation, and update the README release link and version information at the same time.
- Backfill labels, milestones and changelog history for merged PRs without rewriting commits, merged PR titles or published tags.
- Keep reviewable changes in their corresponding local repository or GitHub PR. Use the repository directly by default; create a worktree only when explicitly requested or genuinely required for parallel isolation, and place it under `.worktrees/<repo>-<purpose>`.
- Keep `main` as the GitHub default branch. Avoid stacked PRs unless agreed; merge dependencies into `dev` first.
- Clean up merged feature branches during a release or housekeeping pass. Before deletion, confirm no open PR depends on the branch and that it contains no unmerged work; never delete `dev` or `main`. Use `git fetch --prune` during that pass.
- After a PR is merged, update the relevant `features.md`, `mvp.md`, backlog notes and README documentation before starting the next release batch.
- Treat local and production as separate environments. Require explicit confirmation immediately before production migrations, content or media imports, deletions, cache purges or database changes.
- If an already-open PR fails checks solely because of linting or formatting, fix those issues, commit and push the correction to that PR branch so CI can rerun; this does not need separate code approval. Keep the correction limited to the reported lint/format issues.
- For new feature work, behavioral fixes or other substantive PR updates, the local approval requirement above still applies before committing or pushing.

- Prefer returned markup built with `sprintf()` in PHP helpers. Use escaped `printf()` only at template or WordPress callback output boundaries, and `fwrite(STDOUT, ...)` in standalone CLI scripts; avoid direct `echo` statements. Escape dynamic values for their actual HTML, attribute or URL context. Formatting and returning values do not replace validation, capability checks or escaping.

- Document each PHP and JavaScript function/method with an adequate DocBlock/JSDoc: a concise purpose, descriptions for each parameter, and a return description/type when applicable. Add documentation to callbacks when their purpose or contract is not self-evident. Use `//` for ordinary single-line comments; reserve DocBlocks/JSDoc blocks for function documentation and multiline block comments for longer notes or required WordPress translator comments.
- Group JavaScript imports with comments: WordPress or external dependencies first, then internal dependencies, separated by a blank line. Keep PHP `use` declarations directly after the namespace and alphabetised within their logical groups.
- At final PR preparation, run Ponytail once, one custom-code consistency pass, and only the affected checks: PHPCS for PHP, ESLint and the build for JavaScript, Stylelint and the build for SCSS, and a WordPress bootstrap check for Composer or class-loading changes. Exclude WordPress core, vendor, generated, backup and third-party plugin files. After fixing findings, rerun only the affected checks.
- For front-end features that change templates, blocks, navigation or responsive behaviour, run targeted Playwright checks at the relevant WordPress viewport sizes. Store screenshots and logs only under `.docs/tests/playwright/`.

- Use BEM for custom HTML and SCSS classes: `block`, `block__element`, `block--modifier` or `block__element--modifier`. Preserve WordPress-owned classes and keep block metadata, saved markup and selectors aligned when renaming classes.

- Keep fractional CSS values to a maximum of two decimal places; use an integer unit when exactness matters.

- Prefer native WordPress blocks and editor controls wherever they meet the requirement. Use Page List for page navigation and Query Loop for dynamic card layouts; introduce custom blocks, shortcodes or renderers only for an agreed gap in core.

- Group CSS/SCSS declarations in this order: box model (dimensions, margins, padding, borders and sizing), background, layout (display, positioning, flex/grid and alignment), type (colour, fonts, line height and text properties), then other (effects, transforms, transitions and remaining properties). Alphabetise properties within each group, and separate non-empty groups with a blank line. Use blank lines to show the groups; do not add group-label comments. Preserve order where repeated declarations, fallbacks, or shorthand/longhand interactions depend on it; keep those declarations together and document non-obvious exceptions. This concerns CSS properties, not HTML attributes or selector order. Apply it to new and edited rules; handle existing stylesheets in a dedicated refactor.
