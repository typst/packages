# Unofficial University of Oregon Dissertation Template for Typst (2024)

An unofficial dissertation template for the University of Oregon, following the **2024 Graduate School Style Manual** and official Word template requirements.

## Features

- ✅ Closely follows [UO 2023 Style Manual](https://graduatestudies.uoregon.edu/sites/default/files/2023-07/2023-style-manual.pdf)
- ✅ Based on official [UO Word prefatory template (2024 edition)](https://graduatestudies.uoregon.edu/dissertation-prefatory-pages-template)
- ✅ Automatic section numbering (1.1, 1.2, etc.)
- ✅ Roman numeral chapter headings (CHAPTER I, II, III...)
- ✅ Customizable copyright options (standard or Creative Commons)
- ✅ Support for figures, tables, and schemes
- ✅ Pre-formatted prefatory pages (abstract, CV, acknowledgments, etc.)
- ✅ Proper page numbering throughout
- ✅ Clean, modular structure for easy editing

## Installation

### Using Typst Universe (Recommended)
```bash
typst init @preview/uo-dissertation-2024
cd uo-dissertation-2024
```

### Manual Installation

1. Download or clone this repository
2. Navigate to the template directory
3. Edit `metadata.typ` with your information
4. Compile: `typst compile main.typ dissertation.pdf`

## Quick Start

1. **Edit metadata.typ** - Add your dissertation information:
```typst
#let dissertation-title = "Your Dissertation Title"
#let author-name = "Your Name"
#let degree-name = "Doctor of Philosophy"
#let major-name = "Your Major"
#let term = "Fall"
#let year = "2024"
// ... etc
```

2. **Write your chapters** - Edit files in the `chapters/` folder:
```typst
// chapters/chapter-1.typ
#import "../config.typ": uo-figure, uo-table

#set par(first-line-indent: 0.5in, leading: 2em)

= Introduction

Your content here...

== Background
== Problem Statement
```

3. **Compile**:
```bash
typst compile main.typ dissertation.pdf
```

## Directory Structure
```
├── main.typ              # Main file (compile this)
├── config.typ            # Formatting rules
├── metadata.typ          # Your dissertation info
├── prefatory/            # Title page, abstract, CV, etc.
├── chapters/             # Your chapters
└── figures/              # Store images here
```

## Customization

### Copyright Options

In `main.typ`, choose one copyright option:
```typst
#let copyright-option = "standard"  // Regular copyright
// #let copyright-option = "cc-by"  // Creative Commons BY
// #let copyright-option = "cc-by-nc-sa"  // CC BY-NC-SA
```

### Optional Sections

Comment out sections you don't need in `main.typ`:
```typst
#include "prefatory/cv.typ"  // Include CV
// #include "prefatory/acknowledgments.typ"  // Skip acknowledgments
```

### Heading Levels

- Level 1 (`=`): Chapter titles → "CHAPTER I INTRODUCTION"
- Level 2 (`==`): Sections → "1.1 Background"
- Level 3 (`===`): Subsections → "1.1.1 History"
- Level 4 (`====`): Sub-subsections → "1.1.1.1 Details"

## Requirements

- Typst 0.12.0 or later
- STIX Two Text font (included in most Typst installations)

## License

MIT License - free to use, modify, and distribute for any purpose.

See LICENSE file for full text.

## Contributing

Contributions welcome! Please open an issue or pull request on GitHub.

## Short Description for Typst Universe

Unofficial University of Oregon dissertation template for Typst, following the 2024 UO Graduate School Style Manual and official Word template requirements.

---

**Note**: Always verify current requirements with the UO Graduate School before submitting your dissertation. Requirements may change.

---
