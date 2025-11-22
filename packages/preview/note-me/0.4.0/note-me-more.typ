#import "note-me.typ": admonition

#let todo(title: "TODO", children) = admonition(
  icon-path: "icons/question.svg",
  title: title,
  color: rgb(209, 36, 47),
  children
)