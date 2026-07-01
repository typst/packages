
/// HTML extension
#let xcommand(outer-width: 1024pt, outer-height: 768pt, inner-width: none, inner-height: none, content) = {
  let content = if type(content) == str {
    content
  } else if content.func() == raw {
    content.text
  } else {
    content
  }

  let inner-width = if inner-width == none {
    outer-width
  } else {
    inner-width
  }

  let inner-height = if inner-height == none {
    outer-height
  } else {
    inner-height
  }

  let html-embed = {
    "<svg viewBox=\"0 0 "
    str(inner-width.pt())
    " "
    str(inner-height.pt())
    "\""
    " width=\""
    str(outer-width.pt())
    "\" height=\""
    str(outer-height.pt())
    "\" xmlns=\"http://www.w3.org/2000/svg\">"
    "<foreignObject width=\""
    str(inner-width.pt())
    "\" height=\""
    str(inner-height.pt())
    "\"><!-- embedded-content "
    content
    " embedded-content --></foreignObject>"
    "</svg>"
  }

  image.decode(html-embed, alt: "!typst-embed-command")
}
