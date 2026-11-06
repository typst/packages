#let functions = plugin("plugin.wasm")

#let invert-position(position) = {
  (
    type: <board-n-pieces:fen>,
    fen: str(functions.invert_position(bytes(position.fen))),
  )
}

#let deserialize-game(game) = {
  let (positions, moves) = array(game).split(0xff)
  (
    positions: positions.split(0).map(position => (
      type: <board-n-pieces:fen>,
      fen: str(bytes(position))
    )),
    moves: moves.split(0).map(move => str(bytes(move)).split()),
  )
}

#let replay-game(starting-position, turns) = {
  let game = functions.replay_game(
    bytes(starting-position.fen),
    turns.map(bytes).join(bytes((0, )))
  )
  deserialize-game(game)
}

#let game-from-pgn(pgn) = {
  let game = functions.game_from_pgn(
    bytes(pgn),
  )
  deserialize-game(game)
}

/// Converts a `board-n-pieces:fen` to a `board-n-pieces:position`.
/// For positions, this is the identity function.
#let resolve-position(position) = {
  let message = "expected a position (hint: you can construct a position with the `position` function)"

  assert.eq(type(position), dictionary, message: message)

  if position.type == <board-n-pieces:position> {
    return position
  }

  if position.type == <board-n-pieces:fen> {
    // A `fen` object contains a `fen` entry, which is a full fen string.
    let parts = position.fen.split(" ")
    return (
      type: <board-n-pieces:position>,
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
#let file-index(f) = f.to-unicode() - "a".to-unicode()

/// Returns the index of a rank.
#let rank-index(r) = int(r) - 1

/// Returns the coordinates of a square given a square name.
#let square-coordinates(s) = {
  let (f, r) = s.clusters()
  (file-index(f), rank-index(r))
}

/// Returns the name of a square given its coordinates.
#let square-name(s) = {
  let (f, r) = s
  str.from-unicode(f + "a".to-unicode()) + str(r + 1)
}

#let stroke-sides(arg) = {
  let sides = rect(stroke: arg).stroke

  if type(sides) != dictionary {
    sides = (
      left: sides,
      top: sides,
      right: sides,
      bottom: sides,
    )
  }

  (
    left: none,
    top: none,
    right: none,
    bottom: none,
    ..sides,
  )
}

#let draw-straight-arrow(
  (start-file, start-rank),
  (end-file, end-rank),
  square-size,
  arrow-thickness,
  arrow-base-offset,
  head-thickness,
  head-length,
  tip,
  fill,
) = {
  let angle = calc.atan2(end-file - start-file, end-rank - start-rank)
  let tail-x = start-file * square-size + calc.cos(angle) * arrow-base-offset
  let tail-y = start-rank * square-size + calc.sin(angle) * arrow-base-offset

  curve(
    fill: fill,
    // Base of the arrow.
    curve.move((
      tail-x + (calc.sin(angle) - calc.cos(angle)) * arrow-thickness / 2,
      tail-y + (-calc.cos(angle) - calc.sin(angle)) * arrow-thickness / 2,
    )),
    curve.line((
      tail-x + (-calc.sin(angle) - calc.cos(angle)) * arrow-thickness / 2,
      tail-y + (calc.cos(angle) - calc.sin(angle)) * arrow-thickness / 2,
    )),
    // Right before the arrow head.
    curve.line((
      end-file * square-size
        - calc.sin(angle) * arrow-thickness / 2
        - calc.cos(angle) * (head-length + tip),
      end-rank * square-size
        + calc.cos(angle) * arrow-thickness / 2
        - calc.sin(angle) * (head-length + tip),
    )),
    // Arrow head.
    curve.line((
      end-file * square-size
        - calc.sin(angle) * head-thickness / 2
        - calc.cos(angle) * (head-length + tip),
      end-rank * square-size
        + calc.cos(angle) * head-thickness / 2
        - calc.sin(angle) * (head-length + tip),
    )),
    curve.line((
      end-file * square-size
        - calc.cos(angle) * tip,
      end-rank * square-size
        - calc.sin(angle) * tip,
    )),
    curve.line((
      end-file * square-size
        + calc.sin(angle) * head-thickness / 2
        - calc.cos(angle) * (head-length + tip),
      end-rank * square-size
        - calc.cos(angle) * head-thickness / 2
        - calc.sin(angle) * (head-length + tip),
    )),
    // Right after the arrow head.
    curve.line((
      end-file * square-size
        + calc.sin(angle) * arrow-thickness / 2
        - calc.cos(angle) * (head-length + tip),
      end-rank * square-size
        - calc.cos(angle) * arrow-thickness / 2
        - calc.sin(angle) * (head-length + tip),
    )),
    curve.close(),
  )
}

#let draw-corner-arrow(
  (start-file, start-rank),
  (end-file, end-rank),
  square-size,
  arrow-thickness,
  arrow-base-offset,
  head-thickness,
  head-length,
  tip,
  fill,
  horizontal-first,
) = {
  if not horizontal-first {
    (start-file, start-rank) = (start-rank, start-file)
    (end-file, end-rank) = (end-rank, end-file)
  }
  let c = if horizontal-first { (x, y) => (x, y) } else { (y, x) => (x, y) }

  let main-direction = if end-file > start-file { 1 } else { -1 }
  let secondary-direction = if end-rank > start-rank { 1 } else { -1 }
  let tail-x = start-file * square-size + main-direction * arrow-base-offset
  let tail-y = start-rank * square-size
  let tip-x = end-file * square-size
  let tip-y = end-rank * square-size - secondary-direction * tip

  curve(
    fill: fill,
    // Base of the arrow.
    curve.move(c(
      tail-x - main-direction * arrow-thickness / 2,
      tail-y + secondary-direction * arrow-thickness / 2,
    )),
    curve.line(c(
      tail-x - main-direction * arrow-thickness / 2,
      tail-y - secondary-direction * arrow-thickness / 2,
    )),
    // Outside the corner.
    curve.line(c(
      tip-x + main-direction * arrow-thickness / 2,
      tail-y - secondary-direction * arrow-thickness / 2,
    )),
    // Right before the arrow head.
    curve.line(c(
      tip-x + main-direction * arrow-thickness / 2,
      tip-y - secondary-direction * head-length,
    )),
    // Arrow head.
    curve.line(c(
      tip-x + main-direction * head-thickness / 2,
      tip-y - secondary-direction * head-length,
    )),
    curve.line(c(
      tip-x,
      tip-y,
    )),
    curve.line(c(
      tip-x - main-direction * head-thickness / 2,
      tip-y - secondary-direction * head-length,
    )),
    // Right after the arrow head.
    curve.line(c(
      tip-x - main-direction * arrow-thickness / 2,
      tip-y - secondary-direction * head-length,
    )),
    // Inside the corner.
    curve.line(c(
      tip-x - main-direction * arrow-thickness / 2,
      tail-y + secondary-direction * arrow-thickness / 2,
    )),
    curve.close(),
  )
}
