# Building and deployment notes

This file explains how to to build locally and deploy to Typst app and Typst templates.

Since v0.2.0, the build process is based on [`just`](https://github.com/casey/just)

## Toolchain & dependencies

To build, test and deploy new releases I'm using [just](https://github.com/casey/just), which is really nice!

`pngquant` and `zopflipng` are used for creating the thumbnails (thumbnails are
rendered directly by `typst`, so ImageMagick/Ghostscript are no longer needed):

```bash
sudo apt install pngquant zopfli
```

#### Installing a recent `just`

The `just` shipped by `apt` is too old (Ubuntu ships 1.21.0). Install the latest
prebuilt binary into `~/.local/bin` (which must be ahead of `/usr/bin` on your
`PATH`, so it shadows any apt-installed version):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
```

Verify with `just --version` (should report ≥ 1.51.0). Re-run the same one-liner
to upgrade later. If you previously installed it via apt, you can optionally
remove the stale copy with `sudo apt remove just`.

## Development process

For the sake of simplicity from a developer's perspective, there's a single repository on this side, containing a singe source folder for all the document types. When building, the repos is split and handled differently from Typst perspective. All the heavy-lifting for this is made using `just`.

The Justfile is split into two workflows, surfaced as recipe groups in `just --list`:

- **`dev`** — work against your live source via symlinks; nothing gets packed.
- **`release`** — build and check the artifacts published to the Typst Universe.

:warning: Packing **replaces the dev symlinks** with real dirs — but you don't need to think about it: `just dev` self-heals them, and `just test-all` / `just bump-version` restore them automatically.

### Working on the template (`dev`)

:warning: If running on Mac, you might have to adapt the shell used in `scripts/package` (uncomment the second line).

To develop in the template, the one command you need is:

```bash
just dev
```

It links the `@preview` packages at this repo's live source and compiles all six examples. It **self-heals** the symlinks, so it works even right after a `pack`/`test-all` — run it any time. (Under the hood it runs the internal `install-symblinks` step and then `just test`; you can still call `just install-symblinks` on its own for a bare relink without compiling.)

You can then work on any document and live-preview it, for instance with

```bash
typst watch src/bachelor_thesis.typ
```

The six examples can be compiled in one go to `examples/*.pdf` with `just compile-all`. Run the full test suite against your live source (no packing) with `just test`, or only the poster layout checks (every variant must fit one A1 page) with `just test-poster`.

### Testing local deployment (`release`)

When sufficiently confident that it seems to work, it's time to test a `preview` version as created by `typst`.

To deploy locally for `typst` command-line

```bash
just pack
```

This packs all six packages to `@preview` as the real Universe artifact (it depends on `compile-all` + `generate-thumbs`, so packed examples and thumbnails are fresh). It replaces the dev symlinks; `just dev` restores them when you go back to development (and `just test-all` / `just bump-version` restore them for you). The templates can be tested as needed by creating a local sample using:

```bash
typst init @preview/isc-hei-report:0.8.1
```

Then go the directory, try to compile with `typst watch report.typ`.

For convenience, `just test-all` packs the release and then runs the full test suite against it. It allows a quick check for errors before deploying to the universe.

To remove all packed/symlinked templates from `@preview`, use `just uninstall`.

### Bumping the version

Versions must stay consistent across the root `typst.toml` and every `templates/*/typst.toml`. Bump them all (and the `src/` imports) in one shot:

```bash
just bump-version          # patch:  0.7.9 → 0.7.10 (default)
just bump-version minor    # minor:  0.7.9 → 0.8.0
just bump-version 1.0.0    # explicit X.Y.Z
```

It re-installs the dev symlinks afterwards so `@preview` resolves the new version.

## Deploying to Typst universe

The messy boilerplate (sparse-clone the fork, sync to upstream, pack all six packages,
validate them, commit) is automated by two `just` recipes. **Neither creates the PR** —
you write that yourself on GitHub from the compare URL that's printed for you.

### Prerequisites (one-time)

- Fork [`typst/packages`](https://github.com/typst/packages) to your account (the recipes
  assume `pmudry/packages`; change `FORK`/`UPSTREAM` in `scripts/universe-common` if yours
  differs).
- Install [`typst-package-check`](https://github.com/typst/package-check) (the validator);
  it must be on your `PATH`.
- Make sure the version is what you want to publish (`just bump-version` if not). All six
  packages co-release at the same version; gaps are fine (e.g. 0.7.1 → 0.7.9).

### Releasing

```bash
# 1. Sparse-clone the fork (or reuse it), base a fresh `isc-hei-<version>` branch on
#    upstream/main, pack all six packages into it, validate with typst-package-check,
#    and commit. Nothing is pushed.
just universe-stage

# 2. (optional) Re-run only the validation against the already-packed clone.
just universe-check

# 3. Push the release branch to your fork and print the PR compare URL. This is the
#    ONLY step that writes to the network. It does NOT open the PR.
just universe-push
```

Then open the PR on GitHub via the printed compare URL and fill in the description (the
repository's PR template prompts for new-package vs. update, etc.).

### Updating an already-open PR

If CI flags something (or you spot a fix) while the PR is still **unmerged**, fix it in
this repo and refresh the *same* PR at the *same* version with one recipe:

```bash
just update-pr
```

It re-stages the current version (rebuild + re-validate) and **force-pushes** over the
existing `isc-hei-<version>` branch, so GitHub re-runs CI on the open PR in place — no new
PR, no version bump. (This is why a plain `just universe-push` isn't enough on the second
round: the rebuilt branch has different history and a non-force push is rejected.)
`update-pr` refuses to run unless the branch is already on your fork — for the *first*
push, use `just universe-push`.

:warning: This only works while the PR is unmerged. Once a version is **merged/published**
it's immutable — bump the version (`just bump-version`) and open a fresh PR instead.

Notes:

- The fork clone lives at `~/git/typst-packages` by default. Override with
  `UNIVERSE_CLONE=/some/path just universe-stage`.
- `universe-stage` rebases the release branch on `upstream/main` every time, so the PR
  diff is always *only* your `isc-hei-*` additions — you no longer need to manually sync a
  stale fork.
- Validation is **kebab-case-aware**: `typst-package-check` flags non-kebab public names,
  manifest problems, broken imports and unsupported README features. `universe-check`
  fails only on **errors**; warnings (e.g. the benign `authors/changed`) are printed but
  don't block.
- To do it by hand instead, `scripts/pack` accepts an explicit target:
  `./scripts/pack <clone>/packages/preview <template>` for each of `bachelor-thesis`,
  `report`, `document`, `exec-summary`, `tb-assignment`, `poster`.

### Forking issues

`universe-stage` sidesteps the classic "fork is behind/ahead of upstream" problem by
rebasing the release branch directly on `upstream/main`. If you still want to realign your
fork's `main` itself:

```bash
git fetch upstream
git checkout main
git reset --hard upstream/main
git push origin main --force
```

### Thumbnails & image quantization

Template thumbnails are regenerated with `just generate-thumbs` (this is also pulled in automatically by `just pack`). It renders the first page of each `src/*.typ` example **directly with `typst`** at 120 ppi (`--pages 1 --format png --ppi 120`), then shrinks each PNG with `pngquant` and a lossless `zopflipng` pass to keep the template size on the Universe small.

Rendering with `typst` instead of going through `examples/*.pdf` → Ghostscript → ImageMagick makes the output **byte-for-byte reproducible**: typst's PNG export embeds no timestamp, so regenerating with the same binaries and installed fonts yields identical files (no spurious git diffs). Cross-machine equivalence still requires the same fonts installed.

To re-quantize / re-compress images by hand:

```bash
pngquant --quality 50-80 *.png --ext .png --force
zopflipng -y in.png out.png   # lossless second pass
```