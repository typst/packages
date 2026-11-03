// rendering/controls.typ — Control structures (loops, conditionals)
// Contains repeat, repeat-until, forever, if-then-else blocks.

#import "colors.typ": scratch-block-options, get-colors-from-options, get-stroke-from-options, get-font-from-options
#import "icons.typ": icons
#import "geometry.typ": block-height, block-offset-y, corner-radius, content-inset, notch-spacing, block-path
#import "pills.typ": number-or-content
#import "blocks.typ": condition

// Alias to avoid shadowing by function parameters named `condition`
#let _condition-fn = condition

// ------------------------------------------------
// Common helper for loop and conditional blocks
// ------------------------------------------------
#let conditional-block(
  header-label,
  first-body: none, // First body (loop content or "then" branch)
  middle-notch: false,
  middle-label: none, // "else" label (only for if-block)
  second-body: none, // Second body (only "else" branch for if-block)
  bottom-notch: true,
  first-inset-notch: true,
  second-inset-notch: true,
  block-type: "loop", // "loop" or "if"
) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let font-family = get-font-from-options(options)

  block(
    above: 0em,
    below: 0mm,
  )[
    #set text(font: font-family, colors.text-color, weight: 500)

    #let first-body = if first-body not in (none, []) {
      first-body
    } else { box(height: 0.5 * block-height, width: 0cm) }

    #let second-body = if second-body not in (none, []) {
      second-body
    } else { box(height: 0.5 * block-height, width: 0cm) }

    #let header-box = align(horizon, box(inset: content-inset, height: auto, header-label))
    #let middle-box = if middle-label != none {
      align(horizon, box(inset: content-inset, height: 0.5 * block-height + corner-radius, middle-label))
    } else { none }

    #context [
      #let header-box-sizes = measure(header-box)
      #let middle-box-sizes = if middle-box != none { measure(middle-box) } else { none }

      #let header-height = if header-box-sizes.height > block-height {
        header-box-sizes.height
      } else {
        block-height
      }

      #let middle-height = if middle-box-sizes != none {
        if middle-box-sizes.height > 0.5 * block-height {
          middle-box-sizes.height
        } else {
          block-height
        }
      } else { 0mm }

      #let first-body-sizes = measure(first-body)
      #let second-body-sizes = measure(second-body)

      #let first-height = if first-body != none { first-body-sizes.height - corner-radius - corner-radius } else { 0mm }
      #let second-height = if second-body != none { second-body-sizes.height - corner-radius - corner-radius } else { 0mm }

      // Path prefix based on block type
      #let path-prefix = if block-type == "if" { "if" } else { "loop" }

      // Draw header and body
      #place(top + left, dy: block-offset-y)[
        #curve(
          fill: colors.control.primary,
          stroke: (paint: colors.control.tertiary, thickness: stroke-thickness),
          ..block-path(header-height, header-box-sizes.width, path-prefix + "-header"),
          curve.line((0mm, first-height), relative: true),
          ..if middle-label != none {
            (
              ..block-path(middle-height, header-box-sizes.width, path-prefix + "-middle", bottom-notch: first-inset-notch),
              curve.line((0mm, second-height), relative: true),
            )
          },
          ..block-path(header-height, header-box-sizes.width, path-prefix + "-footer", bottom-notch: bottom-notch, top-notch: second-inset-notch),
        )
      ]
      #if block-type == "loop" {
        place(bottom + left, dx: header-box-sizes.width - 0.5 * block-height)[
          #image(icons.repeat, height: 0.5 * block-height)
        ]
      }

      // Render content — each element with its own height
      #box(height: header-height, header-box)
      #block(
        above: 0em,
        below: 0em,
        inset: (bottom: if middle-label == none { 3mm + 2 * corner-radius } else { corner-radius }),
        move(dx: 2 * notch-spacing, first-body),
      )
      #if middle-label != none {
        box(height: middle-height, middle-box)
        block(
          above: 0em,
          below: 0em,
          inset: (bottom: 3mm + 2 * corner-radius),
          move(dx: 2 * notch-spacing, second-body),
        )
      }
    ]
  ]
}

// ------------------------------------------------
// Repeat n times
// ------------------------------------------------
#let repeat(count: 10, body: none, labels: (repeat: "repeat", times: "times")) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, labels.repeat, number-or-content(count, colors.control), labels.times)],
    first-body: body,
  )
}

// ------------------------------------------------
// Repeat until condition
// ------------------------------------------------
#let repeat-until(condition, body: none, labels: (repeat-until: "repeat until")) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, labels.at("repeat-until"), if condition != [] { condition } else { _condition-fn(colorschema: colors.control, []) })],
    first-body: body,
  )
}

// ------------------------------------------------
// Repeat forever (infinite loop)
// ------------------------------------------------
#let repeat-forever(body, labels: (forever: "forever")) = conditional-block(
  [#stack(dir: ltr, spacing: 1.5mm, labels.forever)],
  first-body: body,
  bottom-notch: false,
)

// ------------------------------------------------
// If-then-else block
// ------------------------------------------------
#let if-then-else(
  condition,
  then: none,
  else-body: none,
  then-end: false,
  else-end: false,
  labels: ("if-then": "if", then: "then", "else": "else"),
) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, labels.at("if-then"), if condition != [] { condition } else { _condition-fn(colorschema: colors.control, []) }, labels.then)],
    first-body: then,
    middle-label: if else-body != none { [#stack(dir: ltr, spacing: 1.5mm, labels.at("else"))] } else { none },
    second-body: else-body,
    block-type: "if",
    first-inset-notch: not else-end,
    second-inset-notch: not then-end,
  )
}

