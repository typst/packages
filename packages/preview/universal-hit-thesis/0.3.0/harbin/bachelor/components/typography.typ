#let special-chapter-format-heading(it: none, font: none, size: none, weight: "regular") = {
  set text(font: font, size: size)

  text(weight: weight)[
    #if it != none {
      it.body
    }
  ]
  v(0.5em)
}

#let main-format-heading(it: none, font: none, size: none, weight: "regular") = {
  set text(font: font, size: size)
    // v(0.5em)
  text(weight: weight)[
    #counter(heading).display()
    #if it != none {
      it.body
    }
  ]
  // v(0.5em)
}