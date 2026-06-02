#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/showybox:2.0.4": showybox
#import "../src/keyle.typ"

#set document(date: none)
#set page(margin: 0.5cm, width: auto, height: auto)

#let example-scope = (keyle: keyle)
#let frame(..args) = showybox(
  frame: (
    border-color: gray,
    title-color: black,
    thickness: .5pt,
    inset: 8pt,
  ),
  ..args,
)

/// Generate a keyboard renderer and code sources.
#let example-with-source(source, vertical: false, title: []) = {
  let rendered = frame(align(eval(source.text, mode: "markup", scope: example-scope), horizon))
  let code = [#title #sourcecode(source, lang: "typ")]
  block(
    if vertical {
      align(
        center,
        stack(
          dir: ttb,
          spacing: 1em,
          align(left, code),
          block(
            width: 100%,
            rendered,
            inset: 1em,
          ),
        ),
      )
    } else {
      table(
        columns: (1fr, 1fr),
        align: horizon,
        stroke: none,
        code, rendered,
      )
    },
    breakable: false,
  )
}

/// Generate a pure keyboard renderer.
#let example(source, vertical: false, title: []) = {
  let rendered = eval(source.text, mode: "markup", scope: example-scope)
  rendered
}

#show raw.where(lang: "example"): text => {
  example(raw(text.text, lang: "typc"))
}

#example(
  ```tpy
  #let kbd = keyle.config()
  #kbd("Ctrl", "Shift", "K", delim: "-")
  ```,
  title: [== Custom Delimiter],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config()
  #kbd("Ctrl", "Shift", "K", compact: true)
  ```,
  title: [== Compact Mode],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.standard)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Standard Theme],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.deep-blue)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Deep Blue Theme],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.type-writer)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Type Writer Theme],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.biolinum, delim: keyle.biolinum-key.delim_plus)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Biolinum Theme],
)
#pagebreak()

#example(
  ```tpy
  // https://www.radix-ui.com/themes/playground#kbd
  #let radix_kdb(content) = box(
    rect(
      inset: (x: 0.5em),
      outset: (y:0.05em),
      stroke: rgb("#1c2024") + 0.3pt,
      radius: 0.35em,
      fill: rgb("#fcfcfd"),
      text(fill: black, font: (
        "Roboto",
        "Helvetica Neue",
      ), content),
    ),
  )
  #let kbd = keyle.config(theme: radix_kdb)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Custom Theme],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.minimal)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Minimal Theme],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.radix)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Radix Theme],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.flowbite)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Flowbite Theme (SVG)],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.flowbite-dark)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Flowbite Dark Theme (SVG)],
)
#pagebreak()

#example(
  ```tpy
  #let kbd = keyle.config(theme: keyle.themes.daisy)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Daisy Theme (SVG)],
)
#pagebreak()

#example(
  ```tpy
  // Extend any preset with `.with(...)`.
  #let rose = keyle.themes.flowbite.with(
    fill: rgb("#fee2e2"),
    stroke: rgb("#fca5a5"),
    text-args: (fill: rgb("#991b1b"), weight: "bold"),
  )
  #let kbd = keyle.config(theme: rose)
  #keyle.gen-examples(kbd)
  ```,
  title: [== Customize with .with()],
)
#pagebreak()

#example(
  ```tpy
  // SVG glyphs are just another kind of `sym`.
  #let kbd = keyle.config(theme: keyle.themes.flowbite)
  #kbd(keyle.svg-key.up) #kbd(keyle.svg-key.down)
  #kbd(keyle.svg-key.left) #kbd(keyle.svg-key.right)
  #kbd(keyle.svg-key.enter) #kbd(keyle.svg-key.backspace)
  #kbd(keyle.svg-key.tab) #kbd(keyle.svg-key.win)
  ```,
  title: [== SVG Key Glyphs],
)