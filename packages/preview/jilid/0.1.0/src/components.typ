#import "state.typ": footer-text

#import "utils.typ": filled

#let signature(
  role: none,
  name: none,
  id: none,
  id-label: "NIP",
  space: 2cm, // height of the blank space to sign in.
  underline-name: false,
  alignment: center,
) = block(width: 100%, breakable: false, {
  set align(alignment)
  set par(first-line-indent: 0pt, justify: false)
  if filled(role) { role }
  v(space)
  let lines = ()
  if filled(name) {
    lines.push(text(weight: "bold", if underline-name { underline(name) } else {
      name
    }))
  }
  // without an id, keep the name in line with its neighbours.
  lines.push(
    if not filled(id) { hide[0] } else if filled(
      id-label,
    ) [#id-label #id] else [#id],
  )
  lines.join(linebreak())
})

/// signatures under a full-width `header`, `columns` per row.
/// names in a row line up.
/// a shorter last row sits in the center.
#let signatures(header: none, columns: 2, gutter: 1cm, ..items) = {
  assert(
    items.named().len() == 0,
    message: "jilid: unknown argument(s) for `signatures`: "
      + items.named().keys().map(k => "`" + k + "`").join(", ")
      + ".",
  )
  assert(
    type(columns) == int and columns >= 1,
    message: "jilid: `signatures(columns: ..)` must be a positive integer.",
  )
  let rows = items
    .pos()
    .chunks(columns)
    .map(row => grid(columns: (1fr,) * row.len(), align: bottom, ..row))
  if filled(header) {
    // keep the header on the same page as the first row.
    let first = if rows.len() > 0 { rows.remove(0) }
    rows.insert(0, block(breakable: false, {
      set par(first-line-indent: 0pt, justify: false)
      align(center, header)
      v(0.5em)
      first
    }))
  }
  stack(spacing: gutter, ..rows)
}

// change the footer text from this page on.
// none restores `footer.left`.
#let set-footer-text(body) = footer-text.update(body)
