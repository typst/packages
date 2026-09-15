// ===========================================================================
//  manual-covers.typ — the covers & meters chapter of the faboxyst manual.
//  Included by manual.typ; helpers are redefined here as in every chapter.
// ===========================================================================

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


= Book covers & meters <covers>

Two late additions to the family: a full-page #cmd[book-cover] in three
styles ported from the TikZ originals, and #cmd[meter], a tiny inline
instrument — a speedometer, a thermometer, a phone battery, signal bars —
that reads an exercise's difficulty at a glance.

== The full-page cover: `book-cover`

#fn("book-cover", `book-cover(title: none, subtitle: none, author: none,
  series: none, level: none, year: none, publisher: none, place-line: none,
  style: "guilloche", colour: auto, accent: auto, direction: auto)`)

A cover paints the WHOLE page: it reads the paper size and the margins
from the context and bleeds to the paper edge, so drop it on a fresh page
(#cmd[pagebreak] first if the page carries text). Eight styles:

- #cmd[guilloche] — the royal navy cover: a lace of cubic sweeps over a
  diagonal grid — the #raw("lace") parameter swaps it for an
  #raw("engine")-turned barleycorn, a woven #raw("braid") or interfering
  #raw("moire") rings (see the #cmd[lace] chapter) — plus a radial wash, a
  silver strip along the leading edge, the series line and title block
  at the leading corner, a rosette seal (#raw("year")) at the trailing
  one, and the publisher's footer under a rule;
- #cmd[wedges] — the Boussaada cover: a checker ground, six big paper
  wedges in #raw("colour") / #raw("accent") / white with soft shadows,
  and white rounded cards for the title, the author, the level and the
  year, each with its icon;
- #cmd[medallion] — the schoolyard cover: a cream medallion ringed in
  orange on a brown ground, chalk doodles and a corner seal (#raw("badge"),
  #raw("badge-label")) around it, the title and a notched ribbon inside,
  a gold pedestal carrying a drawn atelier — pencil, ruler, compass,
  protractor, cylinder — and an author band with its π pastille over a
  footer line (#raw("place-line")) and an italic #raw("note");
- #cmd[compass] — the indigo study cover: diagonal streaks of light, a
  magenta header card hung from the top on the leading side (#raw("series")
  and #raw("note")), a three-line year badge at the trailing corner
  (#raw("badge-label"), #raw("badge"), #raw("badge-note")), the centred
  title under a #raw("lead-in"), an inset graph with axes, a dashed
  asymptote, two branches and its #raw("formula"), and a great metal
  compass standing on its magenta ellipse beside the author block; the
  footer band carries #raw("publisher") and #raw("topics");
- #cmd[openbook] — the study cover: a dark band (#raw("series"), title,
  #raw("subtitle") in the accent, #raw("lead-in")) over an accent rule and
  a pale ground; an open book laid in perspective — foreshortened,
  skewed and rotated on its cover, with its page bulk at the fore-edges —
  two graphed pages (#raw("page-a") /
  #raw("page-b") headers, tangent and asymptote graphs), a gutter shadow,
  a bookmark, the #raw("formula") panel under it, outline rings bleeding
  off two corners, a trailing stripe, and a footer band with a dash,
  #raw("author") and #raw("place-line");
- #cmd[sunburst] — the revision cover: radial rays on a green field, a
  gold motto (#raw("note")) under #raw("series"), a yellow band with
  #raw("level") and #raw("lead-in"), a bulleted list from #raw("topics")
  (array or single content), #raw("title") / #raw("subtitle") in white, an
  open book (#raw("page-a") / #raw("page-b") headers, gridded asymptote
  graph with #raw("formula") caption, tangent graph with its tangent-line
  formula) ringed by a protractor, a set square and a blue compass, and a
  yellow footer band with #raw("author") and #raw("place-line");
- #cmd[dice] — the probability plate: double frame and gem motifs on a
  dark ground, a heading stack (#raw("series"), #raw("note") between rules,
  #raw("title"), #raw("subtitle"), #raw("author")), a teal rosette holding
  #raw("topics") between flanking rules, then a white card whose trailing
  corner is cut by a white swoosh carrying three 3D dice; the card holds
  #raw("page-a") and #raw("formula") and #raw("lead-in"), two columns —
  #raw("page-b") over a uniform bar chart, #raw("badge-label") over
  #raw("badge") — and a cream arched footer with #raw("publisher");
- #cmd[scatter] — the scattered-dice plate: a night-teal gradient with
  six faint rosettes and star dust under a thin gold rule ticked at its
  four corners; #raw("series"), #raw("title"), #raw("subtitle") and
  #raw("author") stack over a diamond divider, #raw("formula") sits under
  a short rule between two side formulas with #raw("note"), thirteen 3D
  dice in ivory, gold and aqua tumble over the lower half, and a dark
  footer band carries #raw("publisher");
- #cmd[spine] — a coloured spine band on the leading edge with two rings
  and a course of rungs, an accent stripe, and a double-ruled panel
  carrying the centred title stack: series, level, rules, title, the
  subtitle as a pill, then the author under a rule.

Every anchored element follows the text direction: under #raw("rtl") the
spine band, the title block, the seal and the footer all move to the
mirrored edge. #raw("colour") and #raw("accent") repaint a style; left at
#raw("auto") each style keeps its own palette. The covers fill a page, so
they are shown in #cmd[examples/covers.typ] rather than demoed here.

== The difficulty meter: `meter`

#fn("meter", `meter(value, max: 5, style: "gauge", label: auto,
  colour: auto, track: auto, size: 1.5cm, digits: true, direction: auto)`,
  ret: [an inline box])

A small instrument, a few centimetres wide, that sits beside an exercise
statement or in a table cell. #raw("value") reads against #raw("max");
#raw("style") picks the instrument:

- #cmd[gauge] — a speedometer: three coloured zones (green, amber, red)
  as annular sectors, a tick per step, a needle and a hub;
- #cmd[thermo] — a thermometer: mercury in a glass tube over a bulb,
  ticks on the trailing side;
- #cmd[battery] — a phone battery: a shell with its cap, the charge
  growing from the cap; empty is the alarm here, so the ramp runs the
  other way;
- #cmd[bars] — signal bars: one column per step of #raw("max"), lit up
  to #raw("value").

With #raw("colour: auto") the reading takes the ramp — green to 40 %,
amber to 70 %, red above — and #raw("label: auto") prints
#raw("value/max") under the instrument (#raw("digits: none") hides it).
Under RTL the asymmetric parts mirror: the battery cap, the thermometer
ticks, the order of the bars.

#demo(`#meter(2) #meter(3, style: "thermo") #meter(4, style: "battery")
#meter(5, style: "bars")`, [
  #meter(2) #h(0.4cm) #meter(3, style: "thermo") #h(0.4cm)
  #meter(4, style: "battery") #h(0.4cm) #meter(5, style: "bars")
])

#fn("difficulty", `difficulty(value, max: 5, style: "gauge", label: auto, …)`,
  ret: [a meter labelled “diff. value/max”])

The pre-set for exercise sheets: a #cmd[meter] whose label reads
#raw("diff. value/max"). See #cmd[examples/meters.typ] for the instruments
beside exercise statements, in both directions.
