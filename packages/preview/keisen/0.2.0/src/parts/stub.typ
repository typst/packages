///! Stub column, row names, groups, and indentation.
///!
///! The stub is the labelling column on the leading edge: it names each row,
///! and optionally divides the body into labelled groups. Both columns leave
///! the ordinary column list, since they label the table rather than carry
///! data, but they stay in the row store for predicates to read.

// `indent` names a column of integers, one indentation level per row.
#let table-stub(rowname: none, group: none, label: none, indent: none) = (
  kind: "stub",
  rowname: rowname,
  group: group,
  label: label,
  indent: indent,
)

// An explicit group, for data that carries no column to group by: which rows
// belong together is then a judgement the document makes rather than something
// the data says.
//
// `rows` is the ordinary row selector, so an index, an array of them, or a
// predicate over the row all work. Later groups win on overlap, which makes a
// second group the correction of the first, and rows no group claims render as
// a leading nameless block.
//
// Groups come from here or from `table-stub(group: ..)`, never from both: two
// sources for the same thing is one too many.
#let table-row-group(label, rows) = (
  kind: "row-group",
  label: label,
  rows: rows,
)

// The data columns a stub claims, in one place, so adding a stub key does not
// mean editing every loop that walks them.
#let stub-column-names(stub) = {
  (stub.rowname, stub.group, stub.indent).filter(name => name != none)
}
