# Publishing checklist

This package is published in **two stages, in this order**: the GitHub
repository first, then Typst Universe.  Universe versions are **immutable**
and the listing displays `typst.toml`'s `repository`, so the repo (and its
`v1.0.0` tag) must exist *before* the Universe submission — otherwise fixing
the link later forces a pointless `1.0.1` bump.

## 0. Pre-flight (placeholders already resolved)

- [x] `typst.toml` → `authors = ["rasko-- <raskolny@gmail.com>"]` (Universe display name)
- [x] `typst.toml` → `repository = "https://github.com/Raskolny/europass-cv"`
- [x] `thumbnail.png` present at repo root and included in the package bundle.
      Do **not** add a `thumbnail` key to `typst.toml`: the current bundler
      rejects unknown manifest fields (it failed CI with
      `unknown fields in package: ["thumbnail"]`); the site picks the file up
      by convention.
- [x] README CI badge points at the real repository
- [ ] Regenerate `thumbnail.png` if the visual design changed:
      `typst compile --ignore-system-fonts --font-path fonts --format png --ppi 150 --pages 1 main.typ thumbnail.png`

## 1. GitHub first

1. Create the public repository `Raskolny/europass-cv`.
2. Push this tree (build outputs are gitignored; do not commit
   `output.pdf` or `examples/pdf/`).
3. Confirm the CI workflow is green on the default branch.
4. Tag the release: `git tag -a v1.0.0 -m "rasko-europass 1.0.0" && git push origin v1.0.0`.
   The Universe version **must** correspond to this tag.

## 2. Typst Universe second

1. Fork <https://github.com/typst/packages>.
2. Add the package at `packages/preview/rasko-europass/1.0.0/`, copying the
   repository contents **minus** the globs in `typst.toml`'s `exclude`
   (`output.pdf`, `build.sh`, `build-examples.sh`, `verify.sh`,
   `examples/pdf`).  Do **not** exclude `README.md` or `LICENSE`.
3. Ensure the folder name matches `{name}/{version}` and that `typst.toml`'s
   `name`/`version` agree.
4. Open the submission PR against `typst/packages`, referencing the
   `v1.0.0` tag of `Raskolny/europass-cv`.
5. Reviewers will check: licence (MIT) and the bundled fonts' licence
   (Apache-2.0, documented in `fonts/README.md`), the thumbnail, the README
   `@preview` usage snippet, and that the compiler floor (`0.15.0`) is correct.

## 3. After publication

- Future releases: bump `version` in `typst.toml` per SemVer, add a
  `CHANGELOG.md` entry, tag `vX.Y.Z`, then submit the new version folder.
  Never edit an already-published version.
- The README already imports `@preview/rasko-europass:1.0.0`; bump that snippet
  only when a new major is released.
