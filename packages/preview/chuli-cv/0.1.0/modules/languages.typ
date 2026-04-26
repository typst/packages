#import "styles.typ": *

#let render-language(nivel: 2) = {
  for k in range(0, 5) {
    if k < nivel {
      box(circle(
        radius: language-style.radius,
        fill: colors.accent,
      ))
    }
    else {
      box(
        circle(
        radius: language-style.radius,
        fill: colors.inactive,
        ))
    }
    h(language-style.margins.between-tags)
  }
}