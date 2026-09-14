#import "/src/types.typ"

/// Silently drop any content that overflows.
/// -> option
#let ignore() = {
  ((type: types.opt.post, field: "overflow", payload: (fun: _ => {})),)
}

/// Loop the last page(s) until all content fits.
/// -> option
#let repeat(
  /// Adjust the number of pages copied from the end.
  /// -> int
  count: 1,
) = {
  ((type: types.opt.post, field: "overflow", payload: (repeat: (count: count,))),)
}

/// Print a warning if there is any overflow.
/// -> option
#let alert() = {
  ((type: types.opt.post, field: "overflow", payload: (alert: none)),)
}

/// Arbitrary handler.
/// -> option
#let custom(
  /// Should take as input a dictionary with fields
  /// #arg[raw], #arg[styled], #arg[structured].
  /// Most likely you should use #arg[styled], but if you
  /// want to pass the result to another MEANDER invocation then
  /// #arg[structured] would be more appropriate.
  /// -> function
  fun
) = {
  ((type: types.opt.post, field: "overflow", payload: (fun: fun)),)
}

/// Store the overflow in the given global state variable.
/// -> option
#let state(
  /// A state or its label.
  /// -> state | str
  state
) = {
  let state = if type(state) == std.state { state } else { std.state(state) }
  ((type: types.opt.post, field: "overflow", payload: (state: state)),)
}

/// Insert a pagebreak between the layout and the overflow regardless
/// of the available space.
/// -> option
#let pagebreak() = {
  ((type: types.opt.post, field: "overflow", payload: (fun: data => {
    std.colbreak()
    data.styled
  })),)
}

#let default = (
  overflow: (fun: data => data.styled),
)
