
/*#import "lib.typ": fit-to-width*/
#import "@local/one-liner:0.1.0": fit-to-width

useful for slides or titles use full width
Things that need to be as big as possible to grab attention.
#block(
  height: 3cm,
  width: 10cm,
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  align(horizon + center,fit-to-width(lorem(2))),
)

as the size of the text becomes bigger the font size decreases too still make it fit in the width.
#block(
  height: 3cm,
  width: 10cm,
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  align(horizon + center,fit-to-width(lorem(20))),
)

There are default limits, because text becomes illegible when text becomes too small in this cases shrinking stops at 4pt.
In this case text starts wrapping.
#block(
  height: 3cm,
  width: 10cm,
  fill: luma(230),
  inset: 8pt,
  clip: true,
  radius: 4pt,
  fit-to-width(align(top + left,lorem(2000))),
)

There is also a default max size, which you can override as done here: 100pt.
#block(
  height: 3cm,
  width: 10cm,
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  fit-to-width(max-text-size: 100pt, align(horizon + center)[A]),
)

#align(center + bottom ,fit-to-width( max-text-size: 70pt,   upper[_experiment_]))

#fit-to-width[] /*test case to see what happens if you add empty content*/
