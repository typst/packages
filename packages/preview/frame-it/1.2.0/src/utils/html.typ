#let wants-html() = {
  let html-frames = sys.inputs.at("html-frames", default: "false")
  assert(
    html-frames in ("true", "false"),
    message: html-frames
      + " is not valid for `--input html-frames={true|false}`",
  )
  (
    html-frames == "true" and target() == "html"
  )
}

#let target-choose(html: auto, paged: auto) = context {
  assert(
    html != auto and paged != auto,
    message: "Please provide options for both `html` and `paged`.",
  )
  if wants-html() {
    if type(html) == function { html() } else { html }
  } else {
    if type(paged) == function { paged() } else { paged }
  }
}

#let elem(tag, body, ..attrs) = {
  assert(attrs.pos() == (), message: "You can only provide named arguments.")
  assert(
    wants-html(),
    message: "You can only use the `elem` function in an HTML context.",
  )
  let body-arg = if type(body) == function { body() } else { body }
  html.elem(tag, attrs: attrs.named(), body-arg)
}

#let elem-ignore(tag, body, ..attrs) = {
  assert(attrs.pos() == (), message: "You can only provide named arguments.")
  if wants-html() {
    let body-arg = if type(body) == function { body() } else { body }
    html.elem(tag, attrs: attrs.named(), body-arg)
  }
}

#let elem-ident(tag, body, ..attrs) = {
  assert(attrs.pos() == (), message: "You can only provide named arguments.")
  if wants-html() {
    let body-arg = if type(body) == function { body() } else { body }
    html.elem(tag, attrs: attrs.named(), body-arg)
  } else {
    body
  }
}

#let span(style, body, ..attrs) = elem(
  "span",
  body,
  style: style,
  ..attrs,
)
#let div(style, body, ..attrs) = elem("div", body, style: style, ..attrs)
#let hr(style, ..attrs) = elem("hr", style: style, ..attrs, none)

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
