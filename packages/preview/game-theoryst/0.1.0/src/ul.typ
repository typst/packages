// "Colored Underline": Underline numbers in game table
  //Underlines value in table with colored line (`col`)
  //The number itself remains black by default (`tcol`), but is boldfaced
/*
ToDo: check that `cont` is math, possibly increase functionality to text for convenience sake
  - Normal text could just be underlined with `#underline()`
*/
#let cul(cont, ucol, tcol: black) = {
  set text(fill: ucol)
  math.bold(math.underline(text(fill: tcol, cont)))
}

// Utilities for red/blue underlining, corresponding to default player name colors
  // "Horizontal Underline" + "Vertical Underline"
#let bul(cont, col: black) = { cul(cont, col) }
#let hul(cont, col: red) = { cul(cont, col) }
#let vul(cont, col: blue) = { cul(cont, col) }

#let hful(cont, col: red) = { cul(cont, col, tcol: col) }
#let vful(cont, col: blue) = { cul(cont, col, tcol: col) }
