#import "@preview/zero:0.7.0": num, set-group, set-num, set-round, ztable

// ---------------------------------------------------------
// OUTILS ARITHMÉTIQUES POUR LES FRACTIONS
// ---------------------------------------------------------

#let gcd(a, b) = {
  let x = calc.abs(a)
  let y = calc.abs(b)
  while y != 0 {
    let temp = y
    y = calc.rem(x, y)
    x = temp
  }
  return x
}

#let reduce-frac(f) = {
  if type(f.n) == float or type(f.d) == float {
    return (n: f.n / f.d, d: 1)
  }
  if calc.round(f.n) != f.n or calc.round(f.d) != f.d {
    return (n: f.n / f.d, d: 1)
  }
  let g = gcd(int(f.n), int(f.d))
  if g == 0 { return f }
  let num = int(f.n / g)
  let den = int(f.d / g)
  if den < 0 {
    num = -num
    den = -den
  }
  return (n: num, d: den)
}

#let add-frac(f1, f2) = reduce-frac((n: f1.n * f2.d + f2.n * f1.d, d: f1.d * f2.d))
#let sub-frac(f1, f2) = reduce-frac((n: f1.n * f2.d - f2.n * f1.d, d: f1.d * f2.d))
#let mul-frac(f1, f2) = reduce-frac((n: f1.n * f2.n, d: f1.d * f2.d))
#let div-frac(f1, f2) = {
  if f2.n == 0 { panic("Division par zéro détectée") }
  return reduce-frac((n: f1.n * f2.d, d: f1.d * f2.n))
}
#let pow-frac(f1, f2) = {
  if f2.d != 1 { panic("L'exposant doit être un entier") }
  let p = f2.n
  if p == 0 { return (n: 1, d: 1) }
  else if p > 0 { return reduce-frac((n: int(calc.pow(f1.n, p)), d: int(calc.pow(f1.d, p)))) }
  else {
    let abs-p = calc.abs(p)
    return reduce-frac((n: int(calc.pow(f1.d, abs-p)), d: int(calc.pow(f1.n, abs-p))))
  }
}

#let parse-frac(s, fraction: true) = {
  if not fraction { return (n: float(s), d: 1) }
  let is-neg = s.starts-with("-")
  let clean-s = if is-neg { s.slice(1) } else { s }
  if clean-s.starts-with("+") { clean-s = clean-s.slice(1) }
  
  let res = (n: 0, d: 1)
  if "." in clean-s {
    let parts = clean-s.split(".")
    let integer-part = if parts.at(0) == "" { 0 } else { int(parts.at(0)) }
    let decimal-part-str = parts.at(1)
    let decimal-len = decimal-part-str.len()
    let decimal-part = int(decimal-part-str)
    let den = calc.pow(10, decimal-len)
    let num = integer-part * den + decimal-part
    res = (n: num, d: den)
  } else {
    res = (n: int(clean-s), d: 1)
  }
  if is-neg { res.n = -res.n }
  return reduce-frac(res)
}

// ---------------------------------------------------------
// CHAÎNE LITTÉRALE D'UN JETON NUMÉRIQUE
// ---------------------------------------------------------

#let get-token-string(t) = {
  let rad = t.at("radicand", default: 1)
  if rad > 1 {
    let rad-str = "sqrt(" + str(rad) + ")"
    if t.val.n == 1 and t.val.d == 1 { return rad-str }
    if t.val.n == -1 and t.val.d == 1 { return "-" + rad-str }
    let coef-str = if t.val.d == 1 { str(t.val.n) } else { "frac(" + str(t.val.n) + ", " + str(t.val.d) + ")" }
    return coef-str + " " + rad-str
  }
  
  if t.symbol == none {
    if t.val.d == 1 { str(t.val.n) }
    else { "frac(" + str(t.val.n) + ", " + str(t.val.d) + ")" }
  } else {
    if t.val.n == 1 and t.val.d == 1 { t.symbol }
    else if t.val.n == -1 and t.val.d == 1 { "-" + t.symbol }
    else if t.val.d == 1 { str(t.val.n) + " " + t.symbol }
    else { "frac(" + str(t.val.n) + ", " + str(t.val.d) + ") " + t.symbol }
  }
}

// ---------------------------------------------------------
// PARSEUR ET INITIALISATION DES JETONS
// ---------------------------------------------------------

#let tokenize(expr-str, fraction: true) = {
  let s = expr-str.replace(" ", "").replace(",", ".")
  let raw-tokens = ()
  let current-num = ""
  let alpha-chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
  
  let chars = s.clusters()
  let i = 0
  while i < chars.len() {
    let c = chars.at(i)
    let is-unary = false
    
    if (c == "-" or c == "+") and current-num == "" {
      if raw-tokens.len() == 0 { is-unary = true }
      else {
        let prev = raw-tokens.at(-1)
        if prev.type == "op" and prev.val not in (")", "]") { is-unary = true }
      }
    }
    
    if is-unary {
      current-num += c
    } else if c in ("+", "-", "*", "/", ":", "^", "(", ")", "[", "]") {
      if current-num != "" {
        let val-frac = parse-frac(current-num, fraction: fraction)
        let approx = float(val-frac.n) / float(val-frac.d)
        raw-tokens.push((type: "num", val: val-frac, symbol: none, approx_val: approx, is-decimal: "." in current-num, orig: current-num, radicand: 1))
        current-num = ""
      }
      raw-tokens.push((type: "op", val: c))
    } else if c in ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".") {
      current-num += c
    } else if c in alpha-chars {
      if current-num != "" {
        let val-frac = parse-frac(current-num, fraction: fraction)
        let approx = float(val-frac.n) / float(val-frac.d)
        raw-tokens.push((type: "num", val: val-frac, symbol: none, approx_val: approx, is-decimal: "." in current-num, orig: current-num, radicand: 1))
        current-num = ""
      }
      let ident = ""
      while i < chars.len() and chars.at(i) in alpha-chars {
        ident += chars.at(i)
        i += 1
      }
      i -= 1
      if ident == "pi" {
        raw-tokens.push((type: "num", val: (n: 1, d: 1), symbol: "pi", approx_val: calc.pi, is-decimal: false, orig: "pi", radicand: 1))
      } else {
        raw-tokens.push((type: "func", val: ident))
      }
    }
    i += 1
  }
  if current-num != "" {
    let val-frac = parse-frac(current-num, fraction: fraction)
    let approx = float(val-frac.n) / float(val-frac.d)
    raw-tokens.push((type: "num", val: val-frac, symbol: none, approx_val: approx, is-decimal: "." in current-num, orig: current-num, radicand: 1))
  }
  
  let merged-tokens = ()
  let idx = 0
  while idx < raw-tokens.len() {
    if idx + 2 < raw-tokens.len() and raw-tokens.at(idx).type == "num" and raw-tokens.at(idx+1).type == "op" and raw-tokens.at(idx+1).val == "/" and raw-tokens.at(idx+2).type == "num" {
      let left = raw-tokens.at(idx)
      let right = raw-tokens.at(idx+2)
      
      if left.symbol == none and right.symbol == none and left.at("radicand", default: 1) == 1 and right.at("radicand", default: 1) == 1 {
        let num = left.val.n * right.val.d
        let den = left.val.d * right.val.n
        if den < 0 { num = -num; den = -den }
        let res-val = (n: num, d: den)
        merged-tokens.push((
          type: "num", 
          val: res-val, 
          symbol: none,
          approx_val: float(num) / float(den),
          is-decimal: false, 
          is-literal-fraction: true,
          orig-n: left,
          orig-d: right,
          radicand: 1
        ))
        idx += 3
      } else {
        merged-tokens.push(raw-tokens.at(idx))
        idx += 1
      }
    } else {
      merged-tokens.push(raw-tokens.at(idx))
      idx += 1
    }
  }
  return merged-tokens
}

// ---------------------------------------------------------
// PRÉPROCESSEURS STRUCTURELS POUR LE RENDU
// ---------------------------------------------------------

#let nest-parentheses(tokens) = {
  let stack = ((),)
  let open-stack = ()
  for t in tokens {
    if t.type == "op" and t.val in ("(", "[") {
      stack.push(())
      open-stack.push(t)
    } else if t.type == "op" and t.val in (")", "]") {
      if stack.len() > 1 {
        let current = stack.pop()
        let open-token = open-stack.pop()
        let h-group = t.at("highlight-group", default: none)
        if h-group == none { h-group = open-token.at("highlight-group", default: none) }
        
        let group-token = (
          type: "group",
          val: current,
          open: open-token.val,
          close: t.val,
          highlight-group: h-group
        )
        stack.at(-1).push(group-token)
      } else {
        stack.at(-1).push(t)
      }
    } else {
      stack.at(-1).push(t)
    }
  }
  while stack.len() > 1 {
    let current = stack.pop()
    let open-val = if open-stack.len() > 0 { open-stack.pop().val } else { "(" }
    stack.at(-1).push((type: "group", val: current, open: open-val, close: ")"))
  }
  return stack.at(0)
}

#let group-fractions-in-list(tokens) = {
  let processed = ()
  for t in tokens {
    if t.type == "group" {
      let nt = t
      nt.val = group-fractions-in-list(t.val)
      processed.push(nt)
    } else {
      processed.push(t)
    }
  }
  
  let result = ()
  let idx = 0
  let len = processed.len()
  while idx < len {
    let t = processed.at(idx)
    if t.type == "op" and t.val == "/" {
      if result.len() > 0 and idx + 1 < len {
        let left = result.pop()
        let right = processed.at(idx + 1)
        let frac-node = (
          type: "frac-node",
          num: left,
          den: right,
          highlight-group: t.at("highlight-group", default: none)
        )
        result.push(frac-node)
        idx += 2
      } else {
        result.push(t); idx += 1
      }
    } else {
      result.push(t); idx += 1
    }
  }
  return result
}

// ---------------------------------------------------------
// MISE EN FORME DES NOMBRES INDIVIDUELS
// ---------------------------------------------------------

#let format-num(t, mode, fraction: true, digits: 2) = {
  if not fraction and t.at("is-final-approx", default: false) {
    let rounded = calc.round(t.approx_val, digits: digits)
    if calc.abs(rounded - calc.round(rounded)) < 0.000001 { return str(int(calc.round(rounded))) }
    else { return str(rounded) }
  }
  
  let rad = t.at("radicand", default: 1)
  if rad > 1 {
    let n = t.val.n
    let d = t.val.d
    let rad-str = "sqrt(" + str(rad) + ")"
    if n == 1 and d == 1 { return rad-str }
    if n == -1 and d == 1 { return "-" + rad-str }
    let coef-str = if d == 1 { str(n) } else { "frac(" + str(n) + ", " + str(d) + ")" }
    return coef-str + " " + rad-str
  }
  
  if t.symbol != none {
    let n = t.val.n
    let d = t.val.d
    if n == 1 and d == 1 { return t.symbol }
    if n == -1 and d == 1 { return "-" + t.symbol }
    let coef-str = if d == 1 { str(n) } else { "frac(" + str(n) + ", " + str(d) + ")" }
    return coef-str + " " + t.symbol
  }
  
  if t.at("is-literal-fraction", default: false) {
    let left-token = t.orig-n
    let right-token = t.orig-d
    let num-str = format-num(left-token, mode, fraction: fraction, digits: digits)
    let den-str = format-num(right-token, mode, fraction: fraction, digits: digits)
    
    let is-neg = (t.val.n < 0 and t.val.d > 0) or (t.val.n > 0 and t.val.d < 0)
    let clean-num = num-str
    if clean-num.starts-with("-") { clean-num = clean-num.slice(1) }
    let clean-den = den-str
    if clean-den.starts-with("-") { clean-den = clean-den.slice(1) }
    
    if is-neg { return "-frac(" + clean-num + ", " + clean-den + ")" }
    else { return "frac(" + clean-num + ", " + clean-den + ")" }
  }
  
  if not fraction {
    let n = float(t.val.n) / float(t.val.d)
    let rounded = calc.round(n, digits: digits)
    if calc.abs(rounded - calc.round(rounded)) < 0.000001 { return str(int(calc.round(rounded))) }
    else { return str(rounded) }
  } else {
    if t.at("is-decimal", default: false) { return t.at("orig", default: "") }
    else if t.val.d == 1 { return str(t.val.n) }
    else {
      if t.val.n < 0 { return "-frac(" + str(calc.abs(t.val.n)) + ", " + str(t.val.d) + ")" }
      else { return "frac(" + str(t.val.n) + ", " + str(t.val.d) + ")" }
    }
  }
}

// ---------------------------------------------------------
// FORMATEUR DE STRUCTURES RÉCURSIF
// ---------------------------------------------------------

#let format-node-list(nodes, mode, fraction, highlight, digits, ignore-highlight: false) = {
  let parts = ()
  let len = nodes.len()
  let i = 0
  while i < len {
    let n = nodes.at(i)
    let group = if ignore-highlight { none } else { n.at("highlight-group", default: none) }
    
    if group != none {
      let group-nodes = ()
      while i < len and (if ignore-highlight { none } else { nodes.at(i).at("highlight-group", default: none) }) == group {
        group-nodes.push(nodes.at(i))
        i += 1
      }
      let sub-str = format-node-list(group-nodes, mode, fraction, none, digits, ignore-highlight: true)
      if highlight != none and highlight != false {
        let color-str = if type(highlight) == "color" {
          repr(highlight)
        } else if type(highlight) == "string" {
          if highlight.starts-with("#") { "rgb(\"" + highlight + "\")" } else { highlight }
        } else {
          repr(highlight)
        }
        parts.push(" bold(#text(fill: " + color-str + ")[$ " + sub-str + " $]) ")
      } else if highlight == none {
        parts.push(sub-str)
      } else {
        parts.push(" bold(" + sub-str + ") ")
      }
    } else {
      if n.type == "num" {
        let val-str = format-num(n, mode, fraction: fraction, digits: digits)
        let is-neg = n.val.n < 0 and n.symbol == none and n.at("radicand", default: 1) == 1
        
        // AMÉLIORATION : Gestion intelligente de l'affichage des parenthèses autour des négatifs seuls
        let need-paren = false
        if is-neg {
          if i > 0 and nodes.at(i - 1).type == "op" and nodes.at(i - 1).val not in ("(", "[") { need-paren = true }
          if i + 1 < len and nodes.at(i + 1).type == "op" and nodes.at(i + 1).val == "^" { need-paren = true }
        }
        
        if need-paren {
          parts.push("(" + val-str + ")")
        } else { parts.push(val-str) }
      } else if n.type == "op" {
        if n.val == "*" { parts.push(" times ") }
        else if n.val == ":" or n.val == "/" { parts.push(" div ") }
        else if n.val == "^" { parts.push(" ^ ") }
        else { parts.push(n.val) }
      } else if n.type == "func" {
        parts.push(n.val)
      } else if n.type == "group" {
        let sub-str = format-node-list(n.val, mode, fraction, highlight, digits, ignore-highlight: ignore-highlight)
        parts.push(n.open + sub-str + n.close)
      } else if n.type == "frac-node" {
        let num-node = n.num
        let den-node = n.den
        if num-node.type == "group" and num-node.open == "(" { num-node = num-node.val } else { num-node = (num-node,) }
        if den-node.type == "group" and den-node.open == "(" { den-node = den-node.val } else { den-node = (den-node,) }
        let num-str = format-node-list(num-node, mode, fraction, highlight, digits, ignore-highlight: ignore-highlight)
        let den-str = format-node-list(den-node, mode, fraction, highlight, digits, ignore-highlight: ignore-highlight)
        parts.push("frac(" + num-str + ", " + den-str + ")")
      }
      i += 1
    }
  }
  return parts.join("").replace(regex("\s+"), " ").trim()
}

#let format-tokens(tokens, mode, fraction: true, highlight: "blue", digits: 2) = {
  let nested = nest-parentheses(tokens)
  let grouped = group-fractions-in-list(nested)
  return format-node-list(grouped, mode, fraction, highlight, digits)
}

// ---------------------------------------------------------
// RECHERCHE DES OPÉRATIONS PRIORITAIRES
// ---------------------------------------------------------

#let find-innermost-groups(tokens) = {
  let all-groups = ()
  let i = 0
  while i < tokens.len() {
    let t = tokens.at(i)
    if t.type == "op" and t.val in (")", "]") {
      let closing-op = t.val
      let opening-op = if closing-op == ")" { "(" } else { "[" }
      let j = i - 1
      let start-idx = none
      while j >= 0 {
        if tokens.at(j).type == "op" and tokens.at(j).val == opening-op {
          let already-paired = false
          for g in all-groups { if g.start == j { already-paired = true; break } }
          if not already-paired { start-idx = j; break }
        }
        j -= 1
      }
      if start-idx != none { all-groups.push((start: start-idx, end: i)) }
    }
    i += 1
  }
  let is-innermost(start, end) = {
    let j = start + 1
    while j < end {
      if tokens.at(j).type == "op" and tokens.at(j).val in ("(", ")", "[", "]") { return false }
      j += 1
    }
    return true
  }
  let innermost = ()
  for g in all-groups { if is-innermost(g.start, g.end) { innermost.push(g) } }
  return innermost
}

#let find-ops-in-scope(tokens, concomitant) = {
  let len = tokens.len()
  let levels = (("^",), ("*", "/", ":"), ("+", "-"))
  let target-ops = none
  for lvl in levels {
    let found = false
    for t in tokens { if t.type == "op" and t.val in lvl { found = true; break } }
    if found { target-ops = lvl; break }
  }
  if target-ops == none { return () }
  
  let selected-op-indices = ()
  if concomitant {
    let busy-indices = ()
    let i = 0
    while i < len {
      let t = tokens.at(i)
      if t.type == "op" and t.val in target-ops {
        let left-idx = i - 1
        let right-idx = i + 1
        if left-idx >= 0 and right-idx < len {
          if left-idx not in busy-indices and right-idx not in busy-indices {
            if tokens.at(left-idx).type == "num" and tokens.at(right-idx).type == "num" {
              selected-op-indices.push(i)
              busy-indices.push(left-idx); busy-indices.push(i); busy-indices.push(right-idx)
            }
          }
        }
      }
      i += 1
    }
  } else {
    let i = 0
    while i < len {
      let t = tokens.at(i)
      if t.type == "op" and t.val in target-ops {
        let left-idx = i - 1
        let right-idx = i + 1
        if left-idx >= 0 and right-idx < len {
          if tokens.at(left-idx).type == "num" and tokens.at(right-idx).type == "num" {
            selected-op-indices.push(i)
            break
          }
        }
      }
      i += 1
    }
  }
  return selected-op-indices
}

#let process-step(tokens, concomitant) = {
  let innermost = find-innermost-groups(tokens)
  let active-ops = ()
  let paren-to-remove = ()
  let active-simplifications = ()
  let active-funcs = ()
  
  if innermost.len() > 0 {
    if concomitant {
      for g in innermost {
        let sub = tokens.slice(g.start + 1, g.end)
        let is-func-arg = (g.start > 0 and tokens.at(g.start - 1).type == "func")
        let is-simple-frac = (sub.len() == 3 and sub.at(1).type == "op" and sub.at(1).val in ("/", ":"))
        
        if sub.len() == 1 or (is-func-arg and is-simple-frac) {
          if is-func-arg {
            active-funcs.push((func-idx: g.start - 1, start: g.start - 1, end: g.end))
          } else {
            paren-to-remove.push(g.start); paren-to-remove.push(g.end)
          }
        } else {
          let sub-simpls = ()
          let idx = 0
          while idx < sub.len() {
            let t = sub.at(idx)
            if t.type == "num" and t.val.d != 1 and gcd(t.val.n, t.val.d) > 1 { sub-simpls.push(idx) }
            idx += 1
          }
          let sub-ops = find-ops-in-scope(sub, true)
          let busy = sub-simpls
          let final-ops = ()
          for op-idx in sub-ops {
            let left = op-idx - 1
            let right = op-idx + 1
            if left not in busy and op-idx not in busy and right not in busy {
              final-ops.push(op-idx)
              busy.push(left); busy.push(op-idx); busy.push(right)
            }
          }
          for s-idx in sub-simpls { active-simplifications.push(g.start + 1 + s-idx) }
          for op-idx in final-ops { active-ops.push(g.start + 1 + op-idx) }
        }
      }
    } else {
      let g = innermost.at(0)
      let sub = tokens.slice(g.start + 1, g.end)
      let is-func-arg = (g.start > 0 and tokens.at(g.start - 1).type == "func")
      let is-simple-frac = (sub.len() == 3 and sub.at(1).type == "op" and sub.at(1).val in ("/", ":"))
      
      if sub.len() == 1 or (is-func-arg and is-simple-frac) {
        if is-func-arg {
          active-funcs.push((func-idx: g.start - 1, start: g.start - 1, end: g.end))
        } else {
          paren-to-remove.push(g.start); paren-to-remove.push(g.end)
        }
      } else {
        let sub-simpls = ()
        let idx = 0
        while idx < sub.len() {
          let t = sub.at(idx)
          if t.type == "num" and t.val.d != 1 and gcd(t.val.n, t.val.d) > 1 { sub-simpls.push(idx) }
          idx += 1
        }
        if sub-simpls.len() > 0 {
          active-simplifications.push(g.start + 1 + sub-simpls.at(0))
        } else {
          let sub-ops = find-ops-in-scope(sub, false)
          for op-idx in sub-ops { active-ops.push(g.start + 1 + op-idx) }
        }
      }
    }
  } else {
    if concomitant {
      let sub-simpls = ()
      let idx = 0
      while idx < tokens.len() {
        let t = tokens.at(idx)
        if t.type == "num" and t.val.d != 1 and gcd(t.val.n, t.val.d) > 1 { sub-simpls.push(idx) }
        idx += 1
      }
      let sub-ops = find-ops-in-scope(tokens, true)
      let busy = sub-simpls
      let final-ops = ()
      for op-idx in sub-ops {
        let left = op-idx - 1
        let right = op-idx + 1
        if left not in busy and op-idx not in busy and right not in busy {
          final-ops.push(op-idx)
          busy.push(left); busy.push(op-idx); busy.push(right)
        }
      }
      active-simplifications = sub-simpls
      active-ops = final-ops
    } else {
      let sub-simpls = ()
      let idx = 0
      while idx < tokens.len() {
        let t = tokens.at(idx)
        if t.type == "num" and t.val.d != 1 and gcd(t.val.n, t.val.d) > 1 { sub-simpls.push(idx) }
        idx += 1
      }
      if sub-simpls.len() > 0 {
        active-simplifications.push(sub-simpls.at(0))
      } else {
        active-ops = find-ops-in-scope(tokens, false)
      }
    }
  }
  return (active-ops: active-ops, paren-to-remove: paren-to-remove, active-simplifications: active-simplifications, active-funcs: active-funcs)
}

#let apply-highlights(tokens, active-ops, paren-to-remove, active-simplifications, active-funcs) = {
  let len = tokens.len()
  let highlighted = ()
  let i = 0
  while i < len {
    let t = tokens.at(i)
    let group-id = none
    let op-count = 1
    
    for op-idx in active-ops {
      if i >= op-idx - 1 and i <= op-idx + 1 { group-id = op-count; break }
      op-count += 1
    }
    if group-id == none {
      for f in active-funcs { if i >= f.start and i <= f.end { group-id = op-count; break } }
      op-count += active-funcs.len()
    }
    if group-id == none {
      let p-count = 0
      while p-count < paren-to-remove.len() {
        let s = paren-to-remove.at(p-count)
        let e = paren-to-remove.at(p-count + 1)
        if i >= s and i <= e { group-id = op-count + int(p-count / 2); break }
        p-count += 2
      }
      op-count += int(paren-to-remove.len() / 2)
    }
    if group-id == none {
      let s-count = 0
      for s-idx in active-simplifications {
        if i == s-idx { group-id = op-count + s-count; break }
        s-count += 1
      }
    }
    if group-id != none {
      let nt = t
      nt.insert("highlight-group", group-id)
      highlighted.push(nt)
    } else { highlighted.push(t) }
    i += 1
  }
  return highlighted
}

// ---------------------------------------------------------
// EXECUTION STRUCURÉE DES OPÉRATIONS ET FONCTIONS
// ---------------------------------------------------------

#let execute-op-tokens(left, op, right, fraction) = {
  let v1 = left.approx_val
  let v2 = right.approx_val
  let res-approx = 0.0
  if op == "+" { res-approx = v1 + v2 }
  else if op == "-" { res-approx = v1 - v2 }
  else if op == "*" { res-approx = v1 * v2 }
  else if op == "/" or op == ":" { res-approx = v1 / v2 }
  else if op == "^" { res-approx = calc.pow(v1, v2) }
  
  let rounded = calc.round(res-approx)
  if calc.abs(res-approx - rounded) < 0.000001 {
    return (type: "num", val: (n: int(rounded), d: 1), symbol: none, approx_val: res-approx, radicand: 1)
  }
  
  if fraction {
    for den in range(1, 21) {
      let num-approx = res-approx * den
      let num-round = calc.round(num-approx)
      if calc.abs(num-approx - num-round) < 0.000001 {
        return (type: "num", val: (n: int(num-round), d: den), symbol: none, approx_val: res-approx, radicand: 1)
      }
    }
  }
  
  let S1 = left.symbol
  let S2 = right.symbol
  let r1 = left.at("radicand", default: 1)
  let r2 = right.at("radicand", default: 1)
  
  if op == "*" and S1 == none and S2 == none and (r1 > 1 or r2 > 1) {
    let joint-radicand = r1 * r2
    let joint-coef = mul-frac(left.val, right.val)
    let k = 1
    let r = joint-radicand
    let idx = 2
    while idx * idx <= r {
      while calc.rem(r, idx * idx) == 0 {
        k *= idx
        r = int(r / (idx * idx))
      }
      idx += 1
    }
    joint-coef = mul-frac(joint-coef, (n: k, d: 1))
    return (type: "num", val: joint-coef, symbol: none, approx_val: res-approx, radicand: r)
  }
  
  if (op == "/" or op == ":") and S1 == none and S2 == none and (r1 > 1 or r2 > 1) {
    let joint-radicand = r1 * r2
    let joint-coef = div-frac(left.val, right.val)
    joint-coef = div-frac(joint-coef, (n: r2, d: 1))
    let k = 1
    let r = joint-radicand
    let idx = 2
    while idx * idx <= r {
      while calc.rem(r, idx * idx) == 0 {
        k *= idx
        r = int(r / (idx * idx))
      }
      idx += 1
    }
    joint-coef = mul-frac(joint-coef, (n: k, d: 1))
    return (type: "num", val: joint-coef, symbol: none, approx_val: res-approx, radicand: r)
  }
  
  if (op == "+" or op == "-") and S1 == none and S2 == none and r1 > 1 and r1 == r2 {
    let res-val = if op == "+" { add-frac(left.val, right.val) } else { sub-frac(left.val, right.val) }
    return (type: "num", val: res-val, symbol: none, approx_val: res-approx, radicand: r1)
  }
  
  if S1 == none and S2 == none and r1 == 1 and r2 == 1 {
    let res-val = (n: 0, d: 1)
    if op == "+" { res-val = add-frac(left.val, right.val) }
    else if op == "-" { res-val = sub-frac(left.val, right.val) }
    else if op == "*" { res-val = mul-frac(left.val, right.val) }
    else if op == "/" or op == ":" { res-val = div-frac(left.val, right.val) }
    else if op == "^" { res-val = pow-frac(left.val, right.val) }
    return (type: "num", val: res-val, symbol: none, approx_val: res-approx, radicand: 1)
  }
  
  if op == "*" {
    if S1 != none and S2 == none { return (type: "num", val: mul-frac(left.val, right.val), symbol: S1, approx_val: res-approx, radicand: 1) }
    else if S1 == none and S2 != none { return (type: "num", val: mul-frac(left.val, right.val), symbol: S2, approx_val: res-approx, radicand: 1) }
    else { return (type: "num", val: mul-frac(left.val, right.val), symbol: S1 + " " + S2, approx_val: res-approx, radicand: 1) }
  } else if op == "/" or op == ":" {
    if S1 != none and S2 == none { return (type: "num", val: div-frac(left.val, right.val), symbol: S1, approx_val: res-approx, radicand: 1) }
    else if S1 == none and S2 != none { return (type: "num", val: div-frac(left.val, right.val), symbol: "frac(1, " + S2 + ")", approx_val: res-approx, radicand: 1) }
    else { return (type: "num", val: div-frac(left.val, right.val), symbol: "frac(" + S1 + ", " + S2 + ")", approx_val: res-approx, radicand: 1) }
  } else if op == "+" or op == "-" {
    if S1 == S2 and S1 != none {
      let res-val = if op == "+" { add-frac(left.val, right.val) } else { sub-frac(left.val, right.val) }
      return (type: "num", val: res-val, symbol: S1, approx_val: res-approx, radicand: 1)
    } else {
      let str-left = get-token-string(left)
      let str-right = get-token-string(right)
      return (type: "num", val: (n: 1, d: 1), symbol: str-left + " " + op + " " + str-right, approx_val: res-approx, radicand: 1)
    }
  } else if op == "^" {
    if S2 == none and right.val.d == 1 {
      return (type: "num", val: pow-frac(left.val, right.val), symbol: if S1 == none { none } else { "(" + S1 + ")^(" + str(right.val.n) + ")" }, approx_val: res-approx, radicand: 1)
    } else {
      return (type: "num", val: (n: 1, d: 1), symbol: "(" + get-token-string(left) + ")^(" + get-token-string(right) + ")", approx_val: res-approx, radicand: 1)
    }
  }
  return (type: "num", val: (n: 1, d: 1), symbol: "error", approx_val: res-approx, radicand: 1)
}

#let execute-func(func-name, token, fraction) = {
  let val-float = token.approx_val
  let res-num = 0.0
  if func-name == "sqrt" { res-num = calc.sqrt(val-float) }
  else if func-name == "ln" { res-num = calc.ln(val-float) }
  else if func-name == "exp" { res-num = calc.exp(val-float) }
  else if func-name == "sin" { res-num = calc.sin(val-float) }
  else if func-name == "cos" { res-num = calc.cos(val-float) }
  else if func-name == "tan" { res-num = calc.tan(val-float) }
  
  let rounded = calc.round(res-num)
  if calc.abs(res-num - rounded) < 0.000001 {
    return (type: "num", val: (n: int(rounded), d: 1), symbol: none, approx_val: res-num, radicand: 1)
  }
  
  if fraction {
    for den in range(1, 21) {
      let num-approx = res-num * den
      let num-round = calc.round(num-approx)
      if calc.abs(num-approx - num-round) < 0.000001 {
        return (type: "num", val: (n: int(num-round), d: den), symbol: none, approx_val: res-num, radicand: 1)
      }
    }
  }
  
  let t-rad = token.at("radicand", default: 1)
  if func-name == "sqrt" and t-rad == 1 and token.symbol == none and token.val.d == 1 and token.val.n > 0 {
    let n = token.val.n
    let k = 1
    let r = n
    let idx = 2
    while idx * idx <= r {
      while calc.rem(r, idx * idx) == 0 {
        k *= idx
        r = int(r / (idx * idx))
      }
      idx += 1
    }
    return (type: "num", val: (n: k, d: 1), symbol: none, approx_val: res-num, radicand: r)
  }
  
  let inner = get-token-string(token)
  let symbol = if func-name == "sqrt" { "sqrt(" + inner + ")" } else { func-name + "(" + inner + ")" }
  return (type: "num", val: (n: 1, d: 1), symbol: symbol, approx_val: res-num, radicand: 1)
}

#let compute-next-tokens(tokens, active-ops, paren-to-remove, active-simplifications, active-funcs, fraction) = {
  let actions = ()
  for op-idx in active-ops { actions.push((type: "eval", start: op-idx - 1, end: op-idx + 1, op-idx: op-idx)) }
  for f in active-funcs { actions.push((type: "func", start: f.start, end: f.end, func-idx: f.func-idx)) }
  
  let p-idx = 0
  while p-idx < paren-to-remove.len() {
    let s = paren-to-remove.at(p-idx)
    let e = paren-to-remove.at(p-idx + 1)
    actions.push((type: "remove-paren", start: s, end: e))
    p-idx += 2
  }
  for s-idx in active-simplifications { actions.push((type: "simplify", start: s-idx, end: s-idx, idx: s-idx)) }
  
  let sorted-actions = actions.sorted(key: act => act.start).rev()
  let next-tokens = tokens
  for act in sorted-actions {
    if act.type == "eval" {
      let left = next-tokens.at(act.op-idx - 1)
      let op = next-tokens.at(act.op-idx).val
      let right = next-tokens.at(act.op-idx + 1)
      let res-token = execute-op-tokens(left, op, right, fraction)
      next-tokens = next-tokens.slice(0, act.start) + (res-token,) + next-tokens.slice(act.end + 1)
    } else if act.type == "func" {
      let func-name = next-tokens.at(act.func-idx).val
      let sub-tokens = next-tokens.slice(act.func-idx + 2, act.end)
      let arg-token = none
      
      if sub-tokens.len() == 1 {
        arg-token = sub-tokens.at(0)
      } else if sub-tokens.len() == 3 and sub-tokens.at(1).type == "op" and sub-tokens.at(1).val in ("/", ":") {
        arg-token = execute-op-tokens(sub-tokens.at(0), sub-tokens.at(1).val, sub-tokens.at(2), fraction)
      } else {
        arg-token = sub-tokens.at(0)
      }
      
      let res-token = execute-func(func-name, arg-token, fraction)
      next-tokens = next-tokens.slice(0, act.start) + (res-token,) + next-tokens.slice(act.end + 1)
    } else if act.type == "remove-paren" {
      let inside-token = next-tokens.at(act.start + 1)
      next-tokens = next-tokens.slice(0, act.start) + (inside-token,) + next-tokens.slice(act.end + 1)
    } else if act.type == "simplify" {
      let token = next-tokens.at(act.idx)
      let res-val = reduce-frac(token.val)
      let res-token = (type: "num", val: res-val, symbol: token.symbol, approx_val: token.approx_val, radicand: token.at("radicand", default:1))
      next-tokens = next-tokens.slice(0, act.idx) + (res-token,) + next-tokens.slice(act.idx + 1)
    }
  }
  
  // CORRECTION : Nettoyage immédiat et automatique des parenthèses superflues autour d'un seul jeton
  let i = 0
  while i < next-tokens.len() {
    if i + 2 < next-tokens.len() and next-tokens.at(i).type == "op" and next-tokens.at(i).val in ("(", "[") and next-tokens.at(i+2).type == "op" and next-tokens.at(i+2).val in (")", "]") {
      let is-func = (i > 0 and next-tokens.at(i - 1).type == "func")
      if not is-func {
        next-tokens = next-tokens.slice(0, i) + (next-tokens.at(i+1),) + next-tokens.slice(i + 3)
        continue
      }
    }
    i += 1
  }
  
  return next-tokens
}
