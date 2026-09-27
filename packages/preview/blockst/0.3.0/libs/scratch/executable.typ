// executable.typ — Core implementation for scratch-run()
// All functions use English names and English parameter names.
// Language-specific wrappers live in exec/de.typ and exec/en.typ.

// =====================================================
// MOTION — Turtle Graphics
// =====================================================

#let move(steps: 10) = (type: "move", steps: steps)
#let turn-right(degrees: 15) = (type: "turn-right", degrees: degrees)
#let turn-left(degrees: 15) = (type: "turn-left", degrees: degrees)
#let set-direction(direction: 90) = (type: "set-direction", angle: direction)
#let go-to(x: 0, y: 0) = (type: "goto", x: x, y: y)
#let set-x(x: 0) = (type: "set-x", x: x)
#let set-y(y: 0) = (type: "set-y", y: y)
#let change-x(dx: 10) = (type: "change-x", dx: dx)
#let change-y(dy: 10) = (type: "change-y", dy: dy)

// Reporters (return values)
#let x-position() = (type: "get", property: "x")
#let y-position() = (type: "get", property: "y")
#let direction() = (type: "get", property: "angle")

// =====================================================
// PEN
// =====================================================

#let erase-all() = (type: "clear")
#let stamp() = (type: "stamp")
#let pen-down() = (type: "pen-down")
#let pen-up() = (type: "pen-up")
#let set-pen-color(color: black) = (type: "set-color", color: color)
#let change-pen-size(size: 1) = (type: "change-size", delta: size)
#let set-pen-size(size: 1) = (type: "set-size", size: size)
#let change-pen-param(param, value: 10) = (
  type: "change-pen-param",
  param: param,
  delta: value,
)
#let set-pen-param(param, value: 50) = (
  type: "set-pen-param",
  param: param,
  value: value,
)
#let change-pen-color(value: 10) = change-pen-param("hue", value: value)
#let set-pen-color-param(value: 50) = set-pen-param("hue", value: value)
#let change-pen-saturation(value: 10) = change-pen-param("saturation", value: value)
#let set-pen-saturation(value: 100) = set-pen-param("saturation", value: value)
#let change-pen-brightness(value: 10) = change-pen-param("brightness", value: value)
#let set-pen-brightness(value: 100) = set-pen-param("brightness", value: value)
#let change-pen-transparency(value: 10) = change-pen-param("transparency", value: value)
#let set-pen-transparency(value: 0) = set-pen-param("transparency", value: value)

// =====================================================
// VARIABLES & OPERATORS
// =====================================================

// Variables
#let set-variable(name, value) = (type: "set-var", name: name, value: value)
#let change-variable(name, delta) = (type: "change-var", name: name, delta: delta)
#let variable(name) = (type: "get-var", name: name)

// Arithmetic
#let plus(a, b) = (type: "add", a: a, b: b)
#let minus(a, b) = (type: "subtract", a: a, b: b)
#let multiply(a, b) = (type: "multiply", a: a, b: b)
#let divide(a, b) = (type: "divide", a: a, b: b)
#let random(from: 1, to: 10) = (type: "random", from: from, to: to)
#let modulo(a, b) = (type: "mod", a: a, b: b)
#let round(number) = (type: "round", value: number)

// Comparisons
#let greater(a, b) = (type: "greater", a: a, b: b)
#let less(a, b) = (type: "less", a: a, b: b)
#let equals(a, b) = (type: "equals", a: a, b: b)

// Logic ("and", "or", "not" are Typst keywords — prefixed with "op-")
#let op-and(a, b) = (type: "and", a: a, b: b)
#let op-or(a, b) = (type: "or", a: a, b: b)
#let op-not(a) = (type: "not", a: a)

// =====================================================
// CONTROL FLOW
// =====================================================

// Note: repeat/if/while map to native Typst constructs.
// Use: for i in range(n), if cond, while cond

#let wait(seconds: 1) = (type: "wait", duration: seconds)

// =====================================================
// LOOKS — For debugging/display
// =====================================================

#let say(message) = (type: "say", message: message)
#let think(message) = (type: "think", message: message)

// =====================================================
// HELPERS
// =====================================================

#let square(size: 50) = {
  for i in range(4) {
    (move(steps: size), turn-right(degrees: 90))
  }
}

#let triangle(size: 50) = {
  for i in range(3) {
    (move(steps: size), turn-right(degrees: 120))
  }
}

#let circle(radius: 50, steps: 36) = {
  let circumference = 2 * calc.pi * radius
  let step-size = circumference / steps
  let angle = 360 / steps
  for i in range(steps) {
    (move(steps: step-size), turn-right(degrees: angle))
  }
}

#let close() = (type: "close")

#let star(size: 50, points: 5) = {
  // {n/2} star polygon: each segment turns by 360*2/n degrees
  // For a 5-pointed star: 5 × 144° = 720° = 2 full rotations → closes correctly
  let angle = 360 * 2 / points
  for i in range(points) {
    (move(steps: size), turn-right(degrees: angle))
  }
  (close(),)
}

#let spiral(start: 5, end: 100, steps: 50) = {
  let angle = 360 / steps
  for i in range(steps) {
    let size = start + (end - start) * i / steps
    (move(steps: size), turn-right(degrees: angle))
  }
}
