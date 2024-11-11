#let is-literal(input) = {
  return input.len() == 1 and input.first() not in ("λ", " ", ".", "\\", "(", ")")
}

#let parse-literal(input) = {
  if is-literal(input) {
    return (type: "value", name: input.first())
  } else {
    panic("Not a valid λ-Calculus Literal: '" + input.join() + "'")
  }
}

#let parse-abstraction(input, parse-expr) = {
  let result = (
    type: "abstraction",
    param: (),
    body: (),
  )

  if input.remove(0) not in ("λ", "\\") {
    panic("Not a valid λ-Calculus Abstraction (needs to begin with λ or \\): '" + input.join() + "'")
  }

  let char = input.remove(0)
  if is-literal(char) {
    result.param = char
  } else if char == "." {
    panic("Not a valid λ-Calculus Abstraction (missing parameter): '" + "λ" + char + input.join() + "'")
  } else {
    panic("Not a valid λ-Calculus Abstraction (invalid parameter '" + char + "'): '" + input.join() + "'")
  }

  char = input.remove(0)
  if char == "." {
    result.body = parse-expr(input)
  } else if char == " " {
    result.body = parse-abstraction(
      ("λ",) + input,
      parse-expr
    )
  } else {
    panic("Not a valid λ-Calculus Abstraction (invalid parameter '" + char + "'): '" + input.join() + "'")
  }

  return result
}

#let parse-parenthesis(input, parse-expr) = {
  if input.first() != "(" or input.last() != ")" {
    panic("Not a valid λ-Calculus expression (wrong parenthesis placement): '" + input.join() + "'")
  }

  return parse-expr(input.slice(1, -1))
}

#let find-application-space(input) = {
  let last-space = none
  let in-abstr = false
  let in-par = 0
  for (index, value) in input.enumerate() {
    if value in ("λ", "\\") { in-abstr = true }
    else if value == "." { in-abstr = false }
    else if value == "(" { in-par += 1 }
    else if value == ")" { in-par -= 1 }
    
    if value == " " and in-abstr == false and in-par == 0 {
      last-space = index
    }
  }

  return last-space
}

#let parse-application(input, parse-expr) = {
  let last-space = find-application-space(input)
  if last-space == none {
    panic("Not a valid λ-Calculus application (missing space): '" + input.join() + "'")
  } else {
    let fn = parse-expr(input.slice(0, last-space))
    let param = parse-expr(input.slice(last-space + 1))

    return (
      type: "application",
      fn: fn,
      param: param,
    )
  }
}

#let parse-expr(input) = {
  if input.len() == 0 {
    panic("λ-Calculus expression must not be empty")
  }

  if input.first() in ("λ", "\\") {
    return parse-abstraction(input, parse-expr)
  } else if find-application-space(input) != none {
    return parse-application(input, parse-expr)
  } else if input.first() == "(" {
    return parse-parenthesis(input, parse-expr)
  } else if is-literal(input) {
    return parse-literal(input)
  } else {
    panic("Not a valid λ-Calculus expression: '" + input.join() + "'")
  }
}
