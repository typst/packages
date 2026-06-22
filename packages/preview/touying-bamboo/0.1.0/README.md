# touying-bamboo

A fresh, bamboo-green theme for the [Touying](https://github.com/touying-typ/touying) presentation framework.

## Features

- Clean header with current section title and slide title
- Footer with slide counter (`current / total`)
- Title slide with centered layout
- Section divider slides
- Focus slides (full-color background for emphasis)
- Bamboo-green primary color (`#5E8B65`)

## Usage

Import directly in your Typst file:

```typ
#import "@preview/touying-bamboo:0.1.0": *

#show: bamboo-theme.with(
  aspect-ratio: "16-9",
  footer: none,
)

#title-slide(
  title: "My Presentation",
  author: "Your Name",
  date: datetime.today(),
)

= Section

== Slide Title

#slide[
  Content goes here...
]

#focus-slide[
  Key takeaway
]
```

## Configuration

### `bamboo-theme`

| Parameter | Default | Description |
|---|---|---|
| `aspect-ratio` | `"16-9"` | Slide aspect ratio (`"16-9"`, `"4-3"`, etc.) |
| `footer` | `none` | Footer text displayed on each slide |

### Slide Functions

| Function | Description |
|---|---|
| `slide(title: auto, body)` | Standard content slide with optional title |
| `title-slide(title, author, date)` | Centered title slide |
| `new-section-slide(body)` | Section divider with current heading |
| `focus-slide(body)` | Full-color emphasis slide |

## Dependencies

- `@preview/touying:0.7.4`

## License

MIT — Copyright (c) 2025 songwupei
