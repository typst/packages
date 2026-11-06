# Contributing

Thanks for taking the time to look. This is a small library package; almost
any thoughtful contribution will be welcome — but a couple of conventions
keep the release pipeline (release-please + Typst Universe) running smoothly.

## Submitting a PR

1. Fork the repository on GitHub.
2. Clone your fork locally and create a branch for your change.
3. Make the changes, commit, and push to your fork.
4. Open a Pull Request against `main` on this repository.

Security issues should be reported privately per [`SECURITY.md`](SECURITY.md)
instead of as a PR or issue.

## Scope

`gairm-import` implements **only** the canonical [JSON Resume schema](https://jsonresume.org/schema).
Anything renderer-specific (theme colours, label overrides, header
decorations, custom sections, …) belongs in the consuming Typst CV template,
not here. PRs that add fields outside the canonical schema will be redirected
to the appropriate downstream template repo.

## Project layout

```text
lib.typ                              # public entry — `parse`, `validate`, `coerce`, combinators, lenses
internal/kinds.typ                   # schema-kind primitives (str-type, content-type, object, array-of, …)
internal/schema.typ                  # canonical resume-schema (faithful derivation) + resume-schema-strict (opt-in opinions)
internal/assets/jsonresume-schema.json  # vendored upstream schema, pinned to v1.0.0
internal/validate.typ                # validation engine (path-typed errors)
internal/coerce.typ                  # coercion engine (content wrapping, null absorption)
internal/json-schema.typ             # JSON Schema → Typst-schema translator
internal/lens.typ                    # path-based functional editing of schemas
tests/                               # fixtures — CI compiles each as a regression guard
```

## Bumping the vendored JSON Resume schema

`internal/schema.typ` derives `resume-schema` from
`internal/assets/jsonresume-schema.json` at module-load time, so the
upstream document is the source of truth. To pull a newer upstream version:

1. Replace `internal/assets/jsonresume-schema.json` with the chosen tag from
   [jsonresume/resume-schema](https://github.com/jsonresume/resume-schema).
2. Run `make test`. The translator handles the draft-04/-07 subset that the
   canonical document uses; newer constructs (`allOf`/`anyOf`/`oneOf`,
   `enum`/`const`, format-aware types beyond uri/email/date/date-time, open
   objects, type unions, external `$ref`) panic with an "unsupported" message.
   If a panic surfaces, extend `internal/json-schema.typ` rather than
   silently dropping the constraint.
3. Audit `_content-paths` and `_date-paths` in `internal/schema.typ` against
   the bumped document. These lists are the opt-in `resume-schema-strict`
   variant's opinions — `_content-paths` lifts free-text `string` fields to
   Typst `content` for inline rendering; `_date-paths` lifts iso8601 `$ref`
   fields (which the translator can't pick up from a `$ref` alone) to
   `date-string` for regex validation. If a new free-text or iso8601-referenced
   field lands in the upstream document, add its path here. The drift guard
   in `_override-fold` will panic at module-load if an existing path's source
   kind changes, so you'll see the audit prompt automatically.

`feat:` commit if the bump introduces new fields or behaviour;
`chore(deps):` if it's a no-op refresh.

## Development loop

Install Typst at the version CI uses — see `TYPST_VERSION` in
`.github/workflows/build.yml`.

```sh
make             # compile every tests/*.typ fixture (= `make test`)
make test        # same as above; the CI lint job runs this
make check       # alias for `make test`
make help        # summarise the available targets
```

`make test` is the local equivalent of the CI lint job — green here means CI
lint will pass too.

If you'd rather drive Typst directly:

```sh
for f in tests/*.typ; do typst compile --root . --format pdf "$f" /dev/null; done
```

`--format pdf` is required when the output path is `/dev/null` — Typst cannot
infer the format from a path with no extension.

## Conventional commits

The repo uses [release-please](https://github.com/googleapis/release-please)
to cut releases. Versioning is derived from commit messages on `main`, so
each merged PR needs a clean conventional-commit message.

| Prefix | Bump | Use for |
|---|---|---|
| `fix:` | patch | Bug fix, doc correction, broken link, validation gap |
| `feat:` | minor | New schema field supported, new coercion, new public helper |
| `feat!:` or `BREAKING CHANGE:` footer | major | API change that existing users would need to migrate |
| `chore:`, `docs:`, `ci:`, `refactor:`, `test:` | none | Internal changes that shouldn't trigger a release |

PRs squash-merge with the PR title as the commit subject, so just make the
**PR title** a conventional commit. The body of the squash commit comes from
the PR description.

## Adding schema coverage

For a **new schema field**:

1. Add (or extend) a fixture under `tests/` exercising the field — a valid
   case and at least one rejection case for the validator.
2. Implement the validation / coercion in `lib.typ` (or a module it imports).
3. Update the README's "Usage" example if the field is end-user-visible.

`feat:` commit.

## First publication to Typst Universe

The automated `submit-to-typst-universe` workflow only handles **updates** to
an already-published package (the auto-generated PR body is the slim
"update" variant). The very first submission to
[typst/packages](https://github.com/typst/packages) must be opened manually
so the maintainers can do a full new-package review.

## Security

See [`SECURITY.md`](SECURITY.md) for how to report a vulnerability.
