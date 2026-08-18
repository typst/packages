# gbt9704-gongwen

> GB/T 9704-2012 Official Document Format — Typst Template

Version: 0.2.0

A Typst template implementing **GB/T 9704-2012**, the Chinese national standard for official government document layout.

---

## Features

- **Strict GB compliance**: page margins, font sizes, line spacing, heading fonts, indentation, justified alignment.
- **Document element functions**: red-header, main receiver, attachments, signatures, dates, end-matter (版记).
- **Red and black separator lines** for red-header and end-matter respectively.
- **Configurable spacing themes**: `compact` | `normal` | `relaxed` — three line-spacing presets.
- **Configurable table themes**: `full-grid` (default) | `three-line` | `plain` — three table border styles.
- **Faux bold table headers**: CJK-friendly text-stroke technique for fonts without native bold variants.
- **CJK font fallback chain** with open-source alternatives (FZDaBiaoSong → SimHei, FangSong → SimSun, etc.).

---

## Quick Start

### typst init

```bash
typst init @preview/gbt9704-gongwen
```

### Manual import

```typst
#import "@preview/gbt9704-gongwen:0.2.0": *
#show: gbt9704.with(redline: true, title-indent: true)

// Your document content here ...
```

### Options

| Parameter | Type | Default | Description |
|---|---|---|---|
| `redline` | bool | `false` | Red separator line below red-header |
| `title-indent` | bool | `true` | Indent section headings 2 characters |
| `spacing-theme` | str | `"normal"` | Line spacing preset: `"compact"` / `"normal"` / `"relaxed"` |
| `table-theme` | str | `"full-grid"` | Table border style: `"full-grid"` / `"three-line"` / `"single-line"` / `"plain"` |
| `table-align` | str | `"center"` | Table horizontal alignment: `"center"` / `"left"` / `"right"` |
| `show-red-header` | bool | `true` | Show the red-header block / 红头显隐 |
| `first-page-number` | bool | `true` | Show page number on the first page / 首页是否显示页码 |
| `page-number-pos` | str | `"both"` | Page number position: `"both"` / `"center"` / `"left"` / `"right"` / 页码位置 |

### Spacing Themes

| Theme | `leading` | `spacing` | `heading-v` | Feel |
|---|---|---|---|---|
| `compact` | 0.75em | 0.5em | 0.5em | Tight GB/T grid |
| `normal` | 0.75em | 0.5em | 1em | Balanced (default) |
| `relaxed` | 0.7em | 0.5em | 2% | Airy, relaxed |

All three themes share the same paragraph spacing (0.5em), so "paragraph gap = line gap + 8pt" holds consistently.

### Table Themes

| Theme | Effect |
|---|---|
| `full-grid` | All cell borders (default) |
| `three-line` | Top thick + header-bottom thin + bottom thick, no verticals |
| `single-line` | Header-bottom 1pt line only, zebra stripes |
| `plain` | No borders, centered only |

---

### Changelog

### v0.2.0

- Add `show-red-header` parameter — toggle entire red-header block
- Add `first-page-number` parameter — suppress page number on first page
- Add `page-number-pos` parameter — `"both"` / `"center"` / `"left"` / `"right"`
- Add `endmatter()` function — bottom-aligned CC + issuing info block with separator lines
- Page number format: `- 1 -` style
- Red line at bottom of first page (when `redline: true`)
- Signature: 3 blank lines before signature block, signatory right-aligned
- Bilingual README (EN + ZH)

### v0.1.1

- Add `spacing-theme` parameter: `"compact"` / `"normal"` / `"relaxed"`
- Add `table-theme` parameter: `"full-grid"` / `"three-line"` / `"single-line"` / `"plain"`
- Add `table-align` parameter: `"center"` / `"left"` / `"right"`
- Faux bold table headers via text stroke (CJK-friendly)
- Table centering with paragraph indent neutralization
- All spacing values use `em` units (font-size-relative)
- Refactored `src/` layout: `spacing.typ` + `table.typ` + `lib.typ`

### v0.1.0
## Core Functions

| Function | Description |
|---|---|
| `gongwentitle(title)` | Document title — 22pt red title font, centered |
| `gongwensubtitle(subtitle)` | Subtitle — 16pt FangSong, centered |
| `make-header(organ, number, signatory, redline)` | Red-header: organ name, document number, signatory |
| `main-receiver(receiver)` | Main receiver — flush left, no indent |
| `attachment(title)` | Single attachment with "附件：" prefix, 2-char indent |
| `attachment-no-hz(title)` | Attachment without prefix, 5-char block indent |
| `attachment-item(title, indent)` | Attachment item with custom indent |
| `signature(name)` | Signature — right-aligned, 2-char right margin |
| `signdate(date)` | Date — same format as signature |
| `notes(text)` | Notes in parentheses, no indent |
| `copyto(text)` | CC field with "抄送：" prefix |
| `issueinfo(organ, date)` | Issuing organ and date, left-right aligned |
| `seprule` | Black separator line for end-matter (版记) |
| `redrule` | Red separator line for red-header |

---

## Heading Levels

| Level | Syntax | Font | Size |
|---|---|---|---|
| 1 | `=` | SimHei (黑体) | 16pt |
| 2 | `==` | KaiTi bold (楷体加粗) | 16pt |
| 3 | `===` | FangSong bold (仿宋加粗) | 16pt |

---

## Font Dependencies

Fonts are listed in priority order; fallbacks are used automatically.

| Font | Purpose | Fallback |
|---|---|---|
| FZDaBiaoSong-B06 (方正大标宋) | Red-header, document title | SimHei (黑体) |
| FangSong (仿宋) | Body text | SimSun (宋体) |
| SimHei (黑体) | Level-1 headings, table headers | Noto Sans CJK SC |
| KaiTi (楷体) | Level-2 headings | STKaiti, Noto Serif CJK SC |
| SimSun (宋体) | Auxiliary | Noto Serif CJK SC |

---

## Project Structure

```text
gbt9704-gongwen/
├── src/
│   └── lib.typ               # Template source
├── template/
│   └── main.typ              # typst init template
├── examples/
│   ├── example.typ           # Full document example (zh)
│   ├── example-en.typ        # Full document example (en)
│   ├── manual.typ            # Usage manual (zh)
│   └── manual-en.typ         # Usage manual (en)
├── typst.toml
├── LICENSE
└── README.md
```

---

## Examples

Compile the examples:

```bash
# Chinese — red-header, tables, attachments, end-matter
typst compile --root . examples/example.typ

# English
typst compile --root . examples/example-en.typ

# Chinese usage manual (API reference)
typst compile --root . examples/manual.typ

# English usage manual
typst compile --root . examples/manual-en.typ
```

Pre-compiled PDFs:

- [example.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/example.pdf)
- [example-en.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/example-en.pdf)
- [manual.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/manual.pdf)
- [manual-en.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/manual-en.pdf)

---

## Changelog

### v0.1.0 (2026-07-09)

- **First Typst release**: Full GB/T 9704-2012 official document format support.
- A4 page, GB-standard margins (L 28mm, R 26mm, T 37mm, B 35mm), 28pt line spacing.
- Document element functions: red-header, title, main receiver, attachment, signature, date, end-matter, notes, CC.
- Chinese heading numbering (一、（一）、1.), first-line indent, centered tables.
- Font sizes: title 22pt, body 16pt, document number 12pt.
- Font fallback: FZDaBiaoSong, FangSong, SimHei, KaiTi, SimSun + open-source alternatives.
- `typst init @preview/gbt9704-gongwen` quick-start template.

---

## 中文简述

GB/T 9704-2012《党政机关公文格式》Typst 模板。严格遵循国标：A4 页面、国标边距、28 磅行距、三号仿宋正文、首行缩进 2 字符。提供红头、主送、附件、署名、日期、版记等公文要素函数。支持三档行间距主题（紧凑/正常/宽松）和三档表格样式（全线表/三线表/无线表）。字体回退链覆盖方正大标宋、仿宋、黑体、楷体、宋体及开源替代。

详细中文手册见 [manual.pdf](https://codeberg.org/songwupei/typst-gbt9704/raw/tag/v0.1.0/examples/manual.pdf)。

---

## Feedback & Contributing

- Issues: https://codeberg.org/songwupei/typst-gbt9704/issues
- Repository: https://codeberg.org/songwupei/typst-gbt9704
