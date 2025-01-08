/*
  File: display.typ
  Author: neuralpain
  Date Modified: 2025-01-08

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
  pgmt-page-setup(bg: bg, {
    set page(footer: align(center)[
      #let svg-h = 5mm // logo height
      #if bg == white {
        image("../assets/logo/pigmentpedia-icon.svg", height: svg-h)
      } else {
        // converting to hex string because luma value will
        // not match hex value even though it's the same color
        let ccl = get-contrast-color(bg).to-hex() // contrast color logo
        if ccl == black.to-hex() {
          image("../assets/logo/pigmentpedia-icon-black.svg", height: svg-h)
        } else if ccl == white.to-hex() {
          image("../assets/logo/pigmentpedia-icon-white.svg", height: svg-h)
        }
      }
    ])
    if type(color) != "color" {
      pgmt-error.not-a-color
    } else {
      align(center + horizon)[
        #rect(height: 60%, width: 80%, radius: 25pt, fill: color, text(fill: get-contrast-color(color), size: 4em, weight: "bold", raw(upper(color.to-hex()))))
      ]
    }
  })
}

/// Search through the `scope` to find the color to pigment
/// to display for the user.
///
/// - pgmt-group (dictionary): The pigment group to search from.
/// -> content
#let get-pigments-to-display(pgmt-group) = {
  for (name, color) in pgmt-group {
    if (type(color) == "color") {
      block(
        ..colorbox-block-properties, stroke: 2pt + color,
        stack(spacing: 5mm, rect(..colorbox, fill: color), name, raw(upper(color.to-hex()))),
      )
    } else {
      block(
        ..colorbox-block-properties,
        stack(rect(radius: 100%, width: 100%, stroke: 1pt + black, pad(y: 8mm, align(center)[#pigment(black, name)]))),
      )
      get-pigments-to-display(color)
    }
  }
}

/// Show a visual list of colors to select from.
///
/// ```typ
/// #view-pigments(NCS)
/// #view-pigments(Zhongguo.en)
/// ```
///
/// Display a single pigment on a page.
///
/// ```typ
/// #view-pigments(Zhongguo.en.Blue.Violet-Blue)
/// ```
///
/// - scope (dictionary, color): Pigment group or color to display.
/// - bg (color): The color of the page background. This is
///   used to choose a contrast color for the text based on
///   the background color.
/// -> content
#let view-pigments(scope, bg: white) = {
  pgmt-page-setup(bg: bg, {
    // catch any pigments entered by the user
    // this is an anticipated user error turned feature
    if type(scope) == "color" {
      view-pigment(scope, bg: bg)
      return
    }

    if type(scope) != "dictionary" {
      pgmt-error.not-a-pgmt-group
      return
    }

    set page(columns: 3)

    if scope != pigmentpedia {
      block(
        ..colorbox-block-properties,
        stack(rect(radius: 100%, width: 100%, stroke: 1pt + get-contrast-color(bg), pad(y: 8mm, align(center)[#pigment(black, get-pgmt-group-name(scope, bg: bg))])))
      )
    }

    get-pigments-to-display(scope)
  })
}
