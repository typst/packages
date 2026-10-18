# `sudokyst`

`sudokyst` is a Typst package for rendering Sudoku boards with optional candidate hints and highlight overlays.

It also includes a helper for computing legal candidate values for a cell from the current board state.

## Rendering approach

The board is rendered as a native Typst `table` with:

- fixed-width columns and fixed-height rows so the board stays square
- thicker strokes on 3x3 block boundaries
- optional fills for highlighted rows, columns, 3x3 boxes, overlapping intersections, and explicit cells
- optional per-cell hint rendering as a nested `3 x 3` Typst `grid`

This keeps the package fully Typst-native and easy to style without generating SVG manually.

## Example

```typ
#import "@preview/sudokyst:0.1.0": sudoku

#let board = (
  (8, 0, 0, 0, 0, 0, 0, 0, 2),
  (0, 4, 0, 7, 0, 1, 0, 5, 0),
  (0, 0, 0, 0, 8, 0, 0, 0, 0),
  (0, 7, 0, 4, 0, 5, 0, 2, 0),
  (0, 0, 8, 0, 2, 0, 6, 0, 0),
  (0, 2, 0, 6, 0, 8, 0, 1, 0),
  (0, 0, 0, 0, 5, 0, 0, 0, 0),
  (0, 9, 0, 8, 0, 4, 0, 7, 0),
  (6, 0, 0, 0, 0, 0, 0, 0, 4),
)

#let hints = (
  ((), (1, 3, 5), (1, 3, 5, 7), (), (), (), (), (3, 4, 6, 9), ()),
  ((2, 3, 9), (), (2, 3, 6, 9), (), (3, 6, 9), (), (3, 8, 9), (), (3, 6, 8, 9)),
  ((1, 2, 3, 5, 7, 9), (1, 3, 5, 6), (1, 2, 3, 5, 6, 7, 9), (2, 3, 5, 9), (), (2, 3, 6, 9), (1, 3, 4, 7, 9), (3, 4, 6, 9), (1, 3, 6, 7, 9)),
  ((1, 3, 9), (), (1, 3, 6, 9), (), (3, 9), (), (3, 8, 9), (), (3, 8, 9)),
  ((1, 3, 4, 5, 9), (1, 3, 5), (), (1, 3, 5, 9), (), (3, 7, 9), (), (3, 4, 9), (3, 5, 7, 9)),
  ((1, 3, 4, 5, 9), (), (3, 4, 5, 9), (), (3, 7, 9), (), (3, 4, 5, 7, 9), (), (3, 5, 7, 9)),
  ((1, 2, 3, 4, 7), (1, 3, 8), (1, 2, 3, 4, 7), (1, 2, 3, 9), (), (2, 3, 6, 9), (1, 2, 3, 8, 9), (3, 6, 8, 9), (1, 3, 6, 8, 9)),
  ((1, 2, 3, 5), (), (1, 2, 3, 5), (), (1, 3, 6), (), (1, 2, 3, 5, 8), (), (1, 3, 5, 6, 8)),
  ((), (1, 3, 5, 8), (1, 2, 3, 5, 7), (1, 2, 3, 9), (1, 3, 7, 9), (2, 3, 7, 9), (1, 2, 3, 5, 8, 9), (3, 8, 9), ()),
)

#sudoku(
  board: board,
  hints: hints,
  show-hints: true,
  highlighted-rows: (2, 5),
  highlighted-columns: (4,),
  highlighted-boxes: (5,),
  highlighted-cells: ((5, 5),),
)
```

Highlight selections are 1-based:

- `highlighted-rows: (1,)` highlights the first row
- `highlighted-columns: (9,)` highlights the ninth column
- `highlighted-boxes: (5,)` highlights the center `3 x 3` box
- `highlighted-cells: ((5, 5),)` highlights the center cell

Boxes are numbered left-to-right and top-to-bottom:

- `(1, 2, 3)` for the top band
- `(4, 5, 6)` for the middle band
- `(7, 8, 9)` for the bottom band

Empty cells should be represented with `0` or `none`.

## Main options

- `board`: a `9 x 9` array of values
- `hints`: a `9 x 9` array whose cells contain candidate arrays like `(1, 3, 9)`
- `show-hints`: show the nested `3 x 3` candidate grid in empty cells
- `highlighted-rows`, `highlighted-columns`, `highlighted-boxes`, `highlighted-cells`: optional 1-based highlight selections
- `cell-size`: side length of each Sudoku cell
- `thin-stroke` and `block-stroke`: cell border styling
- `value-color` and `hint-color`: text colors
- `row-highlight-fill`, `column-highlight-fill`, `box-highlight-fill`, `overlap-highlight-fill`, `cell-highlight-fill`: highlight colors
- `value-text-size` and `hint-text-size`: optional text size overrides

## Helper functions

- `available-values(board, row, column)`: returns the legal values for the given cell as an array like `(1, 2, 4)`. Rows and columns are 1-based. If the cell is already filled, the function returns `()`.
- `valid-move(board, row, column, value)`: returns `true` when `value` is a legal `1..9` placement for the given empty 1-based cell on the current board, otherwise `false`.
- `first-single-position(board)`: returns the 1-based position `(row, column)` of the first cell, scanned top-to-bottom and left-to-right, whose available-values list has length `1`. Returns `none` if there is no such cell.
- `first-single-move(board)`: returns `((row, column), value)` for the first cell, scanned top-to-bottom and left-to-right, whose available-values list has length `1`. Returns `none` if there is no such cell.
- `propagate-step(board)`: applies one `first-single-move(board)` if available. Returns `none` if there is no forced single, otherwise a record with `board`, `position`, `value`, and `move`.
- `propagate(board)`: repeatedly applies `first-single-move(board)` until no forced single remains. Returns a record with `board`, `positions`, and `moves`, where `positions` is the ordered list of filled 1-based cells and `moves` is the ordered list of `((row, column), value)` pairs.
- `solve(board)`: solves the Sudoku with repeated propagation plus recursive backtracking. Returns a record with `solved`, `board`, `boards`, and `move_groups`. `boards` is the ordered trace of board states after each propagation and each unforced guess, across the search tree until the first solution. `move_groups` aligns with `boards`; a propagation contributes multiple moves, while an unforced guess contributes a one-element array. Very hard puzzles may still exceed Typst's maximum function-call depth.
- `generate-hints(board, positions)`: returns a full `9 x 9` hints array for `sudoku(...)`. `positions` is a list of 1-based `(row, column)` pairs. Selected empty cells receive computed candidates; all other cells receive `()`.
- `generate-hints-all(board)`: returns a full `9 x 9` hints array for every empty cell on the board. Filled cells receive `()`.
- `set-cell(board, row, column, value)`: returns a new board with the given 1-based cell updated. `value` may be `0`, `none`, or an integer from `1` to `9`.

Example:

```typ
#import "@preview/sudokyst:0.1.0": available-values, valid-move, first-single-position, first-single-move, propagate-step, propagate, solve, generate-hints, generate-hints-all, set-cell

#let candidates = available-values(board, 1, 3)
#let ok = valid-move(board, 1, 3, 4)
#let single = first-single-position(board)
#let single-move = first-single-move(board)
#let step = propagate-step(board)
#let propagation = propagate(board)
#let solution = solve(board)
#let hints = generate-hints(board, ((1, 3), (1, 4), (2, 2)))
#let all-hints = generate-hints-all(board)
#let next-board = set-cell(board, 1, 3, 4)
```
