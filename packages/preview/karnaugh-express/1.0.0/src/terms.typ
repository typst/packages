#import "graycode-handling.typ": generate-bit-positions, position-bits

#let is-minterm(term) = {
  let contains-and = "&" in term
  let contains-or = "|" in term

  if contains-and and contains-or {panic("The term `" + term + "` contains both `&` and `|`.")}

  not contains-or
}

// given a term, parse it so that it can later be used to compare it to the cell graycode
// returns a sequence of bits and a bit mask. For example
// bits: 1001101, mask: 1000001, so later, we can check wether the cell graycode matches
// these bits in the positions where the masks bits are 1
#let parse-term(vars, term) = {

  // Check, wether the provided term is a minterm
  let is-minterm = is-minterm(term)

  // Extracts all literals from the term
  let literals-in-term = term.split(if is-minterm {"&"} else {"|"})

  // Represents the number of literals in a term
  let literal-count = literals-in-term.len()

  // Represents the variables from the term
  let variables-in-term = ()

  // These will later hold the bit-representation of the term
  // as well as the bit mask, to see which bits are relevant
  let term-as-bits = 0
  let term-bit-mask = 0

  // The count of variables in the entire K-map,
  // *not* the count of variables in the provided term
  let amount-of-vars = vars.len()

  // Extracts the variables from the list of literals
  // and stores them in the list `variables-in-term`
  for i in range(literals-in-term.len()) {
    literals-in-term.at(i) = literals-in-term.at(i).trim(" ")
    variables-in-term.push(literals-in-term.at(i).trim("!"))
  }

  // Creates the bit-representation of the variables. A bit is 0 if the literal
  // is !x and 1 if the literal is x
  // The bit mask is 1 for every literal
  for (i, var) in variables-in-term.enumerate().rev() {
    term-bit-mask = term-bit-mask.bit-or(1.bit-lshift(literal-count - i -1))

    // Behaviour is inverted for minterms and maxterms
    if literals-in-term.at(i).starts-with("!") != is-minterm {
      term-as-bits = term-as-bits.bit-or(1.bit-lshift(literal-count - i -1))
    }
  }

  // Finds out how we need to shift the bits to make the position of variables
  // in the term match the position of variables in the vars-array
  let bit-position-destination = generate-bit-positions(vars, variables-in-term)

  // Shift the bits according to the bit-position-destination
  term-bit-mask = position-bits(bit-position-destination, term-bit-mask)
  term-as-bits = position-bits(bit-position-destination, term-as-bits)

  (term-bit-mask, term-as-bits)
}


// Parse a list of terms
// returns a list of parsed terms
#let parse-term-list(vars, terms) = {
  let parsed-terms = ()
  for term in terms{
    parsed-terms.push(parse-term(vars, term))
  }
  parsed-terms
}

// Given a parsed term, find all the coordinates where it is active
#let term-to-active-coordinates(parsed-term, cell-graycodes) = {
  let coordinates = ()
  for (i-row, row) in cell-graycodes.enumerate() {
    for (i-col, cell-code) in cell-graycodes.at(i-row).enumerate() {

      // If the cells graycode does not match the terms bits
      // in the positions where the bit mask is 1, skip
      if cell-code.bit-and(parsed-term.at(0)) != parsed-term.at(1) {continue}

      // Else, the coordinate is active
      coordinates.push((i-row, i-col))
    }
  }
  coordinates
}

// use the parsed terms to determine what cells should be active
#let term-list-to-active-coordinates(parsed-terms, cell-graycodes) = {
  let coordinates-list = ()

  // Calculate the coordinates for each term
  for parsed-term in parsed-terms {
    coordinates-list.push(term-to-active-coordinates(parsed-term, cell-graycodes))
  }
  coordinates-list
}
