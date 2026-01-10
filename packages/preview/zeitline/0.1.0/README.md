# Zeitline

A Typst package for plotting timelines.

## Examples

![Timeline Example](img/spinetest.png)

![Custom Theme Example](img/custom_theme.png)

## Installation

Copy this package to your Typst packages directory or use it locally:

```typst
#import "@preview/zeitline:0.1.0": timeline
```

## Usage

```typst
#import "@preview/zeitline:0.1.0": timeline

#let events = (
  (date: "Jan 1", desc: "First event description"),
  (date: "Jan 2", desc: "Second event description"),
  (date: "Jan 3", desc: "Third event description"),
)

#timeline(events)
```

Each event is a dictionary with:
- `date`: The date/time label (required)
- `desc`: Event description (required)
- `side` (optional): Force "left" or "right" placement (alternates by default)

## Theme Customization

```typst
#timeline(events, theme: (
  colors: (
    accent: rgb("#2980b9"),  // Blue instead of red
    muted: rgb("#555555"),
    line: rgb("#aaaaaa"),
  ),
  sizes: (
    date: 12pt,
    body: 10pt,
    dot: 6pt,
    line-width: 3pt,
  ),
  spacing: (
    row: 1.5em,
    arm: 3em,
  ),
))
```

## Running Tests

To run the tests (e.g., `repro.typ` or `custom_theme.typ`), you must run `typst compile` from the project root and specify the root path so that imports resolve correctly:

```bash
# Run from the project root
typst compile --root . tests/repro.typ
typst compile --root . tests/custom_theme.typ
```

## License

MIT
