// src/vblock.typ
#let render-vblock(token, config) = {
  box(
    height: config.at("usable-height", default: auto),
    align(center + horizon, rotate(90deg, reflow: true, token.text)),
  )
}

#let default-vblock = (
  node-renderers: (
    "vblock": render-vblock,
  ),
)
