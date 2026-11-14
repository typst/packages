// Native Typst bibliography. The source path belongs to the user's project.
#let make-bibliography(
  sources,
  style: "apa",
  title: auto,
  full: false,
) = [
  #pagebreak(weak: true)
  #bibliography(
    sources,
    style: style,
    title: title,
    full: full,
  )
]
