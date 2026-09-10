#import "@preview/ctxjs:0.5.0"

#let chart-context = ctxjs.new-context(
  ctxjs.load.load-module-bytecode(read("vegalite.kbc1", encoding: none)),
)

#let resolve-size(value, available, fallback, name) = {
  let resolved = if value == auto {
    fallback
  } else if type(value) == length {
    value
  } else if type(value) == ratio or type(value) == relative {
    let ratio-part = if type(value) == ratio { value } else { value.ratio }
    let length-part = if type(value) == ratio { 0pt } else { value.length }
    if ratio-part == 0% {
      length-part
    } else {
      assert(available.pt() < calc.inf, message: "nulite: relative " + name + " requires a bounded container")
      available * ratio-part + length-part
    }
  } else {
    panic("nulite: " + name + " must be auto, a length, or a relative length")
  }
  assert(resolved.pt() > 0 and resolved.pt() < calc.inf, message: "nulite: " + name + " must be positive and finite")
  resolved
}

#let render(width: auto, height: auto, zoom: 1, spec) = {
  assert(type(zoom) == int or type(zoom) == float, message: "nulite: zoom must be a number")
  assert(zoom > 0 and zoom < calc.inf, message: "nulite: zoom must be positive and finite")
  layout(size => {
    let chart-width = resolve-size(width, size.width, 300pt, "width")
    let chart-height = resolve-size(height, size.height, 200pt, "height")
    let (_, svg) = ctxjs.ctx.call-module-function(
      chart-context,
      "vegalite",
      "render",
      spec + (width: chart-width.pt() / zoom, height: chart-height.pt() / zoom),
    )
    image(bytes(svg), format: "svg", width: chart-width, height: chart-height, fit: "contain")
  })
}
