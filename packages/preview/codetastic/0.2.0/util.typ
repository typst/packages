

#let to-arr(code) = {
  if type(code) == "integer" {
    code = str(code)
  }
  if type(code) == "string" {
    code = code.clusters().map(int)
  }
  if type(code) != "array" {
    panic("Code needs to be provided as integer, string or array. Got " + type(code))
  }
  return code
}

#let to-int-arr(code) = {
  return to-arr(code).map(int)
}

#let weighted-sum(nums, weights) = {
  let w-func
  if type(weights) == "array" {
    w-func = (i) => {
      return weights.at(calc.rem(i, weights.len()))
    }
  } else if type(weights) == "function" {
    w-func = weights
  }
  return nums.enumerate().fold(0, (s,v) => {
    let (i, n) = (..v)
    s + n * w-func(i)
  })
}

#let check-code(
  code, digits, generator, tester
) = {
  if code.len() == digits - 1 {
    code.push(generator(code))
  } else if code.len() == digits {
    if not tester(code) {
      panic("Checksum failed for code " + repr(code) + ". Should be " + str(generator(code.slice(0,-1))))
    }
  } else {
    panic("Code has to be " + (digits - 1) + " digits (excluding checksum). Got " + code.len())
  }
  return code
}

#let place-code(cnt) = box(cnt)

#let place-rect(x, y, width, height, fill: black) = place(
  dx: x, dy:y,
  rect(width: width, height: height, fill: fill, stroke: .1pt+fill)
)

#let typst-align = align
#let place-content(x, y, width, height, cnt, fill:white, align:center+horizon) = place(
  dx: x, dy:y,
  block(width: width, height: height, fill: fill, stroke: .1pt+fill, typst-align(align, cnt))
)

#let draw-bars(bits, bar-width:0.264mm, bar-height:18.28mm, bg: white, fg: black) = {
  let width = bits.len() * bar-width

  // Cluster bits to draw thick bars
  // as one rect
  bits = bits.fold((), (c, v) => {
    if v {
      if c == () or c.last() == 0 {
        c.push(1)
      } else {
        c.at(-1) += 1
      }
    } else {
      c.push(0)
    }
    c
  })

  let bar(i, n) = place(
    dx: i * bar-width,
    rect(width: n * bar-width, height: bar-height, fill:fg, stroke:none)
  )

  box(
    width: width,
    height: bar-height,
    {
      place(rect(
        width: width, height: bar-height,
        fill:bg, stroke:none
      ))

      let i = 0
      for bit in bits {
        if bit > 0 {
          bar(i, bit)
        i += bit
        } else {
          i += 1
        }
      }
    }
  )
}


/// Draw a bitfield of binary data as a 2d code matrix.
///
/// Bits will be drawn from the top left to the bottom right.
/// `bits.at(0).at(0)` is located at coordinate `(0,0)` and
/// `bits.at(-1).at(-1)` is located at the last coordinate
/// on the bottom right.
#let draw-modules(
  bitfield,
  quiet-zone: 4,
  size: 1mm,
  bg: white,
  fg: black
) = {
  let (w, h) = (bitfield.first().len(), bitfield.len())
  let (x, y) = (quiet-zone, quiet-zone)
  let (width, height) = (
    (w+2*quiet-zone) * size,
    (h+2*quiet-zone) * size
  )

  let module(i, j) = place(
    dx: (x + j) * size,
    dy: (y + i) * size,
    square(size:size, fill:fg, stroke: .1pt+fg)
  )

  box(
    width: width,
    height: height,
    baseline: quiet-zone * size,
    {
      place(rect(
        width: width, height: height,
        fill:bg, stroke:none
      ))

      for i in range(h) {
        for j in range(w) {
          if bitfield.at(i).at(j) {
            module(i, j)
          }
        }
      }
    }
  )
}
