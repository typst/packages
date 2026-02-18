// =========================================================================
// CAS Expression Parser — Typst math string → CAS expression tree
// =========================================================================
// Parses strings like "x^2 + 3x - 1" into CAS expression trees.
// Two-phase: tokenization → recursive descent parsing.
// =========================================================================

#import "expr.typ": *

// =========================================================================
// Phase 1: Tokenizer
// =========================================================================

#let _is-digit(c) = c >= "0" and c <= "9"

#let _is-alpha(c) = {
  let code = str.to-unicode(c)
  (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
}

#let _tokenize(s) = {
  let tokens = ()
  let chars = s.clusters()
  let i = 0
  let len = chars.len()

  while i < len {
    let c = chars.at(i)

    // Skip whitespace
    if c == " " or c == "\t" or c == "\n" {
      i += 1
      continue
    }

    // Numbers
    if _is-digit(c) {
      let start = i
      while i < len and _is-digit(chars.at(i)) { i += 1 }
      if i < len and chars.at(i) == "." {
        i += 1
        while i < len and _is-digit(chars.at(i)) { i += 1 }
      }
      tokens.push((type: "num", val: chars.slice(start, i).join()))
      continue
    }

    // Identifiers
    if _is-alpha(c) {
      let start = i
      while i < len and _is-alpha(chars.at(i)) { i += 1 }
      tokens.push((type: "ident", val: chars.slice(start, i).join()))
      continue
    }

    if c == "+" or c == "-" or c == "*" or c == "/" or c == "^" or c == "_" or c == "=" {
      tokens.push((type: "op", val: c))
      i += 1
      continue
    }

    // Symbols (from content)
    if c == "π" {
      tokens.push((type: "ident", val: "pi"))
      i += 1
      continue
    }
    if c == "∑" {
      tokens.push((type: "ident", val: "sum"))
      i += 1
      continue
    }
    if c == "∏" {
      tokens.push((type: "ident", val: "product"))
      i += 1
      continue
    }
    if c == "∫" {
      tokens.push((type: "ident", val: "integral"))
      i += 1
      continue
    }
    if c == "∞" {
      tokens.push((type: "ident", val: "infinity"))
      i += 1
      continue
    }
    if c == "∂" {
      tokens.push((type: "ident", val: "diff"))
      i += 1
      continue
    }
    if c == "(" {
      tokens.push((type: "lparen", val: "("))
      i += 1
      continue
    }
    if c == ")" {
      tokens.push((type: "rparen", val: ")"))
      i += 1
      continue
    }
    if c == "," {
      tokens.push((type: "comma", val: ","))
      i += 1
      continue
    }

    i += 1 // skip unknown
  }
  tokens
}

// =========================================================================
// Phase 2: Recursive Descent Parser
// =========================================================================

#let _known-fns = (
  "sin",
  "cos",
  "tan",
  "csc",
  "sec",
  "cot",
  "arcsin",
  "arccos",
  "arctan",
  "arccsc",
  "arcsec",
  "arccot",
  "sinh",
  "cosh",
  "tanh",
  "csch",
  "sech",
  "coth",
  "arcsinh",
  "arccosh",
  "arctanh",
  "arccsch",
  "arcsech",
  "arccoth",
  "ln",
  "exp",
  "sqrt",
  "abs",
  "log",
  "log",
  "frac",
  "root",
)

#let _pk(tokens, pos) = if pos < tokens.len() { tokens.at(pos) } else { none }

#let _is-op(tokens, pos, v) = {
  let t = _pk(tokens, pos)
  t != none and t.type == "op" and t.val == v
}

#let _numval(s) = if s.contains(".") { float(s) } else { int(s) }

// All parser functions take `p` dict as last arg for mutual recursion.
// p.expr, p.term, p.unary, p.power, p.atom

#let _parse-atom(tokens, pos, p) = {
  let tok = _pk(tokens, pos)
  if tok == none { return (num(0), pos) }

  if tok.type == "num" { return (num(_numval(tok.val)), pos + 1) }

  if tok.type == "lparen" {
    let (inner, q) = (p.expr)(tokens, pos + 1, p)
    if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
    return (inner, q)
  }

  if tok.type == "ident" {
    let name = tok.val
    let next = _pk(tokens, pos + 1)

    // Sum/Product: sum_(k=1)^n expr
    if name == "sum" or name == "product" {
      if _is-op(tokens, pos + 1, "_") {
        let q = pos + 2
        // Expect '('
        let t1 = _pk(tokens, q)
        if t1 == none or t1.type != "lparen" { return (num(0), q) } // Error (advance q)
        q += 1

        // var
        let (var-expr, q2) = (p.atom)(tokens, q, p)
        
        // Extract var name checking for var OR const (e.g. "i")
        let var-name = none
        if is-type(var-expr, "var") { 
          var-name = var-expr.name 
        } else if is-type(var-expr, "const") {
           var-name = var-expr.name
        } else {
           // Error but consume tokens to avoid loop
           return (num(0), q2) 
        }
        q = q2

        // =
        if not _is-op(tokens, q, "=") { return (num(0), pos) } // Error
        q += 1

        // start
        let (start, q3) = (p.expr)(tokens, q, p)
        q = q3

        // )
        if _pk(tokens, q).type != "rparen" { return (num(0), pos) } // Error
        q += 1

        // ^
        if not _is-op(tokens, q, "^") { return (num(0), pos) } // Error
        q += 1

        // end (parse as unary to allow -1, or power?)
        // upper bound is usually an atom or power. let's use unary to be safe?
        // Actually, ^(n+1) is atom (parens). ^n is atom.
        // Let's use p.power (for ^n^2?) or p.unary.
        let (end, q4) = (p.power)(tokens, q, p)
        q = q4

        // body (binds tightly? sum x + 1 -> (sum x) + 1)
        // So parse power.
        let (body, q5) = (p.power)(tokens, q, p)

        let result = if name == "sum" {
          csum(body, var-name, start, end)
        } else {
          cprod(body, var-name, start, end)
        }
        return (result, q5)
      }
    }

    // Check for subscript: log_b(x)
    if name == "log" and _is-op(tokens, pos + 1, "_") {
      let (base, q) = (p.atom)(tokens, pos + 2, p)
      // Expect '(' next
      let next-tok = _pk(tokens, q)
      if next-tok != none and next-tok.type == "lparen" {
        let (arg, q2) = (p.expr)(tokens, q + 1, p)
        if q2 < tokens.len() and _pk(tokens, q2).type == "rparen" { q2 += 1 }
        return (log-of(base, arg), q2)
      }
      // If no '(', treat next atom as arg (log_2 x)
      let (arg, q2) = (p.atom)(tokens, q, p)
      return (log-of(base, arg), q2)
    }

    // Function call (ident followed by '(')
    if next != none and next.type == "lparen" and name in _known-fns {
      if name == "frac" {
        let (n, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "comma" { q += 1 }
        let (d, q2) = (p.expr)(tokens, q, p)
        if q2 < tokens.len() and _pk(tokens, q2).type == "rparen" { q2 += 1 }
        return (cdiv(n, d), q2)
      }
      if name == "sqrt" {
        let (arg, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
        return (pow(arg, cdiv(num(1), num(2))), q)
      }
      if name == "root" {
        // root(index, x)
        let (index, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "comma" { q += 1 }
        let (arg, q2) = (p.expr)(tokens, q, p)
        if q2 < tokens.len() and _pk(tokens, q2).type == "rparen" { q2 += 1 }
        return (pow(arg, cdiv(num(1), index)), q2)
      }
      if name == "abs" {
        let (arg, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
        return (abs-of(arg), q)
      }
      if name == "log" {
        let (first, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "comma" {
          q += 1
          let (second, q2) = (p.expr)(tokens, q, p)
          if q2 < tokens.len() and _pk(tokens, q2).type == "rparen" { q2 += 1 }
          return (log-of(first, second), q2)
        }
        if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
        return (func("ln", first), q)
      }
      if name == "exp" {
        let (arg, q) = (p.expr)(tokens, pos + 2, p)
        if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
        return (exp-of(arg), q)
      }
      // Generic function
      let (arg, q) = (p.expr)(tokens, pos + 2, p)
      if q < tokens.len() and _pk(tokens, q).type == "rparen" { q += 1 }
      return (func(name, arg), q)
    }

    // Constants
    if name == "pi" { return (const-pi, pos + 1) }
    if name == "e" { return (const-e, pos + 1) }


    return (cvar(name), pos + 1)
  }

  (num(0), pos + 1)
}

#let _parse-power(tokens, pos, p) = {
  let (base, q) = _parse-atom(tokens, pos, p)
  if _is-op(tokens, q, "^") {
    let (exp, q2) = (p.unary)(tokens, q + 1, p)
    return (pow(base, exp), q2)
  }
  (base, q)
}

#let _parse-unary(tokens, pos, p) = {
  if _is-op(tokens, pos, "-") {
    let (operand, q) = _parse-unary(tokens, pos + 1, p)
    if is-type(operand, "num") { return (num(-operand.val), q) }
    return (neg(operand), q)
  }
  if _is-op(tokens, pos, "+") {
    return _parse-unary(tokens, pos + 1, p)
  }
  _parse-power(tokens, pos, p)
}

#let _parse-term(tokens, pos, p) = {
  let (result, q) = _parse-unary(tokens, pos, p)
  while q < tokens.len() {
    if _is-op(tokens, q, "*") {
      let (right, q2) = _parse-unary(tokens, q + 1, p)
      result = mul(result, right)
      q = q2
      continue
    }
    if _is-op(tokens, q, "/") {
      let (right, q2) = _parse-unary(tokens, q + 1, p)
      result = cdiv(result, right)
      q = q2
      continue
    }
    // Implicit multiplication
    let tok = _pk(tokens, q)
    if tok.type == "num" or tok.type == "ident" or tok.type == "lparen" {
      let (right, q2) = _parse-power(tokens, q, p)
      result = mul(result, right)
      q = q2
      continue
    }
    break
  }
  (result, q)
}

#let _parse-expr(tokens, pos, p) = {
  let (result, q) = _parse-term(tokens, pos, p)
  while q < tokens.len() {
    if _is-op(tokens, q, "+") {
      let (right, q2) = _parse-term(tokens, q + 1, p)
      result = add(result, right)
      q = q2
      continue
    }
    if _is-op(tokens, q, "-") {
      let (right, q2) = _parse-term(tokens, q + 1, p)
      if is-type(right, "num") { result = add(result, num(-right.val)) } else { result = add(result, neg(right)) }
      q = q2
      continue
    }
    break
  }
  (result, q)
}

// Build the parser dict with all functions referencing each other
#let _parser = (
  expr: _parse-expr,
  term: _parse-term,
  unary: _parse-unary,
  power: _parse-power,
  atom: _parse-atom,
)

// =========================================================================
// Content Tokenizer (De-structuring)
// =========================================================================

#let _tokenize-content(c) = {
  let tokens = ()

  // Base case: String
  if type(c) == str {
    return _tokenize(c)
  }

  if type(c) == content {
    let func = c.func()

    // 1. Text element (leaf)
    if c.has("text") and type(c.text) == str {
      return _tokenize(c.text)
    }

    // 2. Math Equation ($...$)
    if func == math.equation {
      return _tokenize-content(c.body)
    }

    // 3. Sequence ([a, b] or $a b$ or {a; b})
    if c.has("children") {
      for child in c.children {
        tokens += _tokenize-content(child)
      }
      return tokens
    }

    // 4. Fractions ($x/y$ or $frac(x, y)$)
    if func == math.frac {
      tokens.push((type: "ident", val: "frac"))
      tokens.push((type: "lparen", val: "("))
      tokens += _tokenize-content(c.num)
      tokens.push((type: "comma", val: ","))
      tokens += _tokenize-content(c.denom)
      tokens.push((type: "rparen", val: ")"))
      return tokens
    }

    // 5. Attachments ($x^2$, $x_i$, $sum^n_k$)
    if func == math.attach {
      tokens += _tokenize-content(c.base)
      if c.has("b") {
        // subscript -> _( ... )
        tokens.push((type: "op", val: "_"))
        tokens.push((type: "lparen", val: "("))
        tokens += _tokenize-content(c.b)
        tokens.push((type: "rparen", val: ")"))
      }
      if c.has("t") {
        // superscript -> ^( ... )
        tokens.push((type: "op", val: "^"))
        tokens.push((type: "lparen", val: "("))
        tokens += _tokenize-content(c.t)
        tokens.push((type: "rparen", val: ")"))
      }
      return tokens
    }

    // 6. Roots ($sqrt(x)$, $root(3, x)$)
    if func == math.root {
      // index is optional. If missing, it's sqrt (index 2).
      // Map to root(index, radicand) string syntax.
      tokens.push((type: "ident", val: "root"))
      tokens.push((type: "lparen", val: "("))
      if c.has("index") {
        tokens += _tokenize-content(c.index)
      } else {
        tokens.push((type: "num", val: "2"))
      }
      tokens.push((type: "comma", val: ","))
      tokens += _tokenize-content(c.radicand)
      tokens.push((type: "rparen", val: ")"))
      return tokens
    }

    // 7. Math Operator (Custom functions/Op)
    if func == math.op {
      return _tokenize-content(c.text)
    }

    // 8. LR grouping (parentheses)
    if func == math.lr {
      return _tokenize-content(c.body)
    }

    // 9. Space (ignore)
    // There isn't a global `space` function easily accessible, but checking repr?
    // Or just ignoring unknown content if it's whitespace.
    // Usually whitespace in math is `space` element.
    if repr(func) == "space" { return () }

    // Fallback: try to see if it has body?
    if c.has("body") {
      return _tokenize-content(c.body)
    }
  }

  tokens
}

// =========================================================================
// Public API
// =========================================================================

/// Parse a Typst math string OR content into a CAS expression tree.
///
/// ```typst
/// #let expr = cas-parse("x^2 + 3x - 1")
/// #let expr2 = cas-parse($x^2 + frac(1, 2)$)
/// $ #cas-display(expr) $   // x² + 3x − 1
/// ```
#let cas-parse(input) = {
  let tokens = ()
  if type(input) == str {
    tokens = _tokenize(input)
  } else if type(input) == content {
    tokens = _tokenize-content(input)
  } else {
    panic("cas-parse: input must be string or content (math)")
  }

  if tokens.len() == 0 { return num(0) }
  let (result, _) = _parse-expr(tokens, 0, _parser)
  result
}
