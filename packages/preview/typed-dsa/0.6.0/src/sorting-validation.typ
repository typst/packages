// Sorting-specific public input and role-style validation.
//
// Generic checks and diagnostic formatting remain in validate.typ. These
// helpers understand sorting inputs and trace customization roles.

#import "style.typ": validate-style, check-cell-customization-options
#import "validate.typ": (
  check-comparable, check-non-empty, fail, show-value,
)

#let sort-orders = ("asc", "desc")

// Role overrides restyle the cells an algorithm marks, so they take the same
// options as any other cell customization.
#let _check-sort-role-override(where, what, override) = {
  if override == none { return }
  check-cell-customization-options(where, what, override)
}

#let _resolve-array-input(where, array-input) = {
  if type(array-input) == dictionary and "values" in array-input {
    return (
      array-input.values,
      array-input.at("style", default: (:)),
    )
  }
  if type(array-input) != array {
    fail(
      where,
      "input is " + show-value(array-input),
      expected: "an array of values, or an array-view(...)",
      fix: "pass the values as an array, for example (5, 3, 8)",
    )
  }
  (array-input, (:))
}

// A sorting trace orders values against each other and needs something to
// order, so both preconditions are checked before any step is generated.
#let _resolve-sorting-input(where, array-input) = {
  let (values, style) = _resolve-array-input(where, array-input)
  check-non-empty(where, "values", values, fix: "pass at least one value to sort")
  check-comparable(where, "values", values)
  validate-style(where, style)
  (values, style)
}
