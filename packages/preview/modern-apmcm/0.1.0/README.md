# modern-apmcm

An unofficial [Typst](https://typst.app/) template for the **Asia and Pacific Mathematical Contest in Modeling (APMCM)**, converted from the official `apmcmthesis.cls`, `apmcmthesis.cfg`, and `ControlSheet.tex`.

## Features

- **Official Page & Typography Layout**: A4 paper (`26.4mm` top/bottom, `31.8mm` left/right), `12pt` font (`Times New Roman` with automatic fallback to `Libertinus Serif`), `2em` first-line indentation, and running header (`Team # ...` and `Page X of Y` starting from the main body).
- **Frontmatter Structure**:
  - Page 1: APMCM Summary Sheet with team number, problem chosen, optional title, summary, and keywords.
  - Page 2: `Contents` table of contents matching the official LaTeX hierarchy (`1.`, `1.1`, and `1.1.1` with italic titles).
  - Page 3+: Main body with page counter reset to `1`, Roman section headings (`I.`), numeric subsections (`1.1`), and italic sub-subsections (`1.1.1`).
- **Academic Helpers**:
  - Three-line tables (`three-line-table`)
  - Styled code listings (`code-block`)
  - Theorem-like environments (`definition`, `theorem`, `lemma`, `corollary`, `assumption`, `conjecture`, `axiom`, `principle`, `problem-env`, `proof`)
- **Control Sheet (`apmcm-control-sheet`)**: Built-in commitment/control sheet template matching `ControlSheet.tex`.

## Quick Start

### Via Typst Universe (after release)

```bash
typst init @preview/modern-apmcm:0.1.0 my-apmcm-paper
cd my-apmcm-paper
typst compile main.typ Aapmcm263XXXXX.pdf
typst compile control_sheet.typ Aapmcm263XXXXXcns.pdf
```

### Local Development / Before Universe Release

If you cloned this repository locally and want to test or use `@preview/modern-apmcm:0.1.0` directly via `--package-path` or your local Typst package directory (`%LOCALAPPDATA%\typst\packages\preview\modern-apmcm\0.1.0` on Windows, `~/.local/share/typst/packages/preview/modern-apmcm/0.1.0` on Linux):

1. Place or link this repository at `<package-path>/preview/modern-apmcm/0.1.0`.
2. Compile with:

```bash
typst compile template/main.typ Aapmcm263XXXXX.pdf
typst compile template/control_sheet.typ Aapmcm263XXXXXcns.pdf
```

## Configuration

### `apmcm-paper` Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `team-number` | `"apmcm263XXXXX"` | Team registration/control number shown on Summary Sheet and header |
| `problem` | `"A"` | Problem chosen (`"A"`, `"B"`, `"C"`, or `"D"`) |
| `year` | `auto` | Contest year (defaults to current year via `datetime.today()`) |
| `title` | `none` | Optional paper title displayed on the Summary Sheet |
| `keywords` | `()` | Array of keyword strings/content |
| `summary` | `[]` | Summary Sheet body content |
| `header-prefix` | `"Team # "` | Header prefix before `team-number` (e.g., set `"Team "` if needed) |
| `font-family` | `("Times New Roman", "Libertinus Serif")` | Body font fallback chain |
| `mono-font` | `("DejaVu Sans Mono",)` | Monospace font fallback chain |

### `apmcm-control-sheet` Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `problem` | `"A"` | Problem chosen (`"A"`, `"B"`, `"C"`, or `"D"`) |
| `team-number` | `"263XXXXX"` | Team control number |
| `school` | `"XXX University"` | Full English school name |
| `members` | `("First Member", "Second Member", "Third Member")` | Up to 3 team member names |
| `supervisor` | `"Supervisor"` | Team adviser name |
| `date` | `"November 28, 2026"` | Submission date |
| `year` | `auto` | Contest year |

## APMCM Submission Checklist

1. **File Naming** (example: Problem `A`, team `apmcm263XXXXX`):
   - Solution paper: `Aapmcm263XXXXX.pdf`
   - Signed control sheet: `Aapmcm263XXXXXcns.pdf` (or `.jpg`)
   - Supporting materials (excluding original contest datasets): `Aapmcm263XXXXXfj.zip` (or `.rar`)
2. **Structure & Page Limit**: Page 1 Summary Sheet, Page 2 Contents, Page 3+ Main Body (keep main body within 25 pages excluding appendices).
3. **Anonymity & Language**: Header must contain only team number and page numbers (no names or university); the entire paper, figures, and tables must be in English.

## License

- The package module (`lib.typ`) and documentation are licensed under the **MIT License** (see [LICENSE](LICENSE)).
- The starter files in `template/` (`template/main.typ` and `template/control_sheet.typ`) are licensed under **MIT-0** (MIT No Attribution), so you may freely use, modify, and distribute your contest papers created from the template without attribution or license notice requirements.
