#import "structure.typ": is-role
#import "utils.typ": merge-dicts
#import "progressive-outline.typ": progressive-outline

/// Default configuration for the transition engine
#let default-transitions = (
  enabled: true,
  max-level: 3,
  show-numbering: true,
  numbering-format: auto,
  background: "theme",
  filter: none,
  parts: (
    enabled: true,
    visibility: (part: "all", section: "none", subsection: "none"),
    background: auto, 
  ),
  sections: (
    enabled: true,
    visibility: (part: "current", section: "current", subsection: "current-parent"),
    background: auto,
  ),
  subsections: (
    enabled: true,
    visibility: (part: "current", section: "current", subsection: "current-parent"),
    background: auto,
  ),
  style: (
    inactive-opacity: 0.4,
    completed-opacity: 0.7,
    active-weight: "bold",
    active-color: none, 
  ),
)

/// Resolves the background color based on configuration and theme colors
#let resolve-background(bg-option, theme-colors) = {
  if bg-option == "theme" { theme-colors.at("primary", default: white) } 
  else if bg-option == "none" or bg-option == none { none } 
  else { bg-option }
}

/// Resolves the active color based on priority
#let resolve-active-color(style-options, theme-colors, final-bg-option) = {
  if style-options.active-color != none { style-options.active-color } 
  else {
     if final-bg-option == "theme" { white } 
     else {
       if "accent" in theme-colors { theme-colors.accent }
       else if "primary" in theme-colors { theme-colors.primary }
       else { black }
     }
  }
}

/// Main function to render a transition slide
#let render-transition(
  h, 
  transitions: (:), 
  mapping: (:), 
  show-heading-numbering: auto,
  numbering-format: auto,
  theme-colors: auto,
  slide-func: auto, 
  base-text-size: auto,
  base-text-font: auto,
  top-padding: 40%,
  content-padding: auto,
  content-align: auto,
  content-wrapper: none,
  headings: auto,
  max-length: auto,
  use-short-title: auto,
) = {
  import "structure.typ": navigator-config
  let config = navigator-config.get()

  let final-mapping = if mapping == (:) { config.at("mapping", default: (:)) } else { mapping }
  let final-slide-func = if slide-func == auto { config.at("slide-func", default: none) } else { slide-func }
  let final-theme-colors = if theme-colors == auto { config.at("theme-colors", default: (:)) } else { theme-colors }
  
  if final-slide-func == none { panic("navigator: slide-func must be provided either in navigator-config or as an argument to render-transition") }
  
  let final-max-length = if max-length == auto { config.at("max-length", default: none) } else { max-length }
  let final-use-short = if use-short-title == auto { config.at("use-short-title", default: true) } else { use-short-title }

  // Double merge: user arg > config transitions > default-transitions
  let options = merge-dicts(config.at("transitions", default: (:)), base: default-transitions)
  options = merge-dicts(transitions, base: options)
  
  let final-show-numbering = if show-heading-numbering == auto { config.at("show-heading-numbering", default: true) } else { show-heading-numbering }
  let final-numbering-format = if numbering-format == auto { config.at("numbering-format", default: auto) } else { numbering-format }

  if not options.enabled { return place(hide(h)) }
  if h.level > options.max-level { return place(hide(h)) }
  if options.filter != none and not (options.filter)(h) { return place(hide(h)) }

  let role = none
  if is-role(final-mapping, h.level, "part") { role = "parts" }
  else if is-role(final-mapping, h.level, "section") { role = "sections" }
  else if is-role(final-mapping, h.level, "subsection") { role = "subsections" }

  if role == none { return place(hide(h)) }
  let role-config = options.at(role)
  if not role-config.enabled { return place(hide(h)) }

  let final-bg-option = if role-config.background != auto { role-config.background } else { options.background }
  let bg-color = resolve-background(final-bg-option, final-theme-colors)
  let final-active-color = resolve-active-color(options.style, final-theme-colors, final-bg-option)

  let common-active = (weight: options.style.active-weight, fill: final-active-color, size: 1.2em)
  let inactive-style = (weight: options.style.active-weight, fill: final-active-color, opacity: options.style.inactive-opacity, size: 1.2em)
  let completed-style = (weight: options.style.active-weight, fill: final-active-color, opacity: options.style.completed-opacity, size: 1.2em)

  let text-styles = (
    level-1: (active: common-active, inactive: inactive-style, completed: completed-style),
    level-2: (active: common-active, inactive: inactive-style, completed: completed-style),
    level-3: (active: common-active, inactive: inactive-style, completed: completed-style),
  )

  let vis = role-config.visibility
  let level-modes = (level-1-mode: "none", level-2-mode: "none", level-3-mode: "none")
  if "part" in final-mapping { level-modes.insert("level-" + str(final-mapping.part) + "-mode", vis.at("part", default: "none")) }
  if "section" in final-mapping { level-modes.insert("level-" + str(final-mapping.section) + "-mode", vis.at("section", default: "none")) }
  if "subsection" in final-mapping { level-modes.insert("level-" + str(final-mapping.subsection) + "-mode", vis.at("subsection", default: "none")) }

  // Calculate the scale factor applied by Typst to headings by default
  let scale = if h.level == 1 { 1.4 } else if h.level == 2 { 1.2 } else { 1.0 }

  context {
    // 1. Apply the reset to the document's base font size and weight
    set text(size: 1em / scale, weight: "regular")
    // 2. Apply explicit overrides if provided
    if base-text-size != auto { set text(size: base-text-size) }
    if base-text-font != auto { set text(font: base-text-font) }
    
    // 3. Generate the roadmap component
    let roadmap = progressive-outline(
      ..level-modes,
      show-numbering: final-show-numbering,
      numbering-format: final-numbering-format,
      target-location: h.location(),
      text-styles: text-styles,
      filter: options.filter,
      headings: headings,
      max-length: final-max-length,
      use-short-title: final-use-short,
    )

    final-slide-func(fill: bg-color, {
      if content-wrapper != none {
         // Expert mode: user takes full control
         // We pass h and the active state to allow building custom headers/footers
         import "structure.typ": get-active-headings
         let active = get-active-headings(h.location())
         content-wrapper(roadmap, h, active)
      } else {
        // Standard configurable mode
        let align-val = if content-align == auto { top + left } else { content-align }
        let pad-val = if content-padding == auto { (x: 10%) } else { content-padding }
        
        set align(align-val)
        v(top-padding)
        if type(pad-val) == dictionary {
          pad(..pad-val, roadmap)
        } else {
          pad(pad-val, roadmap)
        }
      }
      
      place(hide(h)) 
    })
  }
}

  // Calculate the scale factor applied by Typst to headings by default
  let scale = if h.level == 1 { 1.4 } else if h.level == 2 { 1.2 } else { 1.0 }

  context {
    // 1. Apply the reset to the document's base font size and weight
    set text(size: 1em / scale, weight: "regular")
    // 2. Apply explicit overrides if provided
    if base-text-size != auto { set text(size: base-text-size) }
    if base-text-font != auto { set text(font: base-text-font) }
    
    // 3. Generate the roadmap component
    let roadmap = progressive-outline(
      ..level-modes,
      show-numbering: final-show-numbering,
      numbering-format: final-numbering-format,
      target-location: h.location(),
      text-styles: text-styles,
      filter: options.filter,
      headings: headings,
      max-length: final-max-length,
      use-short-title: final-use-short,
    )

    slide-func(fill: bg-color, {
      if content-wrapper != none {
         // Expert mode: user takes full control
         // We pass h and the active state to allow building custom headers/footers
         import "structure.typ": get-active-headings
         let active = get-active-headings(h.location())
         content-wrapper(roadmap, h, active)
      } else {
        // Standard configurable mode
        let align-val = if content-align == auto { top + left } else { content-align }
        let pad-val = if content-padding == auto { (x: 10%) } else { content-padding }
        
        set align(align-val)
        v(top-padding)
        if type(pad-val) == dictionary {
          pad(..pad-val, roadmap)
        } else {
          pad(pad-val, roadmap)
        }
      }
      
      place(hide(h)) 
    })
  }
}
}