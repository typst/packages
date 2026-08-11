// Collapse a sequence into contiguous `(value, count)` runs.
// Values listed in `ignore` are removed from the result. If everything is
// ignored, returns `((0, 0),)` so downstream clue rendering still has a shape.
#let compute-counts(values, ignore: (0,)) = {
  assert(values.len() > 0, message: "compute-counts expects at least one value.")
  let counts = ()
  let count = 0

  let last-value = values.at(0)
  for value in values {
    if value == last-value {
      count += 1
    } else {
      counts.push((last-value, count))
      last-value = value
      count = 1
    }
  }
  counts.push((last-value, count))
  counts = counts.filter(((e, c)) => not ignore.contains(e))
  if counts.len() == 0 {
    counts.push((0, 0))
  }
  counts
}

// Normalize one clue line into a sequence of `(value, count)` pairs.
// Bare numbers are interpreted as `(default-value, count)`.
#let normalize-clue-line(clue-line, default-value: 1) = {
  let normalized = ()
  for clue in clue-line {
    if ((type(clue) == int) or (type(clue) == float)) {
      normalized.push((default-value, clue))
    } else if ((type(clue) == array) and (clue.len() == 2)) {
      normalized.push(clue)
    }
  }
  if normalized.len() == 0 {
    normalized.push((0, 0))
  }
  normalized
}

// Normalize and validate all clue lines for one axis.
// Ensures the caller provided exactly `expected-len` rows or columns.
#let normalize-clues(clues, expected-len, axis: "rows", default-value: 1) = {
  assert(
    clues.len() == expected-len,
    message: "Expected " + str(expected-len) + " " + axis + " clues, got " + str(clues.len()) + ".",
  )
  clues.map(clue-line => normalize-clue-line(clue-line, default-value: default-value))
}

// Resolve a value through a string-keyed map or callback, falling back to the
// map's `default` entry or the explicit `default` argument.
#let get-value(value, map, default: none) = {
  if type(map) == function {
    map(value)
  } else {
    if ((value != none) and str(value) in map.keys()) {
      map.at(str(value))
    } else if "default" in map.keys() {
      map.at("default")
    } else {
      default
    }
  }
}

// Core board renderer used by both `classical-board` and `modern-board`.
// It computes missing clues from `board-matrix`, lays out clue cells around the
// puzzle, and delegates actual drawing to the injected drawer callbacks.
// = Arguments:
// == `board-matrix`
// A 2D array representing the puzzle solution. If it is `none`, the board size
// is inferred from `column-clues` and `row-clues` instead.
// == `cell-drawer`
// A callback that renders each puzzle cell. It receives the cell `value`, its
// `row` and `col`, and an `additional-info` dictionary containing the board
// `width` and `height`.
// == `column-cell-drawer` and `row-cell-drawer`
// Callbacks that render clue cells. They receive `(value, count, row, col)` and
// an `additional-info` dictionary containing the board `width`, `height`, and
// whether the clue is currently `marked`.
// == `cell-size`
// The size of each cell, used for layout and guide number placement.
// == `display-mask`
// An optional 2D mask used when `board-matrix` is present. Cells masked with
// values other than `1` or `true` are passed to `cell-drawer` as `none` while
// still contributing to computed clues.
// == `column-clues` and `row-clues`
// Optional explicit clues that override the ones computed from `board-matrix`.
// Each clue line can contain `(value, count)` pairs or bare counts.
// == `marked-column-clues` and `marked-row-clues`
// Optional lists of coordinates of clues to be rendered in a "marked" state, which
// can be used to indicate clues that are satisfied in the current board state.
// Coordinates are given as `(index, clue-position)`, where `index` is the row or
// column index of the clue and `clue-position` is the position of the clue in the
// clue line, counting from the outer end.
// == `hide-clues`
// If `true`, clue cells are omitted while the puzzle grid is still rendered.
// == `corner-cell-drawer`
// A callback that renders the top-left corner cell. It receives the maximum
// clue height and clue width and should return a spanning cell.
// == `show-guide-numbers`, `guide-number-sides`, `guide-number-step`, and `guide-number-drawer`
// Control the optional rendering of guide numbers along the sides of the board.
#let draw-board(
  board-matrix,
  cell-drawer,
  column-cell-drawer,
  row-cell-drawer,
  cell-size: 1em,
  display-mask: none,
  column-clues: none,
  row-clues: none,
  marked-column-clues: none,
  marked-row-clues: none,
  hide-clues: false,
  corner-cell-drawer: (height, width) => grid.cell(rowspan: height, colspan: width, ""),
  show-guide-numbers: false,
  guide-number-sides: ("right", "bottom"),
  guide-number-step: 5,
  guide-number-drawer: (value, is-row, side) => {
    align(center + horizon, text(0.75em, str(value), fill: gray))
  },
) = {
  let bm = board-matrix
  let has-board = bm != none
  assert(
    has-board or ((column-clues != none) and (row-clues != none)),
    message: "Pass a board-matrix or both column-clues and row-clues.",
  )
  if has-board {
    assert(bm.len() > 0, message: "board-matrix must have at least one row.")
    assert(bm.at(0).len() > 0, message: "board-matrix must have at least one column.")
  }

  let width = if has-board {
    bm.at(0).len()
  } else {
    column-clues.len()
  }
  let height = if has-board {
    bm.len()
  } else {
    row-clues.len()
  }
  if has-board {
    for row-values in bm {
      assert(
        row-values.len() == width,
        message: "All board-matrix rows must have the same length.",
      )
    }
  }

  let column-runs = if column-clues == none {
    let computed = ()
    // For each column
    for i in range(0, width) {
      let column-sequence = ()
      for j in range(0, height) {
        column-sequence.push(bm.at(j).at(i))
      }
      column-sequence = compute-counts(column-sequence)
      computed.push(column-sequence)
    }
    computed
  } else {
    normalize-clues(column-clues, width, axis: "column", default-value: 1)
  }

  let row-runs = if row-clues == none {
    let computed = ()
    // For each row
    for j in range(0, height) {
      let row-sequence = ()
      for i in range(0, width) {
        row-sequence.push(bm.at(j).at(i))
      }
      row-sequence = compute-counts(row-sequence)
      computed.push(row-sequence)
    }
    computed
  } else {
    normalize-clues(row-clues, height, axis: "row", default-value: 1)
  }

  let col-max-height = calc.max(..column-runs.map(cr => cr.len()))
  let row-max-width = calc.max(..row-runs.map(rr => rr.len()))

  // First cell: the corner one
  let cells = ()

  if not hide-clues {
    cells.push(corner-cell-drawer(col-max-height, row-max-width))

    // Column headers
    for row in range(0, col-max-height) {
      for col in range(0, width) {
        let num-values = column-runs.at(col).len()
        // Example: if column max height is 3 and a column has 2 elements, value will be none for row 0, for row 1 it will be the first element (top one), for row 2 it will be the second element (bottom one).
        let (value, count) = if ((col-max-height - row - 1) < num-values) {
          column-runs.at(col).at(row - (col-max-height - num-values))
        } else {
          (none, none)
        }
        let marked = (
          marked-column-clues != none and marked-column-clues.contains((col, (row - (col-max-height - num-values))))
        )
        cells.push(column-cell-drawer(value, count, row, col, additional-info: (
          width: width,
          height: height,
          marked: marked,
        )))
      }
    }
  }

  // for each row
  for row in range(0, height) {
    if not hide-clues {
      // Row header cells
      for col in range(0, row-max-width) {
        let num-values = row-runs.at(row).len()
        let (value, count) = if ((row-max-width - col - 1) < num-values) {
          row-runs.at(row).at(col - (row-max-width - num-values))
        } else {
          (none, 0)
        }
        let marked = marked-row-clues != none and marked-row-clues.contains((row, (col - (row-max-width - num-values))))
        cells.push(row-cell-drawer(value, count, row, col, additional-info: (
          width: width,
          height: height,
          marked: marked,
        )))
      }
    }
    // Hell is over, now rest of normal cells for each column in the row
    let row-cells = ()
    for col in range(0, width) {
      let element = if has-board and ((display-mask == none) or (display-mask.at(row).at(col) in (1, true))) {
        bm.at(row).at(col)
      } else {
        none
      }
      row-cells.push(cell-drawer(element, row, col, (width: width, height: height)))
    }
    cells = (..cells, ..row-cells)
  }

  let num-columns = width + (if not hide-clues { row-max-width } else { 0 })
  // tadah
  block(breakable: false, [
    #grid(columns: num-columns, ..cells)
    #if show-guide-numbers {
      if "top" in guide-number-sides or "bottom" in guide-number-sides {
        for i in range(guide-number-step, width + 1, step: guide-number-step) {
          if "top" in guide-number-sides {
            place(top + left, dx: (i - 1 + (row-max-width * if hide-clues { 0 } else { 1 })) * cell-size, dy: -cell-size, block(
              width: cell-size,
              height: cell-size,
              guide-number-drawer(i, false, "top"),
            ))
          }
          if "bottom" in guide-number-sides {
            place(bottom + left, dx: (i - 1 + (row-max-width* if hide-clues { 0 } else { 1 })) * cell-size, dy: cell-size, block(
              width: cell-size,
              height: cell-size,
              guide-number-drawer(i, false, "bottom"),
            ))
          }
        }
      }

      if "left" in guide-number-sides or "right" in guide-number-sides {
        for j in range(guide-number-step, height + 1, step: guide-number-step) {
          if "left" in guide-number-sides {
            place(left + top, dy: (j - 1 + (col-max-height * if hide-clues { 0 } else { 1 })) * cell-size, dx: -cell-size, block(inset: 0pt,
              width: cell-size,
              height: cell-size,
              guide-number-drawer(j, true, "left"),
            ))
          }
          if "right" in guide-number-sides {
            place(right + top, dy: (j - 1 + (col-max-height * if hide-clues { 0 } else { 1 })) * cell-size, dx: cell-size, block(
              width: cell-size,
              height: cell-size,
              guide-number-drawer(j, true, "right"),
            ))
          }
        }
      }
    }
  ])
}

// Utility to convert a multiline string representation of a board into a matrix.
// Arguments:
// - `text`: the multiline string representing the board. Each line corresponds to a row, and each character corresponds to a cell.
// - `row-separator`: the character(s) used to separate rows in the input text. Default is newline.
// - `char-to-value`: a map that converts characters in the input text to cell values. Default maps "0" to 0 and "1" to 1. Can also be a function that takes a character and returns a value.
#let text-to-matrix(text, row-separator: "\n", char-to-value: ("0": 0, "1": 1)) = {
  let lines = text.split(row-separator).map(line => line.trim()).filter(line => line.len() > 0)
  let matrix = ()
  for line in lines {
    let row = ()
    for char in line {
      if type(char-to-value) == dictionary {
        assert(
          char in char-to-value.keys(),
          message: "Character '" + char + "' not found in char-to-value map.",
        )
        row.push(char-to-value.at(char))
      } else {
        row.push(char-to-value(char))
      }
    }
    matrix.push(row)
  }
  matrix
}
