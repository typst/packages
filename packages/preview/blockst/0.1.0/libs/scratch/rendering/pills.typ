// rendering/pills.typ — Pill primitives and value/content helpers
// Contains all pill shapes (round, reporter, rect, color) and the
// number-or-content helper.

#import "colors.typ": *
#import "icons.typ": icons
#import "geometry.typ": pill-height, pill-inset-x, pill-inset-y, pill-spacing, block-height

// ------------------------------------------------
// Internal base pill function
// ------------------------------------------------
// Accepts explicit colors and stroke-thickness parameters
#let _pill-base-internal(
  fill: white,
  stroke: auto,
  text-color: auto,
  radius: 50%,
  inset: 0mm,
  height: auto,
  dropdown: false,
  body,
  colors: colors-normal,
  stroke-thickness: 0.5pt,
  font-family: "Helvetica Neue",
) = {
  // Default stroke when auto
  let final-stroke = if stroke == auto {
    (paint: black, thickness: stroke-thickness)
  } else {
    stroke
  }

  // Automatic text color:
  // - Explicit value: use as given
  // - White background: use dark gray (normal) or black (high-contrast)
  // - Colored background: use theme text color
  let final-text-color = if text-color != auto {
    text-color
  } else if fill == white or fill == rgb("#FFFFFF") {
    if colors == colors-high-contrast {
      black
    } else {
      rgb("#575E75") // dark gray for normal theme
    }
  } else {
    colors.text-color
  }

  set text(font: font-family, weight: 500)
  box(
    fill: fill,
    stroke: final-stroke,
    radius: radius,
    height: auto,
    inset: inset,
    align(horizon, if dropdown {
      context {
        let height = measure(body).height
        let height = if height < pill-height {
          pill-height
        } else {
          height
        }
        let width = pill-inset-x
        stack(dir: ltr, spacing: pill-spacing, box(height: height, text(final-text-color, body)), image(icons.dropdown-arrow, height: 2mm))
      }
    } else {
      context [
        #let height = measure(body).height
        #let height = if height < pill-height {
          pill-height
        } else {
          height
        }
        #box(height: height, text(final-text-color, body))
      ]
    }),
  )
}

// ------------------------------------------------
// Public base pill function (uses state)
// ------------------------------------------------
#let _pill-base(
  fill: white,
  stroke: auto,
  text-color: auto,
  radius: 50%,
  inset: 0mm,
  height: auto,
  dropdown: false,
  body,
) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let font-family = get-font-from-options(options)

  _pill-base-internal(
    fill: fill,
    stroke: stroke,
    text-color: text-color,
    radius: radius,
    inset: inset,
    height: height,
    dropdown: dropdown,
    body,
    colors: colors,
    stroke-thickness: stroke-thickness,
    font-family: font-family,
  )
}

// ------------------------------------------------
// Public pill variants
// ------------------------------------------------

// White input pills (fixed height, no insets)
#let pill-round(body, stroke: auto, inset: (x: 1.3 * pill-inset-x, y: 1mm), fill: white, text-color: auto) = _pill-base(
  fill: fill,
  stroke: stroke,
  text-color: text-color,
  radius: 50%,
  inset: inset,
  height: auto,
  dropdown: false,
  body,
)

// Colored reporter pills (auto height, reduced insets, min-height 0.8 * block-height)
#let pill-reporter(body, fill: white, stroke: auto, text-color: auto, dropdown: false, inline: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let font-family = get-font-from-options(options)

  // Minimum height for reporters
  let min-height = 0.8 * block-height

  // Prepare body with minimum height
  let prepared-body = context {
    let measured = measure(body)
    if measured.height < min-height {
      box(height: min-height, align(horizon, body))
    } else {
      body
    }
  }

  _pill-base-internal(
    fill: fill,
    stroke: stroke,
    text-color: text-color,
    radius: 50%,
    inset: if inline {
      (x: pill-inset-x, y: 0.7 * pill-inset-y)
    } else {
      (x: 0.4 * pill-inset-x, y: 0.7 * pill-inset-y)
    },
    height: if inline { 100% } else { auto },
    dropdown: dropdown,
    prepared-body,
    colors: colors,
    stroke-thickness: stroke-thickness,
    font-family: font-family,
  )
}

// Rectangular dropdown pills (auto height, reduced insets)
#let pill-rect(body, fill: white, stroke: auto, text-color: auto, dropdown: false, inline: false) = _pill-base(
  fill: fill,
  stroke: stroke,
  text-color: text-color,
  radius: 10%,
  inset: (x: 0.75 * pill-inset-x, y: if inline { 0mm } else { 0.75 * pill-inset-y }),
  height: 0.5 * pill-height,
  dropdown: dropdown,
  body,
)

// Color pills (for color picker)
#let pill-color(body, fill: white) = context {
  let options = scratch-block-options.get()
  let stroke-thickness = get-stroke-from-options(options)

  _pill-base(
    fill: fill,
    stroke: white + stroke-thickness,
    text-color: auto,
    radius: 50%,
    inset: 0mm,
    height: 1.2 * pill-height,
    dropdown: false,
    body,
  )
}

// Legacy pill() function wrapper for compatibility
#let pill(..args, type: "round", stroke: auto, text-color: auto, body, dropdown: false, inset: auto, height: auto, fill: white) = {
  if type == "round" {
    pill-round(body, stroke: stroke, fill: fill, text-color: text-color)
  } else if type == "single" or type == "reporter" {
    pill-reporter(body, fill: fill, stroke: stroke, text-color: text-color, dropdown: dropdown)
  } else if type == "rect" {
    pill-rect(body, fill: fill, stroke: stroke, text-color: text-color, dropdown: dropdown)
  } else if type == "color" {
    pill-color(body, fill: fill)
  }
}

// ------------------------------------------------
// Value/content helper
// ------------------------------------------------
// Converts simple values (string, int, float) into pills,
// leaves content (blocks, reporters, etc.) unchanged.
#let number-or-content(value, colorschema) = {
  let value-type = type(value)
  if value-type == str or value-type == int or value-type == float {
    context {
      let options = scratch-block-options.get()
      let stroke-thickness = get-stroke-from-options(options)

      pill-round(str(value), stroke: colorschema.tertiary + stroke-thickness, inset: (x: 1.3 * pill-inset-x, y: 0.5mm))
    }
  } else {
    value
  }
}


