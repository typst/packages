#import "utils.typ": resolve-body

/// Global state for structure mapping and auto-titling
#let navigator-config = state("navigator-config", (
  mapping: (section: 1, subsection: 2),
  auto-title: false,
  show-heading-numbering: true,
  numbering-format: auto,
  use-short-title: false,
  max-length: none,
  slide-func: none,
  theme-colors: (primary: black, accent: orange),
  transitions: (:),
  slide-selector: metadata.where(value: (t: "ContentSlide")),
  miniframes: (
    fill: none,
    active-color: white,
    inactive-color: gray,
    style: "grid",
  ),
  progressive-outline: (
    level-1-mode: "all",
    level-2-mode: "current-parent",
    level-3-mode: "none",
    text-styles: (
      level-1: (
        active: (fill: rgb("#000000"), weight: "bold"), 
        completed: (fill: rgb("#777777"), weight: "bold"),
        inactive: (fill: rgb("#999999"), weight: "bold")
      ),
      level-2: (
        active: (fill: rgb("#000000"), weight: "regular"), 
        completed: (fill: rgb("#888888"), weight: "regular"),
        inactive: (fill: rgb("#aaaaaa"), weight: "regular")
      ),
      level-3: (
        active: (fill: rgb("#000000"), weight: "regular"), 
        completed: (fill: rgb("#999999"), weight: "regular"),
        inactive: (fill: rgb("#bbbbbb"), weight: "regular")
      ),
    ),
    spacing: (
      indent-1: 0pt, indent-2: 1.5em, indent-3: 3em,
      v-between-1-1: 1em, v-between-1-2: 0.6em, v-between-2-1: 1em,
      v-between-2-2: 0.5em, v-between-2-3: 0.4em, v-between-3-3: 0.3em, 
      v-between-3-2: 0.8em, v-between-3-1: 1.2em,
      v-after-block: 0.5em,
      h-spacing: 0.5em,
    ),
  ),
))



/// Robust comparison of two locations.
#let is-before(loc-a, loc-b) = {
  if loc-a == none or loc-b == none { return false }
  let pg-a = loc-a.page()
  let pg-b = loc-b.page()
  if pg-a < pg-b { return true }
  if pg-a > pg-b { return false }
  
  let pos-a = loc-a.position()
  let pos-b = loc-b.position()
  if pos-a != none and pos-b != none {
    return pos-a.y < pos-b.y
  }
  // Fallback if positions are not available: assume true if we are in document order
  // but for safety in general helper, return false
  return false
}

/// Returns an array of short titles corresponding to the provided headings.
/// Each entry in the returned array is the metadata value of <short> 
/// found after the corresponding heading but before the next one.
#let find-short-titles(all-headings, all-shorts) = {
  if all-headings.len() == 0 { return () }
  if all-shorts == none or all-shorts.len() == 0 { 
    return range(all-headings.len()).map(i => none) 
  }
  
  let mapping = (:)
  for m in all-shorts {
    let m-loc = m.location()
    let m-pg = m-loc.page()
    let m-y = if m-loc.position() != none { m-loc.position().y } else { 0pt }
    
    let best-h-idx = -1
    for i in range(all-headings.len()) {
      let h-loc = all-headings.at(i).location()
      let h-pg = h-loc.page()
      let h-y = if h-loc.position() != none { h-loc.position().y } else { 0pt }
      
      if h-pg < m-pg or (h-pg == m-pg and h-y < m-y) {
        best-h-idx = i
      } else {
        break
      }
    }
    
    if best-h-idx != -1 {
      if m.has("value") {
        mapping.insert(str(best-h-idx), m.value)
      }
    }
  }
  
  return range(all-headings.len()).map(i => mapping.at(str(i), default: none))
}




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
  let all-shorts = query(<short>)
  let mapping = config.mapping
  
  let get-short(h) = {
    if h == none { return none }
    // find-short-titles is expensive to call repeatedly, but resolve-slide-title is called per slide.
    // However, we only need it for the specific active headings.
    let h-loc = h.location()
    let my-short = all-shorts.find(m => {
      let m-loc = m.location()
      m-loc.page() == h-loc.page() and m-loc.position() != none and h-loc.position() != none and m-loc.position().y > h-loc.position().y
      // This is a simplified version of find-short-titles logic for a single heading
    })
    if my-short != none { my-short.value } else { none }
  }

  let fmt-h(h) = {
    if h == none { return none }
    let level = h.level
    let current-max-length = if type(config.at("max-length", default: none)) == dictionary {
      config.max-length.at("level-" + str(level), default: config.max-length.at(str(level), default: none))
    } else {
      config.at("max-length", default: none)
    }

    let current-use-short = if type(config.at("use-short-title", default: true)) == dictionary {
      config.use-short-title.at("level-" + str(level), default: config.use-short-title.at(str(level), default: true))
    } else {
      config.at("use-short-title", default: true)
    }

    let body = resolve-body(
      h.body,
      short-title: get-short(h),
      use-short-title: current-use-short,
      max-length: current-max-length
    )

    format-heading(
      h, 
      show-numbering: config.at("show-heading-numbering", default: false),
      numbering-format: config.at("numbering-format", default: auto)
    )
    // Wait, format-heading uses h.body. I need to override it.
  }
  
  // Re-implementing a bit of format-heading logic here to avoid h.body issue
  let final-fmt(h) = {
    if h == none { return none }
    let level = h.level
    let current-max-length = if type(config.at("max-length", default: none)) == dictionary {
      config.max-length.at("level-" + str(level), default: config.max-length.at(str(level), default: none))
    } else {
      config.at("max-length", default: none)
    }

    let current-use-short = if type(config.at("use-short-title", default: true)) == dictionary {
      config.use-short-title.at("level-" + str(level), default: config.use-short-title.at(str(level), default: true))
    } else {
      config.at("use-short-title", default: true)
    }

    let body = resolve-body(
      h.body,
      short-title: get-short(h),
      use-short-title: current-use-short,
      max-length: current-max-length
    )

    if config.at("show-heading-numbering", default: false) {
      let fmt = if config.numbering-format == auto { h.numbering } else { config.numbering-format }
      let count = counter(heading).at(h.location())
      if fmt != none and count.any(v => v > 0) {
        return numbering(fmt, ..count) + " " + body
      }
    }
    body
  }
  
  // Try to find the title from the lowest mapped level available
  if "subsection" in mapping and mapping.subsection != none {
    let lvl = "h" + str(mapping.subsection)
    if active.at(lvl, default: none) != none { return final-fmt(active.at(lvl)) }
  }
  
  if "section" in mapping and mapping.section != none {
    let lvl = "h" + str(mapping.section)
    if active.at(lvl, default: none) != none { return final-fmt(active.at(lvl)) }
  }
  
  if "part" in mapping and mapping.part != none {
    let lvl = "h" + str(mapping.part)
    if active.at(lvl, default: none) != none { return final-fmt(active.at(lvl)) }
  }
  
  return none
}


/// Helper to check if a heading level matches a mapped role
#let is-role(mapping, lvl, role) = {
  return mapping.at(role, default: none) == lvl
}
