// One catalogue card: a frame in the default look, 62 × 44 mm.
//   typst compile --root . --input style=celtic docs/_card.typ out.png
//   add  --input band=4   to force a band of 4 mm
#import "@preview/nibframe:0.3.0": *
#set page(width: 62mm, height: 44mm, margin: 0pt, fill: white)
#let band = sys.inputs.at("band", default: none)
#let style = sys.inputs.at("style", default: "classic")
#if band == none { frame-graphic(62mm, 44mm, style: style) } else { frame-graphic(62mm, 44mm, style: style, band: float(band) * 1mm) }
