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

// Additional colors for use in documents, independent of the theme
#let color = (
  // neutral gray, e.g. the bar next to the chapter number (thesis)
  gray: rgb(156, 156, 156),
  // bluish gray, a different color than `gray`, currently unused
  grey: rgb("717788"),
  // points of tasks
  green: rgb("006e43"),
  // same as color-cd2020.blue
  blue: color-cd2020.blue,
  // solutions, same as color-cd2020.red
  red: color-cd2020.red,
  yellow: rgb("b98900"),
  // dark red for links, currently unused
  link: rgb(118, 50, 55),
)

// Predefined themes, select one with the option `theme: "cd26"` or "cd20".
// All themes have the same keys:
// - primary: headers, footers, headings and other accents
// - secondary: second accent color
// - highlight: boxes (poster) and the slide progress bar
// - background: text on primary colored areas
// - neutral-lightest: lightest neutral color (slides)
#let color-theme = (
  cd26: (
    primary: color-cd2026.blue,
    secondary: color-cd2026.darkblue,
    highlight: color-cd2026.meanblue,
    background: white,
    neutral-lightest: white,
  ),
  cd20: (
    primary: color-cd2020.blue,
    secondary: color-cd2020.yellow,
    highlight: color-cd2020.teal,
    background: white,
    neutral-lightest: white,
  ),
)
