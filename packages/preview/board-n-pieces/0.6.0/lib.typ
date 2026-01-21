/// Chess pieces symbols.
#import "chess-sym.typ"


/// The starting position of a standard chess game.
#let starting-position = (
  type: "board-n-pieces:position",
  fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  board: (
    ("R", "N", "B", "Q", "K", "B", "N", "R"),
    ("P", ) * 8,
    (none, ) * 8,
    (none, ) * 8,
    (none, ) * 8,
    (none, ) * 8,
    ("p", ) * 8,
    ("r", "n", "b", "q", "k", "b", "n", "r"),
  ),
  active: "w",
  castling-availabilities: (
    white-king-side: true,
    white-queen-side: true,
    black-king-side: true,
    black-queen-side: true,
  ),
  en-passant-target-square: none,
  halfmove: 0,
  fullmove: 1,
)


/// Creates a position from ranks.
///
/// For example, this creates the starting position.
/// ```typ
/// #let starting-position = position(
///   "rnbqkbnr",
///   "pppppppp",
///   "........",
///   "........",
///   "........",
///   "........",
///   "PPPPPPPP",
///   "RNBQKBNR",
/// )
/// ```
#let position(..ranks) = {
  let ranks = ranks.pos()
  if ranks.len() != 0 {
    let file-count = ranks.at(0).clusters().len()
    for rank in ranks {
      assert.eq(
        rank.clusters().len(),
        file-count,
        message: "the ranks of a position should all contain the same amount of files"
      )
    }
  }
  (
    type: "board-n-pieces:fen",
    fen: ranks
      .map(rank => {
        let fen-rank = ""
        let empty-count = 0
        for square in rank {
          if square in (" ", ".", "-") {
            empty-count += 1
          } else {
            if empty-count != 0 {
              fen-rank += str(empty-count)
              empty-count = 0
            }
            fen-rank += square
          }
        }
        if empty-count != 0 {
          fen-rank += str(empty-count)
        }
        fen-rank
      })
      .join("/")
      + " w KQkq - 0 1",
  )
}


/// Creates a position using Forsyth–Edwards Notation.
///
/// For example, this creates the starting position.
/// ```typ
/// #let starting-position = fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
/// ```
#let fen(fen-string) = {
  if " " not in fen-string {
    fen-string = fen-string + " w KQkq - 0 1"
  }
  (
    type: "board-n-pieces:fen",
    fen: fen-string,
  )
}


/// Creates an array containing the successive positions of the game with the
/// given turns.
///
/// Turns can be specified as an array of strings using standard algebraic
/// notation. Alternatively, you can also specify a single string containing
/// whitespace-separated turns.
#let game(starting-position: starting-position, turns) = {
  import "internals.typ": replay-game
  if type(turns) == str {
    turns = turns.split()
  }
  replay-game(starting-position, turns)
}


/// Creates an array containing the successive positions of a game described
/// using Portable Game Notation.
#let pgn(pgn-string) = {
  import "internals.typ": game-from-pgn
  game-from-pgn(pgn-string)
}


/// Marks for squares.
#import "marks.typ"


/// Displays a position on a chess board.
///
/// A position can be created using the `position` function.
#let board(
  /// The position to display.
  position,

  /// Squares to mark.
  ///
  /// Can be specified as a list of strings containing the square names, or as a
  /// single string containing multiple whitespace-separated squares. For
  /// example, `("d4", "e4", "d5", "e5")` is equivalent to `"d4 e4 d5 e5"`.
  ///
  /// Alternatively, this can be a dictionary whose keys are squares, and values
  /// are marks to use. For example:
  /// ```
  /// (
  ///   "d4 e4": marks.circle(paint: rgb("#2bcbc6")),
  ///   "d5": auto,
  /// )
  /// ```
  ///
  /// The marks default to `auto`, with which `white-mark` and `black-mark` are
  /// used appropriately.
  marked-squares: (:),
  /// A list of arrows to draw.
  ///
  /// Must be a list of strings containg the start and end squares. For example,
  /// `("e2 e4", "e7 e5")` or, more compactly, `("e2e4", "e7e5")`.
  arrows: (),

  /// Whether to reverse the board and display it from Black's point of view
  /// instead of White's.
  reverse: false,
  /// Whether to display file and rank numbers.
  display-numbers: false,
  /// How to number ranks.
  rank-numbering: numbering.with("1"),
  /// How to number files.
  file-numbering: numbering.with("a"),

  /// The size of each square.
  square-size: 1cm,
  /// How to fill white squares.
  white-square-fill: rgb("#ffce9e"),
  /// How to fill black squares.
  black-square-fill: rgb("#d18b47"),
  /// The mark to use by default for white squares.
  ///
  /// In case explicit marks are specified in `marked-squares`, this is ignored.
  white-mark: marks.circle(),
  /// The mark to use by default for black squares.
  ///
  /// In case explicit marks are specified in `marked-squares`, this is ignored.
  black-mark: marks.circle(),
  /// How to fill arrows.
  arrow-fill: marks.default-color,
  /// The thickness of arrows.
  ///
  /// Can be expressed as a percentage of the square size.
  arrow-thickness: 20%,
  /// How to display each piece.
  ///
  /// See README for more information (including licensing) on the default
  /// images.
  pieces: auto,
  /// The stroke displayed around the board.
  ///
  /// Use the same structure as `rect.stroke`.
  stroke: none,
) = {
  import "internals.typ": (
    resolve-position,
    square-coordinates,
    square-name,
    stroke-sides,
  )

  position = resolve-position(position)

  let height = position.board.len()
  assert(height > 0, message: "board cannot be empty")
  let width = position.board.at(0).len()
  assert(width > 0, message: "board cannot be empty")
  for rank in position.board {
    assert.eq(
      rank.len(),
      width,
      message: "all ranks of a board must have the same width",
    )
  }

  if type(marked-squares) == dictionary {
    // Dictionary with multiple squares as keys to dictionary with single squares
    // as keys.
    marked-squares = marked-squares
      .pairs()
      .map(((ss, m)) => ss.split().map(s => (s, m)))
      .sum(default: ())
      .to-dict()
  }
  if type(marked-squares) == str {
    marked-squares = marked-squares.split()
  }
  if type(marked-squares) == array {
    marked-squares = marked-squares.map(s => (s, auto)).to-dict()
  }
  assert.eq(
    type(marked-squares),
    dictionary,
    message: "`marked-squares` should be a string, array, or dictionary",
  )

  if type(arrows) == str {
    arrows = (arrows, )
  }
  arrows = arrows.map(arrow => {
    if arrow.len() == 4 {
      (
        square-coordinates(arrow.slice(0, 2)),
        square-coordinates(arrow.slice(2, 4)),
      )
    } else {
      let (start, end) = arrow.split()
      (
        square-coordinates(start),
        square-coordinates(end),
      )
    }
  })

  arrow-thickness = arrow-thickness + 0% + 0pt
  arrow-thickness = arrow-thickness.ratio * square-size + arrow-thickness.length

  // Doing this lazily to save time when loading the package.
  if pieces == auto {
    pieces = (
      P: image("assets/pw.svg", width: 100%),
      N: image("assets/nw.svg", width: 100%),
      B: image("assets/bw.svg", width: 100%),
      R: image("assets/rw.svg", width: 100%),
      Q: image("assets/qw.svg", width: 100%),
      K: image("assets/kw.svg", width: 100%),
      p: image("assets/pb.svg", width: 100%),
      n: image("assets/nb.svg", width: 100%),
      b: image("assets/bb.svg", width: 100%),
      r: image("assets/rb.svg", width: 100%),
      q: image("assets/qb.svg", width: 100%),
      k: image("assets/kb.svg", width: 100%),
    )
  }

  let stroke = stroke-sides(stroke)

  let squares = position.board
    .enumerate()
    .map(((j, rank)) => {
      rank.enumerate().map(((i, square)) => {
        let s = square-name((i, j))
        if s in marked-squares {
          let mark = marked-squares.at(s)
          if mark == auto {
            if calc.odd(i + j) {
              mark = white-mark
            } else {
              mark = black-mark
            }
          }
          show: place
          set align(center + horizon)
          block(width: square-size, height: square-size, mark)
        }
        if square != none {
          pieces.at(square)
        }
      })
    })
    .rev()

  let grid-elements = squares.flatten()

  for ((start-file, start-rank), (end-file, end-rank)) in arrows {
    if reverse {
      start-file = width - start-file - 1
      start-rank = height - start-rank - 1
      end-file = width - end-file - 1
      end-rank = height - end-rank - 1
    }

    let angle = calc.atan2(end-file - start-file, start-rank - end-rank)
    let head-thickness = 2 * arrow-thickness
    let head-length = 1.5 * arrow-thickness
    let tip = square-size / 6

    let arrow = {
      // Arrows are all placed in the bottom right square.
      show: place.with(center + horizon)
      show: place

      curve(
        fill: arrow-fill,
        // Base of the arrow.
        curve.move((
          (start-file - width + 1) * square-size
            + (calc.sin(angle) - calc.cos(angle)) * arrow-thickness / 2,
          -start-rank * square-size
            + (-calc.cos(angle) - calc.sin(angle)) * arrow-thickness / 2,
        )),
        curve.line((
          (start-file - width + 1) * square-size
            + (-calc.sin(angle) - calc.cos(angle)) * arrow-thickness / 2,
          -start-rank * square-size
            + (calc.cos(angle) - calc.sin(angle)) * arrow-thickness / 2,
        )),
        // Right before the arrow head.
        curve.line((
          (end-file - width + 1) * square-size
            - calc.sin(angle) * arrow-thickness / 2
            - calc.cos(angle) * (head-length + tip),
          -end-rank * square-size
            + calc.cos(angle) * arrow-thickness / 2
            - calc.sin(angle) * (head-length + tip),
        )),
        // Arrow head.
        curve.line((
          (end-file - width + 1) * square-size
            - calc.sin(angle) * head-thickness / 2
            - calc.cos(angle) * (head-length + tip),
          -end-rank * square-size
            + calc.cos(angle) * head-thickness / 2
            - calc.sin(angle) * (head-length + tip),
        )),
        curve.line((
          (end-file - width + 1) * square-size
            - calc.cos(angle) * tip,
          -end-rank * square-size
            - calc.sin(angle) * tip,
        )),
        curve.line((
          (end-file - width + 1) * square-size
            + calc.sin(angle) * head-thickness / 2
            - calc.cos(angle) * (head-length + tip),
          -end-rank * square-size
            - calc.cos(angle) * head-thickness / 2
            - calc.sin(angle) * (head-length + tip),
        )),
        // Right after the arrow head.
        curve.line((
          (end-file - width + 1) * square-size
            + calc.sin(angle) * arrow-thickness / 2
            - calc.cos(angle) * (head-length + tip),
          -end-rank * square-size
            - calc.cos(angle) * arrow-thickness / 2
            - calc.sin(angle) * (head-length + tip),
        )),
        curve.close(),
      )
    }

    if reverse {
      grid-elements.first() += arrow
    } else {
      grid-elements.last() += arrow
    }
  }

  if display-numbers {
    let number-cell = grid.cell.with(
      inset: 0.3em,
    )

    let column-numbers = (
      none,
      ..range(1, width + 1)
        .map(file-numbering)
        .map(number-cell),
      none,
    )
    grid-elements = (
      ..column-numbers,
      ..grid-elements
        .chunks(width)
        .enumerate()
        .map(((i, rank)) => {
          let n = rank-numbering(height - i)
          (
            number-cell(n),
            ..rank,
            number-cell(n),
          )
        })
        .flatten(),
      ..column-numbers,
    )
  }

  if reverse {
    grid-elements = grid-elements.rev()
  }

  {
    let index-inset = if display-numbers { 1 } else { 0 }

    let first-rank-index = index-inset
    let last-rank-index = first-rank-index + height
    let first-file-index = index-inset
    let last-file-index = first-file-index + width

    // Left line.
    grid-elements.push(grid.vline(
      x: first-file-index,
      stroke: stroke.left,
      start: first-rank-index,
      end: last-rank-index,
    ))

    // Top stroke.
    grid-elements.push(grid.hline(
      y: first-rank-index,
      stroke: stroke.top,
      start: first-file-index,
      end: last-file-index,
    ))

    // Right line.
    grid-elements.push(grid.vline(
      x: last-file-index,
      stroke: stroke.right,
      start: first-rank-index,
      end: last-rank-index,
    ))

    // Bottom line.
    grid-elements.push(grid.hline(
      y: last-rank-index,
      stroke: stroke.bottom,
      start: first-file-index,
      end: last-file-index,
    ))
  }

  show: block.with(breakable: false)
  set text(dir: ltr)
  set grid.cell(
    inset: 0pt,
    align: center + horizon,
  )
  grid(
    fill: (x, y) => {
      if display-numbers {
        x -= 1
        y -= 1
        if x < 0 or x >= width or y < 0 or y >= height {
          return none
        }
      }
      if calc.even(x + y) {
        white-square-fill
      } else {
        black-square-fill
      }
    },

    columns: if display-numbers {
      (auto, ) + (square-size, ) * width + (auto, )
    } else {
      (square-size, ) * width
    },

    rows: if display-numbers {
      (auto, ) + (square-size, ) * height + (auto, )
    } else {
      (square-size, ) * height
    },

    ..grid-elements,
  )
}
