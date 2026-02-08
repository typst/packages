#let rendering(size: (), img: image, ext-info: (:)) = {
  import "basic/bottom.typ": two-columns

  let first = ext-info.at("first", default: none)
  let second = ext-info.at("second", default: none)
  let background = ext-info.at("background", default: none)
  let extend-ratio = ext-info.at("extend-ratio", default: 10%)
  let extend-half-ratio = ext-info.at("extend-half-ratio", default: 50%)
  let inset-ratio = ext-info.at("inset-ratio", default: (top: 3%, left: 3%, right: 3%, bottom: 0%))

  let img = block(
    inset: inset-ratio,
    img,
  )

  two-columns(
    size: size,
    img: img,
    extend-content: (first, second),
    extend-ratio: extend-ratio,
    half-ratio: extend-half-ratio,
    background: background,
  )
}

