/// splits the array into chunks of given size.
#let chunks(arr, size) = {
  let l = arr.len()
  let remfreelength = l - calc.rem(l, size)
  let rest = arr.slice(remfreelength)

  if rest.len() > 0 {
    range(remfreelength, step: size).map(i => arr.slice(i, i + size)) + (rest,)
  } else {
    range(remfreelength, step: size).map(i => arr.slice(i, i + size))
  }
}

/// inverse of zip method. array(pair) -> pair(array)
#let unzip(arr) = (arr.map(x => x.at(0)), arr.map(x => x.at(1)))

/// cycles through arr until length is met
#let cycle(arr, length) = {
  let l = calc.quo(length, arr.len())
  let add = calc.rem(length, arr.len())
  arr * l + arr.slice(0, add)
}

/// provides a running window of given size
#let windows(arr, size) = range(arr.len() - size + 1).map(x => arr.slice(x, x + size))

/// same as windows, but continues wrapping at the border
#let circular-windows(arr, size) = windows(arr + arr.slice(size - 1), size)

/// creates two arrays, 1. where f returns true, 2. where f returns false
#let partition(arr, f) = (arr.filter(f), arr.filter(x => not f(x)))

/// after partition, maps each partition according to g
#let partition-map(arr, f, g) = {
  let parts = partition(arr, f)
  (parts.at(0).map(g), parts.at(1).map(g))
}

/// groups the array into maximally sized chunks, where each elements yields same predicate value
#let group-by(arr, f) = if arr == () { (()) } else {
  let state = f(arr.at(0))
  let result = ((arr.at(0),),)
  for v in arr.slice(1, arr.len()) {
    if f(v) != state {
      result.push((v,))
      state = f(v)
    } else {
      result.last().push(v)
    }
  }
  result
}

/// inserts a value inbetween each element
#let intersperse(arr, sep) = if arr.len() < 2 { arr } else {
  (arr.zip((sep, ) * (arr.len() - 1)) + ((arr.last(),),)).sum() // flattening happens here with sum, as the flatten method acts recursively
  //range(2 * arr.len() - 2).map(i => if calc.rem(i, 2) == 0 { arr.at(calc.quo(i, 2)) } else { sep }) + (arr.last(),)
}

/// returns all elements until the predicate returns false
#let take-while(arr, f) = if arr == () { () } else {
  let max-index = arr.len()
  for (i, v) in arr.enumerate() {
    if not f(v) {
      max-index = i
      break
    }
  }
  arr.slice(0, max-index)
}

/// returns all elements starting when the predicate returns false
#let skip-while(arr, f) = if arr == () { () } else {
  let min-index = arr.len()
  for (i, v) in arr.enumerate() {
    if not f(v) {
      min-index = i
      break
    }
  }
  arr.slice(min-index)
}