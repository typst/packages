/// Creates a `codepoint` object.
///
/// You can convert a `codepoint` to content using its `show` field:
/// ```example
/// #codepoint("¤").show
/// ```
#let codepoint(code) = {
  if type(code) != int {
    code = str.to-unicode(code)
  }

  // Make sure the value is within the Unicode codespace.
  if not (0 <= code and code <= 0x10FFFF) {
    panic(upper(str(code, base: 0x10)) + " is not a valid codepoint")
  }

  import "internals.typ"
  let (block-data, codepoint-data, aliases) = internals.get-data(code)

  let it = (
    code: code,
    id: {
      let id = upper(str(code, base: 16))
      while id.len() < 4 {
        id = "0" + id
      }
      id
    },
    name: codepoint-data.at(0, default: none),
    general-category: codepoint-data.at(1, default: none),
    canonical-combining-class: codepoint-data.at(2, default: none),
    math-class: codepoint-data.at(3, default: none),
    block: if block-data != none {
      (
        start: block-data.at(0),
        last: block-data.at(1),
        name: block-data.at(2),
      )
    },
    aliases: (
      corrections: aliases.at(0),
      controls: aliases.at(1),
      alternates: aliases.at(2),
      figments: aliases.at(3),
      abbreviations: aliases.at(4),
    ),
    info: (
      aliases: aliases.at(5),
    ),
  )

  (
    ..it,
    "show": {
      set text(lang: "en", region: "US", dir: ltr)
      [U+#it.id]
      sym.space.nobreak
      if it.name == none {
        "<unused>"
      } else if it.name.starts-with("<") {
        it.name
      } else {
        // The displayed character is surrounded with bidi isolation characters.
        "\u{2068}"
        str.from-unicode(it.code)
        "\u{2069}"
        sym.space
        smallcaps(all: true, it.name)
      }
    },
  )
}
