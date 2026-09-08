#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/keyle:0.3.0"

#set document(date: none)
#set page(width: 22cm, height: auto, margin: 1cm)
#set text(size: 8.5pt, font: ("Helvetica Neue", "TeX Gyre Heros"))

#let example-scope = (keyle: keyle)
#let code-col = 1.05fr
#let result-col = 0.95fr

#let result-frame(body) = box(
  width: 100%,
  inset: 12pt,
  stroke: 0.4pt + luma(215),
  radius: 5pt,
  fill: luma(252),
  align(horizon + center)[#body],
)

#let demo-row(source, result: none) = {
  let rendered = if result != none {
    result
  } else {
    eval(source.text, mode: "markup", scope: example-scope)
  }
  table(
    columns: (code-col, result-col),
    column-gutter: 0.9em,
    align: (top, horizon),
    stroke: none,
    inset: (x: 0pt, y: 3pt),
    [#sourcecode(source, lang: "typ")],
    result-frame(rendered),
  )
}

#let theme-showcase() = grid(
  columns: 3,
  column-gutter: 0.65em,
  row-gutter: 0.75em,
  ..keyle.themes.pairs().map(pair => {
    let name = pair.at(0)
    let theme = pair.at(1)
    let kbd = keyle.config(
      theme: theme,
      delim: if name == "biolinum" { keyle.biolinum-key.delim_plus } else { "+" },
    )
    box(
      width: 100%,
      inset: 8pt,
      stroke: 0.3pt + luma(225),
      radius: 4pt,
      align(center)[
        #text(size: 7.5pt, fill: luma(100))[#name]
        #v(0.35em)
        #kbd("Ctrl", "K")
      ],
    )
  }),
)

#demo-row(```typ
#import "@preview/keyle:0.3.0"

#let kbd = keyle.config()
#kbd("Ctrl", "Shift", "P")

#let kbd = keyle.config()
#kbd("Ctrl", "Alt", "T", compact: true)

#let kbd = keyle.config(delim: " ")
#kbd("Ctrl", "Shift", "P")
```)

#pagebreak()

#demo-row(
  ```typ
  #let kbd = keyle.config(theme: keyle.themes.flowbite)
  #kbd("Ctrl", "K")

  // Available: standard, deep-blue, type-writer,
  // minimal, radix, flowbite, flowbite-dark,
  // daisy, biolinum
  ```,
  result: theme-showcase(),
)

#pagebreak()

#block(below: 0pt)[
  #demo-row(```typ
  #let rose = keyle.themes.flowbite.with(
    fill: rgb("#fee2e2"),
    stroke: rgb("#fca5a5"),
    text-args: (fill: rgb("#991b1b"), weight: "bold"),
  )
  #let kbd = keyle.config(theme: rose)
  #kbd("Ctrl", "S") #h(1em)
  #kbd("Ctrl", "Shift", "S")
  ```)

  #v(0.85em)

  #demo-row(```typ
  #let my-theme(content) = box(
    rect(
      inset: (x: 0.5em),
      stroke: rgb("#1c2024") + 0.3pt,
      radius: 0.35em,
      fill: rgb("#fcfcfd"),
      text(content),
    ),
  )
  #let kbd = keyle.config(theme: my-theme)
  #kbd("⌘", "D") #h(1em)
  #kbd("^", "F")
  ```)

  #v(0.85em)

  #demo-row(```typ
  #let kbd = keyle.config(theme: keyle.themes.flowbite)
  #kbd(keyle.svg-key.up) #kbd(keyle.svg-key.down)
  #kbd(keyle.svg-key.left) #kbd(keyle.svg-key.right)
  #kbd(keyle.svg-key.enter) #kbd(keyle.svg-key.backspace)
  #kbd(keyle.svg-key.tab) #kbd(keyle.svg-key.win)
  ```)
]
