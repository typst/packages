#import "../utils/outline-tools.typ": cn-outline

#let outline-conf(outline-depth: 3, show-self-in-outline: false) = {
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
    use-raw-heading: false,
  )
}
