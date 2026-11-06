# ClassicThesis for Typst

A Typst template inspired by [André Miede's ClassicThesis](https://ctan.org/pkg/classicthesis) LaTeX style, which is an homage to Robert Bringhurst's *The Elements of Typographic Style*.

## Features

- **Elegant typography** with Palatino-style fonts (TeX Gyre Pagella)
- **Spaced small caps** for chapter and section headings
- **Classic book design** with proper margins and running headers
- **Part pages** with optional preamble text
- **Theorem environments** (theorem, definition, example, remark)
- **Clean code blocks** with monospace fonts

## Quick Start

```bash
typst init @preview/classicthesis:0.1.0 my-book
cd my-book
typst compile main.typ
```

## Usage

```typst
#import "@preview/classicthesis:0.1.0": *

#show: classicthesis.with(
  title: "My Book Title",
  subtitle: "A Subtitle",
  author: "Author Name",
  date: "2025",
  dedication: [To my readers.],
  abstract: [This book explores...],
)

#part("Part One", preamble: [Introduction to the topic.])

= Chapter One

Your content here...

== Section

More content...
```

## Template Options

| Option | Type | Description |
|--------|------|-------------|
| `title` | string | Document title |
| `subtitle` | string | Optional subtitle |
| `author` | string | Author name |
| `date` | string | Publication date |
| `paper` | string | Paper size (default: "a4") |
| `lang` | string | Language code (default: "en") |
| `dedication` | content | Optional dedication page |
| `abstract` | content | Optional abstract |

## Environments

### Theorem

```typst
#theorem(title: "Pythagorean Theorem")[
  In a right triangle, $a^2 + b^2 = c^2$.
]
```

### Definition

```typst
#definition(title: "Algorithm")[
  A finite sequence of well-defined instructions.
]
```

### Example

```typst
#example(title: "Sorting")[
  QuickSort has average complexity $O(n log n)$.
]
```

### Remark

```typst
#remark()[
  This is an additional observation.
]
```

### Part

```typst
#part("Part Title", preamble: [
  Optional descriptive text for this part.
])
```

## Recommended Fonts

For the authentic ClassicThesis look, install these fonts:

- **TeX Gyre Pagella** - Palatino clone (main text)
- **Fira Code** - Monospace with ligatures (code)

On Ubuntu/Debian:
```bash
sudo apt install fonts-texgyre fonts-firacode
```

## Colors

The template defines these colors for customization:

- `halfgray` - Chapter numbers
- `maroon` - Part titles
- `royalblue` - Links
- `webgreen` - Citation links
- `webbrown` - URL links

## Credits

- Original ClassicThesis LaTeX template by [André Miede](http://www.miede.de)
- Typographic principles from *The Elements of Typographic Style* by Robert Bringhurst
- Typst port by Adwiteey Mauriya

## License

MIT License - see [LICENSE](LICENSE) for details.
