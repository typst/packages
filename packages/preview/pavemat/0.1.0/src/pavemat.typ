#let _get-fills-from(a, i, j, hfence: (), vfence: ()) = {
  // number of rows and columns
  let (n, m) = (a.len(), a.at(0).len())
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
  // @typstyle off
  let ma = if "body" in eq.fields() { eq.body } else { eq }

  // pavement
  if type(pave) != array {
    pave = (pave,)
  }

  // number of rows and columns
  let (n, m) = (ma.rows.len(), ma.rows.at(0).len())

  let hfence = (false,) * ((n + 1) * m)
  let vfence = (false,) * (n * (m + 1))

  let dashes = ()

  // parse pave array
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
    } else if type(from) == "array" and from.len() == 2 {
      from
    } else {
      panic(`expect one of "top-left", "top-right", "bottom-left", "bottom-right" or tuple (x, y)`.text)
    }

    let stroke-stack = (item.at("stroke", default: stroke),)
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
      let ii = if dd == dirs.up {
        i - 1
      } else if dd == dirs.down {
        i + 1
      } else {
        i
      }
      let jj = if dd == dirs.left {
        j - 1
      } else if dd == dirs.right {
        j + 1
      } else {
        j
      }

      // add stroke line if the direction character is upper
      let cur-stroke = stroke-stack.last()

      // debug line
      if debug != false {
        if c != upper(c) {
          c = upper(c)
          cur-stroke = if debug == true {
            gray + 0.5pt
          } else {
            debug
          }
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

      (i, j) = (ii, jj)
      k += 1
    }
  }

  let cell-fills = (none,) * (n * m)

  if type(fills) != dictionary {
    fills = ("": fills)
  }

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
    // @typstyle off
    i = if i == "top" { 0 } else if i == "bottom" { n - 1 } else { int(i) }
    // @typstyle off
    j = if j == "left" { 0 } else if j == "right" { m - 1 } else { int(j) }

    let points = if exact {
      ((i, j),)
    } else {
      _get-fills-from(ma.rows, i, j, hfence: hfence, vfence: vfence)
    }

    for (i, j) in points {
      cell-fills.at(i * m + j) = fill
    }
  }

  // grid cells
  let cells = ma.rows.flatten().zip(cell-fills).map(((c, f)) => grid.cell(math.equation(c), fill: f))

  return context {
    let row-gap = ma.fields().at("row-gap", default: math.mat.row-gap) / 2
    let col-gap = ma.fields().at("column-gap", default: math.mat.column-gap) / 2

    let mat-grid = grid(columns: m, align: center + horizon, inset: (x: col-gap, y: row-gap), ..cells, ..dashes)

    let is-block = if block == auto {
      eq.fields().at("block", default: math.equation.block)
    } else {
      block
    }

    let delim = if delim == auto {
      ma.fields().at("delim", default: "(")
    } else {
      delim
    }

    let ret = mat-grid

    if delim != none {
      ret = math.vec(delim: delim, ret)
    }

    if display-style {
      ret = math.display(ret)
    }

    return math.equation(ret, block: is-block)
  }
}
