// New textbook plates — included by manual.typ after manual-extra.typ.
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
= Textbook plates <plates>

These plates came after the paper stocks: they are *designed* boxes —
octagons, ribbons, helix headers, punched bars, tickets, boards —
rather than generic `fabox` skins. Every one of them is direction-aware
(`direction: auto` follows the text) and sizes itself to its body.

#block(width: 100%,
  table(
    columns: (auto, auto, 1fr),
    inset: (x: 0.38em, y: 0.28em),
    stroke: (x, y) => (bottom: 0.35pt + RULE),
    fill: (x, y) => if y == 0 { ACCENT-SOFT } else if calc.odd(y) { CODEBG } else { none },
    table.header(
      text(font: SANS, size: 0.76em, weight: "bold")[Style],
      text(font: SANS, size: 0.76em, weight: "bold")[Function],
      text(font: SANS, size: 0.76em, weight: "bold")[What it is],
    ),
    ..(
      ("24", "iconbox / tip-card / concept-card", [icon plaque with a glued badge]),
      ("25", "crestbox / plate", [octagonal double-green plate]),
      ("26", "ribbonbox", [yellow plate, blue band, pink tab]),
      ("27", "helixbox", [helix header + trailing stripe]),
      ("28", "swooshbox", [one sheared blue silhouette + white plate]),
      ("29", "circuitbox", [double frame, stepped rails, title gap]),
      ("30", "keybox", [Greek-key corners + inset band]),
      ("31", "ringbox", [binder rings on the leading edge]),
      ("32", "punchbox", [punched bar, title tab, green side rules]),
      ("33", "plannerbox", [punch bar + rings]),
      ("34", "filebox", [folder with labelled tabs]),
      ("35", "stubbox", [ticket stub + perforation]),
      ("36", "stackbox", [offset sheets behind the card]),
      ("37", "calloutbox", [speech bubble with a leaning tail]),
      ("38", "tapebox", [washi tape across the top]),
      ("39", "chalkbox / markerbox", [classroom board, chalk or markers]),
      ("40", "screwbox", [plaque held by corner screws]),
      ("41", "sashbox / ruban", [folded ribbon: flat / arch / hang]),
    ).map(((n, k, d)) => (
      text(font: MONO, size: 0.72em, n),
      text(font: MONO, size: 0.66em, k),
      text(size: 0.8em, d),
    )).flatten(),
  ))

== `iconbox`

#fn("iconbox", `iconbox(body, title: none, icon: auto, colour: …)`)
#fn("tip-card", `tip-card(body, title: [Tip], …)`)
#fn("concept-card", `concept-card(body, title: [Concept], …)`)

A coloured plate with a drawn icon (pencil, bulb or star) glued to the
leading top corner. `tip-card` and `concept-card` are presets.

#params(
  ("title", "content | none", [the heading next to the icon]),
  ("icon", "auto | content", [auto = the default pencil; or ico-bulb / ico-star / ico-pencil]),
  ("colour / fill / title-colour", "color", [frame, wash, heading]),
  ("direction", "auto | ltr | rtl", [which side the icon sits on]),
)

#demo(`#iconbox(title: [Sketch])[A pencil plaque.]
#tip-card[Remember the chain rule.]
#concept-card[A named idea.]`.text,
  {
    iconbox(title: [Sketch], width: 100%)[A pencil plaque.]
    v(0.3em)
    tip-card(width: 100%)[Remember the chain rule.]
    v(0.3em)
    concept-card(width: 100%)[A named idea.]
  })

== `crestbox` / `plate`

#fn("crestbox", `crestbox(body, title: none, colour: …, cut: …, pair: …)`)
#fn("plate", `plate(body, …)   // alias`)

An octagon: the four corners are *cut*, not rounded. One black outer
stroke, two inner green hairlines with a white gutter. `shadow` is off
by default.

#params(
  ("cut", "length", [how far each corner is chamfered]),
  ("pair", "length", [gap between the two inner green hairlines]),
  ("weight / colour / fill", "length / color / color", [inner stroke, paint, wash]),
  ("shadow", "bool  (false)", [a hard drop; leave off to match the source plate]),
)

#demo(`#crestbox(title: [Crest])[
  An octagonal plate.
]`.text,
  crestbox(title: [Crest], width: 100%)[An octagonal plate.])

== `ribbonbox`

#fn("ribbonbox", `ribbonbox(body, title: none, colour: …, band: 0.20cm, …)`)

A yellow plate in a thick blue band, a white gutter, a thin inner
stroke, white L-chevrons in the corners, and a pink title tab. Chevrons
are drawn with physical `start`/`end` so they stay inward in RTL.

#params(
  ("band / pair / weight", "length", [outer band, white gutter, inner hairline]),
  ("tab-fill / title-colour / flourish", "color / color / bool", [the pink tab]),
  ("chevron / chevron-size / chevron-colour", "bool / length / color", [the corner Ls]),
  ("shadow / tab-offset", "bool / length", [drop shadow; tab inset from the start]),
)

#demo(`#ribbonbox(title: [Example])[
  A yellow plate in a blue band.
]`.text,
  ribbonbox(title: [Example], width: 100%)[A yellow plate in a blue band.])

== `helixbox`

#fn("helixbox", `helixbox(body, title: none, colour: …,
  shadow-lift: 0.08cm, …)`)

A teal header bar with a two-sine helix, a yellow/blue trailing stripe,
and an adjustable *lifted* shadow.

#params(
  ("helix-a / helix-b / helix-period", "color / color / length", [the two strands]),
  ("stripe / stripe-width", "array | color | none / length", [trailing colours]),
  ("shadow / shadow-lift / shadow-spread", "bool / length / length", [how high the card floats]),
  ("shadow-colour / shadow-offset / shadow-opacity / shadow-blur", "…", [paint, (dx, dy), peak, layers]),
)

#demo(`#helixbox(title: [Example])[Default lift.]
#helixbox(title: [High],
  shadow-lift: 0.20cm,
  shadow-spread: 0.22cm)[Hovering.]`.text,
  {
    helixbox(title: [Example], width: 100%)[Default lift.]
    v(0.45em)
    helixbox(title: [High], shadow-lift: 0.20cm, shadow-spread: 0.22cm,
      width: 100%)[Hovering.]
  })

== `swooshbox`

#fn("swooshbox", `swooshbox(body, title: none, skew: 10pt,
  tr: auto, br: auto, …)`)

One sheared blue silhouette, then a white rounded plate on top. Offsets
are in *y-up* coordinates: `tr: (dx, dy)` is right and up; `br: (dx, dy)`
is usually left and down. `BL` and `TL` stay flush with the white plate.

#params(
  ("skew", "length  (10pt)", [shorthand: tr = (s, s), br = (−s, −s)]),
  ("tr / br", "auto | (dx, dy)", [per-corner offset; auto follows skew]),
  ("colour / fill / tab-fill", "color", [silhouette, plate, title tab]),
  ("flourish / shadow", "bool", [curls on the tab; drop shadow]),
)

#demo(`#swooshbox(title: [Example])[default 10pt]
#swooshbox(title: [Wide],
  tr: (18pt, 8pt), br: (-6pt, -14pt))[custom]`.text,
  {
    swooshbox(title: [Example], width: 100%)[default 10pt]
    v(0.4em)
    swooshbox(title: [Wide], tr: (18pt, 8pt), br: (-6pt, -14pt),
      width: 100%)[custom]
  })

== `circuitbox`

#fn("circuitbox", `circuitbox(body, title: none, step: 0.26cm,
  rail: 1.35cm, gap: 1.55pt, …)`)

A double-line rounded frame whose top *breaks* into two stepped rails.
The title sits in the gap. The fill follows the rails up.

#params(
  ("step / rail", "length", [how high the rails rise, how long the flat run is]),
  ("weight / gap / pair", "length", [each stroke; the white between them (`gap` aliases `pair`)]),
  ("flourish", "bool", [curls beside the title]),
)

#demo(`#circuitbox(title: [Example])[default gap]
#circuitbox(title: [Wide], gap: 3.2pt)[a wider gutter]`.text,
  {
    circuitbox(title: [Example], width: 100%)[default gap]
    v(0.4em)
    circuitbox(title: [Wide], gap: 3.2pt, width: 100%)[a wider gutter]
  })

== `keybox`

#fn("keybox", `keybox(body, sz: 10pt, colour: rgb(0,0,128),
  frame: black, band: auto, …)`)

A picture-frame: an inset colour band, Greek-key corners, and connecting
rules. Ported from a page-background snippet.

#params(
  ("sz", "length  (10pt)", [size of each key]),
  ("colour / frame / fill", "color", [the band, the keys + rules, the plate]),
  ("band / band-inset", "auto | length / length", [band thickness / how far it sits in]),
)

#demo(`#keybox[four keys]
#keybox(sz: 14pt, colour: rgb("#6D4C41"))[larger]`.text,
  {
    keybox(width: 100%)[four keys]
    v(0.35em)
    keybox(sz: 14pt, colour: rgb("#6D4C41"), width: 100%)[larger]
  })

== `ringbox`

#fn("ringbox", `ringbox(body, rings: auto, colour: black,
  frame: false, …)`)

A pad with binder rings on the *leading* edge (left in LTR, right in
RTL). `rings: auto` packs as many as the height allows.

#params(
  ("rings", "auto | int", [auto = one every pitch; an int is the count]),
  ("ring-width / ring-radius / ring-thickness / ring-spacing", "length", [the bar + bead]),
  ("frame / frame-colour / frame-weight", "false | true | stroke / auto / length", [optional outline]),
  ("colour / fill", "color", [rings, paper]),
)

#demo(`#ringbox[no frame]
#ringbox(frame: true, colour: rgb("#1565C0"),
  fill: rgb("#E3F2FD"))[with a rule]`.text,
  {
    ringbox(width: 100%)[no frame]
    v(0.35em)
    ringbox(frame: true, colour: rgb("#1565C0"),
      fill: rgb("#E3F2FD"), width: 100%)[with a rule]
  })

== `punchbox`

#fn("punchbox", `punchbox(body, title: none, number: none,
  holes: auto, …)`)

A punched header bar, a blue title tab, a red number badge, green side
rules and a soft bottom shadow. The badge sits on the *inner* end of the
tab so RTL Arabic is never covered.

#params(
  ("title / number", "content | none", [the tab and the badge; number is content, e.g. [1]]),
  ("colour / badge-fill / bar / hole / side", "color", [tab, badge, punch bar, holes, side rules]),
  ("holes / hole-radius / bar-height", "auto | int / length / length", [the perforations]),
  ("shadow", "bool", [the lifted strip under the card]),
)

#demo(`#punchbox(title: [Example], number: [1])[
  A punched plate.
]`.text,
  punchbox(title: [Example], number: [1], width: 100%)[A punched plate.])

== `plannerbox`

#fn("plannerbox", `plannerbox(body, title: none, number: none,
  rings: auto, holes: auto, …)`)

#cmd[punchbox] and #cmd[ringbox] in one: a punched bar on top *and*
binder rings on the leading edge.

#demo(`#plannerbox(title: [Week], number: [3])[
  An agenda card.
]`.text,
  plannerbox(title: [Week], number: [3], width: 100%)[An agenda card.])

== `filebox`

#fn("filebox", `filebox(body, tabs: ([Notes],), active: 0, …)`)

A folder. `tabs` is an array of labels; `active` is the raised one
(0-based). Under RTL the physical order is mirrored so reading still
starts at the leading tab.

#params(
  ("tabs", "array of content", [the labels, left-to-right in LTR]),
  ("active", "int  (0)", [which tab is in front]),
  ("colour / active-fill / idle-fill / fill", "color", [outline, raised tab, idle tabs, body]),
)

#demo(`#filebox(tabs: ([Notes], [Ex], [Def]),
  active: 1)[The Ex tab is raised.]`.text,
  filebox(tabs: ([Notes], [Ex], [Def]), active: 1, width: 100%)[
    The Ex tab is raised.
  ])

== `stubbox`

#fn("stubbox", `stubbox(body, stub: none, stub-width: 1.35cm,
  dots: 11, dot: 1.1pt, …)`)

A ticket with a coloured stub and a perforated tear. The stub label is
always set LTR with Western digits (`lang: "en"`), then rotated 90°
without reflow — so `رقم 12` stays readable in an Arabic document.

#params(
  ("stub", "content | none", [the vertical label; use [رقم 12], not Indic digits]),
  ("stub-width", "length  (1.35cm)", [how wide the coloured stub is]),
  ("dots / dot", "int / length", [how many holes, and each hole’s radius]),
  ("colour / stub-colour / fill", "color", [stub fill, lettering, body]),
)

#demo(`#stubbox(stub: [N° 12])[Admit one.]
#stubbox(stub: [رقم 12], stub-width: 1.55cm,
  dots: 7)[Western 12.]`.text,
  {
    stubbox(stub: [N° 12], width: 100%)[Admit one.]
    v(0.35em)
    stubbox(stub: [رقم 12], stub-width: 1.55cm, dots: 7, width: 100%)[Western 12.]
  })

== `stackbox`

#fn("stackbox", `stackbox(body, title: none, layers: 3,
  offset: 0.16cm, …)`)

A card sitting on 2–4 offset sheets. Under RTL the pile grows to the
*left*.

#params(
  ("layers", "int  (3)", [how many sheets, including the top card]),
  ("offset", "length", [how far each back sheet peeks out]),
  ("back", "color | array", [colours of the hidden sheets, farthest first]),
)

#demo(`#stackbox(title: [Stack], layers: 3)[Three sheets.]
#stackbox(title: [Four], layers: 4, offset: 0.12cm,
  colour: rgb("#6A1B9A"),
  back: (rgb("#E1BEE7"), rgb("#CE93D8"),
         rgb("#BA68C8")))[A taller pile.]`.text,
  {
    stackbox(title: [Stack], layers: 3, width: 100%)[Three sheets.]
    v(0.45em)
    stackbox(title: [Four], layers: 4, offset: 0.12cm,
      colour: rgb("#6A1B9A"),
      back: (rgb("#E1BEE7"), rgb("#CE93D8"), rgb("#BA68C8")),
      width: 100%)[A taller pile.]
  })

== `calloutbox`

#fn("calloutbox", `calloutbox(body, title: none, tail: "sw",
  tail-size: 0.42cm, tail-at: 0.18, …)`)

A speech bubble. The tail *leans*: `sw` / `nw` point past the start of
the chord, `se` / `ne` past the end. The chord itself is never stroked
— a fill-coloured cover, as thick as the frame plus 1.2 pt, sits
exactly between the two attachment points.

#params(
  ("tail", `sw | se | nw | ne | start | end`, [corner, or reading-order start/end]),
  ("tail-size / tail-at", "length / float 0–1", [how long, and how far along the edge]),
  ("weight / radius / colour / fill", "length / length / color / color", [the bubble]),
)

#demo(`#calloutbox(title: [Tip], tail: "sw")[leans left]
#calloutbox(tail: "se")[leans right]`.text,
  {
    calloutbox(title: [Tip], tail: "sw", width: 100%)[leans left]
    v(0.45em)
    calloutbox(tail: "se", width: 100%)[leans right]
  })

== `tapebox`

#fn("tapebox", `tapebox(body, title: none, pattern: "solid",
  tilt: -1.2deg, …)`)

A card sealed at the top with a strip of washi tape. `pattern: "gingham"`
is the cloth / torchon check.

#params(
  ("pattern", `solid | gingham`, [the print]),
  ("colour / tape-b", "color", [the wash, and the second gingham colour]),
  ("tape-height / tape-overhang / tilt", "length / length / angle", [the strip]),
)

#demo(`#tapebox(title: [Note])[plain tape]
#tapebox(title: [Gingham],
  pattern: "gingham")[checked]`.text,
  {
    tapebox(title: [Note], width: 100%)[plain tape]
    v(0.5em)
    tapebox(title: [Gingham], pattern: "gingham", width: 100%)[checked]
  })

== `chalkbox` / `markerbox`

#fn("chalkbox", `chalkbox(body, title: none, border: 0.16cm,
  grid-step: 0.32cm, tray: true, …)`)
#fn("markerbox", `markerbox(body, title: none, …)`)

Classroom boards after kmbeamer. #cmd[chalkbox] is a green slate in a
varnished wooden frame, with an eraser and three sticks of chalk on the
*bottom edge*. #cmd[markerbox] is the same woodwork in aluminium, with
markers instead of chalk. The title follows the reading edge.

#params(
  ("border", "length  (0.16cm)", [thickness of the outer wood / aluminium]),
  ("grid / grid-step", "bool / length", [the ruling; horizontals run to the bottom edge]),
  ("tray", "bool", [the eraser + chalks / markers]),
  ("fill / text-fill / title-colour", "auto | color", [slate, body ink, heading]),
)

#demo(`#chalkbox(title: [Lemma])[
  $ a^2 + b^2 = c^2 $
]
#markerbox(title: [Note],
  grid-step: 0.45cm)[a whiteboard]`.text,
  {
    chalkbox(title: [Lemma], width: 100%)[$ a^2 + b^2 = c^2 $]
    v(0.4em)
    markerbox(title: [Note], grid-step: 0.45cm, width: 100%)[a whiteboard]
  })

== `screwbox`

#fn("screwbox", `screwbox(body, tl: true, tr: true, bl: true, br: true,
  angle: 0deg, …)`)

A plate held by corner screws. `tl` / `tr` / `bl` / `br` are *physical*
corners. Each one is `true` (use `angle`), `false` (no screw), or an
`angle` (that screw’s own slot tilt).

#params(
  ("tl / tr / bl / br", "bool | angle  (true)", [which corners have a screw, and optionally the slot]),
  ("angle", "angle  (0deg)", [default slot tilt]),
  ("screw / slot / screw-size", "color / color / length", [head, slot paint, diameter]),
  ("colour / fill / weight / radius", "color / color / length / length", [the plate]),
)

#demo(`#screwbox[four screws]
#screwbox(angle: 35deg)[all tilted]
#screwbox(tl: 20deg, tr: -20deg,
  bl: false, br: false)[top pair, opposed]`.text,
  {
    screwbox(width: 100%)[four screws]
    v(0.3em)
    screwbox(angle: 35deg, width: 100%)[all tilted]
    v(0.3em)
    screwbox(tl: 20deg, tr: -20deg, bl: false, br: false, width: 100%)[
      top pair, opposed
    ]
  })

== `sashbox` / `ruban`

#fn("sashbox", `sashbox(body, kind: "flat", incline: auto, rough: false, …)`)
#fn("ruban", `ruban   // alias of sashbox`)

A folded ribbon banner: a main band
on swallow-tail wings, with a tucked underside triangle at each end.
`kind` is `"flat"`, `"arch"` or `"hang"`. Lettering follows the bow;
under RTL the clusters run the other way along the same arc.

#params(
  ("kind", `flat | arch | hang`, [silhouette: level, bowed up, or hanging]),
  ("incline", "auto | float | length", [1 = the kind’s default bow; 0 = flat; a length is the rise/drop]),
  ("bow", "auto | length", [absolute rise (positive) or drop (negative); overrides incline]),
  ("fill / shade / text-colour", "color / auto / auto", [band, fold face, lettering]),
  ("height / width / tail / fold", "length / ratio|length / auto / auto", [band size and wing geometry]),
  ("rough / hand / ink / pen / ghost / seed", "bool / auto|sloppy|roughjs / auto / length / bool / int", [closed sloppy-box outline]),
)

#demo(`#sashbox(kind: "flat")[SUMMER SALE]
#sashbox(kind: "arch")[Welcome]
#sashbox(kind: "hang")[Thank you]`.text,
  {
    sashbox(kind: "flat", fill: rgb("#FFE566"))[SUMMER SALE]
    v(0.45em)
    sashbox(kind: "arch", fill: rgb("#FF9EC8"))[Welcome]
    v(0.45em)
    sashbox(kind: "hang", fill: rgb("#7ED4C8"))[Thank you]
  })

#demo(`#sashbox(kind: "arch", incline: 0.45)[soft]
#sashbox(kind: "arch", incline: 1.4)[steep]
#sashbox(kind: "arch", rough: true,
  ink: rgb("#C0392B"))[sloppy]`.text,
  {
    sashbox(kind: "arch", incline: 0.45, fill: rgb("#FF9EC8"))[soft]
    v(0.4em)
    sashbox(kind: "arch", incline: 1.4, fill: rgb("#FF9EC8"))[steep]
    v(0.4em)
    sashbox(kind: "arch", rough: true, ink: rgb("#C0392B"),
      fill: rgb("#FF9EC8"))[sloppy]
  })

#note-line[`rough: true` draws *one closed silhouette* (left wing → band
bottom → right wing → band top) plus the two fold creases. `ink` is the
pen colour; omit it for charcoal.]
