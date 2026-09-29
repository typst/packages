// README result images: each page renders ONLY the result of one README
// code block (the code itself lives in README.md as a markdown block).
// Compiled by `just example` into example/example-{n}.png.
#import "/src/keyle.typ"

#set document(date: none)
#set page(width: auto, height: auto, margin: 0.45cm, fill: white)
#set text(size: 11pt, font: ("Helvetica Neue", "TeX Gyre Heros"))

#let example-scope = (keyle: keyle, kbd: keyle.kbd)

#let result(source) = box(
  inset: 14pt,
  stroke: 0.4pt + luma(215),
  radius: 5pt,
  fill: luma(254),
  eval(source.text, mode: "markup", scope: example-scope),
)

// --- example-1: quick start ----------------------------------------------

#result(```typ
#kbd("Ctrl", "Shift", "P") #h(0.8em) #kbd("Ctrl+Alt+T")

#kbd("cmd", "shift", "P") #h(0.8em) #kbd("up") #kbd("down")

#let mac = keyle.config(layout: "mac", delim: none)
#mac("Ctrl+Alt+Del") #h(0.8em) #mac("cmd+Q")
```)

#pagebreak()

// --- example-2: built-in themes ------------------------------------------

#box(
  inset: 14pt,
  stroke: 0.4pt + luma(215),
  radius: 5pt,
  fill: luma(254),
  grid(
    columns: (4.2cm,) * 3,
    column-gutter: 0.7em,
    row-gutter: 0.8em,
    ..keyle
      .themes
      .pairs()
      .map(pair => {
        let name = pair.at(0)
        let theme = pair.at(1)
        let kbd = keyle.config(
          theme: theme,
          delim: if name == "biolinum" { keyle.biolinum-key.delim_plus } else { "+" },
        )
        box(
          width: 100%,
          inset: 9pt,
          stroke: 0.3pt + luma(225),
          radius: 4pt,
          align(center)[
            #text(size: 8.5pt, fill: luma(100), raw(name))
            #v(0.4em)
            #kbd("Ctrl", "K")
          ],
        )
      }),
  ),
)

#pagebreak()

// --- example-3: extending a theme with .with() ---------------------------

#result(```typ
#let rose = keyle.themes.flowbite.with(
  fill: rgb("#fee2e2"),
  stroke: rgb("#fca5a5"),
  text-args: (fill: rgb("#991b1b"), weight: "bold"),
)
#let kbd = keyle.config(theme: rose)
#kbd("Ctrl", "S") #h(0.8em) #kbd("Ctrl", "Shift", "S")
```)

#pagebreak()

// --- example-4: svg key glyphs -------------------------------------------

#result(```typ
#let kbd = keyle.config(theme: "flowbite")
#kbd(keyle.svg-key.up) #kbd(keyle.svg-key.down)
#kbd(keyle.svg-key.left) #kbd(keyle.svg-key.right)
#kbd(keyle.svg-key.enter) #kbd(keyle.svg-key.backspace)
#kbd(keyle.svg-key.tab) #kbd(keyle.svg-key.win)
```)
