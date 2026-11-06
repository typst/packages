
#import "util.typ": *


// Apply element styles to the context. (e.g. from set-style)
#let apply-style(ctx, element) = {
  if "style" in element {
    ctx.style = styles.resolve(
      ctx.style,
      if type(element.style) == "function" {
        (element.style)(ctx)
      } else {
        element.style
      }
    )
  }
  return ctx
}


// Resolve radii for states by applying styles from other elements.
#let resolve-radii(ctx, elements) = {
  let radii = (:)
  for element in elements {
    ctx = apply-style(ctx, element)

    if "name" in element and "radius" in element {
      radii.insert(element.name, (element.radius)(ctx))
    }
  }

  return radii
}


// A base element for creating layouts.
#let base(position, name, anchor, body, children:()) = (
  name: name,
  coordinates: (position,),
  anchor: anchor,
  default-anchor: "origin",
  custom-anchors-ctx: (ctx, pos) => {
    let anchors = ctx.groups.last().anchors
    for (k,v) in anchors {
      anchors.insert(k, vector.add(translate, a))
    }
    anchors.insert("origin", pos)
    return anchors
  },
  before: (ctx) => {
    ctx.groups.push((
      ctx: ctx,
      anchors: (:),
      nodes: body.map((e) => e.at("name", default:none)).filter(is.not-none)
    ))
    return ctx
  },
  push-transform: (ctx) => {
    let t = vector.sub(
      util.apply-transform(ctx.transform, coordinate.resolve(ctx, position)),
      util.apply-transform(ctx.transform, (0,0,0))
    )
    return matrix.mul-mat(matrix.transform-translate(..t), ctx.transform)
  },
  after: (ctx, pos) => {
    let node = ctx.nodes.at(name)
    let anchor = if is.n(anchor) {"left"} else {anchor}
    let translate = vector.sub(node.anchors.default, node.anchors.at(anchor))

    let self = ctx.groups.pop()
    let nodes = ctx.nodes
    ctx = self.ctx

    ctx.nodes.insert(name, nodes.at(name))
    for name in self.nodes {
      if name in nodes {
        let node = nodes.at(name)
        for (k, a) in node.anchors {
          node.anchors.insert(k, vector.add(translate, a))
        }
        ctx.nodes.insert(name, node)
      }
    }

    ctx.prev.pt = pos
    return prepare-ctx(ctx, force:true)
  },
  children: children
)


/// Arrange states in a line.
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
/// - body (array): Array of CETZ elements to draw.
#let linear(
  position, name: none, anchor: "left",
  dir: right,
  spacing: .6,
  body
) = {
  if is.any-type("alignment", "2d alignment", dir) {
    dir = vector.scale(align-to-vec(dir), spacing)
  }
  dir = vector.norm(dir)

  if is.n(name) {
    name = "layout" + body.map((e) => e.at("name", default:"")).join("-")
  }

  let base = base(position, name, anchor, body)
  base.children = (ctx) => {
    let elements = ()

    let at = (0,0)
    let spacing = vector.scale(dir, spacing)
    for element in body {
      ctx = apply-style(ctx, element)

      if "name" in element and "radius" in element {
        let r = vector.scale(dir, (element.radius)(ctx))
        if at != (0,0) {
          at = vector.add(at, r)
        }
        element.coordinates = (at,)
        at = vector.add(at, vector.add(r, spacing))
      }

      elements.push(element)
    }
    elements
  }

  return (base,)
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
///
/// - position (coordinate): Position of the anchor point.
/// - dir (alignment): Direction of the circle. Either #value(left) or #value(right).
/// - spacing (float): Spacing between states on the line.
/// - radius (float,auto): Either a fixed radius or #value(auto) to calculate a suitable the radius.
/// - offset (angle): An offset angle to place the first state at.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - body (array): Array of CETZ elements to draw.
#let circular(
  position, name: none, anchor: "left",
  dir: right,
  spacing: .6,
  radius: auto,
  offset: 0deg,
  body
) = {
  if is.n(name) {
    name = "layout" + body.map((e) => e.at("name", default:"")).join("-")
  }

  let layout = base(position, name, anchor, body)
  layout.children = (ctx) => {
    let elements = ()
    let radii = resolve-radii(ctx, body)
    let n = radii.len()
    let len = radii.values().fold(0, (s, r) => s + 2 * r + spacing)

    let radius = radius
    if is.a(radius) {
      radius = len / (2*calc.pi)
    }

    let at = -radii.values().first()
    let last = none
    let last-radius = 0
    for element in body {
      ctx = apply-style(ctx, element)

      if "name" in element and "radius" in element {
        let r = radii.at(element.name)

        let ang = offset + math.map(
          0.0, len,
          0deg, 360deg,
          at + r
        )

        element.coordinates = ((
          radius - radius * calc.cos(ang),
          if dir == right {radius} else {-radius} * calc.sin(ang),
        ),)

        at += 2 * r + spacing
      }

      elements.push(element)
    }

    elements
  }

  return (layout,)
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
/// - position (coordinate): Position of the anchor point.
/// - columns (integer): Number of columns per row.
/// - spacing (float): Spacing between states on the grid.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - body (array): Array of CETZ elements to draw.
#let grid(
  position, name: none, anchor: "left",
  columns: 4,
  spacing: .6,
  body
) = {
  if not is.arr(spacing) {
    spacing = (x: spacing, y: spacing)
  } else {
    spacing = (x: spacing.first(), y: spacing.last())
  }

  if is.n(name) {
    name = "layout" + body.map((e) => e.at("name", default:"")).join("-")
  }

  let layout = base(position, name, anchor, body)
  layout.children = (ctx) => {
    let elements = ()
    let radii = resolve-radii(ctx, body)
    let max-radius = calc.max(..radii.values())

    let last = none
    let i = 0
    for element in body {
      ctx = apply-style(ctx, element)

      if "name" in element and "radius" in element {
        let (row, col) = (
          calc.quo(i, columns),
          calc.rem(i, columns)
        )
        element.coordinates = ((
          col * (2*max-radius + spacing.x),
          row * (2*max-radius + spacing.y)
        ),)
        i += 1
      }

      elements.push(element)
    }

    return elements
  }

  return (layout,)
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
/// - position (coordinate): Position of the anchor point.
/// - columns (integer): Number of columns per row.
/// - spacing (float): Spacing between states on the line.
/// - name (string): Name for the element to access later.
/// - anchor (string): Name of the anchor to use for the layout.
/// - body (array): Array of CETZ elements to draw.
#let snake(
  position, name: none, anchor: "left",
  columns: 4,
  spacing: .6,
  body
) = {
  if not is.arr(spacing) {
    spacing = (x: spacing, y: spacing)
  } else {
    spacing = (x: spacing.first(), y: spacing.last())
  }

  if is.n(name) {
    name = "layout" + body.map((e) => e.at("name", default:"")).join("-")
  }

  let layout = base(position, name, anchor, body)
  layout.children = (ctx) => {
    let elements = ()
    let radii = resolve-radii(ctx, body)
    let max-radius = calc.max(..radii.values())

    let last = none
    let i = 0
    for element in body {
      ctx = apply-style(ctx, element)

      if "name" in element and "radius" in element {
        let (row, col) = (
          calc.quo(i, columns),
          calc.rem(i, columns)
        )
        if calc.odd(row) {
          element.coordinates = ((
            (columns - col - 1) * (2*max-radius + spacing.x),
            row * (2*max-radius + spacing.y)
          ),)
        } else {
          element.coordinates = ((
            col * (2*max-radius + spacing.x),
            row * (2*max-radius + spacing.y)
          ),)
        }
        i += 1
      }

      elements.push(element)
    }

    return elements
  }

  return (layout,)
}


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
/// - body (array): Array of CETZ elements to draw.
#let custom(
  position, name: none, anchor: "left",
  positions: (..) => (:),
  body
) = {
  if is.n(name) {
    name = "layout" + body.map((e) => e.at("name", default:"")).join("-")
  }

  let l = base(position, name, anchor, body)
  l.children = (ctx) => {
    let radii = resolve-radii(ctx, body)
    let states = body.filter((e) => "name" in e and "radius" in e)
    let positions = positions(ctx, radii, states)
    let default = positions.at("rest", default:(rel:(1,0)))

    let elements = ()
    for element in body {
      ctx = apply-style(ctx, element)

      if "name" in element {
        element.coordinates = (positions.at(element.name, default:default),)
      }

      elements.push(element)
    }
    return elements
  }
  return (l,)
}


#let group(
  position, name: none, anchor: "left",
  grouping: 5,
  spacing: .8,
  layout: linear.with(dir:bottom),
  body
) = {
  if is.n(name) {
    name = "layout" + body.map((e) => e.at("name", default:"")).join("-")
  }

  let base = base(position, name, anchor, body)
  base.children = (ctx) => {
    let groups = ()
    let rest = ()
    if is.int(grouping) {
      for (i, element) in body.enumerate() {
        if calc.rem(i, grouping) == 0 {
          groups.push(())
        }
        groups.last().push(element)
      }
    } else if is.arr(grouping) {
      // Collect States into groups
      for (group) in grouping {
        groups.push(())
        for element in body {
          if "name" in element and element.name in group {
            groups.last().push(element)
          }
        }
      }
      for element in body {
        if "name" not in element or not grouping.any((g) => element.name in g) {
          rest.push(element)
        }
      }
    }

    let elements = ()
    let last-name = none
    for (i, group) in groups.enumerate() {
      let group-layout
      if is.arr(layout) {
        if layout.len() > i {
          group-layout = layout.at(i)
        } else {
          group-layout = layout.at(-1)
        }
      } else {
        group-layout = layout
      }

      if is.n(last-name) {
        elements += group-layout(position, anchor: "left", group)
      } else {
        elements += group-layout((rel:(spacing,0), to:last-name+".right"), anchor: "left", group)
      }
      last-name = elements.last().name
    }

    return elements + rest
  }
  return (base,)
}
