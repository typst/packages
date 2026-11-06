#let functions = plugin("plugin.wasm")

#let replay-game(starting-position, turns) = {
  let game = functions.replay_game(
    bytes(starting-position.fen),
    turns.map(bytes).join(bytes((0, )))
  )
  array(game).split(0).map(position => (
    type: "board-n-pieces:fen",
    fen: str(bytes(position))
  ))
}

#let game-from-pgn(pgn) = {
  let game = functions.game_from_pgn(
    bytes(pgn),
  )
  array(game).split(0).map(position => (
    type: "board-n-pieces:fen",
    fen: str(bytes(position))
  ))
}

/// Converts a `board-n-pieces:fen-position` to a `board-n-pieces:position`.
/// For positions, this is the identity function.
#let resolve-position(position) = {
  let message = "Expected a position. You can construct a position with the `position` function."

  assert.eq(type(position), dictionary, message: message)

  if position.type == "board-n-pieces:position" {
    return position
  }

  if position.type == "board-n-pieces:fen" {
    // A `fen` object contains a `fen` entry, which is a full fen string.
    let parts = position.fen.split(" ")
    return (
      type: "board-n-pieces:position",
      fen: position.fen,
      board: parts.at(0)
        .split("/")
        .rev()
        .map(fen-rank => {
          ()
          for s in fen-rank {
            if "0".to-unicode() <= s.to-unicode() and s.to-unicode() <= "9".to-unicode() {
              (none, ) * int(s)
            } else {
              (s, )
            }
          }
        }),
      active: parts.at(1),
      castling-availabilities: (
        white-king-side: "K" in parts.at(2),
        white-queen-side: "Q" in parts.at(2),
        black-king-side: "k" in parts.at(2),
        black-queen-side: "q" in parts.at(2),
      ),
      en-passant-target-square: if parts.at(3) != "-" { parts.at(3) },
      halfmove: int(parts.at(4)),
      fullmove: int(parts.at(5)),
    )
  }

  panic(message)
}

/// Returns the index of a file.
#let file-index(file) = file.to-unicode() - "a".to-unicode()

/// Returns the index of a rank.
#let rank-index(r) = int(r) - 1

/// Returns the coordinate of a square given a square name.
#let square-coordinates(s) = {
  let (f, r) = s.clusters()
  (file-index(f), rank-index(r))
}
