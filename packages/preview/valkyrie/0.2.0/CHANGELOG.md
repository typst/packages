# [unreleased](https://github.com/jamesxX/valakyrie/releases/tags/)

`Valkyrie` is now a community-lead project and is now homed on the typst-community organisation.

## Added
- `Boolean` validation type
- `Content` validation type. Also accepts strings which are coerced into content types.
- `Color` validation type.
- `Optional` validation type. If a schema yields a validation error, the error is suppressed and the returned value is 'auto'
- `Choice` validation type. Tested value must be contained within the listed choices.
- `Date` validation type.
- Dictionaries can now provide a list of aliases for members.
- Dictionaries can now be coerced from values
- Arrays can be coerced from singular values.

## Removed

## Changed
- **(Breaking)** Schema generator function arguments are now uniform. Types are all now effectively a curried form of `base-type`. A table is provided in the manual to document these arguments.
- **(Breaking)** `transform` argument has been replaced with `pre-transform` (applied prior to validation), and `post-transform` (applied after validation).
- **(Breaking)** Dictionaries now take the schema definition of members as a dictionary in the first positional argument rather than a sink of named arguments.
- **(Breaking)** `strict` contextual flag is now applied on the type level rather than directly in the parse function. It is currently only applied in the dictionary type, and will cause an assertion to fail if s
- **(Breaking)** Dictionaries default to empty dictionaries rather than none.
- **(Potentially breaking)** Dictionaries that don't have a member that is present in the schema no longer produce an error outside of `strict` contexts.
- **(Potentially breaking)** `strict` contextual flag is now applied on the type level rather than directly in the parse function. It is currently only applied in the dictionary type, and will cause an assertion to fail if set to `true` when object being validated contains keys unknown to the schema.
- **(Breaking)** Assertions on values have been moved from named arguments to assertion generator functions. 

## Migration guide from v0.1.X
- Dictionary schema definitions will need additional braces to account for a change in the API layout
- `transform` is now `pre-transform`, and can be used to coerce values into types
- Assertions regarding the value being validated (length, magnitude, regex match) have now been moved from being named arguments to being passed in the `assertions` argument as an array.

---

# [v0.1.1](https://github.com/jamesxX/valakyrie/releases/tags/v0.1.1)
## Changed
- fixed syntax error in Typst 0.11+ because of internal context type

---

# [v0.1.0](https://github.com/jamesxX/valakyrie/releases/tags/v0.1.0)
Initial Release
