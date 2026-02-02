# TU Berlin Typst Presentation Template

## Overview

An **unofficial** Typst presentation template following TU Berlin's corporate design, built on [Touying](https://touying-typ.github.io/) 0.6.1 — a modern presentation framework for Typst with support for animations, multi-column layouts, and structured slide types.

### Features

- Official TU Berlin colors (Red `#c50e1f`, Gray `#717171`)
- Slide types: title, content, section, outline, ending
- Two-column and multi-column layouts via `composer`
- Slide animations with `#pause` and `#meanwhile`
- Header with slide title and logo, 3-column footer with author/title/date+page
- Optional progress bar in footer
- Content helpers: `alert-box`, `highlight-box`, `emphasis`, `tub-block`, `quote-block`
- Academic helpers: `tub-theorem`, `tub-definition`, `tub-example`
- Footnote-style citations with `slide-cite` and bottom-aligned references with `slide-ref`
- Speaker notes via Touying's built-in `speaker-note`

## Quick Start

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/clear-tub:0.2.0": *

#show: tub-theme.with(
  aspect-ratio: "16-9",
  department: [Department of Computer Science],
  logo: image("assets/logos/tub_logo.png"),
  progress-bar: true,
  config-info(
    title: [My Presentation Title],
    subtitle: [Optional Subtitle],
    author: [Author Name],
    date: datetime.today(),
    institution: [Technische Universität Berlin],
  ),
)

#title-slide()

#outline-slide()

= Section Heading        // auto-generates a section slide

== Slide Title            // auto-generates a content slide
- First point
- Second point

#pause                    // animation: reveals next content on click

- Third point (appears after pause)
```

## Installation

### Option 1: Typst Universe

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/clear-tub:0.2.0": *
```

### Option 2: Local Development

```bash
git clone https://github.com/yourusername/tub-typst-presentation
cd tub-typst-presentation
typst watch main.typ
```

## Slide Types

### Title Slide

```typst
#title-slide()
```

Centered layout with logo, title, subtitle, author, department, and date. No header/footer. Metadata is pulled from `config-info(...)`.

### Content Slide (default)

Content slides are created automatically from `== Heading` markup, or explicitly:

```typst
#slide[
  Content goes here.
]
```

Each content slide has a header bar (title + logo) and a 3-column footer.

### Section Slide

Auto-generated when using `= Heading` (level-1 heading). Displays the section name centered in TU Berlin red. No header/footer.

### Outline Slide

```typst
#outline-slide()
```

Displays a table-of-contents style outline of all sections. The current section is highlighted while others are dimmed (progressive outline). No header/footer.

### Ending Slide

```typst
#ending-slide(title: [Thank You!])[
  Author Name \
  author@tu-berlin.de
]
```

A centered closing slide with the title rendered in a red rounded block and body content below. No header/footer. Use for "Thank you", "Questions?", or contact information.

## Progress Bar

A thin red progress bar appears below the footer, showing how far through the presentation you are. It is enabled by default and can be toggled:

```typst
#show: tub-theme.with(
  progress-bar: true,   // default: true
  // ...
)
```

Set `progress-bar: false` to disable it.

## Multi-Column Layout

Use the `composer` parameter to create column layouts:

```typst
#slide(composer: (1fr, 1fr))[
  Left column content
][
  Right column content
]
```

For unequal columns:

```typst
#slide(composer: (2fr, 1fr))[
  Wider left column
][
  Narrower right column
]
```

## Animations

Touying supports sub-slide animations:

```typst
== Animated Slide
First point is always visible.

#pause

This appears on the second sub-slide.

#pause

This appears on the third sub-slide.
```

Use `#meanwhile` to show content on all sub-slides simultaneously in a different area.

## Content Helpers

### Alert Box

```typst
#alert-box[Important information with red left border.]
```

### Highlight Box

```typst
#highlight-box[Key takeaway in bold red text with gray background.]
```

### Emphasis

```typst
#emphasis[Bold red inline text.]
```

### TUB Block

A styled block with a colored header bar and light body area:

```typst
#tub-block(title: [Key Insight])[
  Content of the block goes here.
]
```

Pre-titled wrappers for academic content:

```typst
#tub-theorem[
  For any convex function $f$, a local minimum is also a global minimum.
]

#tub-definition[
  A function $f$ is *convex* if ...
]

#tub-example[
  The function $f(x) = x^2$ is convex on $RR$.
]
```

### Quote Block

A styled blockquote with optional attribution:

```typst
#quote-block(attribution: [Albert Einstein])[
  Imagination is more important than knowledge.
]
```

### Slide Citation

Footnote-style citation within a slide:

```typst
This result#slide-cite[Author, _Title_, Publisher, 2024.] shows that...
```

### Slide Reference

Bottom-aligned reference text:

```typst
#slide-ref[Source: Author, _Title_, 2024]
```

## Speaker Notes

Touying 0.6.1 supports speaker notes natively. Add notes to any slide:

```typst
== My Slide

Content visible to the audience.

#speaker-note[
  Remind audience about the key takeaway.
  Mention the follow-up study.
]
```

Speaker notes are hidden during the presentation by default. To display them on a second screen:

```typst
#show: tub-theme.with(
  config-common(show-notes-on-second-screen: right),
  // ...
)
```

Notes are also exported to PDF presenter tools (pdfpc format).

## Export to PPTX / HTML

Touying provides an exporter utility for converting presentations to other formats. See the [touying-exporter](https://github.com/touying-typ/touying-exporter) project for details on exporting to PPTX and HTML.

Basic workflow:

1. Install `touying-exporter` (requires Node.js)
2. Run: `touying-exporter export main.typ --format pptx`
3. Or for HTML: `touying-exporter export main.typ --format html`

Refer to the touying-exporter documentation for full options and requirements.

## Customization

### Theme Parameters

```typst
#show: tub-theme.with(
  aspect-ratio: "16-9",       // or "4-3"
  department: [Your Dept],
  logo: image("your-logo.png"),
  progress-bar: true,          // toggle footer progress bar
  footer-a: self => self.info.author,    // left footer
  footer-b: self => self.info.title,     // center footer
  footer-c: self => {                     // right footer
    utils.display-info-date(self)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
  },
  config-info(
    title: [...],
    subtitle: [...],
    author: [...],
    date: datetime.today(),
    institution: [...],
  ),
)
```

### Color Override

```typst
#show: tub-theme.with(
  config-colors(
    primary: rgb("#00FF00"),       // override accent color
    neutral-darkest: rgb("#222"),  // override text color
  ),
  config-info(title: [My Talk]),
)
```

### Available Colors

| Color | Hex | Usage |
|-------|-----|-------|
| TU Berlin Red | `#c50e1f` | Primary accent, headings |
| Gray | `#717171` | Secondary text, subtitles |
| Black | `#000000` | Body text |
| White | `#ffffff` | Backgrounds, ending slide text |
| Light Gray | `#f5f5f5` | Header background, highlight boxes |

## File Structure

```txt
clear-tub/
├── lib.typ              # Theme library (Touying-based)
├── main.typ             # Example presentation
├── typst.toml           # Package metadata
├── assets/
│   └── logos/
│       └── tub_logo.png # TU Berlin logo
├── README.md
└── DISCLAIMER.md
```

## Roadmap

Planned features for future releases:

- **Hero slide** — full-bleed image background with overlaid text
- **Navigation bar** — mini-slides or section dots in the header for at-a-glance navigation

## ⚠️ Logo Usage & Licensing

**IMPORTANT: This package contains TU Berlin's official logos which are:**
- **© Technische Universität Berlin**
- **NOT included under the MIT license**
- **Subject to TU Berlin's usage policies**

### Who Can Use the TU Berlin Logo?

✅ **TU Berlin Students & Staff:**
- Academic presentations and theses
- University-related events
- Scientific conferences (in academic context)

❌ **External Users:**
- Require explicit written permission from TU Berlin
- Contact: pressestelle@tu-berlin.de

### Template Code License

The **template code** (lib.typ and related Typst files) is licensed under **MIT License**.

The **TU Berlin logos and branding materials** are copyrighted by TU Berlin and subject to their institutional policies.

**Before using this template, verify you have the right to use TU Berlin's branding.** See:
- [TU Berlin Corporate Design Guidelines](https://www.tu.berlin/en/communication/services-for-tu-staff/corporate-design)
- Contact: corporate.design@pressestelle.tu-berlin.de

## Disclaimer

This is an **unofficial** template created by the community. It is not endorsed by or affiliated with TU Berlin. Verify compliance with your department's requirements before using for official presentations.

For official guidelines, contact:
- TU Berlin Communication & Public Relations
- [tu.berlin/en/communication](https://www.tu.berlin/en/communication)

## License

**MIT License** (applies to template code only)

The template code (Typst files, excluding logos and TU Berlin branding) is released under the MIT License. See the [LICENSE](LICENSE) file for full details.

**TU Berlin Logo and Branding:** © Technische Universität Berlin. Use subject to TU Berlin's institutional policies. See the logo usage section above for details.
