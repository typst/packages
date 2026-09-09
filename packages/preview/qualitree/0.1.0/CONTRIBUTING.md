# Maintaining Qualitree

The library uses native Typst and has no runtime package dependencies. Python scripts use only the standard library. Keep semantic computation independent from rendering.

## Module boundaries

| Module | Responsibility |
| --- | --- |
| `lib.typ` | Explicit public exports |
| `model.typ` | Matrix/series normalization and validation |
| `calculations.typ` | Priority arithmetic and public roof coordinates |
| `stages.typ` | Stable identities and propagation to the next stage |
| `revisions.typ` | ID alignment, edit status and historical data |
| `theme.typ`, `labels.typ` | Visual defaults and translatable text |
| `figure-data.typ` | Resolve visibility and basement once per figure |
| `layout.typ`, `text.typ` | Measure natural geometry and fit constrained content |
| `profile-layout.typ` | Pure score-preserving displacement algorithm |
| `symbols.typ`, `profile-symbols.typ` | Shared native vector primitives |
| `roof.typ`, `matrix-panel.typ`, `comparison-panel.typ`, `legend.typ` | Render one region from shared data and geometry |
| `draw.typ` | Public argument boundary and composition |

Panel modules must not recompute priorities or infer identities. Revision history must never enter current-priority arithmetic. Measurements use the same decorated labels that are drawn. Lines and competitive markers use the same displaced points.

## Comments

Follow [Salvatore Sanfilippo's guidance](https://antirez.com/news/124): function comments specify contracts, module comments describe design, and local comments explain reasons or domain knowledge that would otherwise require reconstruction. Keep comments adjacent to the code they describe. Avoid redundant narration, commented-out implementations, and unexplained debt markers.

A useful comment here explains why a removed relation has a visible historical symbol but zero current value. An unhelpful comment merely says that a loop visits rows.

## Verify a change

```sh
python3 tools/test.py
python3 tools/build_examples.py
python3 tools/build_docs.py --check
python3 tools/package.py
```

Use small numerical assertions for semantics; use rendered fixtures for layout. Add regression cases that would fail under the old behavior. For geometry changes, inspect the espresso, component, revision and overlapping-profile outputs. Check at natural size and when fitted into a report. Tests compile with the bundled fonts and ignore system fonts, exposing undocumented font dependencies.

`docs/site/` contains source-controlled HTML/CSS/JS and rendered examples. `tools/build_docs.py` validates local links, anchors and image alternatives before copying it to `build/site/`. `tools/build_examples.py` refreshes the actual diagram assets. Edit the Typst example, not its SVG output.

## Release

1. Update the manifest version, documented imports and examples together.
2. Run the checks above and inspect rendered output.
3. Build `build/packages/preview/qualitree/VERSION/` using `tools/package.py`.
4. Check the bundle contains the README, license, manifest, library and public examples. It deliberately omits build tools, fonts and documentation images.
5. Push the repository. The Pages workflow validates and publishes the guide; it grants write access only to the deploy job.
6. Submit the versioned directory to [typst/packages](https://github.com/typst/packages) with a PR. Keep the source repository and homepage in the manifest.
7. Use `@preview` in the quickstart only after the package PR is merged and available.

Published versions are immutable in normal circumstances. Ship a new version for fixes.
