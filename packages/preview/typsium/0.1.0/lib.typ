// === Declarations & Configurations ===
#let regex_patterns = (
  element: regex("^\s?([A-Z][a-z]?|[a-z])(\d*)"),
  bracket: regex("^\s?([\(\[\]\)])(\d*)"),
  charge: regex("^\^?\(?([0-9|+-]+)\)?"),
  arrow: regex("^\s?(<->|->)"),
  coef: regex("^\s?(\d+)"),
  plus: regex("^\s?\+"),
)
#let config = (
  arrow: (arrow_size: 120%, reversible_size: 150%),
  conditions: (
    bottom: (
      symbols: ("Delta", "delta", "Δ", "δ", "heat", "hot"),
      identifiers: (("T=", "t="), ("P=", "p=")),
      units: ("°C", "K", "atm", "bar"),
    ),
  ),
)
// === Basic Processing Functions ===
#let process_element(element, count) = { $element_count$ }
#let process_bracket(bracket, count) = { $bracket_count$ }
#let process_charge(input, charge) = context {
  show "+": math.plus
  show "-": math.minus
  $#block(height: measure(input.children.last()).height)^charge$
}

// === Formula Parser ===
#let parse_formula(formula) = {
  let remaining = formula.trim()
  let result = none
  while remaining.len() > 0 {
    let matched = false
    for pattern in ("coef", "element", "bracket") {
      let match = remaining.match(regex_patterns.at(pattern))
      if match != none {
        result += if pattern == "coef" { $#match.text$ } else if pattern == "element" {
          process_element(match.captures.at(0), match.captures.at(1))
        } else { process_bracket(match.captures.at(0), match.captures.at(1)) }
        remaining = remaining.slice(match.end)
        matched = true
        break
      }
    }
    if not matched {
      result += text(remaining.first())
      remaining = remaining.slice(1)
    }
  }
  return if result == none { formula } else { result }
}

// === Condition Processing ===
#let process_condition(cond) = {
  let cond = cond.trim()
  if cond in config.conditions.bottom.symbols {
    return (none, if cond in ("heat", "hot") { sym.Delta } else { sym.Delta })
  }
  let is_bottom = (
    config.conditions.bottom.identifiers.any(ids => ids.any(id => cond.starts-with(id)))
      or config.conditions.bottom.units.any(unit => cond.ends-with(unit))
  )
  return if is_bottom { (none, cond) } else { (parse_formula(cond), none) }
}

// === Arrow Processing ===
#let process_arrow(arrow_text, condition: none) = {
  let arrow = if arrow_text.contains("<-") {
    $stretch(#sym.harpoons.rtlb, size: #config.arrow.reversible_size)$
  } else {
    $stretch(->, size: #config.arrow.arrow_size)$
  }
  let top = ()
  let bottom = ()
  if condition != none {
    for cond in condition.split(",") {
      let (t, b) = process_condition(cond)
      if t != none { top.push(t) }
      if b != none { bottom.push(b) }
    }
  }
  $arrow^top.join(",")_bottom.join(",")$
}

// === Main Function ===
#let ce = (formula, condition: none) => {
  let remaining = formula.trim()
  let result = none
  while remaining.len() > 0 {
    let matched = false
    for pattern in ("coef", "element", "arrow", "bracket", "plus", "charge") {
      let match = remaining.match(regex_patterns.at(pattern))
      if match != none {
        result += if pattern == "plus" { $+$ } else if pattern == "coef" { $#match.text$ } else if (
          pattern == "element"
        ) { process_element(match.captures.at(0), match.captures.at(1)) } else if pattern == "bracket" {
          process_bracket(match.captures.at(0), match.captures.at(1))
        } else if pattern == "charge" { process_charge(result, match.captures.at(0)) } else {
          process_arrow(match.text, condition: condition)
        }
        remaining = remaining.slice(match.end)
        matched = true
        break
      }
    }
    if not matched {
      panic(
        "Parse error at position "
          + str(formula.len() - remaining.len())
          + ": '"
          + remaining.first()
          + "' in formula: "
          + formula,
      )
    }
  }
  $upright(display(result))$
}
