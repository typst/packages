// Auto page-footer — `basics.name` flush left, `Page N / M` flush
// right, suppressed on single-page documents so the common one-page
// case stays clean. The page-count check is reactive (the counter
// resolves to the final value after layout), so adding content that
// pushes onto a second page brings the footer with it without any
// caller change.

#import "state.typ": _body_size_state, _body_colour

#let _auto_page_footer(name) = context {
  let total = counter(page).final().first()
  if total <= 1 { return }
  let body-size = _body_size_state.get()
  set text(0.8 * body-size, fill: _body_colour)
  grid(
    columns: (1fr, auto),
    align: (left, right),
    name,
    [Page #counter(page).display() / #total],
  )
}
