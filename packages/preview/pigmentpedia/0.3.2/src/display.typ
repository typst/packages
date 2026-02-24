/*
  File: display.typ
  Author: neuralpain
  Date Modified: 2025-04-20

  Description: Module for collecting and
  displaying pigments to the user.
*/

#import "private.typ": *
#import "pigments.typ": *
#import "text-contrast.typ": get-contrast-color

/// Display a single pigment on a page.
///
/// This function has been made private and integrated
/// within `view-pigments()` as to prevent confusion with
/// the end users.
///
/// ```typ
/// #view-pigment(RAL.Chocolate-Brown)
/// ```
///
/// - color (color): Pigment color value.
/// - bg (color): The color of the page background. This is
///   used to choose a contrast color for the text based on
///   the background color.
/// -> content
#let view-pigment(color, bg: white) = {
  pgmt-page-setup(
    bg: bg,
    {
      set page(
        footer: align(center)[
          #let svg-h = 5mm // logo height
          #if bg == white {
            image(pgmt-icon-svg, height: svg-h)
          } else {
            image(bytes(pgmt-icon(get-contrast-color(bg))), height: svg-h)
          }
        ],
      )

      align(center + horizon)[
        #rect(
          height: 60%,
          width: 80%,
          radius: 25pt,
          fill: color,
          text(fill: get-contrast-color(color), size: 4em, weight: "bold", raw(upper(color.to-hex()))),
        )
      ]
    },
  )
}

/// Collect pigments to display to the user.
///
/// - pgmt-group (dictionary): The pigment group or scope to search within.
/// - bg (color): Page background color.
/// -> content
#let display-pigments-from(pgmt-group, bg) = {
  // pigment name formatting
  let output-caps   = false
  let output-hyphen = false

  for (name, color) in pgmt-group {
    if name == "output" {
      output-caps   = color.caps
      output-hyphen = color.hyphen
      continue
    }

    if type(color) == color {
      block(
        ..colorbox-block-properties,
        stroke: 2pt + color,
        stack(
          spacing: 5mm,
          rect(..colorbox, fill: color),
          format-pigment-name(name, output-caps, output-hyphen),
          raw(upper(color.to-hex())),
        ),
      )
    } else {
      block(
        ..colorbox-block-properties,
        stack(
          rect(
            radius: 100%,
            width: 100%,
            stroke: 1pt + get-contrast-color(bg),
            pad(
              y: 8mm,
              align(center)[
                #format-pigment-name(name, output-caps, output-hyphen)
              ],
            ),
          ),
        ),
      )
      display-pigments-from(color, bg)
    }
  }
}

/// Show a visual list of colors to select from.
///
/// ```typ
/// #view-pigments(ncs)
/// #view-pigments(zhongguo.en)
/// ```
///
/// Display a single pigment on a page.
///
/// ```typ
/// #view-pigments(zhongguo.en.blue.violet-blue)
/// ```
///
/// - scope (dictionary, color): Pigment group or color to display.
/// - bg (color): Page background color. Default is white.
/// -> content
#let view-pigments(scope, bg: white) = {
  if type(bg) != color {
    pgmt-error.bg-not-a-color
    return
  }

  // catch any pigments entered by the user
  if type(scope) == color {
    view-pigment(scope, bg: bg)
    return
  }

  if type(scope) != dictionary {
    pgmt-error.not-a-pgmt-group
    return
  }

  pgmt-page-setup(
    bg: bg,
    {
      set page(columns: 3)

      if scope != pigmentpedia {
        block(
          ..colorbox-block-properties,
          stack(
            rect(
              radius: 100%,
              width: 100%,
              stroke: 1pt + get-contrast-color(bg),
              pad(y: 8mm, align(center)[#get-pgmt-group-name(scope, bg: bg)]),
            ),
          ),
        )
      }

      display-pigments-from(scope, bg)
    },
  )
}
