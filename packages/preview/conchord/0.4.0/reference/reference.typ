#import "@preview/tidy:0.4.3"

#show heading.where(level: 1): set heading(numbering: "1.")
#show heading.where(level: 1): set block(below: 1em, above: 2em)
#show heading.where(level: 2): set block(inset: (left: -1em))

#let render(mod_name) = {
  let module = eval(
    "import \"" + mod_name + "\";" + mod_name.split("/").at(-1).split(".").at(0)
  )
  import mod_name as mod
  let docs = tidy.parse-module(read(mod_name), scope: dictionary(module))
  let ts = tidy.styles.default
  import "style.typ"
  tidy.show-module(docs, style: style, show-outline: false, colors: ts.colors, sort-functions: (i => i.description.split().at(0)), omit-private-definitions: true)
}

#align(center, text(size: 3em, [*`conchord` reference*]))
#v(2em)

= Chord tabstring generation
#render("../gen/gen.typ")

= Chord drawing
#render("../chords/draw-chord.typ")

= Smart chord
#render("../chords/smart-chord.typ")

= Song sheets
#render("../chords/sheet.typ")

= Tabs
#render("../tabs/tabs.typ")