
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
  /// -> str | int | float | content
  ..args
) = {
  let state = num-state.get()
  let numbers = args.pos().map(num.with(align: "components", state: state, ..args.named()))
  let widths = numbers.map(components => 
    components.map(x => if x == none { 0pt } else { measure(x).width })
  )
  let max-widths = array.zip(..widths).map(col => calc.max(..col))
  // return args.pos().map(
  //   num.with(align: (col-widths: max-widths, col: 0), state: state, ..args.named())
  // )
  return numbers.map(components => 
    components
      .zip(max-widths, (right, left, left, left))
      .map(((body, width, alignment)) => box(width: width, align(alignment, body)))
      .join()
  )
}