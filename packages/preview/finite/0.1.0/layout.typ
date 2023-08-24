#import "@preview/t4t:0.2.0": is, alias

/// A fixed list of coordinates.
///
/// Can be used to manually sepcify individual coordinates
/// for each state. Note, that coordinates may be any specified
/// in any coordinate system CETZ knows. If you want to use
/// fixed coordinates as a sub-layout (e.g. in @@group), all
/// coordinates must be in the (x,y)-system.
///
/// Notes not in #arg[pos] will be placed at #value((0,0)).
///
/// #example[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   start: none, stop: none,
///   layout:finite.layout.fixed.with(pos:(
///     q0: (0,-1), q1: (1,1), q2: (2,-1),
///     q3: (3,1), q4: (4,-1), q5: (5,1)
///   ))
/// )
/// ```]
///
/// - states (dictionary): Transition table.
/// - start (string, none): Initial state.
/// - stop (array, none): List of final states.
/// - pos (dictionary): Dictionary with coordinates for each state.
#let fixed( states, start, stop, pos:(:) ) = {
  let positions = (:)
  for name in states.keys() {
    if name in pos {
      positions.insert(name, pos.at(name))
    } else {
      positions.insert(name, (0,0))
    }
  }
  return positions
}

/// Arrange states in a line.
///
/// The direction of the line can be set by #arg[x] and #arg[y].
///
/// #example[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   start: none, stop: none,
///   layout:finite.layout.linear
/// )
/// #finite.automaton(
///   aut,
///   start: none, stop: none,
///   layout:finite.layout.linear.with(x:2, y:-.2)
/// )
/// ```]
///
/// - states (dictionary): Transition table.
/// - start (string, none): Initial state.
/// - stop (array, none): List of final states.
/// - x (float): Step size along the x-axis.
/// - y (float): Step size along the y-axis.
#let linear(states, start, stop, x:1.6, y:0) = {
  let positions = (:)
  for (i, name) in states.keys().enumerate() {
    positions.insert(name, (i * x, i * y))
  }
  return positions
}

// #let linear(states, start, stop, anchor:"left", x:1.6, y:0) = {
//   let positions = (:)
//   let last-state = none
//   for name in states.keys() {
//     if is.n(last-state) {
//       positions.insert(name, (0, 0))
//     } else {
//       positions.insert(name, (rel: (x, y), to:last-state + "." + anchor))
//     }
//     last-state = name
//   }
//   return positions
// }

/// Arrange states in rows and columns.
///
/// #example[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   start: none, stop: none,
///   layout:finite.layout.grid.with(columns:3)
/// )
/// ```]
///
/// - states (dictionary): Transition table.
/// - start (string, none): Initial state.
/// - stop (array, none): List of final states.
/// - columns (integer): Number of columns per row.
/// - x (float): Distance between the center of each column.
/// - y (float): Distance between the center of each row.
#let grid(states, start, stop, columns: 6, x:1.6, y:2.8) = {
  let positions = (:)

  for (i, name) in states.keys().enumerate() {
    let j = calc.quo(i, columns)
    i = calc.rem(i, columns)
    positions.insert(name, (i * x, -j * y))
  }

  return positions
}

/// Arrange states in a grid, but alternate the direction in every even and odd row.
///
/// #example[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   start: none, stop: none,
///   layout:finite.layout.snake.with(columns: 3)
/// )
/// ```]
///
/// - states (dictionary): Transition table.
/// - start (string, none): Initial state.
/// - stop (array, none): List of final states.
/// - columns (integer): Number of columns per row.
/// - x (float): Distance between the center of each column.
/// - y (float): Distance between the center of each row.
#let snake(states, start, stop, columns: 6, x:1.6, y:2.8) = {
  let positions = (:)

  for (i, name) in states.keys().enumerate() {
    let j = calc.quo(i, columns)
    i = calc.rem(i, columns)
    if calc.even(j) {
      positions.insert(name, (i * x, -j * y))
    } else {
      positions.insert(name, ((columns - i - 1) * x, -j * y))
    }
  }

  return positions
}

/// Arrange states in a circle.
///
/// #example[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #grid(columns: 2, gutter: 2em,
///   finite.automaton(
///     aut,
///     start: none, stop: none,
///     layout:finite.layout.circular,
///     style: (q0: (fill: yellow.lighten(60%)))
///   ),
///   finite.automaton(
///     aut,
///     start: none, stop: none,
///     layout:finite.layout.circular.with(offset:2),
///     style: (q0: (fill: yellow.lighten(60%)))
///   ),
///   finite.automaton(
///     aut,
///     start: none, stop: none,
///     layout:finite.layout.circular.with(dir:left),
///     style: (q0: (fill: yellow.lighten(60%)))
///   ),
///   finite.automaton(
///     aut,
///     start: none, stop: none,
///     layout:finite.layout.circular.with(dir:left, offset:2),
///     style: (q0: (fill: yellow.lighten(60%)))
///   )
/// )
/// ```]
///
/// - states (dictionary): Transition table.
/// - start (string, none): Initial state.
/// - stop (array, none): List of final states.
/// - radius (float, auto): Radius of the circle, the states are placed on. With #value(auto), the radius is calculated based on #arg[spacing].
/// - spacing (float): Distance between the center of each state on the circle.
/// - dir (alignment): #value(left) or #value(right) to indicate the direction, the states are arranged on the circle.
/// - offset (integer): An offset, where the inital state should be placed on the circle. For #arg(offset: 0), the initial state is placed to the left or right (depending on #arg[dir]) of the circle. For #arg(offset: 1), the initial state is placed one step in the direction indicated by #arg[dir].
#let circular(states, start, stop, radius:auto, spacing:1.6, dir:right, offset:0) = {
  let positions = (:)
  let n = states.len()

  for (i, name) in states.keys().enumerate() {
    if is.a(radius) {
      radius = (n*spacing) / (2*calc.pi)
    }
    let a = 360deg / n
    if dir == right {
      a *= -1
    }
    positions.insert(name, (
      -radius * calc.cos((i + offset) * a),
      -radius * calc.sin((i + offset) * a),
    ))
  }

  return positions
}

/// Group states and layout each group with its own layout.
///
/// #example[```
/// #let aut = range(6).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// Group every two states together:
/// #finite.automaton(
///   aut,
///   start: none, stop: none,
///   layout:finite.layout.group.with(
///     grouping: 2
///   )
/// )
/// Group specific states and arrange from bottom to top:
/// #finite.automaton(
///   aut,
///   start: none, stop: none,
///   layout:finite.layout.group.with(
///     grouping: (
///       ("q0", "q3", "q4"),
///       ("q2",),
///       ("q1", "q5"),
///     ),
///     layout: finite.layout.linear.with(x:0, y:1.4)
///   )
/// )
/// ```]
#let group(
  states,
  start,
  stop,
  x: 1.6,
  y: 0,
  grouping: 5,
  layout: linear.with(x:0, y:-1.6)
) = {
  let groups = ()
  let current-group = (:)

  if is.int(grouping) {
    for (i, name) in states.keys().enumerate() {
      current-group.insert(name, states.at(name))

      if calc.rem(i, grouping) == grouping - 1 {
        groups.push(current-group)
        current-group = (:)
      }
    }
  } else if is.arr(grouping) {
    // Collect States into groups
    for (group) in grouping {
      for name in group {
        if name in states {
          current-group.insert(name, states.at(name))
        }
      }
      groups.push(current-group)
      current-group = (:)
    }

    // Group all remaining states into last group
    for name in states.keys() {
      if not groups.any((g) => name in g) {
        current-group.insert(name, states.at(name))
      }
    }
  }
  if current-group != (:) {
    groups.push(current-group)
  }

  let positions = (:)
  let group-x = 0
  for (i, group) in groups.enumerate() {
    let group-positions
    if is.arr(layout) {
      if layout.len() > i {
        group-positions = (layout.at(i))(group, start, stop)
      } else {
        group-positions = (layout.at(-1))(group, start, stop)
      }
    } else {
      group-positions = layout(group, start, stop)
    }

    let max-x = group-x
    for (state, pos) in group-positions {
      let (a, b) = (..pos)
      positions.insert(state, (a + group-x, b + i*y))
      max-x = calc.max(max-x, a + group-x)
    }

    group-x = max-x + x
  }
  return positions
}

/// Arrange initial state on the left, final states on the right and the rest in the center with a custom layout.
///
///
/// #example[```
/// #let aut = range(8).fold((:), (d, s) => {d.insert("q"+str(s), none); d})
/// #finite.automaton(
///   aut,
///   start: "q2", stop: ("q3", "q5"),
///   layout:finite.layout.start-stop.with(
///     layout: finite.layout.circular
///   ),
/// )
/// ```]
#let start-stop(states, start, stop, layout: snake) = {
  let groups = (
    start: (),
    rest: (),
    stop: ()
  )

  for name in states.keys() {
    if name == start {
      groups.start.push(name)
    } else if name in stop {
      groups.stop.push(name)
    } else {
      groups.rest.push(name)
    }
  }

  return group(states, start, stop, grouping:groups.values(), layout: (
    linear.with(x:0, y:-1.4),
    layout,
    linear.with(x:0, y:-1.4)
  ))
}
