// Color links
// https://github.com/typst/typst/issues/5614
#let color-links(
  /// Color external links (default: blue mixed with current text color)
  external: auto,
  /// Color internal links except {glossary links and citations}
  /// use `auto` for default color
  internal: none,
  body,
) = {
  // TODO: do we need these glossy utility functions or not? They are only
  // part of a fork, not yet contributed upstream.
  // Also: when not using glossy, we don't want to import it!!
  //import "../../utils/lib.typ": glossy
  //import glossy(): is-glossy-link, is-glossy-ref

  // Need a function due to needed #context.
  // Such a function can be used as a color in the arguments.
  let ex-color = if external == auto { () => text.fill.mix((blue, 400%)) } else { external }
  let in-color = if internal == auto { maroon } else { internal }

  // Return true when the destination should be excluded
  let internal-excluded(dest) = {(
    // It looks like this should actually be enough to exclude glossy links,
    // no need to import is-glossy-link?
    type(dest) == label and str(dest).starts-with("__gloss")
    or
    // don't color links when in the outline
    state("in-outline", false).get() == true
  )}

  show link: l => {
    if type(l.dest) == str and ex-color != none {
      set text(fill: if type(ex-color) == function {ex-color()} else {ex-color})
      l
    } else {
      l
    }
  }
  show link: l => {
    if type(l.dest) != str and in-color != none {
      context if internal-excluded(l.dest) {
        l
      } else {
        text(fill: in-color, l)
      }
    } else {
      l
    }
  }
  show ref: r => {
    // Recognizing glossy refs is *probably* not needed if this show rule is
    // before init-glossary, since glossy `ref`s are destructively turned into links.
    if r.element != none and in-color != none {//and not is-glossy-ref(r) {
      text(fill: in-color, r)
    } else {
      // Will not color a citation, since a citation has no element
      r
    }
  }

  body
}
