#import "@preview/polylux:0.4.0": *
#import "@preview/clearly-hm:0.1.1" as hm: *

// Set theme and metatdata
#show: hm.setup.with(
  title: "Project Typst HM Presentation Theme",
  subtitle: "Getting Started with Typst's Polylux",
  author: "Tobias Wölfel",
  institute: "Hochschule München",
  date: datetime.today().display(),
  font: "Nimbus Sans",
  show-footer: false,
  show-footer-num-pages: true,
  color-primary: hm.colors.red,
  color-accent: hm.colors.red,
)

// Create title slide
// Content is retrived from metadata
#title-slide()

// Table of contents slide
// Depends on registered sections, see `#new-section()` below
#slide-toc()

// Start a new section, name is registered and shown in table of contents
// This is creating a slide with the name and a progress bar
// Options: don't show slide, see example below
#new-section("Motivation")

#slide[
  = Motivation
  - Typst is great
  - Polylux for creating presentations
  - HM theme, because logos and colors are nice

  #linebreak()
  - This slide is using the standard `#slide` command
]

// Start a new section without displaying a slide
#new-section("Project Status", show-slide: false)

#slide[
  #heading(level: 1)[Project Status]
  - Early stages
    - Title page and footer with HM logos
      - Custom layouts and section slides
]

// New section with table of contents entry
#new-section-orientation("Layouts")

#slide-vertical("Content vertical aligned")[
  - Content is centered vertically
]

#slide-centered("Content is centered", show-footer: false)[
  #text(size: 24pt)[Make a nice statement]

  #context {
    text(fill: text.fill.lighten(50%))[The predefined layouts have the argument
      `hide-footer` to not show the footer on specific slides.]
  }
]

#slide-split-2(
  "Split page into to columns",
  [
    - Default content starts at the top
  ],
  align(horizon)[- can use `align` to center it],
)

#slide-split-1-2(
  "Uneven split",
  [
    - Some short statements
    - Typst is powerful
  ],
  [
    - Here we need more space for longer explanations
    - When creating documents with Typst, the content is much more in focus
      compared to LaTeX.
  ],
)

#new-section-orientation("Features")

#title-slide(
  title: "Title slide with overwritten values",
  subtitle: "Adding the BMFTR logo",
  uppercase-title: false,
  author: none,
  institute: none,
  date: none,
  content-overlay: bmftr-note(dx: 0pt, dy: 0pt),
)
