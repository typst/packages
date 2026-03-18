// convert a sequence to a array splited by "|"
#let _tablem-tokenize(seq) = {
  let res = ()
  for cont in seq.children {
    if cont.func() == text {
      res = res + cont.text
        .split("|")
        .map(s => text(s.trim()))
        .intersperse([|])
        .filter(it => it.text != "")
    } else {
      res.push(cont)
    }
  }
  res
}

// trim first or last empty space content from array
#let _arr-trim(arr) = {
  if arr.len() >= 2 {
    if arr.first() == [ ] {
      arr = arr.slice(1)
    }
    if arr.last() == [ ] {
      arr = arr.slice(0, -1)
    }
    arr
  } else {
    arr
  }
}

// compose table cells
#let _tablem-compose(arr) = {
  let res = ()
  let column-num = 0
  res = arr
    .split([|])
    .map(_arr-trim)
    .map(subarr => subarr.sum(default: []))
  _arr-trim(res)
}

#let tablem(
  render: table,
  ignore-second-row: true,
  ..args,
  body
) = {
  let arr = _tablem-compose(_tablem-tokenize(body))
  // use the count of first row as columns
  let columns = 0
  for item in arr {
    if item == [ ] {
      break
    }
    columns += 1
  }
  // split rows with [ ]
  let res = ()
  let count = 0
  for item in arr {
    if count < columns {
      res.push(item)
      count += 1
    } else {
      assert.eq(item, [ ], message: "There should be a linebreak.")
      count = 0
    }
  }
  // remove secound row
  if (ignore-second-row) {
    let len = res.len()
    res = res.slice(0, calc.min(columns, len)) + res.slice(calc.min(2 * columns, len))
  }
  // render with custom render function
  render(columns: columns, ..args, ..res)
}
