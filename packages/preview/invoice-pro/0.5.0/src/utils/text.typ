// Plain text of values that may be content: for the e-invoice XML, the PDF
// metadata, the EPC-QR payload and anything else that needs a string.

/// The characters XML 1.0 does not allow in a document, not even escaped, as
/// the content of a character class: the one definition of them, which the
/// serializer of the e-invoice combines with the markup characters.
///
/// -> str
#let invalid-xml-class = "\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x{FFFE}\\x{FFFF}"

/// A pattern of the characters of `invalid-xml-class`.
///
/// -> regex
#let invalid-xml-chars = regex("[" + invalid-xml-class + "]")
/// A pattern of the texts `plain-text` returns as they are: printable ASCII
/// words with single spaces between them, as most names, numbers and
/// identifiers are. A string it matches needs no conversion.
///
/// -> regex
#let plain-ascii = regex("^[!-~]+(?: [!-~]+)*$")
// Typst sets a hyphen in front of a digit as minus sign (U+2212) after an
// expression or styled text, e.g. in `[#{2026}-001]`. The hyphens U+2010 and
// U+2011 look the same. In plain text, e.g. an identifier, all of them are
// the ASCII hyphen-minus.
#let _hyphens = regex("[\\x{2010}\\x{2011}\\x{2212}]")
// A space or operator in a part of a fraction or root, which then needs
// parentheses, e.g. "a+b" in "(a+b)/2". Spaces of math are collected as " ".
// (No regular expression: this module is loaded for every invoice, and a
// class with characters beyond ASCII takes a third of a millisecond to
// compile, while math is rare.)
#let _compound = (
  " ",
  "+",
  "*",
  "/",
  "=",
  "<",
  ">",
  "-",
  "\u{2212}",
  "\u{00B1}",
  "\u{00B7}",
  "\u{00D7}",
  "\u{00F7}",
  "\u{22C5}",
)
#let _space = [ ].func()
#let _sequence = [*a* b].func()

// Scripts of math as Unicode superscripts and subscripts, e.g. "m²".
#let _superscripts = (
  "0": "⁰",
  "1": "¹",
  "2": "²",
  "3": "³",
  "4": "⁴",
  "5": "⁵",
  "6": "⁶",
  "7": "⁷",
  "8": "⁸",
  "9": "⁹",
  "+": "⁺",
  "-": "⁻",
  "−": "⁻",
  "=": "⁼",
  "(": "⁽",
  ")": "⁾",
  // Primes (`f'`) are attached as superscripts already.
  "′": "′",
)
#let _subscripts = (
  "0": "₀",
  "1": "₁",
  "2": "₂",
  "3": "₃",
  "4": "₄",
  "5": "₅",
  "6": "₆",
  "7": "₇",
  "8": "₈",
  "9": "₉",
  "+": "₊",
  "-": "₋",
  "−": "₋",
  "=": "₌",
  "(": "₍",
  ")": "₎",
)

// A script of math, e.g. `2` in `x^2`: in Unicode superscript or subscript
// characters if there are any for all of its characters ("²"), otherwise
// after `sign` ("^n", "^(n+1)").
#let _script(text, characters, sign) = {
  if text == "" { return "" }
  let clusters = text.clusters()
  let result = ""
  for cluster in clusters {
    let script = characters.at(cluster, default: none)
    if script == none {
      return sign + if clusters.len() == 1 { text } else { "(" + text + ")" }
    }
    result += script
  }
  result
}

// The text of a part of a fraction or root, in parentheses if it has more
// than one term, e.g. "(a+b)".
#let _grouped(text) = {
  for character in _compound {
    if text.contains(character) { return "(" + text + ")" }
  }
  text
}

// Collects the visible text of a value, see `plain-text`. Line and paragraph
// breaks become `newline`.
#let _collect-text(it, newline) = {
  if it == none or it == auto { return "" }
  let kind = type(it)
  if kind == str { return it }
  if kind in (int, float, decimal) { return str(it) }
  if kind == datetime { return it.display() }
  if kind == symbol { return str(it) }
  if kind == array {
    let parts = ()
    for value in it { parts.push(_collect-text(value, newline)) }
    return parts.join(" ", default: "")
  }
  if kind != content { return "" }

  let func = it.func()
  // `text`, `raw` and symbols (e.g. the `--` shorthand) carry their text,
  // math operators such as `sin` carry it as content.
  if it.has("text") {
    return if type(it.text) == str { it.text } else {
      _collect-text(it.text, newline)
    }
  }
  if func == smartquote {
    return if it.at("double", default: true) { "\"" } else { "'" }
  }
  if func in (linebreak, parbreak) { return newline }
  if func in (_space, h, v) { return " " }
  if func == footnote { return "" }

  // Math as it reads: "1/2", "√2", "x²", "f′".
  if func == math.frac {
    return (
      _grouped(_collect-text(it.num, newline))
        + "/"
        + _grouped(_collect-text(it.denom, newline))
    )
  }
  if func == math.root {
    let index = _collect-text(it.at("index", default: none), newline)
    let sign = if index in ("", "2") { "√" } else if index == "3" {
      "∛"
    } else if index == "4" { "∜" } else {
      _script(index, _superscripts, "") + "√"
    }
    return sign + _grouped(_collect-text(it.radicand, newline))
  }
  if func == math.attach {
    let part(name) = _collect-text(it.at(name, default: none), newline)
    return (
      _script(part("tl"), _superscripts, "^")
        + _script(part("bl"), _subscripts, "_")
        + part("base")
        + _script(part("b") + part("br"), _subscripts, "_")
        + _script(part("t") + part("tr"), _superscripts, "^")
    )
  }
  if func == math.primes { return "′" * it.count }

  if it.has("children") {
    let parts = ()
    for child in it.children { parts.push(_collect-text(child, newline)) }
    return parts.join(default: "")
  }
  if it.has("body") { return _collect-text(it.body, newline) }
  if it.has("child") { return _collect-text(it.child, newline) }

  // Any other element: the text of its content fields in order.
  let parts = ()
  for value in it.fields().values() {
    if type(value) == content { parts.push(_collect-text(value, newline)) }
  }
  parts.join(default: "")
}

/// Extracts the plain text of a value as it reads on the page.
///
/// Works for strings, numbers and arbitrary content, including styled text,
/// emphasis, links, boxes, smart quotes, line breaks and math (`$1/2$` reads
/// "1/2", `$x^2$` reads "x²"). Characters XML cannot carry are removed, and a
/// minus sign or hyphen that Typst sets instead of a hyphen-minus becomes
/// "-", so that identifiers such as `[#{2026}-001]` keep their ASCII hyphen.
///
/// Whitespace is collapsed, so the result can be written into a single XML
/// text node. With `keep-newlines: true`, line breaks (`\n` in a string,
/// `linebreak()` and paragraph breaks in content) are kept as `"\n"`: spaces
/// are collapsed within each line, each line is trimmed, and empty lines at
/// the start and end are removed. This keeps the lines of multi-line texts
/// such as payment terms (BT-20).
///
/// -> str
#let plain-text(it, keep-newlines: false) = {
  // The common values without the recursion of `_collect-text`, whose text
  // they have: a string, a single text (e.g. `[Consulting]`), or a sequence
  // of texts and spaces (e.g. `[Travel & more]`).
  let collected = none
  if type(it) == str { collected = it } else if type(it) == content {
    let func = it.func()
    if func == text { collected = it.text } else if func == _sequence {
      collected = ""
      for child in it.children {
        let kind = child.func()
        if kind == text { collected += child.text } else if kind == _space {
          collected += " "
        } else {
          collected = none
          break
        }
      }
    }
  }
  // Printable ASCII words with single spaces: there is nothing to remove,
  // replace or collapse.
  if collected != none and plain-ascii in collected { return collected }
  if collected == none {
    collected = _collect-text(it, if keep-newlines { "\n" } else { " " })
  }
  let result = collected.replace(invalid-xml-chars, "").replace(_hyphens, "-")
  // `split()` splits at runs of whitespace and drops them at both ends: the
  // words joined by single spaces are the text with its whitespace collapsed
  // and trimmed. (No pattern: the class `\s` of all Unicode whitespace takes
  // more than a third of a millisecond to compile, and this module is loaded
  // for every invoice.)
  if not keep-newlines { return result.split().join(" ", default: "") }
  let lines = ()
  for line in result.replace("\r\n", "\n").replace("\r", "\n").split("\n") {
    lines.push(line.split().join(" ", default: ""))
  }
  lines.join("\n").trim("\n")
}
