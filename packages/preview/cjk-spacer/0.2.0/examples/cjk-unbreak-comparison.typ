#import "@preview/codly:1.3.0": *
#show: codly-init
#codly(lang-format: none)

#set text(lang: "ja", font: "Noto Sans JP")
#set page(width: 16cm, height: auto, margin: 2mm, fill: white)
#show table.cell.where(y: 0): it => {
  set text(.9em)
  strong(it)
}

#let entrypoint = toml("/typst.toml").package.entrypoint
#let usage = "#import \"/" + entrypoint + "\": *\n" + "#show: cjk-spacer\n"

#let cjk-unbreak-usage = ```typst
#import "@preview/cjk-unbreak:0.2.1": remove-cjk-break-space
#show: remove-cjk-break-space

```


#let compare(source) = {
  table(
    columns: (1fr, 1fr, 1fr),
    rows: auto,
    align: center + horizon,
    table.header([Example code], [Output (cjk-unbreak)], [Output (cjk-spacer)]),
    {
      source
    },
    eval(cjk-unbreak-usage.text + source.text, mode: "markup"),
    eval(usage + source.text, mode: "markup"),
  )
}

#compare(```typst
/ 用語: #[
    説明の途中で
    改行
  ]
```)
