// # Quotes. Citações.
// NBR 14724:2024 5.5, NBR 10520:2023 7.1.1.

#import "../style/style.typ": (
  font_size_for_common_text, font_size_for_smaller_text, leading_for_common_text, simple_leading_for_smaller_text,
  simple_spacing_for_smaller_text, spacing_for_common_text,
)

#let format_quote(
  indent: true,
  smaller_text: true,
  body,
) = {
  let font_size = font_size_for_common_text
  let leading = leading_for_common_text
  let spacing = spacing_for_common_text

  // Long quotes should have a smaller font size than the main text.
  if smaller_text {
    font_size = font_size_for_smaller_text
    leading = simple_leading_for_smaller_text
    spacing = simple_spacing_for_smaller_text
  }

  set text(
    size: font_size,
  )
  set par(
    leading: leading,
    spacing: spacing,
  )

  block(
    above: spacing,
    below: spacing,
    breakable: true,
    pad(
      // Long quotes should have a 4cm space on the left side.
      left: if indent {
        4cm
      } else {
        0cm
      },
    )[
      #body.body
      #if body.attribution != none [#body.attribution]
    ],
  )
}
