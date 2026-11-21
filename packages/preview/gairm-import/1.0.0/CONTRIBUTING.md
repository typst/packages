# Contributing

Thanks for taking the time to look. Almost any thoughtful contribution is
welcome; a few conventions keep the release pipeline (release-please and
Typst Universe) running smoothly.

## Submitting a PR

Fork the repository, make your change on a branch, and open a pull request
against `main`. Report security issues privately, as
[`SECURITY.md`](https://github.com/smur89/gairm-import/blob/main/SECURITY.md) describes, not as a PR or issue.

## Scope

`gairm-import` is a JSON Schema (draft 7 subset) → Typst engine;
[JSON Resume](https://jsonresume.org/schema) is a README use case, not a
bundled schema. Engine work (validation, coercion, translator keywords,
schema edits, introspection) is in scope. Anything renderer-specific (colours,
labels, decorations) belongs in the consuming template, and fields
outside a schema belong in an extension schema built by the caller (see
[Schema paths and edits](REFERENCE.md#schema-paths-and-edits)).

## Project layout

See [ARCHITECTURE.md](https://github.com/smur89/gairm-import/blob/main/ARCHITECTURE.md) for the codemap, the layering
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
`test` job runs, so a green `make check` means a green `test` check.

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
