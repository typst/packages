#let assert-mark(mark, kind: "tip") = {
  assert(type(mark) == function, message: "Invalid arrow " + kind + ", expected a function but got a " + str(type(mark)) + ". Ensure that you use e.g. `stealth.with(..)` instead of directly writing `stealth(..)`")
}

#let assert-dict-keys(dict, required: (), optional: ()) = {
  let keys = dict.keys()
  
  for key in required {
    if key not in keys {
      assert(false, message: "")
    }
  }
  let possible-keys = required + optional.dict
  for key in keys {
    if key not in possible-keys {
      assert(false, message: "Unexpected key \"" + key + "\"")
    }
  }
  assert(array)
}