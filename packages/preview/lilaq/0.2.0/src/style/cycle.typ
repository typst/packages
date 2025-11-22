
/// Creates a new style cycle on a given element with the specified properties.
/// 
/// The following example shows how to create a new style cycle with colors 
/// alternating between `red`, `blue`, and `green`. 
/// ```typ
/// let cycle = lq.cycle.generic(lq.style, fill: (red, blue, green))
/// ```
#let generic(element, ..properties) = {
  properties = properties.named()
  let keys = properties.keys()
  let values = array.zip(..properties.values())

  values.map(value => it => { 
    set element(..array.zip(keys, value).to-dict()); it 
  })
} 

#let generic-color(..properties) = {
  generic(style, ..properties)
}



/// Folds plotting style cycles with ascending precedence, i.e., settings from
/// the last cycle may override settings from the preceding cycles. 
#let fold(

  /// The cycles to fold element-wise. 
  /// -> array
  ..cycles, 

  /// How to fold cycles of different lengths. The options are:
  /// - `"strict"`: Cycles must have the same length.
  /// - `"shortest"`: Cycles are folded up to the last element of the shortest
  ///   cycle.
  /// - `"longest"`: Cycles that are too short are extended with empty elements
  ///   to the length of longest cycle before folding them. 
  /// - `"repeat"`: Cycles that are too short are repeated to the length of the
  ///   longest cycle before folding them.
  ///  
  /// -> "shortest" | "longest" | "repeat" | "strict"
  mode: "longest"

) = {
  cycles = cycles.pos().rev()

  if mode == "strict" {
    let lengths = cycles.map(cycle => cycle.len())
    if lengths.dedup().len() > 1 {
      assert(false, message: "Cycles must have the same length in strict mode")
    }

  } else if mode == "longest" {
    let max-length = calc.max(..cycles.map(cycle => cycle.len()))
    cycles = cycles.map(cycle => cycle + (it => it,) * (max-length - cycle.len()))

  } else if mode == "repeat" {
    let max-length = calc.max(..cycles.map(cycle => cycle.len()))
    cycles = cycles.map(cycle => {
      if cycle.len() == max-length { return cycle }
      (cycle * calc.ceil(max-length / cycle.len())).slice(0, max-length)
    })
  }

  array.zip(..cycles).map(sets => 
    it => sets.fold(it, (it, cycle) => cycle(it))
  )
}