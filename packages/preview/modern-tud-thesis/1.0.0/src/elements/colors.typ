#let c() = {
  let colorData = yaml("/src/elements/colors.yaml")
  let colors = (:)

  for (name, channels) in colorData {
    if type(channels) == dictionary {
      for (suffix, channels) in channels {
        colors.insert(name + "-" + suffix, rgb(..channels))
      }
    } else {
      colors.insert(name, rgb(..channels))
    }
  }

  colors
}

#let colors = c()

#let set-colors(
  primary: none,
  secondary: none,
  tertiary: none,
) = {
  if primary != none {
    state("color-primary").update(primary)
  }

  if secondary != none {
    state("color-secondary").update(secondary)
  }

  if tertiary != none {
    state("color-tertiary").update(tertiary)
  }
}