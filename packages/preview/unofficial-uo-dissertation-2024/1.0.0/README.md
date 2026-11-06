# University of Oregon Dissertation Template 2024

An unofficial dissertation template for the University of Oregon, following the **2024 Graduate School Style Manual** and official Word template requirements.

## Features

- ✅ Fully compliant with UO 2024 Style Manual
- ✅ Based on official UO Word template (2024 edition)
- ✅ Automatic section numbering (1.1, 1.2, etc.)
- ✅ Roman numeral chapter headings (CHAPTER I, II, III...)
- ✅ Automatic Table of Contents (chapters and sections)
- ✅ Customizable copyright options (standard or Creative Commons with badges)
- ✅ Chapter-based figure/table numbering (Figure 1.1, 1.2, 2.1, etc.)
- ✅ Support for figures, tables, and schemes
- ✅ Pre-formatted prefatory pages (abstract, CV, acknowledgments, etc.)
- ✅ Single-spaced captions, double-spaced body text
- ✅ Proper page numbering throughout
- ✅ Clean, modular structure for easy editing

## Installation

### Using Typst CLI

```bash
typst init @preview/unofficial-uo-dissertation-2024
cd unofficial-uo-dissertation-2024
```

### Manual Installation

```bash
git clone https://github.com/pamitabh/unofficial-uo-dissertation-2024
cd unofficial-uo-dissertation-2024/template
typst compile main.typ dissertation.pdf
```

## Quick Start

### 1. Edit metadata.typ

Add your dissertation information:

```typ
#let dissertation-title = "Your Dissertation Title"
#let author-name = "Your Name"
#let degree-name = "Doctor of Philosophy"
#let major-name = "Your Major"
#let term = "Fall"
#let year = "2024"
#let committee-chair = "Dr. Jane Smith"
// ... etc
```

### 2. Choose Copyright Option

In `metadata.typ`, select one copyright option:

```typ
#let copyright-option = "standard"  // Regular copyright
// #let copyright-option = "cc-by"  // Creative Commons BY
// #let copyright-option = "cc-by-nc-sa"  // CC BY-NC-SA
```

### 3. Write Your Chapters

Edit files in the `chapters/` folder:

```typ
// chapters/chapter-1.typ

= Introduction

Your content here...

== Background
== Problem Statement
```

### 4. Compile

```bash
typst compile main.typ dissertation.pdf
```

Or use watch mode for automatic recompilation:

```bash
typst watch main.typ dissertation.pdf
```

## Directory Structure

```text
├── LICENSE
├── README.md             # This file
├── thumbnail.png
├── typst.toml
├── config.typ            # Formatting rules
└── template/
    ├── main.typ          # Main file (compile this)
    ├── metadata.typ      # Your dissertation info
    ├── references.bib    # Your bibliography
    ├── prefatory/        # Title page, abstract, CV, etc.
    │   ├── abstract.typ
    │   ├── cv.typ
    │   ├── acknowledgments.typ
    │   ├── dedication.typ
    │   ├── list-of-figures.typ
    │   ├── list-of-tables.typ
    │   ├── list-of-schemes.typ
    │   └── cc-badges/    # Creative Commons badge images
    ├── chapters/         # Your chapters
    │   ├── chapter-1.typ
    │   ├── chapter-2.typ
    │   └── ...
    ├── appendices/       # Optional appendices
    └── figures/          # Store images here
```

## Customization

### Heading Levels

- **Level 1** (`=`): Chapter titles → "CHAPTER I INTRODUCTION"
- **Level 2** (`==`): Sections → "1.1 Background"
- **Level 3** (`===`): Subsections → "1.1.1 History"
- **Level 4** (`====`): Sub-subsections → "1.1.1.1 Details"

### Figures and Tables

```typ
// Create a figure
#figure(
  image("figures/my-image.png", width: 80%),
  caption: [Description of the figure],
) <fig:label>

// Reference in text
As shown in @fig:label...

// Create a table
#figure(
  table(
    columns: 3,
    [Header 1], [Header 2], [Header 3],
    [Data 1], [Data 2], [Data 3],
  ),
  caption: [Table description],
) <tab:label>
```

Figures and tables are automatically numbered by chapter (1.1, 1.2, 2.1, etc.).

### Optional Sections

Comment out sections you don't need in `main.typ`:

```typ
#include "prefatory/cv.typ"  // Include CV
// #include "prefatory/acknowledgments.typ"  // Skip acknowledgments
```

### Creative Commons Licenses

If using a CC license, the corresponding badge image will automatically display on the copyright page.

Supported licenses:
- CC BY 4.0
- CC BY-SA 4.0
- CC BY-NC 4.0
- CC BY-NC-SA 4.0
- CC BY-ND 4.0
- CC BY-NC-ND 4.0

Badge images are included in `prefatory/cc-badges/`.

## Requirements

- Typst 0.12.0 or later
- STIX Two Text font (included in most Typst installations)

## Compliance

This template is based on:
- University of Oregon Graduate School 2024 Style Manual
- Official UO dissertation Word template (2024 edition)
- UO Graduate School formatting requirements

**Note**: This is an unofficial template. Always verify current requirements with the UO Graduate School before submitting your dissertation.

## License

MIT License - free to use, modify, and distribute for any purpose.

See [LICENSE](LICENSE) file for full text.

### Third-Party Media

This template includes the following figures:

- *Nataraja* image: [India statue of Nataraja](https://commons.wikimedia.org/wiki/File:India_statue_of_nataraja.jpg)  
  by [Rosemania](https://www.flickr.com/photos/rosemania/86746598), licensed under  
  [Creative Commons Attribution 2.0 Generic (CC BY 2.0)](https://creativecommons.org/licenses/by/2.0/).

- *Dunning–Kruger effect* diagram: Dedicated to the public domain under  
  [Creative Commons CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).

## Contributing

Contributions welcome! Please open an issue or pull request on [GitHub](https://github.com/pamitabh/unofficial-uo-dissertation-2024).