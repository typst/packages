#let rendering(size: (), img: image, ext-info: (:)) = {
  import "basic/bottom.typ": three-columns

  let first = ext-info.at("first", default: none)
  let second = ext-info.at("second", default: none)
  let third = ext-info.at("third", default: none)
  let background = ext-info.at("background", default: none)
  let extend-ratio = ext-info.at("extend-ratio", default: 10%)
  let extend-middle-ratio = ext-info.at("extend-middle-ratio", default: 20%)
  let inset-ratio = ext-info.at("inset-ratio", default: (top: 3%, left: 3%, right: 3%, bottom: 0%))

  let img = block(
    inset: inset-ratio,
    img,
  )

  three-columns(
    size: size,
    img: img,
    extend-content: (first, second, third),
    extend-ratio: extend-ratio,
    middle-ratio: extend-middle-ratio,
    background: background,
  )
}

