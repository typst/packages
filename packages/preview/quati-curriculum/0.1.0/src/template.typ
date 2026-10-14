// # Template. Modelo.

#import "./packages.typ": icons
#import "./state.typ": get_colors_for_updating_kept_colors, kept_colors

#let template(
  colors: (:),
  background_detail: icons.icon(
    width: 20em,
    "tabler:trees",
  ),
  doc,
) = context {
  // Update states
  let colors_for_updating_kept_colors = get_colors_for_updating_kept_colors(colors)
  hide(kept_colors.update(colors_for_updating_kept_colors))

  set page(
    margin: (
      x: 3em,
      y: 3em,
    ),
    fill: colors_for_updating_kept_colors.secondary,
    background: [
      #align(
        bottom + end,
      )[
        #set text(
          fill: colors_for_updating_kept_colors.primary.saturate(100%).transparentize(95%),
        )
        #background_detail
      ]
    ],
  )

  set par(
    leading: 0.375em,
    spacing: 0.5em,
  )

  set text(
    size: 1em,
    fill: colors_for_updating_kept_colors.dark,
  )

  show heading: it => {
    set text(
      fill: colors_for_updating_kept_colors.dark,
      weight: "extrabold",
    )
    set block(
      above: 0.75em,
      below: 0.5em,
    )

    if it.level == 1 {
      set text(colors_for_updating_kept_colors.primary, size: 1em)
      block(
        breakable: false,
        stroke: (
          bottom: colors_for_updating_kept_colors.primary,
        ),
      )[
        #box()[
          #it
          #h(measure(it).width * 1.25)
        ]
      ]
    } else {
      it
    }
  }

  show link: set text(colors_for_updating_kept_colors.primary)

  doc
}
