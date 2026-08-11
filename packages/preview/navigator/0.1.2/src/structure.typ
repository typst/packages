/// Global state for structure mapping and auto-titling
#let navigator-config = state("navigator-config", (
  mapping: (section: 1, subsection: 2),
  auto-title: false,
  show-heading-numbering: true,
  numbering-format: auto,
))

/// Returns the active headings (h1, h2, h3) at a given location using query.
#let get-active-headings(loc, match-page-only: false, headings: none) = {
  let all-headings = if headings != none { headings } else { query(heading.where(outlined: true)) }
  let active-h1 = none
  let active-h2 = none
  let active-h3 = none
  
  for h in all-headings {
    let h-loc = h.location()
    let is-match = (h-loc == loc)
    let is-before = false
    
    if not is-match {
      if h-loc.page() < loc.page() {
        is-before = true
      } else if h-loc.page() == loc.page() {
        if match-page-only {
          is-before = true
        } else {
          let h-pos = h-loc.position()
          let loc-pos = loc.position()
          if h-pos != none and loc-pos != none and h-pos.y <= loc-pos.y {
            is-before = true
          }
        }
      }
    }

    if is-match or is-before {
      if h.level == 1 { active-h1 = h; active-h2 = none; active-h3 = none }
      else if h.level == 2 { active-h2 = h; active-h3 = none }
      else if h.level == 3 { active-h3 = h }
    } else {
      break
    }
  }
  (h1: active-h1, h2: active-h2, h3: active-h3)
}

/// Formats a heading body with its numbering if requested.
#let format-heading(h, show-numbering: true, numbering-format: auto) = {
  if h == none { return none }
  let body = h.body
  if show-numbering {
    let fmt = if numbering-format == auto { h.numbering } else { numbering-format }
    let count = counter(heading).at(h.location())
    if fmt != none and count.any(v => v > 0) {
      return numbering(fmt, ..count) + " " + body
    }
  }
  body
}

/// Resolves the title for a slide based on manual input and global config.
#let resolve-slide-title(manual-title) = context {
  if manual-title != none { return manual-title }
  
  let config = navigator-config.get()
  if not config.auto-title { return none }
  
  let active = get-active-headings(here())
  let mapping = config.mapping
  
  let fmt-h(h) = format-heading(
    h, 
    show-numbering: config.at("show-heading-numbering", default: false),
    numbering-format: config.at("numbering-format", default: auto)
  )
  
  // Try to find the title from the lowest mapped level available
  if "subsection" in mapping and mapping.subsection != none {
    let lvl = "h" + str(mapping.subsection)
    if active.at(lvl, default: none) != none { return fmt-h(active.at(lvl)) }
  }
  
  if "section" in mapping and mapping.section != none {
    let lvl = "h" + str(mapping.section)
    if active.at(lvl, default: none) != none { return fmt-h(active.at(lvl)) }
  }
  
  if "part" in mapping and mapping.part != none {
    let lvl = "h" + str(mapping.part)
    if active.at(lvl, default: none) != none { return fmt-h(active.at(lvl)) }
  }
  
  return none
}

/// Helper to check if a heading level matches a mapped role
#let is-role(mapping, lvl, role) = {
  return mapping.at(role, default: none) == lvl
}
