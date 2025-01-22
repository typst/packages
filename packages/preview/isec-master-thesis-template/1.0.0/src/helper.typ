// --------------------------------------------------------------------------
// Extra helper functions

// Fix for typst #311 "Behavior of first line indentation in paragraphs ..." 
// https://github.com/typst/typst/issues/311#issuecomment-2023038611
#let fix-311 = context {
  set par.line(numbering: none)
  let a = par(box())
  a
  v(-0.8 * measure(2 * a).width)
}

// Transforms content into string
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// partitle simulates \paragraph{title} (more or less)
#let partitle(title: [Title], body) = context [
  #block(above: 0.8cm)[
    *#title* #h(0.3cm) #body
  ]
  #fix-311
]

//vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
