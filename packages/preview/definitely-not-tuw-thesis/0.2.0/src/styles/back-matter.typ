#import "utils/state.typ": is-back-matter

#let back-matter-styles = rest => {
  is-back-matter.update(true)
  set heading(numbering: none)
  set page(header: none)

  rest
}
