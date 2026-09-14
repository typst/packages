#import "../imports.typ": i-figured

/// Figure Index Page
#let figure-list(
  // from entry
  twoside: false,
  // options
  title: [插图清单],
  outlined: false,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    title,
  )

  i-figured.outline(target-kind: image, title: none)
}
