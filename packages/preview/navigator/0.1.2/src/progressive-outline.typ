#import "structure.typ": get-active-headings

/// Helper function to resolve styles with opacity/inheritance logic
#let resolve-state-style(active-style, target-style) = {
  if type(target-style) == float or type(target-style) == int {
    let new-style = active-style
    let c = new-style.at("fill", default: black)
    new-style.insert("fill", c.transparentize((1.0 - float(target-style)) * 100%))
    new-style
  } else if type(target-style) == dictionary {
    if "opacity" in target-style {
      let new-style = (:)
      let alpha = 1.0
      for (k, v) in target-style {
        if k == "opacity" { alpha = float(v) } 
        else { new-style.insert(k, v) }
      }
      let base-color = if "fill" in new-style { new-style.fill } else { active-style.at("fill", default: black) }
      new-style.insert("fill", base-color.transparentize((1.0 - alpha) * 100%))
      new-style
    } else {
      target-style
    }
  } else {
    target-style
  }
}

/// Helper to resolve marker content based on state
#let resolve-marker(marker-setting, state, level) = {
  if marker-setting == none { none } 
  else if type(marker-setting) == dictionary { marker-setting.at(state, default: none) } 
  else if type(marker-setting) == function { marker-setting(state, level) } 
  else { marker-setting }
}

/// Renders an item with jitter prevention.
#let render-item(
  body, 
  is-active: false, 
  is-completed: false,
  text-style: (:), 
  active-text-style: (:),
  completed-text-style: none,
  numbering-format: none,
  index: none,
  clickable: false,
  dest: none,
  markers: (:), 
  marker-spacing: (:),
) = {
  let base-style = text-style
  let active-style = active-text-style
  let completed-style = if completed-text-style != none { completed-text-style } else { text-style }

  let fmt-num = if numbering-format != none and index != none {
    numbering(numbering-format, ..index) + " "
  } else { "" }

  let wrap-link(content) = {
    if clickable and dest != none { link(dest, content) } 
    else { content }
  }

  let build-line(style, state-marker) = {
    let parts = ()
    if state-marker != none {
      let m-width = marker-spacing.at("width", default: auto)
      let m-gap = marker-spacing.at("gap", default: 0.5em)
      let m-box = if m-width != auto { box(width: m-width, state-marker) } else { state-marker }
      parts.push(m-box)
      parts.push(h(m-gap))
    }
    parts.push(fmt-num)
    parts.push(body)
    wrap-link(text(..style, parts.join()))
  }

  let content-normal = build-line(base-style, markers.at("inactive", default: none))
  let content-active = build-line(active-style, markers.at("active", default: none))
  let content-completed = build-line(completed-style, markers.at("completed", default: none))

  let target-content = if is-active { content-active } 
    else if is-completed { content-completed } 
    else { content-normal }

  block(width: auto, {
    hide(content-active)
    place(top + left, target-content)
  })
}

#let progressive-outline(
  level-1-mode: "all", 
  level-2-mode: "current-parent",
  level-3-mode: "none",
  layout: "vertical",
  separator: none,
  text-styles: (
    level-1: (
      active: (fill: rgb("#000000"), weight: "bold"), 
      completed: (fill: rgb("#888888"), weight: "bold"),
      inactive: (fill: rgb("#000000"), weight: "bold")
    ),
    level-2: (
      active: (fill: rgb("#000000"), weight: "bold"), 
      completed: (fill: rgb("#aaaaaa"), weight: "regular"),
      inactive: (fill: rgb("#333333"), weight: "regular")
    ),
    level-3: (
      active: (fill: rgb("#000000"), weight: "bold"), 
      completed: (fill: rgb("#cccccc"), weight: "regular"),
      inactive: (fill: rgb("#555555"), weight: "regular")
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
  show-numbering: false,
  numbering-format: auto,
  target-location: auto,
  match-page-only: false,
  filter: none,
  headings: auto,
  clickable: true,
  marker: none,
) = {
  context {
    let loc = if target-location == auto { here() } else { target-location }
    let all-headings = if headings == auto { query(heading.where(outlined: true)) } else { headings }
    
    let active-state = get-active-headings(loc, match-page-only: match-page-only, headings: all-headings)
    let active-h1 = active-state.h1
    let active-h2 = active-state.h2
    let active-h3 = active-state.h3
    
    let items-to-render = ()
    let last-level = 0

    let current-h1 = none
    let current-h2 = none
    let is-h1-filtered = false
    let is-h2-filtered = false

    for h in all-headings {
      if h.level == 1 { current-h1 = h; current-h2 = none; is-h1-filtered = false; is-h2-filtered = false } 
      else if h.level == 2 { current-h2 = h; is-h2-filtered = false }

      let explicitly-filtered = (filter != none and not filter((
        ..h.fields(), 
        location: h.location(),
        label: if h.has("label") { h.label } else { none },
        parent-h1: current-h1, 
        parent-h2: current-h2
      )))
      let implicitly-filtered = (h.level > 1 and is-h1-filtered) or (h.level > 2 and is-h2-filtered)

      if explicitly-filtered or implicitly-filtered { 
        if h.level == 1 { is-h1-filtered = true }
        else if h.level == 2 { is-h2-filtered = true }
        continue 
      }

      let is-active = false
      let is-completed = false
      let should-render = false
      let h-loc = h.location()

      let is-child-of-active-h1 = (active-h1 != none and current-h1 != none and h.level > 1 and current-h1.location() == active-h1.location())
      let is-child-of-active-h2 = (active-h2 != none and current-h2 != none and h.level > 2 and current-h2.location() == active-h2.location())

      if h.level == 1 {
        if active-h1 != none and h-loc == active-h1.location() { is-active = true }
        else if active-h1 != none {
          if h-loc.page() < active-h1.location().page() or (h-loc.page() == active-h1.location().page() and h-loc.position() != none and active-h1.location().position() != none and h-loc.position().y < active-h1.location().position().y) { is-completed = true }
        }
        if level-1-mode == "all" { should-render = true }
        else if level-1-mode == "current" and is-active { should-render = true }
      } else if h.level == 2 {
        if active-h2 != none and h-loc == active-h2.location() { is-active = true }
        else if active-h2 != none {
          if h-loc.page() < active-h2.location().page() or (h-loc.page() == active-h2.location().page() and h-loc.position() != none and active-h2.location().position() != none and h-loc.position().y < active-h2.location().position().y) { is-completed = true }
        }
        if level-2-mode == "all" { should-render = true }
        else if level-2-mode == "current-parent" {
           if is-child-of-active-h1 { should-render = true }
           else if active-h1 == none and current-h1 == none { should-render = true }
        }
        else if level-2-mode == "current" and is-active { should-render = true }
      } else if h.level == 3 {
        if active-h3 != none and h-loc == active-h3.location() { is-active = true }
        else if active-h3 != none {
          if h-loc.page() < active-h3.location().page() or (h-loc.page() == active-h3.location().page() and h-loc.position() != none and active-h3.location().position() != none and h-loc.position().y < active-h3.location().position().y) { is-completed = true }
        }
        if level-3-mode == "all" { should-render = true }
        else if level-3-mode == "current-parent" {
           if is-child-of-active-h2 { should-render = true }
           else if active-h2 == none and is-child-of-active-h1 { should-render = true }
           else if active-h2 == none and active-h1 == none and current-h1 == none and current-h2 == none { should-render = true }
        }
        else if level-3-mode == "current" and is-active { should-render = true }
      }

      if should-render {
        let styles-lvl = text-styles.at("level-" + str(h.level), default: (:))
        let raw-active = styles-lvl.at("active", default: (:))
        let raw-inactive = styles-lvl.at("inactive", default: (:))
        let raw-completed = styles-lvl.at("completed", default: none)
        
        let s-active = raw-active
        let s-inactive = resolve-state-style(s-active, raw-inactive)
        let s-completed = resolve-state-style(s-active, raw-completed)
        
        let m-active = resolve-marker(marker, "active", h.level)
        let m-inactive = resolve-marker(marker, "inactive", h.level)
        let m-completed = resolve-marker(marker, "completed", h.level)
        let m-spacing = (gap: spacing.at("marker-gap", default: 0.5em), width: spacing.at("marker-width", default: auto))
        
        let h-counter = counter(heading).at(h-loc)
        let trimmed-idx = if h-counter.len() >= h.level { h-counter.slice(0, h.level) } else { h-counter }

        // Smart numbering resolution
        let final-fmt = if show-numbering {
          let fmt = if numbering-format == auto { h.at("numbering", default: none) } else { numbering-format }
          // Only show numbering if a format exists AND the counter has been incremented (avoiding "0")
          if fmt != none and trimmed-idx.any(v => v > 0) { fmt } else { none }
        } else { none }

        let item = render-item(
          h.body, is-active: is-active, is-completed: is-completed,
          text-style: s-inactive, active-text-style: s-active, completed-text-style: s-completed,
          numbering-format: final-fmt, index: trimmed-idx,
          clickable: clickable, dest: h-loc,
          markers: (active: m-active, inactive: m-inactive, completed: m-completed),
          marker-spacing: m-spacing,
        )

        if layout == "horizontal" {
          if items-to-render.len() > 0 and separator != none {
            items-to-render.push(separator)
          }
          items-to-render.push(item)
        } else {
          let spacing-top = 0pt
          if items-to-render.len() > 0 {
            let key = "v-between-" + str(last-level) + "-" + str(h.level)
            spacing-top = spacing.at(key, default: spacing.at("v-after-block", default: 0.5em))
          }
          let indent = spacing.at("indent-" + str(h.level), default: 0pt)
          
          items-to-render.push(block(
            inset: (top: spacing-top, left: indent),
            item
          ))
        }
        last-level = h.level
      }
    }
    if items-to-render.len() > 0 { 
      if layout == "horizontal" {
        stack(dir: ltr, spacing: spacing.at("h-spacing", default: 0.5em), ..items-to-render)
      } else {
        grid(columns: (auto,), ..items-to-render) 
      }
    }
  }
}