#import "@preview/slydekit:0.4.1" as sk
#import "@preview/navigator:0.1.8" as navigator

// --- CONFIGURATION ---
#let primary = rgb("#014682")
#let accent = orange

#navigator.navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c.theme-colors = (primary: primary, accent: accent)
  c.slide-func = (fill: white, body) => {
    pagebreak(weak: true)
    set page(fill: fill, header: none, footer: none)
    set align(horizon)
    body
  }
  c
})

// --- TRANSITION LOGIC ---
//
// slydekit's own theme reacts to `=`/`==` headings on its own: an automatic
// "Outline" divider slide at level `slide-level - 1`. At the default
// `slide-level: 2` that is level 1 -- the same level our own `section` role
// uses -- and slydekit installs its divider rule (`show heading.where(level:
// slide-level - 1): it => context if not state.get() {it}`, unconditionally
// active, not just when hide-new-section-slide is used) inside its own
// setup, *before* our document's `show heading.where(level: 1): ...` gets a
// chance to run. Two show rules landing on the very same heading level like
// that corrupts something slide-parser depends on to keep track of which
// content belongs to which slide: confirmed with a trivial placeholder show
// rule in place of render-transition, and independent of whether
// hide-new-section-slide is also used -- the title slide's own text and the
// first explicit `sk.slide(..)` following each heading silently lose their
// body, while later slides in the same run render fine.
//
// This deck never relies on slide-level-driven automatic heading-to-slide
// grouping -- every content slide is created explicitly with `sk.slide(..)`
// below -- so nothing depends on `slide-level` matching a real heading
// level. Set to 4 here, past both our heading levels (section: 1,
// subsection: 2), `slide-level - 1` = 3 matches no heading in this
// document, slydekit's own divider rule never fires, and the collision
// disappears -- along with the need for hide-new-section-slide, since
// there is now nothing automatic left to hide.
#show: sk.slydekit.with(
  title: "Slydekit + Navigator",
  subtitle: "Two-level structural transitions",
  author: "David Hajage",
  slide-level: 4,
)

#show heading.where(level: 1): h => navigator.render-transition(
  h,
  top-padding: 20%,
  transitions: (
    background: "theme",
    style: (active-color: white, inactive-opacity: 0.4),
    sections: (visibility: (section: "current", subsection: "current-parent")),
    subsections: (visibility: (section: "current", subsection: "current-parent")),
  ),
)
#show heading.where(level: 2): h => navigator.render-transition(
  h,
  top-padding: 20%,
  transitions: (
    background: "theme",
    style: (active-color: white, inactive-opacity: 0.4),
    sections: (visibility: (section: "current", subsection: "current-parent")),
    subsections: (visibility: (section: "current", subsection: "current-parent")),
  ),
)

// --- CONTENT ---
//
// With both heading levels reserved for transitions, ordinary content slides
// are created explicitly with `sk.slide`, exactly as slydekit's own docs do
// for anything a bare heading can't express.

#sk.title-slide

= Introduction

== Welcome
#sk.slide("Context")[
  #lorem(30)
]
#sk.slide("Motivation")[
  #lorem(30)
]

== Objectives
#sk.slide("Primary goals")[
  #lorem(25)
]

= Methodology

== Data Collection
#sk.slide("Protocol")[
  #lorem(30)
]

== Analysis
#sk.slide("Approach")[
  #lorem(25)
]
#sk.slide("Validation")[
  #lorem(25)
]

= Conclusion

== Final Remarks
#sk.slide("Thank you!")[
  Happy presenting with Typst!
]
