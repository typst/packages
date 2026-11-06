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


/// Displays a position on a chess board.
///
/// A position can be created using the `position` function.
#let board(
  /// The position to display.
  position,

  /// A list of squares to highlight.
  ///
  /// Can be specified as a list of strings containing the square names, or as a
  /// single string containing multiple whitespace-separated squares. For
  /// example, `("d4", "e4", "d5", "e5")` is equivalent to `"d4 e4 d5 e5"`.
  highlighted-squares: (),
  /// A list of arrows to draw.
  ///
  /// Must be a list of strings containg the start and end squares. For example,
  /// `("e2 e4", "e7 e5")` or, more compactly, `("e2e4", "e7e5")`.
  arrows: (),

  /// Whether to reverse the board.
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
  white-square-fill: rgb("FFCE9E"),
  /// How to fill black squares.
  black-square-fill: rgb("D18B47"),
  /// How to fill highlighted white squares.
  highlighted-white-square-fill: rgb("EF765F"),
  /// How to fill highlighted black squares.
  highlighted-black-square-fill: rgb("E5694E"),
  /// How to stroke arrows.
  arrow-stroke: stroke(
    paint: rgb("75C534BC"),
    thickness: 0.3cm,
  ),
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
  import "internals.typ": resolve-position, stroke-sides, square-coordinates

  position = resolve-position(position)

  if type(highlighted-squares) == str {
    highlighted-squares = highlighted-squares.split()
  }

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

  let height = position.board.len()
  assert(height > 0, message: "board cannot be empty")
  let width = position.board.at(0).len()
  assert(width > 0, message: "board cannot be empty")

  let squares = (
    position.board
      .map(rank => {
        rank.map(square => {
          if square != none {
            pieces.at(square)
          }
        })
      })
      .rev()
  )

  let grid-elements = squares.flatten()

  for ((start-file, start-rank), (end-file, end-rank)) in arrows {
    let hypot(x, y) = {
      if type(x) == length and type(y) == length {
        return hypot(x.pt(), y.pt()) * 1pt
      }
      calc.sqrt(x * x + y * y)
    }

    let length = hypot(end-file - start-file, end-rank - start-rank) * square-size
    let angle = calc.atan2(end-file - start-file, start-rank - end-rank)
    let triangle-base = 2 * arrow-stroke.thickness
    let triangle-height = 1.5 * arrow-stroke.thickness
    let triangle-start = triangle-height + square-size / 6

    grid-elements.last() += {
      place(
        center + horizon,
        place(line(
          start: (
            (start-file - width + 1) * square-size
              - calc.cos(angle) * arrow-stroke.thickness / 2,
            -start-rank * square-size
              - calc.sin(angle) * arrow-stroke.thickness / 2,
          ),
          end: (
            (end-file - width + 1) * square-size
              - calc.cos(angle) * triangle-start,
            -end-rank * square-size
              - calc.sin(angle) * triangle-start,
          ),
          stroke: arrow-stroke,
        ))
      )

      let triangle = polygon(
        fill: arrow-stroke.paint,
        (0pt, -triangle-base / 2),
        (0pt, triangle-base / 2),
        (triangle-height, 0pt),
      )
      place(
        center + horizon,
        move(
          dx:
            (end-file - width + 1) * square-size
              - calc.cos(angle) * triangle-start,
          dy:
            -end-rank * square-size
              - calc.sin(angle) * triangle-start,
          rotate(
            angle,
            place(triangle),
          ),
        ),
      )
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

  highlighted-squares = highlighted-squares.map(s => {
    let (x, y) = square-coordinates(s)
    if reverse {
      (width - x - 1, y)
    } else {
      (x, height - y - 1)
    }
  })

  show: block.with(breakable: false)
  set text(dir: ltr)
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
        if (x, y) in highlighted-squares {
          highlighted-white-square-fill
        } else {
          white-square-fill
        }
      } else {
        if (x, y) in highlighted-squares {
          highlighted-black-square-fill
        } else {
          black-square-fill
        }
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

    align: center + horizon,

    ..grid-elements,
  )
}
