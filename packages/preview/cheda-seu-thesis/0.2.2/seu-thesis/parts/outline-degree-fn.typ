#import "../utils/outline-tools.typ": cn-outline

#let outline-conf(outline-depth: 3, show-self-in-outline: true) = {
  set page(
    numbering: "I",
    number-align: center
  )
  heading(
    numbering: none, 
    outlined: show-self-in-outline, 
    bookmarked: true
  )[目录]
  cn-outline(
    outline-depth: outline-depth,
    use-raw-heading: true,
    base-indent: 0pt,
    first-level-spacing: 1.4em,
    first-level-font-weight: "bold",
    item-spacing: .9em,
  )
}
