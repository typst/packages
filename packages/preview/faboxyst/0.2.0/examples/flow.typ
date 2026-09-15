// ===========================================================================
//  faboxyst — marks that run on, tape you can size, boxes that cross pages.
//
//    typst compile examples/flow.typ --root .
//
//  The three flow features added in 0.2.0: `mark` / `highlight` follow a
//  run over several lines, `post-it` grows `tape-wide`, and the canvas
//  boxes (`sketch-box`, `def-card`) trade their wobble for a native frame
//  when you ask for `breakable: true`.
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(width: 15cm, height: 24cm, margin: 9mm, fill: white)
#set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 10.5pt)
#set par(leading: 0.64em)

// ---------------------------------------------------------------------------
= Marks over several lines

A mark is a pen stroke measured around its words — but words run on. Past
a single line, #raw("mark") and #raw("highlight") hand the run to the
native per-line elements, so every fragment stays covered:

#v(0.2cm)
Consider #mark[the long passage that cannot possibly fit on one single
line of this paragraph and therefore has to keep its highlight on every
following fragment, right to the end] — the swipe follows each line.

#v(0.3cm)
A ring works the same way: #mark(kind: "circle", colour: rgb("#C0392B"))[
this sentence is wrapped in a loose red ring although it runs over two
lines of the paragraph without breaking the layout around it].

#v(0.3cm)
And the rules keep their shape per line:
#mark(kind: "wave", colour: rgb("#2A6FB0"))[a wave under every fragment
of this run], then #mark(kind: "double", colour: rgb("#1F6F4A"))[a double
rule under each line of this second, equally long, run of words].

#v(0.3cm)
The blocks marker joins in: #highlight[the fat translucent jotter swipe
also covers a run of text that spans several lines, line fragment after
line fragment, instead of clipping to a single inline box].

// ---------------------------------------------------------------------------
= Tape, sized

#raw("tape-len") sets how long a strip runs; #raw("tape-wide") (new) sets
how wide it is — a packing-tape parcel or a discreet hinge:

#v(0.3cm)
#block(breakable: false, width: 100%, grid(columns: (auto, auto), column-gutter: 0.6cm, row-gutter: 0.5cm, align: top,
    post-it(pin: "tape", tape-len: 0.7, tape-wide: 0.22, angle: -3deg)[
      a discreet hinge
    ],
    post-it(pin: "tape", tape-len: 1.0, tape-wide: 0.45, angle: -3deg)[
      ordinary masking tape
    ],
    post-it(pin: "tape", tape-len: 1.3, tape-wide: 0.8, angle: -3deg)[
      a parcel taped shut
    ],
  )
  )

// ---------------------------------------------------------------------------
= Boxes that cross pages

A hand-drawn frame is one canvas of a fixed size: it cannot be split.
With #raw("breakable: true") the box swaps it for a native stroke that
can — the wobble is lost, the content flows:

#v(0.2cm)
#def-card(breakable: true, [Breakable definition], [
  #lorem(95)
])

#v(0.2cm)
#sketch-box(breakable: true, shape: "round")[
  #lorem(45)
]

// ---------------------------------------------------------------------------
= Ribbons and sashes sit on the frame

The flagbox ribbon now seats its foot on the top rule instead of floating
above it, and the ornate sash defaults to an ogee S-curve at both ends:

#v(0.2cm)
#flagbox(title: [Seated ribbon], colour: rgb("#E0A100"))[
  The rod lies astride the top rule and the banner hangs into the box; the body starts
  clear of it.
]

#v(0.35cm)
#ornatebox(title: [Default ogee sash], edge: "rosette", corner: "scroll")[
  No `caps` argument here: the band ends in the new default ogee curve at
  both ends.
]
