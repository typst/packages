// =============================================================================
// src/state.typ: Reactive states and theme context
// =============================================================================

#import "utils.typ": normalize-color

/// Internal reactive state to share the active primary color with helper components
#let _primary-color-state = state(
  "unsa-epis-abet-primary-color",
  rgb("#C8310E"),
)

/// Resolves an active fill color against the reactive primary color state.
/// Must be called within a contextual block.
///
/// - fill (color, str, auto): Custom color or `auto` to fetch active primary color.
/// -> color
#let resolve-fill(fill) = {
  if fill == auto {
    _primary-color-state.get()
  } else if type(fill) == str {
    rgb(fill)
  } else {
    fill
  }
}

/// Helper to execute `fn(resolved-color)` using context ONLY when `fill == auto`.
/// Defers to a contextual block only when necessary to avoid layout boundary
/// creation and extra layout convergence passes when an explicit color is provided.
///
/// - fill (color, str, auto): Custom color or `auto` to fetch active primary color.
/// - fn (function): Callback receiving the resolved color `(color) => content`.
/// -> content
#let _with-resolved-fill(fill, fn) = {
  if fill == auto {
    context fn(_primary-color-state.get())
  } else {
    fn(normalize-color(fill))
  }
}

/// Public alias for `_with-resolved-fill`.
#let with-resolved-fill = _with-resolved-fill
