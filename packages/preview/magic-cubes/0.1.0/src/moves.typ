/// Returns for a given index the destination after a move.
/// -> int
#let _rotate-piece(
  /// the index of the piece to move. -> int
  i,

  /// the size of the cube. -> int
  size,

  /// the number of rotations. -> int
  n: 1,
) = {
  let j = calc.rem(n + 4, 4)
  if j == 0 {
    return i
  } else if j == 1 {
    return size * (size - 1 - calc.rem(i, size)) + calc.floor(i / size)
  } else if j == 2 {
    return size * size - 1 - i
  } else {
    return (size - 1 + size * calc.rem(i, size)) - calc.floor(i / size)
  }
}

/// rotates a given face. -> cube
#let _rotate-face(
  /// the cube. -> cube
  cube,

  /// the face to rotate, as a one-letter string -> srt
  face,
  /// the numer of times to rotate -> int
  n: 1,
) = {
  cube.at(face) = cube
    .at(face)
    .enumerate()
    .map(i => cube.at(face).at(_rotate-piece(i.at(0), cube.size, n: n)))

  return cube
}

/// Returns a new @type:cube with the specified layer rotated.
///
/// It returns the cube after applying the rotation.
/// It is used for applying the 1-layer rotations explained in @sec:1-layer.
/// -> cube
#let rotate-layer(
  /// The cube to apply the rotation.
  /// -> cube
  cube,

  /// The @type:face used to identify the layer to rotate.
  /// -> face
  face,

  /// The depth of the layer to rotate, by default 1, i.e., the outermost face.
  ///
  /// It must be smaller than the cube size.
  /// -> int
  depth: 1,

  /// The number of rotations to apply, by default 1.
  /// -> int
  turns: 1,
) = {
  let size = cube.size
  assert(
    face in ("f", "r", "u", "b", "l", "d"),
    message: "Invalid index. Expected one of (\"f\", \"r\", \"u\", \"b\", \"l\", \"d\")",
  )

  assert(
    0 < depth and depth < size,
    message: "Depth must be an integer between 1 and size - 1",
  )
  depth = depth - 1

  let prepare = (
    f: (r: 1, u: 2, l: 3),
    r: (f: 3, u: 3, b: 1, d: 3),
    u: (:),
    b: (r: 3, l: 1, d: 2),
    l: (f: 1, u: 1, b: 3, d: 1),
    d: (f: 2, r: 2, b: 2, l: 2),
  )

  let moves = (
    f: ("r", "d", "l", "u"),
    r: ("f", "u", "b", "d"),
    u: ("f", "l", "b", "r"),
    b: ("r", "u", "l", "d"),
    l: ("f", "d", "b", "u"),
    d: ("f", "r", "b", "l"),
  )

  for i in prepare.at(face).pairs() {
    cube = _rotate-face(cube, i.first(), n: i.last())
  }

  let copy = cube
  for j in range(size) {
    for i in range(4) {
      copy.at(moves.at(face).at(i)).at(j + size * depth) = cube
        .at(moves.at(face).at(i - turns))
        .at(j + size * depth)
    }
  }

  cube = copy
  for i in prepare.at(face).pairs() {
    cube = _rotate-face(cube, i.first(), n: -i.last())
  }

  if depth == 0 {
    return _rotate-face(cube, face, n: turns)
  } else {
    return cube
  }
}

/// Returns a new @type:cube with the specified rotation applied.
///
/// It returns the cube after applying the rotation.
/// It is used for applying the rotations explained in @sec:cube-rotations.
/// -> cube
#let rotate-cube(
  /// The cube to apply the rotation.
  /// -> cube
  cube,

  /// The axis around which the cube is rotated.
  /// Must be one of `("x", "y", "z")`.
  /// -> str
  axis,
) = {
  let copy = cube
  if axis == "x" {
    copy.f = cube.d
    copy.r = _rotate-face(cube, "r", n: 1).r
    copy.u = cube.f
    copy.b = _rotate-face(cube, "u", n: 2).u
    copy.l = _rotate-face(cube, "l", n: 3).l
    copy.d = _rotate-face(cube, "b", n: 2).b
  } else if axis == "y" {
    copy.f = cube.r
    copy.r = cube.b
    copy.u = _rotate-face(cube, "u", n: 1).u
    copy.b = cube.l
    copy.l = cube.f
    copy.d = _rotate-face(cube, "d", n: 3).d
  } else if axis == "z" {
    copy.f = _rotate-face(cube, "f", n: 1).f
    copy.r = _rotate-face(cube, "u", n: 1).u
    copy.u = _rotate-face(cube, "l", n: 1).l
    copy.b = _rotate-face(cube, "b", n: 3).b
    copy.l = _rotate-face(cube, "d", n: 1).d
    copy.d = _rotate-face(cube, "r", n: 1).r
  } else {
    assert(false, "Argument error: Axis must be one of (\"x\", \"y\", \"z\")")
  }
  return copy
}
