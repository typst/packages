#import "/src/lib.typ": *

#let entrypoint = toml("/typst.toml").package.entrypoint
#let usage = "#import \"/" + entrypoint + "\": *\n"

#let example(source) = {
  grid(
    columns: (2fr, 1fr),
    rows: auto,
    align: center + horizon,
    gutter: 5pt,
    {
      // set text(0.9em)
      // raw(block: true, lang: "typst", source)
      source
    },
    rect(
      width: 100%,
      inset: 10pt,
      eval(usage + source.text, mode: "markup"),
    ),
  )
}

#let example-vstack(source) = {
  eval(usage + source.text, mode: "markup")
  source
}
