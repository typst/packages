# Publishing to Typst Universe

Checklist for submitting a version of Noteworks to the
[typst/packages](https://github.com/typst/packages) monorepo.
(This file is `exclude`d from the package bundle.)

## Per-release steps

1. **Bump the version** everywhere — it appears in more than typst.toml:
   - `typst.toml` (`version = "X.Y.Z"`)
   - `template/main.typ` import string (plus the sample import shown in
     its Getting Started block)
   - `lib.typ` header comment, `README.md` code blocks
   - `.github/workflows/ci.yml` (symlink path + typst-version if bumped)

   ```bash
   grep -rl '@preview/noteworks:OLD' . | xargs sed -i '' 's/OLD/NEW/g'
   ```

2. **Regenerate the thumbnail** (250 PPI, longer edge >= 1080px, < 3 MiB,
   PNG or lossless WebP, must show the initialized template's first page):

   ```bash
   cd template && typst compile main.typ ../thumbnail.png \
     --format png --pages 1 --ppi 250
   ```

3. **Verify locally** (the preview-cache symlink from README's
   "Local development" section must point at this repo):

   ```bash
   typst compile template/main.typ /tmp/demo.pdf
   typst compile --root . examples/main.typ /tmp/example.pdf
   cd "$(mktemp -d)" && typst init @preview/noteworks:X.Y.Z t \
     && cd t && typst compile main.typ
   ```

4. **Submit**: fork typst/packages, copy this repo's contents to
   `packages/preview/noteworks/X.Y.Z/` (respecting `exclude` is done by
   their tooling, but don't copy `.git`, PDFs, or scratch files), and
   open a PR. The package appears on Universe ~30 minutes after merge.

## Universe rules worth remembering

- Template files must import `@preview/noteworks:X.Y.Z` — never
  relative paths (only the in-repo `examples/` may import `../lib.typ`;
  they are excluded from the bundle).
- The README is the Universe page: examples in it must compile with the
  current version number.
- `description` in typst.toml: 40-60 chars, no "Typst"/"package"/
  "template", no indefinite articles.
- The same person must submit subsequent versions (or get prior
  approval from the previous submitter).
