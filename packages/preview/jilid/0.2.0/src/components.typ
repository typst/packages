#import "state.typ": footer-text

#import "utils.typ": filled

/// A signature block, with a role, space to sign, a name and an ID.
///
/// jilid keeps the block on one page.
/// The name is bold. If there is no ID, jilid keeps an empty line in its place, so names in a row stay level.
/// To put signatures side by side, give them to `signatures`.
///
/// = Example
///
/// ```
/// #signature(
///   role: [Dosen Pembimbing],
///   name: "Nama Dosen",
///   id: "10000000000000000",
/// )
/// ```
///
/// - role (content, str, none): The role above the space, such as Dosen Pembimbing.
/// - name (content, str, none): The name under the space.
/// - id (content, str, none): The ID under the name.
/// - id-label (content, str, none): The word before the ID, such as NIP or NIM.
/// - space (length): The height of the space to sign in.
/// - underline-name (bool): If `true`, jilid underlines the name.
/// - alignment (alignment): The horizontal alignment of the block.
/// -> content
#let signature(
  /// The role above the space, such as Dosen Pembimbing.
  role: none,
  /// The name under the space.
  name: none,
  /// The ID under the name.
  id: none,
  /// The word before the ID, such as NIP or NIM.
  id-label: "NIP",
  /// The height of the space to sign in.
  space: 2cm,
  /// If `true`, jilid underlines the name.
  underline-name: false,
  /// The horizontal alignment of the block.
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
  // If there is no ID, keep an empty line so the name stays level with its neighbors.
  lines.push(
    if not filled(id) { hide[0] } else if filled(
      id-label,
    ) [#id-label #id] else [#id],
  )
  lines.join(linebreak())
})

/// Signature blocks in rows, under a header that spans the full width.
///
/// Each row has `columns` signatures, and the names in a row are level.
/// If the last row has fewer signatures, jilid puts it in the center.
/// jilid keeps the header on the same page as the first row.
///
/// = Example
///
/// ```
/// #signatures(
///   header: [Kota, 1 Januari 2026 \ Mengetahui,],
///   signature(role: [Dosen], name: "Nama Dosen"),
///   signature(role: [Mahasiswa], name: "Nama Mahasiswa", id-label: "NIM"),
/// )
/// ```
///
/// - header (content, none): The text above the first row, such as the place, the date and "Mengetahui,".
/// - columns (int): The number of signatures in each row.
/// - gutter (length): The space between rows.
/// - items (content): The `signature` blocks, in order.
/// -> content
#let signatures(
  /// The text above the first row, such as the place, the date and "Mengetahui,".
  header: none,
  /// The number of signatures in each row.
  columns: 2,
  /// The space between rows.
  gutter: 1cm,
  /// The `signature` blocks, in order.
  ..items,
) = {
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
    // Keep the header on the same page as the first row.
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

/// Changes the footer text from this page on.
///
/// If you give `none`, jilid shows the `footer.left` text again.
///
/// = Example
///
/// ```
/// #set-footer-text[Bab II Tinjauan Pustaka]
/// ```
///
/// - body (content, str, none): The new footer text.
/// -> content
#let set-footer-text(
  /// The new footer text.
  body,
) = footer-text.update(body)
