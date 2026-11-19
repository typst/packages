// With an even count of vars, rows take even indices and columns take oddindices
// This gets swapped with an odd count
#let standard-1(vars) = {
  let row-vars-count = calc.floor(vars.len()/2)
  let col-vars-count = calc.ceil(vars.len()/2)

  let col-arrangement = ()
  for i in range(col-vars-count) {
    col-arrangement.push(vars.at(2 * i + if(row-vars-count == col-vars-count) {1} else {0}))
  }
  let row-arrangement = ()
  for i in range(row-vars-count) {
    row-arrangement.push(vars.at(2 * i + if row-vars-count == col-vars-count {0} else {1}))
  }
  (row-arrangement, col-arrangement)
}

#let standard-0(vars) = {
  let row-vars-count = calc.floor(vars.len()/2)

  (vars.slice(0, row-vars-count), vars.slice(row-vars-count))
}

// Generate the standard arrangements
// They are more closely described
#let generate-standard-arrangement(vars, standard) = {
  let arrangement = ()

  if standard == 0 {arrangement = standard-0(vars)}
  else if standard == 1 {arrangement = standard-1(vars)}
  else {panic("This standard is not defined.")}

  arrangement
}
