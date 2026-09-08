#import "/src/types.typ"

/// Disables the automatic vertical spacing to mimic the space taken
/// by the MEANDER layout.
/// -> option
#let phantom() = {
  ((type: types.opt.pre, field: "virtual-spacing", payload: false),)
}

/// Controls the margins before and after the MEANDER layout.
#let spacing(
  /// Margin above the layout -> auto | length
  above: auto,
  /// Margin below the layout -> auto | length
  below: auto,
  /// Affects #arg[above] and #arg[below] simultaneously. -> auto | length
  both: auto,
) = {
  let payload = (:)
  if both != auto {
    payload.above = both
    payload.below = both
  }
  if above != auto {
    payload.above = above
  }
  if below != auto {
    payload.below = below
  }
  ((type: types.opt.pre, field: "spacing", payload: payload),)
}

#let default = (
  //full-page: false,
  virtual-spacing: true,
  spacing: (:),
)
