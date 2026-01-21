#import "/src/lib.typ": *

#let entrypoint = toml("/typst.toml").package.entrypoint
#let usage = "#import \"/" + entrypoint + "\": *\n" + "#show: mannot-init\n"

#let example(source) = {
  grid(
    columns: (2fr, 1fr),
    rows: (auto),
    align: center + horizon,
    gutter: 5pt,
    {
      set text(0.8em)
      raw(block: true, lang: "typst", source)
    },
    rect(
      width: 100%,
      inset: 10pt,
      eval(usage + source, mode: "markup"),
    ),
  )
}
