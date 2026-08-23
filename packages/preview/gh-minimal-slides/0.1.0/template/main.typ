#import "@preview/touying:0.7.3": *
#import "@preview/gh-minimal-slides:0.1.0" as gh

#show: gh.register.with(
  theme:   "light",   // "light" | "dark"
  accent:  "blue",    // "blue" | "green" | "purple" | "pink" | "orange" | "mono"
  density: "comfy",   // "comfy" | "compact"
)

#gh.cover-slide(
  kicker: "# README.md",
  title: [Your deck\ in a readme.],
  badges: ("v0.1.0", ("MIT", "accent"), ("build: passing", "success")),
  footer-left: "@you · 2026",
  footer-right: "↓ scroll  ·  → next",
)

#gh.section-slide(number: "01", title: [Getting started])

#gh.content-slide(title: [What you get])[
- Light + dark themes, six accents, two density presets.
- Markdown-flavored slide bodies — `-` lists, `+` enums, fenced code blocks.
- Helpers for tables, stats, alerts, tasks — see the API in the README.
]

#gh.content-slide(title: [Edit this file])[
+ Replace this body with your own content.
+ Swap `accent:` and `theme:` in the `register.with(...)` call above.
+ Run `typst compile main.typ` (or watch with `typst watch main.typ`).
]

#gh.closing-slide(
  title: [Thanks.],
  links: ("github.com/xingjian-zhang/gh-minimal-slides", "typst.app/universe"),
)
