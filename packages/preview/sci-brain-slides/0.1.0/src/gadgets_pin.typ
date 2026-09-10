// sci-brain-slides . pinit gadgets (optional, requires @preview/pinit)
// ======================================================================
// Pin annotations onto figures or text: drop inline pin markers, then attach
// highlights and pointing notes that float to the right place on the slide.
// Highlight and arrow colours come from the palette (pinit's defaults are red).
//
//   #import "@preview/sci-brain-slides:0.1.0": pin-gadgets as make
//   #let P = make(palette)
//   A simple #P.pin(1)highlighted phrase#P.pin(2).
//   #P.highlight(1, 2)
//   #P.note(2)[And a note pointing at it.]

#import "@preview/pinit:0.2.2": pin, pinit-highlight, pinit-point-from
#import "scale.typ": sizes as default-sizes

#let make(pal, sizes: default-sizes) = (
  // Drop an inline pin marker. Wrap content between two pins to highlight a span.
  "pin": (id) => pin(id),

  // Highlight the span between two (or more) pin ids, in the accent colour.
  "highlight": (..ids) => pinit-highlight(..ids, fill: pal.accent.transparentize(82%)),

  // A pointing note attached to a pin; arrow and box follow the palette.
  "note": (id, body, dx: 35pt, dy: 35pt) => pinit-point-from(
    id, offset-dx: dx, offset-dy: dy, fill: pal.accent,
  )[
    #block(radius: 3pt, inset: 7pt,
      fill: color.mix((pal.accent, 12%), (pal.paper, 88%)),
      stroke: 0.5pt + pal.accent,
      text(sizes.normal, fill: pal.text)[#body])
  ],
)
