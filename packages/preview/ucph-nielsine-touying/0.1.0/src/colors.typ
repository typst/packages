// Taken from https://designguide.ku.dk/download/ku_farvepalet_rgb.pdf

#let white = rgb("ffffff")

#let ucph_dark = (
  red: rgb("901a1E"),
  blue: rgb("122947"),
  petroleum: rgb("0a5963"),
  green: rgb("39641c"),
  grey: rgb("3d3d3d"),
  white: white,
)

#let ucph_medium = (
  red: rgb("c73028"),
  blue: rgb("425570"),
  petroleum: rgb("197f8e"),
  green: rgb("4b8325"),
  grey: rgb("666666"),
  champagne: rgb("fefaf2"),
)

#let ucph_light = (
  red: rgb("dB3B0A"),
  blue: rgb("bac7d9"),
  petroleum: rgb("b7d7de"),
  green: rgb("becaa8"),
  grey: rgb("e1dfdf"),
  yellow: rgb("ffbd38"),
)

#let gradient_darks = gradient.linear(
  ucph_dark.red,
  ucph_dark.blue,
  ucph_dark.petroleum,
  ucph_dark.green,
  ucph_dark.green,
  ucph_dark.grey,
)

#let gradient_medium = gradient.linear(
  ucph_medium.red,
  ucph_medium.blue,
  ucph_medium.petroleum,
  ucph_medium.green,
  ucph_medium.green,
  ucph_medium.grey,
)

#let gradient_light = gradient.linear(
  ucph_light.red,
  ucph_light.blue,
  ucph_light.petroleum,
  ucph_light.green,
  ucph_light.green,
  ucph_light.yellow,
)


#let palette_box(color, name, text_color: black) = {
  rect(width: 7em, height: 5em, fill: color, inset: 1em, text(fill: text_color, size: 14pt, [
    #name\
    #color.to-hex()
  ]))
}

#let show_color_pallette() = {
  grid(
    columns: 5,
    rows: 3,
    palette_box(ucph_dark.red, "Dark red", text_color: white),
    palette_box(ucph_dark.blue, "Dark blue", text_color: white),
    palette_box(ucph_dark.petroleum, "Dark petroleum", text_color: white),
    palette_box(ucph_dark.green, "Dark green", text_color: white),
    palette_box(ucph_dark.grey, "Dark grey", text_color: white),

    palette_box(ucph_medium.red, "Red", text_color: white),
    palette_box(ucph_medium.blue, "Blue", text_color: white),
    palette_box(ucph_medium.petroleum, "Petroleum", text_color: white),
    palette_box(ucph_medium.green, "Green", text_color: white),
    palette_box(ucph_medium.grey, "Grey", text_color: white),

    palette_box(ucph_light.red, "Light red", text_color: white),
    palette_box(ucph_light.blue, "Light blue"),
    palette_box(ucph_light.petroleum, "Light petroleum"),
    palette_box(ucph_light.green, "Light green"),
    palette_box(ucph_light.grey, "Light grey"),
  )
}


