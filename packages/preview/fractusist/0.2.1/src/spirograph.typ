//==============================================================================
// The spirograph curve
//
// Public functions:
//     hypotrochoid, epitrochoid
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate hypotrochoid
//
// a, b, h: [1, 100]
//
// Arguments:
//     a: the radius of exterior circle
//     b: the radius of interior circle
//     h: the distance from the center of the interior circle
//     size: the width/height of the image (in pt), optional
//     fill: how to fill the curve, optional
//     fill-rule: the drawing rule used to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let hypotrochoid(a, b, h, size: 100, fill: none, fill-rule: "non-zero", stroke: black + 1pt) = {
  assert(type(a) == int and a >= 1 and a <= 100, message: "`a` should be in range [1, 100]")
  assert(type(b) == int and b >= 1 and b <= 100, message: "`b` should be in range [1, 100]")
  assert(type(h) == int and h >= 1 and h <= 100, message: "`h` should be in range [1, 100]")
  assert(size > 0, message: "`size` should be positive")

  let t-cyc = int(calc.lcm(a, b) / a)
  let sc = size/2 / (calc.abs(a - b) + h)
  let cmd = ()
  for i in range(t-cyc * 200 + 1) {
    let t = i / 100 * calc.pi
    let x = ((a - b)*calc.cos(t) + h*calc.cos((a - b)/b*t)) * sc + size/2
    let y = ((a - b)*calc.sin(t) - h*calc.sin((a - b)/b*t)) * sc + size/2
    if i == 0 {
      cmd.push(std.curve.move((x * 1pt, y * 1pt)))
    } else {
      cmd.push(std.curve.line((x * 1pt, y * 1pt)))
    }
  }
  cmd.push(std.curve.close())

  box(
    width: size * 1pt, height: size * 1pt,
    std.curve(fill: fill, fill-rule: fill-rule, stroke: stroke, ..cmd)
  )
}


// Generate epitrochoid
//
// a, b, h: [1, 100]
//
// Arguments:
//     a: the radius of exterior circle
//     b: the radius of interior circle
//     h: the distance from the center of the interior circle
//     size: the width/height of the image (in pt), optional
//     fill: how to fill the curve, optional
//     fill-rule: the drawing rule used to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let epitrochoid(a, b, h, size: 100, fill: none, fill-rule: "non-zero", stroke: black + 1pt) = {
  assert(type(a) == int and a >= 1 and a <= 100, message: "`a` should be in range [1, 100]")
  assert(type(b) == int and b >= 1 and b <= 100, message: "`b` should be in range [1, 100]")
  assert(type(h) == int and h >= 1 and h <= 100, message: "`h` should be in range [1, 100]")
  assert(size > 0, message: "`size` should be positive")

  let t-cyc = int(calc.lcm(a, b) / a)
  let sc = size/2 / (calc.abs(a + b) + h)
  let cmd = ()
  for i in range(t-cyc * 200 + 1) {
    let t = i / 100 * calc.pi
    let x = ((a + b)*calc.cos(t) - h*calc.cos((a + b)/b*t)) * sc + size/2
    let y = ((a + b)*calc.sin(t) - h*calc.sin((a + b)/b*t)) * sc + size/2
    if i == 0 {
      cmd.push(std.curve.move((x * 1pt, y * 1pt)))
    } else {
      cmd.push(std.curve.line((x * 1pt, y * 1pt)))
    }
  }
  cmd.push(std.curve.close())

  box(
    width: size * 1pt, height: size * 1pt,
    std.curve(fill: fill, fill-rule: fill-rule, stroke: stroke, ..cmd)
  )
}
