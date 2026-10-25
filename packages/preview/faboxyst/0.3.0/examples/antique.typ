// faboxyst 0.3.0 — the antique vintage effect (engraved strokes drawn with nibart):
// aged paper, sepia ink, Garamond, and strokes drawn by an elliptical nib.
//
//   #show: planche.with(...)      — the plate-page show rule
//   #show: faboxyst.with(theme: themes.antique)  — restyle every box
#import "@preview/faboxyst:0.3.0": *
#import "@preview/cetz:0.5.2"

#show: planche.with(
  number: [Plate I],
  title: [L'effet antique],
  subtitle: [papier vieilli, encre sépia, traits gravés à la plume elliptique],
)
#show: faboxyst.with(theme: themes.antique)

// --- the engraved frame -----------------------------------------------------
#engraved-frame[
  The text is set in Garamond on aged paper (#raw("#F3EAD9")) with near-black
  sepia ink (#raw("#272119")). The double rule is not a line of constant
  width: it is the envelope of an elliptical nib carried along the rectangle,
  so the stroke thickens where the pen is crossed and thins where it runs
  with the tangent — as in a steel engraving.
]

#v(1.0em)

// --- the theme restyles the box families ------------------------------------
#fabox(title: [Boîte antique], colour: antique-palette.pale-ink)[
  This `fabox` is drawn by the usual sketch engine, but `themes.antique`
  replaced its palette with the sepia one, its fonts with the Garamond stack
  and its wobble with a nearly-straight engraved stroke; the ink above is
  just its `colour` parameter, set to the pale plate ink.
]

#v(0.6em)

#antique-notes(
  antique-note([Ink], [Near-black sepia, #raw("#272119"); the paler companion is #raw("#786A58").]),
  antique-note([Paper], [Aged cream, #raw("#F3EAD9"); the patent variant is #raw("#F5EDDF").]),
  antique-note([Nib], [Elliptical, 24° to the tangent; the thickness follows the path.]),
)

#v(0.8em)

// --- a small drawing, engraved and labelled ---------------------------------
#cetz.canvas(length: 1cm, {
  let arc = {
    range(49).map(i => {
      let a = (200 + 160 * i / 48) * 1deg
      (4.0 + 2.6 * calc.cos(a), 3.2 + 2.6 * calc.sin(a))
    })
  }
  engraved(polyline-path(arc))
  engraved(nib-line-path((0.6, 3.2), (7.4, 3.2)), width: 0.012)
  engraved(nib-rect-path(2.2, 1.4, 5.8, 4.4), width: 0.014)
  etiquette-gravee((6.9, 1.6), [arc de 160°])
  etiquette-gravee((1.0, 4.9), [règle])
})
#legende-figure[Fig. 1 — Engraving primitives: #raw("engraved") through the nibart pens, #raw("etiquette-gravee") for labels.]

// ---------------------------------------------------------------------------
//  Page 2 — the rest of the family, in the antique theme
// ---------------------------------------------------------------------------
#pagebreak()

#align(center, block(width: 12cm,
  cadre-vintage(style: "fleuron", ink: antique-palette.ink)[Chapitre II — les traits]))
#v(0.5em)

#set par(justify: true)
The same components of 0.2.0 keep working, only the inks change. The
scrollwork frame below is the 0.2.0 `cadre-vintage` drawn in the plate's ink;
the plaque is a `vintagebox` on the plate's paper.

#v(0.6em)

#grid(columns: (auto, auto), column-gutter: 18pt, align: center + horizon,
  block(width: 11cm, vintageframe(style: "hooks", ink: antique-palette.ink)[Volute et rai]),
  vintagebox(variant: "banniere", width: 8.5cm, height: 2.4cm,
    ink: antique-palette.ink,
    shadow: rgb("#D9CFBA"))[MAISON 1902],
)

#v(0.8em)

Rules can be engraved too — constant width, dashed, or with a pressure
breath that makes the line swell periodically:

#v(0.3em)

#engraved-rule(from: (0pt, 0pt), to: (15.5cm, 0pt))
#v(0.55em)
#engraved-rule(from: (0pt, 0pt), to: (15.5cm, 0pt),
  dash: (lengths: (0.55, 0.25)))
#v(0.55em)
#engraved-rule(from: (0pt, 0pt), to: (15.5cm, 0pt),
  pressure: (minimum-axis: 0.55, period: 9mm, seed: 2))
#v(0.55em)
#engraved-rule(from: (0pt, 0pt), to: (15.5cm, 0pt),
  weight: 0.009, ink: antique-palette.pale-ink)
#v(0.4em)

#legende-figure[Fig. 2 — #raw("regle-gravee") : plain, dashed, pressured, pale.]
