// Fit metadata as one unit, scaling its typography and em-based spacing together.
// Fixed-size custom content that cannot fit fails explicitly rather than spilling.
#let fit-title(body, fit: true, min-scale: 65%, alignment: center + horizon, decoration: none) = {
  assert(type(fit) == bool, message: "Title fit must be true or false.")
  assert(0% < min-scale and min-scale <= 100%, message: "Title min-scale must be between 0% and 100%.")
  if not fit { return [#decoration#body] }
  layout(bounds => context {
    let render(scale) = block(width: bounds.width, breakable: false, text(size: text.size * scale, body))
    let height(scale) = measure(render(scale)).height
    let chosen = 100%
    if height(chosen) > bounds.height {
      assert(height(min-scale) <= bounds.height,
        message: "Title slide is too dense to fit at the minimum scale. Shorten the metadata, lower title-min-scale, or supply a custom title slide.")
      let low = min-scale
      let high = 100%
      for _ in range(12) {
        let mid = (low + high) / 2
        if height(mid) <= bounds.height { low = mid } else { high = mid }
      }
      chosen = low
    }
    block(width: bounds.width, height: bounds.height, breakable: false, {
      decoration
      [#metadata((scale: chosen / 100%, available: bounds.height.pt(), height: height(chosen).pt()))<ambrosia-title-fit>]
      place(alignment, render(chosen))
    })
  })
}
