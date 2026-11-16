// calculates the gray code of a given number
#let calculate-gray-code(number) = {
  number.bit-xor(number.bit-rshift(1))
}

// reverses the gray code function
#let decode-gray-code(number) = {
  let result = 0
  while number > 0 {
    result = result.bit-xor(number)
    number = number.bit-rshift(1)
  }
  result
}

// extracts the lowest n bits from a number
#let extract-lower-n(number, n) = {
  number.bit-and((1).bit-lshift(n) - 1)
}

// given the variables and an arrangement, determin how much you need to shift the bits so that the arrangement becomes
// the original variables.
// We are given the following variables (in the order of the truth table)
// and an arrangement. Starting from the arrangement, how do we have to shift each variable
// from the flattened arrangement array, so that it gets to its supposed position.
// For example: vars = ("a", "b", "c"), arrangement = (("c"), ("a", "b"))
// you need to move c to position 0 (from the right), a to position 2 and b to position 1, so (0, 2, 1)
#let generate-bit-positions(vars, arrangement) = {
  // flatten the arrangement array
  let arrangement = arrangement.flatten()
  let vars = vars.flatten()

  let position-array = ()


  // REMOVE THIS CHECK FROM HERE. DO IT ELSEWHERE
  if (vars.len() != vars.dedup().len() or
    arrangement.len() != arrangement.dedup().len()) {
    panic("One or more variable(s) appear more than once in an arrangement.")
  }

  // // REMOVE THIS CHECK FROM HERE. DO IT ELSEWHERE
  // if vars.len() != arrangement.len() {panic("Too few arrangement variables")}

  // loop through all of the variables that are used in the arrangement array
  for variable-arrangement in arrangement {
    let found-match = false

    // counting from the right to the left of the variables array
    // search for a variable that matches the variable from the arrangement array
    // then push it to the position array
    for (i, variable) in vars.rev().enumerate() {
      if variable-arrangement == variable {
        position-array.push(i)
        found-match = true
        break
      }
    }

    // if no matching variable has been found, panic and report the error
    if not found-match {panic("One ore more variable names in the arrangement do not match a provided variable name.")}
  }
  position-array
}

// given two binary numbers b and a, where a only uses a-len bits,
// concatenate those two numbers. So for example, for b = 10011 and a = 10 with a-len = 2
// this becomes 1001110
#let concatenate-bits(b, a, a-len) = {
  a.bit-or(b.bit-lshift(a-len))
}

#let split-number-bits(number, left-count, right-count) = {
  let right = decode-gray-code(extract-lower-n(number, right-count))
  let left = decode-gray-code(extract-lower-n(number.bit-rshift(right-count), left-count))
  (left, right)
}

// apply the position-array, so move the bits to the correct positions
#let position-bits(position-array, bits) = {
  let var-count = position-array.len()
  let cell-gray = 0

  // now we arrange them according to the position array
  for i in range(var-count) {
    let bit = bits.bit-rshift(i).bit-and(1)
    bit = bit.bit-lshift(position-array.at(var-count - i -1))
    cell-gray = cell-gray.bit-or(bit)
  }
  cell-gray
}

// generate the gray code of each cell by returning a 2d array where
// each entry is the gray code of a cell
#let generate-cell-graycodes(vars, arrangement) = {
  let position-array = generate-bit-positions(vars, arrangement)

  // retrieve the amount of bits needed for rows and columns
  // this is equivalent to the number of variables used for rows and columns
  let row-bits = arrangement.at(0).len()
  let col-bits = arrangement.at(1).len()

  // calculate the amount of rows and columns based on the variables used for each
  let rows = calc.pow(2, row-bits)
  let cols = calc.pow(2, col-bits)

  let graycode-array = ()

  for i-row in range(rows) {
    let row-array = ()

    // this is the gray code of the current row
    let row-gray = calculate-gray-code(i-row)

    for i-col in range(cols) {

      // this is the gray code of the current column
      let col-gray = calculate-gray-code(i-col)

      // this is the resulting gray code of the cell, based on the variable arrangement
      // as well as the gray code of the row and column
      //
      // The position-array is a flattened version of the arrangement array
      // ((a, b), (c, d, e)) -> (a, b, c, d, e)
      // this means we also have to "flatten" the two gray codes into one
      let concatenated-code = concatenate-bits(row-gray, col-gray, col-bits)
      let cell-gray = position-bits(position-array, concatenated-code)

      row-array.push(cell-gray)
    }
    graycode-array.push(row-array)
  }

  // the resulting 2d array maps each cell in the resulting K-map
  // to its gray code
  graycode-array
}

#let calculate-coordinate-from-gray-code(number, positions-array, row-vars, col-vars) = {
  let reversed-positioning = position-bits(positions-array, number)
  split-number-bits(reversed-positioning, row-vars, col-vars)
}

#let calculate-coordinates-from-custom-highlightings(highlightings, arrangement, variables) = {
  let row-vars = arrangement.at(0).len()
  let col-vars = arrangement.at(1).len()

  let positions-array = generate-bit-positions(arrangement, variables)
  let term-coordinates-list = ()
  for single-term-highlightings in highlightings {
    let coordinates = ()
    for code in single-term-highlightings {
      let coordinate = calculate-coordinate-from-gray-code(code, positions-array, row-vars, col-vars)
      coordinates.push(coordinate)
    }
    if coordinates.len() == 0 {continue}
    term-coordinates-list.push(coordinates)
  }
  term-coordinates-list
}
