#let split-equation(mol, equation: false) = {
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
  for m in mol {
    let last-number-hold = last-number
    if m.has("text") {
      let text = m.text
      if str.match(text, regex("^[A-Z][a-z]*$")) != none {
        result.push(m)
      } else if str.match(text, regex("^[0-9]+$")) != none {
        if last-number {
          panic("Consecutive numbers in molecule")
        }
        last-number = true
        result.push(m)
      } else {
        panic("Invalid molecule content")
      }
    } else if m.func() == math.attach or m.func() == math.lr {
      result.push(m)
    } else if m == [ ] {
      continue
    } else {
      panic("Invalid molecule content")
    }
    if last-number-hold {
      result.at(-2) = result.at(-2) + result.at(-1)
      let _ = result.pop()
      last-number = false
    }
  }
  result
}

#let split-string(mol) = {
  let aux(str) = {
    let match = str.match(regex("^ *([0-9]*[A-Z][a-z]*)(\\^[0-9]+|\\^[A-Z])?(_[0-9]+|_[A-Z])?"))
    if match == none {
      panic(str + " is not a valid atom")
    }
    let eq = "\"" + match.captures.at(0) + "\""
    if match.captures.len() >= 2 {
      eq += match.captures.at(1)
    }
		if match.captures.len() >= 3 {
			eq += match.captures.at(2)
		}
    let eq = math.equation(eval(eq, mode: "math"))
    (eq, match.end)
  }

  while not mol.len() == 0 {
    let (eq, end) = aux(mol)
    mol = mol.slice(end)
    (eq,)
  }
}