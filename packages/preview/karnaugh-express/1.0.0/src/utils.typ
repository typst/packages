// arrange the display variables in the same way as the functional variables
#let arrange-disp-vars(var-disp, arrangement, vars) = {
  let var-disp-len = var-disp.len()
  let var-len = vars.len()

  let new-disp = ()

  for row in arrangement {
    let inb = ()
    for (i-col, val) in row.enumerate() {
      let index = vars.position(x => x == val)
      inb.push(var-disp.at(index, default: vars.at(index)))
    }
    new-disp.push(inb)
  }
  new-disp
}

// create the standard "label" based on the provided variables
#let create-label-equation(vars, funcname: $f$) = {
  math.equation(funcname + math.lr($($ + vars.join($,$) + $)$))
}

// Converts x to an array, if it isn't one already
#let to-array(x) = {
  if type(x) == array { x } else { (x,) }
}

// Converts x to an array of arrays
#let to-array-of-arrays(x) = {
  // Outer array
  let x = to-array(x)

  // Inner array
  if x.any(c => type(c) == array) {
    x.map(to-array)
  } else {
    (x,)
  }
}

#let content-type = type([])
#let symbol-type = type(sym.alpha)
#let stroke-type = type(1pt + black)
#let none-type = type(none)

#let content-types = (str, content-type, int, float, symbol-type, none-type)
#let number-types = (int, float)
#let stroke-types = (length, color, stroke-type, dictionary)

// Returns the type name of a variable
#let type-name(x) = str(type(x))

// Tests wether the provided vairable x is of type expected
// Name is the name of the argument that is being tested
#let assert-type(x, expected, name) = {
  let expected = to-array(expected).flatten()
  assert(
    type(x) in expected,
    message: "`" + name + "`: expected " + expected.map(t => repr(t)).join(" or ")
      + ", got " + type-name(x) + " (" + repr(x) + ")",
  )
}

// Tests wether x is an array of expected
#let assert-array-of(x, expected, name) = {
  assert-type(x, array, name)
  for (i, e) in x.enumerate() {
    assert-type(e, expected, name + "[" + str(i) + "]")
  }
}

// Tests wether x is an array of arrays of expected
#let assert-array-of-arrays-of(x, expected, name) = {
  assert-type(x, array, name)
  for (i, inner) in x.enumerate() {
    assert-array-of(inner, expected, name + "[" + str(i) + "]")
  }
}

// Returns elements that occur more than once in an array
#let duplicates-in(x) = x.filter(v => x.filter(w => w == v).len() > 1).dedup()

// Recolor a standard stroke
#let recolor-stroke(s, paint) = std.stroke(
  paint: paint,
  thickness: s.thickness,
  cap: s.cap,
  join: s.join,
  dash: s.dash,
  miter-limit: s.miter-limit,
)
