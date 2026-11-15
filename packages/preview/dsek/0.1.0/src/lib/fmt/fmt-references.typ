// TODO: Document this thoroughly.
#let ref-id = (
  "person": 99,
  "minute": 98,
  "statutes": 97,
  "appendix": 1,
)

/// Custom `@ref` renderer applied automatically by `plain-document` via `show ref`.
///
/// Renders person references (depth `ref-id.person`) as "Position Name" links,
/// minute-item and statute references (depths `ref-id.minute` / `ref-id.statutes`)
/// as "§N Title" links, and appendix references (depth `ref-id.appendix`) as
/// "A", "B", … links, all in the body text colour (no pink). Falls back to the
/// default renderer for all other references.
///
/// Not called directly — set via `show ref: enhanced-ref` inside `plain-document`.
/// -> content
#let enhanced-ref(it) = {
  let elem = it.element
  show: box
  if elem != none and elem.func() == heading and elem.numbering == none and not elem.outlined {
    if elem.depth == ref-id.person {
      // people
      show link: set text(text.fill)
      link(elem.location(), [
        #{ if it.supplement == [] { elem.supplement } else if it.supplement != auto { it.supplement } }
        #elem.body
      ])
    } else if elem.depth == ref-id.minute {
      // minutes
      show link: set text(text.fill)
      let body = if it.supplement == [] { elem.body } else if it.supplement != auto { it.supplement }
      link(elem.location(), [§#elem.supplement #body])
    } else if elem.depth == ref-id.statutes {
      // statutes
      show link: set text(text.fill)
      let body = if it.supplement == [] { elem.body } else if it.supplement != auto { it.supplement }
      link(elem.location(), [§#elem.supplement #body])
    } else if elem.depth == ref-id.appendix {
      // appendix
      show link: set text(text.fill)
      link(elem.location(), elem.supplement)
    }
  } else {
    it
  }
}
