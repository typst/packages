#import "../src/lib.typ": dropcap

#set text(size: 14pt)
#set page(
  width: 8cm,
  height: auto,
  margin: 1em,
  background: box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
  ),
)

#dropcap(
  height: 2,
  justify: true,
  gap: 6pt,
  transform: letter => style(styles => {
    let height = measure(letter, styles).height

    grid(columns: 2, gutter: 6pt,
      align(center + horizon, text(blue, letter)),
      // Use "place" to ignore the line's height when
      // the font size is calculated later on.
      place(horizon, line(
        angle: 90deg,
        length: height + 6pt,
        stroke: blue.lighten(40%) + 1pt
      )),
    )
  }),
  lorem(21)
)
