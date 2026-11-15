#let check-type(name, value, expected-types, with-none: false) = {
  let ok = true
  let expected-types_display = expected-types.map(str).join(" or ")
  
  if with-none == true {
    expected-types_display = "none or " + expected-types_display
  }
  

  if with-none != true or value != none {
    ok = expected-types.any(t => type(value) == t)
  }

  assert(ok, message:
    "Invalid parameter `" + name + ".\n" +
    "  Received    : " + str(type(value)) + " (" + repr(value) + ")\n" +
    "  Expected : " + expected-types_display
  )
}

#let check-expected-keys(name, value, expected-keys) = {
  // expected-keys: dictionnaire (key: type-attendu ou tableau de types)
  for (key, expected-types) in expected-keys {
    assert(key in value,
      message: "`" + name + "` must contain the key \"" + key + "\"")

    let expected-types = if type(expected-types) == array { expected-types } else { (expected-types,) }
    let val = value.at(key)
    let ok = expected-types.any(t => type(val) == t)
    assert(ok,
      message: "`" + name + "." + key + "` must be of type " + expected-types.map(str).join(" or ") + ", received: " + str(type(val)))
  }
}

#let check-allowed-keys(name, value, allowed-keys) = {
  for (key, val) in value {
    assert(key in allowed-keys,
      message: "`" + name + "` contains unexpected key \"" + key + "\". Allowed keys: " + allowed-keys.keys().join(", "))

    let expected-types = allowed-keys.at(key)
    let ok = expected-types.any(t => type(val) == t)
    assert(ok,
      message: "`" + name + "." + key + "` must be of type " + expected-types.map(str).join(" or ") + ", received: " + str(type(val)))
  }
}

#let check-array-type(name, value, type) = {
  
}