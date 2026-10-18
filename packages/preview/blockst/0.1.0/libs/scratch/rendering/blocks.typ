// rendering/blocks.typ — scratch-block renderer and condition (diamond) shape
// Contains the core scratch-block() and condition() functions.

#import "colors.typ": scratch-block-options, get-colors-from-options, get-stroke-from-options, get-font-from-options
#import "geometry.typ": block-height, block-offset-y, content-inset, pill-height, pill-inset-x, pill-inset-y, pill-spacing, corner-radius, block-path
#import "pills.typ": pill-round, pill-reporter

// ------------------------------------------------
// Internal scratch-block function (takes explicit params)
// ------------------------------------------------
#let scratch-block-internal(colorschema, type: "event", top-notch: true, bottom-notch: true, dx: 0mm, dy: 0mm, font-family: "Helvetica Neue", body, children-array, colors, stroke-thickness) = block(
  above: 0em + if (type == "event" or type == "define") { 6mm } else { 0mm },
  below: 0mm + if (type == "event" or type == "define") { 6mm } else { 0mm },
)[
  #set text(font: font-family, colors.text-color, weight: 500)
  #let content-box = align(horizon, box(
    inset: content-inset,
    height: if type == "define" { 1.5 * block-height } else { auto },
    [
      #context [
        #let content-height = measure(body).height
        #let min-height = 0.75 * block-height
        #box(body, height: calc.max(content-height, min-height))
      ]
    ],
  ))
  #context [
    #let (width, height) = measure(content-box)
    #place(top + left, dx: dx, dy: dy)[
      #curve(
        fill: colorschema.primary,
        stroke: (paint: colorschema.tertiary, thickness: stroke-thickness),
        ..block-path(height, width, type, bottom-notch: bottom-notch, top-notch: top-notch),
      )
    ]
  ]
  #content-box
  #v(dy, weak: true)
  #if children-array.len() != none {
    for child in children-array {
      if std.type(child) == content {
        child
      }
    }
  }
]

// ------------------------------------------------
// Public scratch-block function (uses state)
// ------------------------------------------------
#let scratch-block(colorschema: auto, type: "event", top-notch: true, bottom-notch: true, dx: 0mm, dy: 0mm, body, ..children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let font-family = get-font-from-options(options)
  let final-colorschema = if colorschema == auto { colors.motion } else { colorschema }

  scratch-block-internal(
    final-colorschema,
    type: type,
    top-notch: top-notch,
    bottom-notch: bottom-notch,
    dx: dx,
    dy: dy,
    font-family: font-family,
    body,
    children.pos(),
    colors,
    stroke-thickness,
  )
}

// ------------------------------------------------
// Condition (diamond shape for boolean values)
// ------------------------------------------------
#let condition(colorschema: auto, type: "condition", body, nested: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let font-family = get-font-from-options(options)
  let final-colorschema = if colorschema == auto { colors.control } else { colorschema }

  set text(font: font-family, colors.text-color, weight: 500)
  box([
    // nested can be bool (both sides same) or (left, right) array
    #let nested-type = std.type(nested)
    #let (nested-left, nested-right) = if nested-type == array {
      (nested.at(0), nested.at(1))
    } else {
      (nested, nested)
    }
    #let x-inset-left = if nested-left { -0.5 } else { -0.1 }
    #let x-inset-right = if nested-right { -0.25 } else { -0.05 }
    #let content-box = if body != [] {
      let body = if std.type(body) != array { (body,) } else { body }
      box(inset: (left: pill-inset-x * x-inset-left, right: pill-inset-x * x-inset-right, y: pill-inset-y), align(horizon, [
        #grid(
          columns: (body.len() * 2 + 1) * (auto,),
          column-gutter: 1fr,
          align: center + horizon,
          h(pill-spacing),
          ..body.map(x => { (x, h(0.25em)) }).flatten(),
          h(pill-spacing),
        )
      ]))
    } else { box(height: pill-height, width: pill-height) }

    #context [
      #let (width, height) = measure(content-box, height: auto)
      #let height = if height < block-height and body != [] {
        block-height * 0.9
      } else if height < block-height {
        pill-height
      } else {
        height
      }
      #place(bottom + left)[
        #if body != [] {
          curve(
            fill: final-colorschema.primary,
            stroke: (paint: final-colorschema.tertiary, thickness: stroke-thickness),
            ..block-path(height, width, type),
          )
        } else {
          curve(
            fill: final-colorschema.tertiary,
            stroke: none,
            ..block-path(pill-height, pill-height, type),
          )
        }
      ]
      #box(width: width + 0.5 * height, height: height, align(horizon, content-box))
    ]
  ])
}
