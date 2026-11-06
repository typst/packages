# RenderCV

A CV/resume template for Typst with extensive customization options.

## Installation

```typst
#import "@preview/rendercv:0.2.0": *
```

## Quick Start

```typst
#import "@preview/rendercv:0.2.0": *

#show: rendercv.with(
  name: "John Doe",
)

= John Doe

#headline([Software Engineer])

#connections(
  [San Francisco, CA],
  [#link("mailto:john@example.com")[john\@example.com]],
  [#link("https://github.com/johndoe")[github.com/johndoe]],
)

== Education

#education-entry(
  [
    *University Name*, BS in Computer Science -- City, State
  ],
  [
    Sept 2018  May 2022
  ],
  main-column-second-row: [
    - GPA: 3.9/4.0
    - Honors: Dean's List
  ],
)

== Experience

#regular-entry(
  [
    *Software Engineer*, Company Name -- City, State
  ],
  [
    June 2022  present
  ],
  main-column-second-row: [
    - Developed and deployed scalable web applications
    - Collaborated with cross-functional teams
    - Improved system performance by 40%
  ],
)

== Skills

*Programming:* Python, JavaScript, TypeScript, Rust

*Technologies:* React, Node.js, PostgreSQL, Docker
```

## Components

### Header Components

**`headline(content)`** - Display a headline below your name:
```typst
#headline([Data Scientist])
```

**`connections(...items)`** - Display contact information with automatic line wrapping:
```typst
#connections(
  [New York, NY],
  [#link("mailto:jane@example.com")[jane\@example.com]],
  [#link("https://linkedin.com/in/jane")[LinkedIn]],
)
```

**`connection-with-icon(icon-name, content)`** - Add FontAwesome icons to connections:
```typst
#connection-with-icon("location-dot")[Boston, MA]
#connection-with-icon("envelope")[email\@example.com]
#connection-with-icon("github")[github.com/username]
```

### Entry Components

**`regular-entry(main-column, date-and-location-column, main-column-second-row: none)`** - Standard entry for experience, projects, publications:
```typst
#regular-entry(
  [*Senior Developer*, Tech Corp -- Remote],
  [Jan 2023  present],
  main-column-second-row: [
    - Led team of 5 engineers
    - Architected microservices platform
  ],
)
```

**`education-entry(main-column, date-and-location-column, degree-column: none, main-column-second-row: none)`** - Entry for education with optional degree column:
```typst
#education-entry(
  [*MIT*, PhD in Computer Science -- Cambridge, MA],
  [Sept 2020  May 2024],
  main-column-second-row: [
    - Thesis: Advanced Neural Network Optimization
  ],
)
```

**`content-area(content)`** - Wrap text content with proper formatting:
```typst
== Summary

#content-area[
A software engineer with 5+ years of experience building
scalable web applications.
]
```

**`summary(content)`** - Add a summary block within an entry:
```typst
#regular-entry(
  [*Open Source Project*],
  [2023  present],
  main-column-second-row: [
    #summary[High-performance data processing library]
    - 10,000+ GitHub stars
  ],
)
```

**`reversed-numbered-entries(content)`** - Create reverse-numbered lists:
```typst
== Invited Talks

#reversed-numbered-entries[
+ Talk Title 3  Conference 2024
+ Talk Title 2  Conference 2023
+ Talk Title 1  Conference 2022
]
```

**`link(dest, body, icon: none, if-underline: none, if-color: none)`** - Enhanced link with customizable styling:
```typst
#link("https://example.com", icon: false)[Example]
#link("https://example.com", if-underline: false)[Example]
```

## Customization

The template is highly customizable through parameters passed to `rendercv.with()`:

### Page Settings

```typst
#show: rendercv.with(
  page-size: "us-letter",        // or "a4", "us-legal", etc.
  page-top-margin: 0.7in,
  page-bottom-margin: 0.7in,
  page-left-margin: 0.7in,
  page-right-margin: 0.7in,
  page-show-footer: true,
  page-show-top-note: true,
  text-direction: ltr,           // or rtl for right-to-left languages
  footer: context {
    "Page " + str(here().page()) + " of " + str(counter(page).final().first())
  },
  top-note: "Last updated in " + datetime.today().display(),
)
```

### Colors

```typst
#show: rendercv.with(
  colors-body: rgb(0, 0, 0),
  colors-name: rgb(0, 79, 144),
  colors-headline: rgb(0, 79, 144),
  colors-connections: rgb(0, 79, 144),
  colors-section-titles: rgb(0, 79, 144),
  colors-links: rgb(0, 79, 144),
  colors-footer: rgb(128, 128, 128),
  colors-top-note: rgb(128, 128, 128),
)
```

### Typography

```typst
#show: rendercv.with(
  typography-font-family-body: "Raleway",
  typography-font-family-name: "Raleway",
  typography-font-family-headline: "Raleway",
  typography-font-family-connections: "Raleway",
  typography-font-family-section-titles: "Raleway",
  typography-font-size-body: 10pt,
  typography-font-size-name: 30pt,
  typography-font-size-headline: 10pt,
  typography-font-size-connections: 10pt,
  typography-font-size-section-titles: 1.4em,
  typography-line-spacing: 0.6em,
  typography-alignment: "justified",  // or "left", "justified-with-no-hyphenation"
  typography-date-and-location-column-alignment: right,
  typography-bold-name: false,
  typography-bold-headline: false,
  typography-bold-connections: false,
  typography-bold-section-titles: false,
  typography-small-caps-name: false,
  typography-small-caps-headline: false,
  typography-small-caps-connections: false,
  typography-small-caps-section-titles: false,
)
```

### Header

```typst
#show: rendercv.with(
  header-alignment: left,  // or center, right
  header-space-below-name: 0.7cm,
  header-space-below-headline: 0.7cm,
  header-space-below-connections: 0.7cm,
  header-connections-separator: "",
  header-connections-space-between-connections: 0.5cm,
  header-connections-show-icons: true,
)
```

### Section Titles

```typst
#show: rendercv.with(
  section-titles-type: "with_full_line",  // or "with_partial_line", "moderncv"
  section-titles-line-thickness: 0.5pt,
  section-titles-space-above: 0.5cm,
  section-titles-space-below: 0.3cm,
)
```

### Sections & Entries

```typst
#show: rendercv.with(
  sections-allow-page-break: true,
  sections-space-between-text-based-entries: 0.3em,
  sections-space-between-regular-entries: 1.2em,
  entries-date-and-location-width: 4.15cm,
  entries-side-space: 0.2cm,
  entries-space-between-columns: 0.1cm,
  entries-allow-page-break: false,
  entries-summary-space-left: 0cm,
  entries-summary-space-above: 0.12cm,
  entries-highlights-bullet: "■",
  entries-highlights-nested-bullet: "▪",
  entries-highlights-space-left: 0cm,
  entries-highlights-space-above: 0.12cm,
  entries-highlights-space-between-items: 0.12cm,
  entries-highlights-space-between-bullet-and-text: 0.5em,
)
```

### Links

```typst
#show: rendercv.with(
  links-underline: false,
  links-show-external-link-icon: false,
)
```

## Examples

The [examples](examples/) directory contains several complete CV examples demonstrating different configurations:

- [`classic.typ`](examples/classic.typ) - Clean layout with full-width section lines
- [`moderncv.typ`](examples/moderncv.typ) - Left-aligned dates with decorative lines
- [`engineeringresumes.typ`](examples/engineeringresumes.typ) - Engineering-focused layout
- [`engineeringclassic.typ`](examples/engineeringclassic.typ) - Classic engineering style
- [`sb2nov.typ`](examples/sb2nov.typ) - Minimalist design
- [`rtl.typ`](examples/rtl.typ) - Right-to-left layout (Persian)

Each example shows different parameter combinations to achieve various looks.

## License

MIT License
