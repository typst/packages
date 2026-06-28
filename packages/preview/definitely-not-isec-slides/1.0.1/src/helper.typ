// --------------------------------------------------------------------------
// Extra helper functions

// Fix for typst #311 "Behavior of first line indentation in paragraphs ..." 
// https://github.com/typst/typst/issues/311#issuecomment-2023038611
// https://forum.typst.app/t/how-to-indent-paragraphs-following-a-list-without-affecting-the-paragraph-after-a-heading/4210?u=fungai2000
#let fix-311 = context {
  set par.line(numbering: none)
  v(0pt, weak: true) + par(none)
}

#let content-to-string(content) = {
  if content.has("text") {
    content.text
  }else if content.has("child") {
    content-to-string(content.child)
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let content-to-string-omit(content) = {
  if content.has("text") {
    content.text
  }else if content.has("child") {
    content-to-string-omit(content.child)
  } else if content.has("children") {
    content.children.map(content-to-string-omit).join("")
  } else if content.has("body") {
    content-to-string-omit(content.body)
  } else if content == [ ] {
    " "
  } else {
    "..."
  }
}

// partitle simulates \paragraph{title} (more or less)
#let partitle(title: [Title], body) = context [
  #block(above: 0.8cm)[
    *#title.* #h(0.3cm) #body
  ]
  #fix-311
]

// Wrapper for the technique shown here:
// https://typst.app/docs/reference/layout/layout/
#let measure-text-height(body) = {
  layout(size => {
    let (height,) = measure(width: size.width, body)
    return height
  })
}

//vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
