/// Style functions and labels used for style

/// Plain or default style
#let plain = <terms-table-plain>
/// "Booktabs" like style
#let book = <terms-table-book>
/// Label for each term in term list as table
#let term = <terms-table-term>
/// Label for each description in term list as table
#let description = <terms-table-description>
/// This label revokes the effects of `terms-table` on the terms.
#let revoke = <terms-table-revoke>

/// Template/show rule applying style rules for plain and book styles.
///
/// ```typst
/// #show: tabbyterms.style.default-styles
/// // the rest of the document
/// ```
///
/// - body (any): The document
#let default-styles(body) = {
  let default-stroke(x, y) = {
    if y <= 0 { (y: 0.5pt) }
  }
  show selector.and(table, book): set table(stroke: default-stroke, inset: 0.75em)
  show selector.and(table, book): it => {
    show table.cell.where(y: 0): strong
    it
  }
  show selector.and(table, book): set table.hline(stroke: 0.5pt)
  show selector.and(table, plain): set table(stroke: none)
  show selector.and(table, plain): tab => {
    show term: strong
    tab
  }
  body
}


