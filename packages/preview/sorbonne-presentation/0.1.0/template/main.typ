#import "@preview/sorbonne-presentation:0.1.0": *

// --- Theme Configuration ---
#show: template.with(
  title: [Presentation Title],
  subtitle: [Subtitle or Context],
  author: [Your Name],
  affiliation: [Your Laboratory / Department],
  // faculty: "univ", // Presets: "univ" (blue), "sante" (red), "sciences" (light blue), "lettres" (yellow)
  date: datetime.today().display(),
  show-outline: true, // Show the table of contents at the beginning
)

// --- Content ---

= Introduction

#slide(title: "Welcome")[
  This is a sample presentation using the Sorbonne theme.
  
  - Respects the university's visual identity.
  - Built on top of `presentate` and `navigator` packages.
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
  contact: ("first.name@sorbonne-universite.fr",)
)
