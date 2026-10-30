// Shared algorithm scanner. Each puzzle supplies a regex for one move token
// and a function turning its captures into a move; this file handles
// whitespace, groups `(...)N` and `(...)'`, commutators `[A, B]`, conjugates
// `[A: B]` / `A: B`, and errors.
//
// Every move is a dictionary with at least:
//   base    the move's name as written, e.g. "R", "3Rw", "M"
//   amount  signed number of basic turns (1 = one clockwise turn)
//   order   how many basic turns make a full circle (4, 3 or 5)
//   axis    unit vector the layer turns about
//   step    angle of one basic turn about `axis` (signed, right-hand rule)
//   region  (lo, hi): a sticker moves when lo <= axis·p <= hi (no sticker
//           centroid ever lies on a cutting plane, so both ends are inclusive)
//   style   "" or "pm" (megaminx ++/-- moves)
//   puzzle  the puzzle name, so `to-string` can format it

#let suffix-amount(suffix) = {
  if suffix == none or suffix == "" { 1 } else if suffix == "2" { 2 } else if suffix in ("2'", "'2", "2’", "’2") {
    -2
  } else if suffix in ("'", "’") { -1 } else { panic("cubst: unknown suffix " + repr(suffix)) }
}

#let inverse-of(moves) = moves.rev().map(x => (..x, amount: -x.amount))

// Split an algorithm into tokens: moves, and the punctuation `( ) [ ] , :`.
// A closing bracket carries its repeat count and inversion mark (`)3`, `]'`).
#let tokenize(alg, token, make) = {
  let tokens = ()
  let rest = alg
  while true {
    rest = rest.trim(regex("\s+"), at: start)
    if rest == "" { break }
    let c = rest.slice(0, 1)
    if c in ("(", "[", ",", ":") {
      tokens.push((kind: c))
      rest = rest.slice(1)
    } else if c in (")", "]") {
      let m = rest.slice(1).match(regex("^(\d*)(['’]?)"))
      tokens.push((
        kind: c,
        times: if m.captures.at(0) == "" { 1 } else { int(m.captures.at(0)) },
        inverted: m.captures.at(1) != "",
      ))
      rest = rest.slice(1 + m.end)
    } else {
      let m = rest.match(token)
      assert(m != none, message: "cubst: cannot read " + repr(rest) + " in algorithm " + repr(alg))
      tokens.push((kind: "move", move: make(m.captures)))
      rest = rest.slice(m.end)
    }
  }
  tokens
}

// Parse tokens from `i` until a token whose kind is in `stop` (or the end).
// Returns `(moves, index of the stopping token)`. Handles
//   ( A )N  ( A )'     repeat, invert
//   [ A, B ]           commutator  A B A' B'
//   [ A: B ]  A: B     conjugate   A B A'   (the colon binds to the end of
//                      the enclosing group, so `C: [A, B]` is `C [A, B] C'`)
#let parse-tokens(tokens, i, stop, alg) = {
  let out = ()
  let i = i
  while i < tokens.len() {
    let t = tokens.at(i)
    if t.kind in stop { break }
    if t.kind == "move" {
      out.push(t.move)
      i += 1
    } else if t.kind == "(" or t.kind == "[" {
      let closer = if t.kind == "(" { ")" } else { "]" }
      let inner-stop = if closer == "]" { ("]", ",") } else { (")",) }
      let (a, j) = parse-tokens(tokens, i + 1, inner-stop, alg)
      let seq = a
      if closer == "]" and j < tokens.len() and tokens.at(j).kind == "," {
        let (b, k) = parse-tokens(tokens, j + 1, ("]",), alg)
        seq = a + b + inverse-of(a) + inverse-of(b)
        j = k
      }
      assert(j < tokens.len() and tokens.at(j).kind == closer, message: "cubst: unmatched '" + t.kind + "' in algorithm " + repr(alg))
      let close = tokens.at(j)
      if close.inverted { seq = inverse-of(seq) }
      for _ in range(close.times) { out += seq }
      i = j + 1
    } else if t.kind == ":" {
      let (b, j) = parse-tokens(tokens, i + 1, stop, alg)
      out = out + b + inverse-of(out)
      i = j
    } else if t.kind == "," {
      panic("cubst: ',' outside [ ] in algorithm " + repr(alg))
    } else {
      panic("cubst: unmatched '" + t.kind + "' in algorithm " + repr(alg))
    }
  }
  (out, i)
}

#let scan(alg, token, make) = {
  assert(type(alg) == str, message: "cubst: algorithm must be a string, got " + repr(alg))
  let tokens = tokenize(alg, token, make)
  let (moves, i) = parse-tokens(tokens, 0, (), alg)
  if i < tokens.len() {
    panic("cubst: unexpected '" + tokens.at(i).kind + "' in algorithm " + repr(alg))
  }
  moves
}

/// Suffix for `amount` basic turns on a puzzle of the given order.
#let format-suffix(amount, order) = {
  let k = calc.rem-euclid(amount, order)
  if k == 1 { "" } else if k == order - 1 { "'" } else if k == 2 { "2" } else if k == order - 2 { "2'" } else {
    str(k)
  }
}
