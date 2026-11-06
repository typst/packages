#import "@preview/cetz:0.4.2"
#import cetz.draw: *

/// Empty circle used for attributes.
/// -> content
#let empty-circle = {
  register-mark("empty-circle", style => {
    circle((0, 0), radius: 0.2em)
    anchor("tip", (0em, 0))
    anchor("base", (-0.1em - 1pt, 0))
  })
}

/// Subentity mark, a custom made arrow.
/// -> content
#let subentity-mark = {
  register-mark("subentity-mark", style => {
    line((0, 0), (-0.2, -0.15))
    line((0, 0), (-0.2, 0.15))
    anchor("tip", (0em, 0))
    anchor("base", (0em, 0))
  })
}

/// Filled circle for the primary keys.
/// -> content
#let filled-circle-pk(
  /// Fill colour.
  /// -> color
  fill: black,
) = {
  register-mark("filled-circle-pk", style => {
    circle((-0.2em, 0), radius: 0.2em, fill: fill)
    anchor("tip", (-0.2em, 0))
    anchor("base", (-0.4em, 0))
  })
}

/// Filled circle for multiple primary keys.
/// -> content
#let filled-circle-mpk(
  /// Fill colour.
  /// -> color
  fill: black,
) = {
  register-mark("filled-circle-mpk", style => {
    line((-0.2em, 0), (rel: (0.5em, 0)))
    circle((), radius: 0.2em, fill: fill)
    anchor("tip", (-0.2em, 0))
    anchor("base", (-0.2em, 0))
  })
}

/// Filled circle for weak entities.
/// -> content
#let filled-circle-wk(
  /// Fill colour.
  /// -> color
  fill: black,
  /// Custom length based on x,y side.
  /// -> int | float | length
  _wk-mark-length,
) = {
  register-mark("filled-circle-wk", style => {
    line((_wk-mark-length, 0), (0, 0))
    circle((_wk-mark-length, 0), radius: 0.2em, fill: fill)
    anchor("tip", (0em, 0))
    anchor("base", (0em, 0))
  })
}

/// Custom made "mark", which is just a cute line.
/// -> content
#let righetta = {
  register-mark("righetta", style => {
    line((0, 0), (0.2, 0))
    anchor("tip", (0em, 0))
    anchor("base", (0em, 0))
  })
}
