# Provenance and licensing record

## Repository history inspected

The configured origin is `https://github.com/eakarsu/RailsProject2`. The reachable history contains four commits, all authored as Erol Akarsu `<eakarsu@gmail.com>`:

- `d7c0592c1f1cf6acf97a5b4c5fe2c1fdd9ed2715` — 2015-12-30 — initial Rails scaffold.
- `dbc92e022693f69255feae12213d048bc29dbf9c` — 2015-12-30 — production configuration.
- `76fc648c46c19e1652c86224e7bc797457925619` — 2015-12-30 — PostgreSQL configuration.
- `0ecab9419face66132ec3d6217d67324f68b83e6` — 2020-07-12 — replaced the generic Rails README with unrelated Kubernetes lab instructions.

No `LICENSE`, `COPYING`, or `NOTICE` object exists in the reachable Git history. The removed Kubernetes text is retained in Git history for auditability but is not product documentation and no command from it is executed by the application, image, setup, or CI paths. The obsolete Rails 4 dependency set has been replaced by the pinned `Gemfile.lock`; third-party gem licenses are enumerated from package metadata by `bin/license-report`, and CI fails if a dependency omits license metadata.

## Distribution boundary

No project-level license grant is inferred here. This repository must remain private/internal and must not be redistributed until the copyright owner explicitly selects and adds a project `LICENSE`. That legal choice cannot safely be made from source inspection. A release approver must also review the generated dependency-license report and any deployment-specific media/content rights before public launch.

## Reproducibility boundary

The authoritative build is the pinned Ruby 3.4.4 multi-stage `Dockerfile`. It installs only lockfile dependencies, compiles production assets with non-runtime build placeholders, produces an unprivileged runtime, and never migrates or seeds at image build or web startup. CI rebuilds that image, verifies dependency provenance/security, runs PostgreSQL migration rollback/replay, and exercises the publishing journey.
