#import "@preview/cetz:0.4.2" : canvas, draw

// creates the bar based on the previously calculated positions
#let create-bar(name, start, end, offset, is-horizontal, height, small-bar-len, bar-letter-distance, stroke) = {
  let content-position = (0, 0)
  let main-line = (0, 0)
  let small-line-1 = (0, 0)
  let small-line-2 = (0, 0)
  let anchor = ""
  let length = end - start

  if is-horizontal{
    let length = end - start

    content-position = ((start + length/2, offset + bar-letter-distance))
    main-line = ((start, offset), (end, offset))
    small-line-1 = ((end, offset - small-bar-len),(end, offset + small-bar-len))
    small-line-2 = ((start, offset - small-bar-len),(start, offset + small-bar-len))

    anchor = "south"

  }else{
    start = (height - 1) - start
    end = (height - 1) - end

    let length = end - start

    content-position = (offset - bar-letter-distance, start + length/2)
    main-line = ((offset, start), (offset, end))
    small-line-1 = ((offset - small-bar-len, end),(offset + small-bar-len, end))
    small-line-2 = ((offset - small-bar-len, start),(offset + small-bar-len, start))

    anchor = "east"
  }

  draw.content(content-position, (name), anchor: anchor)
  draw.line(main-line.at(0), main-line.at(1), stroke: stroke)
  draw.line(small-line-1.at(0), small-line-1.at(1), stroke: stroke)
  draw.line(small-line-2.at(0), small-line-2.at(1), stroke: stroke)
}

// finds wether a variable is "active" for a range of given rows/columns
// positions that are right after another, like (1, 2, 3) will be combined to (1,3) for a continuous line
#let value-in-line(lines, order) = {
  let arr = ()

  order = lines - order - 1

  lines = calc.pow(2, lines)

  let first = 1
  let last = 0
  let been-on = false

  for n in range(lines){
    let c = n.bit-xor(n.bit-rshift(1))
    let c = c.bit-rshift(order).bit-and(1)
    if c == 1 {
      if n != last + 1 {
        if been-on {
          arr.push((first + 1, last +1))
        }
        first = n
      }
      been-on = true
      last = n
    }

  }
  arr.push((first+1, last+1))
  arr
}

// find out, which variables cover which rows / columns
#let create-bar-values((arrangement)) = {
  let row-dict = (:)
  let col-dict = (:)

  for (i, row) in arrangement.at(0).enumerate() {
    let arr = value-in-line(arrangement.at(0).len(), i)
    row-dict.insert(row, arr)
  }
  for (i, col) in arrangement.at(1).enumerate() {
    let arr = value-in-line(arrangement.at(1).len(), i)
    col-dict.insert(col, arr)
  }

  (row-dict, col-dict)
}

// given the variables and an arrangement, determin how to shift the bits so that the arrangement becomes
// the original variables. For example: vars = ("a", "b", "c"), arrangement = (("c"), ("a", "b"))
// you need to move c to position 0, a to position 2 and b to position 1, so (0, 2, 1)
#let generate-bit-positions(vars, arrangement) = {
  let flattened-arrangement = arrangement.flatten()
  let position-array = ()

  if vars.len() != vars.dedup().len() or flattened-arrangement.len() != flattened-arrangement.dedup().len() {panic("One or more variables appear more than once")}

  if vars.len() != flattened-arrangement.len() {panic("Too few arrangement variables")}

  for variable-arrangement in flattened-arrangement {
    let found-match = false
    for (i, variable) in vars.rev().enumerate() {
      if variable-arrangement == variable {
        position-array.push(i)
        found-match = true
        break
      }
    }
    if not found-match {panic("Arrangement of variables doesnt match the provided variables.")}
  }
  position-array
}

// combines two binary values as specified in the position array.
// for example a = 110, b = 01, position-array = (4, 2, 3, 0, 1), dim - (3,2) -> 10110
#let arrange-bits(position-array, row-gray, col-gray,  (dim), two-values: true) = {
  let amount-of-vars = dim.at(0) + dim.at(1)
  let concatenated-bits = 0
  if two-values {
    concatenated-bits = col-gray.bit-or(row-gray.bit-lshift(dim.at(1)))
  } else {
    concatenated-bits = row-gray
  }

  let cell-gray = 0

  for i in range(amount-of-vars) {
    let bit = concatenated-bits.bit-rshift(i).bit-and(1)
    bit = bit.bit-lshift(position-array.at(amount-of-vars - i -1))
    cell-gray = cell-gray.bit-or(bit)
  }
  cell-gray
}

// generate the subscripts of each cell based on the gray code of the row and column
// using helper functions from above
#let generate-subscripts(vars, arrangement) = {
  let position-array = generate-bit-positions(vars, arrangement)
  let row-bits = arrangement.at(0).len()
  let col-bits = arrangement.at(1).len()

  let rows = calc.pow(2, arrangement.at(0).len())
  let cols = calc.pow(2, arrangement.at(1).len())

  let subscript-array = ()

  for i-row in range(rows) {
    let row-array = ()
    let row-gray = i-row.bit-xor(i-row.bit-rshift(1))
    for i-col in range(cols) {
      let col-gray = i-col.bit-xor(i-col.bit-rshift(1))
      let cell-gray = arrange-bits(position-array, row-gray, col-gray, (row-bits, col-bits))
      row-array.push(cell-gray)
    }
    subscript-array.push(row-array)
  }

  subscript-array
}

// generates two standard arrangements for variables in k-maps.
// 0: alternating between row and column labeling, starting from the right
// 1: rows first, then columns, starting from the left
#let generate-standard-arrangements((vars), mode) = {
  let arrangement = ()
  let row-vars = calc.floor(vars.len()/2)
  let col-vars = calc.ceil(vars.len()/2)

  if mode == 0 {
    let col-arrangement = ()
    for i in range(col-vars) {
      col-arrangement.push(vars.at(2 * i + if(row-vars == col-vars) {1} else {0}))
    }
    let row-arrangement = ()
    for i in range(row-vars) {
      row-arrangement.push(vars.at(2 * i + if(row-vars == col-vars) {0} else {1}))
    }
    arrangement = (row-arrangement, col-arrangement)
  }

  if mode == 1 {
    arrangement = (vars.slice(0, row-vars), vars.slice(row-vars))
  }
  arrangement
}

// place the values based on the generated subscripts
#let arrange-values((values), subscripts, default) = {
  let arr = ()
  for i in range(subscripts.len()){
    let temp = ()
    for n in range(subscripts.at(i).len()){
      temp.push(values.at(subscripts.at(i).at(n), default: default))
    }
    arr.push(temp)
  }
  arr
}

// given a term, parse it so that it can later be used to compare it to the subscripts
#let parse-terms(vars, term) = {
  let arrangement = term.split(",")
  let var-val = ()
  let x = 0
  let mask = 0
  let provided-variable-count = arrangement.len()
  let amount-of-vars = vars.len()

  for i in range(arrangement.len()) {
    arrangement.at(i) = arrangement.at(i).trim(" ")
    if arrangement.at(i).first() == "!" {
      var-val.push(arrangement.at(i).trim("!"))
    }
    else {
      var-val.push(arrangement.at(i))
    }
  }
  for (i, var) in vars.enumerate() {
    if not var in var-val {var-val.push(var)}
  }
  for (i, var) in var-val.enumerate() {
    if i >= provided-variable-count {
      break
    }
    mask = mask.bit-or(1.bit-lshift(amount-of-vars - i -1))
    if arrangement.at(i).starts-with("!") {continue}
    x = x.bit-or(1.bit-lshift(amount-of-vars - i -1))
  }
  let position-array = generate-bit-positions(vars, var-val)

  mask = arrange-bits(position-array, mask, 0, (amount-of-vars, 0), two-values: false)
  x = arrange-bits(position-array, x, 0, (amount-of-vars, 0), two-values: false)

  (mask, x)
}

// parse multiple terms and put them into an array
#let find-terms(vars, terms) = {
  let parsed-terms = ()
  for term in terms{
    parsed-terms.push(parse-terms(vars, term))
  }
  parsed-terms
}

// use the parsed terms to determine what cells should be active
#let find-matching-term-positions(parsed-terms, subscripts) = {
  let coordinates = ()
  for term in parsed-terms {
    let inb = ()
    for (i-row, row) in subscripts.enumerate() {
      for (i-col, cell-code) in subscripts.at(i-row).enumerate() {
        if cell-code.bit-and(term.at(0)) == term.at(1) {
          inb.push((i-col, i-row))
        }
      }
    }
    coordinates.push(inb)
  }
  coordinates
}

// create the standard "label" based on the provided variables
#let create-var-string(vars) = {
  let string = ""
  for (i, var) in vars.enumerate() {
    string = string + if i != 0 {", "} else {""} + var
  }
  string
}

//arrange the display variables in the same way as the functional variables
#let arrange-disp-vars(var-disp, arrangement, vars) = {
  let var-disp-len = var-disp.len()
  let var-len = vars.len()

  let new-disp = ()

  for row in arrangement {
    let inb = ()
    for (i-col, val) in row.enumerate() {
      let index = vars.position(x => x == val)
      inb.push(var-disp.at(index, default: vars.at(index)))
    }
    new-disp.push(inb)
  }
  new-disp
}
