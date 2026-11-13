#import "@preview/parsely:0.1.1"
#import "utility.typ"
#import "utility-display.typ"
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
  } else if head == "log10" or head == "log" {
    operations.log(args.first(), slots.at("base", default: operations.normalise-constant(10)))
  } else if head == "sin" {
    operations.sin(args.first())
  } else if head == "cos" {
    operations.cos(args.first())
  } else if head == "tan" {
    operations.tan(args.first())
  } else if head == "asin" or head == "arcsin" {
    operations.asin(args.first())
  } else if head == "acos" or head == "arccos" {
    operations.acos(args.first())
  } else if head == "atan" or head == "arctan" {
    operations.atan(args.first())
  } else {
    panic(head)
  }
}

#let calculate-tree(tree, ..values) = {
  let variables = values.named()
  let result = parsely.walk(
    tree,
    post: it => apply-operations(it, variables),
  )
  result.boundary = true
  utility-display.display-info(result)
}

#let calculate-symbolica(tree, ..values) = {
  return [hello]
}
