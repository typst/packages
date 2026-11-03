// ===========================================================================
// Chess960 / Fischer Random starting-position numbering (Scharnagl scheme).
//
// Maps a position number 0..959 to its standard back-rank arrangement and back,
// using the direct algorithm (no lookup tables): the number's digits pick the
// two bishops (on opposite colors), the queen, the knight pair, and the last
// three squares are always rook-king-rook (which is what makes every 960 start
// legally castleable). Anchors: 518 = RNBQKBNR (standard), 0 = BBQNNRKR,
// 959 = RKRNNQBB.
// ===========================================================================

#import "pieces.typ": kind-letters

// The 10 ways to place 2 knights on 5 squares, in Scharnagl order (each pair is
// (lo, hi) 0-based indices into the remaining empty squares).
#let _knight-pairs = ((0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4))

/// The white back rank (files a..h) for Chess960 position `n`, as an array of 8
/// kind strings (e.g. `("rook","knight","bishop",…)`). Scharnagl's algorithm.
///
/// - n (int): the position number, 0–959.
/// -> array
#let chess960-back-rank(n) = {
  assert(type(n) == int and n >= 0 and n <= 959,
    message: "Chess960 position number must be an int 0..959, got " + repr(n))
  let rank = (none, none, none, none, none, none, none, none)
  // NB: Typst closures capture by value, so `empties` must take the CURRENT rank.
  let empties(r) = range(8).filter(f => r.at(f) == none)

  let m = n
  // light-squared bishop -> files b,d,f,h ; dark-squared bishop -> a,c,e,g
  rank.at((1, 3, 5, 7).at(calc.rem(m, 4))) = "bishop"; m = calc.quo(m, 4)
  rank.at((0, 2, 4, 6).at(calc.rem(m, 4))) = "bishop"; m = calc.quo(m, 4)
  // queen on the q-th of the 6 remaining squares
  let e6 = empties(rank)
  rank.at(e6.at(calc.rem(m, 6))) = "queen"; m = calc.quo(m, 6)
  // two knights on the pair of the 5 remaining squares
  let e5 = empties(rank)
  let (k1, k2) = _knight-pairs.at(m)
  rank.at(e5.at(k1)) = "knight"
  rank.at(e5.at(k2)) = "knight"
  // last three squares are always rook, king, rook (left to right)
  let e3 = empties(rank)
  rank.at(e3.at(0)) = "rook"
  rank.at(e3.at(1)) = "king"
  rank.at(e3.at(2)) = "rook"
  rank
}

/// The full starting FEN for Chess960 position `n` — both back ranks (Black on
/// top), pawns, White to move, `KQkq`, no e.p., clocks `0 1`.
///
/// - n (int): the position number, 0–959.
/// -> str
#let chess960-start-fen(n) = {
  let letters = chess960-back-rank(n).map(k => kind-letters.at(k))   // uppercase
  let white = letters.join()
  let black = letters.map(lower).join()
  black + "/pppppppp/8/8/8/8/PPPPPPPP/" + white + " w KQkq - 0 1"
}

/// The Chess960 position number (0–959) of a white back rank — the inverse of
/// `chess960-back-rank`. Errors if the rank is not a legal 960 arrangement.
///
/// - rank (array): 8 kind strings (files a..h), as from `chess960-back-rank`.
/// -> int
#let chess960-number(rank) = {
  assert(type(rank) == array and rank.len() == 8, message: "chess960-number: expected 8 files")
  let bl = (1, 3, 5, 7).position(f => rank.at(f) == "bishop")
  let bd = (0, 2, 4, 6).position(f => rank.at(f) == "bishop")
  assert(bl != none and bd != none, message: "chess960-number: need one bishop on each color")
  // queen index among the 6 non-bishop squares (in file order)
  let non-bishop = range(8).filter(f => rank.at(f) != "bishop")
  let q = non-bishop.position(f => rank.at(f) == "queen")
  assert(q != none, message: "chess960-number: no queen")
  // knight indices among the 5 non-bishop, non-queen squares
  let rest5 = non-bishop.filter(f => rank.at(f) != "queen")
  let ks = range(rest5.len()).filter(i => rank.at(rest5.at(i)) == "knight")
  assert(ks.len() == 2, message: "chess960-number: need exactly two knights")
  let kn = _knight-pairs.position(p => p == (ks.at(0), ks.at(1)))
  assert(kn != none, message: "chess960-number: illegal knight placement")
  kn * 96 + q * 16 + bd * 4 + bl
}
