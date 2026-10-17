#import "@preview/touying:0.7.4": utils
#import "brand.typ": colour
#import "navigation/progress-model.typ": progress-ratios, normalize-progress, section-bounds, finite-number

// Touying 0.7.4 places authored structural headings between these two markers.
// Selecting this range excludes headings created inside an outline or slide body
// while retaining authored sections with outlined:false or touying:hidden.
#let authored-sections(markers) = {
  let sections = ()
  let start = none
  for marker in markers {
    if marker.value.kind == "touying-new-slide" { start = marker }
    if marker.value.kind == "touying-new-subslide" and start != none {
      sections += query(selector(heading.where(level: 1)).after(start.location()).before(marker.location()))
      start = none
    }
  }
  sections
}

#let section-counts(markers) = {
  let pages = markers.filter(marker => marker.value.kind == "touying-new-page")
  authored-sections(markers).map(section => {
    let page = section.location().position().page
    let beginning = pages.find(marker => marker.location().position().page == page)
    assert(beginning != none, message: "progress: section is missing its Touying page marker")
    // The page marker precedes Touying's counter update. A heading's own counter
    // value cannot distinguish a counted card from a frozen card.
    (page: page, before: utils.slide-counter.at(beginning.location()).first())
  })
}

/// Data adapter for the renderer. Call from a context expression.
#let get-progress-state(variant: "exact", ratios: none) = {
  let total = utils.last-slide-counter.final().first()
  let actual-current = utils.slide-counter.get().first()
  let raw = section-bounds(section-counts(query(<touying-metadata>)), here().position().page, total)
  // Touying counts appendix slides in its current counter but excludes them from
  // the main-deck total. Saturate only this semantic boundary, not bad input.
  let completed = actual-current >= total
  let current = if completed { total } else { actual-current }
  let bounds = (
    start: if completed { calc.min(raw.start, total + 1) } else { raw.start },
    end: if completed { calc.min(raw.end, total) } else { raw.end },
  )
  let values = if ratios == none {
    progress-ratios(current, total, ..bounds, variant: variant)
  } else { normalize-progress(ratios, variant: variant) }
  (current: current, actual-current: actual-current, total: total, before: bounds.start - 1, ..bounds, values: values)
}

#let lineal-progress-bar(
  variant: "exact", height: 2pt, ratios: none,
  accent: colour.primary, remaining: colour.primary-light,
) = context {
  assert(type(height) == length,
    message: "progress: height must be a finite positive length")
  let height = height.to-absolute()
  assert(finite-number(height / 1pt) and height > 0pt,
    message: "progress: height must be a finite positive length")
  let state = get-progress-state(variant: variant, ratios: ratios)
  let fills = (
    broad: (accent, remaining),
    near: (black.transparentize(60%), accent, remaining),
    exact: (black.transparentize(60%), accent, remaining, black.transparentize(80%)),
  ).at(variant)
  if state.total == 0 and ratios == none { fills = fills.map(_ => remaining) }
  let segments = state.values.enumerate().filter(pair => pair.last() > 0)
  grid(columns: segments.map(pair => pair.last() * 1fr), rows: height,
    ..segments.map(pair => rect(width: 100%, height: height, fill: fills.at(pair.first()), stroke: none)),
  )
}
