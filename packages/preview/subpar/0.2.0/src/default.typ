// NOTE: we avoid a possible syntax error in the future when custom elements are added and self may become a keyword by appending an underscore

#let _resolve(elem, it, field) = {
  if it.has(field) {
    it.at(field)
  } else {
    // we can't func.at(field) to resolve the field
    // eval(repr(elem) + "." + field)
    elem.at(field)
  }
}

/// The default figure show rule. The active set rules will be used.
///
/// This function is contextual.
///
/// - self_ (content): The figure to show using the defualt show rule.
/// -> content
#let show-figure(self_) = {
  // NOTE: this is written to be close to the rust impl to make changes easier to compare

  let realized = self_.body

  let caption = _resolve(figure, self_, "caption")
  if caption != none {
    let v = v(self_.gap, weak: true)
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

  let placement = _resolve(figure, self_, "placement")
  if placement != none {
    realized = place(placement, float: true)
  }

  realized
}
