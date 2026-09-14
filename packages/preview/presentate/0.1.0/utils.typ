#let merge-dicts(dictA, base: (:)) = {
  for (key, val) in dictA {
    if type(val) == dictionary and key in base.keys() {
      base.insert(key, merge-dicts(dictA.at(key), base: base.at(key)))
    } else {
      base.insert(key, val)
    }
  }
  return base
}


#let subtract-array(arr1, arr2) = {
  let reps = calc.max(arr1.len(), arr2.len())
  let out = ()
  for i in range(reps) {
    out.push(arr1.at(i, default: 0) - arr2.at(i, default: 0))
  }
  out
}