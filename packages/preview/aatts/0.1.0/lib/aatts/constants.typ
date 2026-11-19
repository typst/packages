// color palette
#let palette = (
  //
  // greys
  grey: (
    dark: rgb("#2C2A29"),
    medium: rgb("#6b7280"),
    light: rgb("#f3f1ec")
  ),
  //
  // primary
  red: rgb("#C31F39"),
  green: rgb("#1FC357"),
  blue: rgb("#1F91C2"),
  // 
  // secondary
  olive: rgb("#C2BA1F"),
  magenta: rgb("#B31FC2"),
)

#let font-families = (
  "Helvetica Neue", "Helvetica", 
  "Liberation Sans", "Arial"
)

// num grid columns
#let base-unit-grid = 12

// generate ({1, ..., n} / base-unit-grid)
#let span = (
  range(1, base-unit-grid + 1)
  .map(i => ("p" + str(i), i / base-unit-grid * 100%))
  .to-dict()
)