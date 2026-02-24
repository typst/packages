#import "@preview/tableau-icons:0.336.0": ti-icon

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

#let radius = 3pt
#let inset = (top: 8pt, rest: 6pt)

#let callout-styles = (
  // My own created style :)
  "minimal": (title,icon,content,paint,height,width) => align(
    center, block(
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
  ),

  // inline version
  "compact": (title,icon,content,paint,height,width) => {
    let inset = 0.3em
    box(
      outset: (inset),
      inset: (right: 0.0em),
      radius: 0.3em,
      fill: paint.lighten(85%),
      (place(horizon+left, dx: -inset/2, ti-icon(icon, fill:paint))) + h(1em) +
      text(strong(title), rgb("#343a40"),)
      
    ) + h(2 * inset) + content
  },
  
  // the callout styling from the extended Markdown format "Quarto" (https://quarto.org/docs/authoring/callouts.html)
  "quarto": (title,icon,content,paint,height,width) => align(
    center, block(
      width: width,
      height: height,
      stroke: (left: paint+3pt, rest: paint+0.5pt),
      radius: 3pt,
      clip: true,
      inset: (left: 1.5pt, right: 0.25pt),
      grid(
        columns: (1.5em, 1fr),
        rows: (1.5em,height),
        fill: (x,y) => if y == 0 { paint.lighten(85%) } else { none },
        align: (center+horizon, left+horizon),
        ti-icon(icon, fill:paint),
        grid.cell(text(strong(title), rgb("#343a40"))),
        grid.cell(colspan: 2, align: left+top, block(width: 100%, content, inset: (0.5em)))
      )
    )
  )
)

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



#let callout(style: "minimal", type: "info", title: none, content, width: 100%, height: auto, icon: auto, paint: none) = context {
  let templates = chribel-callout-templates.final()

  assert(
    (std.type(style) == function) or (std.type(style) == str and style in ("minimal","compact","quarto")),
    message: "`style` is neither a function or of a valid string: \"minimal\", \"compact\", \"quarto\"."
  )

  let config = chribel-callout-templates.final().at(type, default: (
    color: gray,
    icon: "question-mark",
    placeholder: context (de: "Kein Zugehöriger Titel").at(text.lang, default: "No Associated Title"),
  ))

  let paint = if paint == none { config.color } else { paint }
  let icon = if icon == auto { config.icon } else { icon }
  let title = if title == none { config.placeholder } else { title }

  if std.type(style) == function {
    // calls custom function
    return style(title,ti-icon(icon),content,paint,height,width)
  } else {
    // Callout Library predefined styles
    return (callout-styles.at(style))(title,icon,content,paint,height,width)
  }

  
}
