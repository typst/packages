#let _namespace = "nutthead.ebnf"

#let _whitespace = regex("^\\s$")

#let _sym-prod = symbol(sym.arrow.r)

#let _qualifier-syms = (
  sym-opt: "?",
  sym-some: "+",
  sym-any: "*",
)

#let _bracket-syms = (
  sym-rounded: (open: "(", close: ")"),
  sym-curly: (open: "{", close: "}"),
  sym-square: (open: "[", close: "]"),
  sym-comment: (open: "(*", close: "*)"),
  sym-special: (open: "?", close: "?"),
)

#let _definition-separator-syms = (
  sym-vertical: "|",
  sym-solidus: "/",
  sym-exclamation: "!",
)

#let _delimiter-syms = (
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

// Φ               ≈ 1.618 \
// $root(4, Φ)$    ≈ 1.127 \
// 1em     / 1.127 ≈ 0.887em \
// 0.887em / 1.127 ≈ 0.787
#let _fonts = (
  font-default: (family: "Libertinus Serif", size: 1em),
  font-monospaced: (family: "Dejavu Sans Mono", size: 0.887em),
)

#let _configuration = state(_namespace, (
  sym-prod: _sym-prod,
  .._qualifier-syms,
  .._bracket-syms,
  .._definition-separator-syms,
  sym-separator: _definition-separator-syms.at("sym-vertical"),
  sym-delim: _delimiter-syms.sym-delim-3,
  .._delimiter-syms,
  .._colors,
  .._illuminations,
  .._fonts,
))

#let _error(message) = {
  panic("Error: " + message)
}

#let _assert-some(value) = {
  assert.ne(value, none, message: "Error: expected some, got none")
}

#let _assert-key(key) = {
  let config = _configuration.get()
  let keys = config.keys()
  if key not in keys {
    let keys = keys.join(", ")
    _error("key must be one of " + keys + ", but got: " + repr(key))
  }
}

#let _get-config(key) = {
  _assert-some(key)
  _assert-key(key)

  let config = _configuration.get()
  let keys = config.keys()

  config.at(key)
}

#let _update-config(key, value) = {
  if key == none {
    _assert-some(name, "expected key to be some, but got: " + repr(name))
  }

  if (value == none) {
    _assert-some(name, "expected value to be some, but got: " + repr(name))
  }

  _configuration.update(it => {
    it.insert(key, value)
    it
  })
}

#let _to-sym-key(key) = {
  _assert-some(key)
  "sym-" + key
}

#let _get-sym(key) = {
  _get-config(_to-sym-key(key))
}

#let _to-illum-key(key) = {
  _assert-some(key)
  "illum-" + key
}

#let _get-illum-color(key) = {
  _get-config(_to-illum-key(key))
}

#let _to-font-key(key) = {
  if key == none {
    _assert-some(key, "expected key to be some, but got: " + repr(key))
  } else {
    "font-" + key
  }
}

#let _get-font(key) = {
  _get-config(_to-font-key(key))
}

#let _validate-opt-key(key) = {
  if key == none {
    return
  }

  let keys = _configuration.get().keys()
  if key not in keys {
    _error("key must be one of " + keys.join(", ") + ", but got: " + repr(key))
  }
}

#let _validate-key(key) = {
  _assert-some(key)
  _validate-opt-key(key)
}

#let _is-space(input) = {
  if type(input) == content {
    input == [ ]
  } else {
    input.match(_whitespace) != none
  }
}

#let _to-string(content) = {
  if type(content) == str {
    return content
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(_to-string).join("")
  } else if content.has("body") {
    _to-string(content.body)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}

#let _trim-str(input) = {
  while input.len() > 0 and input.first().match(_whitespace) != none {
    input = input.slice(1)
  }

  while input.len() > 0 and input.last().match(_whitespace) != none {
    input = input.slice(0, input.len() - 1)
  }

  input
}

#let _trim-content(input) = {
  if not input.has("children") {
    return input
  }

  let children = input.children

  while children.len() > 0 and _is-space(children.first()) {
    children = children.slice(1)
  }

  while children.len() > 0 and _is-space(children.last()) {
    children = children.slice(0, children.len() - 1)
  }

  children.join()
}

#let _trim(input) = {
  if type(input) == content {
    _trim-content(input)
  } else {
    _trim-str(input)
  }
}

#let _get-def-separator-sym() = {
  _get-sym("separator")
}

#let _illuminate(body, type: none) = {
  let result = if type == none {
    text(body)
  } else {
    let illumination = _get-illum-color(type)
    text(body, fill: illumination)
  }

  result
}

#let _bracketify(body, type: none) = {
  let bracket = _get-sym(type)
  let open = bracket.open
  let close = bracket.close

  open + " " + body + " " + close
}

#let _qualify(body, type: none) = {
  let q = _get-sym(type)
  body + super[#q]
}

#let _decorate(body, bracket-type: none, qualifier-type: none, illumination-type: none) = {
  let b = if bracket-type == none { body } else { _bracketify(body, type: bracket-type) }
  let q = if qualifier-type == none { b } else { _qualify(b, type: qualifier-type) }
  _illuminate(q, type: illumination-type)
}

#let _is-terminal(item) = {
  type(item) == dictionary and item.has("kind") and item.kind == "terminal"
}

#let _has-kind(item) = {
  type(item) == dictionary and item.has("kind")
}

#let _mono(body) = {
  let font = _get-font("monospaced")
  let family = font.family
  let size = font.size
  text(font: family, size: size)[#body]
}

#let _regular(body) = {
  let font = _get-font("default")
  let family = font.family
  let size = font.size
  text(font: family, size: size)[#body]
}

#let terminal(body, illumination: none, qualifier: none) = {
  let delimiter = _get-sym("delim")
  let value = if qualifier == none {
    _mono(delimiter + body + delimiter)
  } else {
    _qualify(_mono(delimiter + body + delimiter), type: qualifier)
  }

  if illumination == none { value } else { _illuminate(value, type: illumination) }
}

#let code-example(raw) = {
  let comment-sym = _get-sym("comment")
  let open = comment-sym.open
  let close = comment-sym.close
  open + " " + raw + " " + close
}

#let comment(body) = {
  let comment-sym = _get-sym("comment")
  let open = comment-sym.open
  let close = comment-sym.close
  open + " " + body + " " + close
}

#let meta-identifier(body) = {
  let prod = _get-sym("prod")
  strong(body) + " " + prod
}

#let single-definition(..body, illumination: none, qualifier: none) = {
  let joined = body.pos().map(it => if _is-terminal(it) { it.value } else { emph(it) }).join(" ")
  _decorate(joined, illumination-type: illumination, qualifier-type: qualifier)
}

#let grouped-sequence(..body, illumination: none, qualifier: none) = {
  let alt = " " + _get-sym("separator") + " "
  let joined = body.pos().join(alt)
  _decorate(joined, bracket-type: "rounded", illumination-type: illumination, qualifier-type: qualifier)
}

#let optional-sequence(..body, illumination: none, qualifier: none) = {
  let alt = " " + _get-sym("separator") + " "
  let joined = body.pos().join(alt)
  _decorate(joined, bracket-type: "square", illumination-type: illumination, qualifier-type: qualifier)
}

#let repeated-sequence(..body, illumination: none, qualifier: none) = {
  let alt = " " + _get-sym("separator") + " "
  let joined = body.pos().join(alt)
  _decorate(joined, bracket-type: "curly", illumination-type: illumination, qualifier-type: qualifier)
}

#let special-sequence(..body, illumination: none, qualifier: none) = {
  let alt = " " + _get-sym("separator") + " "
  let joined = body.pos().join(alt)
  _decorate(joined, bracket-type: "special", illumination-type: illumination, qualifier-type: qualifier)
}

#let syntax-rule(
  meta-id: none,
  rule-example: none,
  rule-comment: none,
  definition-list: none,
) = context {
  if rule-comment == none {
    none
  } else {
    comment(rule-comment)
    linebreak()
  }

  if rule-example == none {
    none
  } else {
    code-example(rule-example)
    linebreak()
  }

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
   definition-separator-symbol: _definition-separator-syms.sym-vertical,
   delimiter-symbol: _delimiter-syms.sym-delim-3,
   default-font: _fonts.font-default,
   monospaced-font: _fonts.font-monospaced,
 ) = {
   _update-config("sym-separator", definition-separator-symbol)
   _update-config("sym-delim", delimiter-symbol)
   _update-config("font-default", default-font)
   _update-config("font-monospaced", monospaced-font)
   body
 }
