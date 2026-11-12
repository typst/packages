// The intro between the header and the first section: the CV's
// summary, from the slot `sections/intro.typ` maps `basics.summary`
// onto. (The objective sits in the header, under the tagline.)

#import "../context.typ": _theme
#import "../primitives.typ": _prose

#let _intro-block(summary: none) = if summary != none {
  context {
    let (above, below) = _theme().intro
    v(above * text.size)
    _prose(summary)
    v(below * text.size)
  }
}
