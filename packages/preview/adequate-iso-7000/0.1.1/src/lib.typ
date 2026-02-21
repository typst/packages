#import "icons.typ": _data

#let _iso-7000-svg(name) = {
  ()
}

#let iso-7000(name, color: rgb("#000"), ..args) = {
  let img = (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" role=\"graphics-symbol\" aria-hidden=\"true\" focusable=\"false\" "
      + _data.at(name)
      + "</svg>"
  )
  let img = img.replace("#000", color.to-hex())
  image(
    bytes(img),
    alt: name,
    format: "svg",
    ..args,
  )
}
