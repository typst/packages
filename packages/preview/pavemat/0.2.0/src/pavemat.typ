/// The core library of pavemat.


#let _get-fills-from(n, m, i, j, hfence: (), vfence: ()) = {
  // has each grid been visited
  let vis = (false,) * (n * m)
  // check pos inside
  let check(ii, jj) = {
    ii >= 0 and ii < n and jj >= 0 and jj < m
  }

  // start flood-fill
  vis.at(i * m + j) = true
  let stack = ((i, j),)
  let points = ()

  while stack.len() > 0 {
    let (i, j) = stack.pop()
    points.push((i, j))

    // manually enumerate 4 directions

    let (ii, jj) = (i + 1, j) // down
    if check(ii, jj) and not vis.at(ii * m + jj) and not hfence.at(ii * m + j) {
      vis.at(ii * m + jj) = true
      stack.push((ii, jj))
    }

    let (ii, jj) = (i - 1, j) // up
    if check(ii, jj) and not vis.at(ii * m + jj) and not hfence.at(i * m + j) {
      vis.at(ii * m + jj) = true
      stack.push((ii, jj))
    }

    let (ii, jj) = (i, j + 1) // right
    if check(ii, jj) and not vis.at(ii * m + jj) and not vfence.at(i * m + jj) {
      vis.at(ii * m + jj) = true
      stack.push((ii, jj))
    }

    let (ii, jj) = (i, j - 1) // left
    if check(ii, jj) and not vis.at(ii * m + jj) and not vfence.at(i * m + j) {
      vis.at(ii * m + jj) = true
      stack.push((ii, jj))
    }
  }

  return points
}


#let _parse-pave-array(n, m, pave, dirs, debug, base-stroke) = {
  let hfence = (false,) * ((n + 1) * m)
  let vfence = (false,) * (n * (m + 1))

  let dashes = ()

  for item in pave {
    if type(item) == str {
      item = (path: item)
    }
    let path = item.path.replace("'", "\"")
    let from = item.at("from", default: "top-left")

    // the start position
    let (i, j) = if from == "top-left" {
      (0, 0)
    } else if from == "top-right" {
      (0, m)
    } else if from == "bottom-left" {
      (n, 0)
    } else if from == "bottom-right" {
      (n, m)
    } else if type(from) == array and from.len() == 2 {
      from
    } else {
      panic(`expect one of "top-left", "top-right", "bottom-left", "bottom-right" or tuple (x, y)`.text)
    }

    let stroke-stack = (item.at("stroke", default: base-stroke),)
    let k = 0

    while k < path.len() {
      let c = path.at(k)

      // control character
      if c == "(" {
        let p = path.slice(k).position(")") + k
        let new-stroke = stroke-stack.last() + eval(path.slice(k, p + 1))
        stroke-stack.push(new-stroke)
        k = p + 1
        continue
      }
      if c == "[" {
        k += 1
        continue
      } else if c == "]" {
        stroke-stack.pop()
        k += 1
        continue
      }

      // move one step
      let dd = upper(c)
      let ii = if dd == dirs.up { i - 1 } else if dd == dirs.down { i + 1 } else { i }
      let jj = if dd == dirs.left { j - 1 } else if dd == dirs.right { j + 1 } else { j }

      // add stroke line if the direction character is upper
      let cur-stroke = stroke-stack.last()

      // debug line
      if debug {
        if c != upper(c) {
          c = upper(c)
          cur-stroke = if debug == true { gray + 0.5pt } else { debug }
        }
      }

      if c == dirs.up {
        dashes.push(grid.vline(x: j, start: ii, end: i, stroke: cur-stroke))
        vfence.at(ii * m + j) = true
      } else if c == dirs.left {
        dashes.push(grid.hline(y: i, start: jj, end: j, stroke: cur-stroke))
        hfence.at(i * m + jj) = true
      } else if c == dirs.down {
        dashes.push(grid.vline(x: j, start: i, end: ii, stroke: cur-stroke))
        vfence.at(i * m + j) = true
      } else if c == dirs.right {
        dashes.push(grid.hline(y: i, start: j, end: jj, stroke: cur-stroke))
        hfence.at(i * m + j) = true
      }

      i = ii
      j = jj
      k += 1
    }
  }

  return (hfence, vfence, dashes)
}


#let _get-cell-fills(n, m, fills, hfence, vfence) = {
  let cell-fills = (none,) * (n * m)

  // make cells filled
  for (pos, fill) in fills {
    // fill all
    if pos == "" {
      cell-fills = (fill,) * (n * m)
      continue
    }

    let exact = false
    if pos.starts-with("[") and pos.ends-with("]") {
      exact = true
      pos = pos.slice(1, -1)
    }

    let (i, j) = pos.split("-")
    i = if i == "top" { 0 } else if i == "bottom" { n - 1 } else { int(i) }
    j = if j == "left" { 0 } else if j == "right" { m - 1 } else { int(j) }

    let points = if exact {
      ((i, j),)
    } else {
      _get-fills-from(n, m, i, j, hfence: hfence, vfence: vfence)
    }

    for (i, j) in points {
      cell-fills.at(i * m + j) = fill
    }
  }

  return cell-fills
}


#let _build-grid-mat(ma, dashes, cell-fills, delim, is-block, display-style) = context {
  let m = ma.rows.at(0).len()

  let ma-fields = ma.fields()
  let row-gap = ma-fields.at("row-gap", default: math.mat.row-gap) / 2
  let col-gap = ma-fields.at("column-gap", default: math.mat.column-gap) / 2

  let is-block = if is-block == auto { math.equation.block } else { is-block }
  let delim = if delim == auto { ma-fields.at("delim", default: math.mat.delim) } else { delim }

  // calculate the minimum ascent and descent from a paren.
  let dummy = $\($
  let base-ascent = measure(text(top-edge: "bounds", dummy)).height
  let base-descent = (
    measure(text(bottom-edge: "bounds", dummy)).height - measure(text(bottom-edge: "baseline", dummy)).height
  )

  let row-heights = ()
  let cells = for (i, row) in ma.rows.enumerate() {
    // adjust the ascent and descent for each line
    let combined = math.equation(row.join())
    let ascent = calc.max(base-ascent, measure(text(top-edge: "bounds", combined)).height)
    let descent = calc.max(
      base-descent,
      measure(text(bottom-edge: "bounds", combined)).height - measure(text(bottom-edge: "baseline", combined)).height,
    )

    let height = ascent + descent
    let strut = box(height: ascent, width: 0pt) // to unify the ascent
    for (j, cell) in row.enumerate() {
      let eq = math.equation(cell)
      let f = cell-fills.at(i * m + j)
      (grid.cell(eq + strut, fill: f),)
    }
    row-heights.push(height + row-gap * 2)
  }

  let mat-grid = grid(
    columns: m,
    align: ma-fields.at("align", default: math.mat.align),
    inset: (x: col-gap, y: row-gap),
    rows: row-heights,
    ..cells, ..dashes
  )

  let ret = mat-grid

  if delim != none {
    ret = math.vec(delim: delim, ret)
  }
  if display-style {
    ret = math.display(ret)
  }
  return math.equation(ret, block: is-block)
}


/// Create a _pavemat_ from [`math.mat`] or [`math.equation`].
///
/// For details on the syntax of pave strings and position specifications, please refer to the manual.
///
/// *Example:*
/// ```example
/// #pavemat(
///   $ mat(1, 2, 3; 4, 5, 6; 7, 8, 9; 10, 11, 12) $,
///   pave: "dSDSDSLLAAWASSDD",
///   fills: (
///     "1-1": red.transparentize(80%),
///     "1-2": blue.transparentize(80%),
///     "3-0": green.transparentize(80%),
///   ),
/// )
/// ```
///
/// - eq (equation, mat, array): haha
///   The input matrix expression to be styled. It can be a mathematical equation or a matrix. Specifically,
///   - A ```typc math.equation```. It should contain only a `math.mat` as its body. Example: ```typ $mat(1, 2; 3, 4)$```. ```typc math.display``` in the equation is not properly supported yet.
///   - A `math.mat`. Example: ```typc math.mat((1, 2), (3, 4))```.
///   - A nested array. Example: ```typc ((1, 2), (3, 4))```.
///   If a matrix type is given, pavemat will use its style, including `row-gap`, `column-gap` and `delim`.
///
/// - pave (str, dictionary, array):
///   Describes the pavement lines. It accepts the following formats:
///   - A path string like ```typc "WASD"```.
///   - A dictionary with fields: `path`, `from` (optional, default: ```typc "top-left"```), `stroke` (optional, default: empty). The path is a pave string.
///   - An array whose item type is either string or dictionary described above.
///
/// - stroke (stroke):
///   The global stroke style applying to all segments. This argument will be passed to `cell.stroke`.
///   Accepts anything can be used as stroke.
///   Examples: ```typc blue + 1pt```, ```typc (dash: "dashed", thickness: 0.5pt)```.
///
/// - fills (dictionary):
///   Specifies the fill colors for specific cells.
///   The key represents a position, and the value is the color passed to `cell.fill`.
///   An empty key `""` is used for global fill.
///
/// - dir-chars (dictionary):
///   Controls whether the output is in display style.
///   Its fields will override the default ```typc (up: "W", down: "S", left: "A", right: "D")```.
///   Example: ```typc (up: "U", down: "D", left: "L", right: "R")```
///
/// - delim (auto, any):
///   The delimiter of the matrix.
///   If set to `auto`, it uses the delimiter of the input matrix.
///
/// - block (auto, bool):
///   Controls whether the output is block-style.
///   If set to `auto`, it uses the block setting of the input equation.
///
/// - display-style (bool):
///   Controls whether the output is in display style.
///   If set to `true`, the result will be granted a ```typc math.display(...)```.
///
/// - debug (bool):
///   Controls whether the output is block-style.
///   If set to `auto`, it uses the block setting of the input equation.
///
/// -> content
#let pavemat(
  eq,
  pave: (),
  stroke: (dash: "dashed", thickness: 0.5pt),
  fills: (:),
  dir-chars: (:),
  delim: auto,
  block: auto,
  display-style: true,
  debug: false,
) = {
  // direction character definition
  let dirs = (up: "W", down: "S", left: "A", right: "D") + dir-chars

  // get the matrix
  let ma = if "body" in eq.fields() { eq.body } else { eq }

  // pavement
  if type(pave) != array {
    pave = (pave,)
  }

  if type(fills) != dictionary {
    fills = ("": fills)
  }

  if block == auto {
    block = eq.fields().at("block", default: auto)
  }

  // number of rows and columns
  let (n, m) = (ma.rows.len(), ma.rows.at(0).len())

  let (hfence, vfence, dashes) = _parse-pave-array(n, m, pave, dirs, debug, stroke)

  let cell-fills = _get-cell-fills(n, m, fills, hfence, vfence)

  return _build-grid-mat(ma, dashes, cell-fills, delim, block, display-style)
}
