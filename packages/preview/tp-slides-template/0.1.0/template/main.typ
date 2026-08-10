#import "@preview/touying:0.7.3": *
#import "@preview/tp-slides-template:0.1.0" as tp

#show: tp.register.with(
  theme:   "light",   // "light" | "dark"
  accent:  "blue",    // "blue" | "green" | "purple" | "pink" | "orange" | "mono"
  density: "comfy",   // "comfy" | "compact"
)

#tp.cover-slide(
  kicker: "# README.md",
  title: [Your deck\ in a readme.],
  badges: ("v0.1.0", ("MIT", "accent"), ("build: passing", "success")),
  footer-left: "@you · 2026",
  footer-right: "↓ scroll  ·  → next",
)

#tp.section-slide(number: "01", title: [Getting started])

#tp.content-slide(title: [What you get])[
- Light + dark themes, six accents, two density presets.
- Markdown-flavored slide bodies — `-` lists, `+` enums, fenced code blocks.
- Helpers for tables, stats, alerts, tasks — see the API in the README.
]

#tp.content-slide(title: [Edit this file])[
+ Replace this body with your own content.
+ Swap `accent:` and `theme:` in the `register.with(...)` call above.
+ Run `typst compile main.typ` (or watch with `typst watch main.typ`).
]

#tp.closing-slide(
  title: [Thanks.],
  links: ("github.com/ameneceur/tp_slides_template", "typst.app/universe"),
)
