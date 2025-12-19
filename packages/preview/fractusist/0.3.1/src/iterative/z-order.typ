//==============================================================================
// The Z-order curve
//
// Public functions:
//     z-order-curve
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate Z-order curve
//
// iterations: [1, 8]
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     start-dir: starting direction (0:horizontal, 1:vertical), optional
//     padding: spacing around the content (in pt), optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let z-order-curve(
  n,
  step-size: 10,
  start-dir: 0,
  padding: 0,
  stroke: black + 1pt
) = {
  assert(type(n) == int and n >= 1 and n <= 8, message: "`n` should be in range [1, 8]")
  assert((type(step-size) == int or type(step-size) == float) and step-size > 0, message: "`step-size` should be positive")
  assert(type(start-dir) == int and start-dir >= 0 and start-dir <= 1, message: "`start-dir` should be in range [0, 1]")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")

  let s = (0,)
  for i in range(1, n) {
    let kp = calc.pow(2, i) - 1
    let kn = 1 - calc.pow(2, i + 1)
    s = (s, kp, s, kn, s, kp, s).flatten()
  }

  let size = step-size * (calc.pow(2, n) - 1) + 2 * padding
  let cmd = ()
  if start-dir == 0 {
    cmd.push(std.curve.move((padding * 1pt, padding * 1pt)))
    for c in s {
      if c == 0 {
        cmd.push(std.curve.line((step-size * 1pt, 0pt), relative: true))
        cmd.push(std.curve.line((-step-size * 1pt, step-size * 1pt), relative: true))
        cmd.push(std.curve.line((step-size * 1pt, 0pt), relative: true))
      } else if c > 0 {
        cmd.push(std.curve.line((step-size * 1pt, -step-size * c * 1pt), relative: true))
      } else {
        cmd.push(std.curve.line((step-size * c * 1pt, step-size * 1pt), relative: true))
      }
    }
  } else {
    cmd.push(std.curve.move((padding * 1pt, (size - padding) * 1pt)))
    for c in s {
      if c == 0 {
        cmd.push(std.curve.line((0pt, -step-size * 1pt), relative: true))
        cmd.push(std.curve.line((step-size * 1pt, step-size * 1pt), relative: true))
        cmd.push(std.curve.line((0pt, -step-size * 1pt), relative: true))
      } else if c > 0 {
        cmd.push(std.curve.line((-step-size * c * 1pt, -step-size * 1pt), relative: true))
      } else {
        cmd.push(std.curve.line((step-size * 1pt, -step-size * c * 1pt), relative: true))
      }
    }
  }

  box(
    width: size * 1pt, height: size * 1pt,
    place(std.curve(stroke: stroke, ..cmd))
  )
}
