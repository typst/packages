// english localizations
//
// Each entry is either plain content, or a function that takes a
// (possibly already-formatted) heading number and returns content.
// Functions exist because the label and the number don't always combine
// the same way in every language - compare "chapter" here with
// l10n/ja.typ, where the number is a suffix instead of a prefix.
#let strings = (
  abstract: [Abstract],
  contents: [Contents],
  chapter: n => [Chapter #n],
  section: n => [Section #n],
  table: [Table],
  figure: [Figure],
  appendix: n => [Appendix #n],
  references: [References],
)
