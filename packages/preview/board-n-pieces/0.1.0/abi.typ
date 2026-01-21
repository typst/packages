#let int-to-bytes(n, size: 4) = {
  assert(n >= 0)
  let b = ()
  for i in range(size, 0, step: -1) {
    b.push(n.bit-rshift(8 * (i - 1)).bit-and(0xff))
  }
  bytes(b)
}

#let int-from-bytes(b, size: 4) = {
  let n = 0
  for i in range(size) {
    n = n.bit-or(b.at(i).bit-lshift(8 * (size - i - 1)))
  }
  (b.slice(size), n)
}


#let char-from-bytes(b) = {
  (b.slice(1), str(b.slice(0, 1)))
}


#let option-to-bytes(some-to-bytes, option) = {
  if option == none {
    bytes((0, ))
  } else {
    bytes((1, ))
    some-to-bytes(option)
  }
}

#let option-from-bytes(some-from-bytes, b) = {
  if b.at(0) == 0 {
    (b.slice(1), none)
  } else {
    some-from-bytes(b.slice(1))
  }
}


#let file-to-bytes(file) = {
  bytes(file)
}

#let file-from-bytes(b) = {
  char-from-bytes(b)
}


#let rank-to-bytes(rank) = {
  bytes(rank)
}

#let rank-from-bytes(b) = {
  char-from-bytes(b)
}


#let square-to-bytes(square) = {
  file-to-bytes(square.at(0))
  rank-to-bytes(square.at(1))
}

#let square-from-bytes(b) = {
  let (b, file) = file-from-bytes(b)
  let (b, rank) = rank-from-bytes(b)
  (b, file + rank)
}


#let color-to-bytes(color) = {
  bytes(color)
}

#let color-from-bytes(b) = {
  char-from-bytes(b)
}


#let piece-kind-to-bytes(piece-kind) = {
  bytes(piece-kind)
}

#let piece-kind-from-bytes(b) = {
  char-from-bytes(b)
}


#let piece-to-bytes(piece) = {
  bytes(piece)
}

#let piece-from-bytes(b) = {
  char-from-bytes(b)
}


#let square-content-to-bytes(square-content) = {
  if square-content == none {
    bytes((0, ))
  } else {
    bytes(square-content)
  }
}

#let square-content-from-bytes(b) = {
  if b.at(0) == 0 {
    (b.slice(1), none)
  } else {
    char-from-bytes(b)
  }
}


#let board-to-bytes(board) = {
  let width = board.len()
  let height = board.at(0).len()
  int-to-bytes(width)
  int-to-bytes(height)
  for rank in board {
    for square in rank {
      square-content-to-bytes(square)
    }
  }
}

#let board-from-bytes(b) = {
  let (b, width) = int-from-bytes(b)
  let (b, height) = int-from-bytes(b)
  let board = ()
  for i in range(height) {
    let rank = ()
    for j in range(width) {
      let square-bytes = b.slice(i * width + j, count: 1)
      let (_, square) = square-content-from-bytes(square-bytes)
      rank.push(square)
    }
    board.push(rank)
  }
  (b.slice(width * height), board)
}


#let castling-availability-white-king-mask = 0b0001
#let castling-availability-white-queen-mask = 0b0010
#let castling-availability-black-king-mask = 0b0100
#let castling-availability-black-queen-mask = 0b1000

#let castling-availabilities-to-bytes(castling-availabilities) = {
  let (
    white-king-side,
    white-queen-side,
    black-king-side,
    black-queen-side,
  ) = castling-availabilities
  let b = 0b0000
  if white-king-side { b = b.bit-or(castling-availability-white-king-mask) }
  if white-queen-side { b = b.bit-or(castling-availability-white-queen-mask) }
  if black-king-side { b = b.bit-or(castling-availability-black-king-mask) }
  if black-queen-side { b = b.bit-or(castling-availability-black-queen-mask) }
  bytes((b, ))
}

#let castling-availabilities-from-bytes(b) = {
  let byte = b.at(0)
  (
    b.slice(1),
    (
      white-king-side: byte.bit-and(castling-availability-white-king-mask) != 0,
      white-queen-side: byte.bit-and(castling-availability-white-queen-mask) != 0,
      black-king-side: byte.bit-and(castling-availability-black-king-mask) != 0,
      black-queen-side: byte.bit-and(castling-availability-black-queen-mask) != 0,
    ),
  )
}


#let position-to-bytes(position) = {
  let (
    type,
    board,
    active,
    castling-availabilities,
    en-passant-target-square,
    halfmove,
    fullmove,
  ) = position

  assert(type == "boardnpieces:position")

  board-to-bytes(board)
  color-to-bytes(active)
  castling-availabilities-to-bytes(castling-availabilities)
  option-to-bytes(square-to-bytes, en-passant-target-square)
  int-to-bytes(halfmove)
  int-to-bytes(fullmove)
}

#let position-from-bytes(b) = {
  let (b, board) = board-from-bytes(b)
  let (b, active) = color-from-bytes(b)
  let (b, castling-availabilities) = castling-availabilities-from-bytes(b)
  let (b, en-passant-target-square) = option-from-bytes(square-to-bytes, b)
  let (b, halfmove) = int-from-bytes(b)
  let (b, fullmove) = int-from-bytes(b)
  (
    b,
    (
      type: "boardnpieces:position",
      board: board,
      active: active,
      castling-availabilities: castling-availabilities,
      en-passant-target-square: en-passant-target-square,
      halfmove: halfmove,
      fullmove: fullmove,
    ),
  )
}


#let function(f, ..arguments-to-bytes, result-from-bytes) = (..args) => {
  result-from-bytes(f(
    ..args.pos()
      .zip(arguments-to-bytes.pos())
      .map(((argument, encoder)) => encoder(argument))
  )).at(1)
}
