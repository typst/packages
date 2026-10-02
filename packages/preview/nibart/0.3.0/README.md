# nibart

**A MetaPost-like approach to running a pen along a path** — for Typst 0.15+.\
[Français](README.fr.md) · [Manual (EN)](https://github.com/fergousA/nibart/blob/main/docs/manual-en.pdf) · [Manuel (FR)](https://github.com/fergousA/nibart/blob/main/docs/manual-fr.pdf) · [Gallery](https://github.com/fergousA/nibart/blob/main/docs/gallery-en.pdf) · [Galerie](https://github.com/fergousA/nibart/blob/main/docs/gallery-fr.pdf) · [Changelog](https://github.com/fergousA/nibart/blob/main/CHANGELOG.md)

`nibart` brings the heart of Metafont/MetaPost to Typst: smooth paths described with Hobby's algorithm (directions, tensions, curls),
and *pens* — circle, ellipse, broad-edged nib, polygon, or a nib that changes width and angle along the stroke — whose
exact swept outline is computed for you. Calligraphy, lettering, flourishes, hand-drawn diagrams, technical figures in the
MetaPost tradition: all as plain vector shapes.

![Gallery](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/gallery.jpg)

## Installation

From **Typst Universe** there is nothing to install: `#import "@preview/nibart:0.3.0" as nib`.

## Quick start

```typ
#import "@preview/nibart:0.3.0" as nib

// a path in MetaPost syntax, a broad-edged pen
#nib.nib-stroke(
  nib.mp-path("(0,0){up}..(25,45)..(60,10)..(95,50)"),
  pen: nib.broadnib(10pt, t: 2.5pt, angle: 35deg),
)

// a nib whose width changes along the stroke, and that follows the path
#nib.nib-stroke(
  nib.mp-path("(0,0)..(30,40)..(60,0)..(90,40)"),
  pen: nib.nibpen(
    (at: 0%, width: 3pt), (at: 50%, width: 14pt, thinness: 40%), (at: 100%, width: 3pt),
    angle: 40deg,
  ),
  fill: rgb("#7a2e0e"),
)
```

The axes follow MetaPost (*y points up*, angles are counter-clockwise). Use `nib.xxx` rather than `import "…": *`:
the package exports generic names (`draw`, `cubic`, `reverse`, `pressure`…).

## Features

- **Path language** — `mp-path("(0,0){up}..tension 1.5..(40,20)--cycle")`: `..`, `--`, `{dir}`, `{curl}`, `tension`, `controls`,
  `cycle`; also `mp-path-pts`, `cubic`, `straight`, `polyline`, `cubics`, `path-join`.
- **Hobby's algorithm**, checked against `mpost` (same control points, max difference < 0.01 pt on 17 test paths).
- **Pens** — `pencircle`, `penellipse`, `broadnib`, `penpoly`, `pensquare`, `penrazor`, and `nibpen` with stops along the
  arc length and an optional *follow-the-tangent* mode.
- **Exact outlines** — the swept region is computed as real geometry (no stamping), with a union of all overlaps.
- **Calligraphic effects** — irregular dashes with jitter, intermittent pressure, layered pieces, outlines, a debug view.
- **Path operations** — `point-of`, `direction-of`, `arclength`, `arctime`, `subpath`, `reverse`, `closest-time`,
  `intersection-times`, `intersection-point`, bounding box, and affine transformations (`shifted`, `scaled`, `rotated`,
  `slanted`, `reflected`, `transformed`…).
- **Knots and interlace** — `knot(...)`: automatic crossings (also within one strand), alternating over/under, "gap" or Celtic "weave" style, links, braids.
- **Calligraphic ornaments** — `copperplate` (pointed pen), `prongs` (multi-tine nib), `delimiter` (braces and parentheses between two points).
- **Path surgery** — `offset` (parallel curves), `shorten`, `split-at`, `remove-intervals`, `weld`, `join-smooth`, `round-corners`, `frames-along`…
- **Figures** — `mp-fig` (like `beginfig … endfig`) with dots, labels, fills, skeletons and an optional grid; baseline-aware,
  so figures can be used inline.

| | |
|---|---|
| ![Exotic](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/exotic.jpg) | ![Slides](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/slides.jpg) |
| ![Calligraphy](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/calligraphy.jpg) | ![Flourishes](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/flourishes.jpg) |

### nibart: knots, braces, pointed pen

Trefoil, Olympic and Borromean rings, braids and Celtic interlace; calligraphic braces; a copperplate pen; offsets, rounded corners and frames along a path — [`examples/nibart.typ`](https://github.com/fergousA/nibart/blob/main/examples/nibart.typ) (`--input lang=en` for English captions).

![nibart](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/nibart.jpg)

### The unexpected

A score with tapered slurs, knots that weave over and under (computed with `intersection-times`), a neon sign, embroidery,
a fractal cherry tree, a dry-brush enso, an engraved sphere, guilloché, a map and a hand-drawn sketch — one file,
[`examples/insolite.typ`](https://github.com/fergousA/nibart/blob/main/examples/insolite.typ) (`--input lang=en` for English captions).

| | | |
|---|---|---|
| ![Dry-brush enso, pink cherry tree, engraved sphere, and guilloché medallion](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/unexpected-1.jpg) | ![Interlaced knots, a musical score, neon nib sign, and embroidered flower](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/unexpected-2.jpg) | ![Illustrated island map, shaded contour map, and hand-drawn workflow sketch](https://raw.githubusercontent.com/fergousA/nibart/main/docs/img/unexpected-3.jpg) |

The complete sources of these pictures are in [`examples/`](https://github.com/fergousA/nibart/tree/main/examples) (`galerie`, `exotique`, `boites`, `calligraphie`, `insolite`, `nibart`, `demo`, `chat`, `ile`, `ile-chat`, `podium`).
In a clone of the repository, compile them with `typst compile --root . examples/galerie.typ`.
The examples that the manual does not show are gathered, with a preview, a description, the functions they use and their build command, in the illustrated gallery: [`gallery-en.pdf`](https://github.com/fergousA/nibart/blob/main/docs/gallery-en.pdf) / [`gallery-fr.pdf`](https://github.com/fergousA/nibart/blob/main/docs/gallery-fr.pdf) (rebuild: `sh scripts/build-gallery.sh && make gallery`). Most examples are bilingual: add `--input lang=en` or `--input lang=fr`.

## Documentation

The reference manual (English and French; every function with its parameters table and a detailed example, all executed by the package itself) is in [`docs/`](https://github.com/fergousA/nibart/tree/main/docs):
[`manual-en.pdf`](https://github.com/fergousA/nibart/blob/main/docs/manual-en.pdf), [`manual-fr.pdf`](https://github.com/fergousA/nibart/blob/main/docs/manual-fr.pdf). Rebuild it with
`typst compile --root . docs/manual.typ` (add `--input lang=fr` for French).

## Limits

- Not implemented: `atleast`, `&`, `buildcycle`; `...` behaves as `..`.
- `draw` returns filled shapes; `mp-label` content is not part of the automatic bounding box.
- The geometry lives in a WebAssembly plugin (`nibart.wasm`); it works with the Typst CLI and packages from Universe.
- Variable pens, dashes and pressure are slower than fixed pens (see the manual for tuning).

## Development

The Rust sources of the plugin are in `rust/` in the repository (not part of the published package). `make wasm` rebuilds `nibart.wasm`
(target `wasm32-unknown-unknown`), `make test` runs the tests, `make docs` rebuilds the manual, `make package` produces
and validates the publishable directory in `dist/`.

## Licence

Author: **FERGOUS Abdelhak** ([@fergousA](https://github.com/fergousA)) · repository: <https://github.com/fergousA/nibart>.\
[MIT](LICENSE). Third-party crates: see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
Inspired by MetaPost (D. Knuth, J. D. Hobby) and by the `nibst` package (B. Auguie): the calligraphic options reproduce
its described behaviour; no code from either project is included.
