#let split-equation(mol, equation: false, split-charge: false) = {
  if equation {
    mol = mol.body
    if mol.has("children") {
      mol = mol.children
    } else {
      mol = (mol,)
    }
  }


  let result = ()
  let last-number = false
  let count = 0
  for m in mol {
    if m.has("text") {
      let text = m.text
      if str.match(text, regex("^[A-Z][a-z]*$")) != none {
        if last-number {
          result.at(-1) = (result.at(-1).at(0) + m, result.at(-1).at(1))
        } else {
          result.push((m, true))
        }
        last-number = false
      } else if str.match(text, regex("^[0-9]+$")) != none {
        if last-number {
          panic("Consecutive numbers in fragment fragment")
        }
        last-number = true
        result.push((m, true))
      } else {
        panic("Invalid fragment fragment content")
      }
    } else if m.func() == math.lr {
      result.push((m, true))
      last-number = false
    } else if m.func() == math.attach {
      if split-charge {
        result.push((
          math.attach(
            "",
            bl: m.at("bl", default: none),
            tl: m.at("tl", default: none),
          ),
          false,
        ))
        result.push((
          math.attach(
            m.base,
            b: m.at("b", default: none),
            t: m.at("t", default: none),
          ),
          true,
        ))
        result.push((
          math.attach(
            "",
            br: m.at("br", default: none),
            tr: m.at("tr", default: none),
          ),
          false,
        ))
      } else {
        result.push((m, true))
      }
      last-number = false
    } else if m == [ ] {
      continue
    } else {
      panic("Invalid fragment fragment content")
    }
    count += 1
  }
  (result, count)
}

#let fragment-cor-regex = "[0-9]*[A-Z][a-z]*'*"
#let exponent-regex = "((?:[0-9]+(?:\\+|\\-)?)|[A-Z]|\\+|\\-)"
#let exponent-base-regex = "(?:(\\^|_)" + exponent-regex + ")?(?:(\\^|_)" + exponent-regex + ")?"
#let fragment-regex = regex("^ *(" + fragment-cor-regex + ")" + exponent-base-regex)

#let make-fragment-text(text, indexed) = (
  math.equation(eval(text, mode: "math")),
  indexed,
)

#let split-fragment-string(mol, split-charge: false) = {
  let aux(str) = {
    let match = str.match(fragment-regex)
    if match == none {
      panic(str + " is not a valid fragment")
    } else if match.captures.at(1) == match.captures.at(3) and match
      .captures
      .at(1) != none {
      panic("You cannot use an exponent and a subscript twice")
    }
    let eq = "\"" + match.captures.at(0) + "\""

    let has-exponent = match.captures.at(2) != none
    let has-subscript = match.captures.at(4) != none

    let charge = ""
    if has-exponent {
      charge += match.captures.at(1) + "(" + match.captures.at(2) + ")"
    }
    if match.captures.at(3) != none {
      charge += match.captures.at(3) + "(" + match.captures.at(4) + ")"
    }
    if charge != "" {
      if split-charge {
        charge = "\"\"" + charge
        eq = (make-fragment-text(eq, true), make-fragment-text(charge, false))
      } else {
        eq += charge
        eq = (make-fragment-text(eq, true),)
      }
    } else {
      eq = (make-fragment-text(eq, true),)
    }

    (eq, match.end)
  }

  let count = 0
  let fragments = while not mol.len() == 0 {
    count += 1
    let (eq, end) = aux(mol)
    mol = mol.slice(end)
    eq
  }
  (fragments, count)
}
