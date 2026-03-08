#import "@preview/suiji:0.5.1": *

/// Generates and renders a random maze.
///
/// The maze has `cols` columns and `rows` rows. The function draws the maze
/// inside the specified `width` and `height`.
///
/// The maze is generated using a depth-first search (DFS) backtracking
/// algorithm, producing a *perfect maze* (there is exactly one path between
/// any two cells).
///
/// The generation is deterministic with respect to `seed`, so the same
/// parameters always produce the same maze.
///
/// Optional content can be placed in the start and finish cells.
///
/// Parameters:
/// - cols: Number of maze columns.
/// - rows: Number of maze rows.
/// - width: Width of the rendered maze. Defaults to `100%`.
/// - height: Height of the rendered maze. Defaults to `100%`.
/// - seed: Seed for the pseudo-random generator. Using the same seed
///   produces the same maze. Defaults to `0`.
/// - stroke: How to [stroke] the maze. Defaults to `auto` (for a stroke of 1pt black).
/// - start_cont: Content placed in the start cell. Defaults to `none`.
/// - finish_cont: Content placed in the finish cell. Defaults to `none`.
///
/// Returns:
/// Content containing the rendered maze.
///
/// Example:
/// ```typst
/// #import "@preview/mazed:0.1.0": maze
///
/// #maze(
///   12,
///   8,
///   width: 10cm,
///   height: 6cm,
///   seed: 42,
/// )
/// ```
///
/// Example with markers:
/// ```typst
/// #maze(
///   10,
///   10,
///   start: [🚩],
///   finish: [🏁],
/// )
/// ```
#let maze(cols, rows, width: 100%, height: 100%, seed: 0, stroke: auto, start: none, finish: none) = layout(size => {
  let LL = calc.min(
    if type(width) == ratio {
      size.width * width
    } else if type(width) == relative {
      size.width * width.ratio + width.length
    } else {
      width
    } / cols,
    if type(height) == ratio {
      size.height * height
    } else if type(height) == relative {
      size.height * height.ratio + height.length
    } else {
      height
    } / rows
  )

  let CR = cols * rows
  let right = range(CR).map(_ => false) // we use only cols-1 x rows
  let up = range(CR).map(_ => false) // we use only cols x rows-1

  let index(c, r) = cols * r + c
  let min_max(n1, n2) = (calc.min(n1, n2), calc.max(n1, n2))

  let neighbors(rng, vertex) = {
    let result = ()
    let c = calc.rem(vertex, cols)
    if c > 0 { result.push(vertex - 1) }
    if c+1 < cols { result.push(vertex + 1) }
    if vertex >= cols { result.push(vertex - cols) }
    if vertex+cols < CR { result.push(vertex + cols) }
    return shuffle-f(rng, result)
  }

  let (rng, start_cell) = integers-f(gen-rng-f(seed), high: CR)
  let nn
  (rng, nn) = neighbors(rng, start_cell)
  let path = if CR == 1 { () } else { ((start_cell, nn),) }
  let visited = range(CR).map(_ => false)
  visited.at(start_cell) = true
  while path.len() != 0 {
    let (v, v_neighbors) = path.pop()
    let n = v_neighbors.pop()
    if v_neighbors.len() != 0 { path.push((v, v_neighbors)) }
    if visited.at(n) { continue }
    let (v_min, v_max) = min_max(v, n)
    if v_min+cols == v_max { // add v-n to the graph
      up.at(v_min) = true
    } else {  // v_min+C == v_max
      right.at(v_min) = true
    }
    (rng, nn) = neighbors(rng, n)
    path.push((n, nn))
    visited.at(n) = true
  }

  let draw_line(start, end) = {
    (
      curve.move((start.at(0) * LL, start.at(1) * LL)),
      curve.line((end.at(0) * LL, end.at(1) * LL))
    )
  }

  block(
    box(place(box(align(center + horizon, start), width: LL, height: LL), dy: -rows*LL)) +
    box(place(box(align(center + horizon, finish), width: LL, height: LL), dx: (cols - 1)*LL, dy: -LL)) +
    box(curve(
    ..draw_line((0, 0), (cols, 0)),
    ..draw_line((0, rows), (cols, rows)),
    ..draw_line((0, 1), (0, rows)),
    ..draw_line((cols, 0), (cols, rows - 1)),
    ..for r in range(rows - 1) {
      for c in range(cols) {
        if not up.at(index(c, r)) {
          draw_line((c, r+1), (c+1, r+1))
        }
      }
    },
    ..for c in range(cols - 1) {
      for r in range(rows) {
        if not right.at(index(c, r)) {
          draw_line((c+1, r), (c+1, r+1))
        }
      }
    },
    stroke: stroke
  )),
  width: LL*cols, height: LL*rows)  // do we need this?
})