// # Equation. Equação.
// NBR 14724:2024 5.7

#import "../util/font_family.typ": font_family_for_math_text_state

#let equation(
  placement: none,
  width: auto,
  body,
) = context {
  set text(
    font: font_family_for_math_text_state.get(),
  )
  set math.equation(numbering: "(1.1)")

  let equation_block = align(
    center,
    block(
      sticky: true,
      width: width,
      align(
        start,
        body,
      ),
    ),
  )

  if placement == none {
    equation_block
  } else {
    let alignment = if (
      placement == auto
    ) {
      auto
    } else if (placement == top or placement == bottom) {
      placement + center
    } else {
      panic("Placement should be one of the following options: none, auto, top, bottom.")
    }
    place(
      alignment,
      float: true,
      equation_block,
    )
  }
}
