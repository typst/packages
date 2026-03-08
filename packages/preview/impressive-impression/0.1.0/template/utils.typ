#import "@preview/fontawesome:0.5.0": fa-icon, fa-stack
#import "@preview/impressive-impression:0.1.0": theme-helper

/// Return a flag from the assets directory.
#let flag(id, ..image-args) = {
  return image(
    "assets/flags/" + lower(id) + ".svg",
    ..image-args
  )
}

/// Create a factory function for Font Awesome stacked icons with a specific theme.
#let fa-icon-factory-stack(
  theme,
) = {
  let th = theme-helper(theme)

  let icon1-args = (
    "circle",
    (
      solid: true,
      fill: th("primary-accent-color"),
      size: 18pt,
    )
  )

  let icon2-args = (
    solid: true,
    fill: th("aside-background-color"),
    size: 12pt,
  )

  return (icon) => {
    let icon1 = icon1-args
    let icon2 = (icon, icon2-args)

    fa-stack(icon1, icon2)
  }
}

/// Create a factory function for Font Awesome icons with a specific theme.
#let fa-icon-factory(
  theme,
) = {
  let th = theme-helper(theme)

  return (icon, solid: false, size: 18pt) => {
    let icon-args = (icon, (
      solid: solid,
      fill: th("primary-accent-color"),
      size: size,
    ))

    fa-stack(icon-args)
  }
}
