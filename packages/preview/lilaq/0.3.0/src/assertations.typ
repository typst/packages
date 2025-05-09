
/// Assert that two floats or arrays are equal up to a (configurable) epsilon. 
#let approx(
  /// First value.
  a, 
  /// Second value.
  b, 
  /// Epsilon.
  eps: 1e-12
) = {
  if type(a) == array and type(b) == array {
    assert(a.len() == b.len(), message: "Non-matching array lengths " + repr(a) + " / " + repr(b))
    for (x, y) in a.zip(b) {
      if calc.abs(x - y) >= eps and calc.abs(1 - calc.abs(x / y)) >= eps {
        assert(false, message: repr(x) + " was not approx equal to " + repr(y) )
        assert(false, message: repr(a) + " was not approx equal to " + repr(b) )
      }
    }
  } else {
    assert(calc.abs(a - b) < eps, message: str(a) + " and " + str(b) + " are not equal up to " + str(eps))
    
  }
}


#approx(1, 1)
#approx((5e45, 1e46, 1.4999999999999999e46, 2e46), (5e45, 1e46, 1.5e46, 2e46))



/// Assert that coordinate arrays passed to plots have the same length. 
#let assert-matching-data-dimensions(
  /// Array of $x$ coordinates. 
  x, 
  /// Array of $y$ coordinates. 
  y, 
  /// Other coordinate arrays (e.g., error bars) that should match the length of $x$ and $y$ coordinates. Only named arguments are accepted. 
  ..args,
  /// Function name. This can be used to improve the error message. Entries where the value is not an array are ignored. This is useful for cases like `xerr` that also take a single value. 
  fn-name: "", 
) = {
  let prefix = ""
  if fn-name != "" { prefix = "`" + fn-name + "()`: " }

  if y != none {
    assert(
      x.len() == y.len(), 
      message: prefix + "The dimensions for x (" + str(x.len()) + ") and y (" + str(y.len()) + ") don't match"
    )
  }
  
  for (key, value) in args.named() {
    if value == none { continue }
    if type(value) != array { continue }
    
    assert(
      x.len() == value.len(), 
      message: prefix + "The dimensions for x (" + str(x.len()) + ") and " + key + " (" + str(value.len()) + ") don't match"
    )
  }
}


/// Assert that there are no additional named arguments in an argument sink. 
#let assert-no-named(
  /// Argument sink.
  args, 
  /// Function name. This can be used to improve the error message. 
  fn: ""
) = {
  if args.named().len() == 0 { return }
  
  assert(false,
    message: "Unexpected named argument \"" + args.named().keys().first() + "\"" + if fn == "" {""} else {
      " in function " + fn + "()"
    }
  )
}

#let assert-dict-keys(
  dict, 
  mandatory: (),
  optional: (),
  name: "",
  message: auto,
  missing-message: auto,
  unexpected-message: auto
) = {
  name += " "
  for key in mandatory {
    if key not in dict {
      if message == auto {
        message = name + "dictionary expects key `" + key + "`"
      }
      if type(missing-message) == function {
        message = missing-message(key)
      }
      assert(
        false,
        message: message
      )
    }
    let _ = dict.remove(key)
  }
  for key in dict.keys() {
    if key not in optional {
      
      if message == auto {
        message = name + "dictionary found unexpected key `" + key + "` (expected " + (mandatory + optional).join(", ", last: ", or ") + ")"
      }
      if type(unexpected-message) == function {
        message = unexpected-message(key, (mandatory + optional).join(", ", last: ", or "))
      }
      assert(
        false,
        message: message
      )
    }
  }
}

// #assert-dict-keys((a: 12, b: "", c: "a"), mandatory: ("a", "b"), optional: ("c",))