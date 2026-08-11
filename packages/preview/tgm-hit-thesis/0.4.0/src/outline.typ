/// aligns the fills of all outline entries this is attached to.
///
/// Use this as a show rule:
///
/// ```typ
/// show outline.entry: align-fill()
/// ```
///
/// When used, it will
/// - measure the width of all page numbers appearing in so styled outline entries
/// - ensure that the entries' fills only extend to the edge of the _widest_ page number
/// - ensure that the entries' fills are right-aligned
///
/// You will then typically want to set a `repeat(justify: false, ...)` fill. By doing so, all
/// repeats of all fills will be aligned.
#let align-fill() = it => {
  let max-width = state("thesis-outline-max-width", 0pt)

  let page = it.page()
  page = context {
    let this-width = measure(page).width
    max-width.update(calc.max.with(this-width))
    box(width: max-width.final(), align(right, page))
  }

  let fill = it.fill
  fill = box(width: 1fr, align(right, fill))

  link(
    it.element.location(),
    it.indented(it.prefix(), [#it.body() #fill#h(0.1cm) #sym.wj#page]),
  )
}
