#import "@preview/cetz:0.4.2"
#import "util.typ": foreach-task, task-anchor-line, task-anchor-sidebar

#let _draw-dependency(style, us-id, dependency) = {
  import cetz.draw: *
  let (style, absolute-curviness, curviness) = style
  let us = task-anchor-line(us-id) + ".start"
  let them = task-anchor-line(dependency.id) + ".end"
  let mid1u = (us, 50% - curviness, them)
  let mid2u = (us, 50% + curviness, them)
  let mid1 = (rel: (absolute-curviness, 0), to: (them, "-|", mid1u))
  let mid2 = (rel: (-absolute-curviness, 0), to: (us, "-|", mid2u))
  bezier(them, us, mid1, mid2, ..style)
}

#let _draw-task-dependencies(style, id, task) = {
  task.dependencies.map(_draw-dependency.with(style, id)).join()
}

/// The default style for the dependency lines.
///
/// #raw(repr(gantty.dependencies.default-dependency-style), lang: "typc")
/// -> style
#let default-dependency-style = (stroke: black + 0.75pt, mark: (end: "barbed"))

/// The default drawer of dependencies.
///
/// Draws them as a curvy arrowed line.
/// -> cetz
#let default-dependencies-drawer(
  /// The gantt char
  /// -> gantt
  gantt,
  /// How 'curvy' the curve is.
  /// -> ratio
  curviness: 25%,
  /// An absolute length added to the curviness
  ///
  /// This is necessary for when dependencies' tasks have the same start
  /// and end date.
  /// -> ratio
  absolute-curviness: 10pt,
  /// The style of the line.
  /// -> style
  style: default-dependency-style,
) = {
  foreach-task(gantt, _draw-task-dependencies.with(
    (
      style: style,
      curviness: curviness,
      absolute-curviness: absolute-curviness,
    ),
  ))
}

#let _is_tolerable(tolerance, ctx, us, them) = {
  import cetz.coordinate: resolve
  import cetz.util: resolve-number
  let (_, us, them) = resolve(ctx, us, them)
  let tolerance = resolve-number(ctx, tolerance)
  calc.abs(us.at(0) - them.at(0)) > tolerance
}

#let _draw-orthogonal-dependency(style, us-id, dependency) = {
  import cetz.draw: *

  let (style, tolerance, buldge) = style
  let us = task-anchor-line(us-id) + ".start"
  let them = task-anchor-line(dependency.id) + ".end"

  get-ctx(ctx => {
    let points = if _is_tolerable(tolerance, ctx, us, them) {
      (
        us,
        ((us, 50%, them), "|-", us),
        ((us, 50%, them), "|-", them),
        them,
      )
    } else {
      (
        us,
        (rel: (-buldge, 0), to: ((us, 50%, them), "|-", us)),
        (rel: (-buldge, 0), to: (us, 50%, them)),
        (rel: (buldge, 0), to: (us, 50%, them)),
        (rel: (buldge, 0), to: ((us, 50%, them), "|-", them)),
        them,
      )
    }.rev()
    line(..points, ..style)
  })
}

#let _draw-orthogonal-task-dependencies(style, id, task) = {
  import cetz.draw: *
  task.dependencies.map(_draw-orthogonal-dependency.with(style, id)).join()
}

#let orthogonal-dependencies-drawer(
  gantt,
  style: default-dependency-style,
  tolerance: 10pt,
  buldge: 10pt,
) = {
  let style = (style: style, tolerance: tolerance, buldge: buldge)
  foreach-task(gantt, _draw-orthogonal-task-dependencies.with(style))
}
