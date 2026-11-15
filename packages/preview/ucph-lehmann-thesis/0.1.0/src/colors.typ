// University of Copenhagen colour palette.
//
// RGB values: https://designguide.ku.dk/download/ku_farvepalet_rgb.pdf
// (shared with ucph-nielsine-touying, so slides and documents match).
// CMYK values for the logo red and logotype grey are taken from the official
// logo sheet (KU_CMYK.pdf). Use them when a print shop asks for CMYK.

#let white = rgb("ffffff")

/// The KU red used in the logo (RGB 144/26/30).
#let red = rgb(144, 26, 30)

/// Grey used for the "University of Copenhagen" logotype (RGB 102/102/102).
#let logotype-grey = rgb(102, 102, 102)

/// Print versions of the logo colours, from the official CMYK logo sheet.
#let print = (
  red-uncoated: cmyk(0%, 100%, 65%, 34%),
  red-coated: cmyk(25%, 100%, 77%, 40%),
  logotype-grey: cmyk(0%, 0%, 0%, 70%),
)

#let ucph-dark = (
  red: rgb("901a1E"),
  blue: rgb("122947"),
  petroleum: rgb("0a5963"),
  green: rgb("39641c"),
  grey: rgb("3d3d3d"),
  white: white,
)

#let ucph-medium = (
  red: rgb("c73028"),
  blue: rgb("425570"),
  petroleum: rgb("197f8e"),
  green: rgb("4b8325"),
  grey: rgb("666666"),
  champagne: rgb("fefaf2"),
)

#let ucph-light = (
  red: rgb("dB3B0A"),
  blue: rgb("bac7d9"),
  petroleum: rgb("b7d7de"),
  green: rgb("becaa8"),
  grey: rgb("e1dfdf"),
  yellow: rgb("ffbd38"),
)

#let palette-box(color, name, text-color: black) = rect(
  width: 100%,
  height: 3.2em,
  fill: color,
  inset: 0.6em,
  text(fill: text-color, size: 8pt, [#name\ #color.to-hex()]),
)

/// Show the full palette as a grid of swatches.
#let show-color-palette() = grid(
  columns: 5,
  gutter: 4pt,
  palette-box(ucph-dark.red, "Dark red", text-color: white),
  palette-box(ucph-dark.blue, "Dark blue", text-color: white),
  palette-box(ucph-dark.petroleum, "Dark petroleum", text-color: white),
  palette-box(ucph-dark.green, "Dark green", text-color: white),
  palette-box(ucph-dark.grey, "Dark grey", text-color: white),

  palette-box(ucph-medium.red, "Red", text-color: white),
  palette-box(ucph-medium.blue, "Blue", text-color: white),
  palette-box(ucph-medium.petroleum, "Petroleum", text-color: white),
  palette-box(ucph-medium.green, "Green", text-color: white),
  palette-box(ucph-medium.grey, "Grey", text-color: white),

  palette-box(ucph-light.red, "Light red", text-color: white),
  palette-box(ucph-light.blue, "Light blue"),
  palette-box(ucph-light.petroleum, "Light petroleum"),
  palette-box(ucph-light.green, "Light green"),
  palette-box(ucph-light.grey, "Light grey"),
)
