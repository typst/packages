#import "../imports.typ": i-figured

#let figure-list(
  // from entry
  twoside: false,
  // options
  title: [插图索引],
  outlined: true,
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
