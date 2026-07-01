/// Chomp
/// Utility that enables the truncation of a string passed to a layout function
/// Usea a binary search to achieve O(log N) complexity.

/// Private
/// Utility function used by truncate-to-fit
#let _compare-dims(dims1, dims2) = {
  return dims1.width <= dims2.width and dims1.height <= dims2.height
}

/// Shortens `string` until `func(string, ..args)` fits within `width` and `height`, adding `prefix` and `suffix` if truncation is active
/// Uses a binary search to find the optimal truncation point in O(log N) time
///
/// ```example
/// #let s = lorem(50)
/// #truncate-to-fit(heading, s, width: none, height: 3em, suffix: "...", level: 3)
///
/// This panics if even truncation to an empty string (but with prefix and suffix) does not obey the given size constraints
///
/// -> content
#let truncate-to-fit(
  /// String argument that can be truncated
  /// -> str
  string,

  /// Function with signature `func(string, ..args) -> content`)
  /// Defaults to the text function
  /// -> (str, ..arguments) -> content
  func: text,

  /// Maximal width that must be achieved using truncation
  /// `none` indicates that the layout width should be used
  /// -> length | none
  width: none,

  /// Maximal height that must be achieved using truncation
  /// `none` indicates that the layout height should be used
  /// -> length | none
  height: none,

  /// Prefix that should be added to `string` if truncation is used
  /// -> str
  prefix: "",

  /// Suffix that should be added to `string` if truncation is used
  /// -> str
  suffix: "",

  /// Additional arguments passed to `func`
  /// -> arguments
  ..args
) = layout(size => {
  let _width = if width == none { size.width } else { width.to-absolute() }
  let _height = if height == none { size.height } else { height.to-absolute() }
  let target_dims = (width: _width, height: _height)

  // Check if string fits without modification, if so return without prefix/suffix
  let full_content = func(string, ..args)
  let full_dims = measure(full_content, width: size.width, height: size.height)

  if _compare-dims(full_dims, target_dims) {
    full_content
  } else {
    // Perform Binary Search to find longest substring combined with prefix/suffix.
    let low = 0
    let high = string.len()
    let best_len = none

    while low <= high {
      let mid = int((low + high) / 2)
      let candidate_str = prefix + string.slice(0, mid) + suffix
      let candidate_content = func(candidate_str, ..args)
      let dims = measure(candidate_content, width: size.width, height: size.height)

      if _compare-dims(dims, target_dims) {
        // Fits, try truncating less
        best_len = mid
        low = mid + 1
      } else {
        // Too big, truncate more
        high = mid - 1
      }
    }

    if best_len == none {
       panic("No amount of truncation could make content fit within given bounds.")
    }

    // Return largest string that fits
    func(prefix + string.slice(0, best_len) + suffix, ..args)
  }
})
