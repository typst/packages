#let aspect-ratio(it) = {
  let dims = measure(it)
  dims.at("width") / dims.at("height")
}

// see also https://github.com/typst/typst/issues/3147
#let clip-image(
  img-file,
  img-width: auto, img-height: auto,
  dx: 0pt, dy: 0pt,
  alignment: left + top, fit: "contain",
  ..args
) = context(box(
  clip: true,
  ..args,
  {
    align(alignment, {move(dx: dx, dy: dy,
    image(
      img-file, fit: fit,
      height: if img-height != auto {img-height}
        else {img-width / aspect-ratio(image(img-file))},
      width: if img-width != auto {img-width}
        else {img-height * aspect-ratio(image(img-file))},
    ),
  )})},
))
