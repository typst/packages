// layout: raw bytes -> rows for a hex dump, plus the pure formatting leaves the
// renderer needs. No cetz. A hex dump is byte-granular: each row carries its
// byte offset and the byte values that fall in it; the renderer formats the hex
// and ASCII columns and (later) overlays field annotations. `per` is the row
// width in bytes (16 is the classic xxd / `hexdump -C` width).

#let to-bytes(data) = {
  // Accept Typst `bytes` (e.g. `read(file, encoding: none)`) or an int array.
  if type(data) == bytes { array(data) } else { data }
}

#let rows(data, per: 16) = {
  let b = to-bytes(data)
  let out = ()
  let r = 0
  while r * per < b.len() {
    let lo = r * per
    out.push((offset: lo, bytes: b.slice(lo, calc.min(lo + per, b.len()))))
    r += 1
  }
  out
}

// Two upper-case hex digits, zero-padded: 13 -> "0D", 255 -> "FF".
#let hex-byte(n) = {
  let s = upper(str(n, base: 16))
  "0" * (2 - s.len()) + s
}

// Zero-padded upper-case hex offset of a fixed digit width (default 8).
#let hex-offset(n, width: 8) = {
  let s = upper(str(n, base: 16))
  "0" * calc.max(0, width - s.len()) + s
}

// Printable ASCII renders as itself; everything else as a placeholder dot.
#let printable(n) = n >= 0x20 and n <= 0x7e
#let ascii(n) = if printable(n) { str.from-unicode(n) } else { "." }

// Lay `n` legend entries into balanced columns: aim for `per-col` a column, but
// never exceed `max-cols` (so 1 column up to `per-col`, 2 up to `2*per-col`, 3
// beyond — then columns just grow taller). Sizes differ by at most one, filled
// top-down then left-to-right, so there's no lonely trailing column. Returns
// `(cols, rows, positions)` where `positions.at(k) = (col, row)` for entry `k`.
#let legend-columns(n, per-col: 3, max-cols: 3) = {
  if n <= 0 {
    (cols: 0, rows: 0, positions: ())
  } else {
    let cols = calc.min(max-cols, calc.ceil(n / per-col))
    let base = int(n / cols)
    let extra = calc.rem(n, cols)
    let positions = ()
    let c = 0
    let r = 0
    for _i in range(0, n) {
      positions.push((c, r))
      r += 1
      if r >= base + (if c < extra { 1 } else { 0 }) {
        c += 1
        r = 0
      }
    }
    (cols: cols, rows: calc.ceil(n / cols), positions: positions)
  }
}
