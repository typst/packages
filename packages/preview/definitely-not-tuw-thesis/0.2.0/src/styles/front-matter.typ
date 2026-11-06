#import "utils/state.typ": is-back-matter

#let front-matter-styles = rest => {
  set page(numbering: "i")
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: none)

  rest
}