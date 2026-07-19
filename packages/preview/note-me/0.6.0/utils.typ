#let accessible-icon(
  data,
  alt: auto,
  ..args,
) = {
  if alt == auto {
    image(bytes(data), ..args)
  } else if alt == none {
    pdf.artifact(image(bytes(data), ..args))
  } else {
    assert.eq(type(alt), str, "`alt` must be either `auto`, `str`, or `none`")
    image(bytes(data), alt: alt, ..args)
  }
}
