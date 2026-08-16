// src/hblock.typ
#let render-hblock(token, config) = {
  box(
    height: config.at("usable-height", default: auto),
    align(center + horizon, token.text),
  )
}

#let default-hblock = (
  node-renderers: (
    "hblock": render-hblock,
  ),
)
