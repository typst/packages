
#import "../util/level-state.typ": setting-checklist as setting

/// See: https://github.com/OrangeX4/typst-cheq

/// Gets the effective color for checklist items
///
/// Parameters:
///   - color (auto, color): The color to evaluate. If `auto`, uses text color
#let get-color(color) = {
  if color == auto { text.fill } else { color }
}


/// Creates an unchecked checkbox symbol
///
/// Parameters:
///   - fill (auto, color): Fill color (default: auto)
///   - radius (length): Corner radius (default: 0.1em)
///   - solid (none, color): Inner fill color (default: none)
///
/// Returns:
///   A box element representing an unchecked checkbox
#let unchecked(fill: auto, radius: .1em, solid: none) = context box(
  stroke: .05em + get-color(fill),
  height: 0.8em,
  width: 0.8em,
  radius: radius,
  fill: solid,
)

/// Creates a checked checkbox symbol with checkmark
///
/// Parameters:
///   - fill (auto, color): Stroke color (default: auto)
///   - radius (length): Corner radius (default: 0.1em)
///   - solid (none, color): Inner fill color (default: none)
///
/// Returns:
///   A box element representing a checked checkbox
#let checked(fill: auto, radius: .1em, solid: none) = context box(
  stroke: .05em + get-color(fill),
  height: 0.8em,
  width: 0.8em,
  radius: radius,
  fill: solid,
  align(right + top, {
    box(move(dy: .43em, dx: 0.04em, rotate(45deg, reflow: false, line(length: 0.26em, stroke: get-color(fill) + .1em))))
    box(move(dy: .41em, dx: -0.08em, rotate(-45deg, reflow: false, line(
      length: 0.48em,
      stroke: get-color(fill) + .1em,
    ))))
  }),
)

/// Creates an incomplete/partially-checked checkbox symbol
///
/// Parameters:
///   - fill (auto, color): Stroke and fill color (default: auto)
///   - radius (length): Corner radius (default: 0.1em)
///   - solid (none, color): Background fill (default: none)
#let incomplete(fill: auto, radius: .1em, solid: none) = context box(
  stroke: .05em + get-color(fill),
  height: 0.8em,
  width: 0.8em,
  radius: radius,
  clip: true,
  fill: solid,
  align(left, box(fill: get-color(fill), height: 1em, width: .42em)),
)


/// Creates a canceled/disabled checkbox symbol
///
/// Parameters:
///   - fill (auto, color): Stroke color (default: auto)
///   - radius (length): Corner radius (default: 0.1em)
///   - solid (none, color): Background fill (default: none)
#let canceled(fill: auto, radius: .1em, solid: none) = context box(
  stroke: .05em + get-color(fill),
  height: 0.8em,
  width: 0.8em,
  radius: radius,
  align(center + horizon, box(height: .125em, width: 0.55em, fill: get-color(fill))),
  fill: solid,
)

/// Creates small centered text for symbol rendering
///
/// Parameters:
///   - body (content): Text content to display
#let small-text(body) = box(width: 0.8em, height: 0.8em)[#align(center + horizon)[#text.with(size: 0.8em, top-edge: "bounds", bottom-edge: "bounds")(body)]]


/// Creates a character-based symbol (e.g., emoji or letter)
///
/// Parameters:
///   - symbol (str): Character to display (default: " ")
///   - fill (auto, color): Border color (default: auto)
///   - radius (length): Corner radius (default: 0.1em)
///   - solid (none, color): Background fill (default: none)
#let character-symbol(symbol: " ", fill: auto, radius: .1em, solid: none) = context box(
  stroke: .05em + get-color(fill),
  height: 0.8em,
  width: 0.8em,
  radius: radius,
  fill: solid,
  [#small-text(symbol)],
)

/// Defines basic checklist symbols (checked, unchecked, etc.)
///
/// Parameters:
///   - fill (auto, color): Default symbol color
///   - radius (length): Default corner radius
///   - solid (none, color): Default background fill
///
/// Returns:
///   A dictionary mapping symbol keys to their rendered forms
#let basic-symbol(fill: auto, radius: 0.1em, solid: none) = (
  "x": checked(fill: fill, radius: radius, solid: solid),
  " ": unchecked(fill: fill, radius: radius, solid: solid),
  "/": incomplete(fill: fill, radius: radius, solid: solid),
  "-": canceled(fill: fill, radius: radius, solid: solid),
)

/// Extended symbol mapping for special characters
///
/// Returns:
///   A dictionary mapping keys to their Unicode symbol equivalents
///
/// Symbol Key Mapping:
///   - ">": Right arrow (➡)
///   - "<": Calendar (📆)
///   - "?": Question mark (❓)
///   - "!": Exclamation (❗)
///   - "*": Star (⭐)
///   - ... (and other special symbols)
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
#let default-symbol-map(fill: auto, radius: 0.1em, solid: none, extras: false) = (
  if extras { for (k, v) in extend-symbol { (str(k): small-text(v)) } }
    + basic-symbol(fill: fill, radius: radius, solid: solid)
)

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
