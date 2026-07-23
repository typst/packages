# touying-matcha

A fresh, matcha-green theme for the [Touying](https://github.com/touying-typ/touying) presentation framework.

## Features

- Clean header with current section title and slide title
- Footer with slide counter (`current / total`)
- Title slide with centered layout
- Section divider slides
- Focus slides (full-color background for emphasis)
- Matcha-green primary color (`#5E8B65`)

## Usage

Initialize a new presentation from this template:

```bash
typst init @preview/touying-matcha:0.1.0 my-presentation
cd my-presentation
typst compile main.typ
```

Or import the theme directly in an existing Typst project:

```typ
#import "@preview/touying-matcha:0.1.0": *

#show: matcha-theme.with(
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

### `matcha-theme`

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
