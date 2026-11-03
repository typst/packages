#let action-type = (SHIFT: 0, REDUCE: 1, ACCEPT: 2, ERROR: 3)


// Grammar helpers

#let augment-grammar(grammar) = {
  let first-variable = grammar.at(0).at(0)
  let new-first-prod = (first-variable + "'", (first-variable,))
  let augmented-grammar = (new-first-prod,) + grammar
  return augmented-grammar
}

#let get-variables(grammar) = {
  let variables = ()
  for item in grammar {
    variables.push(item.at(0))
  }
  return variables.dedup()
}

#let get-terminals(grammar) = {
  let vars = get-variables(grammar)
  let terminals = ()
  for item in grammar {
    for t in item.at(1) {
      if t not in vars and t != "." and t != "\\epsilon" {
        terminals.push(t)
      }
    }
  }
  return terminals.dedup()
}

#let get-all-symbols(grammar) = {
  let symbols = get-variables(grammar) + get-terminals(grammar)
  return symbols.dedup()
}


// LR item manipulation

#let append-dot(item) = {
  let (lhs, rhs) = item
  return (lhs, (".",) + rhs)
}

#let append-dot-in-grammar(grammar, target) = {
  grammar.enumerate().map(((i, item)) => {
    if i == target {
      append-dot(item)
    } else {
      item
    }
  })
}

#let advance-dot(item) = {
  let (lhs, rhs) = item
  let dot-index = rhs.position(x => x == ".")

  if dot-index != none and (dot-index + 1) < rhs.len() {
    let next-symbol = rhs.at(dot-index + 1)
    let new-rhs = rhs.slice(0, dot-index) + (next-symbol, ".") + rhs.slice(dot-index + 2)
    return (lhs, new-rhs)
  }
  return item
}



#let closure(state, grammar) = {
  let J = state
  let changed = true

  while changed {
    changed = false

    for item in J {
      let rhs = item.at(1)
      let dot-index = rhs.position(x => x == ".")

      if dot-index != none and (dot-index + 1) < rhs.len() {
        let target = rhs.at(dot-index + 1)
        let target-prods = grammar.filter(x => x.at(0) == target)

        for prod in target-prods {
          let new-item = append-dot(prod)

          if new-item not in J {
            J.push(new-item)
            changed = true
          }
        }
      }
    }
  }

  return J
}

#let goto(state, symbol, grammar) = {
  let moved-items = ()

  for item in state {
    let rhs = item.at(1)
    let dot-index = rhs.position(x => x == ".")

    if dot-index != none and (dot-index + 1) < rhs.len() {
      let next-symbol = rhs.at(dot-index + 1)

      if next-symbol == symbol {
        moved-items.push(advance-dot(item))
      }
    }
  }

  return closure(moved-items, grammar)
}



#let canonical-items(augmented-grammar) = {
  let I0 = closure((append-dot(augmented-grammar.at(0)),), augmented-grammar)
  let C = (I0,)
  let changed = true
  let symbols = get-all-symbols(augmented-grammar).filter(x => x != "\\epsilon")

  while changed {
    changed = false

    for state in C {
      for symbol in symbols {
        let next-state = goto(state, symbol, augmented-grammar)

        if (next-state.len() != 0) and (next-state not in C) {
          C.push(next-state)
          changed = true
        }
      }
    }
  }

  return C
}



#let get-first-of-sequence(seq, first-sets) = {
  if seq.len() == 0 or seq == ("\\epsilon",) { return ("\\epsilon",) }
  let result = ()
  let all-epsilon = true
  for sym in seq {
    let sym-first = first-sets.at(sym, default: ())
    for f in sym-first {
      if f != "\\epsilon" and f not in result { result.push(f) }
    }
    if "\\epsilon" not in sym-first {
      all-epsilon = false
      break
    }
  }
  if all-epsilon and "\\epsilon" not in result { result.push("\\epsilon") }
  return result
}

#let compute-first(grammar) = {
  let first-sets = (:)
  for sym in get-terminals(grammar) { first-sets.insert(sym, (sym,)) }
  for sym in get-variables(grammar) { first-sets.insert(sym, ()) }

  let changed = true
  while changed {
    changed = false
    for prod in grammar {
      let lhs = prod.at(0)
      let rhs = prod.at(1)

      // skip left-recursive productions entirely
      if rhs.at(0) == lhs { continue }

      let rhs-first = get-first-of-sequence(rhs, first-sets)
      for f in rhs-first {
        let current-first = first-sets.at(lhs)
        if f not in current-first {
          current-first.push(f)
          first-sets.insert(lhs, current-first)
          changed = true
        }
      }
    }
  }
  return first-sets
}

#let compute-follow(grammar, first-sets) = {
  let follow-sets = (:)
  let non-terminals = get-variables(grammar)
  for nt in non-terminals { follow-sets.insert(nt, ()) }

  let original-start = grammar.at(0).at(1).at(0)
  follow-sets.insert(original-start, ("$",))

  let changed = true
  while changed {
    changed = false
    for prod in grammar {
      let lhs = prod.at(0)
      let rhs = prod.at(1)
      if rhs == ("\\epsilon",) { continue }

      for i in range(rhs.len()) {
        let symbol = rhs.at(i)
        if symbol in non-terminals {
          let beta = rhs.slice(i + 1)
          let first-beta = get-first-of-sequence(beta, first-sets)

          for f in first-beta {
            if f != "\\epsilon" and f not in follow-sets.at(symbol) {
              let sym-follow = follow-sets.at(symbol)
              sym-follow.push(f)
              follow-sets.insert(symbol, sym-follow)
              changed = true
            }
          }
          if "\\epsilon" in first-beta or beta.len() == 0 {
            for f in follow-sets.at(lhs) {
              if f not in follow-sets.at(symbol) {
                let sym-follow = follow-sets.at(symbol)
                sym-follow.push(f)
                follow-sets.insert(symbol, sym-follow)
                changed = true
              }
            }
          }
        }
      }
    }
  }
  return follow-sets
}


// SLR(1) table construction

// Returns (ACTION: array of dicts, GOTO: array of dicts, conflicts: array)
// Each conflict is a dict: (state: int, symbol: str, existing: action, incoming: action)
// Conflicts are reported but the first entry written wins (shift preferred on shift/reduce so the caller can decide what to do with the conflict list)

#let build-tables(C, augmented-grammar) = {
  let ACTION = ()
  let GOTO = ()
  let conflicts = ()

  let terminals = get-terminals(augmented-grammar).filter(x => x != "\\epsilon")
  let variables = get-variables(augmented-grammar)

  let first-sets = compute-first(augmented-grammar)
  let follow-sets = compute-follow(augmented-grammar, first-sets)

  // S' → S . 
  let start-item = append-dot(augmented-grammar.at(0))    // S' → . S
  let accept-item = advance-dot(start-item)               // S' → S .

  for (state-idx, state) in C.enumerate() {
    let current-action = (:)
    let current-goto = (:)

    for symbol in terminals {
      let next-state = goto(state, symbol, augmented-grammar)

      if next-state.len() > 0 {
        let j = C.position(x => x == next-state)
        current-action.insert(symbol, (action-type.SHIFT, j))
      }
    }

    for symbol in variables {
      let next-state = goto(state, symbol, augmented-grammar)

      if next-state.len() > 0 {
        let j = C.position(x => x == next-state)
        current-goto.insert(symbol, j)
      }
    }

    if accept-item in state {
      current-action.insert("$", (action-type.ACCEPT, none))
    }

    for item in state {
      let lhs = item.at(0)
      let rhs = item.at(1)
      let dot-index = rhs.position(x => x == ".")

      // item is complete (dot at end) and is not the accept item
      if dot-index == (rhs.len() - 1) and item != accept-item {
        let pure-rhs = rhs.slice(0, dot-index)
        if pure-rhs.len() == 0 { pure-rhs = ("\\epsilon",) }

        let rule-index = augmented-grammar.position(
          x => x.at(0) == lhs and x.at(1) == pure-rhs
        )

        let follow-A = follow-sets.at(lhs)
        for f in follow-A {
          let reduce-action = (action-type.REDUCE, rule-index)

          if f in current-action {
            // conflict detected and existing entry wins
            // TODO: precedence/associativity rules
            conflicts.push((
              state:    state-idx,
              symbol:   f,
              existing: current-action.at(f),
              incoming: reduce-action,
            ))
          } else {
            current-action.insert(f, reduce-action)
          }
        }
      }
    }

    ACTION.push(current-action)
    GOTO.push(current-goto)
  }

  return (ACTION: ACTION, GOTO: GOTO, conflicts: conflicts)
}






#let parse-input(input, ACTION, GOTO, augmented-grammar) = {
  let stack = (0,)
  let tree-stack = ()
  let current-input = input
  let step = 0
  let history = ()

  while current-input.len() > 0 {
    step += 1
    // TODO: proper infinite loop detection
    if step > 1000 { break }

    let state = stack.last()
    let token = current-input.at(0)
    let action-dict = ACTION.at(state)

    let act = action-dict.at(token, default: (action-type.ERROR, none))

    history.push((step: step, stack: stack, input: current-input, action: act))

    if act.at(0) == action-type.SHIFT {
      let next-state = act.at(1)
      stack.push(token)
      stack.push(next-state)
      current-input.remove(0)
      tree-stack.push((label: token, children: ()))

    } else if act.at(0) == action-type.REDUCE {
      let rule-index = act.at(1)
      let rule = augmented-grammar.at(rule-index)
      let lhs = rule.at(0)
      let rhs = rule.at(1)

      let rhs-len = if rhs == ("\\epsilon",) { 0 } else { rhs.len() }
      let children = ()

      if rhs-len > 0 {
        let pop-count = rhs-len * 2
        stack = stack.slice(0, stack.len() - pop-count)
        children = tree-stack.slice(tree-stack.len() - rhs-len)
        tree-stack = tree-stack.slice(0, tree-stack.len() - rhs-len)
      } else {
        children = ((label: "\\epsilon", children: ()),)
      }

      let top-state = stack.last()
      let next-state = GOTO.at(top-state).at(lhs)

      stack.push(lhs)
      stack.push(next-state)
      tree-stack.push((label: lhs, children: children))

    } else if act.at(0) == action-type.ACCEPT {
      return (success: true, log: history, ast: tree-stack.last())

    } else {
      return (success: false, log: history, ast: none)
    }
  }

  return (success: false, log: history, ast: none)
}
