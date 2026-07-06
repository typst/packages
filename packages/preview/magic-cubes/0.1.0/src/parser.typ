#import "moves.typ": rotate-cube, rotate-layer

/// Parses an algorithm and translates it to an alg-t dictionary. -> alg-t
#let _parse(
  /// The algorithm to parse. -> str
  alg,

  /// The size of the cube. -> int
  size,
) = {
  let a = alg.replace(regex("[()]"), "")
  a = a.split(" ")
  let list_alg = ()

  for move in a {
    let n
    let action
    let depth = 1

    if move.len() == 0 {
      continue
    } else {
      // Search the end of the string for the orientation of the turn
      if move.ends-with("'") {
        n = 3
        move = move.slice(0, -1)
      } else if move.ends-with("2") {
        n = 2
        move = move.slice(0, -1)
      } else {
        n = 1
      }

      // Central moves
      if move in ("M", "E", "S") {
        assert(
          calc.rem(size, 2) == 1,
          message: "Error: central moves can only be applied to odd size cubes",
        )
        let central = (
          "M": "l",
          "E": "d",
          "S": "f",
        )
        action = central.at(move)
        depth = calc.ceil(size / 2)

        // Cube rotations
      } else if move in ("x", "y", "z") {
        action = move

        // One layer rotation
      } else if move.ends-with(regex("[FRUBLD]")) {
        action = lower(move.at(-1))
        move = move.slice(0, -1)
        if move == "" {
          depth = 1
        } else {
          assert(
            move.match(regex("^\d+$")) != none,
            message: "Invalid syntax: before the move letter can only be an integer number.",
          )
          depth = int(move)
        }

        // Wide moves
      } else {
        if move.ends-with(regex("[frubld]")) {
          action = move.at(-1)
          move = move.slice(0, -1)
        } else if move.ends-with(regex("[FRUBLD]w")) {
          action = lower(move.at(-2))
          move = move.slice(0, -2)
        } else {
          assert(false, message: "Invalid syntax: " + move)
        }

        let lower
        let upper
        if move == "" {
          lower = 1
          upper = calc.ceil(size / 2)
        } else if move.match(regex("^\d+$")) != none {
          lower = 1
          upper = int(move)
        } else if move.match(regex("^\d+-\d+$")) != none {
          let capture = move.match(regex("^(\d+)-(\d+)$"))
          lower = int(capture.captures.at(0))
          upper = int(capture.captures.at(1))
        } else {
          assert(
            false,
            message: "Invalid syntax: wide moves must be preceded by an integer, two integers separated by a dash or none. Your input: "
              + move,
          )
        }
        for i in range(lower, upper) {
          list_alg += ((action, i, n),)
        }
        depth = upper
      }
      list_alg += ((action, depth, n),)
    }
  }
  return list_alg
}

/// Inverts an algorithm. -> alg-t
#let _invert(
  /// The algorithm to invert. -> alg-t
  alg,
) = {
  let inverted = ()
  for move in alg {
    inverted.insert(0, (move.at(0), move.at(1), 4 - move.at(2)))
  }
  return inverted
}

/// Returns a new @type:cube with an algorithm applied.
/// -> cube
#let apply(
  /// The cube to which the algorithm is applied.
  /// -> cube
  cube,

  /// A string containing the algorithm to apply, following the notation specified in @sec:notation.
  /// -> str
  alg,

  /// If true, the inverse of the algorithm is applied.
  /// This is useful when documenting solution algorithms, which are intended to solve the resulting cube.
  ///-> bool
  inverse: false,
) = {
  let list_alg = _parse(alg, cube.size)
  if inverse {
    list_alg = _invert(list_alg)
  }

  for move in list_alg {
    if move.at(0) in ("f", "r", "u", "b", "l", "d") {
      cube = rotate-layer(
        cube,
        move.at(0),
        depth: move.at(1),
        turns: move.at(2),
      )
    } else if move.at(0) in ("x", "y", "z") {
      for i in range(move.at(2)) {
        cube = rotate-cube(cube, move.at(0))
      }
    } else {
      assert(false, message: "Invalid move: " + move)
    }
  }

  return cube
}
