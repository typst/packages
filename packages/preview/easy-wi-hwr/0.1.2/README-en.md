# HWR Berlin — Typst Template

**Deutsche Version:** → [README.md](README.md)

A community-built Typst template for scientific papers at HWR Berlin (Berlin School of Economics and Law), primarily targeting students in the *Wirtschaftsinformatik* (Business Informatics) programme. It automates cover pages, tables of contents, abbreviation lists, the statutory declaration, and more — all conforming to the HWR formatting guidelines as of January 2025, for all cohorts.

You focus on the content. The template handles the rest:
- Cover page with all required fields
- Table of contents, list of abbreviations, list of figures/tables
- Page numbering (Roman → Arabic, automatic switch)
- Statutory declaration with 2025 AI clause
- AI tools register (when AI tools were used)

> **Quickstart:** `brew install typst && typst init @preview/easy-wi-hwr:0.1.2 my-paper && cd my-paper && typst watch main.typ`

> **While writing:** [Helper Functions](#helper-functions-usable-in-text)

> **Something not working?** → [Common Issues](#common-issues)

*I generally recommend reading the [Reference](#reference) section.*

### Contents

**Getting Started**
- [What is Typst?](#what-is-typst)
- [Step 1: Install Typst](#step-1-install-typst)
- [Step 2: Install the font](#step-2-install-the-font)
- [Step 3: Set up a project](#step-3-set-up-a-project--two-options)
- [Step 4: Writing](#step-4-writing)
- [Step 5: Create the PDF](#step-5-create-the-pdf)

**Content & Required Fields**
- [References](#references)
- [AI Tools (required if AI was used)](#ai-tools-required-if-ai-was-used)
- [Abbreviations & Glossary](#abbreviations--glossary)
- [Source Attribution for Figures](#source-attribution-for-figures)
- [Extended Direct Quotes](#extended-direct-quotes)

**Optional Features**
- [English Papers](#english-papers)
- [Group Work](#group-work)
- [Confidentiality Notice](#confidentiality-notice)
- [Draft Mode](#draft-mode)
- [Digital Signature](#digital-signature)
- [Mermaid Diagrams](#mermaid-diagrams)
- [Pretty Mode](#pretty-mode)

**Reference**
- [Helper Functions](#helper-functions-usable-in-text)
- [Good to Know](#good-to-know)
- [All Parameters](#all-parameters-at-a-glance)
- [Common Issues](#common-issues)
- [Local Development](#local-development-for-template-developers)

---

# Getting Started

## What is Typst?

Typst is a writing tool — similar to Word, but you write in plain text files (`.typ`) instead of a graphical editor. You type e.g. `= Introduction` and it automatically becomes a formatted heading. The template then handles all formatting automatically. You compile the finished files to PDF with a single click or command.

**Advantage:** No manual formatting work, no fighting with page breaks, no style conflicts — and the PDF renders in milliseconds.

**Typst reference and documentation** → [typst.app/docs](https://typst.app/docs)

---

## Step 1: Install Typst

The template requires **Typst 0.13.1 or newer**.

### macOS

1. Open Terminal (Applications → Utilities → Terminal)
2. Type:
   ```
   brew install typst
   ```
   If `brew` is not installed: [https://brew.sh](https://brew.sh) — copy the install command from there, run it, then run `brew install typst` again.

### Windows

1. Open PowerShell (Start menu → search for "PowerShell")
2. Type:
   ```
   winget install --id Typst.Typst
   ```
   Alternatively: download the Windows installer at [typst.app/download](https://typst.app/download).

### Linux

```bash
# Ubuntu/Debian:
sudo snap install typst

# Arch:
sudo pacman -S typst

# Or via cargo:
cargo install typst-cli
```

### Verify the installation

After installing, run in the terminal:
```
typst --version
```
→ A version number should appear (e.g. `typst 0.14.2`). An `(unknown hash)` suffix can be ignored.

---

## Step 2: Install the font

The template uses **Times New Roman** (required by HWR).

- **Windows/macOS:** Already pre-installed — no action needed.
- **Linux:** In the terminal:
  ```bash
  sudo apt install ttf-mscorefonts-installer   # Ubuntu/Debian
  # or:
  sudo apt install fonts-liberation
  ```

---

## Step 3: Set up a project — two options

### Option A — Typst Universe (one command)

Run the following command in the terminal (in the directory where you want your project folder):
```bash
typst init @preview/easy-wi-hwr:0.1.2 my-paper
```
→ `my-paper` is the folder name and can be changed.

This instantly creates a ready-to-use project folder with a pre-filled `main.typ`.

### Option B — Interactive setup script (optional, for beginners)

The script asks you all the questions and creates a fully pre-filled `main.typ` with your data.

**Run directly (macOS/Linux):**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lultoni/easy-wi-hwr/main/scripts/init.sh)
```

**Or locally after download:**
```bash
git clone https://github.com/lultoni/easy-wi-hwr.git
bash easy-wi-hwr/scripts/init.sh
```

The script asks you step by step:
- Where should the project be created?
- Project folder name
- Type of paper (PTB, Hausarbeit, Bachelorarbeit, …)
- Your name and student ID
- Title, supervisor, company, field of study, cohort
- Language of the paper (German / English)
- Desired number of chapters

At the end you have a ready-to-use project folder with a pre-filled `main.typ`.

> **Note:** Briefly review the script before running it: [scripts/init.sh](https://github.com/lultoni/easy-wi-hwr/blob/main/scripts/init.sh)

---

## Step 4: Writing

Open the project folder in a text editor. Recommended: **VS Code** (free, [code.visualstudio.com](https://code.visualstudio.com)) with the **Tinymist** extension for syntax highlighting, but any text editor works.

```
my-paper/
├── main.typ            ← your metadata (title, name, …) — this is where you configure
├── refs.bib            ← your references
├── kapitel/
│   ├── 01_einleitung.typ   ← write here
│   ├── 02_theoretische_grundlagen.typ
│   └── ...
└── anhang/
    └── beispiel.typ        ← appendix template
```

**Writing in chapter files:**
```typst
= Introduction

Here begins the text of the first chapter.

== Background

*Bold* and _italic_ work like this.

Footnote#footnote[Footnote text goes here.] inline in the text.

Citation: According to @mustermann2024...

Abbreviation on first use: #abk("AI")
```

**Alternative: Everything in one file** — You can also work without separate chapter files. Leave `chapters:` empty and write all your text directly in `main.typ` after the settings block. Insert `#pagebreak()` between chapters so each starts on a new page (with `chapters:` this happens automatically):

```typst
#show: hwr.with(
  doc-type: "ptb-1",
  title: "My Title",
  // ... remaining settings ...
)

= Introduction

My text starts directly in main.typ.

#pagebreak()
= Background

Second chapter...
```

For shorter papers (e.g. Hausarbeiten) this is often simpler. For longer work, separate files in `kapitel/` are recommended.

---

## Step 5: Create the PDF

```bash
# In your project folder (e.g. cd my-paper):

# Compile once:
typst compile main.typ

# With live compilation (updates on every save):
typst watch main.typ
# Stop: Ctrl+C
```

The finished PDF is placed right next to `main.typ`.

### VS Code + Tinymist

Tinymist provides syntax highlighting and autocomplete for `.typ` files. You can also compile directly from VS Code — Tinymist shows a live preview in the editor window.

---

# Content & Required Fields

## References

References go in the `refs.bib` file. Format examples (Citavi, Zotero, or Google Scholar can export these files automatically):

```bibtex
@book{mustermann2024,
  author    = {Mustermann, Max},
  title     = {Book Title},
  year      = {2024},
  publisher = {Publisher},
}

@online{source2024,
  author  = {Author, Firstname},
  title   = {Website Title},
  year    = {2024},
  url     = {https://example.com},
  urldate = {2024-01-01},
}
```

Cite in the text with `@key`, e.g. `@mustermann2024`.

---

## AI Tools (required if AI was used)

If you used AI tools such as ChatGPT, Copilot, or DeepL, you must declare this per HWR §3.8.
In `main.typ`:

```typst
ai-tools: (
  (
    tool:     "ChatGPT 4o",
    usage:    "Text suggestions, marked in the text",
    chapters: "Chapter 1, p. 3",
    remarks:     "Prompts: ",
    remarks-ref: "Prompt Log",         // → hyperlink to the appendix with this title
  ),
  (
    tool:     "DeepL Translator",
    usage:    "Translation of English source passages",
    chapters: "Entire paper",
  ),
),
```

The AI tools register is automatically inserted as the last appendix item. With `ai-tools: ()` no register appears.

---

## Abbreviations & Glossary

**Abbreviations** work fully automatically:
- First use: `#abk("AI")` → outputs "Artificial Intelligence (AI)"
- All subsequent uses: `#abk("AI")` → outputs "AI"
- The list of abbreviations is created automatically

You define abbreviations once in `main.typ`:
```typst
abbreviations: (
  "AI":  "Artificial Intelligence",
  "HWR": "Berlin School of Economics and Law",
  "ERP": "Enterprise Resource Planning",
),
```

**Alternative: Define inline in the text** — you can omit the `abbreviations:` block entirely and define abbreviations at first use:

```typst
The #abk("AI", long: "Artificial Intelligence") plays an important role.
// → First use: "Artificial Intelligence (AI)"
// → Further uses: #abk("AI") → "AI"
// → List entry is created automatically
```

Both approaches can be combined.

**Glossary** — for technical terms *without* their own abbreviation (e.g. "Stakeholder", "Scrum"):
```typst
glossary: (
  (key: "stakeholder", short: "Stakeholder", long: "Stakeholder",
   description: "Interest groups that are directly or indirectly affected by a project."),
),
```

In the text: `#gls("stakeholder")` → outputs "Stakeholder" and links to the glossary. Plural form: `#glspl("stakeholder")`.

> **Note:** `#gls()` expands on first use to "long (short)". For terms where `short` and `long` are identical (like "Stakeholder"), the glossary entry mainly serves as a reference index — the expansion is redundant. The abbreviation function `#abk()` is better suited for terms with an actual short/long form difference (e.g. "AI" / "Artificial Intelligence").

**Rule:** Never put the same term in both lists — abbreviations go in the abbreviation list, technical terms without abbreviation go in the glossary.

---

## Source Attribution for Figures

HWR requires a source attribution beneath every figure and table. The template provides the `#quelle()` function for this:

```typst
// Own illustration (default):
#figure(
  image("images/diagram.png"),
  caption: [Process overview. #quelle()],
)
// → "Source: Own illustration"

// External source — with clickable citation link (recommended):
#figure(
  image("images/chart.png"),
  caption: [Market shares 2024. #quelle(<mustermann2024>)],
)
// → "Source: Mustermann (2024)" (clickable link to the bibliography)

// With page reference (also clickable):
#figure(
  table(...),
  caption: [Comparison. #quelle(<mueller2023>, "p. 42")],
)
// → "Source: Müller (2023), p. 42"

// Without bib key — plain text (when source is not in the bibliography):
#figure(
  image("images/chart.png"),
  caption: [Market shares 2024. #quelle("Mustermann", 2024)],
)
// → "Source: Mustermann (2024)" (plain text, no link)

// Alternative keyword syntax (equivalent):
// caption: [... #quelle(author: "Mustermann", year: 2024, s: "p. 15")]
```

> **Tip:** Use `#quelle(<bib-key>)` whenever the source is in the bibliography — the attribution becomes a clickable link that jumps directly to the entry.

> **Table footnotes (FMT-47):** HWR requires letters (a, b, c…) instead of numbers for footnotes *inside* tables. Typst supports this natively — use `#footnote(numbering: "a")` within table cells:
> ```typst
> table.cell[Value#footnote(numbering: "a")[Note a]], ...
> ```

---

## Extended Direct Quotes

Longer quotes (approx. 40+ words) must be indented and single-spaced per HWR §3.4.2. Use `#blockquote[]` for this:

```typst
#blockquote[
  "Digital transformation changes not only business processes but also
  corporate culture fundamentally. Companies that do not actively shape this
  change risk their long-term competitiveness." @mustermann2024[p. 42]
]
```

The text is automatically left-indented and single-spaced — no manual formatting needed.

> **Note:** The `[p. 42]` syntax after `@key` passes the page locator to the citation engine. The exact rendering (e.g. "p." vs. "S.") depends on the chosen CSL style.

---

# Optional Features

## English Papers

```typst
lang: "en",
```

All index headings, the statutory declaration, and the AI tools register switch to English automatically. The citation style automatically switches to Harvard (Anglia Ruskin University) — the CSL file is included in the template (HWR §6).

> **Tip:** Set `declaration-lang: "de"` to keep the statutory declaration in German — this is the legally safe choice. Whether an English declaration is accepted has not been definitively established.

---

## Group Work

Simply add more authors:

```typst
authors: (
  (name: "Max Mustermann", matrikel: "12345678"),
  (name: "Lisa Müller",    matrikel: "87654321"),
),
```

The statutory declaration automatically switches to "We declare…" and both authors receive a signature field.

**Only one representative signature** (e.g. for digital submission on behalf of the group — please clarify with your examiner):

```typst
group-signature: false,  // only the first author signs
```

The template then shows a yellow notice in the PDF reminding you to clarify this with your examiner. Suppress it with `warnings: false` after confirmation.

---

## Confidentiality Notice

If parts of the paper are confidential (§3.2.1):

```typst
// Entire paper confidential:
confidential: true,

// Only specific chapters:
confidential: (
  chapters: (
    (number: "3", title: "Methodology"),
    (number: "4", title: "Results"),
  ),
  filename: "PTB_Mustermann_public.pdf",  // optional
),
```

The required text is inserted automatically and appears before the cover page.

---

## Draft Mode

While working, you can enable a watermark so drafts are not accidentally submitted as the final version:

```typst
draft: true,
```

Every page shows a grey "DRAFT" watermark (with `lang: "de"` → "ENTWURF"). Before submission, simply set `draft: false` or remove the line.

---

## Digital Signature

Instead of an empty line for a handwritten signature, you can embed an image of your signature:

1. Sign on white paper, scan or photograph it
2. Save as PNG or SVG under `images/` in your project folder
3. Add to the author entry in `main.typ`:

```typst
authors: (
  (name: "Max Mustermann", matrikel: "12345678", signature: image("images/signature_max.png")),
),
```

The image then appears automatically in the signature field of the statutory declaration.

---

## Mermaid Diagrams

You can embed Mermaid diagrams directly in Typst — no external tools needed. The `mmdr` package renders Mermaid syntax natively in your document:

```typst
#import "@preview/mmdr:0.2.1": mermaid

#figure(
  mermaid("graph TD
    A[Literature Review] --> B[Hypothesis]
    B --> C{Quantitative?}
    C -->|Yes| D[Survey]
    C -->|No| E[Interview]
  "),
  caption: [Research process.],
)
```

23 diagram types are supported: flowcharts, sequence diagrams, class diagrams, ER diagrams, Gantt charts, mindmaps, pie charts, and more.

> **Note:** `mmdr` uses a Rust implementation of Mermaid — visual output may differ slightly from mermaid.js in edge cases. If you need pixel-perfect mermaid.js compatibility, render diagrams externally as SVG and include them via `image()`.

Details: [typst.app/universe/package/mmdr](https://typst.app/universe/package/mmdr)

---

## Pretty Mode

You can activate a decorative cover page and logo header:

```typst
style: "pretty",
school-logo: image("images/school-logo.svg", height: 1.2cm),
company-logo: image("images/company-logo.svg", height: 1.2cm),
```

**Important:** Pretty Mode is **not specified in the HWR guidelines**. Please confirm with your supervisor before using it. The template shows a yellow notice in the PDF — suppress it with `warnings: false` after confirmation.

You can also activate individual features independently:
- `pretty-title: true` — decorative cover page only (ornamental lines, larger title)
- `school-logo:` / `company-logo:` — logo header on body pages only

Default is `style: "compliant"` (guideline-conformant).

---

# Reference

## Helper Functions (usable in text)

These functions can be used in your chapter files:

| Function | Description |
|---|---|
| `#abk("AI")` | Abbreviation — expanded on first use, short form afterwards |
| `#gls("key")` | Glossary entry — expanded on first use, short form afterwards |
| `#glspl("key")` | Glossary entry in plural form |
| `#quelle()` | Source attribution "Own illustration" for figures/tables |
| `#quelle(<bib-key>)` | Source attribution with clickable citation link (recommended) |
| `#quelle(<bib-key>, "p. 42")` | Same, with page reference |
| `#quelle("Name", 2024)` | Source attribution as plain text (no bib link) |
| `#blockquote[...]` | Indented, single-spaced block quote (HWR §3.4.2) |

All functions are automatically available after the import in `main.typ`. In chapter files, you need to import the functions you use:
```typst
#import "@preview/easy-wi-hwr:0.1.2": abk, gls, glspl, quelle, blockquote
```

---

## Good to Know

**Citation style:** Default is `"auto"` — the template automatically selects APA for German-language papers and Harvard (Anglia Ruskin University) for English papers. The Harvard CSL file is included. If your supervisor requires a different style, you can download a `.csl` file from the [Zotero Style Repository](https://www.zotero.org/styles) and include it via `read()`:
```typst
citation-style: read("my-style.csl"),
```
`read()` is resolved in `main.typ` — the path is relative to `main.typ`.

**The list of abbreviations appears automatically**, but only if:
- Abbreviations are entered in `abbreviations:`, AND
- `#abk("XY")` is used at least once in the text

Unused abbreviations do not appear in the list.

**List of figures and list of tables** appear only from 5 entries onwards (HWR requirement). The template checks this automatically.

**Submission as Word + PDF:** HWR requires both formats for Bachelorarbeiten. The template only generates PDF. For the Word version, several options exist:
- **PDF → Word:** Adobe Acrobat (best results), or free online tools (e.g. SmallPDF, iLovePDF) — formatting may differ
- **Pandoc:** `pandoc main.typ -o paper.docx` — experimental, may lose some formatting
- **Copy-paste:** Open the PDF in Word (Word can import PDFs) — often the most pragmatic solution for simple documents

The Word version typically serves archival purposes only — in practice, perfect formatting is not required.

---

## All Parameters at a Glance

### Required Fields

| Parameter | Description |
|---|---|
| `doc-type` | Type of paper: `"ptb-1"`, `"ptb-2"`, `"ptb-3"`, `"hausarbeit"`, `"studienarbeit"`, `"bachelorarbeit"` |
| `title` | Paper title |

**Authors** — use *one* of the two variants:

| Variant | Parameter | Description |
|---|---|---|
| **Single author** | `name` + `matrikel` | Shorthand: `name: "Max Mustermann"`, `matrikel: "12345678"` |
| **Group work** | `authors` | Array: `authors: ((name: "...", matrikel: "..."), (name: "...", matrikel: "..."))` |

### Required Depending on Document Type

| Parameter | Required for | Description |
|---|---|---|
| `supervisor` | All except Bachelorarbeit | Supervising examiner with title |
| `company` | All except Bachelorarbeit | Name of training company |
| `first-examiner` | Bachelorarbeit | First examiner with title |
| `second-examiner` | Bachelorarbeit | Second examiner with title |

### Optional Fields

| Parameter | Default | Description |
|---|---|---|
| `lang` | `"de"` | Document language — `"de"` or `"en"` |
| `field-of-study` | `"Wirtschaftsinformatik"` | Field of study |
| `cohort` | — | Study cohort, e.g. `"2024"` |
| `semester` | — | Study semester, e.g. `"3"` |
| `date` | `auto` | Submission date; `auto` = today's date, or manual: `"15 March 2026"` |
| `abstract` | `none` | Abstract before the table of contents |
| `confidential` | `none` | Confidentiality notice — `none`, `true`, or `(chapters: (...), filename: ...)` |
| `abbreviations` | `(:)` | Abbreviations as a dictionary |
| `glossary` | `()` | Glossary entries for technical terms (without their own abbreviation) |
| `ai-tools` | `()` | AI tools register entries — `(tool, usage, chapters, remarks?)` |
| `chapters` | `()` | Chapter files via `include()` in desired order |
| `appendix` | `()` | Appendix entries: `(title: "...", content: include(...))` |
| `show-appendix-toc` | `false` | `true` = optional appendix table of contents before the appendix entries (HWR §3.10) |
| `bibliography` | — | `bibliography("refs.bib")` — title is set automatically |
| `citation-style` | `"auto"` | Citation style: `"auto"` (DE → APA, EN → Harvard), `"apa"`, `"harvard-anglia-ruskin-university"`, or `read("file.csl")` |
| `heading-depth` | `4` | TOC depth 1–4 (max. 4 per HWR) |
| `declaration-lang` | `auto` | Language of the statutory declaration — `auto` follows `lang`, `"de"` always German (recommended — legally safe) |
| `city` | `"Berlin"` | City in the signature field of the statutory declaration |
| `group-signature` | `auto` | `auto`/`true` = all authors sign; `false` = only first author |
| `draft` | `false` | `true` = watermark "ENTWURF"/"DRAFT" on every page |
| `warnings` | `true` | `false` = suppress yellow warning boxes in PDF (e.g. pretty-mode notice, after confirming with examiner) |
| `style` | `"compliant"` | `"compliant"` (guideline-conformant) or `"pretty"` (decorative, confirm with supervisor) |
| `school-logo` | `none` | Logo on the left of the page header, e.g. `image("images/logo.png", height: 1.2cm)` |
| `company-logo` | `none` | Logo on the right of the page header |
| `pretty-title` | `none` | `true` = decorative cover page; overrides `style:` for the cover page |

### Fields in the `authors` Array

| Field | Required | Description |
|---|---|---|
| `name` | Yes | Full name |
| `matrikel` | Yes | Student ID number |
| `signature` | No | Signature image as content, e.g. `image("images/signature.png")` |

---

## Common Issues

| Problem | Solution |
|---|---|
| `doc-type "..." is invalid` | Value must be exactly `"ptb-1"`, `"ptb-2"`, `"ptb-3"`, `"hausarbeit"`, `"studienarbeit"`, or `"bachelorarbeit"` |
| `supervisor is required for...` | For all types except `"bachelorarbeit"`, `supervisor:` and `company:` must be set |
| `confidential requires company:` | Confidentiality notice needs the company name — set `company:` or remove `confidential:` |
| `authors must be an array of dicts` | `authors:` must be an array: `authors: ((name: "...", matrikel: "..."),)` — don't forget the comma after the closing parenthesis for a single author! |
| `chapters entries must use include()` | Do not use string paths. Correct: `chapters: (include("kapitel/01.typ"),)` instead of `chapters: ("kapitel/01.typ",)` |
| Times New Roman missing (Linux) | `sudo apt install ttf-mscorefonts-installer` |
| Abbreviation not appearing in list | `#abk("XY")` must be used in the text — only used abbreviations appear |
| AI tools register missing | `ai-tools:` needs at least one entry; with `ai-tools: ()` no register appears |
| List of figures missing | Appears only from 5 figures onwards (HWR requirement) |
| Chapter not appearing in PDF | Check that the file is listed in the `chapters:` list in `main.typ` |
| Import error with `include()` | Paths in `chapters:` are relative to `main.typ` — `include("kapitel/01_einleitung.typ")` |
| `signature muss image-Content sein` | Use `signature: image("images/sig.png")` instead of `signature: "images/sig.png"` |
| All pages doubled / strange formatting | Only one `#show: hwr.with(...)` block per file — no second `#show:` and no text before it |
| `#abk()` / `#gls()` not working in chapter file | Each chapter file needs `#import "@preview/easy-wi-hwr:0.1.2": abk` (or whichever functions you use) |
| Citation style file not found | `citation-style: read("my-style.csl")` — path is relative to `main.typ`. File must be in the same folder |
| Appendix numbering shows A, B, C instead of 1, 2, 3 | Use the built-in appendix function via the `appendix:` parameter — do not number manually |
| PDF shows no page numbers | Check that there is only one `#show: hwr.with(...)` and no `set page(numbering: none)` in your text |

---

## Local Development (for template developers)

If you're working on the template itself (not as a user), you need to switch the imports:

**Step 1: Switch imports to local**

In `template/main.typ`:
```typst
// Comment out this line:
// #import "@preview/easy-wi-hwr:0.1.2": hwr, abk, gls, glspl, quelle, blockquote
// Activate this line:
#import "../lib.typ": hwr, abk, gls, glspl, quelle, blockquote
```

In `template/kapitel/01_einleitung.typ` (and all other chapter files that use `abk`):
```typst
// #import "@preview/easy-wi-hwr:0.1.2": abk
#import "../../lib.typ": abk
```

**Step 2: Compile**

```bash
# Clone the repository:
git clone https://github.com/lultoni/easy-wi-hwr.git
cd easy-wi-hwr

# Compile the template (--root . is required so Typst can resolve ../lib.typ):
typst compile --root . template/main.typ

# Live preview:
typst watch --root . template/main.typ
```

**Before committing / publishing:** Switch imports back to `@preview/` so that users don't get errors.

---

## License

MIT — see LICENSE
