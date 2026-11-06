#import "../imports.typ": i-figured

/// Table Index Page
#let table-list(
  // from entry
  twoside: false,
  // options
  title: [附表清单],
  outlined: false,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    title,
  )

  i-figured.outline(target-kind: table, title: none)
}
