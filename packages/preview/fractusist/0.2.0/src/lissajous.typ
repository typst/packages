//==============================================================================
// The Lissajous curve
//
// Public functions:
//     lissajous-curve
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate Lissajous curve
//
// a, b: [1, 100]
// d: [0, 2]
//
// Arguments:
//     a: the frequency of x-axis
//     b: the frequency of y-axis
//     d: the phase offset of x-axis (in $pi$ radius)
//     x-size: the width of the image (in pt), optional
//     y-size: the height of the image (in pt), optional
//     fill: how to fill the curve, optional
//     fill-rule: the drawing rule used to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let lissajous-curve(a, b, d, x-size: 100, y-size: 100, fill: none, fill-rule: "non-zero", stroke: black + 1pt) = {
  assert(type(a) == int and a >= 1 and a <= 100, message: "`a` should be in range [1, 100]")
  assert(type(b) == int and b >= 1 and b <= 100, message: "`b` should be in range [1, 100]")
  assert(d >= 0 and d <= 2, message: "`d` should be in range [0, 2]")
  assert(x-size > 0, message: "`x-size` should be positive")
  assert(y-size > 0, message: "`y-size` should be positive")

  let g = calc.gcd(a, b)
  let t-cyc = int(calc.max(a, b) / g * 200);
  let t-res = 2 * calc.pi / (g * t-cyc)
  let cmd = ()
  for i in range(t-cyc + 1) {
    let t = i * t-res
    let x = x-size/2 * (calc.sin(a * t + d * calc.pi) + 1)
    let y = y-size/2 * (calc.sin(b * t) + 1)
    if i == 0 {
      cmd.push(std.curve.move((x * 1pt, y * 1pt)))
    } else {
      cmd.push(std.curve.line((x * 1pt, y * 1pt)))
    }
  }
  cmd.push(std.curve.close())

  box(
    width: x-size * 1pt, height: y-size * 1pt,
    std.curve(fill: fill, fill-rule: fill-rule, stroke: stroke, ..cmd)
  )
}
