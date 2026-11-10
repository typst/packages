<h1 align="center">modern-ucas-thesis</h1>

<p align="center">
  <strong>English</strong> | <a href="../README.md">中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-beta-blue?style=flat-square" alt="Project Status">
  <img src="https://img.shields.io/github/last-commit/Vncntvx/modern-ucas-thesis?style=flat-square" alt="Last Commit">
  <img src="https://img.shields.io/github/issues/Vncntvx/modern-ucas-thesis?style=flat-square" alt="Issues">
  <img src="https://img.shields.io/github/license/Vncntvx/modern-ucas-thesis?style=flat-square" alt="License">
</p>

A thesis for the University of Chinese Academy of Sciences (UCAS) based on [Typst](https://typst.app/), following the format requirements of the "UCAS Graduate Thesis Writing Guidelines (2022)".

> ⚠️ **Disclaimer**: This project is not officially produced. Please verify the latest format requirements from the university before use.
---

## Quick Start

### 1. Install Typst

```bash
# macOS
brew install typst

# Windows
winget install --id Typst.Typst

# Or use the official installation script
curl -fsSL https://typst.community/install | sh
```

### 2. Use the Project

```bash
# Clone the repository
git clone https://github.com/Vncntvx/modern-ucas-thesis.git
cd modern-ucas-thesis

# Compile the thesis
typst compile template/thesis.typ

# Or enable live preview
typst watch template/thesis.typ
```

### 3. Configure Thesis Information

Edit `template/thesis.typ`:

```typst
#import "../lib.typ": *

#show: documentclass.with(
  title: "Thesis Title",
  author: "Author Name",
  supervisor: "Supervisor Name",
  degree: "Doctor",
  major: "Computer Science and Technology",
)

// Start writing...
```

---

## Project Structure

```text
modern-ucas-thesis/
├── template/          # Thesis source files
│   ├── thesis.typ    # Main file
│   ├── ref.bib       # References
│   └── images/       # Images directory
├── pages/            # Page templates (cover, abstract, etc.)
├── layouts/          # Layout templates (preface, mainmatter, appendix)
├── utils/            # Utility functions
├── lib.typ           # Main library entry
└── docs/             # Documentation
```

---

## Features

| Category | Feature | Status |
|----------|---------|--------|
| **Document Configuration** | Global configuration (document type, degree type, fonts, etc.) | Completed |
| | Anonymous review mode | Completed |
| | Double-sided printing mode | Completed |
| **Cover and Front Matter** | Bachelor cover (Chinese/English) | In Progress |
| | Graduate cover (Chinese/English) | Completed |
| | Originality statement and authorization | Graduate completed, Bachelor in progress |
| | Chinese abstract (with keywords) | Completed |
| | English abstract (with keywords) | Completed |
| | Table of contents (with list of figures/tables) | Completed |
| | Notation list (terms and symbols) | Completed |
| **Main Text Typesetting** | Chapter heading numbering | Completed |
| | Header and footer settings | In Progress |
| | Footnotes and endnotes | Not Started |
| | Cross-references (figures, tables, equations, chapters) | Completed |
| **Figures and Tables** | Bilingual captions (Chinese/English) | Completed |
| | Figure/table notes | Completed |
| | Chapter-based numbering | Completed |
| | Automatic/manual continued tables | In Progress |
| | Appendix prefix for figures/tables | In Progress |
| **Equations and Math** | Display equation numbering | Completed |
| | Multi-line equation alignment and numbering | Completed |
| | Chapter-based equation numbering | Completed |
| | Appendix prefix for equations | Completed |
| **References** | Bilingual bibliography title | Completed |
| | GB/T 7714-2015 format support | Completed |
| | Automatic Chinese-English format conversion | Completed |
| | Citation and cross-reference | Completed |
| **Appendix and Back Matter** | Appendix chapters (Roman numerals) | Completed |
| | Acknowledgements | Completed |
| | Author biography and publications | Completed |
| **Fonts and Typesetting** | Predefined font sets | Completed |
| | Custom font configuration | Completed |
| | Chinese-Western mixed typography | Completed |
| **Other Document Types** | Postdoctoral thesis | Not Started |
| | Bachelor thesis proposal | Not Started |
| | Graduate thesis proposal | Not Started |
| | Theorem/Lemma/Proof environments | Not Started |

---

## Documentation

- [Customization Guide](CUSTOMIZE.md)
- [FAQ](FAQ.md)
- [Formatting Tools](FORMAT.md)

---

## Development

```bash
# Format code
make format

# Check formatting
make format-check
```

---

## Acknowledgements

- Based on [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis)
- Referenced [ucasthesis](https://github.com/mohuangrui/ucasthesis) LaTeX template

---

## License

The code of this project is open-sourced under the [MIT](../LICENSE) License.

**About UCAS Logo**: The visual identity elements such as the university emblem and logo in the `assets/vi/` directory are copyrighted by the University of Chinese Academy of Sciences. They are included in this project solely for the convenience of users writing degree theses (falling under the category of personal learning/teaching fair use). Please do not use them for other commercial or official purposes. For commercial licensing, please contact the relevant university departments. See [LOGO_COPYRIGHT.md](LOGO_COPYRIGHT.md) for details.

---

<p align="center">
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/issues">Report Issues</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/discussions">Discussions</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/pulls">Contribute</a>
</p>
