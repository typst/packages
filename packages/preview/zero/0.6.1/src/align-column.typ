
#import "num.typ": num
#import "state.typ": num-state

/// Turns a series of numeral strings into an array of aligned numbers.
/// This can be used to generate cells for a column in a `table` or `stack`.
///
/// This function requires context from the caller.
///
/// -> array
#let align-column(
  /// Numerals and named options to pass on to `num`.
  /// -> str | int | float | content
  ..args,
) = {
  let num = num.with(
    align: "components",
    state: num-state.get(),
    ..args.named(),
  )

  let numbers = args.pos().map(num)

  let widths = numbers.map(components => components.map(x => measure(x).width))

  let max-widths = array.zip(..widths).map(col => calc.max(..col))

  return numbers.map(components => components
    .zip(max-widths, (right, left, left, left))
    .map(((body, width, alignment)) => box(width: width, align(
      alignment,
      body,
    )))
    .join())
}
