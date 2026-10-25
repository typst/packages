#import "../palettes.typ": on-color

// Keep the caption inside an inset image region, independent of page chrome.
#let render-image-caption(self, caption, credit, position: bottom, width: 100%, margin: 0em,
  fill: auto, text-fill: auto,
) = {
  assert(type(position) == alignment, message: "caption-position must be a Typst alignment, such as bottom or top + right.")
  assert(type(width) in (length, ratio, relative), message: "caption-width must be a length or percentage.")
  let position = ((if position.x == none { left } else { position.x }) +
    (if position.y == none { bottom } else { position.y }))
  let ink = if text-fill != auto { text-fill }
    else if fill != auto and type(fill) == color { on-color(fill) } else { self.colors.on-chrome }
  let background = if fill == auto { self.colors.chrome.transparentize(10%) } else { fill }
  block(width: 100%, height: 100%, inset: margin, above: 0em, below: 0em, breakable: false,
    layout(bounds => context {
      let width = if type(width) == ratio { bounds.width * width }
        else if type(width) == relative { width.ratio * bounds.width + width.length }
        else { width }
      let width = width.to-absolute()
      assert(0pt < width and width <= bounds.width,
        message: "caption-width must fit the image region after caption-margin.")
      let panel = block(width: width, above: 0em, below: 0em,
        inset: (x: 1.5em, y: 0.6em), fill: background, breakable: false, {
          set par(justify: false)
          show link: it => {
            show text: set text(fill: ink)
            it
          }
          set text(fill: ink)
          if caption != none { text(size: 0.9em, weight: "semibold", caption) }
          if credit != none {
            if caption != none { parbreak() }
            text(size: 0.65em, credit)
          }
        })
      let height = measure(panel).height
      assert(height <= bounds.height,
        message: "Image caption is too tall. Shorten it, increase caption-width, reduce caption-margin, or use a smaller text-size.")
      block(width: bounds.width, height: bounds.height, above: 0em, below: 0em,
        place(position, block(width: width, height: height, above: 0em, below: 0em, {
          [#metadata((width: width.pt(), height: height.pt(),
            position: repr(position), fill: background, text-fill: ink))<ambrosia-image-caption>]
          place(top + left, panel)
        })))
    }))
}
