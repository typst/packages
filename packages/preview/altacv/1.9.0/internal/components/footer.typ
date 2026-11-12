// The page footers standalone `alta()` (`sections/footer.typ`) and
// the template's helpers (`footers.typ`) draw: the page counter, which
// hides itself on single-page documents via the reactive page counter
// (so it returns on its own when content grows), and the right-aligned
// "last updated" line (`Last updated: …`), both in body text.

#import "../util/values.typ": _fill-template

#let _auto-page-footer(name, page-number) = context {
  let total = counter(page).final().first()
  if total <= 1 { return }
  grid(
    columns: (1fr, auto),
    align: (left, right),
    name,
    _fill-template(page-number, (
      current: str(counter(page).get().first()),
      total: str(total),
    )),
  )
}

// `label` and `value` joined by `separator` (a theme's
// `separator.label`).
#let _updated-footer(label, value, separator) = align(right, {
  label
  separator
  value
})

// "last-modified (version)", the version only when asked for and set.
#let _updated-line((last-modified, version: v, ..), version) = {
  last-modified
  if version and v != none { " (" + v + ")" }
}
