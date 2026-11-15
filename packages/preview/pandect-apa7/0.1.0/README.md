<div align="center">

# pandect-apa7

**A modular, standards-compliant, and universally accessible APA 7th Edition framework for Typst.**

[![Typst Compiler](https://img.shields.io/badge/typst-0.15.0-blue?style=flat-square&logo=typst)](https://typst.app/)
[![Package Version](https://img.shields.io/badge/version-0.1.0-orange?style=flat-square)](typst.toml)
[![Accessibility: PDF/UA-1](https://img.shields.io/badge/accessibility-PDF%2FUA--1-green?style=flat-square)](https://github.com/Row0902/pandect-apa7/blob/v0.1.0/docs/accessibility.md)
[![CI: Build Status](https://github.com/Row0902/pandect-apa7/actions/workflows/ci.yml/badge.svg)](https://github.com/Row0902/pandect-apa7/actions/workflows/ci.yml)
[![released with: cutver](https://img.shields.io/badge/released%20with-cutver-0969da?style=flat-square&logo=git&logoColor=white)](https://github.com/cutver/cutver)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple?style=flat-square)](LICENSE)

<br />

<p align="center">
  <a href="#-quickstart">Quickstart</a> •
  <a href="#-visual-gallery">Visual Gallery</a> •
  <a href="#-documentation-guides">Documentation</a> •
  <a href="#-core-features">Features</a> •
  <a href="#-accessibility--screen-readers">Accessibility</a> •
  <a href="#-module-architecture">Architecture</a>
</p>

</div>

---

## Overview

`pandect-apa7` — a *pandect* is a complete digest of a body of knowledge — provides a complete, modern implementation of the **American Psychological Association (APA) Style (7th Edition)** for [Typst](https://typst.app/). Designed with modularity, developer ergonomics, and native accessibility in mind, it handles page geometry, typography, dual-mode title pages, 5-level hierarchical headings, accessible tables, figures, abstracts, appendices, statistical reporting, and formal STEM theorems.

---

## 🖼️ Visual Gallery

Every preview below is compiled directly from our included Typst examples with native **PDF/UA-1** universal accessibility.

<div align="center">

| Student Paper Title Page | Professional Paper Title Page |
| :---: | :---: |
| <img src="https://raw.githubusercontent.com/Row0902/pandect-apa7/v0.1.0/assets/preview-student-cover.png" width="380" alt="Preview of an APA 7 Student Title Page: Page number 1 in top-right header, bold centered paper title, author name Rowell Urbaez Reyes, institutional affiliation, course number, instructor name, and formatted assignment due date." /> | <img src="https://raw.githubusercontent.com/Row0902/pandect-apa7/v0.1.0/assets/preview-professional-cover.png" width="380" alt="Preview of an APA 7 Professional Title Page: Running head MINIMAL APA7 in top-left, page number 1 in top-right, bold centered title, author name, affiliation, and Author Note section in the lower third with correspondence details." /> |

| Abstract & Keywords | Math & Statistics (APA 7) |
| :---: | :---: |
| <img src="https://raw.githubusercontent.com/Row0902/pandect-apa7/v0.1.0/assets/preview-abstract.png" width="380" alt="Preview of an APA 7 Abstract and Keywords page: Centered bold Level 1 heading Abstract, single unindented double-spaced paragraph, followed by an indented block with italicized label Keywords: and a list of five keywords." /> | <img src="https://raw.githubusercontent.com/Row0902/pandect-apa7/v0.1.0/assets/preview-math-and-stats.png" width="380" alt="Preview of an APA 7 Spanish Body page: Theoretical definition block, display trigonometric limit with upright sen(x)/x = 1, indented block quote with double spacing, Level 2 heading Resultados Empíricos, and in-text statistical reporting with t-test and 95% confidence interval." /> |

| Tables and Figures (APA 7 Compliant) |
| :---: |
| <img src="https://raw.githubusercontent.com/Row0902/pandect-apa7/v0.1.0/assets/preview-table-figure.png" width="550" alt="Preview of an APA 7 Table and Figure page: Table 1 with bold number and italic title, three horizontal borders with no vertical lines, table note at bottom, followed by Figure 1 with caption on top, diagram, and note below." /> |

</div>

---

## 📖 Documentation Guides

We designed dedicated, low-cognitive-load guides organized with tables and practical snippets:

<div align="center">

| Guide | Description | Target Audience |
| :--- | :--- | :--- |
| 🚀 **[Getting Started](https://github.com/Row0902/pandect-apa7/blob/v0.1.0/docs/getting-started.md)** | Quick setup, boilerplate templates, and CLI compile commands | First-time authors & students |
| 📚 **[API Reference](https://github.com/Row0902/pandect-apa7/blob/v0.1.0/docs/api-reference.md)** | Complete parameters, signatures, and default values | Developers & advanced users |
| ♿ **[Accessibility Guide](https://github.com/Row0902/pandect-apa7/blob/v0.1.0/docs/accessibility.md)** | PDF/UA-1 standard, screen reader shortcuts, and speech tagging | Screen reader users & accessibility audits |
| 📐 **[STEM & Math Guide](https://github.com/Row0902/pandect-apa7/blob/v0.1.0/docs/stem-and-math.md)** | Calculus formulas, linear algebra, theorem blocks, and Spanish math | Mathematics, physics & statistics courses |

</div>

---

## ⚡ Quickstart

Get started immediately using one of our complete, production-ready templates:

<details open>
<summary><b>🎓 Student Paper Template (Click to expand / collapse)</b></summary>

```typst
#import "@preview/pandect-apa7:0.1.0": *

#show: apa7.with(
  paper-type: "student",
  title: "The Effects of Sleep Deprivation on Cognitive Performance",
  authors: (
    (
      name: "Rowell Urbaez Reyes",
      affiliation: "Department of Psychology, University Example",
    ),
  ),
  course: "PSYC 201: Research Methods in Psychology",
  instructor: "Dr. Jane Smith",
  due-date: datetime(year: 2026, month: 11, day: 9),
  abstract: [
    This study investigates the correlation between chronic sleep restriction and
    short-term working memory retention among undergraduate students...
  ],
  keywords: ("Sleep deprivation", "Cognitive psychology", "Memory retention"),
  lang: "en",
)

= Introduction

Sleep deprivation is a prevalent issue in modern academic environments...
```

</details>

<details>
<summary><b>🔬 Professional Paper Template (Click to expand / collapse)</b></summary>

```typst
#import "@preview/pandect-apa7:0.1.0": *

#show: apa7.with(
  paper-type: "professional",
  title: "Neural Correlates of Working Memory Retention",
  running-head: "WORKING MEMORY RETENTION",
  authors: (
    (
      name: "Rowell Urbaez Reyes",
      affiliation: "Department of Psychology, University Example",
    ),
  ),
  author-note: [
    Rowell Urbaez Reyes, Independent Researcher.

    Correspondence concerning this article should be addressed to Rowell Urbaez Reyes, Email: contact\@example.com.
  ],
  abstract: [
    This paper presents a standardized implementation of APA 7th edition formatting...
  ],
  keywords: ("APA style", "Typst", "Academic writing", "PDF/UA-1"),
  lang: "en",
)

= Introduction

As demonstrated by #cite-narrative(<baddeley1974>, page: 48), working memory capacity...
```

</details>

<details>
<summary><b>🇪🇸 Plantilla en Español / Spanish Academic Template (Click to expand / collapse)</b></summary>

```typst
#import "@preview/pandect-apa7:0.1.0": *

#show: apa7.with(
  paper-type: "student",
  title: "Efectos de la Privación de Sueño en el Rendimiento Cognitivo",
  authors: (
    (name: "Carolina Sánchez", affiliation: "Universidad Nacional"),
    (name: "Carlos Pedraza", affiliation: "Universidad Nacional"),
    (name: "Joaquín Rueda", affiliation: "Universidad Nacional"),
  ),
  course: "PSIC 201: Metodología de la Investigación",
  instructor: "Dra. María Duarte",
  due-date: datetime(year: 2026, month: 11, day: 9),
  abstract: [
    Este estudio analiza el impacto de la restricción crónica del sueño sobre la memoria...
  ],
  keywords: ("Privación de sueño", "Memoria de trabajo", "Psicología cognitiva"),
  lang: "es", // Activa "y" sin coma serial, "Referencias", "Resumen", "Tabla", etc.
)

= Introducción

La privación del sueño es un problema prevalente en el ámbito académico contemporáneo...
```

</details>

---

## ♿ Accessibility & Screen Readers

`pandect-apa7` is engineered for **Universal Access** and conforms natively to **PDF/UA-1** (ISO 14289-1).

When navigating compiled PDFs using screen readers like **NVDA**, **JAWS**, or **VoiceOver**:

- <kbd>H</kbd> / <kbd>Shift</kbd> + <kbd>H</kbd>: Jump forward/backward between section headings.
- <kbd>1</kbd> – <kbd>5</kbd>: Jump directly to specific heading levels.
- <kbd>T</kbd> / <kbd>Shift</kbd> + <kbd>T</kbd>: Jump directly to data tables.
- <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Arrow Keys</kbd>: Navigate table cells. Column headers are spoken automatically before each data cell.
- Headers and page numbers are isolated as **PDF Artifacts** so speech synthesis is not interrupted between pages.

```bash
# Validate your document against the PDF/UA-1 standard
typst compile --pdf-standard ua-1 paper.typ paper.pdf
```

---

## 🌟 Core Features

- **Strict Page Geometry:** Standard Letter (or A4) dimensions, 1-inch (2.54 cm) margins on all sides, and top-right page numbers.
- **Dual Title Page Modes:** Student cover (course, instructor, due date) and Professional cover (running head, author note).
- **APA 7 Headings (Levels 1–5):** Automated formatting for all five heading levels (Levels 4 & 5 run-in with automatic trailing period).
- **Approved Typography:** Native presets for standard APA fonts (Times New Roman 12pt, Georgia 11pt, Calibri 11pt, Arial 11pt) with double line spacing (200%) and 0.5-inch paragraph indentation.
- **Structured Tables & Figures:** Compliant layouts with captions on top, three-rule horizontal borders, zero vertical lines, and notes at the bottom.
- **Abstract & Keywords:** Dedicated unindented abstract page with formatted keywords.
- **Appendices:** Automatic labeling and formatting with subordinate numbering (`Table A1`, `Figure A1`).
- **Statistical Reporting (`apa-stat`):** Automatic omission of leading zeros for bounded statistics ($p, r, \eta_p^2$), formatted confidence intervals, and $t$/$F$/$\chi^2$ tests.
- **STEM Theorems & Proofs:** `#apa-theorem`, `#apa-definition`, `#apa-proof` with automatic QED symbol and Spanish operators (`sen`, `tg`, `mcd`, etc.).
- **Bilingual Localization (EN / ES):** Full support for English (Oxford comma and ampersands) and Spanish (RAE / normas-apa.org conjunction rules).

---

## 📂 Module Architecture

The framework is strictly divided into cohesive modules, with every single file guaranteed under **400 lines**:

```text
src/
├── lib.typ             # Main entry point, orchestrator, and public facade (150 lines)
└── apa7/
    ├── layout.typ      # Page dimensions, margins, running heads, and page numbers (87 lines)
    ├── typography.typ  # Typeface settings, paragraph indents, quotes, and footnotes (92 lines)
    ├── heading.typ     # Rules and show functions for Heading Levels 1 to 5 (56 lines)
    ├── cover.typ       # Student and Professional cover page renderers (162 lines)
    ├── abstract.typ    # Abstract layout and keywords block (71 lines)
    ├── table.typ       # APA compliant table styling and notes (93 lines)
    ├── figure.typ      # APA compliant figure layouts and captions (80 lines)
    ├── appendix.typ    # Appendix title and letter-sequencing utilities (69 lines)
    ├── reference.typ   # References list, hanging indents, and citation helpers (102 lines)
    ├── stat.typ        # Statistical reporting engine (apa-stat, apa-t, etc.) (204 lines)
    └── theorem.typ     # STEM academic blocks and accessible math helpers (162 lines)
```

---

## Development & Testing

To compile or inspect the package locally:

```bash
# Clone the repository
git clone git@github.com:Row0902/pandect-apa7.git
cd pandect-apa7

# Compile an example with Universal Accessibility (PDF/UA-1)
typst compile --pdf-standard ua-1 examples/minimal.typ examples/minimal.pdf
```

---

## 🚀 Release Orchestration

This project uses [Cutver](https://github.com/cutver/cutver) for automated Semantic Versioning, conventional changelog generation, and sandboxed release orchestration. All releases are preflight-audited with `cutver doctor` and published by [@cutver-release[bot]](https://github.com/apps/cutver-release).

<div align="center">

[![released with: cutver](https://img.shields.io/badge/released%20with-cutver-0969da?style=flat-square&logo=git&logoColor=white)](https://github.com/cutver/cutver)

</div>

---

## Author

**Rowell Urbaez Reyes**  
- GitHub: [@Row0902](https://github.com/Row0902)

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with architectural discipline for universal access and academic rigor.</sub>
</div>
