
#import "@preview/one-liner:0.3.0": *
//#import "@local/one-liner:0.3.0": *

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
  fit-to-width(min-text-size: 4pt,align(top + left,lorem(1000))),
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

#fit-to-width[] /*test case to see what happens if you add empty content*/

If there is a fixed height, it will also take that into consideration.
#block(
  height: 0.3cm,
  width: 10cm,
  fill: luma(230),
  inset: 0pt,
  radius: 4pt,
  align(horizon + center,fit-to-width(lorem(2))),
)
When you can use auto for height.
#block(
  height: auto,
  width: 10cm,
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  align(horizon + center,fit-to-width(lorem(2))),
)

Sometimes you want textsize to increase when space is available, but not become smaller. Then you can use grow-to-width.
This can put more emphasis on this text.
#block(
  height: auto,
  width: 10cm,
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  align(horizon + center,grow-to-width(lorem(2))),
)

Sometimes you want textsize to decrease when space is available, but not become bigger. Then you can use shrink-to-width. If it must fit on the one line.
#block(
  height: auto,
  width: 10cm,
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  align(horizon + center,shrink-to-width(lorem(10))),
)




