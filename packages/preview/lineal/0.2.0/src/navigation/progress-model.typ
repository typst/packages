// Pure arithmetic: no document queries, counters, colours or rendering.
#let segment-count(variant) = {
  assert(variant in ("broad", "near", "exact"), message: "progress: unknown variant")
  (broad: 2, near: 3, exact: 4).at(variant)
}

#let finite-number(value) = type(value) in (int, float) and value == value and -calc.inf < value and value < calc.inf

/// Divide by the largest weight before summing, so large finite inputs cannot
/// overflow their total. Zero weights retain their position in the result.
#let normalize-progress(weights, variant: "exact") = {
  let count = segment-count(variant)
  assert(type(weights) == array and weights.len() == count,
    message: "progress: ratios must match the variant's segment count")
  assert(weights.all(value => finite-number(value) and value >= 0),
    message: "progress: ratios must be finite non-negative numbers")
  let maximum = calc.max(..weights)
  assert(maximum > 0, message: "progress: ratios must have a positive total")
  let scaled = weights.map(value => value / maximum)
  let total = scaled.sum()
  scaled.map(value => value / total)
}

/// Logical slides, including the current slide, determine completion. The data
/// adapter saturates appendix counters before calling this strict pure model.
#let progress-ratios(current, total, start: 1, end: auto, variant: "exact") = {
  let _ = segment-count(variant)
  assert((current, total, start).all(finite-number) and (end == auto or finite-number(end)),
    message: "progress: slide bounds must be finite numbers")
  let before = start - 1
  let end = if end == auto { total } else { end }
  assert(0 <= before and before <= current and current <= end and end <= total,
    message: "progress: bounds must satisfy 0 <= before <= current <= end <= total")
  if total == 0 {
    return (broad: (0, 1), near: (0, 1, 0), exact: (0, 0, 1, 0)).at(variant)
  }
  let parts = (
    broad: (current, total - current),
    near: (before, end - before, total - end),
    exact: (before, current - before, end - current, total - end),
  )
  normalize-progress(parts.at(variant), variant: variant)
}

/// Each section records the logical count immediately before its physical page.
/// This works whether the section card itself increments the counter or not.
#let section-bounds(sections, page, total) = {
  let previous = sections.filter(section => section.page <= page)
  let future = sections.filter(section => section.page > page)
  (
    start: if previous.len() > 0 { previous.last().before + 1 } else { 1 },
    end: if future.len() > 0 { future.first().before } else { total },
  )
}
