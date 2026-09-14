#let appendix-styles = rest => {
  counter(heading).update(0)
  set heading(numbering: "A.1.", supplement: "Appendix")

  rest
}