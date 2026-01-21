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
#let position(..ranks) = (
  type: "board-n-pieces:fen",
  fen: ranks.pos()
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
  let fen-parts = fen-string.split(" ")
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
  /// Can also be a string containing multiple whitespace-separated squares.
  highlighted-squares: (),

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
  /// The background color of white squares.
  white-square-color: rgb("FFCE9E"),
  /// The background color of black squares.
  black-square-color: rgb("D18B47"),
  /// The background color of highlighted white squares.
  highlighted-white-square-color: rgb("EF765F"),
  /// The background color of highlighted black squares.
  highlighted-black-square-color: rgb("E5694E"),
  /// How to display each piece.
  pieces: auto,
) = {
  import "internals.typ": resolve-position, square-coordinates

  position = resolve-position(position)

  if type(highlighted-squares) == str {
    highlighted-squares = highlighted-squares.split()
  }

  // Doing this saves time when loading the package.
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

  let height = position.board.len()
  assert(height > 0, message: "Board cannot be empty.")
  let width = position.board.at(0).len()
  assert(width > 0, message: "Board cannot be empty.")

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
          highlighted-white-square-color
        } else {
          white-square-color
        }
      } else {
        if (x, y) in highlighted-squares {
          highlighted-black-square-color
        } else {
          black-square-color
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
