/// Numblex main function
///
/// - `numberings`: A tuple of numbering styles. Each style can be a string or a function.
/// - `depth`: A tuple of depths for each numbering style.
/// - `..styles`: A list of styles. If provided, `numberings` and `depth` will be ignored.
///
/// The depth means the level of shown (upper) numbering, default is 1(only show the level at present).
///
/// Example usage:
/// ```typst
/// set heading(numbering: numblex(numberings: ("一.", "1.", "(1).", circle_numbers), depth: (1, 1, 2, 4)))
///
/// set heading(numbering: numblex(
///   "一.",
///   "1.",
///   (numbering: "(1).", depth: 2),
///   (numbering: circle_numbers, depth: 4),
/// ))
/// ```
#let numblex(numberings: (none,), depth: (1,), ..styles) = {
  styles = styles.pos()
  if styles.len() > 0 {
    numberings = ()
    depth = ()
    for s in styles {
      if type(s) == str {
        s = (numbering: s, depth: 1)
      }
      assert("numbering" in s, message: "numblex: style must have a 'numbering' field")
      assert("depth" in s, message: "numblex: style must have a 'depth' field")
      assert(type(s.numbering) in (function, str), message: "numblex: 'numbering' field must be a function or a string")
      assert(type(s.depth) == int and s.depth > 0, message: "numblex: 'depth' field must be a positive integer")
      numberings.push(s.numbering)
      depth.push(s.depth)
    }
  }

  assert(numberings.len() > 0, message: "numblex: at least one numbering style must be provided")
  assert(depth.len() > 0, message: "numblex: at least one depth must be provided")

  let get_repeat_last(arr, ind) = {
    arr.at(ind, default: arr.at(-1))
  }

  return (..numbers) => {
    let nums = numbers.pos()
    let max_level = nums.len()
    let this_depth = get_repeat_last(depth, nums.len() - 1)
    let ans = ""

    for level in range(max_level - this_depth, max_level) {
      ans = ans + numbering(get_repeat_last(numberings, level), nums.at(level))
    }

    return ans
  }
}
