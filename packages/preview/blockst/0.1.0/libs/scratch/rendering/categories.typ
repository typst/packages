// rendering/categories.typ — Category wrapper blocks, event blocks, reporters,
//                              custom blocks, variable/list monitors

#import "colors.typ": scratch-block-options, get-colors-from-options, get-stroke-from-options
#import "icons.typ": icons
#import "geometry.typ": block-height, block-offset-y, corner-radius, content-inset, notch-spacing, block-path
#import "pills.typ": number-or-content, pill-reporter, pill-round
#import "blocks.typ": scratch-block, condition

// ------------------------------------------------
// Category wrappers (statement blocks)
// ------------------------------------------------

// Generic base: one function drives all plain category statement blocks.
// `color-key` must match a field name in the colors dictionary (e.g. "motion").
#let category-statement(color-key, body, bottom-notch: true) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  scratch-block(
    colorschema: colors.at(color-key),
    type: "statement",
    dy: block-offset-y,
    bottom-notch: bottom-notch,
    body,
  )
}

// Thin aliases — preserved for call-site compatibility
#let motion(body)              = category-statement("motion",    body)
#let looks(body)               = category-statement("looks",     body)
#let sound(body)               = category-statement("sound",     body)
#let sensing(body)             = category-statement("sensing",   body)
#let control(body, bottom-notch: true) = category-statement("control", body, bottom-notch: bottom-notch)
#let variables(body)           = category-statement("variables", body)
#let lists(body)               = category-statement("lists",     body)
#let pen(body)                 = category-statement("pen",       body)

// custom() has its own dark-mode logic — kept separate
#let custom(body, dark: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  scratch-block(
    colorschema: if dark {
      (primary: colors.custom.secondary, tertiary: colors.custom.tertiary)
    } else {
      colors.custom
    },
    type: "statement",
    dy: block-offset-y,
    body,
  )
}

// ------------------------------------------------

// ------------------------------------------------
// Event blocks
// ------------------------------------------------
#let event(body, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  scratch-block(colorschema: colors.events, type: "event", body, children)
}

// When green flag clicked
#let event-green-flag(children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  scratch-block(
    colorschema: colors.events,
    type: "event",
    grid(columns: 3, gutter: 0.5em, align: horizon, [Wenn], box(image(icons.green-flag)), [angeklickt wird]),
    children,
  )
}

// When key pressed
#let event-key-pressed(key, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  scratch-block(
    colorschema: colors.events,
    type: "event",
    stack(dir: ltr, spacing: 1.5mm, "Wenn", pill-rect(key, fill: colors.events.primary, stroke: colors.events.tertiary + stroke-thickness, dropdown: true), "gedrückt wird"),
    children,
  )
}

// When sprite clicked
#let event-sprite-clicked(children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  scratch-block(
    colorschema: colors.events,
    type: "event",
    stack(dir: ltr, spacing: 1.5mm, "Wenn diese Figur angeklickt wird"),
    children,
  )
}

// When backdrop switches to
#let event-backdrop-switches-to(name, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  scratch-block(
    colorschema: colors.events,
    type: "event",
    stack(dir: ltr, spacing: 1.5mm, "Wenn das Bühnenbild zu", pill-rect(name, fill: colors.events.primary, stroke: colors.events.tertiary + stroke-thickness, dropdown: true), "wechselt"),
    children,
  )
}

// When greater than threshold
#let event-greater-than(element, value, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  scratch-block(
    colorschema: colors.events,
    type: "event",
    stack(dir: ltr, spacing: 1.5mm, "Wenn", pill-rect(element, fill: colors.events.primary, stroke: colors.events.tertiary + stroke-thickness, dropdown: true), ">", number-or-content(value, colors.events)),
    children,
  )
}

// When I receive message
#let event-message-received(message, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  scratch-block(
    colorschema: colors.events,
    type: "event",
    stack(dir: ltr, spacing: 1.5mm, "Wenn ich", pill-rect(message, fill: colors.events.primary, stroke: colors.events.tertiary + stroke-thickness, dropdown: true), "empfange"),
    children,
  )
}

// Event statement block (no hat)
#let event-statement(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  scratch-block(colorschema: colors.events, type: "statement", dy: block-offset-y, body)
}

// Broadcast message
#let broadcast-message(message, wait: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  event-statement(
    stack(dir: ltr, spacing: 1.5mm, "sende", pill-reporter(message, fill: colors.events.secondary, stroke: colors.events.tertiary + stroke-thickness, dropdown: true, inline: true), if wait {
      "an alle und warte"
    } else { "an alle" }),
  )
}

// When I start as a clone (event shape with control colors)
#let when-i-start-as-clone(children, label: "when I start as a clone") = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  scratch-block(colorschema: colors.control, type: "event", [#label], children)
}

// Create clone of
#let create-clone-of(element: "mir selbst") = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  control(
    stack(dir: ltr, spacing: 1.5mm, "erstelle Klon von", pill-reporter(element, fill: colors.control.secondary, stroke: colors.control.tertiary + stroke-thickness, dropdown: true, inline: true)),
  )
}

// ------------------------------------------------

// ------------------------------------------------
// Reporter blocks (value blocks)
// ------------------------------------------------
// Generic reporter function for all categories
#let reporter(colorschema: auto, body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let final-colorschema = if colorschema == auto { colors.looks } else { colorschema }

  pill-reporter(
    fill: final-colorschema.primary,
    stroke: final-colorschema.tertiary + stroke-thickness,
    text-color: colors.text-color,
    if dropdown-content != none {
      pill-round(fill: none, stroke: none, text-color: colors.text-color, inset: (x: 0mm, y: 0.5mm), stack(dir: ltr, spacing: pill-spacing, box(inset: (left: pill-inset-x), body), pill-reporter(
        dropdown-content,
        fill: final-colorschema.secondary,
        stroke: final-colorschema.tertiary + stroke-thickness,
        text-color: colors.text-color,
        dropdown: true,
        inline: true,
      )))
    } else {
      pill-round(body, fill: none, stroke: none, text-color: colors.text-color, inset: (x: 1.5mm, y: 0.5mm))
    },
  )
}

// Category-specific reporters — thin aliases over the generic reporter()
#let motion-reporter(body, dropdown-content: none)    = context { let c = get-colors-from-options(scratch-block-options.get()); reporter(colorschema: c.motion,    body, dropdown-content: dropdown-content) }
#let looks-reporter(body, dropdown-content: none)     = context { let c = get-colors-from-options(scratch-block-options.get()); reporter(colorschema: c.looks,     body, dropdown-content: dropdown-content) }
#let sound-reporter(body, dropdown-content: none)     = context { let c = get-colors-from-options(scratch-block-options.get()); reporter(colorschema: c.sound,     body, dropdown-content: dropdown-content) }
#let sensing-reporter(body, dropdown-content: none)   = context { let c = get-colors-from-options(scratch-block-options.get()); reporter(colorschema: c.sensing,   body, dropdown-content: dropdown-content) }
#let variables-reporter(body, dropdown-content: none) = context { let c = get-colors-from-options(scratch-block-options.get()); reporter(colorschema: c.variables, body, dropdown-content: dropdown-content) }
#let lists-reporter(body, dropdown-content: none)     = context { let c = get-colors-from-options(scratch-block-options.get()); reporter(colorschema: c.lists,     body, dropdown-content: dropdown-content) }
#let custom-reporter(body, dropdown-content: none)    = context { let c = get-colors-from-options(scratch-block-options.get()); reporter(colorschema: c.custom,    body, dropdown-content: dropdown-content) }
#let pen-reporter(body, dropdown-content: none)       = context { let c = get-colors-from-options(scratch-block-options.get()); reporter(colorschema: c.pen,       body, dropdown-content: dropdown-content) }


// ------------------------------------------------
// Parameter reporter (pink) for custom block parameters
// ------------------------------------------------
#let parameter(name) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  pill-round(name, fill: colors.custom.primary, stroke: colors.custom.tertiary + stroke-thickness)
}

// ------------------------------------------------
// Custom blocks
// ------------------------------------------------
// White argument placeholder for custom blocks
#let custom-input(text) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  pill-round(text, stroke: colors.custom.tertiary + stroke-thickness)
}

// Creates a custom statement block with text and placeholders.
// Usage:
//   #let my-block = custom-block("rotate", custom-input("degrees"))
//   #my-block(45)[ ... ]
#let custom-block(..body) = {
  let items = body.pos()
  return (dark: true, ..values) => context {
    let options = scratch-block-options.get()
    let colors = get-colors-from-options(options)
    let stroke-thickness = get-stroke-from-options(options)

    custom(dark: dark, {
      let values = values.pos()
      stack(
        dir: ltr,
        spacing: 1.5mm,
        ..if values.len() == 0 {
          for item in items {
            if std.type(item) == str {
              (item,)
            } else if std.type(item) == dictionary {
              (pill-round(stroke: colors.custom.tertiary, fill: colors.custom.primary, text-color: colors.text-color, item.name),)
            } else {
              (pill-round(stroke: colors.custom.tertiary, fill: colors.custom.primary, text-color: colors.text-color, str("number or text")),)
            }
          }
        } else {
          let key = 0
          for item in items {
            if std.type(item) == str {
              (item,)
            } else {
              (number-or-content(values.at(calc.rem(key, values.len())), colors.custom),)
              key += 1
            }
          }
        },
      )
    })
  }
}

// Define block header (signature for custom block definitions)
#let define(block-label, verb: "define", ..children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  scratch-block(
    colorschema: colors.custom,
    type: "define",
    dy: 2.5 * corner-radius,
    stack(dir: ltr, spacing: 1.5mm, verb, block-label(dark: true)),
    ..children,
  )
}


// ------------------------------------------------
// Variable monitor (visual display like in Scratch)
// ------------------------------------------------
#let variable-monitor(name: "Variable", value: 0) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  box(
    fill: rgb("#E5F0FF"),
    stroke: (paint: gray, thickness: 0.5pt),
    radius: 5pt,
    inset: (x: 5pt, y: 3pt),
  )[
    #set text(size: 9pt, font: "Helvetica Neue", weight: 500)
    #grid(
      columns: (auto, auto),
      column-gutter: 4pt,
      align: left + horizon,
      text(fill: rgb("#4C4C4C"), weight: 600, name),
      box(
        fill: colors.variables.primary,
        stroke: colors.variables.tertiary + stroke-thickness,
        radius: 4pt,
        inset: (x: 5pt, y: 2pt),
        text(fill: colors.text-color, str(value)),
      ),
    )
  ]
}

// ------------------------------------------------
// List monitor (visual display like in Scratch)
// ------------------------------------------------
#let list-monitor(name: "List", items: (), width: 4cm, height: auto, length-label: "Length") = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  let len = items.len()

  box(
    width: width,
    fill: rgb("#E5F0FF"),
    stroke: (paint: gray, thickness: 0.5pt),
    radius: 5pt,
    clip: true,
  )[
    #set text(size: 9pt, font: "Helvetica Neue", weight: 500)
    // Header with name
    #box(
      fill: white,
      width: 100%,
      inset: 5pt,
      align(center)[
        #text(fill: rgb("#4C4C4C"), weight: 600, name)
      ],
    )
    // List items
    #box(height: height, clip: true, inset: (x: 2mm))[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 8pt,
        row-gutter: 2pt,
        align: left + horizon,
        ..items
          .enumerate()
          .map(((index, item)) => {
            (
              grid.cell(str(index + 1)),
              grid.cell(box(
                width: 100%,
                height: 5mm,
                fill: colors.lists.primary,
                stroke: colors.lists.tertiary + stroke-thickness,
                radius: 3pt,
                inset: 3pt,
                align(left, text(fill: colors.text-color, item)),
              )),
            )
          })
          .flatten(),
      )
    ]
    // Footer with length
    #box(
      fill: white,
      width: 100%,
      align(center)[
        #grid(
          columns: (auto, 1fr, auto),
          column-gutter: 5pt,
          inset: 5pt,
          align: (left + horizon, center + horizon, right + horizon),
          text(fill: rgb("#4C4C4C"), size: 8pt, "+"), text(fill: rgb("#4C4C4C"), size: 8pt, weight: 600, [#length-label: #len]), text(fill: rgb("#4C4C4C"), size: 8pt, "="),
        )
      ],
    )
  ]
}
