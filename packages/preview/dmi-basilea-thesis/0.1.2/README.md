# DMI Basel Thesis Template for Typst

A modern thesis template for the University of Basel, Department of Mathematics
and Computer Science, built with [Typst](https://typst.app).

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
#import "@preview/dmi-basilea-thesis:0.1.2": *

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

#### Font Weights

- `chapter-number-weight`: Weight for chapter numbers (default: "bold")
- `chapter-title-weight`: Weight for chapter titles (default: "bold")

#### Sections

- `sections`: This is an array where each object defines the styling for a
  specific subsection level. The array index corresponds to the subsection level
  (e.g., index 0 for level 1, index 1 for level 2, and so on). Each object
  within the array contains the following properties:
  - `size`: The font size of the section
  - `weight`: The font weight
  - `space-before`: The spacing before the section start
  - `space-after`: The spacing after the section title
  - `style`: A custom styling function for the section
- `default-section`: This is a single dictionary that defines the default
  styling for any heading level not explicitly included in the sections array.
  It contains the same properties as the dictionaries within the sections array.

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

Contributions are welcome! Please open an issue or submit a pull request on
[GitHub](https://github.com/Nifalu/dmi-basilea-thesis).
