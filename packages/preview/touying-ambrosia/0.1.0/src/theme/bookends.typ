#import "../touying.typ": utils
#import "../utils.typ": call-or-display, call-or-return

// Decoration belongs to the slide body, so Touying moves/scales it together
// with that slide in notes previews and all second-screen positions.
#let cover-decoration(self, definition) = context layout(bounds => {
  let (width, height) = utils.get-page-dimensions(self)
  let margin = self.page.margin
  let edge(key, axis, fallback) = {
    let value = if margin == auto { fallback }
      else if type(margin) == dictionary { margin.at(key, default: margin.at(axis, default: margin.at("rest", default: 0em))) }
      else { margin }
    let whole = if axis == "x" { width } else { height }
    if type(value) == ratio { value * whole }
    else if type(value) == relative { value.ratio * whole + value.length }
    else { value }
  }
  let ml = edge("left", "x", (width - bounds.width) / 2)
  let mt = edge("top", "y", (height - bounds.height) / 2)
  if definition.background-image != none {
    place(top + left, dx: -ml, dy: -mt, block(width: width, height: height, clip: true, {
      [#metadata((width: width.to-absolute().pt(), height: height.to-absolute().pt()))<ambrosia-cover-region>]
      place(top + left, block(width: 100%, height: 100%, call-or-display(self, definition.background-image)))
      let overlay = call-or-return(self, definition.background-overlay)
      if overlay != none { place(top + left, rect(width: 100%, height: 100%, fill: overlay, stroke: none)) }
    }))
  }
})
