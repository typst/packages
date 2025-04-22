#import "/src/lib.typ": *
#import "@preview/cetz:0.3.4"

#set page(width: auto, height: auto, margin: (y: 2cm, bottom: 1cm), fill: white)
#set text(24pt)

#let rmark = mark.with(color: red)
#let bmark = mark.with(color: blue)
#let pmark = mark.with(color: purple)

$
  ( rmark(a x, tag: #<ax>) + bmark(b, tag: #<b>) )
  ( rmark(c x, tag: #<cx>) + bmark(d, tag: #<d>) )
  =
  rmark(a c x^2)
  + pmark((a d + b c) x)
  + bmark(b d)
$

#annot-cetz(
  (<ax>, <b>, <cx>, <d>),
  cetz,
  {
    import cetz.draw: *

    set-style(mark: (end: "straight"))
    bezier-through("ax.south", (rel: (x: 1, y: -.5)), "cx.south", stroke: red)
    bezier-through("ax.south", (rel: (x: 1, y: -1)), "d.south", stroke: purple)
    bezier-through("b.north", (rel: (x: .6, y: .5)), "cx.north", stroke: purple)
    bezier-through("b.north", (rel: (x: .6, y: 1)), "d.north", stroke: blue)
  },
)
