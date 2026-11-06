#import "@preview/tableau-icons:0.334.1": ti-icon

#let chribel-callout-templates = state("chribel-callout-templates", (
  // quarto based callouts
  info: (
    color: rgb("#2780e3"),
    icon: "info-circle",
    placeholder: context (de: "Information").at(text.lang, default: "Information"),
  ),
  warning: (
    color: rgb("#ff7518"),
    icon: "alert-triangle",
    placeholder: context (de: "Warnung").at(text.lang, default: "Warning"),
  ),
  important: (
    color: rgb("#ff0039"),
    icon: "exclamation-circle",
    placeholder: context (de: "Wichtig").at(text.lang, default: "Important"),
  ),
  tip: (
    color: rgb("#3fb618"),
    icon: "bulb",
    placeholder: context (de: "Tipp").at(text.lang, default: "Tip"),
  ),
  caution: (
    color: rgb("#f0ad4e"),
    icon: "traffic-cone",
    placeholder: context (de: "Vorsicht").at(text.lang, default: "Caution"),
    
  ),
  
  // my callouts
  correct: (
    color: green.darken(5%),
    icon: "check",
    placeholder: context (de: "Korrekt").at(text.lang, default: "Correct"),
  ),
  incorrect: (
    color: red.darken(5%),
    icon: "x",
    placeholder: context (de: "Inkorrekt").at(text.lang, default: "Incorrect"),
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
    old.insert(name,config)
    old
  })
}



#let callout(style: "minimal", type: "info", title: none, content, width: 100%, height: auto, icon: auto, paint: none, func: none) = context {
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

  if std.type(func) == function {
    return func(title,ti-icon(icon),content,paint,height,width)
  }

  align(center,
  if style == "minimal" {
    block(
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
    )
  } else if style == "quarto" {
   
    block(
      width: width,
      height: height,
      stroke: (left: paint+2pt, rest: paint+0.5pt),
      radius: 3pt,
      clip: true,
      inset: (left: 1pt, right: 0.25pt),
      grid(rows: (1.5em,height),
        align: left+horizon,
        
        block(
          inset: (left: 0.25em),
          fill: paint.lighten(85%),
          width: 100%,
          height: 100%)[#box(ti-icon(icon, fill:paint,baseline: -0.33em),height: 0pt) #text(strong(title), rgb("#343a40"))],
        block(content, inset: (0.5em))
      )
    )
  })
  if style == "compact" {
    box(outset: (y:0.3em), inset: (x: 0.2em), radius: 0.3em,fill: paint.lighten(85%),)[#box(ti-icon(icon, fill:paint,baseline: -0.825em),height: 0pt) #text(strong(title), rgb("#343a40"))] + h(0.4em, weak: true) + content
  }
}
