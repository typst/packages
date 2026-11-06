#let rendering(size: (), img: image, ext-info: (:)) = {
  import "basic/right.typ": three-rows

  let first = ext-info.at("first", default: none)
  let second = ext-info.at("second", default: none)
  let third = ext-info.at("third", default: none)
  let background = ext-info.at("background", default: none)
  let extend-ratio = ext-info.at("extend-ratio", default: 10%)  
  let extend-middle-ratio = ext-info.at("extend-middle-ratio", default: 20%)
  let inset-ratio = ext-info.at("inset-ratio", default: (top: 3%, left: 3%, right: 0%, bottom: 3%))

  let img = block(
    inset: inset-ratio,
    img,
  )

three-rows(
    size: size,
    img: img,
    extend-content: (first, second, third),
    extend-ratio: extend-ratio,
    middle-ratio: extend-middle-ratio,
    background: background,
  )
}

