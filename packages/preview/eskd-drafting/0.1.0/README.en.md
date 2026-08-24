# ESKD Engineering Documentation Library: `eskd-drafting`

`eskd-drafting` is a Typst package that generates technical drawing frames, title blocks (stamps), and document layouts in compliance with the Unified System for Design Documentation (ESKD / GOST).

Language versions: [Русская версия (Russian)](README.ru.md) | [Short Guide](README.md)

---

<p align="center">
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-1.png" alt="Preview 1" width="19%" />
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-2.png" alt="Preview 2" width="19%" />
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-3.png" alt="Preview 3" width="19%" />
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-4.png" alt="Preview 4" width="19%" />
  <img src="https://runasexe.github.io/eskd-drafting-assets/assets/v0.1.0/preview-5.png" alt="Preview 5" width="19%" />
</p>

---

## 1. Standards compliance

The library implements the following official state and interstate standards:

- GOST 2.104-2006 «Basic inscriptions (Title blocks and frames)»
- GOST 2.105-95 / GOST 2.105-2019 «General requirements for text documents»
- GOST 2.106-96 «Text documents»
- GOST 2.301-68 «Formats and sheet orientations»
- GOST 2.302-68 «Scales»
- GOST 2.303-68 «Lines and line thicknesses»
- GOST 2.304-81 «Lettering for drawings and typography»
- GOST 2.004-88 «General requirements for design and technological documents on computer output devices»
- GOST 2.103-2013 «Stages of design and document literas»
- GOST 2.501-2013 «Rules for accounting and storage»

> **NOTE**: `eskd-drafting` is dedicated strictly to page geometry, margins, drawing frames, title blocks, and inventory margin stamps. The package does not enforce styling on inner body content, scientific reports (GOST 7.32), or bibliographic references (GOST R 7.0.5).

---

## 2. Nomenclature of frames and title blocks

Standard sheet margins are established according to GOST 2.104-2006: 20 mm on the left (binding margin) and 5 mm on the top, right, and bottom.

### 2.1. Title blocks

| Form / Stamp | Module | Dimensions | Standard | Scope and Elements |
|---|---|---|---|---|
| Form 1 | `frames-form-1.typ` | 185 × 55 mm | GOST 2.104-2006 (clause 5.1) | Drawings and schematics (first sheet). Cell 1 (Title, 70 × 25 mm), cell 2 (Code, 120 × 15 mm), cell 3 (Material, 70 × 15 mm), cell 4 (Literas), cell 5 (Mass), cell 6 (Scale), cells 7 and 8 (Sheet/Sheets), cell 9 (Organization, 50 × 15 mm), up to 6 signature rows, revisions table. |
| Form 2 | `frames-form-2.typ` | 185 × 40 mm (185 × 52 mm with `toc`) | GOST 2.104-2006, GOST 2.105 / 2.106 | Text documents (first/title sheet). When the `toc` parameter is provided via page or form props, automatically includes a two-tier TOC header (12 mm) over the right section (120 mm): row 1 (5 mm) — "№" (15 mm), "Title" (70 mm), "Designation" (35 mm); row 2 (7 mm) — "Note" (120 mm) with a 65 × 12 mm cutout on the left. Passing `toc` to other forms is prohibited. |
| Form 2a | `frames-form-2a.typ` | 185 × 15 mm | GOST 2.104-2006 (clause 5.1) | Subsequent sheets for all document types. Cell 2 (110 mm), cell 7 (Sheet: top 7 mm label, bottom 8 mm number), revisions table on the left. |
| Form 2b | `frames-form-2b.typ` | 185 × 15 mm | GOST 2.104-2006 (clause 5.1) | Subsequent sheets for double-sided documents. Mirrored layout: cell 7 (Sheet) on the left (10 mm), cell 2 (Code) in the center (110 mm), revisions table on the right. |

### 2.2. Side stamps on binding margin (cells 19–25)

Placed along the left 20 mm margin with a -90° rotation:
- `frame-left-3r` (85 × 12 mm): cells 19–21 (`inv-orig`, `sig-date-orig`, `inv-repl`).
- `frame-left-5r` (145 × 12 mm): cells 19–23 (adds `inv-dup`, `sig-date-dup`).
- `frame-left-7r` (H × 12 mm): side inventory stamp (cells 19–25: bottom block 145 mm and top block 95 mm with cell 24 `ref-num` and cell 25 `prim-apply`).
  - Default mode (`gap: auto`): fixed 47 mm gap from the bottom block. All 7 cells fit within the baseline 287 mm height from the bottom of the sheet, complying with GOST 2.501-2013 folding requirements for A4 folders.
  - Stretched mode (`gap: "max"`): maximum possible gap (H_frame - 240 mm) where cells 24 and 25 align with the top-left corner of the inner frame.
  - Custom gap (`gap: <length>` / `none`): explicitly specified offset.

### 2.3. Rotated document code (box 26)

- `frame-code-inverted` (14 × 70 mm): inverted document code in the top-left corner of the inner frame rotated by 180° (GOST 2.104-2006 clause 4.1).
- Controlled by the `code-inverted` parameter:
  - `code-inverted: auto` — automatically enabled for drawings (Form 1) with `code` text and cell border; disabled for text documents (Forms 2, 2a, 2b).
  - `code-inverted: none` — explicitly disabled.
  - `code-inverted: [ABVG.123456.001]` — explicitly enabled with specified code and border.
  - `code-inverted: (text: [...], frame: false)` — rotated text without cell border.

---

## 3. Quick start

### 3.1. Project initialization (CLI)

```bash
typst init @preview/eskd-drafting:0.1.0 my-eskd-document
```

### 3.2. Minimal working example

```typst
#import "@preview/eskd-drafting:0.1.0": *

#show: eskd-document.with(
  paper: "a4",
  orientation: "portrait",
  preset-lines: "industry",
  members: (
    ("Разраб.", "Алексеев",  "12.05.26"),
    ("Пров.",   "Борисов",   "15.05.26"),
    ("Н.контр.","Григорьев", "19.05.26"),
    ("Утв.",    "Дмитриев",  "20.05.26"),
  ),
  code: [АБВГ.000111.001РЭ],
  name: [Блок управления\ Руководство по эксплуатации],
  org: [НПК "Электроника"],
  lit: [О1],
  inv-orig: [12345],
  sig-date-orig: [12.05.26],
)

// Title Page
#show: page-title
#align(center + horizon)[
  #gost-text(h: h7_0, weight: "bold")[РУКОВОДСТВО ПО ЭКСПЛУАТАЦИИ]
]

// Text Document Body
#show: page-first-form2
= 1. Introduction
Text of explanatory note...

#show: page-body
= 2. Technical Data
Continuing document content...
```

---

## 4. API reference and configuration

### 4.1. Complete document configuration (`eskd-document`)

```typst
#import "@preview/eskd-drafting:0.1.0": *

#show: eskd-document.with(
  // Paper format per GOST 2.301-68: "a4", "a3", "a2", "a1", "a0", "a4x3", "a3x4", etc.
  paper: "a4",
  // Orientation: "portrait" or "landscape"
  orientation: "portrait",
  // Line stroke preset: "industry" (0.8 mm thick dividers, default) or "gost" (0.35 mm thin)
  preset-lines: "industry",

  // Custom Font Injection with automated GOST 2.304-81 geometric metric calculations
  font: auto,                                   // "Arial", ("PT Astra Sans", "Arial"), etc.
  font-type: auto,                              // "type-b" (thickness d=1/10 h, default) or "type-a" (d=1/14 h)
  font-italic: false,                           // true for authentic 75° inclined font per GOST 2.304-81

  // 1. Members (cells 10–13 signature rows: label, name, date, sign)
  members: (
    ("Разраб.", "Алексеев",  "12.05.26"),
    ("Пров.",   "Борисов",   "15.05.26"),
    ("Т.контр.","Васильев",  "18.05.26"),
    ("Н.контр.","Григорьев", "19.05.26"),
    ("Утв.",    "Дмитриев",  "20.05.26"),
  ),

  // 2. Document Attributes (cells 1–9 per GOST 2.104-2006)
  code: [АБВГ.000111.001РЭ],                    // Cell 2: Document code (120x15 mm)
  name: [Блок управления\ Руководство по эксплуатации], // Cell 1: Document title (70x25 mm)
  org: [НПК "Электроника"],                     // Cell 9: Organization name (50x15 mm)
  material: [Сталь 45 ГОСТ 1050-2013],          // Cell 3: Material (Form 1 drawings)
  lit: [О1А],                                   // Cell 4: Document literas
  mass: [15,4],                                 // Cell 5: Mass in kg (decimal comma)
  scale: [1:2],                                 // Cell 6: Scale per GOST 2.302-68
  code-inverted: auto,                          // Cell 26: Inverted code (auto, none, content, dict)
  page: auto,                                   // Cell 7: Sheet number (auto, none, int, str)
  total: auto,                                  // Cell 8: Total sheet count (auto, none, int, str)

  // 3. Revisions Table (cells 14–18 per GOST 2.104-2006 and GOST 2.503-2013)
  changes: (
    (
      num: [1],                                 // Cell 14: Revision index (Изм.)
      sheet: [Зам.],                            // Cell 15: Sheet status (Зам., Нов. or sheet number)
      doc: [ИИ-401-26],                         // Cell 16: Notice number (№ докум.)
      sig: [Белов],                             // Cell 17: Signature (Подп.)
      date: [20.08.26],                         // Cell 18: Date
    ),
  ),

  // 4. Side Inventory Margin Stamps (cells 19–25 per GOST 2.104-2006)
  inv-orig: [12345],                            // Cell 19: Original inventory number
  sig-date-orig: [12.05.26],                    // Cell 20: Original approval date and signature
  inv-repl: [ВЗ-4512],                          // Cell 21: Replacement inventory number
  inv-dup: [67890],                             // Cell 22: Duplicate inventory number
  sig-date-dup: [15.05.26],                     // Cell 23: Duplicate approval date and signature
  ref-num: [РИС.2026],                          // Cell 24: Reference number (for 7r side stamp)
  prim-apply: [АБВГ.000111.000],                // Cell 25: Primary applicability (for 7r side stamp)

  // 5. Outer Frame Service Cells 31 and 32 (GOST 2.104-2006)
  copier: [Федоров],                            // Cell 31: Copier name (120 mm)
  format: auto,                                 // Cell 32: Paper format label (65 mm, auto, true, [A4x3])

  // 6. Typography Scale Hierarchy (GOST 2.304-81)
  sizes: (
    labels: h2_5,                               // Field labels ("Разраб.", "Лист" — 2.5 mm)
    values: h3_5,                               // Field values (names, dates — 3.5 mm)
    dates: h2_5,                                // Dates in signatures (2.5 mm)
    signs: h3_5,                                // Signatures (3.5 mm)
    code: h7_0,                                 // Document code in cell 2 (7.0 mm)
    name: h5_0,                                 // Document title in cell 1 (5.0 mm)
    org: h5_0,                                  // Organization name in cell 9 (5.0 mm)
    material: h5_0,                             // Material in cell 3 (5.0 mm)
    params: h5_0,                               // Mass and scale in cells 5, 6 (5.0 mm)
    lit: h3_5,                                  // Litera in cell 4 (3.5 mm)
    sheet: h3_5,                                // Sheet numbers in cells 7, 8 (3.5 mm)
  ),

  // 7. Rule Suppression Engine
  ignore-rules: auto,                           // auto (strict validation), "*" (disable all), or rule array
)
```

### 4.2. Dynamic state modification (`eskd-set`)

```typst
#eskd-set(
  name: [New Section Title],
  changes: ((num: [2], doc: [ИИ-402-26], sig: [Иванов], date: [25.08.26]),),
)
```

### 4.3. Page templates and document structure

Switch sections using `#show: <preset>`:

```typst
#show: page-title        // Title sheet (border and 5r side stamp, no title block)
#show: page-first-form2  // Text document title sheet (Form 2; subsequent — Form 2a)
#show: page-first-form1  // Drawing / scheme title sheet (Form 1; subsequent — Form 2a)
#show: page-body         // Subsequent sheets (Form 2a)
#show: page-body-double  // Subsequent sheets for double-sided printing (Form 2b)
#show: page-blank        // Blank sheet without borders
```

For table of contents title sheets, use `page-first-form2` with the `toc` structure passed in properties:

```typst
#show: page-first-form2.with(
  left: frame-left-7r,
  toc: (num: [№], name: [Наименование], code: [Обозначение], note: [Примечание]),
)
```

For customized sections, use `#eskd-page`:

```typst
#show: eskd-page.with(
  bottom: frame-form-1,             // Title block for first sheet of section
  left: frame-left-5r,              // Side stamp for first sheet
  subsequent-bottom: frame-form-2a, // Title block for subsequent sheets
  subsequent-left: frame-left-5r,   // Side stamp for subsequent sheets
  frame: true,                      // Outer drawing frame (true/false)
  code-inverted: auto,              // Inverted code (auto / none / [Code] / dict)
  gap: auto,                        // Gap for 7r side stamp (auto, "max", length, none)
  page: auto,                       // First sheet number of section (auto / none / int / str)
  total: auto,                      // Total sheets (auto / none / int / str)
  paper: "a3",                      // Paper format for section
  orientation: "landscape",         // Orientation for section
)
```

---

## 5. Engineering rationale and standard requirements

### 5.1. Side inventory stamp (`frame-left-7r`), folding and GOST 2.501-2013

- Standards: GOST 2.104-2006 (clause 4.1, 4.2, Figures 1 and 2), GOST 2.501-2013 (clause 5.6, Appendix G — drawing folding rules), GOST 2.301-68.
- Technical Context:
  - In GOST 2.104-2006, the side stamp on the 20 mm binding margin consists of a bottom block (cells 19–23, 145 mm long) and a top block (cell 24 `ref-num` 35 mm and cell 25 `prim-apply` 60 mm, totaling 95 mm).
  - In GOST 2.104-2006, illustrations are shown on an A4 sheet ($H_{\text{frame}} = 287\text{ mm}$), where $145 + 47 + 95 = 287\text{ mm}$, making cells 24 and 25 visually abut the top-left corner.
  - In some CAD systems, the top block was parametrically tied to the top edge of the frame, causing it to stretch to the full sheet height (410, 584, 831 mm) on A3–A0 formats.
  - According to GOST 2.501-2013, drawings of all formats bound into volumes are folded down to A4 (210 × 297 mm) leaving the 20 mm left margin for binding. If the stretched mode is used, cells 24 and 25 are concealed inside inner folds. With a fixed 47 mm gap, the entire inventory block (287 mm) fits within the first fold and remains visible on the binding spine.
- `gap` Parameter Modes:
  - `gap: auto` (default) — Fixed 47 mm gap. All 7 cells fit within the baseline 287 mm height from the bottom of the sheet, ensuring compliance with GOST 2.501-2013.
  - `gap: "max"` — Maximum gap ($H_{\text{frame}} - 240\text{ mm}$) where cells 24 and 25 align with the top-left corner of the sheet.
  - `gap: <length>` (e.g. `gap: 100mm` or `gap: none`) — Explicitly specified offset.

### 5.2. Line style preset `preset-lines: "industry"` and CAD standards

- Standards: GOST 2.104-2006 (clause 4.1), GOST 2.303-68.
- Technical Context:
  - In the revisions table (cells 14–18) and signature rows (cells 10–13), columns are 5, 7, and 10 mm wide.
  - The text of GOST 2.104-2006 specified continuous thin lines ($s_{\text{thin}} \approx 0.35\text{ мм}$) for internal cell dividers.
  - In CAD systems, rendering internal dividers with continuous thick lines ($s = 0.8\text{ мм}$) became the standard to maintain line contrast during plotting.
- `preset-lines` Options:
  - `preset-lines: "industry"` (default) — CAD standard with thick dividers (0.8 mm).
  - `preset-lines: "gost"` — Standard compliance with thin dividers (0.35 mm).

### 5.3. Rotated document code border (box 26 / `code-inverted`)

- Standards: GOST 2.104-2006 (clause 4.1, Figures 1 and 2).
- Technical Context: Cell 26 is a 180° rotated document code (70 × 14 mm) in the top-left corner of the inner frame.
- `code-inverted` Options:
  - `code-inverted: auto` (default) — Automatically enabled with cell border for drawings (Form 1); disabled for text documents.
  - `code-inverted: [ABVG.123456.001]` — Explicitly specified text with standard cell border.
  - `code-inverted: (text: [...], frame: false)` — Rotated code without cell border.
  - `code-inverted: none` — Explicitly disabled.

### 5.4. Outer frame service cells 31 («Copied») and 32 («Format»)

- Standards: GOST 2.104-2006 (clause 4.1, Figures 1–4), GOST 2.301-68.
- Geometry & Placement: Cells 31 and 32 are located outside the inner working frame on the 5-mm bottom margin directly below the title block in the lower right corner:
  - Cell 31 («Copied»): width 120 mm, height 5 mm (left);
  - Cell 32 («Format»): width 65 mm, height 5 mm (right).
  - Total width: $120\text{ мм} + 65\text{ мм} = 185\text{ мм}$ (matches title block width).
- Display Rules and Parameter Semantics:
  - Parameter `copier`:
    - `auto` (default) — Cell 31 renders `Копировал` with an empty signature area;
    - `none` — Cell 31 is disabled and hidden;
    - `str` / `content` / `dict` (e.g. `copier: [Федоров]`) — renders `Копировал <value>`.
  - Parameter `format`:
    - `auto` (default) — Cell 32 renders `Формат <format name>` auto-detected from page properties (`Формат А4`, `Формат А3`, `Формат А4х3`, etc.);
    - `true` — explicitly enables paper format rendering based on sheet dimensions;
    - `none` or `false` — Cell 32 is disabled and hidden;
    - `str` / `content` / `dict` (e.g. `format: [А4]`) — overrides the displayed format text.
  - Cells are rendered independently:
    - `copier: auto, format: auto` — both cells active;
    - `copier: none, format: auto` — only Cell 32 («Format») rendered;
    - `copier: auto, format: none` (or `format: false`) — only Cell 31 («Copied») rendered;
    - `copier: none, format: none` (or `format: false`) — both cells hidden.
  - When the outer border is disabled (`frame: false` per GOST 2.105-2019 cl. 4.1), service cells are not rendered.

### 5.5. Sheet format nomenclature and orientations (GOST 2.301-68, GOST 2.104-2006, GOST 2.501-2013)

The package implements standard nomenclature and spatial orientation rules for base and multiplied sheet formats per GOST 2.301-68 (Tables 1 and 2).

#### Base formats (GOST 2.301-68, cl. 2)

| Format | Sheet Size (mm) | Allowed Orientation | Standard Requirements |
|---|---|---|---|
| `a4` | 210 × 297 | Portrait only (`portrait`) | GOST 2.301-68 (cl. 2): A4 is restricted to portrait orientation only.<br>GOST 2.104-2006 (cl. 4.2.1): title block is placed strictly along the short side (210 mm). |
| `a3` | 297 × 420 | Landscape (`landscape`, primary)<br>Portrait (`portrait`, allowed) | GOST 2.301-68 (cl. 2), GOST 2.104-2006 (cl. 4.2.2): title block in the lower right corner. |
| `a2` | 420 × 594 | Landscape (primary)<br>Portrait (allowed) | GOST 2.301-68 (cl. 2), GOST 2.104-2006 (cl. 4.2.2). |
| `a1` | 594 × 841 | Landscape (primary)<br>Portrait (allowed) | GOST 2.301-68 (cl. 2), GOST 2.104-2006 (cl. 4.2.2). |
| `a0` | 841 × 1189 | Landscape (primary)<br>Portrait (allowed) | GOST 2.301-68 (cl. 2), GOST 2.104-2006 (cl. 4.2.2). |

Base formats are specified without suffix: `a4`, `a3`, `a2`, `a1`, `a0`. Designations with suffix `x1` (such as `a4x1`) are not defined by standard and raise `gost-2.301-68-paper-format`.

#### Multiplied formats `aNxM` (GOST 2.301-68, cl. 3, Table 2)

According to GOST 2.301-68 (cl. 3), multiplied formats are formed by multiplying exclusively the short side of the base sheet ($W = W_N \times M, H = H_N$). All derived formats are horizontal strips of fixed height and are used strictly in landscape orientation (`landscape`).

| Series | Format List | Dimensions ($H \times W$, mm) | Allowed Orientation | Standard Base |
|---|---|---|---|---|
| А4хN | `a4x3`..`a4x9` | 297 × (210 × N) (297 × 630 to 297 × 1892) | Landscape only | GOST 2.301-68 (cl. 3, Table 2), folding per GOST 2.501-2013 |
| А3хN | `a3x3`..`a3x7` | 420 × (297 × N) (420 × 891 to 420 × 2080) | Landscape only | GOST 2.301-68 (cl. 3, Table 2) |
| А2хN | `a2x3`..`a2x5` | 594 × (420 × N) (594 × 1261 to 594 × 2102) | Landscape only | GOST 2.301-68 (cl. 3, Table 2) |
| А1хN | `a1x3`, `a1x4` | 841 × (594 × N) (841 × 1783 to 841 × 2378) | Landscape only | GOST 2.301-68 (cl. 3, Table 2) |
| А0хN | `a0x2`, `a0x3` | 1189 × (841 × N) (1189 × 1682 to 1189 × 2523) | Landscape only | GOST 2.301-68 (cl. 3, Table 2) |

Multiplier $\times 2$ is omitted for most formats ($A4\times2 = A3$, $A3\times2 = A2$, $A2\times2 = A1$, $A1\times2 = A0$), except for $A0\times2$.

#### Engineering rationale and origins of restrictions

1. Vertical Orientation of A4: The baseline format for project documentation and archive storage is 210 × 297 mm. A portrait A4 sheet binds directly into standard folders along the 20 mm left margin without folding, keeping the title block immediately visible in the lower right corner of the front page.
2. Horizontal Orientation of Multiplied Formats A4xN: Format A4xN is designed to fold into standard A4 binders strictly via vertical concertina folds per GOST 2.501-2013 (Appendix B) with a 190/210 mm pitch. With a fixed height of 297 mm, the folded sheet matches binder height without horizontal folds, preserving title block visibility. Vertical orientation (e.g. 297 × 630 mm) is not supported because folding it without obscuring stamps and binding margins is physically impossible.
3. Standard Exceptions for A4 Landscape (297 × 210 mm):
   - GOST 2.004-88 (cl. 1.8) permits landscape A4 for wide computer printouts, tables, and listings;
   - GOST 2.701-2008 (cl. 5.1.2) permits schematics on landscape A4 where required by CAD workflows.
   - In `eskd-drafting`, suppress this check via: `ignore-rules: "gost-2.301-68-a4-landscape"`.

Geometry & Working Area for A4xN:
- Outer Margins: Left binding margin — 20 mm (only at the leftmost edge of the first segment), top, right, and bottom margins — 5 mm.
- Working Area inside Frame: Height $= 287\text{ mm}$, Width $= (210 \times N - 25)\text{ mm}$ ($605\text{ mm}$ for A4x3, $816\text{ mm}$ for A4x4).
- Folding per GOST 2.501-2013: Concertina folding into standard $210 \times 297\text{ mm}$ dimension allowing full rightward unfolding without unbinding, with title block remaining visible on the cover.

Foldout Insert Sheets in Text Documents (GOST 2.105-2019):
In explanatory notes and specs, A4x3 insert sheets integrate into standard A4 documents via `#eskd-page(paper: "a4x3", bottom: frame-form-2a)[...]` for wide tables and diagrams with continuous volume page numbering.

### 5.6. Custom font injection and GOST 2.304-81 typography

The package supports Type A and Type B lettering according to GOST 2.304-81:

| Font Type | Line Thickness d | Scale Factor | Line Spacing b | Letter Spacing a | Word Spacing e |
|---|---|---|---|---|---|
| Type B (`type-b`) | (1/10) h | 1.40 | 1.40 h | 0.20 h | 0.60 h |
| Type A (`type-a`) | (1/14) h | 1.286 | 1.429 h | 0.143 h | 0.429 h |

By default (`font: auto`, `font-group: auto`), the library employs a clean, compact chain of open and system fonts (`OpenGost Type B/A`, `osifont`, `GOST Type B/A`, `PT Astra Sans`, `Arial`), preventing compiler warning storms on systems without specialized CAD software.

Font configuration is split into two orthogonal parameters:
- `font-group`: selection of CAD ecosystem font families (`gost-font-families`):
  - ASCON group (KOMPAS-3D): `font-group: "ascon"` (`Ascon GOST 2.304 Type B`, `GOST 2.304 type B`);
  - T-FLEX CAD group: `font-group: "tflex"` (`T-FLEX GOST Type B`, `T-FLEX GOST Type A`);
  - SolidWorks group: `font-group: "solidworks"` (`SolidWorks GOST`, `SolidWorks GOST A`);
  - AutoCAD group: `font-group: "autocad"` (`ISOCPEUR`, `ISOCTEUR`, `ISOCP`, `ISOCT`);
  - SPDS and Mechanics group: `font-group: "spds"` (`SPDS GOST Type B`, `CSC GOST Type B`, `Mechanics GOST Type B`).
- `font`: specific font family name (`font: "osifont"`, `font: "PT Astra Sans"`) or custom fallback array (`font: ("CustomGost", "Arial")`).

```typst
#show: eskd-document.with(
  font-group: "ascon", // CAD ecosystem font group
  font: "osifont",     // Specific font family at top of fallback chain
  font-type: "type-b",
  font-italic: true,   // Native 75° inclination
)
```

For low-level metric customization, use `font-cfg` to pass exact ratios (`font`, `scale`, `cap-ratio`, `leading-ratio`, `letter-space-ratio`, `word-space-ratio`).

#### Digital glyph metrics and sidebearings

When using digital vector fonts (TrueType, OpenType), character advance width includes both the visible stroke contour and lateral protective paddings (sidebearings). Glyph metrics and sidebearing dimensions are individual to each font. Under GOST 2.004-88 (cl. 1.8, note 3), fonts generated by computer equipment are permitted provided they ensure legibility. Responsibility for character outline geometry, stroke proportions, and native sidebearings rests with the font, while the `eskd-drafting` package manages layout geometry, positioning, and ESKD validation rules.

### 5.7. Technical rationale for rejecting synthetic font slanting

According to GOST 2.304-81 (clauses 1.1, 1.2), lettering may be performed either upright or inclined at approximately 75°.

By default, `eskd-drafting` renders upright lettering (`font-italic: false`), ensuring maximum legibility across multi-page technical texts.

The package rejects programmatic font slanting (`skew` / `shear`) for the following technical reasons:
1. Stroke Distortion: Artificial shearing thins vertical strokes relative to horizontal bars, violating GOST 2.304-81 uniform stroke thickness $d = 1/10\,h$ (Type B) or $d = 1/14\,h$ (Type A).
2. Bounding Box Inaccuracies: Slanted characters protrude beyond their em-boxes, distorting Typst `measure` calls, causing layout miscalculations in `auto-fit-gost` and triggering false positive readability warnings (`gost-text-scale-warning`).

To use inclined lettering, supply an authentic GOST font with native 75° glyphs and set `font-italic: true`:

```typst
#show: eskd-document.with(
  font: ("OpenGost Type B TT", "Arial"),
  font-type: "type-b",
  font-italic: true,
)
```

### 5.8. Text auto-fitting (`auto-fit-gost`) and readability validation

1. Discrete GOST 2.304-81 stepping: font height scales down across standard series h ∈ {40.0, 28.0, 20.0, 14.0, 10.0, 7.0, 5.0, 3.5, 2.5, 1.8} mm.
2. Geometric scaling (`scale`): activated if content overflows at minimum height 1.8 mm.

Readability Thresholds (GOST 2.304-81, GOST 2.004-88):
- Shrinkage below 70%: warning `gost-text-scale-warning`.
- Extreme shrinkage below 40%: error `gost-text-scale-extreme`.

### 5.9. Automatic body content adjustment for first-page title block

First sheets feature 40 mm (Form 2) or 52 mm (Form 2 with `toc` parameter) title blocks, while subsequent sheets use 15 mm (Form 2a). Dynamic layout spacers equalize body content flow seamlessly.

### 5.10. Font harmonization for signature rows (`members`)

`compute-group-font` evaluates surname lengths across signature rows and aligns them to a uniform height to avoid aesthetic jarring.

### 5.11. Revision table handling (`changes`)

Parameter `changes` accepts an array of dictionaries `( (num: [...], ...), ... )`. Cell capacity is governed by GOST 2.104-2006:
- Form 1 (drawings): up to 4 rows (20 mm above header, bottom-to-top order);
- Form 2 (text title sheets): up to 2 rows (10 mm);
- Form 2a & 2b (subsequent sheets): 1 row (5 mm).

`compute-group-font` harmonizes font heights across revision columns. Capacity overflow triggers `gost-2.104-2006-changes-overflow`.

### 5.12. Litera parsing and processing (`lit`)

Under GOST 2.103-2013, literas occupy up to three cells in Cell 4. Supports composite literas (О1, О2), Unicode subscripts (О₁, О₂), and Latin-to-Cyrillic homoglyph normalization.

### 5.13. Parameter semantics: `auto`, `none`, and user content

- `auto` (default): Cascade-resolved from document `state`, computed geometrically (e.g. `format: auto`), or retrieved from Typst `counter(page)` (for `page` and `total`). For Form 1 drawings, `code-inverted: auto` enables the rotated Cell 26 box.
- `none`: Fully suppresses the field (returns empty content `[]` without reserving space or drawing lines).
  - `page: none`: Suppresses sheet numbering. In subsequent forms (2a, 2b), the divider line and «Лист» label are removed.
  - `total: none`: Suppresses total sheet count.
  - `code-inverted: none`: Suppresses the rotated top-left code box.
- Explicit Content (`str` / `int` / `content` / `dict`): Rendered, checked by standard validators, and auto-fitted via `auto-fit-gost`.

---

## 6. Validation rules reference (`ignore-rules`)

| Rule ID | Standard Verification Requirement |
|---|---|
| `gost-2.301-68-paper-format` | Sheet format must belong to GOST 2.301 series (A0..A4 or multiplied `aNxM`). |
| `gost-2.301-68-paper-multiplied-ratio` | Multiplier $M$ must match Table 2 of GOST 2.301-68. |
| `gost-2.301-68-multiplied-landscape-only` | Prohibition of multiplied formats `aNxM` in portrait orientation. |
| `gost-2.301-68-paper-orientation` | Page orientation validity (`portrait` or `landscape`). |
| `gost-2.301-68-a4-landscape` | Prohibition of A4 in landscape orientation (GOST 2.301-68, cl. 2). |
| `gost-2.302-68-scale-series` | Scale must belong to GOST 2.302 series (1:1, 1:2, 1:2.5, 2:1, etc.). |
| `gost-2.302-68-scale-m-prefix` | Prohibition of "М" or "М:" prefix in scale cell. |
| `gost-2.302-68-scale-decimal-comma` | Decimal comma required for scale ratios. |
| `gost-2.304-81-subscript-base-height` | Base font height must be at least 2.5 mm when subscripts/superscripts are present (GOST 2.304-81, cl. 2.6). |
| `gost-2.304-81-font-height` | Font height h must match standard GOST 2.304 series. |
| `gost-text-scale-warning` | Warning when text scale is below 70%. |
| `gost-text-scale-extreme` | Error when text scale is below 40%. |
| `gost-2.103-2013-litera-value` | Verification of valid litera characters (П, Э, Т, И, О, О1, О2, А, Б, У). |
| `gost-2.104-2006-mass-unit` | Prohibition of "кг" unit suffix in mass cell. |
| `gost-2.104-2006-mass-decimal-comma` | Decimal comma required for mass. |
| `gost-2.104-2006-stamp-width` | Title block width and columns must conform to GOST 2.104-2006 (185 mm). |
| `gost-2.104-2006-stamp-height` | Title block height and rows must conform to GOST 2.104-2006. |
| `gost-2.104-2006-members-overflow` | Signature row limit enforcement (Form 1: 6 rows, Form 2: 5 rows). |
| `gost-2.104-2006-changes-overflow` | Revisions table row limit enforcement for active title block. |
| `gost-2.104-2006-toc-unsupported` | Prohibition of passing table of contents (toc) parameter to forms other than Form 2. |
| `gost-2.303-68-line-thickness-s` | Main line thickness s must be in range [0.5, 1.4] mm. |
| `gost-2.303-68-line-thickness-ratio` | Thin line thickness s_thin must be in range [s/3, s/2]. |
| `eskd-drafting-preset-lines` | Valid line preset selection (`"industry"` or `"gost"`). |
| `eskd-drafting-page-numbers` | Page number validity (current <= total, positive integers). |

---

## 7. Custom and enterprise title blocks

The package core strictly follows official ESKD standards. Custom enterprise (STO, TU) and academic forms can be integrated via the `bottom:` or `subsequent-bottom:` parameters without modifying the core:

- Enterprise Standard Stamp: [examples/06-custom-stamps/custom-industry-stamp.typ](examples/06-custom-stamps/custom-industry-stamp.typ)
- Academic Coursework Frame: [examples/06-custom-stamps/student-custom-form.typ](examples/06-custom-stamps/student-custom-form.typ)

---

## 8. Example catalog (`examples/`)

### 8.1. Quick start (`01-quickstart/`)
- [examples/01-quickstart/readme-quickstart.typ](examples/01-quickstart/readme-quickstart.typ) — Quick Start: Minimal working example creating a compliant ESKD document with standard title block fields.
- [examples/01-quickstart/all-page-types.typ](examples/01-quickstart/all-page-types.typ) — ESKD Page Presets Showcase: Comprehensive demonstration of all 6 built-in page layouts (`page-title`, `page-first-form2`, `page-body`, `page-first-form1`, `page-body-double`, `page-blank`).

### 8.2. Drawings and schematics (`02-drawings/`)
- [examples/02-drawings/drawing-a4.typ](examples/02-drawings/drawing-a4.typ) — A4 Portrait Detail Drawing: Form 1 title block (55 mm), 3-row left inventory stamp 3r (cells 19–23), cell 26 (inverted code), cell 3 (material).
- [examples/02-drawings/drawing-a3.typ](examples/02-drawings/drawing-a3.typ) — A3 Landscape Assembly Drawing: Form 1 title block, 5-row left inventory stamp 5r (cells 19–25), cell 26, compound litera "О1".
- [examples/02-drawings/drawing-a2-portrait.typ](examples/02-drawings/drawing-a2-portrait.typ) — A2 Portrait Assembly Drawing: 7r side stamp layout with fixed gap (`gap: 47mm`) for A4 folder binding.
- [examples/02-drawings/drawing-a2-landscape.typ](examples/02-drawings/drawing-a2-landscape.typ) — A2 Landscape Assembly Drawing: Form 1 title block, 7-row left inventory stamp 7r (cells 19–25), cell 26.
- [examples/02-drawings/multiplied-formats-a4x3-drawing.typ](examples/02-drawings/multiplied-formats-a4x3-drawing.typ) — A4x3 Multiplied Drawing & Scheme (630x297 mm): Working frame $605 \times 287\text{ мм}$, Form 1, side stamp 7r, Cell 31 ("Copied") and Cell 32 (`Формат А4х3`).

### 8.3. Text documents (`03-text-documents/`)
- [examples/03-text-documents/explanatory-note.typ](examples/03-text-documents/explanatory-note.typ) — Explanatory Note (Multi-page Text Document): Complete workflow: Title (`page-title`), TOC (`page-first-form2` with `toc`, Form 2 52 mm), Main Section (`page-first-form2`, Form 2 40 mm), Body Pages (`page-body`, Form 2a 15 mm).
- [examples/03-text-documents/double-sided-text.typ](examples/03-text-documents/double-sided-text.typ) — Double-Sided Text Document (Specifications): Alternating odd pages with right-side binding margin (Form 2, Form 2a) and even pages with mirrored left-side margin and Form 2b stamp (`page-body-double`).
- [examples/03-text-documents/text-document-with-a4x3-insert.typ](examples/03-text-documents/text-document-with-a4x3-insert.typ) — Explanatory Note with A4x3 Foldout Insert (GOST 2.105-2019): Continuous volume numbering with A4x3 foldout sheet for wide tables (Form 2a) and process diagrams (Form 1).

### 8.4. Advanced metadata and revisions (`04-advanced-features/`)
- [examples/04-advanced-features/advanced-members.typ](examples/04-advanced-features/advanced-members.typ) — Advanced Signature Rows & Typography (cells 10–13): 4-element tuples with personal signatures, granular font heights (`label-size`, `name-size`), column harmonization (`compute-group-font`), empty separators `()`.
- [examples/04-advanced-features/advanced-changes.typ](examples/04-advanced-features/advanced-changes.typ) — Advanced Multi-Row Revisions Table (cells 14–18): Multi-row revision table (up to 4 rows in Form 1), array of dictionaries format, granular cell font heights (`doc-size`, `sig-size`), column font harmonization, dynamic sheet overrides via `eskd-set`.
- [examples/04-advanced-features/table-of-changes.typ](examples/04-advanced-features/table-of-changes.typ) — Table of Changes (cells 14–18): `changes` array, multi-row rendering on drawings (Form 1) and dynamic sheet updates for Form 2a.
- [examples/04-advanced-features/dynamic-override.typ](examples/04-advanced-features/dynamic-override.typ) — Dynamic Metadata & Page Number Overrides: On-the-fly metadata updates via `#eskd-set`, explicit page numbering overrides (`page`, `total`).
- [examples/04-advanced-features/copier-and-format-labels.typ](examples/04-advanced-features/copier-and-format-labels.typ) — Outer Frame Cells 31 and 32: Cell 31 ("Копировал", 120 mm) and Cell 32 ("Формат", 65 mm) with automatic paper size detection (`format: auto`).

### 8.5. Fonts and line styles (`05-typography/`)
- [examples/05-typography/custom-fonts-and-types.typ](examples/05-typography/custom-fonts-and-types.typ) — Custom Fonts & GOST Type A Typography: Font injection via `font` parameter, GOST 2.304-81 Type A styling (`font-type: "type-a"`), thin-line preset `"gost"`.
- [examples/05-typography/text-scale-and-autofit.typ](examples/05-typography/text-scale-and-autofit.typ) — Font Auto-Fitting & Readability Validation: Discrete standard heights $h \in \{5.0, 3.5, 2.5, 1.8\}\text{ мм}$, readability warnings (`gost-text-scale-warning` < 70%) and error guard (`gost-text-scale-extreme` < 40%).
- [examples/05-typography/preset-lines.typ](examples/05-typography/preset-lines.typ) — Line Style Presets Comparison (`industry` vs `gost`): CAD-style 0.8 mm thick dividers compared to 0.35 mm thin lines.

### 8.6. Custom title blocks (`06-custom-stamps/`)
- [examples/06-custom-stamps/custom-industry-stamp.typ](examples/06-custom-stamps/custom-industry-stamp.typ) — Custom Enterprise Title Block: Enterprise-specific title block integration via `bottom` parameter while preserving normative outer frame and margins.
- [examples/06-custom-stamps/student-custom-form.typ](examples/06-custom-stamps/student-custom-form.typ) — Academic Coursework Frame: Custom subsequent sheet title block integration via modular `subsequent-bottom` parameter.

---

## 9. Testing and performance

### 9.1. Test suite execution

```bash
# Install test dependencies
pip install -r ./tests/requirements-dev.txt

# Run unit test suite
python ./tests/tests.py

# Run performance benchmark suite
python ./tests/benchmarks.py
```

### 9.2. Architecture and export profiles

- Linear Scalability O(N): Compilation time grows proportionally to page count.
- Export Standards: Validated across `PDF 1.7`, `PDF 2.0`, `PDF/A` (`1b`, `2b`, `3b`), `PDF/UA-1`, `SVG`, `PNG`, and `HTML`.

---

## 10. License

This package uses dual-licensing:
- The core package and library source code are distributed under the [MIT License](LICENSE).
- The boilerplate and starter code provided in the `template/` and `examples/` directories are distributed under the [MIT No Attribution License (MIT-0)](https://spdx.org/licenses/MIT-0.html). This ensures that you can freely use, modify, and distribute documents created from these templates without any obligation to include the original copyright notice.
