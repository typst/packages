#import "utility.typ"
#import "@preview/zero:0.7.0"

#let _method-prec-table = (add: 1, sub: 1, neg: 2, mul: 2.5, div: 2.5)
#let _method-prec(value) = {
  let op = value.at("source", default: none)
  if op == none { return 1000 }
  _method-prec-table.at(op.head, default: 1000)
}

#let variable(value, show-error: true) = {
  value = utility.normalise-quantity(value)

  if show-error == false {
    let args = value.at("args", default: none)
    let round = value.at("round", default: none)
    if round == none and args != none {
      value.round = args.named().at("round", default: none)
      round = value.round
    }
    if round != none {
      value.round.precision = calc.min(
        {
          let u = value.round.at("uncertainty-precision", default: 15)
          if type(u) == dictionary { u = u.places }
          u
        },
        value.round.at("precision", default: 15),
        value.at("pm", default: (none, range(15))).at(1).len(),
      )
      let x = value.round.remove("uncertainty-precision", default: none)
    }
    if args != none {
      let named = args.named()
      let x = named.remove("round", default: none)
      value.args = arguments(args.pos(), named)
    }
    value.info.pm = none
  }
  let x = value.remove("source", default: none)
  utility.display(value)
}

#let method(value, show-error: false, depth: none, frozen: false) = {
  let _method-wrap(value, min-prec, show-error: false, depth: none, frozen: false) = {
    let rendered = method(value, show-error: show-error, depth: depth, frozen: frozen)
    if _method-prec(value) < min-prec { $(#rendered)$ } else { rendered }
  }
  value = utility.normalise-quantity(value)

  let is-boundary = value.at("boundary", default: false)
  let free = frozen and not is-boundary
  let expand = value.at("source", default: none) != none and (free or depth == none or depth > 0)

  let child-depth = if depth == none {
    none
  } else if free {
    depth
  } else {
    depth - 1
  }
  let child-frozen = frozen or is-boundary

  if expand {
    let operation = value.source.head
    if operation == "add" {
      $#value.source.data.map(x => _method-wrap(x, 1, show-error: show-error, depth: child-depth, frozen: child-frozen)).join($+$)$
    } else if operation == "sub" {
      let (a, terms) = value.source.data
      let rest = terms
        .map(t => $- #_method-wrap(t, 2, show-error: show-error, depth: child-depth, frozen: child-frozen)$)
        .join()
      $#_method-wrap(a, 1, show-error: show-error, depth: child-depth, frozen: child-frozen) #rest$
    } else if operation == "neg" {
      $- #_method-wrap(value.source.data, 2, show-error: show-error, depth: child-depth, frozen: child-frozen)$
    } else if operation == "abs" {
      $abs(#method(value.source.data, show-error: show-error, depth: child-depth, frozen: child-frozen))$
    } else if operation == "mul" {
      context {
        let product = zero.impl.num-state.get().product
        $#value.source.data.map(x => _method-wrap(x, 2.5, show-error: show-error, depth: child-depth, frozen: child-frozen)).join(product)$
      }
    } else if operation == "div" {
      let values = value.source.data.map(x => method(
        x,
        show-error: show-error,
        depth: child-depth,
        frozen: child-frozen,
      ))
      $#values.at(0)/#values.at(1)$
    } else if operation == "pow" {
      let (base, exponent) = value.source.data
      if utility.as-float(base) == calc.e {
        $e^(#method(exponent, show-error: show-error, depth: child-depth, frozen: child-frozen))$
      } else {
        $#_method-wrap(base, 3, show-error: show-error, depth: child-depth, frozen: child-frozen)^(#method(exponent, show-error: show-error, depth: child-depth, frozen: child-frozen))$
      }
    } else if operation == "root" {
      let (radicand, index) = value.source.data
      if utility.as-float(index) == 2 {
        $sqrt(#method(radicand, show-error: show-error, depth: child-depth, frozen: child-frozen))$
      } else {
        $root(#method(index, show-error: show-error, depth: child-depth, frozen: child-frozen), #method(radicand, show-error: show-error, depth: child-depth, frozen: child-frozen))$
      }
    } else if operation == "log" {
      let (val, base) = value.source.data
      if utility.as-float(base) == calc.e {
        $ln(#method(val, show-error: show-error, depth: child-depth, frozen: child-frozen))$
      } else {
        $log_(#method(base, show-error: show-error, depth: child-depth, frozen: child-frozen))(#method(val, show-error: show-error, depth: child-depth, frozen: child-frozen))$
      }
    } else if operation == "sin" {
      $sin(#method(value.source.data, show-error: show-error, depth: child-depth, frozen: child-frozen))$
    } else if operation == "cos" {
      $cos(#method(value.source.data, show-error: show-error, depth: child-depth, frozen: child-frozen))$
    } else if operation == "tan" {
      $tan(#method(value.source.data, show-error: show-error, depth: child-depth, frozen: child-frozen))$
    } else if operation == "asin" {
      $arcsin(#method(value.source.data, show-error: show-error, depth: child-depth, frozen: child-frozen))$
    } else if operation == "acos" {
      $arccos(#method(value.source.data, show-error: show-error, depth: child-depth, frozen: child-frozen))$
    } else if operation == "atan" {
      $arctan(#method(value.source.data, show-error: show-error, depth: child-depth, frozen: child-frozen))$
    }
  } else {
    variable(value, show-error: show-error)
  }
}

#let method-result(value, show-error: false, depth: none, ..args) = {
  value = utility.normalise-quantity(value)
  math.equation(
    $
      #method(value, show-error: show-error, depth: depth) = #variable(value, show-error: show-error)
    $,
    ..args,
  )
}

#let error(value) = {
  value = utility.normalise-quantity(value)
  let info = if value.info.pm == none or value.info.pm == () {
    (
      int: "0",
      frac: "",
      sign: "+",
      pm: none,
      e: none,
    )
  } else {
    (
      int: value.info.pm.at(0),
      frac: value.info.pm.at(1),
      sign: "+",
      pm: none,
      e: value.info.e,
    )
  }
  let round = value.at("round", default: none)
  if round == none and value.at("args", default: none) != none {
    round = value.args.named().at("round", default: none)
  }
  round = if (
    round != none and round.at("uncertainty-precision", default: none) != none
  ) {
    let precision = round.uncertainty-precision
    if type(precision) == dictionary { precision = precision.places }
    (
      precision: precision,
      mode: round.mode,
    )
  }
  utility.display((info: info, unit: value.at("unit", default: none), round: round))
}

#let rss(errors) = {
  context {
    let product = zero.impl.num-state.get().product
    $sqrt(#errors.map(t => $#if t.count != 1 { $#t.count product$ } (#t.error)^2$).join($+$))$
  }
}

#let _deduplicate-errors(errors, consider-value: true) = {
  let errors = errors.filter(x => (
    not x.at("constant", default: false) and utility.as-uncertainty(x) not in (none, 0)
  ))
  let dedup-errors = errors.dedup(key: x => if consider-value {
    (utility.as-uncertainty(x), utility.as-float(x))
  } else { utility.as-uncertainty(x) })
  dedup-errors = if dedup-errors.len() != errors.len() {
    dedup-errors.map(x => (
      count: errors.filter(y => utility.as-uncertainty(y) == utility.as-uncertainty(x)).len(),
      error: x,
    ))
  } else {
    dedup-errors.map(x => (count: 1, error: x))
  }
  dedup-errors
}

#let _has-error(x) = not x.at("constant", default: false) and utility.as-uncertainty(x) not in (none, 0)

#let error-method(value, depth: none, frozen: false) = {
  value = utility.normalise-quantity(value)

  let is-boundary = value.at("boundary", default: false)
  let free = frozen and not is-boundary
  let expand = value.at("source", default: none) != none and (free or depth == none or depth > 0)

  let child-depth = if depth == none {
    none
  } else if free {
    depth
  } else {
    depth - 1
  }
  let child-frozen = frozen or is-boundary

  if expand {
    let operation = value.source.head
    if operation == "add" or operation == "sub" {
      let errors = _deduplicate-errors(value.source.data, consider-value: false)
      if errors.len() == 0 { return $0$ }
      rss(errors.map(x => (count: x.count, error: error-method(x.error, depth: child-depth, frozen: frozen))))
    } else if operation == "abs" or operation == "neg" {
      error-method(value.source.data, depth: child-depth, frozen: frozen)
    } else if operation == "mul" or operation == "div" {
      let errors = _deduplicate-errors(value.source.data)
      if errors.len() == 0 { return $0$ }
      context {
        let product = zero.impl.num-state.get().product
        $#variable(value, show-error: false) product #rss(errors.map(x => (count: x.count, error: $#error-method(x.error, depth: child-depth, frozen: frozen)/ #variable(x.error, show-error: false)$)))$
      }
    } else if operation == "pow" {
      let (base, exponent) = value.source.data
      let terms = ()
      if _has-error(base) {
        terms.push((
          count: 1,
          error: context {
            let product = zero.impl.num-state.get().product
            $#variable(exponent, show-error: false) product #variable(value, show-error: false) product #error-method(base, depth: child-depth, frozen: frozen)/#variable(base, show-error: false)$
          },
        ))
      }
      if _has-error(exponent) {
        terms.push((
          count: 1,
          error: $#variable(value, show-error: false) dot ln(#variable(base, show-error: false)) dot #error-method(exponent, depth: child-depth, frozen: frozen)$,
        ))
      }
      if terms.len() == 0 { return $0$ }
      rss(terms)
    } else if operation == "root" {
      let (radicand, index) = value.source.data
      let terms = ()
      if _has-error(radicand) {
        terms.push((
          count: 1,
          error: context {
            let product = zero.impl.num-state.get().product
            $#variable(index, show-error: false) product #variable(value, show-error: false) product #error-method(radicand, depth: child-depth, frozen: frozen)/#variable(radicand, show-error: false)$
          },
        ))
      }
      if _has-error(index) {
        terms.push((
          count: 1,
          error: $#variable(value, show-error: false) dot ln(#variable(radicand, show-error: false)) dot #error-method(index, depth: child-depth, frozen: frozen)$,
        ))
      }
      if terms.len() == 0 { return $0$ }
      rss(terms)
    } else if operation == "log" {
      let (val, base) = value.source.data
      let terms = ()
      if _has-error(val) {
        terms.push((
          count: 1,
          error: $#error-method(val, depth: child-depth, frozen: frozen) / (#variable(val, show-error: false) dot ln(#variable(base, show-error: false)))$,
        ))
      }
      if _has-error(base) {
        terms.push((
          count: 1,
          error: $#variable(value, show-error: false) dot #error-method(base, depth: child-depth, frozen: frozen) / (#variable(base, show-error: false) dot ln(#variable(base, show-error: false)))$,
        ))
      }
      if terms.len() == 0 { return $0$ }
      rss(terms)
    } else if operation == "sin" {
      if not _has-error(value.source.data) { return $0$ }
      $abs(cos(#variable(value.source.data, show-error: false))) dot #error-method(value.source.data, depth: child-depth, frozen: frozen)$
    } else if operation == "cos" {
      if not _has-error(value.source.data) { return $0$ }
      $abs(sin(#variable(value.source.data, show-error: false))) dot #error-method(value.source.data, depth: child-depth, frozen: frozen)$
    } else if operation == "tan" {
      if not _has-error(value.source.data) { return $0$ }
      $#error-method(value.source.data, depth: child-depth, frozen: frozen) / cos^2(#variable(value.source.data, show-error: false))$
    } else if operation == "asin" or operation == "acos" {
      if not _has-error(value.source.data) { return $0$ }
      $#error-method(value.source.data, depth: child-depth, frozen: frozen) / sqrt(1 - #variable(value.source.data, show-error: false)^2)$
    } else if operation == "atan" {
      if not _has-error(value.source.data) { return $0$ }
      $#error-method(value.source.data, depth: child-depth, frozen: frozen) / (1 + #variable(value.source.data, show-error: false)^2)$
    }
  } else {
    error(value)
  }
}

#let error-method-result(value, depth: none, ..args) = {
  value = utility.normalise-quantity(value)
  math.equation(
    $
      #error-method(value, depth: depth) = #error(value)
    $,
    ..args,
  )
}

#let prec-table = (add: 1, sub: 1, neg: 2, pos: 2, mul: 2.5, dot: 2.5, times: 2.5)
#let prec(node) = if type(node) == dictionary { prec-table.at(node.head, default: 1000) } else { 1000 }

#let signed-add-term(term) = {
  if type(term) == dictionary and term.head == "neg" {
    (sign: "-", node: term.args.at(0), force-parens: false)
  } else {
    (sign: "+", node: term, force-parens: false)
  }
}
#let signed-sub-term(term) = {
  if type(term) == dictionary and term.head == "neg" {
    (sign: "+", node: term.args.at(0), force-parens: false)
  } else if type(term) == dictionary and term.head in ("add", "sub") {
    (sign: "-", node: term, force-parens: true)
  } else {
    (sign: "-", node: term, force-parens: false)
  }
}

#let join-signed(first, rest) = {
  let piece(t) = if t.force-parens { $(#equation(t.node))$ } else { wrap(t.node, 1) }
  let out = if first.sign == "-" { $- #piece(first)$ } else { piece(first) }
  for t in rest {
    out = if t.sign == "-" { $#out - #piece(t)$ } else { $#out + #piece(t)$ }
  }
  out
}

#let fn-names = (asin: "arcsin", acos: "arccos", atan: "arctan")
#let fn-call(head, value) = {
  let arg = wrap(value, 0)
  if head in fn-names { $#math.op(fn-names.at(head))(arg)$ } else { $#math.op(head)(arg)$ }
}

#let equation(tree) = {
  let wrap(node, min-prec) = {
    let rendered = equation(node)
    if prec(node) < min-prec { $(#rendered)$ } else { rendered }
  }
  if type(tree) == array { return tree.map(equation) }
  if type(tree) != dictionary { return tree }

  let head = tree.head
  let args = tree.at("args", default: ())
  let slots = tree.at("slots", default: (:))

  if head == "eq" {
    return $#equation(args.at(0)) = #equation(args.at(1))$
  }

  if head == "add" {
    let terms = args.map(signed-add-term)
    return join-signed(terms.first(), terms.slice(1))
  }
  if head == "sub" {
    let a = wrap(args.at(0), 1)
    let terms = args.slice(1).map(signed-sub-term)
    let out = a
    for t in terms {
      let piece = if t.force-parens { $(#equation(t.node))$ } else { wrap(t.node, 1) }
      out = if t.sign == "-" { $#out - #piece$ } else { $#out + #piece$ }
    }
    return out
  }
  if head == "pos" {
    return wrap(args.at(0), 2)
  }
  if head == "neg" {
    let inner = args.at(0)
    if type(inner) == dictionary and inner.head == "neg" {
      return equation(inner.args.at(0))
    }
    return $- #wrap(inner, 2)$
  }

  if head in ("mul", "dot", "times") {
    let sym = if head == "dot" { $dot$ } else { $times$ }
    let pieces = args.map(f => wrap(f, 2.5))
    let out = pieces.first()
    for p in pieces.slice(1) { out = $#out #sym #p$ }
    return out
  }

  if head == "frac" {
    return $frac(#equation(slots.num), #equation(slots.denom))$
  }

  if head == "pow" {
    let base = wrap(args.at(0), 4)
    let exp = equation(args.at(1))
    return $#base^(#exp)$
  }

  if head == "root" {
    let radicand = equation(slots.radicand)
    let content-to-str = utility.to-str(slots.index)
    let number-match = content-to-str.match(utility.valid-number-regex)
    if float(number-match.text) == 2 {
      return $sqrt(#radicand)$
    }
    return $root(#equation(slots.index), #radicand)$
  }
  if head == "sqrt" {
    return $sqrt(#equation(slots.radicand))$
  }
  if head in ("abs", "abs-bars") {
    return $abs(#equation(slots.value))$
  }

  if head in ("log10", "log", "log-br", "log10-br") {
    let value = equation(args.at(0))
    let base = slots.at("base", default: none)
    if base == none or as-literal-int(base) == 10 {
      return $log(#value)$
    }
    if utility.to-str(base) == "e" {
      return $ln(#value)$
    }
    return $log_(#equation(base))(#value)$
  }
  if head == "ln" {
    return $ln(#equation(args.at(0)))$
  }
  if head == "exp" {
    return $e^(#equation(args.at(0)))$
  }

  if head in ("sin", "cos", "tan", "asin", "acos", "atan") {
    return fn-call(head, args.at(0))
  }

  if head == "group" {
    return equation(slots.expr)
  }

  panic("equation: no rendering defined for operation '" + head + "'")
}
