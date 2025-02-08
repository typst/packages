/// Converts math equations to strings.
/// -> string
#let math-to-str(
  /// The math expression.
  /// - equation
  math,
) = {
  let map-math(n, depth: 0) = {
    if n.has("base") {
      "calc.pow(" + math-to-str(n.base) + ", " + math-to-str(n.t.text) + ")"
    } else if n.has("radicand") {
      (
        "calc.root("
          + math-to-str(n.radicand)
          + ", "
          + n.at("index", default: "2")
          + ")"
      )
    } else if n.has("num") {
      "(" + math-to-str(n.num) + ")/(" + math-to-str(n.denom) + ")"
    } else {
      n.at("text", default: "")
    }
  }

  // Adding `[]` to make it a sequence if it isn't already.
  let nodes = (math.at("body", default: math) + []).fields().children
  nodes
    .map(map-math)
    .join()
    .replace(regex("(\d)\s*x"), ((captures,)) => captures.first() + "*x")
}


