# modern-ucas-thesis

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

### 2. Use the Template

```bash
# Clone the repository
git clone https://github.com/Vncntvx/modern-ucas-thesis.git
cd modern-ucas-thesis

# Compile thesis
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

```
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

## Feature Support

- **Documentation**
  - [ ] Write more detailed documentation. For now, you can refer to [NJUThesis](https://mirror-hk.koddos.net/CTAN/macros/unicodetex/latex/njuthesis/njuthesis.pdf) documentation. The parameters are mostly consistent, or you can directly check the function parameters in the source code.
- **Type Checking**
  - [ ] All function parameters should be type-checked for timely error reporting
- **Global Configuration**
  - [x] Global information configuration similar to `documentclass` in LaTeX
  - [x] **Blind review mode** - replaces personal information with black bars and hides the acknowledgements page, for thesis submission stage
  - [x] **Duplex mode** - adds blank pages for convenient printing
  - [x] **Custom font configuration** - can configure specific fonts for "Song", "Hei", "Kai" and other fonts
  - [x] **Math font configuration**: The template does not provide configuration. Users can change it themselves using `#show math.equation: set text(font: "Fira Math")`
- **Templates**
  - [ ] Undergraduate template
    - [ ] Font test page
    - [ ] Cover
    - [ ] Statement page
    - [x] Chinese abstract
    - [x] English abstract
    - [x] Table of contents
    - [x] List of figures
    - [x] List of tables
    - [x] Notation list
    - [ ] Acknowledgements
  - [x] Graduate template
    - [x] Cover
    - [x] Statement page
    - [x] Chinese abstract
    - [x] English abstract
    - [ ] Table of contents
    - [x] List of figures and tables
    - [x] Bilingual figure/table captions
    - [x] Notation list
    - [ ] Header
    - [ ] Acknowledgements
    - [ ] Author biography
  - [ ] Postdoctoral template
- **Numbering**
  - [x] Preface uses Roman numeral numbering
  - [x] Appendix uses Roman numeral numbering
  - [x] Tables use `1.1` format for numbering
  - [x] Mathematical equations use `(1.1)` format for numbering
- **Environments**
  - [ ] Theorem environments (users can also configure this using third-party packages)
- **Other Files**
  - [ ] Undergraduate proposal
  - [ ] Graduate proposal

---

## Documentation

- [CUSTOMIZE](docs/CUSTOMIZE.md)
- [FAQ](docs/FAQ.md)
- [Formatting Tool](docs/FORMAT.md)

---

## Development

```bash
# Format code
make format

# Check format
make format-check
```

---

## Acknowledgements

- Developed based on [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis)
- Referenced [ucasthesis](https://github.com/mohuangrui/ucasthesis) LaTeX template

---

## License

This project's code is open-sourced under the [MIT](../LICENSE) license.

**About UCAS Logo**: The copyright of the university emblem, logo, and other visual identity elements in the `assets/vi/` directory belongs to the University of Chinese Academy of Sciences. This template includes them only for the convenience of users writing academic theses (which falls under the reasonable use category of personal study/teaching). Please do not use them for other commercial or official purposes. For commercial authorization, please contact the university's relevant department. See [LOGO_COPYRIGHT.md](LOGO_COPYRIGHT.md) for details.

---

<p align="center">
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/issues">Report Issue</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/discussions">Discussions</a> ·
  <a href="https://github.com/Vncntvx/modern-ucas-thesis/pulls">Contribute</a>
</p>
