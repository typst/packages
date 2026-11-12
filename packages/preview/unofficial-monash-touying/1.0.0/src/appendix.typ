// Appendix bookkeeping. Touying's `appendix` freezes the slide total; this
// file lets outlines and section numbers tell appendix headings apart.

#let _appendix-label = <monash-appendix-start>

/// Marks the current page as belonging to the appendix. Emitted by every
/// slide function while `self.appendix` is true.
#let appendix-marker(self) = if self.at("appendix", default: false) {
  [#metadata("monash-appendix")#_appendix-label]
}

/// First page of the appendix, or `none` without an appendix. Needs context.
#let appendix-start-page() = {
  let marks = query(_appendix-label)
  if marks.len() > 0 { marks.first().location().page() }
}

/// Whether a location lies in the appendix. Needs context.
#let in-appendix(location) = {
  let start = appendix-start-page()
  start != none and location.page() >= start
}

/// Number of a section heading, counted separately for the main part
/// ("1", "2", ..) and the appendix ("A", "B", ..). Needs context.
#let section-label(location, level: 1) = {
  let start = appendix-start-page()
  let appendix = start != none and location.page() >= start
  let earlier = query(heading.where(level: level, outlined: true).before(location))
  let same-part = earlier.filter(it => {
    (start != none and it.location().page() >= start) == appendix
  })
  let index = same-part.len()
  if appendix { numbering("A", calc.max(index, 1)) } else { str(calc.max(index, 1)) }
}
