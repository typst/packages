#let color-cd2026 = (
  // CD 2026
  blue: rgb(0, 66, 104),
  darkblue: rgb(0, 58, 91),
  meanblue: rgb(0, 119, 165),
  black: rgb(0, 0, 0),
  blue_Z1: rgb(0, 81, 126),
  blue_Z2: rgb(0, 73, 115),
  blue_Z3: rgb(0, 99, 145),
  blue_Z4: rgb(0, 102, 141),
)

#let color-cd2020 = (
  // CD 2020
  red: rgb(128, 19, 50),
  teal: rgb(0, 92, 100),
  blue: rgb(0, 53, 103),
  purple: rgb(85, 25, 95),
  yellow: rgb(171, 141, 37),
  light_gray: rgb(217, 218, 219),
  gray: rgb(141, 143, 141),
  dark_gray: rgb(90, 79, 74),
)

#let color = (
  // some other colors
  gray: rgb(156, 156, 156),
  grey: rgb("717788"),
  green: rgb("006e43"),
  blue: rgb(0, 53, 103),
  red: rgb(128, 19, 50),
  yellow: rgb("b98900"),
  link: rgb(118, 50, 55),
)

#let color-theme = (
  cd26:
  (
    primary: color-cd2026.blue,
    secondary: color-cd2026.darkblue,
    tertiary: color-cd2026.black,
    lolight: color-cd2026.blue_Z2,
    meanlight: color-cd2026.blue_Z1,
    highlight: color-cd2026.meanblue,
    background: white,
    neutral-lightest: white,
  ),
  cd20:
  (
    primary: color-cd2020.blue,
    secondary: color-cd2020.yellow,
    lolight: color-cd2020.dark_gray,
    meanlight: color-cd2020.gray,
    highlight: color-cd2020.teal,
    background: white,
    neutral-lightest: white,
  )
)

