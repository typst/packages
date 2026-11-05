///! Title and subtitle directives.

// The header sits above the column labels, as a level-1 native header, so it
// never repeats across a page break.
#let table-header(title: none, subtitle: none) = (
  kind: "header",
  title: title,
  subtitle: subtitle,
)
