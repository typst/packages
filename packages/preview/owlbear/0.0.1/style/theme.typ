#import "fonts.typ": font

#let colors = (
  red: rgb(121, 59, 47),
  red-light: rgb(181, 79, 66),
  yellow: rgb(209, 163, 71),
  yellow-light: rgb(234, 200, 137),
  yellow-start: rgb(222,192,133,50%),
  yellow-end: rgb(222,192,133,0),
  yellow-half: rgb(244, 232, 209),
  ochre: rgb(222, 192, 133),
  orange: rgb(235, 214, 193),
  blue-light: rgb(241, 247, 249),
  blue: rgb(215, 232, 238),
  blue-dark: rgb(71, 114, 128),
)

#let book-theme = (gradients: true) => (
  paint: (
    chapter: (
      number: (
        fill: colors.orange,
      ),
      heading: (
        fill: gradient.linear(colors.red, colors.red-light, angle: 90deg),
        stroke: colors.red,
      ),
    ),
    dialogue: (
      fill: colors.yellow-half,
    ),
    dropcap: (
      fill: gradient.linear(colors.yellow, colors.yellow-light, angle: 90deg),
      stroke: colors.yellow,
    ),
    heading: (
      fill: colors.red,
      line: colors.yellow,
    ),
    label: (
      dm: (
        fill: colors.red,
      ),
      player: (
        fill: colors.blue-dark,
      ),
    ),
    table: (
      even: colors.blue,
      odd: colors.blue-light,
    ),
  ),
  font: font,
)