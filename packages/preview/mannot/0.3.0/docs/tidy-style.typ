#import "@preview/tidy:0.4.0"
#import tidy.utilities: *
#import tidy.styles.default: *


#let show-example(
  code,
  scope: (:),
  preamble: "",
  mode: auto,
  inherited-scope: (:),
  col-spacing: 5pt,
  preview-inset: 10pt,
  ..options,
) = {
  let displayed-code = code.text.split("\n").filter(x => not x.starts-with(">>>")).join("\n")
  let executed-code = code.text.split("\n").map(x => x.trim(">>>", at: start)).join("\n")

  let lang = if code.has("lang") { code.lang } else { auto }
  if mode == auto {
    if lang == "typ" { mode = "markup" } else if lang == "typc" { mode = "code" } else if lang == "typm" {
      mode = "math"
    } else if lang == auto { mode = "markup" }
  }
  if lang == auto {
    if mode == "markup" { lang = "typ" }
    if mode == "code" { lang = "typc" }
    if mode == "math" { lang = "typm" }
  }
  if mode != "code" {
    preamble = "#" + preamble
  }
  assert(
    lang in ("typ", "typc", "typm"),
    message: "Previewing code only supports the languages \"typ\", \"typc\", and \"typm\"",
  )

  grid(
    columns: (2fr, 1fr),
    rows: auto,
    align: horizon,
    gutter: col-spacing,
    {
      set text(0.9em)
      raw(displayed-code, lang: lang, block: true)
    },
    rect(
      width: 100%,
      inset: preview-inset,
      {
        set text(font: "Noto Serif")
        eval(preamble + executed-code, mode: mode, scope: scope + inherited-scope)
      },
    ),
  )
}
