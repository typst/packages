#import "@preview/codly:1.3.0": *
#show: codly-init
#codly(lang-format: none)

#set text(lang: "ja", font: "Noto Serif JP")
#show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif JP"))

#show raw: set text(font: ("DejaVu Sans Mono", "Noto Sans JP"))
#set page(width: 16cm, height: auto, margin: 2mm, fill: white)
#show table.cell.where(y: 0): it => {
  set text(size: .9em, font: "Noto Sans JP")
  strong(it)
}

#let entrypoint = toml("/typst.toml").package.entrypoint
#let usage = "#import \"/" + entrypoint + "\": *\n" + "#show: cjk-spacer\n"


#let compare(source) = {
  table(
    // columns: (1fr, 1fr, 1fr),
    rows: auto,
    align: center + horizon,
    table.header(
      [Example code],
      [Output (default)],
      [Output (cjk-spacer)],
    ),
    {
      source
    },
    eval(source.text, mode: "markup"),

    eval(usage + source.text, mode: "markup"),
  )
}

#set table(columns: (1fr, 1fr, 1fr))
#compare(```typst
こんにちは
世界
```)
#pagebreak()

#compare(```typst
任意の実数$x$に対して
```)
#pagebreak()

#compare(```typst
タイプスト(Typst)で遊ぶ
```)
#pagebreak()

#[
  #set table(columns: (1.6fr, 1fr, 1fr))
  #compare(```typst
  $
    x^2 >= 0 "ただし" x "は実数" \
    x^2 >= 0 #[ただし $x$ は実数] \
    x^2 >= 0 #box[ただし$x$は実数]
  $
  ```)
]
#pagebreak()

#set table(columns: (1.9fr, 1fr, 1fr))
#compare(```typst
*太字！* の後の空白

#show "^": h(0.25em, weak: true)
*太字！*^の後の空白
```)
