# Contributing

Thanks for taking the time to look. Almost any thoughtful contribution is
welcome; a few conventions keep the release pipeline (release-please and
Typst Universe) running smoothly.

## Submitting a PR

Fork the repository, make your change on a branch, and open a pull request
against `main`. Report security issues privately, as
[`SECURITY.md`](SECURITY.md) describes, not as a PR or issue.

## Scope

`gairm-import` is a JSON Schema (draft 7 subset) → Typst engine. The
bundled [JSON Resume schema](https://jsonresume.org/schema) is deprecated
and goes in 1.0 (#200); JSON Resume is a README use case. Engine work
(validation, coercion, translator keywords, lenses, introspection) is in
scope. Anything renderer-specific (colours, labels, decorations) belongs in
the consuming template, and fields outside a schema belong in an extension
schema built by the caller (see
[Lenses and edits](REFERENCE.md#lenses-and-edits)).

## Project layout

See [ARCHITECTURE.md](ARCHITECTURE.md) for the codemap, the layering
rule and where to make each kind of change.

## Development loop

Install Typst and typstyle at the versions CI uses: `TYPST_VERSION` and
`TYPSTYLE_VERSION` in `.github/workflows/build.yml`.

```sh
make -k -j8 check  # everything CI's test job runs, in parallel, reporting every failure
make test          # fixtures, panic cases and package tests only (the default target)
make fmt           # format with typstyle
make help          # every target, and the variables you can override
```

`make check` is `test`, `fmt-check`, `check-layers` and
`check-conventions` (no test for a named kind outside `internal/kinds/`
unless marked `// kind-check: <why>`, no `panic(` outside
`core/error.typ`, panic cases named after an export): exactly what CI's
`test` job runs, so a green `make check` means a green `test` check. Each
test file is its own Make target (`check/fixture/…`, `check/panic/…`,
`check/package/…`), so `-j` runs them in parallel and `-k` keeps going
past a failure.

**Panic cases** live in `tests/panics/`, one per place the package panics,
named `<public-function>-<problem>.typ` (`string-min-length-negative.typ`),
or `import-<problem>.typ` for a check that runs when the package loads.
A second case for the same place earns its file only by pinning other
wording, or another check that reaches the same message. Line 1 is
`// expect: <substring of the error>`, then the imports and the call that
panics. `make test-panics` checks that each file fails to compile with
that text, so a panic that stops firing, or changes its message, fails.

**Doc mirrors** live in `tests/package/`. Every README or REFERENCE.md
example that states its output has a `readme-*` or `reference-*` test that
runs it and asserts that output; change the two together.

## Bumping the vendored JSON Resume schema

`resume-schema` is translated from `internal/json-resume/schema.json` at
load time, so the upstream document is the source of truth.

1. Replace `schema.json` with the one from the chosen version of the
   [`@jsonresume/schema`](https://www.npmjs.com/package/@jsonresume/schema)
   npm package (source: `packages/schema` in
   [jsonresume/jsonresume.org](https://github.com/jsonresume/jsonresume.org)),
   and `tests/fixtures/jsonresume-sample.json` from its
   `sample.resume.json`.
2. Run `make check`. Anything the translator does not support panics,
   naming the keyword; [the translator's reference](REFERENCE.md#json-schema-translation)
   lists what is supported. Extend `internal/json-schema/` rather than
   dropping the constraint.
3. Audit `_content-paths`, `_iso8601-date-paths` and `_last-modified-paths`
   in `internal/json-resume/schema.typ`, the strict variant's opinions,
   for new free-text or iso8601 fields. A listed path whose kind changes
   panics at load, so drift there surfaces on its own. The README's
   "Validating a JSON Resume" rebuilds the strict variant by hand, and
   `tests/package/readme-json-resume.typ` fails until it matches again.
4. Update the recorded version: the header of
   `internal/json-resume/schema.typ` and the "bundled copy of JSON
   Resume x.y.z" sentence in the README.

Use `feat:` if the bump adds fields or behaviour, `chore(deps):` if not.

## Conventional commits

release-please derives each release from the commit messages on `main`.
PRs squash-merge with the PR title as the subject, so make the **PR title**
a conventional commit:

| Prefix | Bump | Use for |
|---|---|---|
| `fix:` | patch | Bug fix, doc correction, validation gap |
| `feat:` | minor | New keyword, kind, helper or schema field |
| `feat!:` or a `BREAKING CHANGE:` footer | major | A change existing users must migrate for |
| `chore:`, `docs:`, `ci:`, `build:`, `refactor:`, `test:` | none | Changes that shouldn't cut a release |

release-please keeps a release PR open with the next version and
changelog. It runs CI like any other PR, and `test` and
`typst-package-check` must pass before it merges; merging it tags the
release and submits it to Typst Universe.

## Security

See [`SECURITY.md`](SECURITY.md) for how to report a vulnerability.
