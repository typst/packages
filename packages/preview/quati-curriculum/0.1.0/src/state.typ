// # State. Estado.

#import "./style.typ": theme_colors

#let kept_colors = state("kept_colors_ckfeuqqjvyhl4nbg7ih9jfef", (:))

#let get_color_for_updating_kept_colors(key, value) = {
  if type(value) != color and value != none {
    panic("The parameter colors." + key + " must be of type color or none.")
  }
  value
}

#let get_colors_for_updating_kept_colors(colors) = {
  let colors_for_updating_kept_colors = (:)

  colors_for_updating_kept_colors.primary = theme_colors.primary
  colors_for_updating_kept_colors.secondary = theme_colors.secondary
  colors_for_updating_kept_colors.dark = theme_colors.dark

  if colors.len() > 0 {
    colors_for_updating_kept_colors.primary = get_color_for_updating_kept_colors("primary", colors.at(
      "primary",
      default: theme_colors.primary,
    ))

    colors_for_updating_kept_colors.secondary = get_color_for_updating_kept_colors("secondary", colors.at(
      "secondary",
      default: theme_colors.secondary,
    ))

    colors_for_updating_kept_colors.dark = get_color_for_updating_kept_colors("dark", colors.at(
      "dark",
      default: theme_colors.dark,
    ))
  }

  return colors_for_updating_kept_colors
}
