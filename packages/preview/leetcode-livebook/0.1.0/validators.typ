// validators.typ - Validator definitions for test comparison
// Depends on: helpers.typ (for unordered-compare, float-compare)

#import "utils.typ": float-compare, unordered-compare
#import "problems.typ": format-id

// Default validator - direct equality
#let default-validator = (input, expected, yours) => expected == yours

// Built-in validators dispatch table
// All validators have signature: (input, expected, yours) => bool
#let validators = (
  "default": default-validator,
  "unordered-compare": (input, expected, yours) => unordered-compare(
    expected,
    yours,
  ),
  "float-compare": (input, expected, yours) => float-compare(expected, yours),
  // "custom" is a special value - loads from validator.typ
)

// Load validator from problem.toml
// Returns validator function with signature (input, expected, yours) => bool
#let load-validator(id-str, base) = {
  let info = toml("problems/" + id-str + "/problem.toml")

  // Check for custom validator file first
  if info.at("validator", default: none) == "custom" {
    import (base + "validator.typ"): validator
    return validator
  }

  // Check for named validator in dispatch table
  if "validator" in info {
    let val-name = info.at("validator")
    if val-name in validators {
      return validators.at(val-name)
    }
  }

  // Default validator
  default-validator
}
