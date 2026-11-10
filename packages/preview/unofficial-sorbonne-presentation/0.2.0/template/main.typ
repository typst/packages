#import "@preview/unofficial-sorbonne-presentation:0.2.0": *

// --- Theme Configuration ---
// Note: 'template' is an alias for 'sorbonne-template'. 
// You can also use 'iplesp-template' for the Laboratory theme.

#show: template.with(
  title: [Presentation Title],
  subtitle: [Subtitle or Context],
  author: [Your Name],
  affiliation: [Your Laboratory / Department],
  // faculty: "univ", // Options: "univ" (blue), "sante" (red), "sciences" (light blue), "lettres" (yellow)
  date: datetime.today().display(),
  show-outline: true, // Show the table of contents at the beginning
)

// --- Content ---

= Introduction

#slide(title: "Welcome")[
  This is a sample presentation using the Unified Example/Laboratory theme.
  
  - Respects institutional visual identities.
  - Built on top of `presentate` and `navigator` packages.
  - Supports Dark Mode (`dark-mode: true` in configuration).
]

= First Part

== Key Concepts

#slide[
  You can use numbered and bulleted lists:
  + First important point
  + Second crucial point
    - Technical detail
]

#focus-slide[
  "Focus" slides are designed for impactful messages or major transitions.
]

= Conclusion

#ending-slide(
  title: [Thank you for your attention!],
  subtitle: [Any questions?],
  contact: ("first.name@sorbonne-universite.fr", "github.com/username")
)
