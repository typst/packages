#import "@preview/parsely:0.1.1"
#import "utility.typ"
#import "operations.typ"

#let grammar = (
  eq: (infix: $=$, prec: 0),

  add: (infix: $+$, prec: 1, assoc: true),
  sub: (infix: $-$, prec: 1),
  pos: (prefix: $+$, prec: 2),
  neg: (prefix: $-$, prec: 2),

  times: (infix: $times$, prec: 2, assoc: true),
  dot: (infix: $dot$, prec: 2),
  mul: (infix: none, prec: 2.5, assoc: true),

  group: (match: $(parsely.slot("expr*"))$),
  frac: (match: math.frac),
  abs: (match: $abs(parsely.slot("value"))$),
  abs-bars: (match: $|parsely.slot("value")|$),

  pow: (
    match: math.attach,
    guard: slots => "t" in slots,
    rewrite: ((slots,)) => {
      let (base, t, ..rest) = slots
      let base = if rest.len() == 0 { base } else { math.attach(base, ..rest) }
      (head: "pow", args: (base, t), slots: (:))
    },
  ),

  root: (match: math.root(parsely.slot("index", guard: it => it != none), parsely.slot("radicand"))),
  sqrt: (match: $sqrt(parsely.slot("radicand"))$),

  ln: (prefix: $ln$, prec: 10),
  log: (prefix: $log_parsely.slot("base")$, prec: 10),
  log10: (prefix: $log$, prec: 0),

  sin: (prefix: $sin$),
  cos: (prefix: $cos$),
  tan: (prefix: $tan$),
  arcsin: (prefix: $arcsin$),
  arccos: (prefix: $arccos$),
  arctan: (prefix: $arctan$),
  call: (match: $parsely.slot("fn") parsely.tight (parsely.slot("args*"))$),

  delta: (prefix: $delta$, prec: 3),
  Delta: (prefix: $Delta$, prec: 3),
)

#let resolve-leaf-node(it, vars) = {
  let content-to-str = utility.to-str(it)
  let variable-name = content-to-str.replace(utility.invisible-symbols, "").replace(utility.illegal-symbols, "-")
  let variable = vars.at(variable-name, default: none)
  let quantity = if variable == none {
    if variable-name == "e" {
      operations.e
    } else if variable-name == "tau" {
      operations.tau
    } else if variable-name == "pi" {
      operations.pi
    }
  } else if variable != none {
    if type(variable) == function {
      let result = variable(..vars)
      let candidate = utility.retrieve-metadata(result)
      if candidate != none {
        candidate
      } else {
        result
      }
    } else if variable == auto {
      variable
    } else {
      operations.normalise-quantity(variable)
    }
  }

  if (quantity == none) {
    let number-match = content-to-str.match(utility.valid-number-regex)
    if (number-match != none) and (number-match.start == 0) and (number-match.end == content-to-str.len()) {
      quantity = operations.normalise-constant(content-to-str)
    }
  }

  if quantity == none {
    panic(
      "please consider adding a variable called \"" + variable-name + "\"",
      "cannot evaluate symbol: " + repr(it),
    )
  }
  quantity.boundary = true
  return quantity
}

#let apply-operations((head, args, slots), vars) = {
  if (head == "eq") {
    if type(args.at(0)) == content and type(args.at(1)) == dictionary {
      return args.at(1)
    } else if type(args.at(1)) == content and type(args.at(0)) == dictionary {
      return args.at(0)
    } else {
      panic("can't find equation branch to calculate")
    }
  }

  if head == "delta" {
    return resolve-leaf-node($delta-$ + args.first(), vars)
  } else if head == "Delta" {
    return resolve-leaf-node($Delta-$ + args.first(), vars)
  }

  if (head == "call") {
    return resolve-leaf-node(((slots.fn, [-]) + slots.values().slice(1)).join(), vars)
  }

  args = args.map(x => if type(x) == dictionary { x } else { resolve-leaf-node(x, vars) })
  slots = slots.map(x => if type(x) == dictionary { x } else { resolve-leaf-node(x, vars) })
  if head == "add" or head == "pos" {
    operations.add(args)
  } else if head == "sub" {
    operations.sub(args.first(), args.slice(1))
  } else if head == "neg" {
    operations.neg(args.first())
  } else if head == "mul" or head == "dot" or head == "times" {
    operations.mul(args)
  } else if (head == "frac") {
    operations.div(slots.num, slots.denom)
  } else if head == "abs" or head == "abs-bars" {
    operations.abs(slots.value)
  } else if head == "pow" {
    operations.pow(..args)
  } else if head == "exp" {
    operations.exp(args.first())
  } else if head == "group" {
    slots.expr
  } else if head == "root" {
    operations.root(slots.radicand, slots.index)
  } else if head == "sqrt" {
    operations.sqrt(slots.radicand)
  } else if head == "ln" {
    operations.ln(..args)
  } else if head == "log10" or head == "log" or head == "log-br" or head == "log10-br" {
    operations.log(args.first(), slots.at("base", default: operations.normalise-constant(10)))
  } else if head == "sin" {
    operations.sin(args.first())
  } else if head == "cos" {
    operations.cos(args.first())
  } else if head == "tan" {
    operations.tan(args.first())
  } else if head == "asin" {
    operations.asin(args.first())
  } else if head == "acos" {
    operations.acos(args.first())
  } else if head == "atan" {
    operations.atan(args.first())
  } else {
    panic(head)
  }
}


#let invert(node, others, path) = {
  let (head, args, slots) = node

  if head == "add" or head == "pos" {
    let (i, terms) = (path, args)
    let siblings = terms.enumerate().filter(x => x.at(0) != i).map(x => x.at(1))
    let new-others = others.map(o => (head: "sub", args: (o,) + siblings, slots: (:)))
    return (new-others, terms.at(i))
  }

  if head == "sub" {
    let (i, terms) = (path, args)
    if i == 0 {
      let new-others = others.map(o => (head: "add", args: (o,) + terms.slice(1), slots: (:)))
      return (new-others, terms.at(0))
    } else {
      let a = terms.at(0)
      let siblings = terms.slice(1).enumerate().filter(x => x.at(0) != i - 1).map(x => x.at(1))
      let new-others = others.map(o => (head: "sub", args: (a, o) + siblings, slots: (:)))
      return (new-others, terms.at(i))
    }
  }

  if head == "neg" {
    return (others.map(o => (head: "neg", args: (o,), slots: (:))), args.at(0))
  }

  if head in ("mul", "dot", "times") {
    let (i, factors) = (path, args)
    let siblings = factors.enumerate().filter(x => x.at(0) != i).map(x => x.at(1))
    let sibling-tree = if siblings.len() == 1 { siblings.at(0) } else { (head: "mul", args: siblings, slots: (:)) }
    let new-others = others.map(o => (head: "frac", args: (), slots: (num: o, denom: sibling-tree)))
    return (new-others, factors.at(i))
  }

  if head == "frac" {
    let (num, denom) = (slots.num, slots.denom)
    if path == "num" {
      return (others.map(o => (head: "mul", args: (o, denom), slots: (:))), num)
    } else {
      return (others.map(o => (head: "frac", args: (), slots: (num: num, denom: o))), denom)
    }
  }

  if head == "pow" {
    let (base, exponent) = (args.at(0), args.at(1))
    if path == 0 {
      let content-to-str = utility.to-str(exponent)
      let number-match = content-to-str.match(utility.valid-number-regex)
      let new-others = if (
        (number-match != none)
          and (number-match.start == 0)
          and (number-match.end == content-to-str.len())
          and (calc.rem(float(number-match.text), 2) == 0)
      ) {
        others
          .map(o => (
            (head: "root", args: (), slots: (radicand: o, index: exponent)),
            (head: "neg", args: ((head: "root", args: (), slots: (radicand: o, index: exponent)),), slots: (:)),
          ))
          .flatten()
      } else {
        others.map(o => (head: "root", args: (), slots: (radicand: o, index: exponent)))
      }

      return (new-others, base)
    } else {
      if utility.to-str(base) == "e" {
        return (others.map(o => (head: "ln", args: (o,), slots: (:))), exponent)
      }
      return (others.map(o => (head: "log", args: (o,), slots: (base: base))), exponent)
    }
  }

  if head == "root" {
    let (radicand, index) = (slots.radicand, slots.index)
    return (others.map(o => (head: "pow", args: (o, index), slots: (:))), radicand)
  }

  if head == "sqrt" {
    let radicand = slots.radicand
    let new-others = others
      .map(o => (
        (head: "pow", args: (o, [2]), slots: (:)),
        (head: "pow", args: ((head: "neg", args: (o,), slots: (:)), [2]), slots: (:)),
      ))
      .flatten()
    return (new-others, radicand)
  }

  if head in ("abs", "abs-bars") {
    let value = slots.value
    return (others.map(o => (o, (head: "neg", args: (o,), slots: (:)))).flatten(), value)
  }

  if head in ("log10", "log", "log-br", "log10-br") {
    let value = args.at(0)
    let base = slots.at("base", default: [10])
    if path == "value" {
      return (others.map(o => (head: "pow", args: (base, o), slots: (:))), value)
    } else {
      let new-others = others.map(o => (
        head: "pow",
        args: (value, (head: "frac", args: (), slots: (num: [1], denom: o))),
        slots: (:),
      ))
      return (new-others, base)
    }
  }

  if head == "ln" {
    return (others.map(o => (head: "exp", args: (o,), slots: (:))), args.at(0))
  }
  if head == "exp" {
    return (others.map(o => (head: "ln", args: (o,), slots: (:))), args.at(0))
  }
  if head == "sin" {
    return (others.map(o => (head: "asin", args: (o,), slots: (:))), args.at(0))
  }
  if head == "cos" {
    return (others.map(o => (head: "acos", args: (o,), slots: (:))), args.at(0))
  }
  if head == "tan" {
    return (others.map(o => (head: "atan", args: (o,), slots: (:))), args.at(0))
  }

  if head == "group" {
    return (others, slots.expr)
  }

  panic("isolate: no inverse defined for operation '" + head + "'")
}

#let children-of(node) = {
  let (head, args, slots) = node
  if head == "eq" {
    return args.enumerate()
  }
  if head in ("add", "pos", "sub", "mul", "dot", "times") {
    return args.enumerate()
  }
  if head in ("neg", "exp", "ln", "sin", "cos", "tan") {
    return ((0, args.at(0)),)
  }
  if head in ("log10", "log", "log-br", "log10-br") {
    let entries = (("value", args.at(0)),)
    let base = slots.at("base", default: none)
    if base != none { entries += (("base", base),) }
    return entries
  }
  if head == "frac" {
    return (("num", slots.num), ("denom", slots.denom))
  }
  if head in ("abs", "abs-bars") {
    return (("value", slots.value),)
  }
  if head == "root" {
    return (("radicand", slots.radicand), ("index", slots.index))
  }
  if head == "sqrt" {
    return (("radicand", slots.radicand),)
  }
  if head == "pow" {
    return args.enumerate()
  }
  if head == "group" {
    return (("expr", slots.expr),)
  }
  panic("isolate: no argument layout defined for operation '" + head + "'")
}

#let find-paths-to-variable(node, var) = {
  if type(node) != dictionary {
    if node == var { return ((),) }
    return ()
  }
  let results = ()
  for (token, child) in children-of(node) {
    for sub-path in find-paths-to-variable(child, var) {
      results.push((token,) + sub-path)
    }
  }
  return results
}

#let peel(expr, others, path, depth) = {
  if path.len() == depth {
    return others
  }

  let (new-others, sub-expr) = invert(expr, others, path.at(depth))
  return peel(sub-expr, new-others, path, depth + 1)
}
