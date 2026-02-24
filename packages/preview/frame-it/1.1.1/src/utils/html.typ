#let span(style, body) = html.elem("span", attrs: (style: style), body)
#let div(style, body) = html.elem("div", attrs: (style: style), body)

#let css(..args) = {
  assert(
    args.pos().map(type) in ((), (dictionary,)),
    message: "CSS function only accepts named arguments or one dictionary.",
  )
  let css-dict = if args.pos().len() == 1 {
    assert(args.named() == (:))
    args.pos().first()
  } else {
    args.named()
  }

  let parse(val) = if type(val) == color {
    val.to-hex()
  } else if type(val) != str {
    repr(val)
  } else {
    val
  }

  for (key, value) in css-dict {
    value = if type(value) == array {
      value.map(parse).join(" ")
    } else {
      parse(value)
    }
    key + ": " + value + "; "
  }
}
