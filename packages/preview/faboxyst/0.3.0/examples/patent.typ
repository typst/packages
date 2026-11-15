// faboxyst 0.3.0 — the patent page of the antique vintage effect.
//   #show: brevet.with(...)  — the patent-page show rule
#import "@preview/faboxyst:0.3.0": *

#show: brevet.with(
  office: [Bureau des Brevets — Alger],
  title: [Amélioration de la plume gravée],
  subtitle: [Procédé pour faire varier l'épaisseur de l'encre],
  number: [N° 0012 345],
  date: [14 mars 1902],
)
#show: faboxyst.with(theme: themes.antique)

It is hereby declared that the present invention consists in carrying an
elliptical nib along the path of the intended stroke, the major axis of the
nib being kept at an angle of about twenty-four degrees to the tangent, so
that the mark left by the pen is thin when the nib runs with the line and
full when it is crossed.

#v(0.8em)

#fabox(title: [Premier mode d'exécution], colour: antique-palette.patent-ink)[
  The frame is drawn twice: a heavy outer rule and a thinner inner rule, the
  two being the envelopes of the same nib at two weights. A small diamond is
  placed at each outer corner.
]

#v(0.6em)

#grid(columns: (auto, auto), column-gutter: 18pt, align: center + horizon,
  tip[The dashed variant is obtained by alternating the nib and the paper —
  the dash length, the offset, a jitter and a seed are all parameters.],
  warning[Pressure is a periodic modulation of the minor axis between a
  minimum value and the full width; the period is set in length units.],
)

#v(0.8em)

#set par(justify: true)
The same device, applied to a full page, yields the plates and patents in
which the present boxes are commonly displayed: aged paper
(#raw("#F5EDDF")), patent ink (#raw("#221E1A")), Garamond body at ten
points, justified, with a leading of #raw("0.62em"). No colour is used
beyond the ink and the paper; the pale ink (#raw("#786A58")) may be employed
for rules and captions that are meant to fade.

#v(0.8em)

#antique-notes(
  antique-note([Plate I], [See #raw("examples/antique.typ") for the plate style and its engraving primitives.]),
  antique-note([N° 0012 345], [The number and the date are printed in smallcaps at the top right of the sheet.]),
)
