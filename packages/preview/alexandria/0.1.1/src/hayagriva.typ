#let _p = plugin("alexandria.wasm")

#let names = {
  // Typst 0.13: `cbor.decode` is deprecated, directly pass bytes to `cbor` instead
  let decode = if sys.version < version(0, 13, 0) { cbor.decode } else { cbor }

  decode(_p.names())
}

#let read(
  sources,
  full,
  style,
  locale,
  citations,
) = {
  // Typst 0.13: `cbor.decode` is deprecated, directly pass bytes to `cbor` instead
  let decode = if sys.version < version(0, 13, 0) { cbor.decode } else { cbor }

  let config = cbor.encode((sources: sources, full: full, style: style, locale: locale, citations: citations))
  decode(_p.read(config))
}

#let render(body) = {
  if type(body) == array {
    body.map(render).join()
  } else if "text" in body {
    let body = body.text
    set text(style: "italic") if body.font-style == "italic"
    // TODO this is an absolute weight and not an offset
    set text(weight: "bold") if body.font-weight == "bold"
    set text(weight: "light") if body.font-weight == "light"
    show: it => {
      if body.font-variant == "small-caps" {
        it = smallcaps(it)
      }
      if body.text-decoration == "underline" {
        it = underline(it)
      }
      if body.vertical-align == "sup" {
        it = h(0pt, weak: true) + super(it)
      } else if body.vertical-align == "sub" {
        it = h(0pt, weak: true) + sub(it)
      }
      it
    }
    body.text
  } else if "elem" in body {
    let body = body.elem
    // TODO handle body.display when present
    render(body.children)
  } else if "link" in body {
    let body = body.link
    link(body.url, render(body.text))
  } else {
    set text(red)
    repr(body)
  }
}
