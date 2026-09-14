
/// Check for equality. 
#let eq(a, b) = {
  if a == b { return (true,) } 
  else {
    return (false, repr(a) + " != " + repr(b))
  }
}

/// Check for inequality. 
#let ne(a, b) = {
  if a != b { return (true,) } 
  else {
    return (false, repr(a) + " == " + repr(b))
  }
}

/// Check for approximate equality. 
#let approx(a, b, eps: 1e-10) = {
  if calc.abs(a - b) < eps { return (true,) } 
  else {
    return (false, str(a) + " !≈ " + str(b))
  }
}

#let assertations = (
  eq: eq,
  ne: ne,
  approx: approx
)


#let get-source-info-str(source-location) = {
  if source-location == none { return none }
  return "(" + source-location.module + ":" + str(source-location.line) + ")"
}



/// Implementation for doc-comment tests. All tests are run immediately. Fails if
///  at least one test did not succeed. 
///
/// This function is made available in all doc-comments under the name 'test'. 
#let test(

  /// Tests to run in form of raw objects. 
  /// -> any
  ..tests, 

  /// Additional definitions to make available for the evaluated test code.
  /// -> dictionary
  scope: (:), 

  /// Definitions that are made available to the entire parsed module including
  /// the test functions. This parameter is only used internally.
  /// -> dictionary
  inherited-scope: (:), 

  /// Information about the location of the test source code. Should contain
  /// values for the keys `module` and `line`. This parameter is only used internally.
  /// -> dictionary
  source-location: none,

  /// When set to `false`, the tests are ignored. 
  /// -> bool
  enable: true

) = {
  if not enable { return }
  let source-info = get-source-info-str(source-location)

  for test in tests.pos() {
    let result = eval(test.text, scope: scope + inherited-scope)
    let result-type = type(result)
    
    if result-type == array {
      if not result.at(0) {
        assert(
          false, 
          message: "Failed test " + source-info + ": " 
            + result.at(1) + "\nin " + test.text
        )
      }
    } else if result-type == bool {
      if not result {
        let msg = test.text
        assert(false, message: "Failed test " + source-info + ": " + msg)
      }
    } else {
      assert(
        false, 
        message: "Test \"" + test.text 
          + "\" at " + source-info 
          + " did not result in a boolean expression"
      )
    }
  }
}
