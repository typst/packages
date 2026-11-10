# Contributing

The structure follows Solveng: `lib.typ` exports the core API, `letmeout-extras.typ` groups optional helpers, `src/` contains
implementation modules, `docs/` contains examples and design notes, and `tests/`
contains regression fixtures.

```sh
python3 tests/check.py
```

This checks the supplied image/math example, nesting, all functions,
inherited defaults, placement, styling, error handling, HTML frames, and native
paged equivalence. Generated files go in `tests/output/`. Open
`tests/output/features.html` in T3's browser and evaluate `tests/browser.js` for
browser assertions covering RTL, vertical alignment, resizing, and stroke removal.
Open `tests/output/document-adapters.html` and evaluate `tests/document-browser.js`
for typography, native API alignment, layout callback images, inline grid text, and
chip wrapping. Run these assertions in both Chromium and WebKit: font-edge syntax
support alone does not guarantee correct glyph bounds. The checks cover actual
descender clearance, scoped frame sizing, aspect ratios, and spacing after images.
The compile suite also checks release archives for missing documentation links.

On macOS, run the document assertions in the system `WKWebView` after compiling:

```sh
swift tests/check-wkwebview.swift
```

`scripts/api-docs.py` writes the doc comments of `grid`, `line`, `align`, `page`, and the element aliases
from the latest Typst docs on typst.app. It copies Typst's summary,
parameters, types, and defaults, and adds the HTML notes from `scripts/api.toml`.
It stops if Typst adds or removes a parameter that `api.toml` doesn't cover yet,
so each new parameter gets a decision about what it does in HTML.

```sh
python3 scripts/api-docs.py           # update the doc comments
python3 scripts/api-docs.py --check   # fail if they are out of date
```

Releases run from the Actions tab (`.github/workflows/release.yml`), as in
Solveng. Pick a channel: `alpha` and `rc` publish a GitHub prerelease; `stable`
publishes a release and opens a pull request to Typst Universe. The workflow
installs the latest Typst, runs `scripts/api-docs.py`, runs the tests, and
commits the updated docs with the release. The version comes from the
Conventional Commits since the last stable release; enable the commit message
check once per clone with `git config core.hooksPath .githooks`.

Release archives retain Markdown documentation and CONTRIBUTING.md even though
`typst.toml` excludes them from compiler packages: Universe validates README links
against the committed source files.
