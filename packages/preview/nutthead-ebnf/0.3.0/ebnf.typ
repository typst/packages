#let _namespace = "nutthead.ebnf."

#let _sym-prod = symbol(sym.arrow.r)

#let _qualifiers = (
  sym-opt: "?",
  sym-some: "+",
  sym-any: "*",
)

#let _brackets = (
  sym-rounded: (open: "(", close: ")"),
  sym-curly: (open: "{", close: "}"),
  sym-square: (open: "[", close: "]"),
  sym-comment: (open: "(*", close: "*)"),
  sym-special: (open: "?", close: "?"),
)

#let _definition-separator-symbols = (
  sym-vertical: "|",
  sym-solidus: "/",
  sym-exclamation: "!",
)

#let _delimiter-symbols = (
  sym-delim-1: "\"",
  sym-delim-2: "'",
  sym-delim-3: "`",
)

#let _colors = (
  color-dimmed: rgb("#828282"),
  color-highlighted: rgb("#4F46E5"),
  color-error: rgb("#FF0000"),
)

#let _illuminations = (
  illum-dimmed: _colors.color-dimmed,
  illum-highlighted: _colors.color-highlighted,
)

///
/// root(4, Φ)      ≈ 1.127
///
/// 1em     / 1.127 ≈ 0.887em
///
/// 0.887em / 1.127 ≈ 0.787
///
#let _fonts = (
  font-default: (family: "Libertinus Serif", size: 1em),
  font-monospaced: (family: "Dejavu Sans Mono", size: 0.887em),
)

#let _configuration = state("nutthead.ebnf", (
  sym-prod: _sym-prod,
  .._qualifiers,
  .._brackets,
  .._definition-separator-symbols,
  sym-separator: _definition-separator-symbols.at("sym-vertical"),
  sym-delim: _delimiter-symbols.sym-delim-3,
  .._delimiter-symbols,
  .._colors,
  .._illuminations,
  .._fonts,
))

#let _error(message) = {
  panic("Error: " + message)
}

#let _assert-some(value, message) = {
  if message == none {
    assert.ne(value, none, message: "Error: expected some, got none")
  } else {
    assert.ne(value, none, message: "Error: " + message)
  }
}

#let _update-config(key, value) = {
  if key == none {
    _error("key must not be none, but got: " + repr(key))
  }

  if (value == none) {
    _error("value must not be none, but got: " + repr(value))
  }

  _configuration.update(it => {
    it.insert(key, value)
    it
  })
}

#let _get-config(key, default: none) = {
  if key == none {
    return default
  }

  let config = _configuration.get()
  let keys = config.keys()
  if key not in keys {
    let keys = config.keys().join(", ")
    _error("key must be one of " + keys + ", but got: " + repr(key))
  }

  let result = config.at(key)
  result
}

#let _to-sym-key(text) = {
  if text == none { none } else { "sym-" + text }  
}

#let _get-brackets(kind) = {
  _assert-some(kind, "kind must not be none, got: " + repr(kind))
  _get-config(_to-sym-key(kind))
}

#let _validate-opt-key(key, dict: none) = {
  if key == none {
    return
  }

  dict = if dict == none {
    _configuration.at(here())
  } else {
    dict
  }

  if type(dict) != dictionary {
    _error(
      "expected dict to resolve to dictionary, but got: " + repr(type(key)),
    )
  }

  let keys = dict.keys()

  if key not in keys {
    _error(
      "key must be one of " + keys.join(", ") + ", but got: " + repr(key),
    )
  }
}

#let _validate-key(key, dict: none) = {
  if key == none {
    _error("key must not be none, but got: " + repr(key))
  }

  _validate-opt-key(key, dict: dict)
}

#let _trim-str(text) = {
  while text.len() > 0 and text.first() == " " {
    text = text.slice(1)
  }

  while text.len() > 0 and text.last() == " " {
    text = text.slice(0, text.len() - 1)
  }

  text
}

#let _is-space(c) = {
  c == [ ]
}

#let _trim-content(content) = {
  if type(content) == str {
    return _trim-str(content)
  }

  if not content.has("children") {
    return content
  }

  let children = content.children

  while children.len() > 0 and _is-space(children.first()) {
    children = children.slice(1)
  }

  while children.len() > 0 and _is-space(children.last()) {
    children = children.slice(0, children.len() - 1)
  }

  children.join()
}

#let _get-def-separator-sym() = {
  _get-config("sym-separator")
}

#let _illuminate(body, type: none) = {
  if type == none {
    text(body)
  } else {
    let key = "illum-" + type
    let keys = _illuminations.keys()

    if key not in keys {
      _error("type must be one of " + keys.join(", ") + ", got: " + repr(type))
    }

    let color = _get-config(key)

    text(body, fill: color)
  }
}

#let _wrap(
  body,
  illumination: none,
  qualifier: none,
  bracket-type: none,
) = {
  if bracket-type == none {
    _error(
      "bracket-type must not be none, but got: " + repr(bracket-type),
    )
  }

  let bracket = _get-config(_to-sym-key(bracket-type))
  let open-bracket = bracket.open
  let close-bracket = bracket.close
  let result = open-bracket + body + close-bracket

  if illumination != none {
    result = _illuminate(result, type: illumination)
  }

  let qualifier-key = _to-sym-key(qualifier)

  let qualifier-sym = if qualifier-key == none {
    none
  } else {
    _get-config(qualifier-key)
  }

  if qualifier-sym != none {
    result = result + qualifier-sym
  }

  result
}

#let _to-string(content) = {
  if type(content) == str {
    return content
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}

#let _to-illumination-key(illum) = {
  if illum == none { none } else { "illum-" + illum }
}

#let mono(body) = {
  let font = _get-config("font-monospaced")
  let family = font.family
  let size = font.size
  text(font: family, size: size)[#body]
}

#let regular(body) = {
  let font = _get-config("font-default")
  let family = font.family
  let size = font.size
  text(font: family, size: size)[#body]
}

#let terminal(body, illumination: none) = {
  let delimiter = _get-config("sym-delim")
  mono(delimiter + body + delimiter)
}

#let code-example(code) = {
  let brackets = _get-config(_to-sym-key("comment"))
  let open-bracket = brackets.open
  let close-bracket = brackets.close

  let _code = _to-string(code)

  open-bracket + " " + raw(_code, lang: "rust") + " " + close-bracket
}

#let qualified(body, illumination: none, qualifier: none) = {
  let result = if qualifier == none or qualifier not in _qualifiers {
    panic(
      "Error: qualifier must be one of " + _qualifiers.keys().join(", ") + ", got: " + repr(qualifier),
    )
  } else {
    body + super(_qualifiers.at(qualifier))
  }

  if illumination != none {
    _illuminate(result, type: illumination)
  } else {
    result
  }
}

#let meta-identifier(body) = {
  let prod = _get-config(_to-sym-key("prod"))
  strong(body) + " " + prod
}

#let grouped-sequence(body, illumination: none, qualifier: none) = {
  let _body = if body.has("children") {
    body.children.filter(it => it != [ ]).join(" | ")
  } else {
    body
  }

  _wrap(_body, illumination: illumination, qualifier: qualifier, bracket-type: "rounded")
}

#let optional-sequence(body, illumination: none, qualifier: none) = {
  let _body = if body.has("children") {
    body.children.filter(it => it != [ ]).join(" | ")
  } else {
    body
  }

  _wrap(_body, illumination: illumination, qualifier: qualifier, bracket-type: "square")
}

#let repeated-sequence(body, illumination: none, qualifier: none) = {
  let _body = if body.has("children") {
    body.children.filter(it => it != [ ]).join(" | ")
  } else {
    body
  }

  _wrap(_body, illumination: illumination, qualifier: qualifier, bracket-type: "curly")
}

#let special-sequence(body, illumination: none, qualifier: none) = {
  let _body = if body.has("children") {
    body.children.filter(it => it != [ ]).join(" | ")
  } else {
    body
  }

  _wrap(_body, illumination: illumination, qualifier: qualifier, bracket-type: "special")
}

#let single-definition(body, illumination: none, qualifier: none) = {
  let illum = _to-illumination-key(illumination)
  let qual = _to-sym-key(qualifier)

  _validate-opt-key(qual)
  _validate-opt-key(illum)

  let result = (
    emph(body) + if qual == none { none } else { _qualifiers.at(qual) }
  )

  let result = if qual == none {
    emph(body)
  } else {
    qualified(body, illumination: illumination, qualifier: qual)
  }

  if illumination != none {
    _illuminate(result, type: illumination)
  } else {
    result
  }
}

#let syntax-rule(
  meta-id: none,
  example: none,
  definition-list: none,
) = context {
  code-example(example)
  linebreak()
  meta-identifier(meta-id)

  let indent = 1
  for (i, item) in definition-list.enumerate() {
    if type(item) == dictionary {
      indent = 1 * item.indent
    } else {
      linebreak()

      h(indent * 1em)

      if type(item) == content {
        _trim-content(item)
      }
    }
  }
}

#let ebnf(
  body,
  definition-separator-symbol: _definition-separator-symbols.sym-vertical,
  delimiter-symbol: _delimiter-symbols.sym-delim-3,
  default-font: _fonts.font-default,
  monospaced-font: _fonts.font-monospaced,
) = {
  _update-config("sym-separator", definition-separator-symbol)
  _update-config("sym-delim", delimiter-symbol)
  _update-config("font-default", default-font)
  _update-config("font-monospaced", monospaced-font)

  body
}
