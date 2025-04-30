/// #property(requires-context: true)
/// The default figure show rule. This can be used to display a figure the same
/// way as typst does by default.
///
/// -> content
#let show-figure(
  /// The figure to show using the default show rule.
  ///
  /// -> content
  it
) = {
  import "util.typ"

  // NOTE: this is written to be close to the rust impl to make changes easier
  // to compare

  let realized = it.body

  let caption = util.resolve-element-field(figure, it, "caption")
  if caption != none {
    let v = v(it.gap, weak: true)
    let position = _resolve(figure.caption, caption, "position")
    realized = if position == top {
      caption + v + realized
    } else {
      realized + v + caption
    }
  }

  realized = {
    set align(center)
    block(realized)
  }

  let placement = util.resolve-element-field(figure, it, "placement")
  if placement != none {
    realized = place(placement, float: true)
  }

  realized
}
