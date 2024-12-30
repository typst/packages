#let main-matter-styles = rest => {
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "1.")

  rest
}