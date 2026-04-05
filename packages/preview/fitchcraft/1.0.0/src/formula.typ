//type definition
#let formula(index, equation, rule: none) = {
  (
    index: [#index],
    equation: equation,
    rule: rule
  )
}

// utility formulas

// opens a subproof
#let open = formula(-1,"UTIL subproof open")

// closes a subproof
#let close = formula(-1,"UTIL subproof close")

// an assumption line
#let assume = formula(-1,"UTIL assumption line")

#let utils = (open, close, assume)

// parse a single formula; use internally
#let parse-single(fm, line-number) = {

  if type(fm) == content or (type(fm) == array and fm.len() == 1) { // just an equation
      return formula(
        [#line-number],
        fm,
        rule: $$ // changing '$$' to '[]' completely breaks the spacing for some reason!
      )
    }

    // otherwise, must be an array

    if type(fm) == array {

      if fm.len() == 2 { // equation, rule
        return formula(
          [#line-number],
          fm.at(0), // equation
          rule: fm.at(1) // rule
        )
      }

      else if fm.len() == 3 { // index, equation, rule
        return formula(
          fm.at(0), // index
          fm.at(1), // equation
          rule: fm.at(2) // rule
        )
      }

      //else
      panic("Array of invalid form! The valid forms are (equation, rule) or (index, equation, rule).")

      }

    // else
    panic("Invalid input type! Valid inputs are equations or arrays.")

}

// parse input to array of formulas
#let parse(arr, indexation) = {

  let formulas = ()
  let line-number = 1

  for line in arr {

    if line in utils {
      formulas.push(line)
    }

    else { // is a visible formula
      formulas.push(
        parse-single(line,
          eval(numbering(indexation, line-number), mode: "math")
        )
      )
      line-number += 1
    }

  }

  /* why does this exist?
  let last = formulas.last()

  assert((last not in utils) or (last == spe), message: "Can't close the proof with a utility line other than spe!")
  */

  return formulas
  
}