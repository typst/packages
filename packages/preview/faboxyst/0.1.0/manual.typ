// ===========================================================================
//  faboxyst — package manual
//
//    typst compile manual.typ --root .
// ===========================================================================

#import "/lib.typ": *

#let VERSION = "0.1.0"
#let ACCENT = rgb("#1772B2")
#let ACCENT-SOFT = rgb("#E8F2FA")
#let INK = rgb("#1A1A1A")
#let MUTED = rgb("#5A6570")
#let CODEBG = rgb("#F4F6F8")
#let RULE = rgb("#D0D7DE")
#let BODY = ("Libertinus Serif", "DejaVu Serif")
#let SANS = ("DejaVu Sans",)
#let MONO = ("DejaVu Sans Mono",)

#set document(title: "faboxyst " + VERSION, author: "faboxyst")
#set page(
  paper: "a4",
  margin: (x: 2.0cm, top: 2.2cm, bottom: 2.0cm),
  header: context {
    let n = counter(page).get().first()
    if n <= 2 { return }
    set text(size: 8pt, fill: MUTED, font: SANS)
    grid(columns: (1fr, 1fr),
      align(left)[faboxyst #VERSION],
      align(right, {
        let h = query(selector(heading.where(level: 1)).before(here()))
        if h.len() > 0 { h.last().body } else { [] }
      }),
    )
    v(-0.3em)
    line(length: 100%, stroke: 0.4pt + RULE)
  },
  footer: context {
    let n = counter(page).get().first()
    if n <= 1 { return }
    set text(size: 8pt, fill: MUTED, font: SANS)
    align(center, counter(page).display("1"))
  },
)
#set text(font: BODY, size: 10pt, fill: INK, lang: "en")
#set par(justify: true, leading: 0.68em, spacing: 0.78em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  if it.numbering != none { pagebreak(weak: true) }
  block(above: 0.4em, below: 0.7em, {
    set text(font: SANS, weight: "bold", fill: ACCENT, size: 1.45em)
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(0.4em)
    }
    it.body
  })
  line(length: 100%, stroke: 1.2pt + ACCENT)
  v(0.35em)
}
#show heading.where(level: 2): it => block(above: 1.15em, below: 0.45em, {
  set text(font: SANS, weight: "bold", fill: ACCENT.darken(8%), size: 1.12em)
  if it.numbering != none {
    counter(heading).display(it.numbering)
    h(0.35em)
  }
  it.body
})
#show heading.where(level: 3): it => block(above: 0.9em, below: 0.3em, {
  set text(font: SANS, weight: "bold", fill: INK, size: 1.02em)
  if it.numbering != none {
    counter(heading).display(it.numbering)
    h(0.3em)
  }
  it.body
})
#show raw.where(block: false): it => text(font: MONO, size: 0.86em, fill: rgb("#0B3D5C"), it)
#show outline.entry.where(level: 1): it => {
  v(0.35em, weak: true)
  strong(it)
}

// --- documentation helpers ------------------------------------------------

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

// ===========================================================================
//  COVER
// ===========================================================================

#page(header: none, footer: none, margin: (x: 2.2cm, y: 2.4cm), {
  align(horizon, {
    text(font: SANS, size: 11pt, fill: ACCENT, tracking: 1.2pt)[TYPST PACKAGE]
    v(0.6em)
    text(font: SANS, size: 36pt, weight: "bold", fill: INK)[faboxyst]
    v(0.25em)
    text(size: 13pt, fill: MUTED)[Coloured boxes for Typst, in the spirit of tcolorbox]
    v(3.1em)

    text(size: 13pt, fill: luma(68))[#emoji.hand.write FERGOUS Abdelhak]
  
    v(.1em)
    line(length: 4.2cm, stroke: 2pt + ACCENT)
    v(1.1em)
    text(font: SANS, size: 11pt)[Manual for version #VERSION]
    v(0.25em)
    text(size: 10pt, fill: MUTED)[Typst 0.15  ·  RTL-aware]
  })
  place(bottom + left, {
    set text(size: 8.5pt, fill: MUTED)
    [Compile: #raw("typst compile manual.typ --root .")]
  })
})

// ===========================================================================
//  OUTLINE
// ===========================================================================

#page(header: none, {
  heading(outlined: false, numbering: none)[Contents]
  v(0.3em)
  columns(2, outline(indent: 0.7em, depth: 3, title: none))
})

// ===========================================================================
= Introduction

*faboxyst* draws coloured, titled boxes. It is the Typst counterpart of
Thomas F. Sturm’s LaTeX package *tcolorbox*: one function, #cmd[fabox],
covers titles, tabs, shadows, decorated borders and folded corners; a
handful of wrappers give you everyday callouts without repeating options.

Boxes *measure their own content* and draw a frame at exactly that size.
The line can be crisp (`rough: false`, the default on #cmd[fabox]) or
hand-drawn (`rough: true`). The wobble is deterministic: the same `seed`
always produces the same line.

Everything is direction-aware. Under `dir: rtl` titles, tabs, side bars
and folded corners move to the leading edge on their own.

= Getting started

== Installation

Place the `faboxyst/` folder next to your document.

```
typst compile doc.typ --root .
```

The package needs `@preview/cetz:0.5.2` (Typst downloads it on first
compile) and the bundled `assets/sketch.wasm`. No fonts are shipped —
Typst uses whatever is installed (DejaVu, etc.). Optional extras if you
have them: xkcd Script, Bevan, Comic Neue, Tajawal, Lalezar.

== A first document

#demo(`#import "faboxyst/lib.typ": *
#show: faboxyst.with(
  theme: themes.notebook,
)

#fabox(title: [Note])[
  A titled box.
]
#tip[A semantic tip.]
#warning[Never divide by zero.]`.text,
  {
    fabox(title: [Note], width: 100%)[A titled box.]
    v(0.35em)
    tip(width: 100%)[A semantic tip.]
    v(0.35em)
    warning(width: 100%)[Never divide by zero.]
  })

#cmd[faboxyst] is a *show rule*, not a document class. It applies a
theme (colours, roughness, language, direction) and leaves the page to you.

== How to read this manual

Every function is documented the same way:

1. A *signature* (name, parameters, return type).
2. A *parameter table* (name, type / default, meaning).
3. A *live example*: source on the left, compiled result on the right.

To find something fast:

- @quick-ref[Quick reference] lists every public function in one table.
- @styles[Style catalogue] shows each look with the options that change it.
- @fabox-opts[Option index] lists every #cmd[fabox] key alphabetically.
- @fn-index[Function index] is the same list, grouped by role.

= Quick reference <quick-ref>

#block(width: 100%,
  table(
    columns: (auto, 1fr),
    inset: (x: 0.45em, y: 0.34em),
    stroke: (x, y) => (bottom: 0.4pt + RULE),
    fill: (x, y) => if y == 0 { ACCENT-SOFT } else if calc.odd(y) { CODEBG } else { none },
    table.header(
      text(font: SANS, size: 0.8em, weight: "bold")[Function],
      text(font: SANS, size: 0.8em, weight: "bold")[Use this when…],
    ),
    ..(
      ("fabox", [you want a titled coloured box — start here]),
      ("fabox-sign", [an octagonal / polygonal sign (STOP)]),
      ("fabox-note", [a yellow folded “!” note]),
      ("example-header", [a textbook masthead, not a box]),
      ("numbox", [numbered question; auto or manual, LTR / RTL]),
      ("note / tip / warning / example", [everyday callouts]),
      ("definition", [a term + explanation (+ examples)]),
      ("sketch-box", [you need a custom shape / hatch / extrusion]),
      ("burst / block3d / hatched / shadowed", [one-knob variants of sketch-box]),
      ("plaque / pill-box / double-frame", [plaque, stadium, double outline]),
      ("sloppy-box", [four overshooting strokes]),
      ("notebook-box", [spiral-bound exercise card (wire rings)]),
      ("notepad / ruled-sheet", [spiral pad, or punched filler paper]),
      ("torn-note / deckle-tag / sb-tape", [torn kraft, feathered tag, washi / gingham tape]),
      ("stamp-card / grid-note / index-card / lesson-card", [mat, graph paper, ruled card, dovetail banner]),
      ("sticky / post-it", [sticky notes; pin / clip / tape]),
      ("ticket / ticketbox / folder / terminal", [torn stub (RTL hole + disc), file tab, terminal]),
      ("sashbox / ruban", [folded ribbon: flat / arch / hang; incline; rough ink]),
      ("vignette / neon / polaroid", [two-cell, glow, instant-photo]),
      ("spread-box", [a box that grows into the margins]),
      ("highlight", [a highlighter swipe on inline text]),
      ("iconbox / crestbox / ribbonbox", [icon plaque, octagon, yellow+blue band]),
      ("helixbox / swooshbox / circuitbox", [helix header, sheared plate, stepped rails]),
      ("keybox / ringbox / punchbox / plannerbox", [Greek key, binder rings, punched bar, both]),
      ("filebox / stubbox / stackbox", [folder tabs, ticket stub, stacked sheets]),
      ("calloutbox / tapebox / chalkbox / markerbox", [speech bubble, washi, slate, whiteboard]),
      ("screwbox", [plaque held by 1–4 corner screws]),
      ("faboxyst", [apply a theme (`#show: …`)]),
    ).map(((n, d)) => (
      text(font: MONO, size: 0.76em, n),
      text(size: 0.84em, d),
    )).flatten(),
  ))

= Setup and themes

#fn("faboxyst", "faboxyst(theme: default-theme, ..over, body)")

A show rule. Merge a ready-made theme, a partial dictionary, or both.

#params(
  ("theme", "dictionary", [a full theme, or overrides merged onto the default]),
  ("..over", "named", [same keys as a theme, shorthand for a partial]),
)

#demo(`#show: faboxyst.with(theme: themes.blueprint)
#show: faboxyst.with(theme: (accent: red, roughness: 1.5))
#show: faboxyst.with(theme: themes.arabic)`.text,
  {
    set text(size: 8pt)
    grid(columns: (1fr, 1fr), gutter: 0.28cm, row-gutter: 0.28cm,
      sketch-box(stroke-colour: palette.pink, width: 100%)[notebook],
      sketch-box(stroke-colour: palette.cyan, width: 100%)[blueprint],
      sketch-box(stroke-colour: palette.lime, roughness: 1.6, width: 100%)[bold],
      sketch-box(stroke-colour: luma(120), roughness: 0.55, width: 100%)[quiet],
    )
  })

== Built-in themes

#params(
  ("themes.notebook", "default", [warm paper, pink accent]),
  ("themes.blueprint", "—", [cool blue, ruled paper]),
  ("themes.bold", "—", [heavier strokes, more wobble]),
  ("themes.quiet", "—", [grey, nearly straight lines]),
  ("themes.arabic", "—", [dir: rtl, lang: "ar", Tajawal]),
)

== Theme keys

These keys live on the theme dictionary and are read by every semantic box.

#params(
  ("accent", "color", [default stroke of note / sketch-box]),
  ("palette", "dictionary", [named swatches: palette.lime, palette.navy, …]),
  ("ink / paper", "color", [text and page colours]),
  ("fonts", "dictionary", [body / heading / bubble / mono / emoji stacks]),
  ("roughness", "float  (1.0)", [wobble multiplier; 0 is a clean line]),
  ("stroke-weight", "length  (1.6pt)", [default frame thickness]),
  ("pad / radius / gap", "length / cm / length", [inner pad, corner, after-gap]),
  ("dir / lang", "direction / str", [ltr or rtl; language tag]),
  ("seed", "int  (1)", [base seed for the document]),
)

#fn("make-theme", "make-theme(base: default-theme, ..over) → dictionary", ret: [dictionary])
#fn("get-theme", "get-theme() → dictionary   // call inside context", ret: [dictionary])

== Palette

#let sw(c, n) = box(inset: (y: 1pt, x: 1pt), {
  box(width: 8pt, height: 8pt, fill: c, radius: 1.5pt, stroke: 0.35pt + luma(160))
  h(3pt)
  text(size: 7.2pt, font: MONO, n)
})
#sw(palette.pink, "pink") #sw(palette.sky, "sky") #sw(palette.lime, "lime")
#sw(palette.gold, "gold") #sw(palette.orchid, "orchid") #sw(palette.red, "red")
#sw(palette.navy, "navy") #sw(palette.green, "green") #sw(palette.orange, "orange")
#sw(palette.cyan, "cyan") #sw(palette.hilite, "hilite") #sw(palette.pltblue, "pltblue")

= The main box: `fabox` <sec-fabox>

#fn("fabox", `fabox(
  body,
  title: none, colour: rgb("#B03A2E"),
  frame: auto, back: auto,
  title-fill: auto, title-colour: auto,
  …   // see Option index
)`)

This is the function to reach for. One description draws both a crisp
box and a hand-drawn one (`rough: true`). Fully RTL-aware.

== A titled box

#demo(`#fabox(title: [My title])[
  This is a *fabox*.
]`.text,
  fabox(title: [My title], width: 100%)[This is a *fabox*.])

#demo(`#fabox[
  No title — just a coloured frame.
]`.text,
  fabox(width: 100%)[No title — just a coloured frame.])

== Colours

#params(
  ("colour", "color  (#B03A2E)", [the family colour; other paints derive from it]),
  ("frame", "color | auto", [the outline; auto = colour]),
  ("back", "color | auto", [body fill; auto = a 5 % wash of colour]),
  ("title-fill", "color | auto", [title bar; auto = colour]),
  ("title-colour", "color | auto", [title text; auto = black or white, whichever reads]),
  ("gradient-to", "color | none", [second colour for a vertical body wash]),
)

#demo(`#fabox(title: [Navy], colour: rgb("#1E5CB3"))[derived paints]
#fabox(title: [Wash], colour: rgb("#2F7D32"),
  gradient-to: rgb("#E8F5E9"))[a vertical wash]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.3cm,
    fabox(title: [Navy], colour: rgb("#1E5CB3"), width: 100%)[derived paints],
    fabox(title: [Wash], colour: rgb("#2F7D32"),
      gradient-to: rgb("#E8F5E9"), width: 100%)[a vertical wash],
  ))

== Size and geometry

#params(
  ("width", "auto | length | ratio  (100%)", [auto shrinks to the content]),
  ("radius", "float cm  (0.16)", [corner radius]),
  ("sharp", "array  (())", [which corners stay square: "northwest", … or ("all",)]),
  ("weight", "length  (1.0pt)", [outline thickness]),
  ("inset", "length  (0.34cm)", [padding around the body]),
  ("title-inset", "length  (0.24cm)", [padding around the title]),
  ("inline", "bool  (false)", [stay in the paragraph instead of breaking the line]),
  ("baseline", "relative  (30%)", [how far an inline box drops below the baseline]),
)

#demo(`A tight box: #fabox(width: auto, title: none)[$ e^{i pi} + 1 = 0 $].
An inline one: #fabox(inline: true, width: auto,
  colour: rgb("#1E5CB3"))[inline].`.text,
  [A tight box: #fabox(width: auto, title: none)[$ e^{i pi} + 1 = 0 $].
    An inline one: #fabox(inline: true, width: auto, colour: rgb("#1E5CB3"))[inline].])

== Tabs

`tab` attaches the title instead of drawing a full-width bar.

#params(
  ("tab", "none | str", [none, "top", "ribbon", "bottom", "plaque", "swoosh", "fold", "label", "exercise", "spine", "ears", "dots"]),
  ("tab-width", "ratio  (45%)", [share of the edge for "top" / "ribbon"]),
  ("tab-offset", "float cm  (0.5)", [leading gap before a plaque / ears / dots]),
)

=== `plaque` — heading on the rule

#demo(`#fabox(title: [Theorem 1.1], tab: "plaque",
  colour: rgb("#CCCCFF"), title-colour: black,
  back: white, weight: 2pt, radius: 0,
  sharp: ("all",))[
  $ a^2 + b^2 = c^2 $
]`.text,
  fabox(title: [Theorem 1.1], tab: "plaque",
    colour: rgb("#CCCCFF"), title-colour: black,
    back: white, weight: 2pt, radius: 0,
    sharp: ("all",), width: 100%)[$ a^2 + b^2 = c^2 $])

=== `top` / `ribbon` / `bottom`

#demo(`#fabox(title: [top], tab: "top")[a flag]
#fabox(title: [ribbon], tab: "ribbon")[a pennant]
#fabox(title: [bottom], tab: "bottom")[a lobe]`.text,
  grid(columns: (1fr, 1fr, 1fr), gutter: 0.25cm,
    fabox(title: [top], tab: "top", width: 100%)[a flag],
    fabox(title: [ribbon], tab: "ribbon", width: 100%)[a pennant],
    fabox(title: [bottom], tab: "bottom", width: 100%)[a lobe],
  ))

=== `swoosh` — InDesign banner

#params(
  ("swoosh", "float  (0.2)", [length of the S-curve, as a fraction of the edge]),
  ("swoosh-deep", "float  (0.48)", [how far it drops, as a fraction of the banner]),
  ("swoosh-side", "top | bottom | left | right", [which edge carries it]),
  ("swoosh-align", "start | center | end", [where the title sits]),
)

#demo(`#fabox(title: [Long Fancy Title],
  tab: "swoosh", colour: rgb("#00A000"),
  back: white)[the bar swells around the words]`.text,
  fabox(title: [Long Fancy Title], tab: "swoosh",
    colour: rgb("#00A000"), back: white, width: 100%)[
    the bar swells around the words
  ])

=== `fold` — 3-D ribbon

#demo(`#fabox(title: [Title], tab: "fold",
  colour: black, title-fill: rgb("#89BADD"),
  title-colour: black,
  fold-colour: rgb("#1475BB"),
  back: white, sharp: ("all",))[Hello World!]`.text,
  fabox(title: [Title], tab: "fold", colour: black,
    title-fill: rgb("#89BADD"), title-colour: black,
    fold-colour: rgb("#1475BB"), back: white,
    radius: 0, sharp: ("all",), width: 100%)[Hello World!])

=== `exercise` — badge and chevrons

#params(
  ("badge", "content | none", [a boxed number at the end of the tab]),
  ("chevrons", "int  (0)", [fading `>` marks trailing the title]),
  ("side-bar / bottom-rule / corner-tick", "float cm | none", [open frame: left + bottom + a short return]),
)

#demo(`#fabox(title: [Exercise], tab: "exercise",
  badge: [1], chevrons: 4,
  colour: rgb("#663599"),
  frame-hidden: true, back: white,
  side-bar: 0.05, bottom-rule: 0.05,
  corner-tick: 0.5, sharp: ("all",))[
  An open left + bottom frame.
]`.text,
  fabox(title: [Exercise], tab: "exercise", badge: [1], chevrons: 4,
    colour: rgb("#663599"), frame-hidden: true, back: white,
    side-bar: 0.05, bottom-rule: 0.05, corner-tick: 0.5,
    radius: 0, sharp: ("all",), width: 100%)[An open left + bottom frame.])

=== `label` — two-tone tab plus an outside caption

#params(
  ("label-number", "content | none", [the square number block]),
  ("label-caption", "content | none", [a caption set *outside* the tab]),
  ("label-out", "auto | float cm", [how far the tab overhangs; auto = 0.88 × height]),
  ("label-round / label-square", "bool", [round the number block / no rounding at all]),
)

#demo(`#fabox(title: [EXAMPLE], tab: "label",
  label-number: [1],
  label-caption: [Solution],
  colour: rgb("#00A550"),
  title-fill: rgb("#5B58FF"))[
  This is Example 1.
]`.text,
  fabox(title: [EXAMPLE], tab: "label", label-number: [1],
    label-caption: [Solution], colour: rgb("#00A550"),
    title-fill: rgb("#5B58FF"), back: white, width: 100%)[
    This is Example 1.
  ])

=== `spine` — upright side bar

#params(
  ("spine-side", "start | end", [leading or trailing edge]),
  ("spine-align", "start | center | end", [where it sits along the edge]),
  ("spine-out", "auto | length", [how far it sticks out; auto = 0.85 × depth]),
  ("spine-len", "auto | length | ratio", [its length; a ratio is of the frame height]),
)

#demo(`#fabox(tab: "spine", title: [LEARN THIS],
  colour: rgb("#641648"),
  radius: 0, spine-out: 0pt)[
  A vertical bar clamped on the leading edge.
]`.text,
  fabox(tab: "spine", title: [LEARN THIS], colour: rgb("#641648"),
    radius: 0, spine-out: 0pt, weight: 0.8pt, width: 100%)[
    A vertical bar clamped on the leading edge.
  ])

=== `ears` / `dots` — moulded headings

#demo(`#fabox(tab: "ears", title: [Definition],
  colour: rgb("#7F0000"),
  back: rgb("#FDF0F0"))[flared scoops]
#fabox(tab: "dots", title: [Note],
  colour: rgb("#2D6FB1"))[studs on the rule]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.3cm,
    fabox(tab: "ears", title: [Definition], colour: rgb("#7F0000"),
      back: rgb("#FDF0F0"), width: 100%)[flared scoops],
    fabox(tab: "dots", title: [Note], colour: rgb("#2D6FB1"),
      width: 100%)[studs on the rule],
  ))

== Shadows

#params(
  ("shadow", "none | true | str", [true/"plain", "small", "large", "lifted", "fuzzy"]),
  ("shadow-colour", "color | auto", [auto = luma(120)]),
  ("shadow-spread", "auto | float cm", [how far it reaches]),
  ("shadow-offset", "auto | (dx, dy)", [auto = down and to the trailing side]),
  ("shadow-opacity", "auto | ratio", [darkest point, 0–100 %]),
  ("shadow-blur", "int  (14)", [stacked copies; more = smoother]),
)

#demo(`#fabox(title: [plain], shadow: true)[offset]
#fabox(title: [fuzzy], shadow: "fuzzy")[soft]
#fabox(title: [lifted], shadow: "lifted")[pinned corners]`.text,
  grid(columns: (1fr, 1fr, 1fr), gutter: 0.28cm,
    fabox(title: [plain], shadow: true, width: 100%)[offset],
    fabox(title: [fuzzy], shadow: "fuzzy", width: 100%)[soft],
    fabox(title: [lifted], shadow: "lifted", width: 100%)[pinned],
  ))

== Borders and rules

#params(
  ("border", "none | zigzag | wave | caution", [decorated edge; "caution" is hazard tape]),
  ("tape-width / tape-period", "length  (0.16 / 0.10 cm)", [caution band and stripe]),
  ("tape-colours", "(color, color)", [the two hazard colours]),
  ("frame-hidden", "bool  (false)", [drop the outline entirely]),
  ("side-bar / top-rule / bottom-rule", "none | float cm", [thick rules inside the frame]),
  ("corner-tick", "none | float cm", [a short return up from the trailing bottom corner]),
  ("title-rule-inset", "float cm  (0.0)", [shorten the rule under the title, both ends]),
  ("sweep", "none | float cm", [open U-frame; the number is the big-corner radius]),
  ("halo", "none | (r, color) | array", [a soft glow around the frame]),
  ("vignette", "none | float", [a raised bevel just inside the frame]),
  ("fold", "bool  (false)", [turn up a dog-ear (the *corner*, not tab: "fold")]),
  ("watermark", "content | none", [faint text behind the body]),
)

#demo(`#fabox(border: "caution", width: auto,
  title: none)[$ a^2 + b^2 = c^2 $]
#fabox(title: [open], sweep: 1.4,
  colour: rgb("#1E5CB3"))[a U-frame]`.text,
  grid(columns: (auto, 1fr), gutter: 0.35cm, align: horizon,
    fabox(border: "caution", width: auto, title: none)[$ a^2 + b^2 = c^2 $],
    fabox(title: [open], sweep: 1.4, colour: rgb("#1E5CB3"), width: 100%)[a U-frame],
  ))

#demo(`#fabox(title: [Warn], shadow: "fuzzy",
  watermark: [NOTE], colour: rgb("#B03A2E"))[
  fuzzy shadow + watermark
]
#fabox(title: [Note], fold: true,
  colour: rgb("#FBEC5D"),
  title-colour: black)[a turned-up corner]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.3cm,
    fabox(title: [Warn], shadow: "fuzzy", watermark: [NOTE],
      colour: rgb("#B03A2E"), width: 100%)[fuzzy shadow + watermark],
    fabox(title: [Note], fold: true, colour: rgb("#FBEC5D"),
      title-colour: black, width: 100%)[a turned-up corner],
  ))

== Hand-drawn mode

#params(
  ("rough", "bool  (false)", [draw with a wobble]),
  ("roughness", "float  (1.0)", [how wild the wobble is]),
  ("bowing", "float  (0.6)", [how much each edge bows]),
  ("seed", "int  (11)", [fix the wobble]),
)

#demo(`#fabox(title: [crisp], rough: false)[default]
#fabox(title: [drawn], rough: true)[same options]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.3cm,
    fabox(title: [crisp], rough: false, width: 100%)[default],
    fabox(title: [drawn], rough: true, width: 100%)[same options],
  ))

== Subtitles

#params(
  ("subtitles", "array  (())", [((heading, body), …) — extra bars under the body]),
)

#demo(`#fabox(title: [Lemma],
  subtitles: (([Proof], [By induction.]),))[
  The statement.
]`.text,
  fabox(title: [Lemma],
    subtitles: (([Proof], [By induction.]),),
    width: 100%)[The statement.])

= Ready-made boxes

These three are specialised shapes, not #cmd[fabox] with different defaults.

== `fabox-sign`

#fn("fabox-sign", `fabox-sign(body, sides: 8, size: 2.6, colour: rgb("#D32F2F"), …)`)

A regular polygon — tcolorbox’s STOP-sign example.

#params(
  ("sides", "int  (8)", [3 = triangle, 4 = square, 8 = octagon]),
  ("size", "float cm  (2.6)", [width and height]),
  ("colour / text-colour", "color", [fill and lettering]),
  ("ring", "float cm  (0.16)", [the white inner rule]),
  ("rough / seed", "bool / int", [hand-drawn mode]),
)

#demo(`#fabox-sign[STOP]
#fabox-sign(sides: 4, colour: rgb("#1565C0"),
  size: 2.2)[INFO]`.text,
  grid(columns: (auto, auto), gutter: 0.7cm, align: horizon,
    fabox-sign[STOP],
    fabox-sign(sides: 4, colour: rgb("#1565C0"), size: 2.2)[INFO],
  ))

== `fabox-note`

#fn("fabox-note", `fabox-note(body, icon: [!], colour: rgb("#FBEC5D"), …)`)

The yellow folded note of the tcolorbox manual: a square icon block on
the leading edge and a turned-up trailing corner.

#demo(`#fabox-note[Remember to save.]
#fabox-note(icon: [?], colour: rgb("#BBDEFB"))[A question.]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.3cm,
    fabox-note[Remember to save.],
    fabox-note(icon: [?], colour: rgb("#BBDEFB"))[A question.],
  ))

== `example-header`

#fn("example-header", `example-header(word, number: none, tag: none, note: none, …)`)

A *header*, not a box: pill + numbered disc + arrow banner + label. It
takes no body, so it can sit above running text or above a #cmd[fabox].

#demo(`#example-header([Example], number: [1],
  tag: [SKILLS], note: [PROBLEM-SOLVING])`.text,
  example-header([Example], number: [1],
    tag: [SKILLS], note: [PROBLEM-SOLVING]))

= Semantic boxes

Everyday callouts. All of them are #cmd[sketch-box] with different
defaults, so they accept the same extra arguments (`width`, `fill`,
`hatch`, `roughness`, `seed`, `breakable`, …).

#fn("note", "note(body, ..sketch-box-args)")
#fn("tip", "tip(body, colour: auto, ..)")
#fn("warning", "warning(body, colour: auto, ..)")
#fn("example", "example(body, colour: auto, ..)")

#demo(`#note[A plain note in the accent colour.]
#tip[A tip, in lime.]
#warning[A warning, in red.]
#example[A worked example, tinted.]`.text,
  {
    note(width: 100%)[A plain note in the accent colour.]
    v(0.28em)
    tip(width: 100%)[A tip, in lime.]
    v(0.28em)
    warning(width: 100%)[A warning, in red.]
    v(0.28em)
    example(width: 100%)[A worked example, tinted.]
  })

== `definition`

#fn("definition", `definition(term, body)  or  definition(term, body, examples)`)

#demo(`#definition("INTEGERS")[
  All whole numbers, positive or negative.
][
  ... −2, −1, 0, 1, 2 ...
]`.text,
  definition("INTEGERS")[All whole numbers, positive or negative.][
    #text(fill: palette.navy)[... −2, −1, 0, 1, 2 ...]])

Under RTL the open frame and the *أمثلة:* label swap sides.

= Custom shapes: `sketch-box`

#fn("sketch-box", `sketch-box(body, shape: "round", fill: none, …)`)

The workhorse under every semantic box. Reach for it when no name covers
what you want.

#params(
  ("shape", "round | rect | burst | ellipse | plaque | stadium | none", [the outline]),
  ("fill / stroke-colour / stroke-weight", "color | none / auto", [paint; none drops the outline]),
  ("radius / pad / width", "cm / length / auto|length|ratio", [corner, padding, width]),
  ("roughness / seed", "auto | float / auto | int", [per-box wobble]),
  ("hatch", "none | (angle, spacing)", [clipped against the real outline]),
  ("shadow", "none | color", [a soft drop shadow]),
  ("depth", "float cm  (0)", [> 0 extrudes the box]),
  ("passes / pass-offset", "int / float cm", [draw the outline N times]),
  ("curl", "float  (0.42)", [corner curl for shape: "plaque"]),
  ("breakable", "bool  (false)", [true = native stroke, can split pages]),
)

#note-line[A hand-drawn frame is one canvas of a known size, so it *cannot*
break across pages. `breakable: true` falls back to a native Typst block:
it splits correctly but loses the wobble. Prefer several shorter boxes.]

#demo(`#sketch-box(shape: "round")[round]
#sketch-box(shape: "rect")[rect]
#sketch-box(shape: "ellipse")[ellipse]`.text,
  grid(columns: (1fr, 1fr, 1fr), gutter: 0.22cm,
    sketch-box(shape: "round", width: 100%)[round],
    sketch-box(shape: "rect", width: 100%)[rect],
    sketch-box(shape: "ellipse", width: 100%)[ellipse],
  ))

== One-knob variants

#demo(`#burst[A starburst.]
#block3d[Extruded.]
#hatched[Hatched, no fill.]
#shadowed[A drop shadow.]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.28cm, row-gutter: 0.28cm,
    burst(width: 100%)[A starburst.],
    block3d(width: 100%)[Extruded.],
    hatched(width: 100%)[Hatched, no fill.],
    shadowed(width: 100%)[A drop shadow.],
  ))

#demo(`#plaque(title: [KEY TERM])[curling corners]
#pill-box[a stadium]
#double-frame[drawn twice]
#sloppy-box[four overshooting strokes]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.28cm, row-gutter: 0.28cm,
    plaque(title: [KEY TERM], width: 100%)[curling corners],
    pill-box(width: 100%)[a stadium],
    double-frame(width: 100%)[drawn twice],
    sloppy-box[four overshooting strokes],
  ))

#note-line[#cmd[sloppy-box] hugs its words when `width` is `auto` (the
default). A ratio such as `100%` is resolved against the column, not the
page.]

= Notebook card

#fn("notebook-box", `notebook-box(body, title: none, badge: none, colour: rgb("#22C55E"), …)`)

A page-within-a-page: outer shell, lighter inner page on a faint grid, a
wire binding, and a title pill that straddles the top border. The rings
follow the text direction. #cmd[notebook-box-clean] is the same with
`roughness: 0`.

#params(
  ("title / badge", "content | none", [the pill; badge gets its own rounded outline]),
  ("rings / ring-side / ring-at", "int / auto|left|right / auto|array", [count, edge, or fractions down the spine]),
  ("ring-size / ring-aspect / bead", "float cm", [loop geometry]),
  ("gap / spine / radius / grid", "float cm / auto / cm / bool", [inner page and squared paper]),
  ("roughness / bowing / seed / colour", "float / float / int / color", [wobble and paint]),
)

#demo(`#notebook-box(title: [Exercice], badge: [03],
  colour: rgb("#22C55E"))[
  Sachant que $a + b = 3$
]`.text,
  notebook-box(title: [Exercice], badge: [03],
    colour: rgb("#22C55E"), width: 100%)[
    Sachant que $a + b = 3$
  ])

#demo(`#notebook-box(title: [3 rings], rings: 3)[fewer loops]
#notebook-box(title: [right], ring-side: "right")[other edge]
#notebook-box-clean(title: [clean])[no wobble]`.text,
  {
    notebook-box(title: [3 rings], rings: 3, width: 100%)[fewer loops]
    v(0.3em)
    notebook-box(title: [right], ring-side: "right", width: 100%)[other edge]
    v(0.3em)
    notebook-box-clean(title: [clean], width: 100%)[no wobble]
  })

The torn-off pad (#cmd[notepad]), the punched filler sheet
(#cmd[ruled-sheet]) and the full-page coil (#cmd[spiral-binding]) live
in @paper and @styles.

= Furniture boxes

Boxes that look like objects rather than panels. All of them size
themselves and follow `dir`.

== Sticky notes

#fn("sticky", "sticky(body, width: 4cm, angle: −3deg, colour: auto, seed: 1)")
#fn("post-it", `post-it(body, title: none, pin: none, size: auto, …)`)

#params(
  ("pin", "none | pushpin | paperclip | tape", [how the note is fastened]),
  ("pin-colour / pins / pin-at", "color / int / auto|array", [colour, count, or explicit offsets]),
  ("size", "auto | length", [auto = at most 5 cm across]),
  ("angle", "angle  (−6deg)", [the whole note’s tilt]),
)

#demo(`#sticky[Don't forget!]
#post-it(pin: "pushpin", size: 3.3cm)[pin]
#post-it(pin: "paperclip", size: 3.3cm)[clip]
#post-it(pin: "tape", size: 3.3cm)[tape]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.3cm, row-gutter: 0.35cm, align: horizon,
    sticky[Don't forget!],
    post-it(pin: "pushpin", size: 3.3cm)[pin],
    post-it(pin: "paperclip", pin-colour: black, size: 3.3cm)[clip],
    post-it(pin: "tape", pin-colour: luma(150), size: 3.3cm)[tape],
  ))

== Ticket, folder, terminal

#fn("ticket", "ticket(body, stub: none, colour: rgb(\"#C0392B\"), width: auto, …)")
#fn("ticketbox", "ticketbox   // alias of ticket")
#fn("folder", "folder(body, title: none, colour: rgb(\"#E67E22\"), width: 100%, …)")
#fn("terminal", "terminal(body, title: none, fill: rgb(\"#1E2430\"), …)")

The leading short side carries a half-disc that sticks *out*; the
trailing side is a hole bitten *in*. Both travel with the stub under
RTL. Arabic-Indic and Persian digits become Western 0–9.

#demo(`#ticket(stub: [12])[ADMIT ONE]
#folder(title: [folder])[a tabbed file]`.text,
  grid(columns: (1fr, 1fr), gutter: 0.3cm,
    ticket(stub: [12])[ADMIT ONE],
    folder(title: [folder])[a tabbed file],
  ))
#demo(`#terminal(title: [shell])[typst compile doc.typ]`.text,
  terminal(width: 100%, title: [shell])[typst compile doc.typ])

== Vignette, neon, polaroid, spread

#fn("vignette", "vignette(title, body, colour: rgb(\"#2A6FB0\"), …)")
#fn("neon", "neon(body, colour: rgb(\"#00E5FF\"), back: rgb(\"#101018\"), …)")
#fn("polaroid", "polaroid(body, caption: none, width: auto, angle: −2deg, …)")
#fn("spread-box", "spread-box(body, spread: auto, inwards: auto, outwards: auto, …)")

#demo(`#vignette([Note], [a two-cell box])
#neon[a glowing tube]`.text,
  {
    vignette([Note], [a two-cell box])
    v(0.35em)
    neon[a glowing tube]
  })
#demo(`#polaroid(width: 3.4cm, caption: [June])[
  #box(width: 100%, height: 1.4cm, fill: rgb("#BBD3E8"))
]
#spread-box(spread: 0.3cm, title: [wide],
  colour: rgb("#2A6FB0"))[grows into the margins]`.text,
  {
    polaroid(width: 3.4cm, caption: [June])[
      #box(width: 100%, height: 1.4cm, fill: rgb("#BBD3E8"))]
    v(0.4em)
    spread-box(spread: 0.3cm, title: [wide], colour: rgb("#2A6FB0"))[
      grows into the margins]
  })

= Inline highlight

#fn("highlight", "highlight(body, colour: auto, expand: 0.14em, lift: 0.0em, seed: auto)")

A highlighter swipe behind a run of text. The stroke is sized from the
measured glyph box, so it tracks any font size.

#demo(`Text with #highlight[highlighted words]
and #highlight(colour: palette.sky)[a blue one].`.text,
  [Text with #highlight[highlighted words] and
    #highlight(colour: palette.sky)[a blue one].])

= Right-to-left

Set the direction (or use `themes.arabic`) *before* the boxes. Geometry
mirrors: tabs, side bars, folded corners, notebook rings and ticket stubs
all swap edges.

#demo(`#text(lang: "ar", dir: rtl)[
  #fabox(title: [ملاحظة], tab: "plaque",
    colour: rgb("#CCCCFF"),
    title-colour: black, back: white,
    sharp: ("all",))[
    في المثلث القائم…
  ]
]`.text,
  {
    set text(lang: "ar", dir: rtl)
    fabox(title: [ملاحظة], tab: "plaque",
      colour: rgb("#CCCCFF"), title-colour: black,
      back: white, weight: 2pt, radius: 0, sharp: ("all",), width: 100%)[
      في المثلث القائم…
    ]
  })

#note-line[No fonts are bundled. If *Tajawal* / *Lalezar* are installed they
are preferred for Arabic; otherwise DejaVu. Lalezar has no bold cut —
`heading-weight(dir)` keeps headings regular under `rtl`.]

#include "manual-extra.typ"
#include "manual-gallery.typ"

= Option index <fabox-opts>

Every named argument of #cmd[fabox], alphabetically. Types are Typst
types; `float cm` means a number of centimetres.

#let opt-row(n, t, d) = (
  text(font: MONO, size: 0.7em, n),
  text(font: MONO, size: 0.64em, fill: MUTED, t),
  text(size: 0.78em, d),
)

#block(width: 100%,
  table(
    columns: (auto, auto, 1fr),
    inset: (x: 0.38em, y: 0.28em),
    stroke: (x, y) => (bottom: 0.35pt + RULE),
    fill: (x, y) => if y == 0 { ACCENT-SOFT } else if calc.odd(y) { CODEBG } else { none },
    table.header(
      text(font: SANS, size: 0.76em, weight: "bold")[Key],
      text(font: SANS, size: 0.76em, weight: "bold")[Type],
      text(font: SANS, size: 0.76em, weight: "bold")[Default / role],
    ),
    ..(
      ("back", "color | auto", [body fill; auto = colour at 5 %]),
      ("badge", "content | none", [number box on an exercise tab]),
      ("badge-colour", "color | auto", [its colour]),
      ("baseline", "relative", [30% — inline drop]),
      ("border", "none | zigzag | wave | caution", [decorated edge]),
      ("bottom-rule", "none | float cm", [thick rule along the bottom]),
      ("bowing", "float", [0.6 — edge bow in rough mode]),
      ("chevrons", "int", [0 — fading > marks]),
      ("colour", "color", [the family colour (default red-brown)]),
      ("corner-tick", "none | float cm", [short return at the trailing corner]),
      ("dots / dotsfill / dotscolour", "auto | …", [studs of a dots tab]),
      ("ears / earsrise / earsshade", "auto | …", [scoops of an ears tab]),
      ("fold", "bool", [false — dog-ear the sheet corner]),
      ("fold-colour / fold-out / fold-size", "auto | …", [3-D ribbon / dog-ear size]),
      ("frame", "color | auto", [the outline]),
      ("frame-hidden", "bool", [false — drop the outline]),
      ("gradient-to", "color | none", [vertical body wash]),
      ("halo", "none | (r, c) | array", [glow around the frame]),
      ("icon", "content | none", [small badge on the leading title edge]),
      ("inline", "bool", [false — stay in the paragraph]),
      ("inset", "length", [0.34cm — body padding]),
      ("label-caption / label-number", "content | none", [outside caption / number block]),
      ("label-out / label-round / label-square", "auto | bool", [label-tab geometry]),
      ("plaque-rule / plaque-sharp", "bool / array", [outline the plaque; its corners]),
      ("radius", "float cm", [0.16]),
      ("rough / roughness", "bool / float", [false / 1.0]),
      ("rule-between", "bool", [true — line under the title]),
      ("seed", "int", [11]),
      ("shadow / shadow-*", "see Shadows", [drop-shadow family]),
      ("sharp", "array", [() — square corners by name, or ("all",)]),
      ("side-bar / side-bar-colour", "none | float cm / auto", [thick rule on the leading edge]),
      ("spine-*", "see spine tab", [upright side bar]),
      ("subtitles", "array", [() — ((heading, body), …)]),
      ("sweep / sweep-*", "none | float cm / …", [open U-frame]),
      ("swoosh / swoosh-*", "float / …", [InDesign banner]),
      ("tab", "none | str", [how the title is attached]),
      ("tab-offset / tab-width", "float cm / ratio", [0.5 / 45%]),
      ("tape-width / tape-period / tape-colours", "length / …", [hazard tape]),
      ("title", "content | none", [the heading]),
      ("title-colour / title-fill / title-inset / title-weight", "auto | …", [title paint and pad]),
      ("title-rule-inset / title-rule-weight", "float cm / auto", [underline of the title]),
      ("top-rule", "none | float cm", [thick rule along the top]),
      ("vignette", "none | float", [inner bevel]),
      ("watermark / watermark-colour", "content | none / auto", [faint back text]),
      ("weight", "length", [1.0pt — outline]),
      ("width", "auto | length | ratio", [100%]),
    ).map(((n, t, d)) => opt-row(n, t, d)).flatten(),
  ))

= Function index <fn-index>

#columns(2, [
  #set text(size: 0.88em)
  #set par(leading: 0.55em)

  *Setup*\
  #cmd[faboxyst] · #cmd[make-theme] · #cmd[get-theme] · #cmd[themes] · #cmd[palette]

  #v(0.45em)
  *The main box*\
  #cmd[fabox] · #cmd[fabox-sign] · #cmd[fabox-note] · #cmd[example-header]\
  #cmd[numbox] · #cmd[numbox-reset] · #cmd[iconbox]

  #v(0.45em)
  *Semantic*\
  #cmd[note] · #cmd[tip] · #cmd[warning] · #cmd[example] · #cmd[definition]

  #v(0.45em)
  *Shapes*\
  #cmd[sketch-box] · #cmd[burst] · #cmd[block3d] · #cmd[hatched] · #cmd[shadowed]\
  #cmd[plaque] · #cmd[pill-box] · #cmd[double-frame] · #cmd[sloppy-box]

  #v(0.45em)
  *Notebook and paper*\
  #cmd[notebook-box] · #cmd[notebook-box-clean] · #cmd[notepad] · #cmd[ruled-sheet]\
  #cmd[torn-note] · #cmd[stamp-card] · #cmd[grid-note] · #cmd[index-card]\
  #cmd[deckle-tag] · #cmd[lesson-card] · #cmd[sb-tape] · #cmd[spiral-binding]

  #v(0.45em)
  *Furniture*\
  #cmd[sticky] · #cmd[post-it] · #cmd[ticket] · #cmd[folder] · #cmd[terminal]\
  #cmd[vignette] · #cmd[neon] · #cmd[polaroid] · #cmd[spread-box]\
  #cmd[flag-ribbon] · #cmd[speed-bar] · #cmd[sashbox] · #cmd[ruban]

  #v(0.45em)
  *Textbook plates*\
  #cmd[crestbox] · #cmd[ribbonbox] · #cmd[helixbox] · #cmd[swooshbox]\
  #cmd[circuitbox] · #cmd[keybox] · #cmd[ringbox] · #cmd[punchbox]\
  #cmd[plannerbox] · #cmd[filebox] · #cmd[stubbox] · #cmd[stackbox]\
  #cmd[calloutbox] · #cmd[tapebox] · #cmd[chalkbox] · #cmd[markerbox]\
  #cmd[screwbox]

  #v(0.45em)
  *Inline*\
  #cmd[highlight] · #cmd[felt] · #cmd[mark] · #cmd[is-rtl]
])

= Troubleshooting

#params(
  ("boxes cannot break", "—", [a drawn frame is one canvas; breakable: true on sketch-box falls back to a plain stroke]),
  ("sloppy-box looks one-sided", "—", [a ratio is now resolved against the column; prefer width: auto to hug the words]),
  ("tape: true fails", "—", [torn-note / ruled-sheet tape is none | dict | array, never true]),
  ("holes: true fails", "—", [ruled-sheet holes is auto | int]),
  ("emoji as tofu", "—", [the package ships no colour-emoji font; pass a text icon]),
  ("RTL after a show", "—", [set text(dir: rtl) — or themes.arabic — before the boxes]),
  ("theme not applied", "—", [the show rule must wrap the boxes]),
  ("torn-note(tape: true)", "—", [tape is auto | none | dict | array]),
  ("callout white bar", "—", [fixed in 0.4.0: the chord is covered, not stroked]),
  ("numbox plaque overflow", "—", [the square is clamped to the frame height (and width)]),
  ("RTL ticket digits", "—", [ticket converts Arabic-Indic / Persian digits to 0–9]),
  ("sashbox rough invisible", "—", [pass rough: true; the ink is a closed silhouette]),
)

#v(1.2em)
#block(width: 100%, inset: (top: 0.6em), stroke: (top: 0.5pt + RULE),
  text(size: 8pt, fill: MUTED)[
    Box families follow *tcolorbox* by Thomas F. Sturm. The wobble is a
    Rough.js / TikZ sketch port with a bit-exact clone of PGF’s PRNG.
    jotter-polylux (Andreas Kröpelin, MIT) inspired the sloppy frame and
    the post-it fasteners. Optional faces if installed: xkcd Script, Bevan,
    Comic Neue, Tajawal, Lalezar (OFL).
  ])

