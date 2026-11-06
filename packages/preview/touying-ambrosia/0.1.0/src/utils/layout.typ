/// Call a `self => {..}` function recursively and return the final result, or just return the content.
///
/// -> content
#let call-or-display(self, it) = {
  while type(it) == function {
    it = it(self)
  }
  return [#it]
}


/// Call a `self => {..}` function recursively and return the final result.
///
/// -> content
#let call-or-return(self, it) = {
  while type(it) == function {
    it = it(self)
  }
  return it
}

/// Keep footer fields on one line; readable-size overflow gets a visible ellipsis.
#let fitted-footer-field(body, alignment: center, background: white, min-scale: 80%, complete: false) = layout(bounds => context {
  let natural = measure(box(body), width: 10000pt)
  if natural.width == 0pt or natural.height == 0pt { return body }
  let fitting = calc.min(100%, bounds.width / natural.width * 100%, bounds.height / natural.height * 100%)
  let chosen = if complete { fitting } else { calc.max(min-scale, fitting) }
  let scaled = scale(x: chosen, y: chosen, reflow: true,
    box(width: natural.width + 0.01pt, height: natural.height, body))
  let overflow = chosen > fitting
  block(width: bounds.width, height: bounds.height, breakable: false, clip: true, {
    [#metadata((scale: chosen / 100%, overflow: overflow, complete: complete,
      available: bounds.width.pt(), width: (natural.width * chosen).pt()))<ambrosia-footer-fit>]
    if overflow {
      place(left + horizon, scaled)
      place(right + horizon, box(fill: background, inset: (left: 0.25em),
        text(size: text.size * chosen)[#sym.dots.h.c]))
    } else {
      place(alignment + horizon, scaled)
    }
  })
})


/// Display text with adaptive size to fit in its container
#let adaptive-display(body, min-size: 0.35em) = layout(bounds => context {
  let low = min-size.to-absolute().pt()
  let high = text.size.pt()
  for _ in range(15) {
    // binary search
    let mid = (low + high) / 2
    let current-size = mid * 1pt
    let m = measure(block(width: bounds.width, text(size: current-size, body)))
    if m.height <= bounds.height {
      low = mid
    } else {
      high = mid
    }
  }
  text(size: low * 1pt, body)
})


/// Prose display title and subtitle with adaptive size to fit in its container
#let adaptive-prose-display-title-subtitle(
  title,
  subtitle,
  spacing: 1em,
  min-size: 0.35em,
) = layout(bounds => context {
  let low = min-size.to-absolute().pt()
  let high = text.size.pt()
  let content = title + h(spacing) + subtitle
  for _ in range(15) {
    // binary search
    let mid = (low + high) / 2
    let current-size = mid * 1pt
    let m = measure(block(width: bounds.width, text(size: current-size, content)))
    if m.height <= bounds.height {
      low = mid
    } else {
      high = mid
    }
  }
  text(size: low * 1pt, content)
})
