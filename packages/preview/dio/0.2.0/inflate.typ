// Pure-Typst decoding helpers for compressed draw.io diagrams.
//
// draw.io stores compressed pages as:
//   base64( raw-DEFLATE( encodeURIComponent( xml ) ) )
// Typst has no built-in inflate, so it is implemented here (a port of the
// classic "puff" algorithm). All functions are pure: Typst closures cannot
// mutate captured variables, so state is passed explicitly.

#let _b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
#let _b64map = {
  let d = (:)
  for (i, c) in _b64chars.clusters().enumerate() { d.insert(c, i) }
  d
}

/// Decodes a base64 string into an array of byte values.
#let base64-decode(s) = {
  let out = ()
  let acc = 0
  let nbits = 0
  for c in s.clusters() {
    let v = _b64map.at(c, default: none)
    if v == none { continue }
    acc = acc * 64 + v
    nbits += 6
    if nbits >= 8 {
      nbits -= 8
      let p = calc.pow(2, nbits)
      out.push(calc.quo(acc, p))
      acc = calc.rem(acc, p)
    }
  }
  out
}

#let _hv(b) = if b >= 48 and b <= 57 { b - 48 } else if b >= 65 and b <= 70 {
  b - 55
} else if b >= 97 and b <= 102 { b - 87 } else { none }

/// Decodes %XX escapes in an array of byte values.
#let url-decode(arr) = {
  let out = ()
  let i = 0
  let n = arr.len()
  while i < n {
    let b = arr.at(i)
    if b == 37 and i + 2 < n {
      let h = _hv(arr.at(i + 1))
      let l = _hv(arr.at(i + 2))
      if h != none and l != none {
        out.push(h * 16 + l)
        i += 3
        continue
      }
    }
    out.push(b)
    i += 1
  }
  out
}

#let _to-bits(data) = {
  let bits = ()
  for b in data {
    let x = b
    for _ in range(8) {
      bits.push(calc.rem(x, 2))
      x = calc.quo(x, 2)
    }
  }
  bits
}

#let _read(bits, pos, n) = {
  let v = 0
  let m = 1
  for i in range(n) {
    v += bits.at(pos + i) * m
    m *= 2
  }
  v
}

// Canonical Huffman table: (count per length, symbols ordered by code).
#let _build(lengths) = {
  let count = (0,) * 16
  for l in lengths { count.at(l) += 1 }
  let offs = (0,) * 16
  for l in range(1, 15) { offs.at(l + 1) = offs.at(l) + count.at(l) }
  let symbol = (0,) * lengths.len()
  for (sym, l) in lengths.enumerate() {
    if l != 0 {
      symbol.at(offs.at(l)) = sym
      offs.at(l) += 1
    }
  }
  (count, symbol)
}

// Returns (symbol, new bit position).
#let _decode(bits, pos, tbl) = {
  let (count, symbol) = tbl
  let code = 0
  let first = 0
  let index = 0
  let p = pos
  for len in range(1, 16) {
    code += bits.at(p)
    p += 1
    let c = count.at(len)
    if code - c < first { return (symbol.at(index + (code - first)), p) }
    index += c
    first += c
    first *= 2
    code *= 2
  }
  panic("drawio: corrupt compressed data (bad Huffman code)")
}

#let _fixed-lit = _build(range(288).map(i => if i < 144 { 8 } else if i < 256 {
  9
} else if i < 280 { 7 } else { 8 }))
#let _fixed-dist = _build((5,) * 30)

#let _lbase = (3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258)
#let _lext = (0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0)
#let _dbase = (1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577)
#let _dext = (0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13)
#let _order = (16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15)

/// Inflates a raw DEFLATE stream (array of bytes) into an array of bytes.
#let inflate(data) = {
  let bits = _to-bits(data)
  let out = ()
  let pos = 0
  let last = false
  while not last {
    last = bits.at(pos) == 1
    let typ = bits.at(pos + 1) + 2 * bits.at(pos + 2)
    pos += 3
    if typ == 0 {
      // stored block
      pos = calc.quo(pos + 7, 8) * 8
      let len = _read(bits, pos, 16)
      pos += 32
      let start = calc.quo(pos, 8)
      for i in range(len) { out.push(data.at(start + i)) }
      pos += len * 8
    } else if typ == 3 {
      panic("drawio: corrupt compressed data (bad block type)")
    } else {
      let lit = _fixed-lit
      let dist = _fixed-dist
      if typ == 2 {
        let nlen = _read(bits, pos, 5) + 257
        let ndist = _read(bits, pos + 5, 5) + 1
        let ncode = _read(bits, pos + 10, 4) + 4
        pos += 14
        let lengths = (0,) * 19
        for i in range(ncode) {
          lengths.at(_order.at(i)) = _read(bits, pos, 3)
          pos += 3
        }
        let lencode = _build(lengths)
        let ll = ()
        while ll.len() < nlen + ndist {
          let (sym, p) = _decode(bits, pos, lencode)
          pos = p
          if sym < 16 {
            ll.push(sym)
          } else {
            let prev = 0
            let rep = 0
            if sym == 16 {
              prev = ll.last()
              rep = 3 + _read(bits, pos, 2)
              pos += 2
            } else if sym == 17 {
              rep = 3 + _read(bits, pos, 3)
              pos += 3
            } else {
              rep = 11 + _read(bits, pos, 7)
              pos += 7
            }
            for _ in range(rep) { ll.push(prev) }
          }
        }
        lit = _build(ll.slice(0, nlen))
        dist = _build(ll.slice(nlen))
      }
      let done = false
      while not done {
        let (sym, p) = _decode(bits, pos, lit)
        pos = p
        if sym < 256 {
          out.push(sym)
        } else if sym == 256 {
          done = true
        } else {
          let s = sym - 257
          let len = _lbase.at(s) + _read(bits, pos, _lext.at(s))
          pos += _lext.at(s)
          let (ds, p2) = _decode(bits, pos, dist)
          pos = p2
          let d = _dbase.at(ds) + _read(bits, pos, _dext.at(ds))
          pos += _dext.at(ds)
          let from = out.len() - d
          for i in range(len) { out.push(out.at(from + i)) }
        }
      }
    }
  }
  out
}
