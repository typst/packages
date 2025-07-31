/// Given a value, transform it using the list of functions
#let pipe(input, transformations) = transformations.fold(
  input,
  ((x, f) => f(x)),
)

/// Given a list of transformations, apply them to a value
/// This is the curried version of its counterpart without `_` suffix
#let pipe_(transformations) = input => transformations.fold(
  input,
  ((x, f) => f(x)),
)

/// Apply a list of transformations from right to left to a value
#let compose(transformations, input) = transformations.rev().fold(
  input,
  ((x, f) => f(x)),
)

/// Compose a list of transformation from right to left into a single function.
/// This is the curried version of its counterpart without `_` suffix
#let compose_(transformations) = input => transformations.rev().fold(
  input,
  ((x, f) => f(x)),
)
