// Decorative rules: the chapter-rule reading-position hairline and the hashed
// bit-rule shared by the bachelor-thesis cover and the poster separator.

#import "includes.typ" as inc

// Decorative "hash rule": a brand-colored square at each end joined by a line
// whose circles encode a deterministic hash of `seed` (hollow = 1 bit, filled
// = 0 bit). Each document therefore gets a stable, unique pattern. Shared by
// the bachelor-thesis cover and the poster title separator.
#let hash-rule(
  seed,
  length: 8cm,
  thickness: 2pt,
  square-size: 8pt,
  circle-r: 2.5pt,
  n-bits: 16,
  bits-length: auto,
  color: inc.hei-purple,
) = {
  // bits-length: span the circle bits are packed into (left-aligned). When
  // auto it equals `length` (bits fill the whole rule); set it shorter to
  // cluster the bits on the left and let the line run on to the right square.
  let bspan = if bits-length == auto { length } else { bits-length }
  let bit-set(n, i) = calc.rem(int(n / calc.pow(2, i)), 2) == 1

  // Polynomial rolling hash (base 31) over the seed string.
  let hash = seed.clusters().fold(0, (acc, ch) =>
    calc.rem(acc * 31 + str.to-unicode(ch), 2147483647))

  let pattern = calc.rem(hash, calc.pow(2, n-bits))

  // Guarantee at least n-bits/4 set bits so the pattern never looks empty.
  let min-ones = calc.quo(n-bits, 4)
  let ones = range(n-bits).filter(i => bit-set(pattern, i)).len()
  if ones < min-ones {
    let s = calc.quo(hash, calc.pow(2, n-bits))
    let i = 0
    while ones < min-ones {
      let pos = calc.rem(s + i * 7, n-bits)
      if not bit-set(pattern, pos) {
        pattern = pattern + calc.pow(2, pos)
        ones = ones + 1
      }
      i = i + 1
    }
  }

  box(width: length, height: square-size, {
    let mid = square-size / 2
    // Main line, vertically centered in the box.
    place(dy: mid, line(length: length, stroke: (thickness: thickness, paint: color)))
    // End squares.
    place(rect(width: square-size, height: square-size, fill: color, stroke: none))
    place(dx: length - square-size, rect(width: square-size, height: square-size, fill: color, stroke: color))
    // Bit circles, evenly spaced across the (possibly shorter) bits span,
    // with the whole cluster centered in `length` (leading + trailing line).
    let usable = bspan - 2 * square-size
    let gap    = (usable - n-bits * 2 * circle-r) / (n-bits + 1)
    let stride = 2 * circle-r + gap
    let bits-offset = (length - bspan) / 2
    for i in range(n-bits) {
      let dx-val = bits-offset + square-size + gap + circle-r + i * stride
      place(dx: dx-val, dy: mid - circle-r,
        circle(radius: circle-r,
               fill: if bit-set(pattern, i) { white } else { color },
               stroke: 0.5pt + color))
    }
  })
}

// Draws the reading-position hairline below a numbered chapter heading: a faint
// full-width track with the leading `progress` fraction (0–1) in brand color and
// a dot at the head, indicating chapter n of the total. With `progress: none`
// nothing visible is drawn.
#let chapter-rule(progress: none) = {
  let color      = inc.hei-purple
  let track-w    = 1.0pt   // faint background track
  let fill-w     = 1.0pt   // filled (read-so-far) portion
  let dot-r      = 4.0pt   // head marker radius

  // Distance between heading text and line
  v(-0.2em)

  layout(size => {
    if progress != none {
      place(line(length: size.width, stroke: (paint: luma(60%), thickness: track-w)))
      place(line(length: progress * size.width, stroke: (paint: color, thickness: fill-w)))
      // Head marker at the current reading position.
      place(dx: progress * size.width, move(dx: -dot-r, dy: -dot-r,
        circle(radius: dot-r, fill: color, stroke: none)))
    }

    // Space below the line
    v(1em)
  })
}
