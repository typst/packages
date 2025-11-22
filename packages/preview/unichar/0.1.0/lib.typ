/// Create a `codepoint` object.
///
/// You can convert a to content `codepoint` using its `show` field:
/// ```example
/// #codepoint("¤").show
/// ```
#let codepoint(code) = {
  if type(code) != int {
    code = str.to-unicode(code)
  }

  import "ucd/index.typ"
  let data = index.get-data(code)

  let (block, codepoint-data) = data

  let it = (
    code: code,
    name: codepoint-data.at(0, default: none),
    general-category: codepoint-data.at(1, default: none),
    canonical-combining-class: codepoint-data.at(2, default: none),
    block: block,
  )

  (
    ..it,
    "show": {
      let str-code = upper(str(it.code, base: 16))
      while str-code.len() < 4 {
        str-code = "0" + str-code
      }
      raw("U+" + str-code)
      sym.space.nobreak
      if it.name == none {
        "<unused>"
      } else if it.name.starts-with("<") {
        it.name
      } else {
        // The character appears bigger without increasing line height.
        text(size: 1.2em, top-edge: "x-height", str.from-unicode(it.code))
        sym.space
        smallcaps(lower(it.name))
      }
    },
  )
}
