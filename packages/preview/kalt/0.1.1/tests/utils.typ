#import "../lib.typ": comp, reduce, tensor-variant

#let test-state = state("kalt-test-results", ())
#let ci-mode = sys.inputs.at("ci", default: "false") == "true"

// Returns whether `output` is the inline sertyp error representation.
#let is-error(output) = "sertyp:panic" in repr(output)

// Returns the diagnostic representation used for expected-error matching.
#let error-text(output) = repr(output)

// Compares scalar or complex scalar output with a tolerance of 1e-6.
#let validate-scalar(output, expected) = {
  let is-nan-or-inf(val) = {
    if val in ("NaN", "nan", "Inf", "inf") { return true }
    return false
  }
  let part(op, output) = {
    let c = comp($#op (#output)$)
    if ("body" not in c.fields()) { return none }
    let val = c.body.children.at(0).text
    if is-nan-or-inf(val) { return val }
    eval(val)
  }
  let (real, imag) = (part($Re$, output), part($Im$, output))
  let (expected-real, expected-imag) = (part($Re$, expected), part($Im$, expected))
  if real == none or imag == none or expected-real == none or expected-imag == none { return false }

  let dist(a, b) = {
    if is-nan-or-inf(a) and is-nan-or-inf(b) { return 0 } else if is-nan-or-inf(a) or is-nan-or-inf(b) {
      return 1e100000
    }
    calc.abs(a - b)
  }
  if dist(real, expected-real) > 1e-6 or dist(imag, expected-imag) > 1e-6 { return false }
  true
}

// Compares scalar or matrix output with the same scalar tolerance.
#let validate(output, expected) = {
  if type(output) != type(expected) { return false }
  if tensor-variant(output) == "matrix" {
    reduce((acc, output, expected) => acc and validate-scalar(output, expected), true, output, expected)
  } else {
    validate-scalar(output, expected)
  }
}

// Records one test result. Set `expect-error` for a test whose evaluation should fail.
#let record-test(name, output, expected: none, expect-error: false, error: none) = {
  let actual-error = is-error(output)
  let actual-error-text = if actual-error { error-text(output) } else { none }
  let passed = if expect-error {
    actual-error and (error == none or error in actual-error-text)
  } else {
    not actual-error and validate(output, expected)
  }
  let update = test-state.update(results => {
    results.push((
      name: name,
      passed: passed,
      expected-error: expect-error,
      error-contains: error,
      actual-error: actual-error,
      actual-error-text: actual-error-text,
      debug-output: if not passed and not expect-error { repr(output) } else { none },
      debug-expected: if not passed and not expect-error { repr(expected) } else { none },
    ))
    results
  })
  (passed, update)
}

// Asserts that an expression evaluates successfully to `expected`.
#let assert-eq(name, output, expected) = {
  let (_, update) = record-test(name, output, expected: expected)
  update
}

// Asserts that an expression evaluates to a sertyp error. If `contains` is set,
// the diagnostic representation must contain that text.
#let assert-error(name, output, contains: none) = {
  let (_, update) = record-test(name, output, expect-error: true, error: contains)
  update
}

// Emits the aggregate and per-test results as metadata for the CI runner.
#let emit-test-report() = context {
  let results = test-state.get()
  let passed = results.filter(result => result.passed).len()
  let report = (
    total: results.len(),
    passed: passed,
    failed: results.len() - passed,
    results: results,
    failures: results.filter(result => not result.passed),
  )
  [#metadata(report) <kalt-test-report>]
}

// Runs a table-driven binary operation test and renders it in visual mode.
#let binary-operation(title, description, op, ..cases) = {
  let rows = cases
    .pos()
    .enumerate()
    .map(((index, case)) => {
      let expression = op(case.v1, case.v2)
      let output = comp(expression)
      let expect-error = "error" in case
      let (passed, update) = record-test(
        title + " case " + str(index + 1),
        output,
        expected: if "e" in case { case.e } else { none },
        expect-error: expect-error,
        error: if expect-error { case.error } else { none },
      )
      if ci-mode { return update }
      (
        [#update #expression],
        block($#output$),
        if "e" in case { block($#case.e$) } else { [expected error: #case.error] },
        if passed { "PASS" } else { "FAIL" },
      )
    })
  if ci-mode { return rows.join() }
  [
    == #title
    #description
    #table(
      columns: 4,
      align: left,
      [*Input*], [*Output*], [*Expected*], [*Result*],
      ..rows.flatten(),
    )
  ]
}

// Runs a table-driven unary operation test and renders it in visual mode.
#let unary-operation(title, description, op, ..cases) = {
  let rows = cases
    .pos()
    .enumerate()
    .map(((index, case)) => {
      let expression = op(case.v)
      let output = comp(expression)
      let expect-error = "error" in case
      let (passed, update) = record-test(
        title + " case " + str(index + 1),
        output,
        expected: if "e" in case { case.e } else { none },
        expect-error: expect-error,
        error: if expect-error { case.error } else { none },
      )
      if ci-mode { return update }
      (
        [#update #expression],
        block($#output$),
        if "e" in case { block($#case.e$) } else { [expected error: #case.error] },
        if passed { "PASS" } else { "FAIL" },
      )
    })
  if ci-mode { return rows.join() }
  [
    == #title
    #description
    #table(
      columns: 4,
      align: left,
      [*Input*], [*Output*], [*Expected*], [*Result*],
      ..rows.flatten(),
    )
  ]
}

#let binary_operation = binary-operation
#let unary_operation = unary-operation
