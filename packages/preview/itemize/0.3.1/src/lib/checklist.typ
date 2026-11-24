/// See: https://github.com/OrangeX4/typst-cheq

/// Gets the color for checklist items
///   - color (auto, color): The color to evaluate. If `auto`, uses text color
#let get-color(color) = {
  if color == auto { text.fill } else { color }
}

#let box-baseline = if sys.version >= version(0, 15, 0) { (baseline: (at: bottom, shift: 0.05em)) } else { (:) }

/// Creates an unchecked checkbox symbol
#let unchecked(fill: auto, radius: .1em, solid: none) = context [
  #set text(dir: ltr, baseline: 0pt)
  #box(
    stroke: .05em + get-color(fill),
    height: 0.8em,
    width: 0.8em,
    radius: radius,
    fill: solid,
    ..box-baseline,
  )]

/// Creates a checked checkbox symbol with checkmark
#let checked(fill: auto, radius: .1em, solid: none) = context [
  #set text(dir: ltr, baseline: 0pt)
  #box(
    stroke: .05em + get-color(fill),
    height: 0.8em,
    width: 0.8em,
    radius: radius,
    fill: solid,
    ..box-baseline,
    {
      set align(right + top)
      move(dy: .43em, dx: -.45em, rotate(45deg, reflow: false, line(
        length: 0.26em,
        stroke: .1em + get-color(fill),
      )))
      move(dy: -.78em, dx: -0.08em, rotate(-45deg, reflow: false, line(
        length: 0.48em,
        stroke: .1em + get-color(fill),
      )))
    },
  )]

/// Creates an incomplete/partially-checked checkbox symbol
#let incomplete(fill: auto, radius: .1em, solid: none) = context [
  #set text(dir: ltr, baseline: 0pt)
  #box(
    stroke: .05em + get-color(fill),
    height: 0.8em,
    width: 0.8em,
    radius: radius,
    clip: true,
    fill: solid,
    ..box-baseline,
    align(left, box(fill: get-color(fill), height: 1em, width: .42em)),
  )]


/// Creates a canceled/disabled checkbox symbol
#let canceled(fill: auto, radius: .1em, solid: none) = context [
  #set text(dir: ltr, baseline: 0pt)
  #box(
    stroke: .05em + get-color(fill),
    height: 0.8em,
    width: 0.8em,
    radius: radius,
    ..box-baseline,
    align(center + horizon, box(height: .125em, width: 0.55em, fill: get-color(fill))),
    fill: solid,
  )]

/// Creates small centered text for symbol rendering
#let small-text(body, ..args) = box(width: 0.8em, height: 0.8em, {
  set align(center + horizon)
  set text(top-edge: "bounds", bottom-edge: "bounds", ..args)
  body
})


/// Creates a character-based symbol (e.g., emoji or letter)
#let character-symbol(symbol: none, fill: auto, radius: .1em, solid: none) = context box(
  stroke: .05em + get-color(fill),
  height: 0.8em,
  width: 0.8em,
  radius: radius,
  fill: solid,
  ..box-baseline,
  [#small-text(symbol, fill: get-color(fill))],
)

/// Defines basic checklist symbols (checked, unchecked, incomplete, canceled)
#let basic-symbol(fill: auto, radius: 0.1em, solid: none) = (
  "x": checked(fill: fill, radius: radius, solid: solid),
  " ": unchecked(fill: fill, radius: radius, solid: solid),
  "/": incomplete(fill: fill, radius: radius, solid: solid),
  "-": canceled(fill: fill, radius: radius, solid: solid),
)

/// Extended symbol mapping for special characters
#let extend-symbol = (
  ">": "➡",
  "<": "📆",
  "?": "❓",
  "!": "❗",
  "*": "⭐",
  "\"": "❝",
  "l": "📍",
  "b": "🔖",
  "i": "ℹ️",
  "S": "💰",
  "I": "💡",
  "p": "👍",
  "c": "👎",
  "f": "🔥",
  "k": "🔑",
  "w": "🏆",
  "u": "🔼",
  "d": "🔽",
)

/// Creates the complete symbol map combining basic and extended symbols
///
/// Parameters:
///   - fill (auto, color): Default symbol color
///   - radius (length): Default corner radius
///   - solid (none, color): Default background fill
///   - extras (bool): Whether to include extended symbols (default: false)
#let default-symbol-map(fill: auto, radius: 0.1em, solid: none, extras: false) = {
  (
    if extras { for (k, v) in extend-symbol { (str(k): small-text(v)) } }
      + basic-symbol(fill: fill, radius: radius, solid: solid)
  )
}

/// Default formatting rules for special checklist items
///
/// Returns:
///   A dictionary mapping format keys to their styling functions
///
/// Current Formatting:
///   - "-": Applies strikethrough with gray color
#let default-format-map = (
  "-": it => strike(text(fill: rgb("#888888"), it)),
)
