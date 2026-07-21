# RailsProject2

RailsProject2 is an editorial publishing application with role-based authoring, independent review, immutable and restorable revisions, comment moderation, taxonomy, search, RSS, constrained media attachments, and versioned JSON portability.

The former README was unrelated Kubernetes lab material and is documented—not executed—in `PROVENANCE.md`. For local development, set a random `SECRET_KEY_BASE`, run `bundle install`, prepare the database explicitly with `bundle exec rails db:prepare`, and launch with `./start.sh`. Normal development and production startup never migrate or seed automatically. See `RUNBOOK.md` for release, backup, restore, and incident procedures.
