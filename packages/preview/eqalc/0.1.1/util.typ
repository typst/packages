/// Converts a label to a math expression.
/// -> content
#let label-to-math(
  /// A label representing a math expression.
  /// -> label
  label,
) = {
  query(label).first()
}

/// Converts math equations to strings.
/// -> string
#let math-to-str(
  /// The math expression.
  /// -> content | label
  eq,
  /// Get the part before the equals sign. This is used to get the function name.
  /// -> boolean
  get-first-part: false,
  /// The depth of the recursion. This is used for debugging.
  /// -> integer
  depth: 0,
) = {
  let map-math(n) = {
    // Operators like sin, cos, etc.
    if n.func() == math.op {
      "calc." + n.fields().text.text
      // Parentheses
    } else if n.func() == math.lr {
      math-to-str(n.body, depth: depth + 1)
      // Powers
    } else if n.has("base") and n.has("t") {
      "calc.pow(" + math-to-str(n.base) + ", " + math-to-str(n.t) + ")"
      // Roots
    } else if n.func() == math.root {
      (
        "calc.root("
          + math-to-str(n.radicand, depth: depth + 1)
          + ", "
          + n.at("index", default: "2")
          + ")"
      )
      // Fractions
    } else if n.func() == math.frac {
      (
        "("
          + math-to-str(n.num, depth: depth + 1)
          + ")/("
          + math-to-str(n.denom, depth: depth + 1)
          + ")"
      )
      // Default case
    } else if n == [ ] { } else if n.has("text") {
      if n.text == "e" {
        "calc.e"
      } else if n.text == $pi$.body.text {
        "calc.pi"
      } else if n.text == $tau$.body.text {
        "calc.tau"
      } else {
        n.text
      }
      // This is still a sequence.
    } else {
      math-to-str(n, depth: depth + 1)
    }
  }

  if type(eq) == "label" {
    eq = label-to-math(eq)
  }

  if not type(eq) == "string" and eq.has("body") {
    eq = eq.body
  }
  // Adding `[]` to make it a sequence if it isn't already.
  let string = (eq + [])
    .fields()
    .children
    .map(map-math)
    .join()
    .replace(
      regex("(\d)\s*([a-zA-Z]\b|calc|\()"),
      ((captures,)) => captures.first() + "*" + captures.last(),
    )
    .replace(math.dot, "*")

  if depth == 0 {
    let reg = if get-first-part {
      if string.contains("=") {
        regex("=.+")
      } else {
        regex(".+")
      }
    } else {
      regex(".+=")
    }
    string.replace(reg, "")
  } else {
    string
  }
}

/// Gets the main variable from a math expression.
/// -> string
#let get-variable(
  /// The math expression.
  /// -> string
  math-str,
) = {
  let reg = regex("\b([A-Za-z--e])\b")
  let match = math-str.match(reg)
  if match != none {
    match.text
  } else {
    "x"
  }
}
