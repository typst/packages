# Contributing to `tuwien-geo-masterthesis`

Thanks for considering a contribution to this template! This document covers
how to set up your dev environment, the conventions we use, and how to get a
change merged and released.

## Getting Started

1. Fork the repository and clone your fork.
2. Install the required tooling:

   ```bash
   bash scripts/install-deps.sh
   ```

   This installs `typst`, `typstyle`, `just`, `uv`, `tt` (tytanic), `gotpm`,
   and `typst-package-check`. If the script doesn't work for your platform,
   install manually:

   - [`just`](https://just.systems)
   - [`uvx`/`uv`](https://docs.astral.sh/uv/getting-started/installation/)
   - [`gotpm`](https://github.com/npikall/gotpm)
   - [`typst`](https://github.com/typst/typst#installation)
   - [`typstyle`](https://github.com/typst/typstyle)
   - [`tytanic` (`tt`)](https://typst-community.github.io/tytanic/quickstart/install.html)
   - [`typst-package-check`](https://github.com/typst/package-check#using-this-tool)

3. Install the package locally so you can preview it while working on it:

   ```bash
   just install --editable  # installs into @local
   just install-preview     # installs into @preview
   ```

4. (Optional but recommended) Set up pre-commit hooks:

   ```bash
   just hooks-install
   ```

   These run `typstyle` formatting and basic hygiene checks
   (`trailing-whitespace`, `check-added-large-files`, `detect-private-key`)
   on every commit. Not enforced by CI, but keeps diffs clean.

Run `just` with no arguments to see the full list of available recipes.

## Branching & Pull Requests

- Branch off `main` in your fork, make your change, open a PR against `main`
  in this repository.
- No issue required first — feel free to open a PR directly, even for small
  stuff (typos, doc tweaks, small fixes). For larger features, opening an
  issue first (using one of the templates: bug / feature / docs / change) is
  a good idea to align before doing the work, but not mandatory.
- Keep PRs focused on one change where reasonable.

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/), since
the changelog is generated automatically from commit history
(`git-changelog` with the `conventional` parser). Please format your commits
as:

```
<type>(<scope>): <short summary>

[optional body]
```

Common types:

- `feat:` — a new feature
- `fix:` — a bug fix
- `docs:` — documentation only changes
- `chore:` — tooling/maintenance, no user-facing change
- `refactor:` — code change that neither fixes a bug nor adds a feature
- `test:` — adding or updating tests
- `ci:` — CI/workflow changes

Example: `fix(title-page): correct margin on landscape logo`

## Code Style

- Run `just format` (or `just fmt`) to auto-format `.typ` files with
  `typstyle` before committing.
- If you installed the pre-commit hooks, this happens automatically.

## Tests

- Tests live under the `tests/` directory and run via
  [tytanic](https://typst-community.github.io/tytanic/) (`tt`).
- Adding or updating a test case for behavior changes is encouraged, but not
  a hard requirement for your PR to be accepted — a maintainer can add
  missing coverage if needed.
- Useful commands:

  ```bash
  just test           # run the test suite
  just test-update     # update reference test output
  ```

## Before Opening a PR

Run the full CI suite locally to catch issues early:

```bash
just ci
```

This runs, in order:

- `just test` — the tytanic test suite
- `just docs` — builds the manual (`docs/docs.typ` → `docs/docs.pdf`)
- `just thumbnail` — builds the package thumbnail
- `just check` — packages the library and runs `typst-package-check` against it

All of these must pass before merge. CI runs this same suite (via GitHub
Actions, `.github/workflows/ci.yml`) against every push and PR.

## Release Process

Releases are cut by whoever has push access, using the `release` recipe.
Anyone with push rights can run this locally after merging changes to `main`:

```bash
just release patch   # or: minor / major / a specific semver
```

This does the following, in order:

- `just test` and `just check` — verifies everything is green first
- Ensures the working tree is clean (aborts otherwise)
- Bumps the version in `typst.toml` via `gotpm bump`
- Regenerates `CHANGELOG.md` from Conventional Commit history
  (`git-changelog`)
- Commits the bump (`chore(release): bumped version to X.Y.Z`) and creates
  an annotated tag `vX.Y.Z`

After that, push both manually as instructed by the command's output:

```bash
git push && git push --tags
```

Pushing the tag triggers `.github/workflows/release.yml`, which:

- Builds release notes from the changelog
- Builds the manual PDF
- Creates a **draft** GitHub release with the PDF attached

A maintainer reviews and publishes the draft release. Publishing to the
Typst Universe (`just publish`) is a separate, manual step, explained below.

### Publishing to the Typst Universe

`just publish` wraps `gotpm publish`, which pushes the package to a fork of
[`typst/packages`](https://github.com/typst/packages) — the repository
behind the Typst Universe. This needs a one-time setup before it works:

1. Fork [`typst/packages`](https://github.com/typst/packages) on GitHub.
2. Tell `gotpm` where your fork lives:

   ```bash
   gotpm config set fork.url <your-fork-url>
   ```

   This is a one-time, machine-local config — only whoever runs `gotpm
   publish` needs it set, not every contributor.

Once configured, `gotpm publish` does the following:

- Clones your configured fork
- Packages this repo's files (following `typst.toml`'s `exclude` list) into
  `packages/preview/tuwien-geo-masterthesis/<version>/` inside the clone
- Commits and pushes that to your fork

From there, open a pull request from your fork to `typst/packages` (same as
any other Universe submission) to get the new version listed.

## License

By contributing, you agree that your contributions are licensed under the
project's [MIT License](LICENSE). No sign-off or CLA required.
