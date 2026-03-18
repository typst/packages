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

#let render(body, ..transparent-contents) = {
  assert.eq(transparent-contents.named().len(), 0, message: "no named arguments allowed")
  let transparent-contents = transparent-contents.pos()
  let formatted(fmt) = it => {
    set text(style: "italic") if fmt.font-style == "italic"
    // TODO this is an absolute weight and not an offset
    set text(weight: "bold") if fmt.font-weight == "bold"
    set text(weight: "light") if fmt.font-weight == "light"
    if fmt.font-variant == "small-caps" {
      it = smallcaps(it)
    }
    if fmt.text-decoration == "underline" {
      it = underline(it)
    }
    if fmt.vertical-align == "sup" {
      it = h(0pt, weak: true) + super(it)
    } else if fmt.vertical-align == "sub" {
      it = h(0pt, weak: true) + sub(it)
    }
    it
  }

  let inner(body) = {
    if type(body) == array {
      body.map(inner).join()
    } else if "text" in body {
      let body = body.text
      show: formatted(body)
      body.text
    } else if "elem" in body {
      let body = body.elem
      // TODO handle body.display when present
      inner(body.children)
    } else if "link" in body {
      let body = body.link
      link(body.url, inner(body.text))
    } else if "transparent" in body {
      let body = body.transparent
      show: formatted(body)
      assert(body.cite-idx < transparent-contents.len(), message: "Alexandria: internal error: unmatched transparent content")
      transparent-contents.at(body.cite-idx)
    } else {
      set text(red)
      repr(body)
    }
  }
  inner(body)
}
