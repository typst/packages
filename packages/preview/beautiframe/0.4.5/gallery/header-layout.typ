#import "@preview/beautiframe:0.4.5": *

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)

#align(center)[#text(size: 14pt, weight: "bold")[Header Layout & Per-Environment Colors]]

#v(0.5em)

// ── Header layouts ──────────────────────────────────────────────────────────
#beautiframe-setup(style: "classic")

*`header-layout: "label-first"` — the default, label leads:*
#beautiframe-setup(header-layout: "label-first", label-abbrev: false)
#beautiframe-reset()
#theorem(name: "Bolzano")[If $f$ is continuous on $[a; b]$, it takes every value between $f(a)$ and $f(b)$.]

*`header-layout: "title-first"` — the title leads, the label follows:*
#beautiframe-setup(header-layout: "title-first")
#beautiframe-reset()
#theorem(name: "Bolzano")[If $f$ is continuous on $[a; b]$, it takes every value between $f(a)$ and $f(b)$.]

*`header-layout: "title-abbrev"` — the label always abbreviated:*
#beautiframe-setup(header-layout: "title-abbrev", label-abbrev: false)
#beautiframe-reset()
#theorem(name: "Bolzano")[If $f$ is continuous on $[a; b]$, it takes every value between $f(a)$ and $f(b)$.]

*`header-layout: "title-only"` — the title alone carries the header:*
#beautiframe-setup(header-layout: "title-only")
#beautiframe-reset()
#theorem(name: "Bolzano")[If $f$ is continuous on $[a; b]$, it takes every value between $f(a)$ and $f(b)$.]

*`header-layout: "prefix"` with `label-abbrev: true`:*
#beautiframe-setup(header-layout: "prefix", label-abbrev: true)
#beautiframe-reset()
#theorem(name: "Bolzano")[If $f$ is continuous on $[a; b]$, it takes every value between $f(a)$ and $f(b)$.]

#v(0.6em)

// ── env-colors ──────────────────────────────────────────────────────────────
#beautiframe-setup(style: "boxed", header-layout: "label-first", label-abbrev: false)

*`env-colors: false` — one accent hue everywhere (default):*
#beautiframe-setup(env-colors: false)
#beautiframe-reset()
#theorem(number: none)[Every frame uses `accent-color`.]
#example(number: none)[Including this one.]

*`env-colors: true` with `label-color: "base"` — each env paints with its own colour:*
#beautiframe-setup(env-colors: true, label-color: "base")
#beautiframe-reset()
#theorem(number: none)[Red, from `theorem-color`.]
#example(number: none)[Green, from `example-color`.]

#v(0.6em)

// ── Perceptual tints ────────────────────────────────────────────────────────
// A yellow and a navy make the difference plain: a fixed lightening washes the
// yellow out completely while the navy still reads.
#beautiframe-setup(
  style: "colorful", label-color: auto,
  default-variant: "accent",       // filled boxes, so the tint is what varies
  theorem-color: rgb("#1a3d7c"),   // dark navy
  remark-color: rgb("#e8b500"),    // pale yellow
  example-color: rgb("#27ae60"),   // mid green
)

*`background-tint: 92%` — one fixed lightening: the yellow washes out:*
#beautiframe-setup(background-tint: 92%)
#beautiframe-reset()
#theorem(number: none)[Navy tint.]
#remark(number: none)[Yellow tint.]
#example(number: none)[Green tint.]

*`background-tint: auto` — perceptual: all three tints read with equal strength:*
#beautiframe-setup(background-tint: auto)
#beautiframe-reset()
#theorem(number: none)[Navy tint.]
#remark(number: none)[Yellow tint.]
#example(number: none)[Green tint.]
