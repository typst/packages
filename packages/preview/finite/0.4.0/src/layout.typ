#import "util.typ"
#import util: cetz


/// Arange states in a line.
///
/// The direction of the line can be set via #arg[dir] either to an #dtype("alignment")
/// or a `vector` with a x and y shift.
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
///   layout:finite.layout.linear.with(dir:(.5, -.2))
/// )
/// ```]
///
/// - position (coordinate): Position of the anchor point.
/// - dir (vector,alignment,2d alignment): Direction of the line.
/// - spacing (float): Spacing between states on the line.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - body (array): Array of CETZ elements to cetz.draw.
#let linear(
  position,
  name: none,
  anchor: "west",
  dir: right,
  spacing: .6,
  body,
) = cetz.draw.group(
  name: name,
  anchor: anchor,
  ctx => {
    let dir = dir
    if util.is.any-type("alignment", "2d alignment", dir) {
      dir = util.align-to-vec(dir)
    }
    dir = cetz.vector.norm(dir)
    let dir-angle = cetz.vector.angle2((0, 0), dir)

    let _ctx = ctx
    let prev-name = none
    let (_, elements) = util.resolve-zipped(ctx, body)
    for (cetz-element, element) in elements {
      // Move states to proper locations
      if util.is-state(element) {
        if prev-name == none {
          cetz.draw.move-to(position)
        } else {
          cetz.draw.move-to((
            rel: cetz.vector.scale(dir, spacing + element.finite.radius),
            to: prev-name + "." + repr(dir-angle),
          ))
        }
        prev-name = element.name
      }
      (cetz-element,)
    }
  },
)


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
///
/// - position (coordinate): Position of the anchor point.
/// - dir (alignment): Direction of the circle. Either #value(left) or #value(right).
/// - spacing (float): Spacing between states on the line.
/// - radius (float,auto): Either a fixed radius or #value(auto) to calculate a suitable the radius.
/// - offset (angle): An offset angle to place the first state at.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - body (array): Array of CETZ elements to cetz.draw.
#let circular(
  position,
  name: none,
  anchor: "west",
  dir: right,
  spacing: .6,
  radius: auto,
  offset: 0deg,
  body,
) = cetz.draw.group(
  name: name,
  anchor: anchor,
  ctx => {
    let (_, coordinates) = cetz.coordinate.resolve(ctx, position)

    let (_, elements) = util.resolve-zipped(ctx, body)
    //let radii = util.resolve-radii(ctx, body)
    let radii = util.get-radii(elements.map(((_, e)) => e))
    let len = radii.values().fold(0, (s, r) => s + 2 * r + spacing)

    let radius = radius
    if util.is.a(radius) {
      radius = len / (2 * calc.pi)
    } else {
      len = 2 * radius * calc.pi
    }


    let at = -radii.values().first()
    for (cetz-element, element) in elements {
      // Move states to proper locations
      if util.is-state(element) {
        let ang = offset + util.math.map(
          0.0,
          len,
          0deg,
          360deg,
          at + element.finite.radius,
        )
        let pos = (
          coordinates.at(0) - radius * calc.cos(ang),
          coordinates.at(1) + if dir == right {
            radius
          } else {
            -radius
          } * calc.sin(ang),
        )

        at += 2 * element.finite.radius + spacing
        cetz.draw.move-to(pos)
      }
      (cetz-element,)
    }
  },
)


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
/// - position (coordinate): Position of the anchor point.
/// - columns (integer): Number of columns per row.
/// - spacing (float): Spacing between states on the grid.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - body (array): Array of CETZ elements to cetz.draw.
#let grid(
  position,
  name: none,
  anchor: "west",
  columns: 4,
  spacing: .6,
  body,
) = cetz.draw.group(
  name: name,
  anchor: anchor,
  ctx => {
    let (_, coordinates) = cetz.coordinate.resolve(ctx, position)

    let spacing = if not util.is.arr(spacing) {
      (x: spacing, y: spacing)
    } else {
      (x: spacing.first(), y: spacing.last())
    }

    let (_, elements) = util.resolve-zipped(ctx, body)
    let radii = util.get-radii(elements.map(((_, e)) => e))
    let max-radius = calc.max(..radii.values())

    let _ctx = ctx
    let i = 0
    for (cetz-element, element) in elements {
      // Move states to proper locations
      if util.is-state(element) {
        let (row, col) = (
          calc.quo(i, columns),
          calc.rem(i, columns),
        )
        cetz.draw.move-to((
          coordinates.at(0) + col * (2 * max-radius + spacing.x),
          coordinates.at(1) + row * (2 * max-radius + spacing.y),
        ))
        i += 1
      }
      (cetz-element,)
    }
  },
)


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
/// - position (coordinate): Position of the anchor point.
/// - columns (integer): Number of columns per row.
/// - spacing (float): Spacing between states on the line.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - body (array): Array of CETZ elements to cetz.draw.
#let snake(
  position,
  name: none,
  anchor: "west",
  columns: 4,
  spacing: .6,
  body,
) = cetz.draw.group(
  name: name,
  anchor: anchor,
  ctx => {
    let (_, coordinates) = cetz.coordinate.resolve(ctx, position)

    let spacing = if not util.is.arr(spacing) {
      (x: spacing, y: spacing)
    } else {
      (x: spacing.first(), y: spacing.last())
    }

    let (_, elements) = util.resolve-zipped(ctx, body)
    let radii = util.get-radii(elements.map(((_, e)) => e))
    let max-radius = calc.max(..radii.values())

    let _ctx = ctx
    let i = 0
    for (cetz-element, element) in elements {
      // Move states to proper locations
      if util.is-state(element) {
        let (row, col) = (
          calc.quo(i, columns),
          calc.rem(i, columns),
        )
        if calc.odd(row) {
          cetz.draw.move-to((
            coordinates.at(0) + (columns - col - 1) * (2 * max-radius + spacing.x),
            coordinates.at(1) + row * (2 * max-radius + spacing.y),
          ))
        } else {
          cetz.draw.move-to((
            coordinates.at(0) + col * (2 * max-radius + spacing.x),
            coordinates.at(1) + row * (2 * max-radius + spacing.y),
          ))
        }
        i += 1
      }
      (cetz-element,)
    }
  },
)


/// Create a custom layout from a positioning function.
///
/// See "Creating custom layouts" for more information.
///
/// #example(breakable:true)[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   initial: none, final: none,
///   layout:finite.layout.custom.with(positions:(..) => (
///     q0: (0,0), q1: (0,5), rest:(rel: (2,-1))
///   ))
/// )
/// ```]
///
/// - position (coordinate): Position of the anchor point.
/// - positions (function): A function #lambda("dictionary","dictionary","array",ret:"dictionary") to compute coordinates for each state.\
///    The function gets the current CETZ context, a dictionary of computed radii for each
///    state and a list with all state elements to position. The returned dictionary
///    contains each states name as a key and the new coordinate as a value.
///
///    The result may specify a `rest` key that is used as a default coordinate. This makes
///    sense in combination with a relative coordinate like `(rel:(2,0))`.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - body (array): Array of CETZ elements to cetz.draw.
#let custom(
  position,
  name: none,
  anchor: "west",
  positions: (ctx, radii, states) => (:),
  body,
) = cetz.draw.group(
  name: name,
  anchor: anchor,
  ctx => {
    let states = util.resolve-states(ctx, body)
    let radii = states.fold(
      (:),
      (r, s) => {
        r.insert(s.name, s.finite.radius)
        r
      },
    )

    let coordinates = if type(positions) == function {
      positions(ctx, radii, states)
    } else {
      positions
    }
    let default = coordinates.at("rest", default: (rel: (2, 0)))

    let _ctx = ctx
    for elem in body {
      // Resolve element
      let element = (elem)(_ctx)
      _ctx = element.ctx
      // Move states to proper locations
      if "finite" in element and "radius" in element.finite {
        cetz.draw.move-to(coordinates.at(element.name, default: default))
      }
      (elem,)
    }
  },
)

/// Creates a group layout that collects states into groups that are
/// positioned by specific sub-layouts.
///
/// See @sec:showcase for an example.
///
/// - position (coordinate): Position of the anchor point.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - grouping (int, array): Either an integer to collect states into
///     roughly equal sized groups or an array of arrays that specify which states
///     (by name) are in what group.
/// - spacing (float): A spacing between sub-group layouts.
/// - layout (array): An array of layouts to use for each group. The first group of
///     states will be passed to the first layout and so on.
/// - body (array): Array of CETZ elements to cetz.draw.
#let group(
  position,
  name: none,
  anchor: "west",
  grouping: 5,
  spacing: .8,
  layout: linear.with(dir: bottom),
  body,
) = cetz.draw.group(
  name: name,
  anchor: anchor,
  ctx => {
    let groups = ()
    let rest = ()

    let (_, elements) = util.resolve-zipped(ctx, body)

    if util.is.int(grouping) {
      for (i, (cetz-element, element)) in elements.enumerate() {
        if calc.rem(i, grouping) == 0 {
          groups.push(())
        }
        groups.last().push(cetz-element)
      }
    } else if util.is.arr(grouping) {
      // Collect States into groups
      for (group) in grouping {
        groups.push(())
        for (cetz-element, element) in elements {
          if "name" in element and element.name in group {
            groups.last().push(cetz-element)
          }
        }
      }
      for (cetz-element, element) in elements {
        if "name" not in element or not grouping.any(g => element.name in g) {
          rest.push(cetz-element)
        }
      }
    }

    let elements = ()
    let last-name = none
    for (i, group) in groups.enumerate() {
      let group-layout
      if util.is.arr(layout) {
        if layout.len() > i {
          group-layout = layout.at(i)
        } else {
          group-layout = layout.at(-1)
        }
      } else {
        group-layout = layout
      }


      elements += group-layout(
        if i == 0 {
          position
        } else {
          (rel: (spacing, 0), to: "l" + str(i - 1) + ".east")
        },
        name: "l" + str(i),
        anchor: "west",
        group,
      )
      elements += cetz.draw.copy-anchors("l" + str(i))
      elements += cetz.draw.rect("l" + str(i) + ".north-west", "l" + str(i) + ".south-east")
      elements += cetz.draw.circle("l" + str(i) + ".west", radius: .2, fill: green)
      elements += cetz.draw.circle("l" + str(i) + ".east", radius: .2, fill: red)
    }

    elements + rest
  },
)
