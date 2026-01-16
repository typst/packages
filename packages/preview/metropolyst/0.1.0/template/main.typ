// Metropolyst Theme - Presentation Template
// A highly configurable Metropolis-style theme for Touying

#import "@preview/metropolyst:0.1.0": *

// Theme setup with default configuration
// See README.md for all available options
#show: metropolyst-theme.with(
  // Uncomment to customize:
  // font: ("Fira Sans",),
  // accent-color: rgb("#eb811b"),
  // header-background-color: rgb("#23373b"),
  config-info(
    title: [Your Presentation Title],
    subtitle: [Optional Subtitle],
    author: [Your Name],
    date: datetime.today(),
    institution: [Your Institution],
    // logo: emoji.rocket,
  ),
)

// Title slide
#title-slide()

// Section divider
= Introduction

== Getting Started

This presentation uses the Metropolyst theme with default settings:

- *Aspect ratio:* 16:9
- *Fonts:* Fira Sans throughout
- *Accent color:* Orange (\#eb811b)
- *Header background:* Dark teal (\#23373b)

== Example of two-column layout
#slide(composer: (3fr, 2fr))[
  === The first column is wider than the second
  Because the code for the layout is

  ```typst
  #slide(composer: (3fr, 2fr))[
    First column content
  ][
    Second column content
  ]
  ```
][
  === For equal width columns
  You can instead do

  ```typst
  #slide[
    First column content
  ][
    Second colum content
  ]
  ```
]

// Focus slide for emphasis
#focus-slide[
  This is a focus slide for emphasis!
]

== Configuration options, and a long slide title with font size automatically scaled to fit on one line

These are the default styles for *bold*, #alert[alert], and #link("https://typst.app")[hyperlink] text.

View the #link("https://github.com/benzipperer/metropolyst")[documentation] for all configuration options.

=== Example

```typst
#show: metropolyst-theme.with(
  font: ("Roboto",),                       // Modern sans-serif
  font-size: 22pt,                         // Slightly larger text
  accent-color: rgb("#10b981"),            // Emerald accent
  hyperlink-color: rgb("#0ea5e9"),         // Sky blue links
  header-background-color: rgb("#0f172a"), // Slate dark header
)
#set strong(delta: 300)                    // Bolder bold text
```

#text(
  font: "Roboto",
  size: 22pt,
)[These are the custom styles for #text(weight: "bold")[*bold*], #text(fill: rgb("#10b981"))[alert], and #link("https://typst.app")[#text(fill: rgb("#0ea5e9"))[hyperlink]] text.]


