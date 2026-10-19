#import "../palettes.typ": prefer-light, contrast, on-color
#import "../colors.typ"

// Decoration only: no layout space, counters, or citation/heading content.
#let watermark-mark(self, background, height, opacity: auto) = {
  let source = self.store.at("watermark-logo", default: none)
  if source == none { return none }
  let fill = if prefer-light(background) { colors.light-ink }
    else if type(background) == color and contrast(self.colors.primary, background) < 2.5 { on-color(background) }
    else { self.colors.primary }
  let data = source(fill)
  let opacity = if opacity == auto { self.store.at("watermark-opacity", default: 5.5%) } else { opacity }
  assert(type(opacity) == ratio and 0% <= opacity and opacity <= 100%,
    message: "Watermark opacity must be a percentage between 0% and 100%, such as 5.5%.")
  // Root opacity applies once to the entire SVG, including overlapping paths.
  let data = str(data).replace(regex("<svg\\b[^>]*>"), match => {
    let root = match.text.replace(regex("\\sopacity\\s*=\\s*[\"'][^\"']*[\"']"), "")
    root.replace(">", " opacity=\"" + str(opacity / 100%) + "\">")
  })
  image(bytes(data), height: height)
}

#let watermark-layer(self, background, width, height, size: 50%, opacity: auto) = {
  let mark = watermark-mark(self, background, height * size, opacity: opacity)
  if mark == none { return none }
  let dimensions = measure(mark)
  block(width: width, height: height, clip: true, breakable: false,
    place(bottom + right, dx: dimensions.width * 25%, dy: dimensions.height * 20%, mark),
  )
}
