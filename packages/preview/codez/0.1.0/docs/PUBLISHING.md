## Publishing `codez` to Typst Universe

1. Fork `https://github.com/typst/packages`.
2. Clone your fork (sparse checkout recommended).
3. Create directory: `packages/preview/codez/0.1.0`.
4. Copy this repository contents into that directory.
5. Open a PR against `typst/packages:main`.

Checklist before opening the PR:

- `typst.toml` fields are complete and valid.
- `README.md` examples are up-to-date and use `@preview/codez:0.1.0`.
- Preview assets are up-to-date: `./scripts/generate-previews.sh`.
- `LICENSE` matches manifest SPDX (`MIT`).
- Documentation/examples are linked from README and excluded in manifest.
- Package imports without errors on Typst `0.14.x`.
- Local smoke check passes: `./scripts/check.sh`.

After merge and CI completion, package indexing can take up to ~30 minutes.
