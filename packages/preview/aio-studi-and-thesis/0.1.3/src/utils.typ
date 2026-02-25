// Validation if content is not none and not empty
#let is-not-none-or-empty(content) = if content != none and content != "" { return true } else { return false }

// Validation if dict contains a specified key
#let dict-contains-key(dict: (), key) = {
  if (key in dict) { return true } else { return false }
}

// Converts content to string
#let to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// Default font
#let default-font = (
  "Roboto",   // typst.app
  "Calibri",  // Windows
  "Arial",    // macOS
  "Carlito",  // Linux
)

// Colors
#let blue = rgb("#009fe3")
#let dark-blue = rgb("#152f4e")
#let light-blue = rgb("#e8eff7")
#let dark-grey = rgb("#4a4a49")
#let green = rgb("#26a269")
#let purple = rgb("#613583")

// Outline, which has a title listed in toc and no special formatting
#let simple-outline(title: none, target: none, indent: 1em, depth: none) = {
  if is-not-none-or-empty(title) {
    heading(depth: 1)[ #title ]
  }
  outline(
    title: none,
    target: target,
    indent: indent,
    depth: depth
  )
}

// Signing
#let signing(text: none) = {
  import "dictionary.typ": txt-location, txt-date, txt-author-signature
  
  v(1fr)
    
  let gutter = 30pt
  let stroke = 0.5pt
  let columns = (1.2fr, 2fr)
    
  grid(
    columns: columns,
    gutter: gutter,
    [ #line(length: 100%, stroke: stroke) ],
    [ #line(length: 90%, stroke: stroke) ]
  )

  v(-5pt)
  
  grid(
    columns: columns,
    gutter: gutter,
    [ #txt-location, #txt-date ],
    [ #if text == none { txt-author-signature } else { text } ]
  )
}

// Emphasising keywords
#let emphasized(fill: dark-blue, it) = {
  text(style: "normal", weight: "bold", tracking: 0pt, fill: fill, it)
}

// TODO handling - Reference: https://github.com/typst/typst/issues/662#issuecomment-1516709607
#let txt-todo = text(size: 1.2em, emphasized(fill: red, "TODO"))

#let todo(it) = [
  #if is-not-none-or-empty(it) {
    text([#txt-todo: #[#it <todo>]], red)
  }
]