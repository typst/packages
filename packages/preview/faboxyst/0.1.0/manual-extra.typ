// Extra chapters included by manual.typ.
// `#include` evaluates this file in its own scope, so the package and
// the doc helpers are imported / redefined here.

#import "/lib.typ": *

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
        text(font: MONO, size: 0.68em, fill: MUTED,
          if type(t) == str { t } else { t }),
        text(size: 0.82em, d),
      )).flatten(),
    ))
}

#let demo(src, body) = block(
  breakable: false, width: 100%, above: 0.4em, below: 0.65em,
  grid(columns: (1fr, 1fr), column-gutter: 0.45cm, align: top,
    box(width: 100%, fill: CODEBG, inset: 0.5em, radius: 2pt,
      stroke: 0.45pt + RULE,
      text(font: MONO, size: 6.9pt, raw(src, lang: "typ"))),
    box(width: 100%, inset: (x: 0.1em, y: 0.05em), body),
  ),
)

#let note-line(body) = block(width: 100%, above: 0.35em, below: 0.45em,
  fill: rgb("#FFF8E6"), inset: 0.5em, radius: 2pt,
  stroke: (left: 2.2pt + rgb("#E0A100")),
  text(size: 0.88em, body))

#let cap(t) = block(below: 0.25em, above: 0.15em,
  text(size: 7.6pt, style: "italic", fill: MUTED, font: SANS, t))

#let trio(..cells) = grid(columns: (1fr,) * calc.min(3, cells.pos().len()),
  column-gutter: 0.28cm, row-gutter: 0.35cm, align: top, ..cells.pos())

// ===========================================================================
= Paper boxes <paper>

Torn kraft, punched filler paper, a spiral pad, a scalloped mat, graph
paper, a ruled index card, a deckle-edged tag and a lesson card. These
are the *paper stocks* of the package: each is a self-contained box
with its own edge and its own fastening.

#note-line[Tape is *not* a boolean. Pass `none`, a dictionary of
#cmd[sb-tape] arguments, or an array of those dictionaries. Punch
holes take `auto` or an integer — never `true`.]

== Washi tape: `sb-tape`

#fn("sb-tape", `sb-tape(w: 2.6, h: 0.78, angle: -8deg,
  kind: "dots", colour: auto, ink: auto, seed: 3)`)

A translucent strip. The long edges are slightly ragged; the ends are
cut square. `kind` is the pattern.

#params(
  ("kind", `plain | dots | gingham | stripe`, [the print; gingham is the cloth / “torchon” check]),
  ("w / h", "float cm  (2.6 / 0.78)", [size]),
  ("angle", "angle  (−8deg)", [how it sits]),
  ("colour / ink", "color | auto", [the wash, and the dots / stripes]),
)

#demo(`#sb-tape(kind: "plain")
#sb-tape(kind: "dots")
#sb-tape(kind: "gingham")
#sb-tape(kind: "stripe")`.text,
  {
    set text(size: 8pt)
    grid(columns: 2, gutter: 0.35cm, row-gutter: 0.45cm,
      [#cap[plain] #sb-tape(kind: "plain", w: 2.8, h: 0.72, angle: -6deg)],
      [#cap[dots] #sb-tape(kind: "dots", w: 2.8, h: 0.72, angle: 8deg)],
      [#cap[gingham — cloth / torchon]
        #sb-tape(kind: "gingham", w: 2.8, h: 0.72, angle: -10deg,
          colour: rgb("#DCCBB4"))],
      [#cap[stripe]
        #sb-tape(kind: "stripe", w: 2.8, h: 0.72, angle: 6deg,
          colour: rgb("#C9D4C4"))],
    )
  })

== Torn kraft: `torn-note`

#fn("torn-note", `torn-note(body, width: 12.0, tape: auto, tilt: 0deg, …)`)

Hand-torn kraft paper. The default tape is a polka-dot washi strip.

#params(
  ("width / pad", "float cm  (12.0 / 0.85)", [sheet width and inner pad]),
  ("tape", "auto | none | dict | array", [auto = one dots strip; none = bare]),
  ("amp / tilt / fill", "float / angle / auto", [tear roughness, rotation, stock colour]),
  ("grain / shadow", "bool", [fibre grain and drop shadow]),
  ("rough / roughness / hand", "auto | bool / float / none|str", [hand-drawn mode]),
)

#demo(`#torn-note(width: 7.2)[default dots tape]
#torn-note(width: 7.2, tape: none)[no tape]
#torn-note(width: 7.2,
  tape: (kind: "gingham",
    colour: rgb("#DCCBB4"),
    at: (0.8, -0.2)))[cloth tape]`.text,
  {
    torn-note(width: 7.4)[#align(center)[default dots tape]]
    v(0.35em)
    torn-note(width: 7.4, tape: none)[#align(center)[no tape]]
    v(0.35em)
    torn-note(width: 7.4,
      tape: (kind: "gingham", colour: rgb("#DCCBB4"), w: 2.2, h: 0.7,
        angle: -12deg, at: (0.8, -0.2)))[#align(center)[cloth tape]]
  })

== Punched sheet: `ruled-sheet`

#fn("ruled-sheet", `ruled-sheet(body, width: 9.0, holes: auto,
  hole-side: auto, rule: "lines", tape: none, …)`)

A page torn out of a ring binder: punch holes on the leading edge, ruling
behind the text, *only the top edge torn*. Four torn edges would read as
a scrap, not a page.

#params(
  ("holes", "auto | int", [auto = one every 1.05 cm; an int is the count]),
  ("hole-side", "auto | left | right", [auto follows the text direction]),
  ("rule / ruling / heart", `"lines"|"none" / float cm / bool`, [ruling and a rose divider]),
  ("tape", "none | dict", [a strip of #cmd[sb-tape]; see above]),
  ("clip", "bool  (false)", [reserved; the clip lives on grid-note / index-card]),
)

#demo(`#ruled-sheet(width: 7.2, holes: 4)[
  punched filler paper
]
#ruled-sheet(width: 7.2, holes: 3, heart: true,
  tape: (kind: "gingham",
    colour: rgb("#DCCBB4"),
    w: 2.1, h: 0.7, angle: 8deg,
    at: (2.0, -0.28)))[
  holes + cloth tape
]`.text,
  {
    ruled-sheet(width: 7.4, holes: 4)[
      #set text(size: 9pt)
      punched filler paper
    ]
    v(0.4em)
    ruled-sheet(width: 7.4, holes: 3, heart: true,
      tape: (kind: "gingham", colour: rgb("#DCCBB4"),
        w: 2.1, h: 0.7, angle: 8deg, at: (2.0, -0.28)))[
      #set text(size: 9pt)
      holes + cloth tape
    ]
  })

== Spiral pad: `notepad`

#fn("notepad", `notepad(body, width: 9.5, rings: auto,
  crumpled: false, side: auto, …)`)

A sheet *torn off* a spiral pad. The coil is one continuous wire, not a
row of rings: each turn comes up through a hole, wraps the edge and
dives back. #cmd[notebook-box] is the *card* with a title pill;
#cmd[notepad] is the *page* pulled off the pad.

#params(
  ("rings", "auto | int", [auto = one every 0.81 cm; an int is the count]),
  ("ring / ring-colour", "auto | float / auto | color", [oval size and ink]),
  ("side", "auto | left | right", [auto follows the text direction]),
  ("crumpled / creases / crease-ink", "bool / int / float", [facet crumple]),
  ("tilt", "angle  (0deg)", [the whole sheet]),
)

#demo(`#notepad(width: 7.2, rings: 5)[smooth]
#notepad(width: 7.2, rings: 5,
  crumpled: true)[crumpled]
#notepad(width: 7.2, rings: 3,
  side: right)[bound on the right]`.text,
  {
    notepad(width: 7.4, rings: 5)[
      #set text(size: 9pt)
      #align(center, strong[smooth])
      Torn from the coil. The edge along the binding is torn, not cut.
    ]
    v(0.4em)
    notepad(width: 7.4, rings: 5, crumpled: true)[
      #set text(size: 9pt)
      #align(center, strong[crumpled])
      Facets of light and shade, not drawn cracks.
    ]
    v(0.4em)
    notepad(width: 7.4, rings: 3, side: right)[
      #set text(size: 9pt)
      Bound on the right.
    ]
  })

== The other four stocks

#fn("stamp-card", `stamp-card(body, width: 8.0, pin: true, scallop: 0.20, …)`)
#fn("grid-note", `grid-note(body, width: 8.4, clip: false, tape: none, …)`)
#fn("index-card", `index-card(body, heading: none, note: none, clip: false, …)`)
#fn("deckle-tag", `deckle-tag(body, width: 5.6, tape: auto, …)`)

#params(
  ("stamp-card", "pin / holes / scallop / mat", [a card pinned to a punched mat]),
  ("grid-note", "grid / clip / tape", [graph paper; clip straddles the top]),
  ("index-card", "heading / note / rules", [ruled card + tinted footer]),
  ("deckle-tag", "amp / tape", [feathered handmade edge; default tape is gingham]),
)

#demo(`#stamp-card(width: 7.2)[pinned card]
#grid-note(width: 7.2, clip: true)[graph + clip]
#index-card(width: 7.2, heading: [Example],
  note: [a caution])[the body]
#deckle-tag(width: 6.2)[cloth tape]`.text,
  {
    stamp-card(width: 7.4)[#align(center)[pinned card]]
    v(0.4em)
    grid-note(width: 7.4, clip: true)[#align(center)[graph + clip]]
    v(0.4em)
    index-card(width: 7.4, heading: align(center)[Example],
      note: [A caution set on the tinted footer.])[
      #align(center)[the body]
    ]
    v(0.4em)
    deckle-tag(width: 6.4)[#align(center)[cloth tape]]
  })

== Lesson card: `lesson-card`

#fn("lesson-card", `lesson-card(body, title: none, width: 9.0,
  clip: true, rule: true, …)`)

A lined exercise-book card with a dovetail title banner pinned across
the top rule. Designed for Arabic; `align(start)` is applied throughout.

#params(
  ("title", "content | none", [the ribbon; none leaves the frame plain]),
  ("banner-w / banner-h / notch", "auto | float / float / float", [ribbon geometry]),
  ("ink / rule / ruling", "color / bool / float cm", [frame colour and lined paper]),
  ("clip / clip-at", "bool / float", [a paperclip on the top-left corner]),
)

#demo(`#lesson-card(width: 7.2, title: [Note],
  clip: false)[
  A lined card with a
  dovetail banner.
]`.text,
  lesson-card(width: 7.4, title: [Note], clip: false)[
    A lined card with a dovetail banner.
  ])

= Spiral binding and banners

== Full-page coil: `spiral-binding`

#fn("spiral-binding", `spiral-binding(side: auto, colour: …, gap: 1.5cm, …)`)

A page *background*, not a box. Use it as `set page(background: …)` or
through the helper #cmd[bound-page], which also reserves the margin.

#params(
  ("side", `auto | left | right | top | bottom`, [auto follows the text direction]),
  ("gap / scale / offset", "length / float / length", [pitch, size, first-loop shift]),
  ("gutter / gutter-width / gutter-colour", "bool / length / color", [the paper edge]),
  ("bead / colour / weight", "bool / color / length", [the wire]),
)

#demo(`#box(width: 100%, height: 3.2cm,
  clip: true,
  spiral-binding(side: "left",
    colour: rgb("#5AA"),
    gap: 1.05cm, scale: 0.85))`.text,
  box(width: 100%, height: 3.2cm, clip: true,
    stroke: 0.4pt + RULE,
    spiral-binding(side: "left", colour: rgb("#5AAAAA"),
      gap: 1.05cm, scale: 0.85)))

#fn("bound-page", `bound-page(body, side: auto, colour: …, margin: 2.6cm, …)`)

A show rule: `#show: bound-page.with(side: "top", colour: teal)`. Extra
named arguments go to #cmd[spiral-binding].

== Swallow-tail: `flag-ribbon`

#fn("flag-ribbon", `flag-ribbon(body, height: 0.74, tail: 1.17, notch: 0.38, …)`)

A pen-and-ink banner with a swallow-tail at each end and a hatched fold.

#params(
  ("height / width", "float cm / auto", [the band; auto = as wide as the words]),
  ("tail / notch / drop / deeper", "float × height", [tail geometry]),
  ("hatch / shade / fold", "int / bool / float", [the fold marks]),
  ("wobble / radius / shadow", "float / length / none|float", [hand, rounding, drop shadow]),
  ("colour / fill / tails", "color / none|color / bool", [ink, wash, hide the tails]),
)

#demo(`#flag-ribbon(height: 0.62)[Useful Patterns]
#flag-ribbon(height: 0.62, tail: 0.55,
  notch: 0)[short, no V]
#flag-ribbon(height: 0.62,
  colour: rgb("#1A5C9E"),
  fill: rgb("#EAF2FA"),
  shadow: 0.08)[filled + shadow]`.text,
  {
    align(center, flag-ribbon(height: 0.62)[Useful Patterns])
    v(0.3em)
    align(center, flag-ribbon(height: 0.62, tail: 0.55, notch: 0)[short, no V])
    v(0.3em)
    align(center, flag-ribbon(height: 0.62, colour: rgb("#1A5C9E"),
      fill: rgb("#EAF2FA"), shadow: 0.08)[filled + shadow])
  })

== Streaked masthead: `speed-bar`

#fn("speed-bar", `speed-bar(body, height: 2.4, colour: rgb("#552384"), …)`)

Nine stacked capsules whose ends break into streaks. Prefer a height
around `1.05cm`–`1.2cm` inside a column; the default `2.4` is for a
full-width banner.

#params(
  ("height / width", "float cm | length / auto", [the bar; auto = the words]),
  ("colour / text-colour / body-radius", "color / color / float cm", [paint and the solid block]),
  ("streaks / dots", "auto | array", [override the measured silhouette]),
  ("overlap / gap / radius", "float / float / auto|length", [how the capsules meet]),
  ("rough / roughness", "bool / float", [hand-drawn mode]),
)

#demo(`#speed-bar(height: 1.05cm)[SPEED]
#speed-bar(height: 1.05cm,
  colour: rgb("#B8123A"))[RED]
#speed-bar(height: 1.05cm, dots: ())[no dots]`.text,
  {
    align(center, speed-bar(height: 1.05cm)[SPEED])
    v(0.28em)
    align(center, speed-bar(height: 1.05cm, colour: rgb("#B8123A"))[RED])
    v(0.28em)
    align(center, speed-bar(height: 1.05cm, dots: ())[no dots])
  })

= Inline marks

#fn("mark", `mark(body, kind: "highlight", colour: auto, …)`)
#fn("felt", `felt(body, ink: "yellow", alpha: 45%, …)`)

#cmd[mark] is a hand-drawn emphasis on a run of words.
#cmd[felt] is a felt-tip highlighter (rounded nib, translucent ink).
#cmd[highlight] (from the semantic family) is a simpler swipe.

#params(
  ("kind", `highlight | underline | double | wave | circle | box | strike | scribble | bracket | jagged | fan`, [the mark shape]),
  ("felt.ink", `yellow | green | pink | blue | orange | violet`, [named felt inks]),
  ("felt.alpha / height", "ratio / float", [opacity and band height × x-height]),
)

#demo(`#mark[highlight]
#mark(kind: "wave", colour: blue)[wave]
#mark(kind: "jagged")[jagged]
#mark(kind: "fan")[fan]
#felt(ink: "green")[felt green]
#felt(ink: "pink")[felt pink]`.text,
  [ #mark[highlight]
    #h(0.3em) #mark(kind: "wave", colour: blue)[wave]
    #h(0.3em) #mark(kind: "jagged")[jagged]
    #h(0.3em) #mark(kind: "fan")[fan]
    #h(0.3em) #felt(ink: "green")[felt green]
    #h(0.3em) #felt(ink: "pink")[felt pink] ])

= Style catalogue <styles>

Each family from the original `styles/` folder, with the *options that
change the look* and a live result. Styles 17–18 were slide decks and
are not part of this boxes-only package. Style 14 (`ws-card`) was a
full worksheet card; the same punched / ring look is #cmd[ruled-sheet]
and #cmd[notebook-box].

#block(width: 100%,
  table(
    columns: (auto, auto, 1fr),
    inset: (x: 0.38em, y: 0.28em),
    stroke: (x, y) => (bottom: 0.35pt + RULE),
    fill: (x, y) => if y == 0 { ACCENT-SOFT } else if calc.odd(y) { CODEBG } else { none },
    table.header(
      text(font: SANS, size: 0.76em, weight: "bold")[Style],
      text(font: SANS, size: 0.76em, weight: "bold")[Key],
      text(font: SANS, size: 0.76em, weight: "bold")[What it is],
    ),
    ..(
      ("01", "tab: \"plaque\"", [heading slab sitting on the top rule]),
      ("02", "border: caution | wave | zigzag", [hazard tape, coil, or sawtooth]),
      ("03", "side-bar + frame-hidden", [azurios flat bar, no outline]),
      ("04", "tab: \"swoosh\"", [InDesign banner with an S-curve]),
      ("05", "tab: \"exercise\"", [badge + fading chevrons, open frame]),
      ("06", "tab: \"fold\"", [3-D ribbon folded at both ends]),
      ("07", "example-header", [pill + disc + arrow, not a box]),
      ("08", "tab: \"label\"", [two-tone tab + outside caption]),
      ("09", "sweep:", [open U-frame with a big rounded corner]),
      ("10", "post-it(pin:)", [pushpin / paperclip / tape]),
      ("11", "mark(kind:)", [jagged, fan, and the other inline marks]),
      ("12", "tab: \"spine\"", [upright LEARN-THIS bar]),
      ("13", "tab: ears | dots", [moulded headings]),
      ("15", "flag-ribbon", [swallow-tail ink banner]),
      ("16", "speed-bar", [streaked masthead]),
      ("19", "torn-note …", [six paper stocks + washi]),
      ("20", "notepad", [spiral pad, smooth or crumpled]),
      ("21", "lesson-card", [dovetail banner on lined paper]),
      ("22", "felt / lesson-table", [felt-tip + lavender table]),
      ("23", "numbox", [numbered question, auto or manual, LTR / RTL]),
      ("24–40", "see @plates", [icon, crest, ribbon, helix, swoosh, circuit, key, ring, punch, planner, file, stub, stack, callout, tape, chalk, marker, screw]),
    ).map(((n, k, d)) => (
      text(font: MONO, size: 0.72em, n),
      text(font: MONO, size: 0.66em, k),
      text(size: 0.8em, d),
    )).flatten(),
  ))

== Style 01 — `tab: "plaque"`

A flat heading centred on the top rule. `tab-offset` slides it;
`plaque-rule` outlines it; `plaque-sharp` picks the corners.

#trio(
  [#cap[`tab-offset: 0`]
    #fabox(title: [offset 0], tab: "plaque", tab-offset: 0,
      colour: rgb("#CCCCFF"), title-colour: black, back: white,
      weight: 1.4pt, radius: 0, sharp: ("all",), width: 100%)[flush]],
  [#cap[`tab-offset: 1.4`]
    #fabox(title: [offset 1.4], tab: "plaque", tab-offset: 1.4,
      colour: rgb("#CCCCFF"), title-colour: black, back: white,
      weight: 1.4pt, radius: 0, sharp: ("all",), width: 100%)[slid]],
  [#cap[`plaque-rule: true`]
    #fabox(title: [outlined], tab: "plaque", plaque-rule: true,
      colour: rgb("#CCCCFF"), title-colour: black, back: white,
      weight: 1.4pt, radius: 0.12, plaque-sharp: (),
      width: 100%)[rounded]],
)

== Style 02 — `border: "caution" | "wave" | "zigzag"`

Three decorated edges. `"caution"` is hazard tape (`tape-width`,
`tape-period`, `tape-colours`). `"wave"` and `"zigzag"` run along the
top and bottom rules.

#trio(
  [#cap[`border: "zigzag"`]
    #fabox(title: [zigzag], border: "zigzag", width: 100%)[sawtooth]],
  [#cap[`border: "wave"`]
    #fabox(title: [wave], border: "wave", width: 100%)[a coil]],
  [#cap[`border: "caution"`]
    #fabox(border: "caution", back: white, weight: 0pt, radius: 0,
      sharp: ("all",), width: 100%)[hazard tape]],
)

#trio(
  [#cap[`tape-width: 3pt`]
    #fabox(border: "caution", tape-width: 3pt, tape-period: 0.07,
      back: white, weight: 0pt, radius: 0, sharp: ("all",),
      width: 100%)[thin]],
  [#cap[`tape-period: 0.22`]
    #fabox(border: "caution", tape-period: 0.22,
      back: white, weight: 0pt, radius: 0, sharp: ("all",),
      width: 100%)[wide stripes]],
  [#cap[`tape-colours: red/white`]
    #fabox(border: "caution", tape-colours: (rgb("#D32F2F"), white),
      back: white, weight: 0pt, radius: 0, sharp: ("all",),
      width: 100%)[not yellow]],
)

== Style 03 — `side-bar`, `frame-hidden`, `title-rule-inset`

The outline is dropped; a thick bar on the leading edge and a short
underline under the title do the work.

#let ora = rgb("#FF8000")
#trio(
  [#cap[the azurios recipe]
    #fabox(title: [Definition], colour: ora, title-fill: ora,
      back: rgb("#FFE6CC"), frame-hidden: true, side-bar: 0.12,
      title-rule-inset: 0.4, radius: 0, sharp: ("all",),
      width: 100%)[no outline]],
  [#cap[`side-bar` only]
    #fabox(title: [Note], colour: rgb("#1E5CB3"), frame-hidden: true,
      side-bar: 0.18, radius: 0, width: 100%)[just the bar]],
  [#cap[`title-rule-inset: 0.8`]
    #fabox(title: [Short rule], colour: ora, frame-hidden: true,
      side-bar: 0.10, title-rule-inset: 0.8, radius: 0,
      width: 100%)[underline pulled in]],
)

== Style 04 — `tab: "swoosh"`

The bar swells around the words. `swoosh` is the curve length,
`swoosh-deep` how far it drops, `swoosh-side` which edge, `swoosh-align`
where the title sits.

#trio(
  [#cap[default, top]
    #fabox(title: [Title], tab: "swoosh", colour: rgb("#00A000"),
      back: white, width: 100%)[swells around the words]],
  [#cap[`swoosh-align: center`]
    #fabox(title: [centred], tab: "swoosh", swoosh-align: center,
      colour: rgb("#00A000"), back: white, width: 100%)[both ends taper]],
  [#cap[`swoosh-side: "left"`]
    #fabox(title: [SIDE], tab: "swoosh", swoosh-side: "left",
      colour: rgb("#00A000"), back: white, width: 100%)[down the edge]],
)

== Style 05 — `tab: "exercise"`

A slab, a boxed number, fading chevrons, and an open left + bottom
frame (`side-bar` + `bottom-rule` + `corner-tick`).

#let V = rgb("#663599")
#trio(
  [#cap[`chevrons: 0`]
    #fabox(title: [Ex.], tab: "exercise", badge: [1], chevrons: 0,
      colour: V, frame-hidden: true, back: white,
      side-bar: 0.05, bottom-rule: 0.05, corner-tick: 0.4,
      radius: 0, sharp: ("all",), width: 100%)[no marks]],
  [#cap[`chevrons: 4`]
    #fabox(title: [Ex.], tab: "exercise", badge: [1], chevrons: 4,
      colour: V, frame-hidden: true, back: white,
      side-bar: 0.05, bottom-rule: 0.05, corner-tick: 0.4,
      radius: 0, sharp: ("all",), width: 100%)[four marks]],
  [#cap[`badge: none`]
    #fabox(title: [Ex.], tab: "exercise", chevrons: 3,
      colour: V, frame-hidden: true, back: white,
      side-bar: 0.05, bottom-rule: 0.05, corner-tick: 0.4,
      radius: 0, sharp: ("all",), width: 100%)[no number]],
)

== Style 06 — `tab: "fold"`

A 3-D ribbon: `fold-out` is the overhang, `fold-colour` the two
triangles that sell the twist.

#let clair = rgb("#89BADD")
#let fonce = rgb("#1475BB")
#trio(
  [#cap[`fold-out: 0`]
    #fabox(title: [flush], tab: "fold", fold-out: 0,
      colour: black, title-fill: clair, title-colour: black,
      fold-colour: fonce, back: white, radius: 0, sharp: ("all",),
      width: 100%)[no overhang]],
  [#cap[default]
    #fabox(title: [Title], tab: "fold",
      colour: black, title-fill: clair, title-colour: black,
      fold-colour: fonce, back: white, radius: 0, sharp: ("all",),
      width: 100%)[Hello]],
  [#cap[`shadow: true`]
    #fabox(title: [lifted], tab: "fold", shadow: true,
      colour: black, title-fill: clair, title-colour: black,
      fold-colour: fonce, back: white, radius: 0, sharp: ("all",),
      width: 100%)[with relief]],
)

== Style 07 — `example-header`

A header, not a box. `number` must be *content* (`[1]`), not an integer.

#demo(`#example-header([Example], number: [1],
  tag: [SKILLS], note: [PROBLEM-SOLVING])
#example-header([Exemple], number: [3],
  colour: rgb("#1A5C9E"))`.text,
  {
    example-header([Example], number: [1],
      tag: [SKILLS], note: [PROBLEM-SOLVING])
    v(0.35em)
    example-header([Exemple], number: [3], colour: rgb("#1A5C9E"))
  })

== Style 08 — `tab: "label"`

Two-tone tab above the frame: a rounded word, a square number, a
caption set *outside* the tab.

#trio(
  [#cap[word + number + caption]
    #fabox(title: [EX.], tab: "label", label-number: [1],
      label-caption: [Sol.], colour: rgb("#00A550"),
      title-fill: rgb("#5B58FF"), back: white, width: 100%)[body]],
  [#cap[`label-square: true`]
    #fabox(title: [EX.], tab: "label", label-number: [2],
      label-square: true, colour: rgb("#00A550"),
      title-fill: rgb("#5B58FF"), back: white, width: 100%)[square]],
  [#cap[`label-round: true`]
    #fabox(title: [EX.], tab: "label", label-number: [3],
      label-round: true, colour: rgb("#00A550"),
      title-fill: rgb("#5B58FF"), back: white, width: 100%)[round end]],
)

== Style 09 — `sweep`

An open U-frame. Combinable with `tab: "label"`.

#trio(
  [#cap[`sweep: 1.2`]
    #fabox(title: [open], sweep: 1.2, colour: rgb("#1E5CB3"),
      width: 100%)[big corner]],
  [#cap[`sweep-ticks: 0`]
    #fabox(title: [plain], sweep: 1.0, sweep-ticks: 0,
      sweep-diamond: false, colour: rgb("#1E5CB3"),
      width: 100%)[no ornaments]],
  [#cap[with a label tab]
    #fabox(title: [EX.], tab: "label", label-number: [1],
      sweep: 1.0, colour: rgb("#1E5CB3"), width: 100%)[combined]],
)

== Style 10 — `post-it` fasteners

Each fastener meets the paper differently: a pin is *pressed in*, a
clip is *slipped over*, tape is *laid across*.

#params(
  ("pin", `none | pushpin | paperclip | tape`, [the fastener]),
  ("pins / pin-at / pin-shift", "int / auto|array / float", [how many, and where]),
  ("tape-at", `corner | top | bottom | left | right`, [which edge the strip follows]),
  ("clip-style", `gem | postit`, [the measured Gem clip, or the package wire]),
)

#trio(
  [#cap[`pin: "pushpin"`]
    #post-it(pin: "pushpin", size: 3.4cm, angle: -4deg)[pin]],
  [#cap[`pin: "paperclip"`]
    #post-it(pin: "paperclip", pin-colour: luma(40),
      size: 3.4cm, angle: 3deg)[clip]],
  [#cap[`pin: "tape", tape-at: "top"`]
    #post-it(pin: "tape", tape-at: "top", pin-colour: luma(160),
      size: 3.4cm, angle: -2deg)[tape]],
)

== Style 11 — `mark(kind:)`

#cmd[MARKS] is the full list. `"jagged"` and `"fan"` are the two
shapes that were added for this style.

#demo(`#mark(kind: "circle")[circle]
#mark(kind: "box")[box]
#mark(kind: "jagged")[jagged]
#mark(kind: "fan")[fan]
#mark(kind: "bracket")[bracket]
#mark(kind: "scribble", colour: red)[scribble]`.text,
  [ #mark(kind: "circle")[circle]
    #h(0.35em) #mark(kind: "box")[box]
    #h(0.35em) #mark(kind: "jagged")[jagged]
    #h(0.35em) #mark(kind: "fan")[fan]
    #h(0.35em) #mark(kind: "bracket")[bracket]
    #h(0.35em) #mark(kind: "scribble", colour: red)[scribble] ])

== Style 12 — `tab: "spine"`

An upright bar clamped on one edge. `spine-out: 0pt` puts it flush
(Gonzalo Medina’s version); the default hangs out by 0.85 of its depth.

#trio(
  [#cap[`spine-out: 0pt`]
    #fabox(tab: "spine", title: [LEARN], colour: rgb("#641648"),
      radius: 0, spine-out: 0pt, weight: 0.8pt, width: 100%)[flush]],
  [#cap[default overhang]
    #fabox(tab: "spine", title: [LEARN], colour: rgb("#641648"),
      radius: 0, weight: 0.8pt, width: 100%)[hangs out]],
  [#cap[`spine-side: end`]
    #fabox(tab: "spine", title: [NOTE], colour: rgb("#1A5C9E"),
      radius: 0, spine-side: end, spine-out: 0pt, weight: 0.8pt,
      width: 100%)[trailing edge]],
)

== Style 13 — `tab: "ears"` / `"dots"`

Headings moulded *out of* the frame, not laid on top of it.

#trio(
  [#cap[`tab: "ears"`]
    #fabox(tab: "ears", title: [Definition], colour: rgb("#7F0000"),
      back: rgb("#FDF0F0"), width: 100%)[flared scoops]],
  [#cap[`earsshade: false`]
    #fabox(tab: "ears", title: [Lemma], colour: rgb("#7F0000"),
      back: rgb("#FDF0F0"), earsshade: false, width: 100%)[no rim]],
  [#cap[`tab: "dots"`]
    #fabox(tab: "dots", title: [Note], colour: rgb("#2D6FB1"),
      width: 100%)[studs on the rule]],
)

== Style 15 — `flag-ribbon`

#trio(
  [#cap[default]
    #align(center, flag-ribbon(height: 0.58)[Remember])],
  [#cap[`tails: false`]
    #align(center, flag-ribbon(height: 0.58, tails: false,
      fill: rgb("#F6EFD8"))[no tails])],
  [#cap[`wobble: 1.1`]
    #align(center, flag-ribbon(height: 0.58, wobble: 1.1)[shaky])],
)

== Style 16 — `speed-bar`

#trio(
  [#cap[`height: 1.05cm`]
    #align(center, speed-bar(height: 1.05cm)[FAST])],
  [#cap[another colour]
    #align(center, speed-bar(height: 1.05cm, colour: rgb("#0F5C8C"))[BLUE])],
  [#cap[`dots: ()`]
    #align(center, speed-bar(height: 1.05cm, dots: ())[plain])],
)

== Style 19 — paper stocks + tape

The six sheets. Tape `kind` is `"plain"`, `"dots"`, `"gingham"`
(cloth / torchon) or `"stripe"`.

#grid(columns: (1fr, 1fr), gutter: 0.35cm, row-gutter: 0.4cm,
  [#cap[`torn-note` + dots]
    #torn-note(width: 7.4)[#align(center)[kraft]]],
  [#cap[`ruled-sheet` + gingham]
    #ruled-sheet(width: 7.4, holes: 3, heart: true,
      tape: (kind: "gingham", colour: rgb("#DCCBB4"),
        w: 2.0, h: 0.68, angle: 7deg, at: (1.8, -0.26)))[
      #set text(size: 8.5pt)
      punched + cloth tape
    ]],
  [#cap[`stamp-card`]
    #stamp-card(width: 7.4)[#align(center)[pinned]]],
  [#cap[`deckle-tag` (gingham by default)]
    #deckle-tag(width: 6.4)[#align(center)[feathered]]],
)

== Style 20 — `notepad` (spiral)

#trio(
  [#cap[`rings: 4`, smooth]
    #notepad(width: 5.0, rings: 4, pad: 0.45)[
      #set text(size: 8.5pt)
      torn off the coil
    ]],
  [#cap[`crumpled: true`]
    #notepad(width: 5.0, rings: 4, pad: 0.45, crumpled: true)[
      #set text(size: 8.5pt)
      crumpled sheet
    ]],
  [#cap[`side: right`]
    #notepad(width: 5.0, rings: 3, pad: 0.45, side: right)[
      #set text(size: 8.5pt)
      bound right
    ]],
)

Compare with the *card* that keeps its rings:

#demo(`#notebook-box(title: [Exercice], badge: [03],
  rings: 3)[$ a + b = 3 $]
#notebook-box-clean(title: [Clean],
  rings: 3)[roughness: 0]
#notebook-box(title: [No wire],
  rings: 0)[just the frames]`.text,
  {
    notebook-box(title: [Exercice], badge: [03], rings: 3, width: 100%)[$ a + b = 3 $]
    v(0.35em)
    notebook-box-clean(title: [Clean], rings: 3, width: 100%)[roughness: 0]
    v(0.35em)
    notebook-box(title: [No wire], rings: 0, width: 100%)[just the frames]
  })

== Style 21 — `lesson-card`

#trio(
  [#cap[default clip]
    #lesson-card(width: 5.2, title: [Note], clip: true)[
      #set text(size: 8.5pt)
      lined paper
    ]],
  [#cap[`rule: false`]
    #lesson-card(width: 5.2, title: [Plain], rule: false, clip: false)[
      #set text(size: 8.5pt)
      no ruling
    ]],
  [#cap[`ink:` blue]
    #lesson-card(width: 5.2, title: [Blue], ink: rgb("#2B5CA8"),
      clip: false)[
      #set text(size: 8.5pt)
      another colour
    ]],
)

== Style 22 — `felt` and `lesson-table`

#demo(`#felt(ink: "yellow")[yellow]
#felt(ink: "green")[green]
#felt(ink: "pink")[pink]
#felt(ink: "blue")[blue]
#felt(ink: "orange")[orange]
#felt(ink: "violet")[violet]`.text,
  [ #felt(ink: "yellow")[yellow]
    #h(0.25em) #felt(ink: "green")[green]
    #h(0.25em) #felt(ink: "pink")[pink]
    #h(0.25em) #felt(ink: "blue")[blue]
    #h(0.25em) #felt(ink: "orange")[orange]
    #h(0.25em) #felt(ink: "violet")[violet] ])

#fn("lesson-table", `lesson-table(..cells, columns: auto, header: true, …)`)

#demo(`#lesson-table(
  [Modal], [Use], [Example],
  [can], [ability], [I can swim.],
  [must], [obligation], [You must go.],
)`.text,
  lesson-table(
    [Modal], [Use], [Example],
    [can], [ability], [I can swim.],
    [must], [obligation], [You must go.],
  ))

== Style 23 — `numbox`

A simple textbook question: a filled number plaque on the *leading*
corner (left in LTR, right in RTL), a rounded frame, and an optional
answer block. The number increments by itself unless you set it.

#fn("numbox", `numbox(body, answer: auto, number: auto, numbering: "1.",
  colour: rgb("#1E54A8"), direction: auto, …)`)
#fn("numbox-reset", `numbox-reset(n: 1)`)

#params(
  ("number", "auto | int | none | content", [auto increments; an int shows that value and continues from there; none hides the plaque; content is printed as-is]),
  ("numbering", "str | function  (\"1.\")", [how an integer is printed — any Typst numbering]),
  ("answer", "none | content", [or pass it as a second positional: `#numbox[q][a]`]),
  ("answer-label", "auto | content", [auto = \"Ans.\" / \"ج:\"]),
  ("direction", "auto | ltr | rtl", [which edge the plaque sits on; auto follows the text]),
  ("colour / frame / fill", "color / auto / auto", [plaque, outline colour, wash]),
  ("weight / dash", "length / none | dashed | dotted | array", [outline thickness and dash pattern]),
  ("stroke", "auto | stroke", [full Typst stroke; overrides frame + weight + dash]),
  ("frame-char / frame-char-size", "none | str / length", [repeat a character instead of a line]),
  ("badge-size / badge-radius", "length  (0.78cm / 0.11cm)", [maximum plaque size — clamped to the frame so a one-line box is never shorter than its square]),
)

#demo(`#numbox-reset()
#numbox[
  Find 3 examples where the product
  of two numbers remains unchanged.
][
  Let the numbers be $a$ and $b$. \
  Then $(a + 2)(b - 4) = a b$.
]`.text,
  {
    numbox-reset()
    numbox[
      Find 3 examples where the product
      of two numbers remains unchanged.
    ][
      Let the numbers be $a$ and $b$. \
      Then $(a + 2)(b - 4) = a b$.
    ]
  })

#trio(
  [#cap[`number: auto` (1, then 2)]
    #numbox-reset()
    #numbox[First.]
    #v(0.25em)
    #numbox[Second.]],
  [#cap[`number: 7` then auto]
    #numbox(number: 7)[Forced to 7.]
    #v(0.25em)
    #numbox[Next is 8.]],
  [#cap[`number: none` / custom]
    #numbox(number: none)[No plaque.]
    #v(0.25em)
    #numbox(number: [A], colour: rgb("#7B1FA2"))[Letter.]],
)

#demo(`#numbox(colour: rgb("#C62828"),
  answer-label: [Sol.])[A red one.][Done.]`.text,
  numbox(colour: rgb("#C62828"), answer-label: [Sol.])[A red one.][Done.])

RTL: set the direction *before* the boxes (or pass `direction: rtl`).
The plaque moves to the right; the digits stay `1.` (not `.1`).

#demo(`#set text(lang: "ar", dir: rtl)
#numbox-reset()
#numbox[جد ثلاثة أمثلة.][
  ليكن العددان $a$ و $b$.
]`.text,
  {
    set text(lang: "ar", dir: rtl, font: ("Tajawal", "DejaVu Sans"))
    numbox-reset()
    numbox[جد ثلاثة أمثلة.][ليكن العددان $a$ و $b$.]
  })
