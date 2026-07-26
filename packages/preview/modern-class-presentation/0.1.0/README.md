# Modern Class Presentation

A clean, dependency-free Typst package for modern university lectures, seminars,
and classroom presentations. It provides a 16:9 canvas, an accessible
high-contrast palette, clear section dividers, focus slides, and reusable content blocks.

![Package status](https://img.shields.io/badge/Typst-package-356AE6?logo=typst&logoColor=white)

## Quick start

```typst
#import "@preview/modern-class-presentation:0.1.0": *
```

The `template/` directory is a complete starting presentation. Copy it into a
new project, or select it from Typst Universe once published.

## Building blocks

| Function | Purpose |
| --- | --- |
| `deck` | Configures the slide deck and renders the opening title slide. |
| `slide` | Renders a standard content slide with eyebrow, title, and footer. |
| `section-slide` | Creates a visual divider between topics with vertical accent bar. |
| `focus-slide` | Highlights a single key takeaway or statement in large centered text. |
| `callout` | Highlights a definition, question, or teaching point with left border accent. |
| `card` | Renders a clean content container box with optional top border accent. |
| `columns` | Lays out two content columns with configurable ratio and gutter. |
| `source` | Styles compact source and attribution text. |

All color constants are exported: `primary`, `teal`, `coral`, `gold`, `navy`,
`ink`, `muted`, `cloud`, and `white`. The `palette` dictionary offers the same
colors by name.

## Developing locally

Compile the included example from the repository root:

```sh
typst compile --root . examples/lecture.typ lecture.pdf
```

For a release, update `version` in `typst.toml`, compile the example, and
follow the [Typst Universe package submission guide](https://github.com/typst/packages).

## License

This project is licensed under the [MIT License](LICENSE).
