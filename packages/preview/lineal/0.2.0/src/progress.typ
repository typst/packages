#import "@preview/touying:0.5.3": utils
#import "brand.typ": colour

// Use slide counters so title slides and overlays do not skew progress.
#let progress-ratios(current, total, start: 1, end: auto, variant: "exact") = {
  assert(variant in ("broad", "near", "exact"), message: "progress: unknown variant")
  if total <= 0 { return (broad: (1, 0), near: (0, 1, 0), exact: (0, 1, 0, 0)).at(variant) }
  let current = calc.clamp(current, 0, total)
  let before = calc.clamp(start - 1, 0, current)
  let end = if end == auto { total } else { calc.clamp(end, current, total) }
  let parts = (
    broad: (current, total - current),
    near: (before, end - before, total - end),
    exact: (before, current - before, end - current, total - end),
  )
  parts.at(variant).map(value => value / total)
}

#let lineal-progress-bar(
  variant: "exact", height: 2pt, ratios: none,
  accent: colour.primary, remaining: colour.primary-light,
) = context {
  assert(variant in ("broad", "near", "exact"), message: "progress: unknown variant")
  let total = utils.last-slide-counter.final().first()
  let current = utils.slide-counter.get().first()
  let sections = query(heading.where(level: 1))
  let previous = sections.filter(section => section.location().position().page <= here().position().page)
  let future = sections.filter(section => section.location().position().page > here().position().page)
  let start = if previous.len() > 0 {
    utils.slide-counter.at(previous.last().location()).first()
  } else { 1 }
  let end = if future.len() > 0 {
    utils.slide-counter.at(future.first().location()).first() - 1
  } else { total }
  let values = if ratios == none {
    progress-ratios(current, total, start: start, end: end, variant: variant)
  } else { ratios }
  let fills = (
    broad: (accent, remaining),
    near: (black.transparentize(60%), accent, remaining),
    exact: (black.transparentize(60%), accent, remaining, black.transparentize(80%)),
  ).at(variant)
  assert(type(values) == array and values.len() == fills.len(),
    message: "progress: ratios must match the variant's segment count")
  assert(values.all(value => type(value) in (int, float) and value >= 0) and values.sum() > 0,
    message: "progress: ratios must be non-negative numbers with a positive total")
  let segments = values.enumerate().filter(pair => pair.last() > 0)
  grid(columns: segments.map(pair => pair.last() / values.sum() * 100%), rows: height,
    ..segments.map(pair => rect(width: 100%, height: height, fill: fills.at(pair.first()), stroke: none)),
  )
}
