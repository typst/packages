#let rendering(size: (), img: image, ext-info: (:)) = {
  import "basic/right.typ": two-rows

  let first = ext-info.at("first", default: none)
  let second = ext-info.at("second", default: none)
  let background = ext-info.at("background", default: none)
  let extend-ratio = ext-info.at("extend-ratio", default: 10%)
  let extend-half-ratio = ext-info.at("extend-half-ratio", default: 50%)

  two-rows(
    size: size,
    img: img,
    extend-content: (first, second),
    extend-ratio: extend-ratio,
    half-ratio: extend-half-ratio,
    background: background,
  )
}
