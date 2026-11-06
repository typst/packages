#import "match.typ": *
#import "util.typ": *

// This is a Pratt parser
// which handles prefix, infix and postfix operators
// of variable precedence using recursive descent.
// 
// Tokens may be symbols or entire subexpressions,
// to support the nested structures produced by math mode.
// 
// Multi-token operators are supported and may use
// pattern matching with capture groups.
// For example, $sum_(#var = #lo)^#hi$ may be parsed as a
// prefix operator with "slots" (capture groups) for the
// summation variable and limits.
#let parse(it, grammar, min-prec: -float.inf) = {

  let tokens = flatten-sequence(as-array(unwrap(it)))
  if tokens.len() == 0 { return (tree: none, rest: none) }

  // parse tokens as one of the operators defined in the grammar
  // or return false if no match
  let parse-op(tokens, ctx: (:)) = {

    // test whether tokens possibly begin with given operator
    let match-op(spec, tokens) = {
      if type(spec) == function {
        let fn = spec
        let m = match-sequence((fn,), tokens, match: match)
        if m == false { return false }
        let (slots, tokens) = m

        let args = util.element-fields-to-arguments(fn, slots)

        let op = (
          kind: function,
          fn: spec,
          args: args.pos(),
          slots: args.named(),
        )
        return (op, tokens)
      }

      let (kind, pattern) = spec.pairs().first()
      let pattern = as-array(unwrap(pattern))

      // disallow leading with infix/postfix
      if ctx.at("left", default: none) == none {
        if kind in ("infix", "postfix") { return false }
      }

      let m = match-sequence(pattern, tokens, match: match)
      if m == false { return false }
      let (slots, tokens) = m
      let op = (
        kind: kind,
        ..if kind != "match" { (prec: spec.at("prec", default: 0)) },
        ..if kind == "infix" { (assoc: spec.at("assoc", default: alignment.left)) },
        slots: slots,
      )
      return (op, tokens)
    }

    // find all possible operators matching leading tokens
    let matching-ops = ()
    for (name, spec) in grammar {
      let m = match-op(spec, tokens)
      if m == false { continue }
      let (op, tokens) = m
      op.name = name        
      matching-ops.push((op, tokens))
      break // if selecting first break early
      // may extend this in future
    }

    // choose one operator
    let old-tokens = tokens
    let (op, tokens) = matching-ops.at(0, default: (none, tokens))

    
    // if no operators match, interpret tokens as literal
    if op == none {
      // drop whitespace
      while true {
        if tokens.len() == 0 { return (none, none) }
        if util.is-space(tokens.first()) {
          tokens = tokens.slice(1)
        } else { break }
      }

      let it = tokens.first()

      // recurse into content
      if type(it) == content and false {
        let kind = repr(it.func())
        if kind not in ("symbol", "text") {
          tokens = tokens.slice(1)
          let named = it.fields()
          let pos = ()
          let arg-kinds = util.content-positional-args.at(kind, default: (positional: ()))
          for n in arg-kinds.positional {
            pos.push(named.remove(n))
          }
          if "variadic" in arg-kinds {
            pos += named.remove(arg-kinds.variadic)
          }
          op = (
            name: "content",
            kind: "match",
            args: (it.func(), ..pos),
            slots: named,
          )
        }
      }
    }

    // try to parse pattern slots
    if op != none {
      for (key, slot) in op.slots {
        if type(slot) != content { continue }

        // danger of infinite recursion
        // do not parse a slot's content if it is the same as the content that
        // gave rise to this slot in the first place
        let m = match-sequence(slot, old-tokens, match: match)
        // panic(old-tokens, slot, m)
        if m != false { continue }

        let (tree, rest) = parse(slot, grammar, min-prec: -float.inf)
        // if the whole slot doesn't parse to the end, keep unparsed
        if rest != none { continue }
        op.slots.at(key) = tree
      }

      // sometimes slots are stored as positional arguments
      // e.g., for some content functions
      if "args" in op {
        for (i, arg) in op.args.enumerate() {
          if type(arg) != content { continue }
          let (tree, rest) = parse(arg, grammar, min-prec: -float.inf)
          // if the whole arg doesn't parse to the end, keep unparsed
          if rest != none { continue }
          op.args.at(i) = tree
        }
      }
    }


    (op, tokens)
  }


  let left = none
  let (op, tokens) = parse-op(tokens, ctx: (left: left))

  // consume literal token
  if op == none {
    while true {
      if tokens.len() == 0 { return (tree: none, rest: none) }
      (left, ..tokens) = tokens
      if not util.is-space(left) { break }
    }
    let _ = tokens

  } else if op.kind == function {
    left = (head: op.name, args: op.args, slots: op.slots)
    // panic(op)

  } else if op.name == "content" {
    // parsing doesn't recurse into content args??
    left = (head: "content", args: op.args, slots: op.slots)

  } else if op.kind == "match" {
    left = (head: op.name, args: (), slots: op.slots)
  
  // prefix
  } else if op.kind == "prefix" {
    let (tree: right, rest) = parse(tokens, grammar, min-prec: op.prec)
    left = (head: op.name, args: (right,), slots: op.slots)
    tokens = as-array(rest) // consumed op + right
  }



  // infix and postfix
  let i = 0
  while tokens.len() > 0 {
    assert(type(tokens) == array)
    if i > 200 {
      panic("seems to be infinite", tokens)
    }
    i += 1

    let (op, subtokens) = parse-op(tokens, ctx: (left: left))
    if op == none { break }
    
    if op.kind == "postfix" {
      if op.prec < min-prec { break }
      left = (head: op.name, args: (left,), slots: op.slots)

      tokens = subtokens // consumed op
      continue

    } else if op.kind == "infix" {

      // nothing left for right of infix
      // leave operator unparsed
      if subtokens.len() == 0 { break }

      if op.prec < min-prec { break }
      
      let assoc = op.at("assoc", default: alignment.left)
      if assoc == true {
        // n-ary
        left = (head: op.name, args: (left,), slots: op.slots)
        let abort = false
        while true {
          let (tree: right, rest) = parse(subtokens, grammar, min-prec: op.prec + 1e-3)
          rest = as-array(rest)

          // don't allow rhs of operator to be none
          if right == none { break }

          left.args.push(right)
          tokens = rest // consumed op + right

          // if followed by same operator, absorb
          let (next-op, rest) = parse-op(rest, ctx: (left: right))
          if next-op == none { break }
          if next-op.name != op.name { break }
          if next-op.prec < min-prec { break }
          subtokens = rest
        }
        if abort { break }
        continue
      } else {
        // binary
        let right-prec = if assoc == alignment.left { op.prec + 1e-3 } else { op.prec }
        let (tree: right, rest) = parse(subtokens, grammar, min-prec: right-prec)
        
        // don't allow rhs of operator to be none
        if right == none { break }

        left = (head: op.name, args: (left, right), slots: op.slots)

        tokens = as-array(rest)
        continue
      }

    } else if op.kind == "match" {
      // encountered two consecutive tokens
      // which are not joined by any operator
      // leave unparsed
      break
    }
    
    panic(op)

  }
  
  return (tree: left, rest: tokens.join())
}
