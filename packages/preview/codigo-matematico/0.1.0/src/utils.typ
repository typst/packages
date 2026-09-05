
#import "./palette.typ": *


// Puts in uppercase just the first letter in a word.
#let capitalize(text) = {
  if text == "" { "" } else {
    upper(text.slice(0, 1)) + text.slice(1,)
  }
}


// Optional suffixes for theorem-like environments (number, title, ref, …).
#let env_parenthetical(value) = {
  if value != none { [ (#value)] } else { [] }
}

#let env_title_suffix(number: none, title: none) = {
  let number-suffix = if number != none { [ #number] } else { [] }
  [#number-suffix#env_parenthetical(title)]
}


// Thematic pause.
#let hrule = block[
  #v(15pt)
  #line(length: 100%, stroke: (paint: palette.fg, thickness: 0.5pt, dash: "dashed"))
  #v(15pt)
]


// Vertical spacing before and after headings of a given level.
#let heading_vspace(level, top, bottom) = {
  show heading.where(level: level): it => {
    v(top)
    it
    v(bottom)
  }
}
