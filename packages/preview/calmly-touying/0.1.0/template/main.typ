// Calmly-Touying Presentation Template
// A calm, modern presentation theme with Moloch-inspired design
//
// Documentation: https://github.com/YHan228/calmly-touying

#import "@preview/calmly-touying:0.1.0": *

// Configure your presentation
#show: calmly.with(
  config-info(
    title: [Your Presentation Title],
    subtitle: [Conference or Event Name],
    author: [Your Name],
    date: datetime.today(),
    institution: [Your Institution],
  ),
  // Theme options (all optional):
  // variant: "light",        // "light" | "dark"
  // colortheme: "tomorrow",  // "tomorrow" | "warm-amber" | "paper"
  // progressbar: "foot",     // "foot" | "head" | "frametitle" | "none"
  // header-style: "moloch",  // "moloch" | "minimal"
  // title-layout: "moloch",  // "moloch" | "centered" | "split"
)

// =============================================================================
// Title Slide
// =============================================================================

#title-slide()

// =============================================================================
// Introduction
// =============================================================================

== Welcome

This is a presentation created with *Calmly-Touying*.

- Clean, modern design
- Multiple color themes
- Rich component library

#pause

Use `#pause` to reveal content progressively.

== Key Features

#two-col(
  [
    *Layout*
    - Light and dark variants
    - Three color themes
    - Moloch-style headers
  ],
  [
    *Components*
    - Highlight boxes
    - Alert and example boxes
    - Citation gadgets
  ],
)

// =============================================================================
// Content Examples
// =============================================================================

#focus-slide[
  Main Section
]

== Box Components

#highlight-box(title: "Key Point")[
  Use highlight boxes to emphasize important information.
]

#v(1em)

#example-box(title: "Example")[
  This is an example box for demonstrations.
]

== Multi-Column Layout

#three-col(
  [
    *Column 1*

    First point here.
  ],
  [
    *Column 2*

    Second point here.
  ],
  [
    *Column 3*

    Third point here.
  ],
)

// =============================================================================
// Conclusion
// =============================================================================

== Summary

#alert-box(title: "Remember")[
  - Customize colors with `colortheme`
  - Switch to dark mode with `variant: "dark"`
  - Use `#focus-slide` for emphasis
]

#ending-slide(
  title: [Thank You],
  subtitle: [Questions?],
  contact: (
    "your.email@example.com",
    "github.com/yourusername",
  ),
)
