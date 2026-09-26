// Ornate frames and the flag box — included by manual.typ after
// manual-gallery.typ.
#import "@preview/faboxyst:0.2.0": *

#let ACCENT = rgb("#1772B2")
#let ACCENT-SOFT = rgb("#E8F2FA")
#let INK = rgb("#1A1A1A")
#let MUTED = rgb("#5A6570")
#let CODEBG = rgb("#F4F6F8")
#let RULE = rgb("#D0D7DE")
#let SANS = ("DejaVu Sans",)
#let MONO = ("DejaVu Sans Mono",)

#let cmd(name) = text(font: MONO, weight: "bold", fill: ACCENT, name)

#let fn(name, sig, ret: [content]) = block(
  width: 100%, breakable: false, above: 0.85em, below: 0.45em,
  {
    block(width: 100%, fill: ACCENT-SOFT, inset: (x: 0.55em, y: 0.42em),
      stroke: (left: 2.4pt + ACCENT),
      {
        text(font: MONO, size: 0.95em, weight: "bold", fill: ACCENT, name)
        h(0.45em)
        text(size: 0.78em, fill: MUTED, font: SANS)[→ #ret]
        v(0.22em)
        text(font: MONO, size: 0.72em, fill: rgb("#334"),
          if type(sig) == str { raw(sig) } else { sig })
      })
  },
)

#let params(..rows) = {
  let items = rows.pos()
  block(width: 100%, above: 0.35em, below: 0.55em,
    table(
      columns: (auto, auto, 1fr),
      inset: (x: 0.42em, y: 0.32em),
      stroke: (x, y) => (bottom: 0.4pt + RULE),
      fill: (x, y) => if y == 0 { CODEBG } else { none },
      table.header(
        text(font: SANS, size: 0.78em, weight: "bold")[Parameter],
        text(font: SANS, size: 0.78em, weight: "bold")[Type / default],
        text(font: SANS, size: 0.78em, weight: "bold")[Meaning],
      ),
      ..items.map(((n, t, d)) => (
        text(font: MONO, size: 0.74em, n),
        text(font: MONO, size: 0.68em, fill: MUTED, t),
        text(size: 0.82em, d),
      )).flatten(),
    ))
}

#let demo(src, body) = block(
  breakable: false, width: 100%, above: 0.4em, below: 0.65em,
  grid(columns: (1fr, 1fr), column-gutter: 0.45cm, align: top,
    box(width: 100%, fill: CODEBG, inset: 0.5em, radius: 2pt,
      stroke: 0.45pt + RULE,
      text(font: MONO, size: 6.9pt,
        raw(if type(src) == str { src } else { src.text }, lang: "typ"))),
    box(width: 100%, inset: (x: 0.1em, y: 0.05em), body),
  ),
)

/// Code above, result below — for the wide plates.
#let wide(src, body) = block(
  breakable: false, width: 100%, above: 0.4em, below: 0.8em, {
    box(width: 100%, fill: CODEBG, inset: 0.5em, radius: 2pt,
      stroke: 0.45pt + RULE,
      text(font: MONO, size: 6.9pt,
        raw(if type(src) == str { src } else { src.text }, lang: "typ")))
    v(0.3em)
    body
  })

#let note-line(body) = block(width: 100%, above: 0.35em, below: 0.45em,
  fill: rgb("#FFF8E6"), inset: 0.5em, radius: 2pt,
  stroke: (left: 2.2pt + rgb("#E0A100")),
  text(size: 0.88em, body))

#let cap(t) = block(below: 0.25em, above: 0.15em,
  text(size: 7.6pt, style: "italic", fill: MUTED, font: SANS, t))

#let sample = [
  Consider the complex numbers $z_1 = 2 + i$ and $z_2 = 1 - 2i$.
  + Write $z_1 + z_2$, $z_1 z_2$ and $z_1 / z_2$ in algebraic form.
  + Compute $overline(z_1)$, $|z_1|$ and $|z_2|$.
]

// ===========================================================================
= Ornate frames <ornate>

The plates of a Maghrebi textbook: a cream page inside a pair of hairlines,
a rosette every few centimetres down the sides, a scroll in each corner
and a dark sash carrying the title. #cmd[ornatebox] draws all of it from
_motifs_ — small vector drawings that repeat along the contour — so a frame
recolours from three colours, scales to any size and ships no image
assets.

Five presets cover the reference plates; every knob of #cmd[ornatebox] is
still open on each of them.

#wide(`#khatambox(title: [Algebraic computation and conjugate],
  badge: [1], badge-label: [Exercise])[…]`,
  khatambox(title: [Algebraic computation and conjugate],
    badge: [1], badge-label: [Exercise], sample))

#wide(`#zellijbox(title: [Exercise 2 — Exponential form and roots])[…]`,
  zellijbox(title: [Exercise 2 — Exponential form and roots], sample))

#wide(`#arabesquebox(title: [Exercise 1 — Algebraic computation])[…]`,
  arabesquebox(title: [Exercise 1 — Algebraic computation], sample))

#wide(`#mihrabbox(title: [Exercise 1 — Algebraic computation])[…]`,
  mihrabbox(title: [Exercise 1 — Algebraic computation], sample))

#wide(`#mosaicbox[…]`,
  mosaicbox(align(center)[#text(size: 1.4em, weight: "bold")[Complex numbers]
    #v(-0.3em) #text(fill: luma(90))[Chapter 4]]))

== How a frame is built

Layers, back to front: shadow · paper · rules · edge strips · edge motifs
· centre pieces · corners · title band · flank and end motifs · badge ·
body. Everything is positioned against the _rule band_ — the stack of
concentric hairlines — so a thicker `rules` setting moves the motifs with
it.

#fn("ornatebox", "ornatebox(body, title: none, colour, gold, paper, palette: (:), fill: auto, rules, rule-gap, radius, outset, edge, edge-sides, edge-size, edge-gap, edge-count, edge-shift, edge-mask, edge-band, edge-band-fill, edge-band-stroke, edge-alternate, edge-pack, edge-fit, edge-clear, edge-turn, corner, corner-size, corner-shift, centre, centre-size, centre-mask, title-style, title-colour, title-size, title-weight, title-align, title-inset, title-gap, title-rule, sash-fill, sash-stroke, sash-line, sash-gap, sash-inset, caps, cap-len, tile, pennant-caps, pennant-width, pennant-stroke, badge, badge-label, badge-size, badge-star, badge-shift, end-motif, end-motif-size, flank, flank-size, inset, width, height, shadow, direction)")

#params(
  ("colour / gold / paper", "colour", [the three colours every motif draws from: the dark ground, the metallic accent, the page]),
  ("palette", "dict (:)", [extra palette keys — `tile`, `accent`, `light` — or overrides]),
  ("rules", "array", [concentric hairlines, outermost first: `((0.9pt, "ink"), (0.4pt, "gold"))`. A paint is a colour or a palette key]),
  ("rule-gap / radius", "length", [paper between two rules; radius of the outer rule]),
  ("edge", "motif \"rosette\"", [what repeats along the sides — a name, a motif dictionary, a function `(size, palette) => content`, or content]),
  ("edge-sides", "\"all\" | array", [`("start", "end")`, `("bottom",)` … logical names follow the text direction]),
  ("edge-size / edge-gap", "length", [motif size; the minimum space between two]),
  ("edge-count", "auto | int", [force the number per side]),
  ("edge-shift", "length 0cm", [push the run inward from the rule band; negative pushes outward]),
  ("edge-mask", "auto | bool", [hide the rules under each motif]),
  ("edge-band", "none | length", [a filled strip behind the run, as on the khatam plate]),
  ("edge-alternate", "bool | motif", [`true` mirrors every second motif; a motif takes its place]),
  ("edge-pack / edge-fit", "bool", [butt the motifs together; and resize them so a whole number closes the run]),
  ("edge-turn", "bool true", [rotate the motif on the top and bottom edges so it keeps facing outward]),
  ("corner", "motif | dict", [`"scroll"` for all four, `(top: .., bottom: ..)`, `(bottom-end: ..)`, or `(tl: .., tr: .., bl: .., br: ..)`. Motifs are drawn for the top-left and mirrored]),
  ("corner-size / corner-shift", "length / (dx, dy)", [size; pushed inward]),
  ("centre", "motif | dict", [a piece at the middle of a side: `(bottom: "flourish")`]),
  ("title-style", "\"sash\" | \"tiles\" | none", [a dark band with shaped ends, or a course of tiles with a paper pennant]),
  ("caps / cap-len", "(start, end)", [the sash ends: `flat`, `point`, `notch`, `arch`, `round`, `ogee`, `swoosh`, `step`, `bevel`]),
  ("sash-inset / sash-gap", "(start, end) / length", [how far the band stops short of the rules; paper above it]),
  ("sash-line", "none | length", [a gold hairline inside the band, this far from its foot]),
  ("badge / badge-label", "content", [a khatam medallion riding the leading end: the number, and the small word above it]),
  ("badge-shift", "(fx, fy)", [its centre, as fractions of its size, from the band's leading end]),
  ("end-motif / flank", "motif", [a piece at each cap tip; a piece between each cap and the side rule]),
  ("tile / pennant-*", "—", [the motif of a `"tiles"` band; the pennant's caps, width and stroke]),
  ("width / height", "ratio | length", [the plate's width; a minimum height (page frames)]),
  ("direction", "auto | ltr | rtl", [auto follows `text.dir`]),
)

== Motifs

A motif is a dictionary `(aspect: (w, h), draw: (size, palette) => content)`
whose `draw` returns a box of `size × aspect`. The built-in ones are listed
in #cmd[motifs]; #cmd[ornament] draws one on its own.

#let pal = ornament-palette
#block(width: 100%, inset: 0.4em, fill: rgb("#FCF9F2"), radius: 3pt, stroke: 0.4pt + RULE,
  grid(columns: 7, column-gutter: 0.3em, row-gutter: 0.5em, align: center + bottom,
    ..motifs.pairs().map(((k, m)) => stack(dir: ttb, spacing: 0.3em,
      box(height: 1.1cm, align(horizon, (m.draw)(0.8cm, pal))),
      text(font: MONO, size: 6.4pt, k)))))

#v(0.4em)
Any glyph of any font is a motif too — that is how the ornament faces
(Fleurons, Dingbats, _Noto Sans Symbols 2_ …) come in — and so is any
content.

#demo(`#ornatebox(
  title: [From a font],
  edge: glyph-motif("❦"),
  edge-sides: "all",
  edge-turn: false,
  corner: glyph-motif("✤",
    fill: p => p.gold),
  centre: none,
  edge-size: 0.4cm,
  caps: ("swoosh", "swoosh"),
)[…]`,
  ornatebox(title: [From a font], edge: glyph-motif("❦"), edge-sides: "all",
    edge-turn: false, corner: glyph-motif("✤", fill: p => p.gold),
    centre: none, edge-size: 0.4cm, caps: ("swoosh", "swoosh"),
    inset: (x: 0.4cm, y: 0.3cm))[#lorem(14)])

#demo(`#ornatebox(
  title: none,
  edge: "merlon",
  edge-sides: ("top",),
  edge-turn: false,
  edge-shift: -0.2cm,
  edge-gap: 0.15cm,
  edge-pack: true,
  edge-mask: false,
  corner: "bracket",
  centre: (bottom: "flourish"),
  colour: rgb("#7A1F2B"),
)[…]`,
  ornatebox(title: none, edge: "merlon", edge-sides: ("top",), edge-turn: false,
    edge-shift: -0.2cm, edge-gap: 0.15cm, edge-pack: true, edge-mask: false,
    corner: "bracket", centre: (bottom: "flourish"), colour: rgb("#7A1F2B"),
    inset: (x: 0.4cm, y: 0.3cm))[#lorem(14)])

#demo(`// your own motif
#let dot = (
  aspect: (1, 1),
  draw: (s, pal) => box(
    width: s, height: s,
    circle(radius: s / 2,
      fill: pal.gold,
      stroke: 0.5pt + pal.ink)))
#ornatebox(
  title: [Custom],
  edge: dot, edge-size: 0.2cm,
  edge-gap: 0.25cm,
  edge-sides: "all",
  corner: tint("wedge", ink: red),
  centre: none,
  rules: ((1.4pt, "ink"),),
  radius: 0.25cm,
)[…]`,
  {
    let dot = (aspect: (1, 1), draw: (s, pal) => box(width: s, height: s,
      circle(radius: s / 2, fill: pal.gold, stroke: 0.5pt + pal.ink)))
    ornatebox(title: [Custom], edge: dot, edge-size: 0.2cm, edge-gap: 0.25cm,
      edge-sides: "all", corner: tint("wedge", ink: red), centre: none,
      rules: ((1.4pt, "ink"),), radius: 0.25cm,
      inset: (x: 0.4cm, y: 0.3cm))[#lorem(14)]
  })

#fn("ornament", "ornament(motif, size: 0.5cm, palette: (:), baseline: 20%)")
#fn("glyph-motif", "glyph-motif(ch, font: auto, fill: auto, weight: \"regular\", aspect: (1, 1))", ret: [motif])
#fn("content-motif", "content-motif(body, aspect: (1, 1))", ret: [motif])
#fn("tint / turned", "tint(motif, ..palette-keys) · turned(motif, angle)", ret: [motif])

Inline: a #ornament("rosette", size: 0.35cm) rosette, a
#ornament("star8", size: 0.35cm) star, a #ornament("lozenge", size: 0.3cm)
lozenge — #cmd[ornament] is a `box` with a baseline, so it sits in a line
of text and makes a list marker or a divider:

#align(center, {
  ornament("finial", size: 0.3cm)
  h(0.3em)
  ornament("rosette", size: 0.45cm, baseline: 30%)
  h(0.3em)
  scale(x: -100%, ornament("finial", size: 0.3cm))
})

== The sash and the badge

The title band is one closed `curve`; each end is a _cap_. The nine caps,
as `(start, end)` pairs — the default is an `ogee` S-curve at both ends:

#let caps-demo = ("flat", "point", "notch", "arch", "round", "ogee", "swoosh", "step", "bevel")
#grid(columns: 3, column-gutter: 0.4cm, row-gutter: 0.3cm,
  ..caps-demo.map(c => {
    box(width: 100%, height: 0.7cm, {
      sash-shape(0.2cm, 4.6cm, 0.12cm, 0.58cm, caps: (c, c), cap-len: (0.3cm, 0.3cm),
        fill: rgb("#1F3A68"))
      place(top + left, dx: 0.2cm, dy: 0.12cm, box(width: 4.4cm, height: 0.46cm,
        align(center + horizon, text(fill: rgb("#E8D9B0"), size: 7pt, font: MONO, c))))
    })
  }))

#fn("sash-shape", "sash-shape(x0, x1, y0, y1, caps: (\"flat\", \"flat\"), cap-len: (0pt, 0pt), ..style)")
#fn("khatam-badge", "khatam-badge(number, label: none, size: 1.4cm, ink, gold, paper, number-colour: auto, label-colour: auto, star: true, label-font: auto)")

#demo(`#ornatebox(
  title: [Roots of unity],
  badge: [3], badge-label: [Ex.],
  caps: ("flat", "arch"),
  sash-fill: rgb("#7A1F2B"),
  sash-inset: (0cm, 0.8cm),
  edge: none, corner: (bottom: "wedge"),
  centre: none,
  colour: rgb("#7A1F2B"),
  gold: rgb("#D8B15A"),
)[…]`,
  ornatebox(title: [Roots of unity], badge: [3], badge-label: [Ex.],
    caps: ("flat", "arch"), sash-fill: rgb("#7A1F2B"), sash-inset: (0cm, 0.8cm),
    edge: none, corner: (bottom: "wedge"), centre: none,
    colour: rgb("#7A1F2B"), gold: rgb("#D8B15A"),
    inset: (x: 0.4cm, y: 0.3cm))[#lorem(12)])

== Page frames

#fn("ornate-pages", "ornate-pages(doc, preset: ornatebox, margin: 1.2cm, inner: auto, ..args)")

A `show` rule that draws the frame on every page's background and keeps
the text inside it:

```typ
#show: ornate-pages.with(preset: arabesquebox, margin: 1cm)
```

The frame is drawn once per page at `page.width − 2·margin` by
`page.height − 2·margin`; `inner` is the paper between the frame and the
text.

== Right-to-left

Everything logical flips under `dir: rtl`: the badge and the flat cap go
to the right, the tiles' pennant opens towards the left, `(bottom-end:
"wedge")` lands in the bottom-left corner, and the title is set with the
surrounding direction.

#wide(`#set text(lang: "ar", dir: rtl)
#khatambox(title: [الحساب الجبري والمرافق], badge: [1], badge-label: [تمرين])[…]`,
  {
    set text(lang: "ar", dir: rtl, font: ("Amiri", "Noto Naskh Arabic", "DejaVu Serif"), size: 11pt)
    khatambox(title: [الحساب الجبري والمرافق], badge: [1], badge-label: [تمرين])[
      نعتبر العددين المركّبين $z_1 = 2 + i$ و $z_2 = 1 - 2i$.
      + اكتب الأعداد $z_1 + z_2$، $z_1 z_2$ و $z_1 / z_2$ على الشكل الجبري.
      + احسب $overline(z_1)$، $overline(z_2)$، $|z_1|$ و $|z_2|$.
    ]
  })

#note-line[No fonts are bundled. The plates above use whatever Arabic face
the document sets; the reference textbook pairs a Kufi display face for
titles with a Naskh for the body.]

// ===========================================================================
= The flag box <flagbox>

A box whose title hangs from a rod, after _tcolorbox_'s `flag` style: the
banner is wider at the rod than at its foot, painted with a three-stop
gradient, and straddles the top rule. The Typst port keeps the geometry
and adds the furniture a flag has in real life.

#fn("flagbox", "flagbox(body, title: none, colour, fill: auto, ribbon: auto, ribbon-mid: auto, title-colour: white, title-weight, title-size, title-inset, flag-align: start, shift: 1cm, spread: 0.2cm, overlap: 0.16cm, overhang: 0.05cm, tail: \"drape\", notch: 0.22cm, rod: 0.1cm, rod-colour: auto, finials: true, badge: none, badge-colour: auto, end-motif: none, end-motif-size: 0.5cm, gloss: true, stitch: false, shadow: true, radius, flag-radius, stroke: 0.4mm, inset, width: 100%, breakable: true, direction: auto)")

#params(
  ("colour", "colour", [the frame; the wash and the banner derive from it]),
  ("ribbon / ribbon-mid", "colour auto", [the banner's ends and middle]),
  ("flag-align", "start | center | end", [where the flag hangs — logical, so it follows the text direction]),
  ("shift", "length 1cm", [distance from the frame corner to the flag]),
  ("spread", "length", [how much wider the banner is at the rod than at its foot]),
  ("overlap / overhang", "length", [how far the foot reaches into the box; how far the rod stands above the rule]),
  ("tail", "\"drape\" | \"point\" | \"swallow\"", [the shape of the foot; `notch` its depth]),
  ("rod / finials", "length / bool", [the rod and the beads at its ends; `rod: none` removes it]),
  ("badge", "content", [a number in a disc astride the rod's leading end]),
  ("end-motif", "motif", [an ornament hanging from the rod's trailing end — `"finial"`, `"rosette"` …]),
  ("gloss / stitch / shadow", "bool", [the light line under the rod; a dashed hem; a soft shadow under the banner]),
  ("breakable", "bool true", [the body block may break across pages]),
)

#wide(`#flagbox(title: [First box])[…]
#flagbox(title: [Second box: with a longer title], colour: rgb("#a11d1d"),
  tail: "swallow", badge: [2])[…]`,
  {
    flagbox(title: [First box])[#lorem(30)]
    v(0.45cm)
    flagbox(title: [Second box: with a longer title], colour: rgb("#a11d1d"),
      tail: "swallow", badge: [2])[#lorem(22)]
  })

#wide(`#flagbox(title: [Centred, pointed foot], colour: rgb("#1E6B5A"), tail: "point",
  flag-align: center, stitch: true, end-motif: "finial")[…]
#flagbox(title: [At the end], colour: rgb("#6B3FA0"), flag-align: end, badge: [7],
  end-motif: "rosette")[…]`,
  {
    flagbox(title: [Centred, pointed foot], colour: rgb("#1E6B5A"), tail: "point",
      flag-align: center, stitch: true, end-motif: "finial")[#lorem(22)]
    v(0.45cm)
    flagbox(title: [At the end], colour: rgb("#6B3FA0"), flag-align: end, badge: [7],
      end-motif: "rosette")[#lorem(18)]
  })

Under `dir: rtl` the flag, the badge and the end motif all move to the
right; the gradient still runs from the rod's leading end.

#demo(`#set text(lang: "ar", dir: rtl)
#flagbox(
  title: [الحساب الجبري],
  badge: [1],
  colour: rgb("#1F3A68"),
  end-motif: "finial",
)[…]`,
  {
    set text(lang: "ar", dir: rtl, font: ("Amiri", "Noto Naskh Arabic", "DejaVu Serif"), size: 11pt)
    flagbox(title: [الحساب الجبري], badge: [1], colour: rgb("#1F3A68"), end-motif: "finial")[
      نعتبر العددين المركّبين $z_1 = 2 + i$ و $z_2 = 1 - 2i$.
    ]
  })
