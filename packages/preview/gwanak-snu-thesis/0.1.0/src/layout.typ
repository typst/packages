#let page-width = 190mm
#let page-height = 260mm

#let body-margin = (
  left: 30mm,
  right: 30mm,
  top: 20mm,
  bottom: 15mm,
)

#let page-number-align = bottom + center

#let _page-size-args(paper-size) = {
  if paper-size == "default" {
    (width: page-width, height: page-height)
  } else if type(paper-size) == str {
    (paper: paper-size)
  } else {
    assert(type(paper-size) == dictionary, message: "paper-size must be 'default', a Typst paper string, or a dictionary")
    assert("width" in paper-size, message: "paper-size dictionary must include width")
    assert("height" in paper-size, message: "paper-size dictionary must include height")
    (width: paper-size.width, height: paper-size.height)
  }
}

#let page-args(paper-size: "default", margin: body-margin, numbering: none, number-align: none) = {
  let args = _page-size-args(paper-size)
  args.insert("margin", margin)
  args.insert("numbering", numbering)
  if number-align != none {
    args.insert("number-align", number-align)
  }
  args
}

