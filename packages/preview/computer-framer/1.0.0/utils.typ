#let load-icon(path, fill-color: white.transparentize(100%), stroke-color:black) = {
  if fill-color == none {
    fill-color = black.transparentize(100%)
  }
  if stroke-color == none {
    stroke-color = black.transparentize(100%)
  }
  let icon-text = read(path)
  icon-text = icon-text.replace("fill:#000000", "fill:" + fill-color.to-hex())
  icon-text = icon-text.replace("stroke:#000000", "stroke:" + stroke-color.to-hex())
  return bytes(icon-text)
}