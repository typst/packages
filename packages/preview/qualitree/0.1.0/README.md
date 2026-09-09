<p align="center"><img src="https://raw.githubusercontent.com/tychota/qfd-typst/main/docs/site/assets/logo.svg" width="72" alt="Qualitree logo"></p>

# Qualitree

Draw, connect, and compare Houses of Quality in native Typst. Map **needs → functions → components**, carry priorities between stages, and show design revisions with readable green/red/yellow backgrounds.

[Documentation](https://tychota.github.io/qfd-typst/) · [Coffee example](https://github.com/tychota/qfd-typst/blob/main/examples/COFFEE.md) · [API reference](https://github.com/tychota/qfd-typst/blob/main/docs/API.md)

![House of Quality and coffee-machine illustration](https://raw.githubusercontent.com/tychota/qfd-typst/main/docs/site/assets/hero.png)

## Start in five minutes

Install [Typst 0.15.1 or newer](https://github.com/typst/typst/releases). On macOS:

```sh
brew install typst
git clone https://github.com/tychota/qfd-typst.git
cd qfd-typst
mkdir -p build
typst compile --root . --font-path fonts examples/espresso.typ build/espresso.pdf
```

Open `build/espresso.pdf`. For automatic recompilation while editing:

```sh
typst watch --root . --font-path fonts examples/espresso.typ build/espresso.pdf
```

On Windows/Linux, download the CLI from the official releases page and put the executable on your PATH. Verify with `typst --version`. No LaTeX installation is needed.

In the [Typst web app](https://typst.app/), upload `lib.typ`, `src/`, and an example, preserving their folder structure. Upload the bundled Plex fonts too if those families are unavailable. Relative imports work without publishing a package.

## A first matrix

Create `main.typ` beside `lib.typ`:

```typst
#import "lib.typ": qfd
#set page(width: auto, height: auto, margin: 6mm)

#qfd(
  whats: ("Enjoy good coffee", "Prepare drinks quickly"),
  hows: ("Heat water", "Channel water"),
  importance: (10, 7),
  matrix: ((9, 3), (3, 9)),
  targets: ("92 °C*", [Recipe target]),
  directions: ("target", "maximize"),
  correlations: ((1, 2, "-"),),
  width: auto,
)
```

Compile with `typst compile --font-path fonts main.typ`. The temperature is an illustrative recipe hypothesis, not a universal recommendation.

## Connect stages

Stable IDs identify entities; labels are editable text. Relations remain one-based positions within each stage.

```typst
#import "lib.typ": qfd, qfd-stage, qfd-deploy
#let needs = qfd-stage(
  rows: ((id: "taste", label: "Good taste", weight: 10),),
  columns: ((id: "heat", label: "Heat water", direction: "target"),),
  matrix: ((9,),),
)
#let components = qfd-deploy(needs,
  columns: ((id: "heater", label: "Heater"),),
  matrix: ((9,),), labels: (whats: [Functions], hows: [Components]),
)
#qfd(..components)
```

`qfd-deploy` carries **unrounded relative weights** forward. Only displayed values are rounded. Priorities are engineering judgments; they do not replace acceptance thresholds for taste, temperature, or safety.

## Compare revisions

```typst
#import "lib.typ": qfd, qfd-stage, qfd-diff
#let before = qfd-stage(
  rows: ((id: "taste", label: "Good taste", weight: 10),),
  columns: ((id: "heat", label: "Heat water"),), matrix: ((3,),),
)
#let after = before + (matrix: ((9,),))
#qfd(..qfd-diff(before, after))
```

Additions have pale green backgrounds, removals pale red, and changes pale yellow. Dark symbols and +/−/~ annotations supplement color. Reordering IDs creates no false edits. Removed relationships remain visible but contribute zero to current priorities. Diff views do not currently support competitive profiles or custom basements; compare source stages without those options.

![Revision comparison](https://raw.githubusercontent.com/tychota/qfd-typst/main/docs/site/assets/revisions.svg)

## Typography and layout

Plex Sans labels and Plex Serif headings are the defaults, with built-in fallback families. The repository includes the fonts under their SIL Open Font License. The library does not install fonts or change your page settings.

Header and row sizes are measured automatically. Override `header-height`, `row-height`, `cell-size`, `label-padding`, `header-padding`, or `cell-padding` independently. `font`, `serif-font`, `font-size`, `grid-thickness`, `frame-thickness`, and `theme` control appearance. `width: auto` preserves natural dimensions; `width: 100%` scales a figure to a finite container. Scaling a dense chart into a small space also shrinks its text.

Correlation signs use bold vector +/− and circled strong signs. Choose `correlation-style: "text"` for ++/--. Direction indicators are ↑ maximize, ↓ minimize, and a bullseye for a target. Competitive markers stagger vertically by default, preserving score positions; `marker-stagger: false` restores centered markers. Dense ties may shrink markers, and crossings forced by score order cannot always be avoided.

## Named local installation

```sh
python3 tools/install_local.py
```

Then use `#import "@local/qualitree:0.1.0": qfd`. This only installs the library for the local CLI; fonts are separate. See [installation paths](https://github.com/tychota/qfd-typst/blob/main/docs/API.md#installation).

**Typst Universe:** [submission PR #5808](https://github.com/typst/packages/pull/5808) is open. Use relative or `@local` imports until it is accepted; `@preview/qualitree:0.1.0` is not available yet.

## Develop and verify

```sh
python3 tools/test.py
python3 tools/build_examples.py
python3 tools/build_docs.py
python3 tools/package.py
```

Tests execute Typst assertions, 128 visibility combinations and other layout cases, invalid inputs, stage propagation, ID-based revisions, and profile placement. All public examples compile with bundled fonts and without system fonts. Source files drive the documentation previews; `build_examples.py` refreshes them.

## Documentation map

- [Vocabulary](https://github.com/tychota/qfd-typst/blob/main/CONTEXT.md): needs, functions, components, technologies and thresholds.
- [Coffee study](https://github.com/tychota/qfd-typst/blob/main/examples/COFFEE.md): scope, assumptions, candidate technologies, evidence and validation work.
- [API](https://github.com/tychota/qfd-typst/blob/main/docs/API.md): inputs, styling, calculations and revision limitations.
- [Maintaining the package](https://github.com/tychota/qfd-typst/blob/main/CONTRIBUTING.md): module boundaries, comments, checks and releases.
- [Methodology](https://github.com/tychota/qfd-typst/blob/main/docs/METHODOLOGY.md): functional analysis and classic QFD terminology.
- [Design](https://github.com/tychota/qfd-typst/blob/main/DESIGN.md) and [implementation plan](https://github.com/tychota/qfd-typst/blob/main/PLAN.md).

## Credits

Tycho Tatitscheff and Julien Calixte.

## License

MIT for source and documentation. Bundled IBM Plex fonts retain their adjacent SIL Open Font License notices. The hero is an AI-generated decorative illustration; the examples are native Typst diagrams with explicit illustrative assumptions.
