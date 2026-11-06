// Taken from https://designguide.ku.dk/download/ku_farvepalet_rgb.pdf

#let white = rgb("ffffff")

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

#let gradient-darks = gradient.linear(
  ucph-dark.red,
  ucph-dark.blue,
  ucph-dark.petroleum,
  ucph-dark.green,
  ucph-dark.green,
  ucph-dark.grey,
)

#let gradient-medium = gradient.linear(
  ucph-medium.red,
  ucph-medium.blue,
  ucph-medium.petroleum,
  ucph-medium.green,
  ucph-medium.green,
  ucph-medium.grey,
)

#let gradient-light = gradient.linear(
  ucph-light.red,
  ucph-light.blue,
  ucph-light.petroleum,
  ucph-light.green,
  ucph-light.green,
  ucph-light.yellow,
)


#let palette-box(color, name, text-color: black) = {
  rect(width: 7em, height: 6em, fill: color, inset: 1em, text(fill: text-color, size: 14pt, [
    #name\
    #color.to-hex()
  ]))
}

#let show-color-pallette() = {
  grid(
    columns: 5,
    rows: 3,
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
}


