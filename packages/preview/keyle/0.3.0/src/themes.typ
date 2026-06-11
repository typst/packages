// Built-in themes. Each preset is simply a `keycap`/`svg-keycap` factory with
// styling pre-bound through `.with(...)`. Users customize any of them with the
// exact same mechanism, e.g.
//
//   #let mine = keyle.themes.flat.with(fill: rgb("#fee"))
//   #let kbd = keyle.config(theme: mine)

#import "cap.typ": keycap, svg-keycap, style-text

/// Linux Biolinum Keyboard font theme. Needs the font installed.
/// -> content
#let biolinum(sym) = text(
  fill: black,
  font: "Linux Biolinum Keyboard",
  size: 1.4em,
  sym,
)

/// Type writer theme: a dark rounded cap haloed by a white ring.
/// -> content
#let type-writer(
  /// Baseline shift of the cap relative to surrounding text. -> length | ratio
  baseline: 0.3em,
  /// The key symbol. -> any
  sym,
) = {
  let bg = rgb("#333333")
  let edge = rgb("#2b2b2b")
  let cust = rect.with(inset: (x: 3pt, y: 2.5pt), stroke: bg, fill: edge, radius: 50%)
  let button = cust(smallcaps(text(fill: white, sym)))
  let ring = cust(outset: 2.2pt, fill: white, stroke: edge + 1.2pt, smallcaps(text(fill: edge, sym)))
  box(baseline: baseline, inset: 2.2pt, {
    place(ring)
    button
  })
}

/// Built-in theme dictionary. Values are renderer functions `sym => content`.
#let themes = (
  // rect backend ----------------------------------------------------------
  standard: keycap.with(
    fill: rgb("#eeeeee"),
    stroke: rgb("#555555") + 0.6pt,
    radius: 2pt,
    raise: 1pt,
    shadow: rgb("#555555"),
    text-args: (fill: black),
  ),
  deep-blue: keycap.with(
    fill: rgb("#4682b4"),
    stroke: rgb("#16456b") + 0.6pt,
    radius: 2pt,
    raise: 1pt,
    shadow: rgb("#16456b"),
    text-args: (fill: white),
    wrap: smallcaps,
  ),
  type-writer: type-writer,
  minimal: keycap.with(
    fill: rgb("#f6f8fa"),
    stroke: rgb("#d0d7de") + 0.6pt,
    radius: 3pt,
    inset: (x: 4pt, y: 2.5pt),
    raise: 0pt,
    shadow: none,
    text-args: (fill: rgb("#1f2328"), font: ("DejaVu Sans Mono", "Menlo")),
  ),
  // https://www.radix-ui.com/themes/playground#kbd
  radix: keycap.with(
    fill: rgb("#fcfcfd"),
    stroke: rgb("#1c2024") + 0.3pt,
    radius: 5pt,
    inset: (x: 6pt, y: 2.5pt),
    raise: 0pt,
    shadow: none,
    text-args: (fill: black, font: ("Helvetica Neue", "TeX Gyre Heros")),
  ),
  // svg backend -----------------------------------------------------------
  // https://flowbite.com/docs/components/kbd/
  flowbite: svg-keycap.with(
    fill: rgb("#f3f4f6"),
    stroke: rgb("#e5e7eb"),
    stroke-width: 1.2,
    radius: 6,
    lip: 2.5,
    text-args: (fill: rgb("#1f2937"), weight: "semibold"),
  ),
  flowbite-dark: svg-keycap.with(
    fill: rgb("#4b5563"),
    stroke: rgb("#374151"),
    stroke-width: 1.2,
    radius: 6,
    lip: 2.5,
    text-args: (fill: rgb("#f3f4f6"), weight: "semibold"),
  ),
  // https://daisyui.com/components/kbd/
  daisy: svg-keycap.with(
    fill: rgb("#ffffff"),
    stroke: rgb("#d4d4d8"),
    stroke-width: 1.4,
    radius: 7,
    lip: 4,
    text-args: (fill: rgb("#3f3f46"), weight: "medium"),
  ),
  // font backend ----------------------------------------------------------
  biolinum: biolinum,
)
