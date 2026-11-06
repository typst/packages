/// A function which displays an `outline.entry` using its default show rule _with_ the given page
/// numbering.
///
/// - entry (outline.entry): the outline entry to display
/// - func: (function): transforms a location to a page number
/// -> content
#let outline-entry(entry, func: loc => loc.page()) = {
  link(entry.element.location(), entry.body)
  if entry.fill != none {
    [ ]
    box(width: 1fr, entry.fill)
    [ ]
  } else {
    h(1fr)
  }
  link(entry.element.location(), func(entry.element.location()))
}
