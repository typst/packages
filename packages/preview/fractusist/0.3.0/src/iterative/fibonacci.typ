//==============================================================================
// The Fibonacci fractal
//
// Public functions:
//     fibonacci-word-fractal
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate Fibonacci word fractal
//
// iterations: [3, 24]
//
// Arguments:
//     n: the number of iterations
//     skip-last: whether skip the last symbol (Fibonacci word fractal becomes more symmetrical), optional;
//                default is true, false is not skip the last symbol
//     step-size: step size (in pt), optional
//     start-dir: starting direction (0: right, 1:up, 2:left, 3: down), optional
//     padding: spacing around the content (in pt), optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let fibonacci-word-fractal(
  n,
  skip-last: true,
  step-size: 10,
  start-dir: 0,
  padding: 0,
  stroke: black + 1pt
) = {
  assert(type(n) == int and n >= 3 and n <= 24, message: "`n` should be in range [3, 24]")
  assert(type(skip-last) == bool, message: "`skip-last` should be boolean")
  assert((type(step-size) == int or type(step-size) == float) and step-size > 0, message: "`step-size` should be positive")
  assert(type(start-dir) == int and start-dir >= 0 and start-dir <= 3, message: "`start-dir` should be in range [0, 3]")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")

  let dx = (step-size, 0, -step-size, 0)
  let dy = (0, step-size, 0, -step-size)

  let (s-2, s-1) = ("1", "0")
  let s
  for i in range(3, n + 1) {
    s = s-1 + s-2
    s-2 = s-1
    s-1 = s
  }
  if skip-last {
    let lens = s.len()
    s = s.slice(0, lens - 1)
  }

  let dir = start-dir
  let cmd = ()
  let (x, y) = (0, 0)
  let (x-min, x-max, y-min, y-max) = (0, 0, 0, 0)
  let is-odd = 0
  for c in s {
    is-odd = 1 - is-odd
    cmd.push(std.curve.line((dx.at(dir) * 1pt, dy.at(dir) * 1pt), relative: true))
    x += dx.at(dir)
    y += dy.at(dir)
    x-min = calc.min(x-min, x)
    x-max = calc.max(x-max, x)
    y-min = calc.min(y-min, y)
    y-max = calc.max(y-max, y)
    if c == "0" {
      if is-odd == 1 {
        dir += 1
        if (dir == 4) {dir = 0}
      } else {
        dir -= 1
        if dir < 0 {dir = 3}
      }
    }
  }
  x-min -= padding
  x-max += padding
  y-min -= padding
  y-max += padding
  cmd.insert(0, std.curve.move((-x-min * 1pt, -y-min * 1pt)))

  let width = (x-max - x-min) * 1pt
  let height = (y-max - y-min) * 1pt
  box(
    width: width, height: height,
    place(std.curve(stroke: stroke, ..cmd))
  )
}
