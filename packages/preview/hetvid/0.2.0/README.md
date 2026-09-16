hetvid
========================================

This is a template for writing scientific notes in Typst,
with careful handling of indentation, theorem environments,
spacing, and other typographic details.
This template is designed for English and Chinese languages,
typographic details are optimized for Chinese.

The name _hetvid_ derives from Sanskrit word _hetuvidyā_,
which refers to Buddhist logico-epistemology.
The Chinese translation is 因明.

## Quick start

A minimal setup is as follows:

```typ
#import "@preview/hetvid:0.2.0": *
#show: hetvid.with(
  title: [Hetvid: A Typst template for lightweight notes],
  author: "itpyi",
  affiliation: "Xijing Ci'en Institute of Translation, Tang Empire",
  header: "Instruction",
  date-created: "2025-03-27",
  date-modified: "2025-04-22",
  abstract: [This is a template designed for writing scientific notes. ],
  toc: true,
)
```

See below for more configuration options.

## Configuration Options

The `hetvid` function accepts the following arguments to customize your document:

### Metadata & Layout

| Parameter | Type | Default Value | Description |
| --- | --- | --- | --- |
| `title` | content | `[Title]` | The title of the document. |
| `author` | string or array of dicts | `"The author"` | Single author: a string. Multi-author: array of dicts with keys `name`, `affiliation` (content or array), and `email`. |
| `affiliation` | content | `[The affiliation]` | Affiliation for single-author mode. Ignored in multi-author mode. |
| `header` | string/content | `[]` | Custom text to appear in the page header. |
| `date-created` | string | `datetime.today().display()` | Original creation date. |
| `date-modified` | string | `datetime.today().display()` | Last modification date. |
| `abstract` | content | `[]` | The abstract content. |
| `toc` | boolean | `true` | Whether to include a Table of Contents. |
| `paper-size` | string | `"a4"` | The physical paper size (e.g., `"letter"`, `"a4"`). |
| `lang` | string | `"en"` | Main document language (e.g., `"en"`, `"zh"`). |

### Typography

| Parameter | Type | Default Value | Description |
| --- | --- | --- | --- |
| `body-font` | array/string | *(List of Serif fonts)* | Font family for the main text. |
| `raw-font` | array/string | *(List of Mono fonts)* | Font family for code blocks and raw text. |
| `heading-font` | array/string | *(List of Sans fonts)* | Font family for titles and headings. |
| `math-font` | array/string | *(List of Math fonts)* | Font family for mathematical formulas. |
| `emph-font` | array/string | *(List of CJK fonts)* | Font family used for emphasized (italicized) text. |
| `body-font-size` | length | `11pt` | Base font size for the body text. |
| `raw-font-size` | length | `9pt` | Font size for code blocks. |
| `caption-font-size` | length | `10pt` | Font size for figure and table captions. |
| `body-font-weight` | string/int | `"regular"` | Weight for body text (use `450` for NewCM Book). |
| `heading-font-weight` | string/int | `"regular"` | Font weight for headings. |

### Styling & Spacing

| Parameter | Type | Default Value | Description |
| --- | --- | --- | --- |
| `link-color` | color | `link-color` | Color used for hyperlinks. |
| `muted-color` | color | `muted-color` | Color for less prominent text or UI elements. |
| `block-bg-color` | color | `block-bg-color` | Background color for code or quote blocks. |
| `ind` | length | `1.5em` (if `lang: "zh"`, then `2em` and unadjustable) | First-line indentation for paragraphs. |
| `justify` | boolean | `true` | Whether to justify the text alignment. |
| `hyphenate` | boolean | `true` | Enable or disable word hyphenation. |
| `bib-style` | dictionary | *(Mixed)* | Bibliography style mapping based on `lang`. |
| `thm-num-lv` | integer | `1` | The heading level at which theorem numbering resets. |

See [`doc.pdf`](https://github.com/itpyi/hetvid/blob/main/doc/doc.pdf) for a detailed explanation of how to use this template.

## Changelog

### 0.2.0

- **Multi-author support**: `author` now accepts an array of dicts with keys `name`, `affiliation` (content or array of contents), and `email`. Affiliations are automatically deduplicated and numbered; shared affiliations receive the same superscript. Single-author syntax remains fully backward-compatible.
- **`hyphenate` parameter**: boolean to control word hyphenation (default `true`).

### 0.1.0

First released version.

## Acknowledgements

This template is inspired by the [kunskap](https://typst.app/universe/package/kunskap/) template.



