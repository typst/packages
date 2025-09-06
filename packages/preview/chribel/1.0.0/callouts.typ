#import "@preview/tableau-icons:0.334.1": ti-icon

#let chribel-callout-templates = state("chribel-callout-templates", (
  info: (
    color: blue,
    icon: "info-circle",
    placeholder: context (de: "Information").at(text.lang, default: "Information"),
  ),
  warning: (
    color: rgb("#fa8e46"),
    icon: "alert-triangle",
    placeholder: context (de: "Warnung").at(text.lang, default: "Warning"),
  ),
  correct: (
    color: olive,
    icon: "check",
    placeholder: context (de: "Korrekt").at(text.lang, default: "Correct"),
  ),
  incorrect: (
    color: rgb("#CB4154"),
    icon: "x",
    placeholder: context (de: "Inkorrekt").at(text.lang, default: "Incorrect"),
  ),
  tip: (
    color: rgb("#4169E1"),
    icon: "bulb",
    placeholder: context (de: "Tipp").at(text.lang, default: "Tip"),
  ),
  example: (
    color: rgb("#966FD6"),
    icon: "tools",
    placeholder: context (de: "Beispiel").at(text.lang, default: "Example"),
  ),
))

#let chribel-add-callout-template(name, config) = context {

  if type(config) != dictionary {
    panic("given config is not a dictionary")
  }

  if (config.keys().map(x => x not in ("color","icon","placeholder")).any(n => n)) {
    panic("config must have 'color', 'icon' and 'placeholder' keys and respective values")
  }

  if type(name) != str {
    panic("template name must be a string")
  }

  if ((type(config.at("color")) != color) or (type(config.at("icon")) != str) or (type(config.at("placeholder")) != str)) {
    panic("config values are not of correct type - expected (color: color, icon: str,placeholder: str)")
  }

  chribel-callout-templates.update(old => {
    old.insert("dog", (color: red, icon: "dog", placeholder: "hello"))
    old
  })
}


#let callout(type: "info", title: none, content, width: 100%, height: auto, icon: auto, paint: none) = context {
  let radius = 3pt
  let inset = (top: 8pt, rest: 6pt)

  let config = chribel-callout-templates.final().at(type, default: (
    color: gray,
    icon: "question-mark",
    placeholder: context (de: "Kein Zugehöriger Titel").at(text.lang, default: "No Associated Title"),
  ))

  let paint = if paint == none { config.color } else { paint }
  let icon = if icon == auto { config.icon } else { icon }
  let title = if title == none { config.placeholder } else { title }

  set text(0.9em)

  align(center, block(
    above: 1.5em,
    below: 1.5em,
    width: width,
    height: height,
    stroke: paint + 0.5pt,
    inset: inset,
    radius: radius,
    {
      set align(left)
      // title block
      place(top + left, dy: -inset.top - 0.5em, dx: -1pt, box(
        fill: white,
        inset: if icon != none { (left: 1pt, right: 2pt) } else { (x: 2pt) },
        outset: (y: 1pt),


        grid(
          column-gutter: 2pt, align: center + horizon,
          columns: if icon == none {
            auto
          } else {
            (1em, auto)
          }, rows: 1em,
          ..(
            if icon != none {
              (ti-icon(icon, fill: paint),)
            }
              + (text(weight: "bold", paint, title),)
          )
        ),
      ))
      content
    },
  ))
}
