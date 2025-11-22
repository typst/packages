# DMI Basel Thesis Template for Typst

A modern thesis template for the University of Basel, Department of Mathematics and Computer Science, built with [Typst](https://typst.app).

## Features

- **Fast compilation**: Near-instant preview updates
- **Clean design**: Based on the official LaTeX template
- **Multi-language**: Supports English and German
- **Draft mode**: Built-in TODO markers and draft indicators
- **Rich formatting**: Custom environments for definitions, theorems, algorithms
- **Flexible typography**: Full control over fonts, sizes, and weights

## Quick Start

### Using the Typst Package

```typst
#import "@preview/dmi-basilea-thesis:0.1.1": *

#show: thesis.with(
  title: "Your Thesis Title",
  author: "Your Name",
  supervisor: "Prof. Dr. Supervisor",
  examiner: "Prof. Dr. Examiner",
  thesis-type: "Bachelor Thesis",  // or "Master Thesis"

  abstract: [
    Your abstract here...
  ],

  chapters: (
    include "introduction.typ",
    include "methodology.typ",
    include "conclusion.typ",
  ),

  bibliography-content: bibliography("references.bib"),
)
```

### Local Development

1. Clone this repository
2. Import from the local path:
   ```typst
   #import "src/main.typ": *
   ```

## Configuration Options

### Basic Settings

- `title`: Your thesis title
- `author`: Your name
- `email`: Your email address
- `supervisor`: Name of your supervisor
- `examiner`: Name of your examiner
- `thesis-type`: "Bachelor Thesis" or "Master Thesis"
- `language`: "en" or "de"
- `date`: Defaults to today

### Optional Typography Control

#### Font Families
- `body-font`: Main text font (default: "Times New Roman")
- `sans-font`: Headings font (default: "Arial")
- `mono-font`: Code font (default: "Courier New")

#### Font Sizes
- `body-size`: Main text size (default: 10pt)
- `mono-size`: Code text size (default: 10pt)
- `footnote-size`: Footnote size (default: 9pt)
- `header-size`: Page header size (default: 9pt)

#### Heading Sizes
- `chapter-number-size`: Chapter number size (default: 100pt)
- `chapter-title-size`: Chapter title size (default: 24pt)
- `section-size`: Section heading size (default: 14pt)
- `subsection-size`: Subsection size (default: 11pt)
- `subsubsection-size`: Subsubsection size (default: 11pt)

#### Font Weights
- `chapter-number-weight`: Weight for chapter numbers (default: "bold")
- `chapter-title-weight`: Weight for chapter titles (default: "bold")
- `section-weight`: Section heading weight (default: "bold")
- `subsection-weight`: Subsection weight (default: "bold")
- `subsubsection-weight`: Subsubsection weight (default: "bold")

### Advanced Styling

For complete control, you can provide custom styling functions:

```typst
#show: thesis.with(
  // Rainbow gradient chapter titles
  chapter-title-style: (content) => text(
    size: 30pt,
    fill: gradient.linear(..color.map.rainbow),
    content
  ),

  // Custom body text
  body-text-style: (body) => {
    set text(font: "Minion Pro", size: 11pt)
    body
  },
)
```

Available style functions:
- `body-text-style`: Override body text styling
- `mono-text-style`: Override code text styling
- `chapter-number-style`: Override chapter number styling
- `chapter-title-style`: Override chapter title styling
- `section-style`: Override section styling
- `subsection-style`: Override subsection styling
- `subsubsection-style`: Override subsubsection styling

### Compilation Modes

- `draft`: Show/hide TODO markers (default: true)
- `colored`: Enable/disable colors for definitions and theorems (default: false)

## Template Features

### TODO Markers (Draft Mode)

```typst
#todo[General TODO]
#todo-missing[Missing content]
#todo-check[Needs verification]
#todo-revise[Needs revision]
#todo-citation[Add citation]
#todo-language[Check language]
#todo-question[Open question]
#todo-note[Note to self]
```

### Custom Environments

```typst
#definition(title: "Definition")[
  Your definition here...
]

#theorem(title: "Theorem")[
  Your theorem here...
]

#algorithm(caption: "My Algorithm")[
  Your algorithm here...
]
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on [GitHub](https://github.com/Nifalu/dmi-basilea-thesis).
