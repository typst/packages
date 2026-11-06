#import "../base-type.typ": base-type, assert-base-type
#import "../ctx.typ": z-ctx

/// Valkyrie schema generator for integer- and floating-point numbers
///
/// - name (internal):
/// - default (string): Default value to set if none is provided. *MUST* respect all other
///   validation requirements.
/// - min (integer, none): If not none, the minimum string length that satisfies the validation.
///   *MUST* be a positive integer. The program is *ILL-FORMED* if `min` is greater than `max`.
/// - max (integer, none): If not none, the maximum string length that satisfies the validation.
///   *MUST* be a positive integer. The program is *ILL-FORMED* if `max` is less than `min`.
/// - length (integer, auto): If not auto, the exact string length that satisfies validation.
///   *MUST* be a positiive integer. The program *MAY* be *ILL-FORMED* is concurrently set with
///   either `min` or `max`.
/// - includes (array, string, none): If set, a coerced array of required strings that are required
///   to pass validation.
/// - starts-with (string, regex, none): If set, a string or regex requirement that the string
///   *SHOULD* start with in order to pass validation.
/// - ends-with (string, regex, none): If set, a string or regex requirement that the string
///   *SHOULD* end with in order to pass validation.
/// - pattern (string, regex, none): If set, a string or regex requirment over the entire string
///   that *SHOULD* be matched in order to pass validation.
/// - pattern-error (string, auto): If set, the error thrown if `pattern` is not satisfied.
/// - transform (function): A transformation applied after successful validation.
/// -> schema
#let string(
  name: "string",
  default: none,
  min: none,
  max: none,
  length: auto,
  includes: (),
  starts-with: none,
  ends-with: none,
  pattern: none,
  pattern-error: auto,
  transform: it=>it,
) = {
  // Program is ill-formed if length is set at the same time as min or max

  // Type safety
  assert(type(default) in (str, type(none)),
    message: "Default of string must be of type string or none",
  )

  assert(type(min) in (int, type(none)), message: "Minimum length must be an integer")
  if min != none { assert(min >= 0, message: "Minimum length must be a positive integer") }

  assert(type(max) in (int, type(none)), message: "Maximum length must be an integer")
  if max != none { assert(max >= 0, message: "Maximum length must be a positive integer") }

  assert(type(length) in (int, type(auto)), message: "Length must be an integer")
  if length != auto { assert(length >= 0, message: "Maximum length must be a positive integer") }

  if type(includes) == str { includes = (includes,) }
  assert(type(includes) == array,
    message: "Includes must be an array of string or regex primitives",
  )
  for each in includes {
    assert(type(each) in (str, regex),
      message: "Includes must be an array of string or regex primitives",
    )
  }

  assert(type(starts-with) in (str, regex, type(none)),
    message: "Starts-with must be of type string or regex",
  )
  assert(type(ends-with) in (str, regex, type(none)),
    message: "Ends-with must be of type string or regex",
  )
  assert(type(pattern) in (regex, type(none)), message: "Pattern must be of type regex")
  assert(type(pattern-error) in (str, type(auto)), message: "Pattern-error must be a string")
  assert(type(transform) == function,
    message: "Transform must be a function that takes a single string and return a string",
  )

  base-type() + (
    name: name,
    default: default,
    min: min,
    max: max,
    length: length,
    includes: includes,
    starts-with: starts-with,
    ends-with: ends-with,
    pattern: pattern,
    pattern-error: pattern-error,
    transform: transform,
    validate: (self, it, ctx: z-ctx(), scope: ()) => {
      // Default value
      if it == none { it = self.default }

      // String must be a string
      if not (self.assert-type)(self, it, scope: scope, ctx: ctx, types: (str,)) {
        return none
      }

      // Minimum length
      if self.min != none and (it.len() < self.min) {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,
          message: "String length less than specified minimum of " + str(self.min),
        )
      }

      // Minimum length
      if self.max != none and (it.len() > self.max) {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,
          message: "String length greater than specified maximum of " + str(self.max),
        )
      }

      // Exact length
      if self.length != auto and (it.len() != self.length) {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,
          message: "String length must exactly equal " + str(self.length),
        )
      }

      // Includes
      for required-include in self.includes {
        if not it.contains(required-include) {
          return (self.fail-validation)(
            self,
            it,
            ctx: ctx,
            scope: scope,
            message: "String must include " + str(required-include),
          )
        }
      }

      // startswith
      if self.starts-with != none and not it.starts-with(self.starts-with) {
        return (self.fail-validation)(
          self,
          it,
          ctx: ctx,
          scope: scope,

          message: "String must start with " + str(self.starts-with))
      }

      // ends with
      if self.ends-with != none and not it.ends-with(self.ends-with) {
        return (self.fail-validation)(self, it, ctx: ctx, scope: scope,
          message: "String must end with " + str(self.ends-with))
      }

      // regex, possibly extend to custom like other types?
      if self.pattern != none and (it.match(self.pattern) == none) {
        let message = "String failed to match following pattern: " + repr(self.pattern)
        if self.pattern-error != auto { message = self.pattern-error }
        return (self.fail-validation)(self, it, ctx: ctx, scope: scope, message: message)
      }

      (self.transform)(it)
    }
  )
}

/// A specialization of string that is satisfied only by email addresses. *Note*: The testing is not
/// rigourous to save on complexity.
#let email = string.with(
  name: "email",
  pattern: regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]{2,3}){1,2}$"),
  pattern-error: "String must be an email address",
)

// TODO(james): url
// TODO(james): emoji
// TODO(james): uuid

/// A specialization of string that is satisfied only by valid IP addresses. *Note*: The testing
/// *IS* strict.
#let ip = string.with(
  name: "ip",
  pattern: regex("^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$"),
  pattern-error: "String must be a valid IP address"
)

// Transformations:
#let transform-trim = string.with(transform: str.trim)
#let transform-lowercase = string.with(transform: lower)
#let transform-uppercase = string.with(transform: upper)
