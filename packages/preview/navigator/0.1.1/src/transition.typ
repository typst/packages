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
    inactive-opacity: 0.3,
    completed-opacity: 0.6,
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
  show-heading-numbering: true,
  numbering-format: auto,
  theme-colors: (:),
  slide-func: none, 
  base-text-size: auto,
  base-text-font: auto,
  top-padding: 40%,
) = {
  if slide-func == none { panic("navigator: slide-func must be provided to render-transition") }

  let options = merge-dicts(transitions, base: default-transitions)
  
  let final-show-numbering = if "show-numbering" in transitions { options.show-numbering } else { show-heading-numbering }
  let final-numbering-format = if "numbering-format" in transitions { options.numbering-format } else { numbering-format }

  if not options.enabled { return place(hide(h)) }
  if h.level > options.max-level { return place(hide(h)) }
  if options.filter != none and not (options.filter)(h) { return place(hide(h)) }

  let role = none
  if is-role(mapping, h.level, "part") { role = "parts" }
  else if is-role(mapping, h.level, "section") { role = "sections" }
  else if is-role(mapping, h.level, "subsection") { role = "subsections" }

  if role == none { return place(hide(h)) }
  let role-config = options.at(role)
  if not role-config.enabled { return place(hide(h)) }

  let final-bg-option = if role-config.background != auto { role-config.background } else { options.background }
  let bg-color = resolve-background(final-bg-option, theme-colors)
  let final-active-color = resolve-active-color(options.style, theme-colors, final-bg-option)

  let common-active = (weight: options.style.active-weight, fill: final-active-color, size: 1.2em)
  let inactive-style = (opacity: options.style.inactive-opacity, size: 1.2em)
  let completed-style = (opacity: options.style.completed-opacity, size: 1.2em)

  let text-styles = (
    level-1: (active: common-active, inactive: inactive-style, completed: completed-style),
    level-2: (active: common-active, inactive: inactive-style, completed: completed-style),
    level-3: (active: common-active, inactive: inactive-style, completed: completed-style),
  )

  let vis = role-config.visibility
  let level-modes = (level-1-mode: "none", level-2-mode: "none", level-3-mode: "none")
  if "part" in mapping { level-modes.insert("level-" + str(mapping.part) + "-mode", vis.at("part", default: "none")) }
  if "section" in mapping { level-modes.insert("level-" + str(mapping.section) + "-mode", vis.at("section", default: "none")) }
  if "subsection" in mapping { level-modes.insert("level-" + str(mapping.subsection) + "-mode", vis.at("subsection", default: "none")) }

  // Calculate the scale factor applied by Typst to headings by default
  let scale = if h.level == 1 { 1.4 } else if h.level == 2 { 1.2 } else { 1.0 }

  context {
    // 1. Apply the reset to the document's base font size and weight
    set text(size: 1em / scale, weight: "regular")
    // 2. Apply explicit overrides if provided
    if base-text-size != auto { set text(size: base-text-size) }
    if base-text-font != auto { set text(font: base-text-font) }

    slide-func(fill: bg-color, {
      set align(top + left)
      
      v(top-padding)
      pad(x: 10%, {
         progressive-outline(
          ..level-modes,
          show-numbering: final-show-numbering,
          numbering-format: final-numbering-format,
          target-location: h.location(),
          text-styles: text-styles,
          filter: options.filter,
        )
      })
      
      place(hide(h)) 
    })
  }
}
}