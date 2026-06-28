/// Detects if the location contains a heading of the
/// specified level
#let page-has-heading = (loc, level: 1) => {
  query(heading.where(level: level)).any(h => (
    h.location().page() == loc.page()
  ))
}

/// Returns the body of the latest heading. Returns none
/// if no headings have been added yet
#let latest-heading = (level: 1) => {
  let prev-headings = query(selector(heading.where(level: level)).before(here()))
  if prev-headings.len() == 0 {
    return none
  }
  prev-headings.last().body
}
