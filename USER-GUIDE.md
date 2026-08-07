# User Guide — xkcd-style sketchy drawing in Typst

Hand-drawn / xkcd-looking vector graphics for **Typst 0.15.1** + **CeTZ 0.5.2**.
Every line gets a slow, organic wobble instead of being mathematically straight.

---

## 1. Quick start

You need **Typst 0.15.1** (or later 0.15.x). **That is the only requirement.**
You do *not* need Rust, cargo, or a WebAssembly target — the compiled
`sketch.wasm` engine is included and ready to use.

```bash
cd xkcd
typst compile example.typ --font-path fonts     # small starter figure
typst compile gallery.typ --font-path fonts     # what else it can do
typst compile xkcd.typ    --font-path fonts     # the full 4-figure document
```

The `--font-path fonts` flag matters: without it the bundled handwriting
font is not found and Typst silently falls back to a normal sans face
(you get a warning, but it still produces a PDF).

Live preview while editing:

```bash
typst watch example.typ --font-path fonts
```

### Files

| File | What it is |
|---|---|
| `example.typ` | minimal starting point — copy this |
| `gallery.typ` | flowchart, charts, illustration, parametric curves |
| `xkcd.typ` | the full document, four worked figures |
| `xkcd-lib.typ` | the drawing API you import |
| `sketch.wasm` | the decoration engine (precompiled) |
| `fonts/` | handwriting font |
| `plugin/src/lib.rs` | engine source, only needed to rebuild |
| `build.sh` | rebuild engine + document |

---

## 2. Your first drawing

```typst
#import "@preview/cetz:0.5.2"
#import cetz.draw: *
#import "xkcd-lib.typ": *

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: ("xkcd Script", "xkcd", "DejaVu Sans"))

#cetz.canvas(length: 1cm, {
  xkcd-line(((0, 0), (0, 4)), seed: 1, stroke: 1.2pt)
  xkcd-line(((0, 0), (6, 0)), seed: 2, stroke: 1.2pt)
  xkcd-circle((3, 2), 0.8, seed: 3, stroke: 1pt, fill: yellow)
  content((3, 2), [hello])
})
```

Keep `xkcd-lib.typ` and `sketch.wasm` in the same folder as your document,
or adjust the import path.

---

## 3. The drawing functions

All of them take a `seed:` and pass any extra named arguments straight
through to CeTZ (`stroke:`, `fill:`, `mark:`, ...).

```typst
xkcd-line(points, seed: 1, closed: false, ..style)
xkcd-rect(corner-a, corner-b, seed: 1, ..style)
xkcd-circle(center, radius, seed: 1, ..style)
xkcd-arc(center, radius, start-deg, end-deg, seed: 1, ..style)
xkcd-plot(f, from, to, samples: 100, seed: 1, ..style)
xkcd-grid(corner-a, corner-b, step: 1, seed: 1, ..style)
```

Examples:

```typst
// polyline through three points
xkcd-line(((0,0), (0,3), (3,3)), seed: 7, stroke: 1.2pt)

// closed + filled
xkcd-rect((0,0), (2,1), seed: 8, stroke: 1pt, fill: red.lighten(60%))

// a function plot, y = sin x
xkcd-plot(x => calc.sin(x * 1rad), 0, 7, samples: 100, seed: 9,
          stroke: (paint: pltblue, thickness: 1.2pt))

// half circle, degrees, counter-clockwise
xkcd-arc((0,0), 1.5, 0, 180, seed: 10, stroke: 1.2pt)

// an arrow head still works
xkcd-line(((0,0), (3,2)), seed: 11,
          stroke: 1pt, mark: (end: "stealth", fill: black))
```

More shapes, all built on the same engine:

```typst
xkcd-ellipse(center, rx, ry, seed: 1, ..style)
xkcd-polygon(center, r, n: 5, start: 90, seed: 1, ..style)   // n-gon; n:4 = diamond
xkcd-star(center, r-outer, r-inner, n: 5, seed: 1, ..style)
xkcd-rounded-rect(a, b, radius: 0.3, seed: 1, ..style)
xkcd-wedge(center, r, a0, a1, seed: 1, ..style)              // pie slice
xkcd-bezier(p0, c1, c2, p3, seed: 1, ..style)
xkcd-smooth(points, samples: 12, closed: false, seed: 1, ..style)
```

`xkcd-smooth` draws a Catmull-Rom spline *through* your points — useful when
you want a flowing curve but only want to specify a handful of positions.

`pltblue` (`#1F77B4`, the matplotlib blue) is exported for convenience.

Text is *not* wobbled — use CeTZ's normal `content()`. The handwriting font
does that job.

---

## 4. Seeds: controlling the wobble

Every shape takes `seed:`, an integer. **The same seed always produces the
same wobble**, so your document is reproducible — it will not re-shuffle
each time you compile.

- Give each shape a **different** seed, or neighbouring shapes will wobble
  identically and it looks copy-pasted.
- Don't like how one line came out? Change *its* seed until it looks right.
- Two shapes that should look "drawn in the same stroke"? Give them the same seed.

A simple habit is to number them per figure: `seed: 1, 2, 3...`, and use a
separate block (`seed: 100 + i`) inside loops:

```typst
for i in range(5) {
  xkcd-line(((i, 0), (i, 3)), seed: 100 + i, stroke: 0.5pt)
}
```

---

## 5. Tuning the look

Pass an `opts:` dictionary to override the defaults:

```typst
xkcd-line(pts, seed: 1, opts: (amplitude: 1.2, wavelength: 60))
```

| Option | Default | Effect |
|---|---|---|
| `amplitude` | `0.5` | wobble size, in pt. **The main knob.** Raise to ~1–2 for a scruffier look, lower to 0.2 for a subtle one. |
| `wavelength` | `100.0` | how *long* each wobble is. Smaller = more frequent, jittery. Larger = long lazy curves. |
| `randomness` | `2.0` | irregularity of the wobble rhythm. `1.0` gives an almost perfect sine; higher is more erratic. |
| `segment` | `0.5` | sampling step in pt. Rarely worth changing; smaller = smoother but slower. |
| `epsilon` | `0.02` | output simplification tolerance in pt. `0` disables it (much larger files, no visible gain). |

To change the defaults globally for a document, edit the `DEFAULTS`
dictionary at the top of `xkcd-lib.typ`.

---

## 6. Working with scaled axes

This is the one thing that will bite you.

The wobble is applied in **paper space**, so it should always be about half a
point on the page regardless of what your data looks like. If your data is in
units like "0 to 100 along x, 0 to 110 up y", **do the scaling yourself when
you build the coordinates** — don't hand raw data values to the drawing
functions.

The pattern used throughout `xkcd.typ`:

```typst
#cetz.canvas(length: 1cm, {
  let SX = 0.08     // x scale factor
  let SY = 0.15     // y scale factor
  let P(x, y) = (x * SX, y * SY)     // data -> canvas

  xkcd-line((P(0, -30), P(100, -30)), seed: 1, stroke: 1.2pt)
  xkcd-line((P(1, 1), P(70, 1), P(100, -28)), seed: 2, stroke: 1.2pt)
})
```

Define `P()` once per figure and wrap every coordinate in it. If instead you
pass unscaled data and shrink the canvas afterwards, the wobble is scaled too
and you get a wild zigzag on the squashed axis.

(There is a `scale:` parameter on each function for the same purpose, but the
`P()` helper is clearer and is what the example figures use.)

---

## 7. Drawing anything else

**The engine is not limited to the built-in shapes.** It only ever consumes a
list of `(x, y)` points, so *anything* you can express as coordinates can be
drawn sketchy: diagrams, maps, charts from your own data, logos, parametric
curves, geometry generated by a loop.

The one rule: build a list of points, hand it to `xkcd-line`.

```typst
// a triangle
xkcd-line(((0,0), (2,0), (1,1.7)), closed: true, seed: 1, stroke: 1pt)

// your own data
let data = (3, 7, 4, 9, 6)
xkcd-line(data.enumerate().map(((i, v)) => (i * 0.5, v * 0.2)), seed: 2)

// anything parametric
let heart = range(200).map(i => {
  let t = i / 199 * 2 * calc.pi
  let x = 16 * calc.pow(calc.sin(t * 1rad), 3)
  let y = (13 * calc.cos(t * 1rad) - 5 * calc.cos(2 * t * 1rad)
    - 2 * calc.cos(3 * t * 1rad) - calc.cos(4 * t * 1rad))
  (x * 0.08, y * 0.08)
})
xkcd-line(heart, closed: true, seed: 3, stroke: 1pt, fill: red.lighten(70%))
```

See **`gallery.typ`** for worked examples: a flowchart, bar/pie/scatter
charts, a freeform landscape, and parametric curves.

Two Typst syntax gotchas when generating points in loops:

- Wrap a multi-line arithmetic expression in parentheses, or Typst reads the
  continuation lines as separate values (`cannot join float with array`).
- Don't start a continuation line with `+`; it parses as a unary sign.
  Put the `+` at the end of the previous line, or use `out += ...`.

### Flattening helpers

To wobble a curve you must first turn it into points. Provided:

```typst
flatten-bezier(p0, c1, c2, p3, n: 24)      // cubic Bezier -> points
flatten-arc(center, r, a0, a1, n: 40)
flatten-circle(center, r, n: 64)
rect-points(a, b)
plot-points(f, from, to, samples: 100)
```

```typst
// a curved connector
let pts = flatten-bezier((0,0), (1,2), (3,-1), (4,1))
xkcd-line(pts, seed: 12, stroke: 1pt)

// a parametric spiral
let spiral = range(200).map(i => {
  let t = i / 20
  (t * calc.cos(t * 1rad), t * calc.sin(t * 1rad))
})
xkcd-line(spiral, seed: 13, stroke: 1pt)
```

Raise `n:` / `samples:` if a curve looks faceted before the wobble is applied.

---

## 8. Fonts

The document requests `"xkcd Script"`, then `"xkcd"`, then `"DejaVu Sans"`.
To use a different handwriting face, drop the files into `fonts/` and edit:

```typst
#set text(font: ("Your Font", "DejaVu Sans"), size: 11pt)
```

Check what Typst can actually see:

```bash
typst fonts --font-path fonts
```

If the name doesn't appear in that list, the file is not a valid font (a
common cause: a download that silently saved an HTML error page instead).

`use-ofl-font.sh` swaps in Comic Neue automatically if you'd rather use that.

---

## 9. Rebuilding the engine (optional)

**You almost certainly don't need this.** `sketch.wasm` is precompiled and
included; Rust is only required if you want to change the engine itself
(`plugin/src/lib.rs`).

To compile the documents, plain Typst is enough:

```bash
typst compile xkcd.typ --font-path fonts
```

If you *do* want to rebuild the engine, you need the Rust toolchain **and**
the WebAssembly target — installing Rust alone is not sufficient, and a
missing target is what produces `can't find crate for 'std'` (see §10):

```bash
rustup target add wasm32-unknown-unknown
./build.sh
```

`build.sh` is defensive: it installs that target if it's missing, and if it
can't (no rustup, offline, ...) it prints a note and falls back to the
bundled `sketch.wasm` rather than failing.

---

## 10. Troubleshooting

**`unknown font family` warning, output looks like plain sans**
You forgot `--font-path fonts`.

**`file not found (searched at sketch.wasm)`**
`sketch.wasm` must sit next to the `.typ` file that imports `xkcd-lib.typ`.

**Lines look like a violent zigzag**
Scaled-axis problem — see §6. Your coordinates are being scaled *after*
the wobble is applied.

**Everything looks too neat / too messy**
Adjust `amplitude` (§5). It's the knob you want 90% of the time.

**Adjacent shapes wobble identically**
They share a seed. Give them different ones (§4).

**`error: cannot export multiple images without a page number template`**
PNG export needs a per-page name for multi-page documents:
`typst compile xkcd.typ "page-{p}.png" --font-path fonts`

**`error[E0463]: can't find crate for 'std'` when running `./build.sh`**
Rust is installed but the WebAssembly target is not. Either install it:

```bash
rustup target add wasm32-unknown-unknown
```

...or skip the plugin rebuild entirely — you only need it if you edit
`plugin/src/lib.rs`. The bundled `sketch.wasm` works as-is:

```bash
typst compile xkcd.typ --font-path fonts
```

(Current `build.sh` installs the target for you, or falls back to the
bundled binary. Older copies aborted here instead.)

**Compile feels slow**
Check `epsilon` isn't set to `0`, and that `samples:`/`n:` aren't far higher
than needed. Normal speed is well under a second for a full page.
