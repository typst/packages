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

// Guilloche lace and the banknote frame — included by manual.typ after
// manual-ornate.typ.

#heading(level: 2)[Guilloche lace: #cmd[lacebox] and the #cmd[lace] parameter]

The guilloche cover draws its field with one of four line families, and
the same four dress a box of their own. All of them live in
#cmd[src/lace.typ] and are exported as #cmd[lace(pattern, w, h, paint,
thickness:)] for anyone who wants the raw drawing.

#params(
  ("pattern", "str", [one of #raw("spiral") (the banknote whirl of cubic
   sweeps), #raw("engine") (barleycorn: close circles crossed by spokes),
   #raw("braid") (two phased families of woven cubic waves) or
   #raw("moire") (two interfering circle families)]),
)

#fn("lacebox", `body, title: none, lace: "spiral", model: "band", colour: rgb("#1B2A41"), fill: white, band: 1.15cm, weight: 1pt, inset: 0.4cm, width: 100%, direction: auto, rough: 0, ornament: none, ornament-family: "vectorian"`)

A picture-frame box in the manner of a banknote: the chosen lace is drawn
over the whole field and a panel in #raw("fill") is laid over its middle, so
the guilloche survives only as a border band; rosettes sit in the four
corners of the band and the #raw("title") rides a plaque straddling the
panel's top rule.

#params(
  ("lace", "str", [the line family of the border band]),
  ("model", "str", [the frame model: #raw("band") (a plain lace band),
    #raw("double") (a second lace ring inside the panel rule),
    #raw("scallop") (the panel edge waves in scallops) or
    #raw("corners") (no band: a double rule and ray-and-arc fans)]),
  ("band", "length", [the frame's width — how deep the lace border runs;
    the rosettes scale with it]),
  ("colour", "color", [the ink of lace, rules, rosettes and plaque]),
  ("fill", "color", [the panel and sheet colour]),
  ("inset", "length", [clear space between panel rule and body]),
  ("direction", "auto | rtl | ltr", [forces the body's reading direction]),
  ("rough", "number", [#raw("0") keeps the engraved rules crisp; any value
    above 0 redraws every straight rule — outer, panel, inner ring, plaque
    — with the sketchbook's felt-tip wobble, e.g. #raw("rough: 1.2")]),
  ("ornament", "int | none", [a pgfornament number (see below) seated,
    mirrored, in the four corners of the frame instead of the rosettes or
    the ray fans]),
  ("ornament-family", "str", [the family of that ornament:
    #raw("vectorian"), #raw("han") or #raw("am")]),
)

#demo(`#lacebox(title: [Moiré], lace: "moire",
         colour: rgb("#14424B"))[Deux trames superposées
         interfèrent : l'effet moiré des billets.]`,
  lacebox(title: [Moiré], lace: "moire",
    colour: rgb("#14424B"))[Deux trames superposées
    interfèrent : l'effet moiré des billets.])

#demo(`#lacebox(title: [Main levée], lace: "engine", rough: 1.2,
         ornament: 64, colour: rgb("#14424B"))[
         Les filets oscillent comme au tire-ligne, et le fleuron
         vectorian 64 siège, miroité, dans les quatre coins.]`,
  lacebox(title: [Main levée], lace: "engine", rough: 1.2,
    ornament: 64, colour: rgb("#14424B"))[
    Les filets oscillent comme au tire-ligne, et le fleuron
    vectorian 64 siège, miroité, dans les quatre coins.])

On the cover side, #cmd[book-cover] takes the same four families through
its #raw("lace") parameter when the style is #raw("guilloche"):

#demo(`#book-cover(style: "guilloche", lace: "braid",
         title: [حواضر البحر], …)`,
  block(width: 100%, inset: 0.4em, fill: CODEBG, radius: 2pt,
    stroke: 0.45pt + RULE,
    text(size: 0.8em, fill: MUTED)[see #cmd[examples/lace.typ] — three
      full plates draw #raw("engine"), #raw("moire") and #raw("braid").]))

#heading(level: 2)[Engraved ornaments: #cmd[pgfornament]]

The whole ornament bank of the CTAN package #cmd[pgfornament] (Alain
Matthes, LPPL 1.3 — original idea of F. Fradin and H. Voss, #raw("han")
family by LIM LianTze) is ported to Typst curves: 196 #raw("vectorian")
pieces, 78 #raw("han") and 2 #raw("am"), each drawn at any width from its
own path data in #cmd[src/pgfornament.typ].

#fn("pgfornament", `n, family: "vectorian", width: 1.2cm, paint: black, thickness: 0.5pt`)

#params(
  ("n", "int", [the ornament's number inside its family — 1–196 for
    #raw("vectorian"), 1–78 for #raw("han"), 1–2 for #raw("am")]),
  ("family", "str", [#raw("vectorian") (the classical banknote fleurons),
    #raw("han") (Chinese knots, meanders, clouds) or #raw("am")]),
  ("width", "length", [the drawn width; the height follows the engraving's
    own ratio]),
  ("paint", "color", [fill and outline ink of the piece]),
  ("thickness", "length", [outline weight — the fill carries most pieces]),
)

#demo(`#pgfornament(6, width: 1.4cm) #h(0.5cm)
       #pgfornament(64, width: 1.4cm) #h(0.5cm)
       #pgfornament(88, width: 1.4cm) #h(0.5cm)
       #pgfornament(58, family: "han", width: 1.4cm,
         paint: rgb("#8A2A1B"))`,
  [#pgfornament(6, width: 1.4cm) #h(0.5cm)
   #pgfornament(64, width: 1.4cm) #h(0.5cm)
   #pgfornament(88, width: 1.4cm) #h(0.5cm)
   #pgfornament(58, family: "han", width: 1.4cm, paint: rgb("#8A2A1B"))])

Two documented deviations from the LaTeX original: paths used as a clip
(#raw("\\i")) or as a bounding box (#raw("\\ubb")) are not drawn — Typst
has no arbitrary path clipping — so a clipped piece renders in full
instead of masking its neighbours. Everything else, fills, outlines and
mirroring, follows the source streams exactly.

// ===========================================================================
//  Page frames, live
// ===========================================================================

= Page frames, live <pageframes>

Every frame family also ships a page-frame twin — #cmd[coil-pages],
#cmd[volute-pages], #cmd[plank-pages], #cmd[torn-pages],
#cmd[rosette-pages], on top of #cmd[ornate-pages] shown earlier. Called
with their content as argument (or as a `#show:` rule for a whole
document), they seat the frame on exactly the pages that content lands
on. The next pages run each of them for one page, spiral included.

#pagebreak()
#coil-pages[
== The spiral notebook — coil-pages

  The punched spine and its blue coils run down the leading edge of
  every page of this scope; `spine-gap` reserves the gutter and `rtl`
  moves the spiral to the right edge.

  #v(0.6em)
  #notebook-box(title: [Cours])[Une boîte cahier posée sur la page
  spirale : les marges viennent du cadre lui-même.]

  #v(0.6em)
  Any box of the package can live here; the frame is a page background,
  so breaks, footnotes and floats behave as usual.
]

#pagebreak()
#volute-pages[
== The stationery volute — volute-pages

  The blush chamfered double rule with ink volutes at the four corners,
  drawn at page size behind the text. `margin` and `gap` set how far the
  frame sits from the paper edge and from the text block.

  #v(0.6em)
  #volutebox[*Courrier.* — le même cadre, en boîte cette fois.]
]

#pagebreak()
#plank-pages[
== The wooden sign — plank-pages

  The hand-split planks frame the whole page; the grain, knots and bark
  outline are the same vectors as the box version.

  #v(0.6em)
  #plankbox(title: [Attention])[Cadre planche et boîte planche partagent
  la même palette #cmd[plank-colours].]
]

#pagebreak()
#torn-pages[
== Torn paper — torn-pages

  A deckle-edged sheet with its rolled top cylinder seats the text block
  on every page of the scope; `depth` and `amp` refine the torn edge.

  #v(0.6em)
  #tornpage(title: [Brouillon])[La version boîte, pour un seul
  paragraphe.]
]

#pagebreak()
#rosette-pages(margin: 1cm)[
== The dedication rosette — rosette-pages

  The triple rule, interlaced corner curves, sage leaves, eight-petal
  rosettes, diamond rows and centre medallions of the dedication sheet,
  at page size. The ornament scale follows the page, and the same frame
  boxes content with #cmd[rosettebox].

  #v(0.6em)
  #rosettebox(title: [Édition])[Le cadre dédicace en boîte adaptative.]
]
