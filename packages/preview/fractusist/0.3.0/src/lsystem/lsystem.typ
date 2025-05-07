//==============================================================================
// L-system generator
//
// Public functions:
//     lsystem
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// L-system generator
//
// The L-system treats the symbols as follows:
//     `draw-forward-sym`: move forward by line length `step-size` drawing a line
//     `move-forward-sym`: move forward by line length `step-size` without drawing a line
//     +: turn left by turning angle `angle`
//     -: turn right by turning angle `angle`
//     |: reverse direction (i.e. turn by 180 degrees)
//     [: save the current state (i.e. the position and direction)
//     ]: restore the last saved state
// All other symbols are ignored.
//
// Arguments:
//     draw-forward-sym: symbol set for moving forward by line length drawing a line, optional
//     move-forward-sym: symbol set for moving forward by line length without drawing a line, optional
//     axiom: starting string, optional
//     rule-set: rewrite rule, optional
//     angle: turning angle (in $pi$ radius), optional
//     cycle: whether close the curve, optional; default is false
//     order: the number of iterations, optional
//     step-size: step size (in pt), optional
//     start-angle: starting angle of direction (in $pi$ radius), optional
//     padding: spacing around the content (in pt), optional
//     fill: how to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let lsystem(
  draw-forward-sym: "F",
  move-forward-sym: "",
  axiom: "F",
  rule-set: ("F": "F-F++F-F"),
  angle: 1/3,
  cycle: false,
  order: 3,
  step-size: 10,
  start-angle: 1,
  padding: 0,
  fill: none,
  stroke: black + 1pt
) = {
  // Check the validity of arguments
  assert(type(draw-forward-sym) == str and draw-forward-sym.len() > 0, message: "`draw-forward-sym` should be non-empty string")
  assert(type(move-forward-sym) == str, message: "`move-forward-sym` should be string")
  assert(type(axiom) == str and axiom.len() > 0, message: "`axiom` should be non-empty string")
  assert(type(rule-set) == dictionary and rule-set.len() > 0, message: "`rule-set` should be non-empty dictionary")
  for (k, v) in rule-set {
    assert(k.len() == 1, message: "key of dictionary `rule-set` should be single character")
    assert(type(v) == str, message: "value of dictionary `rule-set` should be string")
  }
  assert(type(angle) == float and angle > 0 and angle < 1, message: "`angle` should be in range (0, 1)")
  assert(type(cycle) == bool, message: "`cycle` should be boolean")
  assert(type(order) == int and order >= 0, message: "`order` should be non-negative integer")
  assert((type(step-size) == int or type(step-size) == float) and step-size > 0, message: "`step-size` should be positive")
  assert((type(start-angle) == int or type(start-angle) == float) and start-angle >= 0 and start-angle < 2, message: "`start-angle` should be in range [0, 2)")
  assert((type(padding) == int or type(padding) == float) and padding >= 0, message: "`padding` should be non-negative")

  // Generate the string after iteration
  let match-str = regex(rule-set.keys().join("|"))
  let s = axiom
  for i in range(order) {
    s = s.replace(match-str, x => rule-set.at(x.text))
    assert(s.len() <= 500000, message: "the length of string has exceeded 500000")
  }

  // Generate drawing commands
  let (x-min, x-max, y-min, y-max) = (0, 0, 0, 0)
  let (x, y) = (0, 0)
  let a = start-angle
  let (x0, y0) = (0, 0)
  let (dx, dy) = (0, 0)
  let stk = ()
  let cmd = ()
  for c in s {
    if c == "+" {
      a += angle
      if a >= 2 {a -= 2}
    } else if c == "-" {
      a -= angle
      if (a < 0) {a += 2}
    } else if c == "|" {
      a += 1
      if a >= 2 {a -= 2}
    } else if c in draw-forward-sym {
      dx = calc.cos(a * calc.pi) * step-size
      dy = -calc.sin(a * calc.pi) * step-size
      x0 = x
      y0 = y
      x += dx
      y += dy
      x-min = calc.min(x-min, x0, x)
      x-max = calc.max(x-max, x0, x)
      y-min = calc.min(y-min, y0, y)
      y-max = calc.max(y-max, y0, y)
      cmd.push(std.curve.line((dx * 1pt, dy * 1pt), relative: true))
    } else if c in move-forward-sym {
      dx = calc.cos(a * calc.pi) * step-size
      dy = -calc.sin(a * calc.pi) * step-size
      x += dx
      y += dy
      cmd.push(std.curve.move((dx * 1pt, dy * 1pt), relative: true))
    } else if c == "[" {
      stk.push((x, y, a))
    } else if c == "]" {
      (x0, y0, a) = stk.pop()
      dx = x0 - x
      dy = y0 - y
      x = x0
      y = y0
      cmd.push(std.curve.move((dx * 1pt, dy * 1pt), relative: true))
    }
  }
  if cycle {cmd.push(std.curve.close(mode: "straight"))}
  x-min -= padding
  x-max += padding
  y-min -= padding
  y-max += padding
  cmd.insert(0, std.curve.move((-x-min * 1pt, -y-min * 1pt)))

  // Output the graphic
  let width = (x-max - x-min) * 1pt
  let height = (y-max - y-min) * 1pt
  box(
    width: width, height: height,
    place(std.curve(fill: fill, stroke: stroke, ..cmd))
  )
}
