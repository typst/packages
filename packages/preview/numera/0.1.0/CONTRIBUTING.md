# Contributing to Numera

## Development setup

Install the development tools:

```bash
cargo install --locked --version 0.15.1 typst-cli
cargo install --locked --version 0.4.1 tytanic
cargo install --locked --version 0.15.1 typstyle
cargo install --git https://github.com/typst/package-check.git
cargo install --git https://github.com/sjfhsjfh/typship.git
```

## Testing releases and local changes

Every example and test imports Numera the same way a user does:

```typst
#import "@preview/numera:0.1.0"
```

This is intentional. The examples remain copyable, while package resolution lets the same files exercise either the published release or the current checkout. A relative import would always select the checkout, while an `@local` import would test a different namespace from the one users install.

For everyday development, point Tytanic at the local package directory:

```bash
tt --package-path "$PWD/packages" run
```

The equivalent environment-variable form is handy when several commands should use the checkout:

```bash
TYPST_PACKAGE_PATH="$PWD/packages" tt run
```

To run the current test suite against the published `0.1.0` release, make sure no local override is active:

```bash
env -u TYPST_PACKAGE_PATH tt run
```

This tells you whether the released package still passes today's tests. A failure does not always mean the release is broken: the current suite may cover an API or behavior that has not been released yet.

You can make the opposite comparison with a worktree at the release tag or commit. First run the old test suite against the published package to verify the release itself, then point those same tests at your current checkout to check backward compatibility:

```bash
development_packages="/absolute/path/to/current/numera/packages"
release_worktree="/absolute/path/to/release/worktree"

(
  cd "$release_worktree"
  env -u TYPST_PACKAGE_PATH tt run
  TYPST_PACKAGE_PATH="$development_packages" tt run
)
```

Together, these commands answer four useful questions:

- Does the current checkout pass the current tests?
- Does the published release still pass the current tests?
- Does a release pass the tests that shipped with it?
- Does the current checkout still pass an older release's tests?

Keeping release commits tagged makes the last two checks easy to reproduce.

## Checks and publishing

Format and verify development code before submitting a change:

```bash
typstyle --inplace .
typstyle --check .
tt --package-path "$PWD/packages" run
typst compile --package-path "$PWD/packages" docs.typ
```

Publishing is a separate, intentional release step:

```bash
typst-package-check check

typship login universe
typship publish universe --upload-method api
```
