#import "match.typ": *
#import "util.typ": *


// parse tokens as one of the operators defined in the grammar
// returning a tuple of the operator and the remaining tokens.
// if no operator was matched, the operator is `none`
#let parse-op(tokens, grammar, ctx: (:)) = {

  // test whether tokens possibly begin with given operator
  // or return false if no match
  let match-op(spec, tokens) = {
    let kind = spec.keys().first()
    let pattern = as-array(unwrap(spec.remove(kind)))

    // disallow leading with infix/postfix
    if ctx.at("left", default: none) == none {
      if kind in ("infix", "postfix") { return false }
    }

    let m = match-sequence(pattern, tokens, match: match)
    if m == false { return false }
    let (slots, tokens-remaining) = m
    let op = (kind: kind, slots: slots)
    
    if kind in ("prefix", "infix", "postfix") {
      op.insert("prec", spec.remove("prec", default: 0))
      if kind == "infix" {
        op.insert("assoc", spec.remove("assoc", default: alignment.left))
      }
    }

    if "rewrite" in spec {
      op.insert("rewrite", spec.remove("rewrite"))
    }

    if "guard" in spec {
      if not (spec.guard)(slots) { return false }
    }

    return (op, tokens-remaining)
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
  }

  (op, tokens)
}


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
// summation variable and limits. The entire pattern is
// treated as one "token" in and subsequent tokens are
// consumed as arguments to a prefix operator.

/// Parse content into a tree according to a specified grammar, returning a dictionary `(tree, rest)` with the parsed syntax tree and any trailing content that failed to parse.
/// 
/// ```example
/// let (tree, rest) = parsely.parse($f(x) = x^2/2$, parsely.common.arithmetic)
/// ```
/// 
/// Not all content in the syntax tree needs to be parsed; content that fails to be parsed is left as is, which may result in a "partially parsed" syntax tree with content in some nodes.
/// 
/// When is called on some content, the parser tries to match the content with operators defined in the grammar.
/// If successful, the parser recursively descends into arguments and tries to parse those.
/// If parsing slot arguments fails, the slot is simply left as content in the resulting syntax tree.
/// If parsing a positional argument fails, what was parsed so far is returned in `tree` and remaining content is returned in `rest`.
#let parse(it, grammar, min-prec: -float.inf) = {

  let tokens = flatten-sequence(as-array(unwrap(it)))
  if tokens.len() == 0 { return (tree: none, rest: none) }

  let make-node(op, args: (), old-tokens) = {
    let node = (head: op.name, args: args, slots: op.slots)
    let rewrite-rule = op.at("rewrite", default: it => it)

    node = rewrite-rule(node)
    // rewrite rules may return nodes, or more content to be parsed
    
    if type(node) == content {
      // panic(node)
      let (tree, rest) = parse(node, grammar, min-prec: -float.inf)
      return tree
    }


    // try to parse pattern slots
    for (key, slot) in node.slots {
      if type(slot) != content { continue }

      // danger of infinite recursion
      // do not parse a slot's content if it is the same as the content that
      // gave rise to this slot in the first place
      let m = match-sequence(slot, old-tokens, match: match)
      if m != false {
        let (_, rest) = m
        if rest.len() == 0 { continue }
      }

      let (tree, rest) = parse(slot, grammar, min-prec: -float.inf)
      // if the whole slot doesn't parse to the end, keep unparsed
      if rest != none { continue }
      node.slots.at(key) = tree
    }

    // sometimes slots are stored as positional arguments
    // e.g., for some content functions
    if "args" in node {
      for (i, arg) in node.args.enumerate() {
        if type(arg) != content { continue }
        let (tree, rest) = parse(arg, grammar, min-prec: -float.inf)
        // if the whole arg doesn't parse to the end, keep unparsed
        if rest != none { continue }
        node.args.at(i) = tree
      }
    }

    node

  }


  let left = none
  let old-tokens = tokens
  let (op, tokens) = parse-op(tokens, grammar, ctx: (left: left))

  if op == none {
    // leading token(s) did not match any operator
    // so we consume as a literal token
    while true {
      if tokens.len() == 0 { return (tree: none, rest: none) }
      (left, ..tokens) = tokens
      if not util.is-space(left) { break }
    }

  } else if op.kind == "match" {
    left = make-node(op, args: (), old-tokens)
  
  // prefix
  } else if op.kind == "prefix" {
    let (tree: right, rest) = parse(tokens, grammar, min-prec: op.prec)
    left = make-node(op, args: (right,), old-tokens)
    tokens = as-array(rest) // consumed op + right
  }

  // infix and postfix
  // we found a left node and seek an operator that can consume it

  let i = 0
  while tokens.len() > 0 {
    assert(type(tokens) == array)
    if i > 200 {
      panic("seems to be infinite", tokens)
    }
    i += 1

    let (subop, subtokens) = parse-op(tokens, grammar, ctx: (left: left))

    if subop == none {
      // encountered an atomic node directly following the left node
      // these two nodes are not joined by an operator
      // leave unparsed, the expression is completed early
      break

    } else if subop.kind == "match" {
      // encountered a match node which does not consume any left nodes
      // leave unparsed, the expression is completed early
      break

    } else if subop.kind == "prefix" {
      // we have an unconsumed node to the left of a prefix operator...
      // this is malformed but it is better to exit than to panic
      break
    
    } else if subop.kind == "postfix" {
      // we found a postfix operator to consume the left node
      if subop.prec < min-prec { break }
      left = make-node(subop, args: (left,), old-tokens)
      tokens = subtokens // consumed op
      continue

    } else if subop.kind == "infix" {
      // we found an infix operator to consume the left node
      // but we must continue to find a right node (or nodes if associative)

      // nothing left for right of infix
      // leave operator unparsed
      if subtokens.len() == 0 { break }

      if subop.prec < min-prec { break }
      
      let assoc = subop.at("assoc", default: alignment.left)
      if assoc == true {
        // n-ary
        left = make-node(subop, args: (left,), ())
        let abort = false
        while true {
          let (tree: right, rest) = parse(subtokens, grammar, min-prec: subop.prec + 1e-3)
          rest = as-array(rest)

          // don't allow rhs of operator to be none
          if right == none { break }

          left.args.push(right)
          tokens = rest // consumed op + right

          // if followed by same operator, absorb
          let (next-op, rest) = parse-op(rest, grammar, ctx: (left: right))
          if next-op == none { break }
          if next-op.name != subop.name { break }
          if next-op.prec < min-prec { break }
          subtokens = rest
        }
        if abort { break }
        continue
      } else {
        // binary
        let right-prec = if assoc == alignment.left { subop.prec + 1e-3 } else { subop.prec }
        let (tree: right, rest) = parse(subtokens, grammar, min-prec: right-prec)
        
        // don't allow rhs of operator to be none
        if right == none { break }

        left = make-node(subop, args: (left, right), ())

        tokens = as-array(rest)
        continue
      }

    } else {
      panic(op)
    }
  }
  
  return (tree: left, rest: tokens.join())
}
