#import "util.typ"
#import util: default-style, cetz, test, assert-dict, assert-spec


/// Helper function to create a layout dictionary by providing
/// #arg[positions] and/or #arg[anchors].
/// -> array
#let create-layout(positions: (:), anchors: (:)) = {
  (positions, anchors)
}


/// Create a custom layout from a #typ.t.dictionary with
/// state #dtype("coordinate")s.
///
/// The result may specify a `rest` key that is used as a default coordinate. This is useful
/// sense in combination with a relative coordinate like `(rel:(2,0))`.
///
/// #example(breakable:true)[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   initial: none, final: none,
///   layout:finite.layout.custom.with(positions: (
///     q0: (0,0), q1: (0,2), rest:(rel: (1.5,-.5))
///   ))
/// )
/// ```]
///
/// -> array
#let custom(
  /// Automaton specification.
  /// -> spec
  spec,
  /// A dictionary with #dtype("coordinate")s for each state.
  ///
  /// The dictionary contains each states name as a
  /// key and the new coordinate as a value.
  ///
  /// -> dictionary
  positions: (:),
  /// Position of the anchor point.
  /// -> coordinate
  position: (0, 0),
  /// Styling options.
  /// -> dictionary
  style: (:),
) = {
  assert-spec(spec)
  assert-dict(positions)

  let rest = positions.at("rest", default: (rel: (4, 0)))

  for state in spec.states {
    positions.insert(
      state,
      (
        rel: position,
        to: positions.at(state, default: util.call-or-get(rest, state)),
      ),
    )
  }

  // return coordinates
  return create-layout(positions: positions)
}


/// Arrange states in a line.
///
/// The direction of the line can be set via #arg[dir] either to an #typ.t.alignment
/// or a direction vector with a x and y shift. Note that the length of the vector is set to #arg[spacing] and only the direction is used.
///
/// #example(breakable:true)[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   initial: none, final: none,
///   layout:finite.layout.linear.with(dir: right)
/// )
/// #finite.automaton(
///   aut,
///   initial: none, final: none,
///   layout:finite.layout.linear.with(spacing: .5, dir:(2,-1))
/// )
/// ```]
///
/// -> array
#let linear(
  /// Automaton specification.
  /// -> spec
  spec,
  /// Direction of the line.
  /// -> vector | alignment | 2d alignment
  dir: right,
  /// Spacing between states on the line.
  /// -> float
  spacing: default-style.state.radius * 2,
  /// Position of the anchor point.
  /// -> coordinate
  position: (0, 0),
  /// Styling options.
  /// -> dictionary
  style: (:),
) = {
  assert-spec(spec)

  let dir = dir
  if test.is-type(alignment, dir) {
    dir = util.align-to-vec(dir)
  }
  dir = cetz.vector.norm(dir)
  let dir-angle = cetz.vector.angle2((0, 0), dir)
  let spacing-vec = cetz.vector.scale(dir, spacing)

  let positions = (:)
  let anchors = (:)

  let prev-name = none
  for name in spec.states {
    positions.insert(
      name,
      if prev-name == none {
        position
      } else {
        (
          rel: spacing-vec,
          to: prev-name + ".state." + repr(dir-angle),
        )
      },
    )
    anchors.insert(
      name,
      if prev-name == none {
        "center"
      } else {
        repr(dir-angle + 180deg)
      },
    )
    prev-name = name
  }

  // return coordinates
  return create-layout(positions: positions, anchors: anchors)
}


/// Arrange states in a circle.
///
/// #example(breakable:true)[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #grid(columns: 2, gutter: 2em,
///   finite.automaton(
///     aut,
///     initial: none, final: none,
///     layout:finite.layout.circular,
///     style: (q0: (fill: yellow.lighten(60%)))
///   ),
///   finite.automaton(
///     aut,
///     initial: none, final: none,
///     layout:finite.layout.circular.with(offset:45deg),
///     style: (q0: (fill: yellow.lighten(60%)))
///   ),
///   finite.automaton(
///     aut,
///     initial: none, final: none,
///     layout:finite.layout.circular.with(dir:left),
///     style: (q0: (fill: yellow.lighten(60%)))
///   ),
///   finite.automaton(
///     aut,
///     initial: none, final: none,
///     layout:finite.layout.circular.with(dir:left, offset:45deg),
///     style: (q0: (fill: yellow.lighten(60%)))
///   )
/// )
/// ```]
#let circular(
  /// Automaton specification.
  /// -> spec
  spec,
  /// Direction of the circle. Either #value(left) or #value(right).
  /// -> alignment
  dir: right,
  /// Spacing between states on the line.
  /// -> float
  spacing: default-style.state.radius * 2,
  /// Either a fixed radius or #typ.v.auto to calculate a suitable radius.
  /// -> float | auto
  radius: auto,
  /// An offset angle to place the first state at.
  /// -> angle
  offset: 0deg,
  /// Position of the anchor point.
  /// -> coordinate
  position: (0, 0),
  /// Styling options.
  /// -> dictionary
  style: (:),
) = {
  // TODO: (jneug) fix positioning
  let radii = util.get-radii(spec, style: style)
  let len = radii.values().fold(0, (s, r) => s + 2 * r + spacing)

  let radius = radius
  if util.is-auto(radius) {
    radius = len / (2 * calc.pi)
  } else {
    len = 2 * radius * calc.pi
  }

  let positions = (:)
  let anchors = (:)
  let at = 0.0
  for name in spec.states {
    let state-radius = radii.at(name)
    let ang = 0deg
    let ang = (
      offset
        + util.math.map(
          0.0,
          len,
          0deg,
          360deg,
          at + state-radius,
        )
    )

    let pos = (
      rel: (
        -radius * calc.cos(ang),
        if dir == right {
          radius
        } else {
          -radius
        }
          * calc.sin(ang),
      ),
      to: position,
    )

    positions.insert(name, pos)

    // anchors.insert(name, "state." + repr(-ang))

    at += 2 * state-radius + spacing
  }
  return create-layout(positions: positions, anchors: anchors)
}


/// Arrange states in rows and columns.
///
/// #example[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   initial: none, final: none,
///   layout:finite.layout.grid.with(columns:3)
/// )
/// ```]
///
/// -> array
#let grid(
  /// Automaton specification.
  /// -> spec
  spec,
  /// Number of columns per row.
  /// -> int
  columns: 4,
  /// Spacing between states on the grid.
  /// -> float
  spacing: default-style.state.radius * 2,
  /// Position of the anchor point.
  /// -> coordinate
  position: (0, 0),
  /// Styling options.
  /// -> dictionary
  style: (:),
) = {
  let spacing = if not util.is-arr(spacing) {
    (x: spacing, y: spacing)
  } else {
    (x: spacing.first(), y: spacing.last())
  }

  let radii = util.get-radii(spec, style: style)
  let max-radius = calc.max(..radii.values())

  let positions = (:)
  for (i, name) in spec.states.enumerate() {
    let (row, col) = (
      calc.quo(i, columns),
      calc.rem(i, columns),
    )
    positions.insert(
      name,
      (
        rel: (
          col * (2 * max-radius + spacing.x),
          row * (2 * max-radius + spacing.y),
        ),
        to: position,
      ),
    )
  }
  return create-layout(positions: positions)
}


/// Arrange states in a grid, but alternate the direction in every even and odd row.
///
/// #example(breakable:true)[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   initial: none, final: none,
///   layout:finite.layout.snake.with(columns:3)
/// )
/// ```]
///
/// -> array
#let snake(
  /// Automaton specification.
  /// -> spec
  spec,
  /// Number of columns per row.
  /// -> int
  columns: 4,
  /// Spacing between states on the line.
  /// -> float
  spacing: default-style.state.radius * 2,
  /// Position of the anchor point.
  /// -> coordinate
  position: (0, 0),
  /// Styling options.
  /// -> dictionary
  style: (:),
) = {
  let spacing = if not util.is-arr(spacing) {
    (x: spacing, y: spacing)
  } else {
    (x: spacing.first(), y: spacing.last())
  }

  let radii = util.get-radii(spec, style: style)
  let max-radius = calc.max(..radii.values())

  let positions = (:)
  for (i, name) in spec.states.enumerate() {
    let (row, col) = (
      calc.quo(i, columns),
      calc.rem(i, columns),
    )
    positions.insert(
      name,
      if calc.odd(row) {
        (
          rel: (
            (columns - col - 1) * (2 * max-radius + spacing.x),
            row * (2 * max-radius + spacing.y),
          ),
          to: position,
        )
      } else {
        (
          rel: (
            col * (2 * max-radius + spacing.x),
            row * (2 * max-radius + spacing.y),
          ),
          to: position,
        )
      },
    )
  }
  return create-layout(positions: positions)
}


/// Creates a group layout that collects states into groups that are
/// positioned by specific sub-layouts.
///
/// #example(breakable:true)[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   initial: none, final: none,
///   layout: finite.layout.group.with(
///     grouping: 3,
///     spacing: 4,
///     layout: (
///       finite.layout.linear.with(dir: bottom),
///       finite.layout.circular,
///     )
///   )
/// )
/// ```]
///
/// See @sec:showcase for a more comprehensive example.
///
/// -> array
#let group(
  /// Automaton specification.
  /// -> spec
  spec,
  /// Either an integer to collect states into
  /// roughly equal sized groups or an array of arrays that specify which
  /// states (by name) are in each group.
  /// -> int | array
  grouping: auto,
  /// Spacing between states on the line.
  /// -> float
  spacing: default-style.state.radius * 2,
  /// An array of layouts to use for each group. The first group of
  /// states will be passed to the first layout and so on.
  /// -> array
  layout: linear.with(dir: bottom),
  /// Position of the anchor point.
  /// -> coordinate
  position: (0, 0),
  /// Styling options.
  /// -> dictionary
  style: (:),
) = {
  assert-spec(spec)

  let groups = ()
  let rest = ()

  let grouping = util.def.if-auto(grouping, def: spec.states.len())

  // collect state groups
  if util.is-int(grouping) {
    // by equal size
    groups = spec.states.chunks(grouping)
  } else if util.is-arr(grouping) {
    groups = grouping
    // collect remaining states into "rest" group
    rest = spec.states.filter(s => not groups.any(g => s in g))
  }

  let positions = (:)
  let anchors = (:)
  let last-name = none
  for (i, group) in groups.enumerate() {
    let group-layout
    if util.is-arr(layout) {
      if layout.len() > i {
        group-layout = layout.at(i)
      } else {
        group-layout = layout.at(-1)
      }
    } else {
      group-layout = layout
    }

    let (pos, anc) = group-layout(
      spec + (states: group),
      position: if i == 0 {
        position
      } else {
        // TODO: (jneug) fix spacing between layouts
        (rel: (i * spacing, 0), to: position)
      },
      style: style,
    )

    positions += pos
    anchors += anc
  }

  return create-layout(positions: positions, anchors: anchors)
}
