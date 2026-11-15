#let wants-html() = {
  "target" in dictionary(std) and target() == "html"
}

#let target-choose(html: none, paged: none) = context {
  assert(
    html != none and paged != none,
    message: "Please provide options for both `html` and `paged`.",
  )
  if wants-html() { html() } else { paged() }
}

// Builds a CSS declaration list for the `style` attribute of typed `html` elements.
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
