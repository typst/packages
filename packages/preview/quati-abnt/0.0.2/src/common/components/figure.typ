// # Figures. Figuras.
// NBR 14724:2024 5.8, NBR 14724:2024 5.9

#import "../style/style.typ": (
  font_size_for_common_text, font_size_for_smaller_text, leading_for_common_text, simple_leading_for_smaller_text,
  simple_spacing_for_smaller_text, spacing_around_figure, spacing_for_common_text,
)
#import "./figure_footer.typ": figure_footer

#let format_caption_of_figure(
  width: auto,
  it,
) = {
  // NBR 14724:2024 5.8
  // The caption of a figure should be in the same font size as the common text
  set text(
    size: font_size_for_common_text,
  )
  set par(
    leading: leading_for_common_text,
    spacing: spacing_for_common_text,
  )
  it
}

#let format_information_of_figure(
  note: none,
  source: none,
) = context {
  // NBR 14724:2024 5.8
  // Source and notes should be in a smaller font size
  set par(
    first-line-indent: 0cm,
    leading: simple_leading_for_smaller_text,
    spacing: simple_spacing_for_smaller_text,
  )
  set text(
    size: font_size_for_smaller_text,
  )
  // Source and notes should be aligned to the left
  set align(start)

  block(
    above: simple_spacing_for_smaller_text,
    below: simple_spacing_for_smaller_text,
  )[
    #figure_footer(
      note: note,
      source: source,
    )
  ]
}

#let include_information_of_figure(
  note: none,
  source: none,
  width: auto,
) = {
  set align(center)
  block(
    above: spacing_for_common_text,
    below: spacing_for_common_text,
    width: width,
  )[
    #format_information_of_figure(
      source: source,
      note: note,
    )
  ]
}

#let format_figure(
  include_information: false,
  note: none,
  source: none,
  sticky: false,
  it,
) = {
  layout(
    size => {
      let width_of_figure_body = measure(
        width: size.width,
        it.body,
      ).width

      block(
        breakable: true,
        sticky: sticky,
        width: 100%,
      )[
        // The caption of a figure should be on top of the figure.
        #block(
          sticky: true,
          width: width_of_figure_body,
          below: spacing_for_common_text,
          format_caption_of_figure(
            it.caption,
          ),
        )

        #show figure: it => {
          align(
            bottom,
            format_figure(it),
          )
        }

        #it.body

        #if include_information {
          include_information_of_figure(
            source: source,
            note: note,
            width: width_of_figure_body,
          )
        }
      ]
    },
  )
}

#let figure_with_spacing_around = formatted_figure => {
  let space_around = v(
    weak: true,
    spacing_around_figure,
  )
  {
    space_around
    formatted_figure
    space_around
  }
}

#let describe_figure(
  note: none,
  placement: none,
  source: none,
  sticky: false,
  body,
) = {
  set block(breakable: true)
  set grid(gutter: spacing_for_common_text)

  show figure: it => {
    let formatted_figure = format_figure(
      include_information: true,
      note: note,
      source: source,
      sticky: sticky,
      it,
    )

    set block(breakable: true)
    if placement == none {
      figure_with_spacing_around(formatted_figure)
    } else {
      let alignment = if (
        placement == auto
      ) {
        auto
      } else if (placement == top or placement == bottom) {
        placement + center
      } else {
        panic("Placement should be one of the following options: none, auto, top, bottom")
      }

      place(
        clearance: spacing_around_figure,
        float: true,
        alignment,
        formatted_figure,
      )
    }
  }

  body
}
