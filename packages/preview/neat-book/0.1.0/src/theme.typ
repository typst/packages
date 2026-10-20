#let ink = rgb("243746")
#let teal = rgb("176B70")
#let muted = rgb("687882")
#let appendix-mode = state("neat-book.appendix", false)
#let accent-color = state("neat-book.accent", teal)

// Used in equations and figure counters; evaluated at the element's location.
#let chapter-number(at: auto) = {
  let at = if at == auto { here() } else { at }
  let chapter = counter(heading).at(at).at(0, default: 0)
  numbering(if appendix-mode.at(at) { "A" } else { "1" }, chapter)
}
#let chapter-item-number(..numbers) = {
  [#chapter-number().#numbering("1", ..numbers.pos())]
}
#let equation-number(n) = context [\(#chapter-item-number(n)\)]
#let figure-number(..n) = context chapter-item-number(..n)

#let target-item-number(el) = {
  let loc = el.location()
  let is-equation = el.func() == math.equation
  let count = if is-equation { counter(math.equation) } else { counter(figure.where(kind: el.kind)) }
  let number = [#chapter-number(at: loc).#numbering("1", ..count.at(loc))]
  if is-equation { [\(#number\)] } else { number }
}

// Native numbering callbacks run at the reference's location. Resolve chapter
// prefixes at the target instead, including references across the appendix.
#let show-book-ref(it) = context {
  let el = it.element
  if el == none or it.form != "normal" { return it }
  let is-equation = el.func() == math.equation and el.numbering == equation-number
  let is-figure = el.func() == figure and el.numbering == figure-number
  if not (is-equation or is-figure) { return it }
  let number = target-item-number(el)
  let supplement = if it.supplement == auto { el.supplement } else { it.supplement }
  if type(supplement) == function { supplement = supplement(el) }
  link(el.location(), if supplement == none or supplement == [] { number } else { [#supplement#sym.space.nobreak#number] })
}

// Figure/algorithm lists need the same target-based numbering as references.
#let show-book-outline-entry(it) = context {
  let el = it.element
  if el.func() != figure or el.numbering != figure-number { return it }
  let supplement = el.supplement
  if type(supplement) == function { supplement = supplement(el) }
  let prefix = if supplement == none or supplement == [] { target-item-number(el) }
    else { [#supplement#sym.space.nobreak#target-item-number(el)] }
  link(el.location(), it.indented(prefix, it.inner()))
}
