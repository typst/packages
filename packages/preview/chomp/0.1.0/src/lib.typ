/// Chomp
/// Utility that enables the truncation of a string passed to a layout function

/// Private
/// Utility function used by truncate-to-fit
#let _compare-dims(dims1, dims2) = {
  return dims1.width <= dims2.width and dims1.height <= dims2.height
}

/// Shortens `string` until `func(string, ..args)` fits within `width` and `height`,
/// adding `prefix` and `suffix` if truncation is active
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
  /// This could for example be `CONTINUED: ` or something along those lines
  /// -> str
  prefix: "",

  /// Suffix that should be added to `string` if truncation is used
  /// This could for example be `...`, `…`, or something along those lines
  /// -> str
  suffix: "",

  /// Additional arguments passed to `func`
  /// -> arguments
  ..args
) = layout(size => {
  let _string = string
  let _width = if width == none { size.width } else { width.to-absolute() }
  let _height = if height == none { size.height } else { height.to-absolute() }

    let laid-out = func(string, ..args)
    while not _compare-dims(measure(laid-out, width: size.width, height: size.height), (width: _width, height: _height)) {
      if _string.len() == 0 { panic("No amount of truncation could make content fit within given bounds.") }
      _string = _string.slice(0, -1)
      laid-out = func(prefix + _string + suffix, ..args)
    }

    laid-out
  }
)
