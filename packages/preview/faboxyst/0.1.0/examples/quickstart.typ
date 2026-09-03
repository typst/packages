// ===========================================================================
//  faboxyst — 30-second smoke test
//
//    typst compile examples/quickstart.typ examples/quickstart.pdf --root .
// ===========================================================================

#import "/lib.typ": *

#set page(width: 16cm, height: auto, margin: 10mm)
#set text(font: "DejaVu Sans", size: 10.5pt)
#set par(leading: 0.62em)

#show: faboxyst.with(theme: themes.notebook)

= faboxyst #text(size: 0.7em, fill: luma(90))[v0.1.0]

#fabox(title: [Note])[A titled coloured box — the workhorse.]

#v(0.45em)
#grid(columns: (1fr, 1fr), gutter: 0.35cm,
  tip[A semantic tip.],
  warning[Never divide by zero.],
)

#v(0.45em)
#numbox-reset()
#numbox[A one-line question — the plaque matches the frame.]
#numbox[
  A taller question keeps the requested plaque size because the
  frame is already deeper than the square.
][The optional answer block.]

#v(0.45em)
#ribbonbox(title: [Example])[A yellow plate with a blue band.]

#v(0.45em)
#grid(columns: (1fr, 1fr), gutter: 0.35cm,
  punchbox(title: [Example], number: [1])[Punched header.],
  screwbox(tl: 20deg, br: -15deg)[A plaque held by screws.],
)

#v(0.45em)
#sashbox(kind: "arch", fill: rgb("#FF9EC8"))[Welcome]

#v(0.45em)
#chalkbox(title: [Lemma])[$ a^2 + b^2 = c^2 $]
