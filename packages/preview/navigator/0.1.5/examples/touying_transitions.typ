#import "@preview/touying:0.7.3": *
#import themes.simple: *
#import "@preview/navigator:0.1.5" as navigator

// --- Configuration ---
#let primary = rgb("#003366")

// Navigator configuration must be placed BEFORE show: simple-theme to avoid
// Touying wrapping the state update in a blank slide.
#navigator.navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c
})

// --- Transition slide ---
//
// Plugged into new-section-slide-fn and new-subsection-slide-fn.
// level-3-mode: "none" keeps per-slide titles out of the outline.
#let nav-transition-slide(config: (:), body) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: primary, header: none, footer: none),
  )
  let roadmap = navigator.progressive-outline(
    level-1-mode: "current",
    level-2-mode: "current-parent",
    level-3-mode: "none",
    match-page-only: true,
    text-styles: (
      level-1: (
        active:    (fill: white,                     weight: "bold",    size: 1.3em),
        completed: (fill: white.transparentize(30%),  weight: "bold",    size: 1.3em),
        inactive:  (fill: white.transparentize(60%),  weight: "bold",    size: 1.3em),
      ),
      level-2: (
        active:    (fill: white,                     weight: "regular", size: 1em),
        completed: (fill: white.transparentize(30%),  weight: "regular", size: 1em),
        inactive:  (fill: white.transparentize(60%),  weight: "regular", size: 1em),
      ),
    ),
  )
  touying-slide(self: self, config: config, {
    set align(top + left)
    v(35%)
    pad(x: 10%, roadmap)
  })
})

// --- Slide preamble ---
//
// With slide-level: 3, each === heading creates an implicit slide.
// Shows the === title when the current slide has one; falls back to ==.
#let slide-preamble = context {
  let h3 = utils.current-heading(level: 3)
  let title = if h3 != none {
    h3.body
  } else {
    let h2 = utils.current-heading(level: 2)
    if h2 != none { h2.body } else { none }
  }
  if title != none {
    block(below: 1.5em, text(1.2em, weight: "bold", title))
  }
}

// --- Theme ---
//
// slide-level: 3 means:
//   =   (level 1) → new-section-slide-fn    (transition slide)
//   ==  (level 2) → new-subsection-slide-fn (transition slide)
//   === (level 3) → slide-fn                (content slide, no #slide[] needed)
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-colors(primary: primary),
  config-common(
    slide-level: 3,
    new-section-slide-fn:    nav-transition-slide,
    new-subsection-slide-fn: nav-transition-slide,
  ),
  subslide-preamble: slide-preamble,
)

// --- Content ---

#title-slide[
  #set align(center + horizon)
  #text(size: 1.5em, weight: "bold", fill: primary)[Touying + Navigator] \
  #v(0.5em)
  #text(size: 0.9em, style: "italic")[Structural Transitions · Per-slide Titles]
]

= Introduction

== Background

=== Context

#lorem(40)

=== Motivation

#lorem(40)

== Objectives

=== Primary goals

#lorem(35)

=== Scope

#lorem(35)

= Methodology

== Data Collection

=== Protocol

#lorem(40)

// Slide without a === heading: the subsection title is shown in the preamble.
#slide[
  #lorem(40)
]

== Analysis

=== Approach

#lorem(40)

=== Validation

#lorem(35)

= Conclusion

== Results

=== Findings

#lorem(40)

== Final Remarks

#slide[
  #set align(center + horizon)
  #text(fill: primary, weight: "bold", size: 1.2em)[Thank you!]
]
