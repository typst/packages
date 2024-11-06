#import "printing.typ": expr-to-str
#import "parsing.typ": parse-literal

#let free-vars(expr) = {
  if expr.type == "value" {
    return (expr.name,)
  } else if expr.type == "application" {
    return (free-vars(expr.fn) + free-vars(expr.param)).dedup()
  } else if expr.type == "abstraction" {
    return free-vars(expr.body).filter(it => it != expr.param)
  }
}

#let alpha-conversion-impl(expr, old, new) = {
  if expr.type == "abstraction" {
    if expr.param == old {
      return expr
    } else {
      expr.body = alpha-conversion-impl(expr.body, old, new)
      return expr
    }
  } else if expr.type == "application" {
    expr.fn = alpha-conversion-impl(expr.fn, old, new)
    expr.param = alpha-conversion-impl(expr.param, old, new)
    return expr
  } else if expr.type == "value" {
    expr.name = new
    return expr
  }
}

#let alpha-conversion(expr, new) = {
  if type(new) != str {
    panic("New parameter name has to be of type str")
  }

  parse-literal(new.codepoints())

  if expr.type != "abstraction" {
    panic("Can only apply λ-Calculus alpha-conversion on abstraction, got: '" + expr.type + "'")
  }

  if free-vars(expr).contains(new) {
    panic("Cannot apply λ-Calculus alpha-conversion (new variable name '" + new + "' already bound): '" + expr-to-str(expr) + "'")
  }

  let old = expr.param
  expr.param = new

  return alpha-conversion-impl(expr, old, new)
}

#let beta-reduction-impl(expr, param, value) = {
  if expr.type == "value" {
    if expr.name == param {
      return value
    } else {
      return expr
    }
  } else if expr.type == "application" {
    expr.fn = beta-reduction-impl(expr.fn, param, value)
    expr.param = beta-reduction-impl(expr.param, param, value)
    return expr
  } else if expr.type == "abstraction" {
    if expr.param == param {
      return expr
    } else {
      if expr.param in free-vars(value) {
        panic("Cannot apply λ-Calculus beta-reduction (free variable '" + expr.param + "' would be bound): '" + expr-to-str(expr) + "'")
      } else {
        expr.body = beta-reduction-impl(expr.body, param, value)
        return expr
      }
    }
  }
}

#let beta-reduction(expr) = {
  if expr.type != "application" {
    panic("Can only apply λ-Calculus beta-reduction on applications, got: '" + expr.type + "'")
  }

  if expr.fn.type != "abstraction" {
    panic("Can only apply λ-Calculus beta-reduction on applications on abstractions, was: '" + expr.fn.type + "'")
  }

  return beta-reduction-impl(expr.fn.body, expr.fn.param, expr.param)
}

#let eta-reduction(expr) = {
  if expr.type != "abstraction" {
    panic("Can only apply λ-Calculus eta-reduction on abstractions, got: '" + expr.type + "'")
  }

  if expr.body.type != "application" {
    panic("Can only apply λ-Calculus eta-reduction on abstractions with an application body, got: '" + expr.body.type + "'")
  }

  if expr.body.param.type != "value" or expr.body.param.name != expr.param {
    panic("Can only apply λ-Calculus eta-reduction on abstractions with an application body with the abstraction variable on the right side, got: '" + expr.body.type + "'")
  }

  return expr.body.fn
}

#let normalize-is-reducable(expr) = {
  if expr.type == "value" {
    return false
  } else if expr.type == "application" {
    if expr.fn.type == "abstraction" {
      return true
    } else {
      return normalize-is-reducable(expr.fn) or normalize-is-reducable(expr.param)
    }
  } else if expr.type == "abstraction" {
    return normalize-is-reducable(expr.body)
  }
}

#let normalize-reduce(expr) = {
  if expr.type == "value" {
    return expr
  } else if expr.type == "application" {
    if expr.fn.type == "abstraction" {
      return beta-reduction(expr)
    } else {
      if normalize-is-reducable(expr.fn) {
        expr.fn = normalize-reduce(expr.fn)
        return expr
      } else {
        expr.param = normalize-reduce(expr.param)
        return expr
      }
    }
  } else if expr.type == "abstraction" {
    expr.body = normalize-reduce(expr.body)
    return expr
  }
}

#let normalization-steps(expr) = {
  let steps = (expr,)
  while normalize-is-reducable(expr) {
    expr = normalize-reduce(expr)
    if expr in steps {
      panic("λ-Calculus expression not normalizable")
    }
    steps.push(expr)
  }
  return steps
}

#let normalize(expr) = {
  return normalization-steps(expr).last()
}

#let is-normalizable(expr) = {
  let prev = (expr,)
  while normalize-is-reducable(expr) {
    expr = normalize-reduce(expr)
    if expr in prev {
      return false
    }
    prev.push(expr)
  }
  return true
}

#let is-normalform(expr) = {
  if is-normalizable(expr) {
    return normalize(expr) == expr
  } else {
    return false
  }
}

#let count-binds(expr) = {
  if expr.type == "application" {
    return count-binds(expr.fn) + count-binds(expr.param)
  } else if expr.type == "abstraction" {
    return 1 + count-binds(expr.body)
  } else if expr.type == "value" {
    return 0
  }
}

#let tag(
  expr,
  bound-ranks: (:),
  index: 0,
) = {
  let _tag(expr, bound-ranks, index) = tag(
    expr,
    bound-ranks: bound-ranks,
    index: index,
  )

  if expr.type == "value" {
    if expr.name in bound-ranks {
      expr.insert("index", bound-ranks.at(expr.name))
    }

    return expr
  } else if expr.type == "application" {
    expr.fn = _tag(expr.fn, bound-ranks, index)
    expr.param = _tag(expr.param, bound-ranks, index + count-binds(expr.fn))

    return expr
  } else if expr.type == "abstraction" {
    bound-ranks.insert(expr.param, index)
    expr.insert("index", index)
    expr.body = _tag(expr.body, bound-ranks, index + 1)

    return expr
  } else {
    panic("Not a valid λ-Calculus type: '" + expr.type + "'")
  }
}