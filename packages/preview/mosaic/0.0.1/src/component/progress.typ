// Position indicator driven by the deck's logical slide and section counters.
#import "../shared.typ": fail
#import "../deck-state.typ": slide-position, section-position
#import "style.typ": role-colors, component-tokens

/// Displays progress through logical slides or semantic sections in the deck.
///
/// It reads the deck's own counters, so it needs no arguments in the ordinary
/// case. The usual home for it is a setup-level footer default, which puts one
/// indicator on every slide that has a footer.
///
/// ```typ
/// #show: mosaic.setup.with(
///   content: (
///     footer: align(right, mosaic.components.progress()),
///   ),
/// )
/// ```
///
/// *Variants*
///
/// - `1/1`: the current and final values, as text. The default.
/// - `1`: the current value alone.
/// - `circle`: a compact ring filling clockwise, sized by `width` and
///   `thickness`.
/// - `line`: a horizontal bar filling left to right, sized by `width` and
///   `thickness`.
///
/// *What it counts*
///
/// `count` selects the automatic counter: `slides` counts logical slides, and
/// `sections` counts slides with `layout: "section"`.
///
/// Both readings come from `info()`, which publishes the same position as
/// `slide` and `section` records. Chrome that needs more than one indicator,
/// or the section's title rather than its number, reads that instead of
/// composing several of these.
///
/// -> content
#let progress(
  /// Visual treatment: `"1/1"`, `"1"`, `"circle"`, `"line"`, or a function
  /// drawing one. A renderer is called with a dictionary holding `current`,
  /// `total`, `amount`, `accent`, `fill`, `width`, and `thickness`, and
  /// returns the content to place.
  ///
  /// ```typ
  /// #mosaic.components.progress(
  ///   variant: state => grid(
  ///     columns: state.total,
  ///     ..range(state.total).map(i => rect(
  ///       height: state.thickness,
  ///       fill: if i < state.current { state.accent } else { state.fill },
  ///     )),
  ///   ),
  /// )
  /// ```
  /// -> str | function
  variant: "1/1",
  /// Which automatic counter to read: `"slides"` or `"sections"`.
  /// -> str
  count: "slides",
  /// Semantic role supplying the default colors: `accent`, `neutral`,
  /// `warning`, or `error`. The role's own color paints the
  /// completed portion and its tinted fill paints the remainder.
  /// -> str
  role: "accent",
  /// Length of the `line` variant, or diameter of the `circle` variant. `auto`
  /// is the full width for `line` and a compact fixed diameter for `circle`.
  /// -> auto | length | relative | fraction
  width: auto,
  /// Stroke thickness of the `circle` and `line` variants.
  /// -> length
  thickness: component-tokens.rule-thickness,
  /// Paint of the inactive remainder. `auto` uses the role's fill.
  /// -> auto | color | gradient | tiling
  fill: auto,
  /// Paint of the completed portion, and of the text variants. `auto` uses the
  /// role's accent.
  /// -> auto | color
  accent: auto,
) = context {
  if type(variant) != function and (
    type(variant) != str or variant not in ("1/1", "1", "circle", "line")
  ) {
    fail(
      "progress variant must be \"1/1\", \"1\", \"circle\", \"line\", or a "
        + "renderer function",
    )
  }
  if type(count) != str or count not in ("slides", "sections") {
    fail("progress count must be \"slides\" or \"sections\"")
  }
  // The same position `info()` publishes, read from the same place, so the
  // indicator and a hand-built footline can never print different numbers.
  let position = if count == "slides" {
    slide-position()
  } else {
    section-position()
  }
  let current = position.number
  // A deck with no section slides legitimately totals zero; the ratio below
  // guards against dividing by it.
  let total = calc.max(position.total, 1)
  let colors = role-colors(role, contextual: true)
  let fill = if fill == auto { colors.fill } else { fill }
  let accent = if accent == auto { colors.accent } else { accent }
  let width = if width == auto {
    if variant == "circle" { component-tokens.progress-size } else { 100% }
  } else {
    width
  }
  let amount = 100% * current / total

  // A renderer receives everything the built-in treatments draw from, so an
  // extension theme can add a treatment without forking this component.
  if type(variant) == function {
    return variant((
      current: current,
      total: total,
      amount: amount,
      accent: accent,
      fill: fill,
      width: width,
      thickness: thickness,
    ))
  }
  if variant == "1/1" {
    text(fill: accent)[#current/#total]
  } else if variant == "1" {
    text(fill: accent)[#current]
  } else if variant == "circle" {
    box(circle(
      width: width,
      height: width,
      fill: none,
      stroke: thickness + gradient.conic(
        (accent, 0%),
        (accent, amount),
        (fill, amount),
        (fill, 100%),
        angle: component-tokens.progress-start-angle,
        space: rgb,
      ),
    ))
  } else {
    block(width: width, height: thickness)[
      #place(top + left, rect(
        width: 100%,
        height: thickness,
        fill: fill,
      ))
      #place(top + left, rect(
        width: amount,
        height: thickness,
        fill: accent,
      ))
    ]
  }
}
