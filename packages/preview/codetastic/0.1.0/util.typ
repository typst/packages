
#import "@preview/cetz:0.1.1"
#import cetz.draw: rect


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

#let draw-bars(bits, width:0.264mm, height:18.28mm, bg: white, fg: black) = {
  // Draw background rect to set fixed size
  rect((0,0), (bits.len() * width, height), fill:bg, stroke:none, name:"code-bg")

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

  // Draw bars
  let i = 0
  for bit in bits {
    if bit > 0 {
      rect(
        (i*width,0),
        (rel:(bit*width,height)),
        fill:fg, stroke:none
      )
      i += bit
    } else {
      i += 1
    }
  }
}

#let draw-rect(at, width, height, fill: white, ..style) = {
  rect(
    at,
    (rel:(width,height)),
    fill: fill, stroke:none,
    ..style
  )
}


/// Draw a bitfield of binary data as a 2d code matrix.
///
/// Bits will be drawn from the top left to the bottom right.
/// `bits.at(0).at(0)` is located at coordinate `(0,0)` and
/// `bits.at(-1).at(-1)` is located at the last coordinate
/// on the bottom right.
#let draw-matrix(
  bitfield,
  quiet-zone: 4,
  size: 3mm,
  bg: white,
  fg: black
) = {
  let (w, h) = (bitfield.first().len(), bitfield.len())
  let (x, y) = (quiet-zone, quiet-zone)

  // Draw background rect to set fixed size
  rect((0,0), ((w+2*quiet-zone) * size, (h+2*quiet-zone) * -size), fill:bg, stroke:none, name:"code-bg")

  // Draw modules
  for i in range(h) {
    for j in range(w) {
      if bitfield.at(i).at(j) {
        rect(
          ((x + j) * size, (y + i) * -size),
          (rel:(size, -size)),
          fill:fg, stroke:none
        )
      }
    }
  }
}
