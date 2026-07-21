# Completeness Review: RailsProject2

**Review date:** 2026-07-18

## Assessment basis

Static inspection of project-owned source and configuration only; no dependency installation, build, database migration, external-service call, or runtime launch was performed. The scan considered 55 project files (21 source files), 1 manifest(s), 7 test-like file(s), and 0 CI workflow(s), excluding dependency/generated directories.

## Classification

**Broken-inert-unsafe**

This repository should not be treated as a launchable publishing/blog app. Its checked-in state is inert, internally inconsistent, credential/provenance-sensitive, or unsafe to operate; feature work must wait until the blockers below are repaired and verified.

## Why it is not complete

- The supported build/runtime path and a trustworthy end-to-end workflow have not been demonstrated from the checked-in state.
- The documented purpose and executable source layout are mismatched or rely on missing/obsolete components.

## Needed features

1. Establish provenance/licensing and reproduce a clean build in an isolated environment before adding product surface.
2. Implement complete author, article, draft, revision, taxonomy, moderation, and publication workflows.
3. Add secure authentication, role permissions, input sanitization, spam/rate controls, and media handling.
4. Provide search, feeds, accessibility, SEO metadata, backups, and export/import behavior.
5. Add request/model/system tests and a reproducible deploy/migration path.

## Risks or launch blockers

- Weak/fallback secret patterns can permit forged sessions or accidental insecure deployments.
- No CI evidence prevents broken or insecure changes from reaching a release.

## Evidence inspected

- `README.rdoc`
- `config/secrets.yml:3`
- `config/application.rb`
- `config/routes.rb`
- `test/test_helper.rb`
- `Gemfile`

## Recommended next action

Quarantine execution, repair provenance/secret/startup/build blockers in an isolated branch, and reassess only after a clean reproducible build and smoke test.

## Implementation progress — 2026-07-19

- Requirement 1 is implemented to the limit of source authority: `PROVENANCE.md` records the configured origin, all four reachable commits/authors/dates, the 2020 replacement of the README with unrelated Kubernetes lab text, and the absence of any historical project license. That lab text and its obsolete host-specific launcher were removed from executable/documentation paths. Dependencies were freshly resolved in an isolated bundle directory, all 82 resolved gem records declared license metadata through `bin/license-report`, and clean SQLite plus disposable PostgreSQL builds, migration rollback/replay, tests, production compilation/eager loading, and a live smoke test succeeded. No license grant is inferred: public redistribution remains quarantined until the copyright owner makes the external legal decision to add a project `LICENSE`.
- Requirement 2 is implemented: persisted users and author ownership, collision-safe article slugs, draft/review/rejected/published/archived transitions, independent editor approval, immutable publication events and revisions with authorized restore behavior, editor and moderation queues, category/tag taxonomy, comment states, and immutable moderation events are present. Foreign keys, non-null constraints, unique indexes, state checks, publication-time checks, legacy-data backfill, and optimistic locking enforce critical invariants.
- Requirement 3 is implemented: bcrypt sessions use active/suspended users and explicit author/editor/moderator/admin permissions; production secrets and database configuration fail closed; secure cookie, CSRF, CSP, frame, MIME, referrer, and permissions controls are configured. Untrusted content is normalized and safely rendered, sensitive fields are filtered, comments use a honeypot/content scoring/HMAC source identifiers/rate throttles, and bounded allowlisted media uses authenticated multipart writes and signed reads with public direct-upload routes disabled.
- Requirement 4 is implemented: published-only search, RSS with freshness metadata, semantic/keyboard/reduced-motion UI behavior, article title/description/canonical metadata, versioned checksummed JSON export, validate-first bounded draft import with recorded outcomes, PostgreSQL dump/checksum tooling, and documented database plus media restore drills are present.
- Requirement 5 and the CI blocker are implemented: 20 model/service/request tests (87 assertions) and the RackTest author-to-independent-editor journey pass on SQLite and PostgreSQL. Rails 8.1.3, Ruby 3.4.4, reversible migrations, an unprivileged pinned multi-stage image, explicit release migration, pending-migration startup guard, health endpoint, environment contract, and operations runbook provide the deployment path. CI provisions PostgreSQL, replays a two-migration rollback, splits unit/request/end-to-end coverage, checks current advisories, Brakeman and dependency license metadata, and builds the release image.
- Local verification also passed production asset compilation/eager loading, live startup through the compatibility `start-app` wrapper and `/health`, Ruby syntax, Bundler resolution, `bundle-audit` with no known vulnerabilities, Brakeman with no warnings, and `git diff --check`; the disposable PostgreSQL database was deleted. The only remaining blocker is the explicit project-license choice above, which requires copyright-owner direction rather than an inferred source edit.

## Runtime and login acceptance (2026-07-20)

- `start.sh` validates Ruby, Bundler, dependencies, and `PORT`, then replaces itself with the existing foreground Puma launcher. It never installs dependencies or kills unrelated processes.
- Development and production retain the pending-migration guard in `bin/start`; only the explicit `NODE_ENV=test` and `RAILS_ENV=test` acceptance combination prepares its selected disposable database and creates an explicitly supplied acceptance administrator.
- `/api/auth/login` uses the existing bcrypt authentication and server-side session. `/api/auth/me` verifies that session while returning only the user's identifier, email, display name, and role.
