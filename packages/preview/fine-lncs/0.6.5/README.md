# fine-lncs

**fine-lncs** is a [Typst](https://typst.app) template that tries to closely replicate the look and structure of the official [Springer LNCS (Lecture Notes in Computer Science)](https://www.overleaf.com/latex/templates/springer-lecture-notes-in-computer-science/kzwwpvhwnvfj#.WuA4JS5uZpi) LaTeX template.

## Usage

```typst
#import "@preview/fine-lncs:0.6.5": author, institute, lncs, proof, theorem

#let inst_princ = institute(
  "Princeton University",
  addr: "Princeton NJ 08544, USA",
)
#let inst_springer = institute(
  "Springer Heidelberg",
  addr: "Tiergartenstr. 17, 69121 Heidelberg, Germany",
  email: "lncs@springer.com",
  url: "http://www.springer.com/gp/computer-science/lncs",
)
#let inst_abc = institute(
  "ABC Institute",
  addr: "Rupert-Karls-University Heidelberg, Heidelberg, Germany",
  email: "{abc,lncs}@uni-heidelberg.de",
)

#show: lncs.with(
  title: "Contribution Title",
  // Opt.: Set this, if the title is too long to avoid linebreaks in the header of odd pages
  // running-title: "Short version of contribution title",
  // running-author: "Override the default author shortening",
  thanks: "Supported by organization x.",
  authors: (
    author("First Author", insts: (inst_princ), oicd: "0000-1111-2222-3333"),
    author(
      "Second Author",
      insts: (inst_springer, inst_abc),
      oicd: "1111-2222-3333-4444",
    ),
    author("Third Author", insts: (inst_abc), oicd: "2222-3333-4444-5555"),
  ),
  abstract: [
    The abstract should briefly summarize the contents of the paper in
    15--250 words.
  ],
  keywords: ("First keyword", "Second keyword", "Another keyword"),
  bibliography: bibliography("../../template/refs.bib"),
)

= First Section

My awesome paper ...
```

### Local Usage

If you want to use this template locally, clone it and install it with:

```bash
just install
```

This allows you to import the template using

```typst
#import "@local/fine-lncs:0.6.5": lncs, institute, author, theorem, proof
```

## Development

Common tasks are wrapped in a [`justfile`](https://github.com/casey/just). Run `just` in the repo root to see all recipes:

```text
dev              # Symlink this template into the local @preview package dir
install          # Install this template locally as @local/fine-lncs
fmt              # Format all .typ files in place
fmt-check        # Check formatting without modifying files (same as CI)
gen-tests        # Regenerate tests/template/ and tests/readme/ from source
gen-tests-check  # Regenerate, then fail if the committed copies drift (CI)
pdf-to-ref       # Convert a LaTeX PDF into ref/1.png, ref/2.png, ...
test             # Run the test suite
bump <version>   # Bump the package version across all files
ci               # Run everything CI runs
```

Required tools:

- [`just`](https://github.com/casey/just) — command runner
- [`utpm`](https://github.com/typst-community/utpm) — local package management and Universe publication
- [`typstyle`](https://github.com/typstyle-rs/typstyle) — formatter (`cargo install typstyle`)
- [`tytanic`](https://github.com/tingerrr/tytanic) — test runner (`cargo install tytanic`)

Use `just dev` to symlink this library into your local `@preview` Typst package directory while you're iterating on it. Use `just install` to copy it into `@local`.

### Formatting

All `.typ` files are formatted with `typstyle`. CI enforces this via `just fmt-check`, so before pushing run:

```bash
just fmt
```

### Testing

The project uses [tytanic](https://github.com/tingerrr/tytanic) for tests. Run the full suite with:

```bash
just test
```

Two tests (`tests/template/` and `tests/readme/`) are generated automatically from `template/main.typ` and the `README.md` usage example respectively. They compile against the local `src/lib.typ` instead of the published `@preview` version, and `just gen-tests` also refreshes their committed `ref/` snapshots so CI catches both API and rendering regressions before a release. After changing the template or the README example, regenerate them:

```bash
just gen-tests
```

Commit the regenerated files alongside your changes.

If you want to compare Typst output against the official LNCS LaTeX template, first render the LaTeX source to PDF and then convert that PDF into tytanic-compatible reference snapshots:

```bash
just pdf-to-ref latex-srcs/samplepaper.pdf tests/some-test/ref
```

This exports the PDF at `144` ppi, producing `tests/some-test/ref/1.png`, `2.png`, and so on. Pass a third argument to override the pixel density if needed.

### Releasing

Publication to the [Typst Universe](https://typst.app/universe) is handled by [`utpm`](https://github.com/typst-community/utpm) and is intentionally decoupled from GitHub tagging: the two systems are independent and must be triggered separately.

The [`VERSION`](VERSION) file at the repo root is the single source of truth for the package version. Every other version reference (in `typst.toml`, `template/main.typ`, and the `README.md` import examples) must match it — the release script enforces this.

Release flow:

1. Bump the version with `just bump <new-version>`. This updates `VERSION`, `typst.toml`, `template/main.typ`, and the `README.md` import examples atomically.
2. Regenerate the derived tests: `just gen-tests`.
3. Create a release branch named `release/X.Y.Z`, where `X.Y.Z` matches `VERSION`. For example, `0.6.4` releases from `release/0.6.4`.
4. Commit both the bump and the regenerated tests on that release branch.
5. From a clean `release/X.Y.Z`, dry-run the release pre-flight:

   ```bash
   just release-check
   ```

   This verifies: `VERSION` parses as semver, it's greater than the most recent `v*` git tag, every in-repo reference matches it, the working tree is clean, the current branch is the matching `release/X.Y.Z` branch, and `just ci` passes.

6. Make sure `UTPM_GITHUB_TOKEN` is set in your shell. `utpm prj publish` currently requires it.
   A repo-local `.env` file also works; `scripts/release.sh` loads it automatically.
7. When all checks pass, publish:

   ```bash
   just release
   ```

   Runs the same checks and, on success, bootstraps `utpm`'s local
   `git-packages` checkout if needed, archives any previous checkout
   instead of resetting and searching through it, recreates a sparse
   checkout rooted at this package's `packages/preview/<name>` path,
   ensures a writable `https://github.com/<you>/packages.git` fork is
   available as the push remote, syncs fork `main` back to upstream
   `main` when an older publish left the fork branch diverged, runs
   `utpm prj publish -p` so `utpm` only prepares and pushes the package
   update, and finally creates or reuses the GitHub pull request itself.
   This works around current `utpm 0.3.0` publish failures around both
   stale `git-packages/` state and its broken post-push GitHub API step.

Tagging the release on GitHub is a separate manual step and isn't performed by this script.
