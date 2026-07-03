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
/// - start: Content placed in the start cell. Defaults to `none`.
/// - finish: Content placed in the finish cell. Defaults to `none`.
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

  let get-thickness(stroke) = {
    if stroke == none { return 0pt }
    if stroke == auto { return 1pt }
    let stroke-obj = std.stroke(stroke)
    if stroke-obj.thickness == auto { 1pt } else { stroke-obj.thickness }
  }
  let extra_thickness = get-thickness(stroke) / 2

  let horizontal_line(row, col_start, col_end) = (  // must be col_start < col_end
      curve.move((col_start * LL - extra_thickness, row * LL)),
      curve.line((col_end * LL + extra_thickness, row * LL))
    )

  let vertical_line(col, row_start, row_end) = (  // must be row_start < row_end
      curve.move((col * LL, row_start * LL - extra_thickness)),
      curve.line((col * LL, row_end * LL + extra_thickness))
    )

  block(
    box(place(box(align(center + horizon, start), width: LL, height: LL), dy: -rows*LL)) +
    box(place(box(align(center + horizon, finish), width: LL, height: LL), dx: (cols - 1)*LL, dy: -LL)) +
    box(curve(
    ..horizontal_line(0, 0, cols),
    ..horizontal_line(rows, 0, cols),
    ..vertical_line(0, 1, rows),
    ..vertical_line(cols, 0, rows - 1),
    ..for r in range(rows - 1) {
        let start_c = -1
        for c in range(cols) {
          if up.at(index(c, r)) {
            if start_c != -1 {
              horizontal_line(r+1, start_c, c)
              start_c = -1
            }
          } else {
            if start_c == -1 { start_c = c }
          }
        }
        if start_c != -1 { horizontal_line(r+1, start_c, cols) }
    },
    ..for c in range(cols - 1) {
        let start_r = -1
        for r in range(rows) {
          if right.at(index(c, r)) {
            if start_r != -1 {
              vertical_line(c+1, start_r, r)
              start_r = -1
            }
          } else {
            if start_r == -1 { start_r = r }
          }
        }
        if start_r != -1 { vertical_line(c+1, start_r, rows) }
    },
    stroke: stroke
  )),
  width: LL*cols, height: LL*rows)  // do we need this?
})