// citrus - Compiler Runtime Helpers

#import "../../data/conditions.typ": check-type, eval-condition
#import "../../output/helpers.typ": content-to-string

#import "names.typ": (
  format-names-compiled, format-names-multi-compiled,
  format-names-single-compiled, format-names-substitute-compiled,
)
#import "date.typ": format-date-compiled
#import "number.typ": (
  format-number-compiled, format-number-long-ordinal-compiled,
  format-number-numeric-compiled, format-number-ordinal-compiled,
  format-number-roman-compiled,
)
#import "label.typ": format-label-compiled
#import "text.typ": (
  format-text-content, format-text-value, format-text-value-raw,
  get-text-variable, get-text-variable-planned, get-text-variable-raw,
)
#import "term.typ": get-term-compiled, get-term-raw
#import "conditions.typ": has-variable

#import "../../core/mod.typ": finalize, is-empty
#import "../../data/variables.typ": get-variable
#import "../../parsing/mod.typ": lookup-term

/// Normalize content to avoid nested arrays in joins
#let normalize-content(content) = {
  if type(content) == bool { return [] }
  if type(content) != array { return content }
  let result = []
  for item in content {
    let normalized = normalize-content(item)
    if normalized != [] and normalized != none and normalized != "" {
      result = [#result#normalized]
    }
  }
  result
}

/// All helpers bundled for passing to eval()
#let compiler-helpers = (
  normalize-content: normalize-content,
  content-to-string: content-to-string,
  format-names: format-names-compiled,
  format-names-single: format-names-single-compiled,
  format-names-multi: format-names-multi-compiled,
  format-names-substitute: format-names-substitute-compiled,
  format-date: format-date-compiled,
  format-number: format-number-compiled,
  format-number-numeric: format-number-numeric-compiled,
  format-number-ordinal: format-number-ordinal-compiled,
  format-number-long-ordinal: format-number-long-ordinal-compiled,
  format-number-roman: format-number-roman-compiled,
  format-label: format-label-compiled,
  get-text-variable: get-text-variable,
  get-text-variable-raw: get-text-variable-raw,
  get-text-variable-planned: get-text-variable-planned,
  format-text-content: format-text-content,
  format-text-value: format-text-value,
  format-text-value-raw: format-text-value-raw,
  get-term: get-term-compiled,
  get-term-raw: get-term-raw,
  has-variable: has-variable,
  get-variable: get-variable,
  check-type: check-type,
  eval-condition: eval-condition,
  finalize: finalize,
  is-empty: is-empty,
  lookup-term: lookup-term,
)
