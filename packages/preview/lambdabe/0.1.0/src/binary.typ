#import "struct.typ": *
#import "parse.typ": *
#import "simplify.typ": *
#import "free-vars.typ": *

#let encode(expr) = {
  if type(expr) == str {
    expr = parse(expr)
  }
  expr = expand(expr)
  assert(free-vars(expr).len() == 0)
  let impl(expr, vars) = {
    if expr.type == "var" {
      "1" * (vars.len() - vars.at(expr.name)) + "0"
    } else if expr.type == "func" {
      vars.insert(expr.vars.first().name, vars.len())
      "00 " + impl(expr.body, vars)
    } else if expr.type == "apply" {
      "01 " + expr.items.map(i => impl(i, vars)).join(" ")
    } else {
      panic()
    }
  }
  impl(expr, (:))
}

#let equal(e1, e2) = {
  encode(e1) == encode(e2)
}

#let decode(bits) = {
  bits = bits.replace(" ", "").clusters()
  assert(bits.all(b => b == "0" or b == "1"))
  let tokens = ()
  while bits.len() > 1 {
    if bits.slice(0, 2) == "00".clusters() {
      tokens.push("func")
      bits = bits.slice(2)
    } else if bits.slice(0, 2) == "01".clusters() {
      tokens.push("apply")
      bits = bits.slice(2)
    } else if bits.at(0) == "1" {
      let count = 1
      while count < bits.len() and bits.at(count) == "1" {
        count += 1
      }
      assert(count < bits.len() and bits.at(count) == "0")
      tokens.push(count)
      bits = bits.slice(count + 1)
    } else {
      panic()
    }
  }
  assert(bits.len() == 0)
  // `var-count`: outer variable count
  // Returns: (the index of the token after current expression, parse result).
  let impl(i, var-count) = {
    if type(tokens.at(i)) == int {
      (i + 1, var(str(var-count - tokens.at(i) + 1, base: 36)))
    } else if tokens.at(i) == "func" {
      i += 1
      let (j, body) = impl(i, var-count + 1)
      (j, func(var(str(var-count + 1, base: 36)), body))
    } else if tokens.at(i) == "apply" {
      i += 1
      let (j, f) = impl(i, var-count)
      let (k, x) = impl(j, var-count)
      (k, apply(f, x))
    } else {
      panic()
    }
  }
  let (j, expr) = impl(0, 0)
  assert(j == tokens.len())
  simplify(expr)
}
