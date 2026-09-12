# eskd-drafting

`eskd-drafting` is a Typst package that generates engineering drawing frames, title blocks (stamps), and technical document layouts in compliance with the Unified System for Design Documentation (ESKD / GOST).

Documentation: [Русская версия (Russian)](README.ru.md) | [Full English Specification](README.en.md)

---

<p align="center">
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-1.png" alt="Preview 1" width="19%" />
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-2.png" alt="Preview 2" width="19%" />
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-3.png" alt="Preview 3" width="19%" />
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-4.png" alt="Preview 4" width="19%" />
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-5.png" alt="Preview 5" width="19%" />
</p>

---

## Overview

`eskd-drafting` provides standard drawing borders, official title blocks (Forms 1, 2, 2a, 2b), binding margin inventory stamps, rotated document codes (Box 26), custom font injection, and automatic layout management.

> **NOTE**: `eskd-drafting` is dedicated strictly to page geometry, margins, drawing frames, title blocks, and inventory margin stamps. The package does not enforce formatting on inner body text, headings, or scientific reports (GOST 7.32).

---

## Quick start

### Project initialization (CLI)

```bash
typst init @preview/eskd-drafting:0.1.0 my-eskd-document
```

### Direct usage

```typst
#import "@preview/eskd-drafting:0.1.0": *

#show: eskd-document.with(
  paper: "a4",                                          // Paper size per GOST 2.301-68
  orientation: "portrait",                              // Portrait orientation (A4 allows only portrait per GOST 2.301)
  preset-lines: "industry",                             // "industry" (0.8 mm thick dividers) or "gost" (0.35 mm thin)
  members: (
    ("Разраб.", "Алексеев",  "12.05.26"),
    ("Пров.",   "Борисов",   "15.05.26"),
    ("Т.контр.","Васильев",  "18.05.26"),
    ("Н.контр.","Григорьев", "19.05.26"),
    ("Утв.",    "Дмитриев",  "20.05.26"),
  ),
  code: [АБВГ.000111.001РЭ],                            // Cell 2: Document code (120x15 mm)
  name: [Блок управления\ Руководство по эксплуатации], // Cell 1: Title (70x25 mm)
  org: [НПК "Электроника"],                             // Cell 9: Organization (50x15 mm)
  lit: [О1],                                            // Cell 4: Litera per GOST 2.103-2013
  mass: [0,05],                                         // Cell 5: Mass in kg (decimal comma)
  scale: [1:1],                                         // Cell 6: Scale per GOST 2.302-68
  code-inverted: auto,                                  // Cell 26: Rotated document code
  inv-orig: [12345],                                    // Cell 19: Inventory number
  sig-date-orig: [12.05.26],                            // Cell 20: Date and signature
)

// 1. Title Page
#show: page-title
#align(center + horizon)[
  #gost-text(h: h7_0, weight: "bold")[РУКОВОДСТВО ПО ЭКСПЛУАТАЦИИ]
]

// 2. Table of Contents (Form 2 with TOC headers -> Form 2a)
#show: page-first-form2.with(
  left: frame-left-7r,
  toc: (num: [№], name: [Наименование], code: [Обозначение], note: [Примечание]),
)
#align(center)[#gost-text(h: h5_0, weight: "bold")[СОДЕРЖАНИЕ]]
#outline(title: none)

// 3. Document Body (Form 2 -> Form 2a)
#show: page-first-form2
= 1. Введение
Текст пояснительной записки...

#show: page-body
= 2. Расчетная часть
Продолжение документа...
```

> **TIP**: In compliance with GOST 2.304-81, `eskd-drafting` defaults to upright text and avoids synthetic/geometric slanting (which distorts stroke width $d$ and bounding boxes). To use authentic 75° lettering, inject a true GOST font file and set `font-italic: true`.

---

## Key features

- Official Title Blocks:
  - Form 1 (185 × 55 mm): Drawings and schematics (first sheet, GOST 2.104-2006).
  - Form 2 (185 × 40 mm, 185 × 52 mm with `toc`): Text documents and Table of Contents title sheets (GOST 2.104-2006, GOST 2.105 / 2.106).
  - Form 2a (185 × 15 mm): Subsequent sheets for all documents (GOST 2.104-2006).
  - Form 2b (185 × 15 mm): Subsequent sheets for double-sided documents (GOST 2.104-2006).
- Flexible Page Numbering & Suppression:
  - `page: auto` / `total: auto` (dynamic page counting), `none` (complete suppression of numbers and labels), or custom explicit values (`page: 42, total: 100`).
- Side Stamps on Binding Margin (Cells 19–25):
  - `frame-left-3r` (85 × 12 mm), `frame-left-5r` (145 × 12 mm), `frame-left-7r` (H × 12 mm, `gap: auto` default 47 mm for A4 folding; `gap: "max"` for top-corner placement).
- Rotated Document Code (Box 26): Top-left corner document code rotated 180° (`code-inverted: auto`, `none`, or custom dict with `frame: true/false`).
- Custom Font Injection & CAD Ecosystem Groups: Pass `font: "CustomFont"` (or `"osifont"`) and select CAD ecosystem font groups via `font-group: "ascon"` (or `"autocad"`, `"solidworks"`, `"tflex"`, `"spds"`) with automatic GOST 2.304-81 metric calculations (Type A & Type B) and true 75° inclination (`font-italic: true`).
- Text Auto-Fitting & Readability Validation:
  - Stepping across standard font heights h ∈ {40.0, ..., 1.8} mm.
  - Warnings and errors for excessive shrinkage: `< 70%` (`gost-text-scale-warning`) and `< 40%` (`gost-text-scale-extreme`).
- Line Rendering Presets:
  - `preset-lines: "industry"` (0.8 mm thick dividers, default) or `"gost"` (0.35 mm thin dividers).
- Validation Engine (`ignore-rules`):
  - Automatic validation of scales (GOST 2.302), literas (GOST 2.103), paper formats (GOST 2.301), and line weights (GOST 2.303).

---

## Example catalog (`examples/`)

### Quick start (`01-quickstart/`)
- [examples/01-quickstart/readme-quickstart.typ](examples/01-quickstart/readme-quickstart.typ) — Quick Start: Minimal working example creating a compliant ESKD document with standard title block fields.
- [examples/01-quickstart/all-page-types.typ](examples/01-quickstart/all-page-types.typ) — ESKD Page Presets Showcase: Comprehensive demonstration of all 6 built-in page layouts (`page-title`, `page-first-form2`, `page-body`, `page-first-form1`, `page-body-double`, `page-blank`).

### Drawings and schematics (`02-drawings/`)
- [examples/02-drawings/drawing-a4.typ](examples/02-drawings/drawing-a4.typ) — A4 Portrait Detail Drawing: Form 1 title block (55 mm), 3-row left inventory stamp 3r (cells 19–23), cell 26 (inverted code), cell 3 (material).
- [examples/02-drawings/drawing-a3.typ](examples/02-drawings/drawing-a3.typ) — A3 Landscape Assembly Drawing: Form 1 title block, 5-row left inventory stamp 5r (cells 19–25), cell 26, compound litera "О1".
- [examples/02-drawings/drawing-a2-portrait.typ](examples/02-drawings/drawing-a2-portrait.typ) — A2 Portrait Assembly Drawing: 7r side stamp layout with fixed gap (`gap: 47mm`) for A4 folder binding.
- [examples/02-drawings/drawing-a2-landscape.typ](examples/02-drawings/drawing-a2-landscape.typ) — A2 Landscape Assembly Drawing: Form 1 title block, 7-row left inventory stamp 7r (cells 19–25), cell 26.
- [examples/02-drawings/multiplied-formats-a4x3-drawing.typ](examples/02-drawings/multiplied-formats-a4x3-drawing.typ) — A4x3 Multiplied Drawing & Scheme (630x297 mm): Working frame $605 \times 287\text{ мм}$, Form 1, side stamp 7r, Cell 31 ("Copied") and Cell 32 (`Формат А4х3`).

### Text documents (`03-text-documents/`)
- [examples/03-text-documents/explanatory-note.typ](examples/03-text-documents/explanatory-note.typ) — Explanatory Note (Multi-page Text Document): Complete workflow: Title (`page-title`), TOC (`page-first-form2` with `toc`, Form 2 52 mm), Main Section (`page-first-form2`, Form 2 40 mm), Body Pages (`page-body`, Form 2a 15 mm).
- [examples/03-text-documents/double-sided-text.typ](examples/03-text-documents/double-sided-text.typ) — Double-Sided Text Document (Specifications): Alternating odd pages with right-side binding margin (Form 2, Form 2a) and even pages with mirrored left-side margin and Form 2b stamp (`page-body-double`).
- [examples/03-text-documents/text-document-with-a4x3-insert.typ](examples/03-text-documents/text-document-with-a4x3-insert.typ) — Explanatory Note with A4x3 Foldout Insert (GOST 2.105-2019): Continuous volume numbering with A4x3 foldout sheet for wide tables (Form 2a) and process diagrams (Form 1).

### Advanced metadata and revisions (`04-advanced-features/`)
- [examples/04-advanced-features/advanced-members.typ](examples/04-advanced-features/advanced-members.typ) — Advanced Signature Rows & Typography (cells 10–13): 4-element tuples with personal signatures, granular font heights (`label-size`, `name-size`), column harmonization (`compute-group-font`), empty separators `()`.
- [examples/04-advanced-features/advanced-changes.typ](examples/04-advanced-features/advanced-changes.typ) — Advanced Multi-Row Revisions Table (cells 14–18): Multi-row revision table (up to 4 rows in Form 1), array of dictionaries format, granular cell font heights (`doc-size`, `sig-size`), column font harmonization, dynamic sheet overrides via `eskd-set`.
- [examples/04-advanced-features/table-of-changes.typ](examples/04-advanced-features/table-of-changes.typ) — Table of Changes (cells 14–18): `changes` array, multi-row rendering on drawings (Form 1) and dynamic sheet updates for Form 2a.
- [examples/04-advanced-features/dynamic-override.typ](examples/04-advanced-features/dynamic-override.typ) — Dynamic Metadata & Page Number Overrides: On-the-fly metadata updates via `#eskd-set`, explicit page numbering overrides (`page`, `total`).
- [examples/04-advanced-features/copier-and-format-labels.typ](examples/04-advanced-features/copier-and-format-labels.typ) — Outer Frame Cells 31 and 32: Cell 31 ("Копировал", 120 mm) and Cell 32 ("Формат", 65 mm) with automatic paper size detection (`format: auto`).

### Fonts and line styles (`05-typography/`)
- [examples/05-typography/custom-fonts-and-types.typ](examples/05-typography/custom-fonts-and-types.typ) — Custom Fonts & GOST Type A Typography: Font injection via `font` parameter, GOST 2.304-81 Type A styling (`font-type: "type-a"`), thin-line preset `"gost"`.
- [examples/05-typography/text-scale-and-autofit.typ](examples/05-typography/text-scale-and-autofit.typ) — Font Auto-Fitting & Readability Validation: Discrete standard heights $h \in \{5.0, 3.5, 2.5, 1.8\}\text{ мм}$, readability warnings (`gost-text-scale-warning` < 70%) and error guard (`gost-text-scale-extreme` < 40%).
- [examples/05-typography/preset-lines.typ](examples/05-typography/preset-lines.typ) — Line Style Presets Comparison (`industry` vs `gost`): CAD-style 0.8 mm thick dividers compared to 0.35 mm thin lines.

### Custom title blocks (`06-custom-stamps/`)
- [examples/06-custom-stamps/custom-industry-stamp.typ](examples/06-custom-stamps/custom-industry-stamp.typ) — Custom Enterprise Title Block: Enterprise-specific title block integration via `bottom` parameter while preserving normative outer frame and margins.
- [examples/06-custom-stamps/student-custom-form.typ](examples/06-custom-stamps/student-custom-form.typ) — Academic Coursework Frame: Custom subsequent sheet title block integration via modular `subsequent-bottom` parameter.

---

## Custom title blocks

The package core follows official ESKD standards. Custom enterprise (STO, TU) and academic forms can be integrated via the `bottom:` or `subsequent-bottom:` parameters without modifying the core:
- Enterprise Standard Stamp: [examples/06-custom-stamps/custom-industry-stamp.typ](examples/06-custom-stamps/custom-industry-stamp.typ)
- Academic Coursework Frame: [examples/06-custom-stamps/student-custom-form.typ](examples/06-custom-stamps/student-custom-form.typ)

---

## Testing and performance

```bash
# Install test dependencies
pip install -r ./tests/requirements-dev.txt

# Run unit test suite
python ./tests/tests.py

# Run performance benchmark suite
python ./tests/benchmarks.py
```

- Linear Scalability O(N): Compilation time grows proportionally to page count.
- Export Standards: Validated across `PDF 1.7`, `PDF 2.0`, `PDF/A` (`1b`, `2b`, `3b`), `PDF/UA-1`, `SVG`, `PNG`, and `HTML`.

---

## License

This package uses dual-licensing:
- The core package and library source code are distributed under the [MIT License](LICENSE).
- The boilerplate and starter code provided in the `template/` and `examples/` directories are distributed under the [MIT No Attribution License (MIT-0)](https://spdx.org/licenses/MIT-0.html). This ensures that you can freely use, modify, and distribute documents created from these templates without any obligation to include the original copyright notice.
