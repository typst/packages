#let empty-board = (
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0, 0),
)

#let empty-hints = (
  ((), (), (), (), (), (), (), (), ()),
  ((), (), (), (), (), (), (), (), ()),
  ((), (), (), (), (), (), (), (), ()),
  ((), (), (), (), (), (), (), (), ()),
  ((), (), (), (), (), (), (), (), ()),
  ((), (), (), (), (), (), (), (), ()),
  ((), (), (), (), (), (), (), (), ()),
  ((), (), (), (), (), (), (), (), ()),
  ((), (), (), (), (), (), (), (), ()),
)

#let _normalize-selection(value) = if value == none { () } else { value }

#let _normalize-hint-cell(value) = if value == none { () } else { value }

#let _assert-grid-shape(name, grid) = {
  assert(
    grid.len() == 9 and grid.all(row => row.len() == 9),
    message: name + " must be a 9x9 array.",
  )
}

#let _assert-cell-position(row, column) = {
  assert(
    row >= 1 and row <= 9 and column >= 1 and column <= 9,
    message: "row and column must be between 1 and 9.",
  )
}

#let _assert-cell-value(value) = {
  assert(
    (value == none) or (type(value) == int and value >= 0 and value <= 9),
    message: "value must be an integer between 0 and 9, or none.",
  )
}

#let _has-value(value) = value != none and value != 0

#let _set-cell(board, row, column, value) = {
  let row-index = row - 1
  let column-index = column - 1

  range(9).map(current-row => {
    if current-row == row-index {
      range(9).map(current-column => {
        if current-column == column-index {
          value
        } else {
          board.at(current-row).at(current-column)
        }
      })
    } else {
      board.at(current-row)
    }
  })
}

#let _row-has-value(board, row, value) = board.at(row).contains(value)

#let _column-has-value(board, column, value) = {
  range(9).any(row => board.at(row).at(column) == value)
}

#let _column-values(board, column) = range(9).map(row => board.at(row).at(column))

#let _block-has-value(board, row, column, value) = {
  let block-row-start = calc.floor(row / 3) * 3
  let block-column-start = calc.floor(column / 3) * 3

  range(block-row-start, block-row-start + 3)
    .any(block-row => range(block-column-start, block-column-start + 3)
      .any(block-column => board.at(block-row).at(block-column) == value))
}

#let _available-values(board, row, column) = {
  let row-index = row - 1
  let column-index = column - 1
  let current-value = board.at(row-index).at(column-index)

  if _has-value(current-value) {
    ()
  } else {
    range(1, 10).filter(value =>
      not _row-has-value(board, row-index, value)
      and not _column-has-value(board, column-index, value)
      and not _block-has-value(board, row-index, column-index, value)
    )
  }
}

#let _block-values(board, block-row-start, block-column-start) = {
  range(block-row-start, block-row-start + 3)
    .map(block-row => range(block-column-start, block-column-start + 3)
      .map(block-column => board.at(block-row).at(block-column)))
    .flatten()
}

#let _has-duplicate-values(values) = {
  range(values.len()).any(i => {
    let value = values.at(i)

    _has-value(value) and range(i + 1, values.len()).any(j => values.at(j) == value)
  })
}

#let _board-complete(board) = {
  range(9).all(row => range(9).all(column => _has-value(board.at(row).at(column))))
}

#let _board-infeasible(board) = {
  let duplicate-rows = range(9).any(row => _has-duplicate-values(board.at(row)))
  let duplicate-columns = range(9).any(column => _has-duplicate-values(_column-values(board, column)))
  let duplicate-blocks = (0, 3, 6).any(block-row =>
    (0, 3, 6).any(block-column =>
      _has-duplicate-values(_block-values(board, block-row, block-column))
    )
  )
  let empty-cell-without-candidates = range(1, 10).any(row =>
    range(1, 10).any(column =>
      not _has-value(board.at(row - 1).at(column - 1)) and _available-values(board, row, column).len() == 0
    )
  )

  duplicate-rows or duplicate-columns or duplicate-blocks or empty-cell-without-candidates
}

#let available-values(board, row, column) = {
  _assert-grid-shape("board", board)
  _assert-cell-position(row, column)
  _available-values(board, row, column)
}

#let valid-move(board, row, column, value) = {
  _assert-grid-shape("board", board)
  _assert-cell-position(row, column)
  assert(
    type(value) == int and value >= 1 and value <= 9,
    message: "value must be an integer between 1 and 9.",
  )

  let current-value = board.at(row - 1).at(column - 1)

  if _has-value(current-value) {
    false
  } else {
    available-values(board, row, column).contains(value)
  }
}

#let first-single-position(board) = {
  _assert-grid-shape("board", board)

  for row in range(1, 10) {
    for column in range(1, 10) {
      if available-values(board, row, column).len() == 1 {
        return (row, column)
      }
    }
  }

  none
}

#let first-single-move(board) = {
  _assert-grid-shape("board", board)

  for row in range(1, 10) {
    for column in range(1, 10) {
      let candidates = available-values(board, row, column)

      if candidates.len() == 1 {
        return ((row, column), candidates.at(0))
      }
    }
  }

  none
}

#let _first-branch(board) = {
  for row in range(1, 10) {
    for column in range(1, 10) {
      let candidates = available-values(board, row, column)

      if candidates.len() >= 2 {
        return ((row, column), candidates)
      }
    }
  }

  none
}

#let _propagate(board, positions, moves) = {
  let single-move = first-single-move(board)

  if single-move == none {
    (
      board: board,
      positions: positions,
      moves: moves,
    )
  } else {
    let position = single-move.at(0)
    let value = single-move.at(1)
    let next-board = _set-cell(board, position.at(0), position.at(1), value)

    _propagate(
      next-board,
      positions + (position,),
      moves + (single-move,),
    )
  }
}

#let propagate(board) = {
  _assert-grid-shape("board", board)
  _propagate(board, (), ())
}

#let propagate-step(board) = {
  _assert-grid-shape("board", board)

  let single-move = first-single-move(board)

  if single-move == none {
    none
  } else {
    let position = single-move.at(0)
    let value = single-move.at(1)

    (
      board: _set-cell(board, position.at(0), position.at(1), value),
      position: position,
      value: value,
      move: single-move,
    )
  }
}

#let _solve(
  board,
  mode: "solve",
  branch-position: none,
  candidates: none,
  candidate-index: 0,
  boards: (),
  move-groups: (),
) = {
  if mode == "branch" {
    if candidate-index >= candidates.len() {
      (
        solved: false,
        board: none,
        boards: boards,
        move_groups: move-groups,
      )
    } else {
      let value = candidates.at(candidate-index)
      let move = (branch-position, value)
      let guessed-board = _set-cell(board, branch-position.at(0), branch-position.at(1), value)
      let guessed-boards = boards + (guessed-board,)
      let guessed-move-groups = move-groups + ((move,),)
      let subproblem = _solve(guessed-board)
      let branch-boards = guessed-boards + subproblem.boards
      let branch-move-groups = guessed-move-groups + subproblem.move_groups

      if subproblem.solved {
        (
          solved: true,
          board: subproblem.board,
          boards: branch-boards,
          move_groups: branch-move-groups,
        )
      } else {
        _solve(
          board,
          mode: "branch",
          branch-position: branch-position,
          candidates: candidates,
          candidate-index: candidate-index + 1,
          boards: branch-boards,
          move-groups: branch-move-groups,
        )
      }
    }
  } else {
    let propagation = propagate(board)
    let boards = (propagation.board,)
    let move-groups = (propagation.moves,)

    if _board-infeasible(propagation.board) {
      (
        solved: false,
        board: none,
        boards: boards,
        move_groups: move-groups,
      )
    } else if _board-complete(propagation.board) {
      (
        solved: true,
        board: propagation.board,
        boards: boards,
        move_groups: move-groups,
      )
    } else {
      let branch = _first-branch(propagation.board)

      if branch == none {
        (
          solved: false,
          board: none,
          boards: boards,
          move_groups: move-groups,
        )
      } else {
        _solve(
          propagation.board,
          mode: "branch",
          branch-position: branch.at(0),
          candidates: branch.at(1),
          candidate-index: 0,
          boards: boards,
          move-groups: move-groups,
        )
      }
    }
  }
}

#let solve(board) = {
  _assert-grid-shape("board", board)
  _solve(board)
}

#let generate-hints(board, positions) = {
  _assert-grid-shape("board", board)

  for position in positions {
    assert(
      type(position) == array and position.len() == 2,
      message: "each position must be a (row, column) pair.",
    )
    _assert-cell-position(position.at(0), position.at(1))
  }

  range(9).map(row => range(9).map(col => {
    let position = (row + 1, col + 1)

    if positions.contains(position) {
      available-values(board, row + 1, col + 1)
    } else {
      ()
    }
  }))
}

#let generate-hints-all(board) = {
  _assert-grid-shape("board", board)

  range(9).map(row => range(9).map(col => {
    available-values(board, row + 1, col + 1)
  }))
}

#let set-cell(board, row, column, value) = {
  _assert-grid-shape("board", board)
  _assert-cell-position(row, column)
  _assert-cell-value(value)
  _set-cell(board, row, column, value)
}

#let _box-index(row, col) = calc.floor(row / 3) * 3 + calc.floor(col / 3) + 1

#let _cell-fill(
  row,
  col,
  highlighted-rows,
  highlighted-columns,
  highlighted-boxes,
  highlighted-cells,
  row-highlight-fill,
  column-highlight-fill,
  box-highlight-fill,
  overlap-highlight-fill,
  cell-highlight-fill,
) = {
  let row-hit = highlighted-rows.contains(row + 1)
  let column-hit = highlighted-columns.contains(col + 1)
  let box-hit = highlighted-boxes.contains(_box-index(row, col))
  let cell-hit = highlighted-cells.contains((row + 1, col + 1))

  if cell-hit {
    cell-highlight-fill
  } else if (if row-hit { 1 } else { 0 }) + (if column-hit { 1 } else { 0 }) + (if box-hit { 1 } else { 0 }) >= 2 {
    overlap-highlight-fill
  } else if row-hit {
    row-highlight-fill
  } else if column-hit {
    column-highlight-fill
  } else if box-hit {
    box-highlight-fill
  } else {
    none
  }
}

#let _cell-stroke(col, row, thin-stroke, block-stroke) = (
  left: if col == 0 {
    block-stroke
  } else if calc.rem(col, 3) == 0 {
    block-stroke
  } else {
    thin-stroke
  },
  top: if row == 0 {
    block-stroke
  } else if calc.rem(row, 3) == 0 {
    block-stroke
  } else {
    thin-stroke
  },
  right: if col == 8 { block-stroke } else { 0pt },
  bottom: if row == 8 { block-stroke } else { 0pt },
)

#let _hint-grid(cell-hints, cell-size, hint-text-size, hint-color) = {
  let slot-size = cell-size / 3

  grid(
    columns: (slot-size,) * 3,
    rows: (slot-size,) * 3,
    gutter: 0pt,
    align: center + horizon,
    ..range(1, 10).map(n => {
      if cell-hints.contains(n) {
        text(size: hint-text-size, fill: hint-color)[#n]
      } else {
        []
      }
    }),
  )
}

#let _cell-content(
  board,
  hints,
  row,
  col,
  show-hints,
  cell-size,
  value-text-size,
  hint-text-size,
  value-color,
  hint-color,
) = {
  let value = board.at(row).at(col)

  if _has-value(value) {
    text(size: value-text-size, weight: "semibold", fill: value-color)[#value]
  } else if show-hints {
    let cell-hints = _normalize-hint-cell(hints.at(row).at(col))
    _hint-grid(cell-hints, cell-size, hint-text-size, hint-color)
  } else {
    []
  }
}

#let sudoku(
  board: empty-board,
  hints: none,
  show-hints: false,
  highlighted-rows: none,
  highlighted-columns: none,
  highlighted-boxes: none,
  highlighted-cells: none,
  cell-size: 2.4em,
  thin-stroke: 0.5pt + black,
  block-stroke: 1.4pt + black,
  value-color: black,
  hint-color: luma(90),
  row-highlight-fill: rgb("f7f1c7"),
  column-highlight-fill: rgb("ddeefa"),
  box-highlight-fill: rgb("f4dfef"),
  overlap-highlight-fill: rgb("e7f4dc"),
  cell-highlight-fill: rgb("f8d7d4"),
  value-text-size: auto,
  hint-text-size: auto,
) = {
  _assert-grid-shape("board", board)

  let hints = if hints == none { empty-hints } else { hints }
  _assert-grid-shape("hints", hints)

  let highlighted-rows = _normalize-selection(highlighted-rows)
  let highlighted-columns = _normalize-selection(highlighted-columns)
  let highlighted-boxes = _normalize-selection(highlighted-boxes)
  let highlighted-cells = _normalize-selection(highlighted-cells)
  let value-text-size = if value-text-size == auto {
    cell-size * 0.5
  } else {
    value-text-size
  }
  let hint-text-size = if hint-text-size == auto {
    cell-size / 5.5
  } else {
    hint-text-size
  }

  table(
    columns: (cell-size,) * 9,
    rows: (cell-size,) * 9,
    inset: 0pt,
    align: center + horizon,
    fill: (col, row) => _cell-fill(
      row,
      col,
      highlighted-rows,
      highlighted-columns,
      highlighted-boxes,
      highlighted-cells,
      row-highlight-fill,
      column-highlight-fill,
      box-highlight-fill,
      overlap-highlight-fill,
      cell-highlight-fill,
    ),
    stroke: (col, row) => _cell-stroke(col, row, thin-stroke, block-stroke),
    ..range(9)
      .map(row => range(9).map(col => _cell-content(
        board,
        hints,
        row,
        col,
        show-hints,
        cell-size,
        value-text-size,
        hint-text-size,
        value-color,
        hint-color,
      )))
      .flatten(),
  )
}
