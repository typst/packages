# Configuration Reference

This document provides a complete API reference for the Quill Typst package, including function signatures, parameters, themes, and cover page styles.

## `assignment` Template Function

The `#show: assignment.with(...)` rule configures document-wide metadata, cover pages, themes, and layout rules.

### Parameters

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `content` \| `str` | `none` | Document title. |
| `subtitle` | `content` \| `str` | `none` | Subtitle or secondary title description. |
| `course` | `content` \| `str` | `none` | Course name or code (e.g., `"CS 480"`). |
| `assignment` | `content` \| `str` | `none` | Assignment title or number (e.g., `"Assignment 3"`). |
| `student` / `author` | `content` \| `str` | `none` | Student or author name. |
| `student-id` / `id` | `content` \| `str` | `none` | Student ID or registration number. |
| `instructor` | `content` \| `str` | `none` | Instructor or supervisor name. |
| `department` | `content` \| `str` | `none` | Department or faculty name. |
| `university` | `content` \| `str` | `none` | University or institution name. |
| `semester` | `content` \| `str` | `none` | Term or semester (e.g., `"Fall 2026"`). |
| `section` | `content` \| `str` | `none` | Course section number. |
| `date` | `datetime` \| `str` | `none` | Submission date. Accepts `datetime` objects or formatted strings. |
| `logo` | `content` \| `image` | `none` | Institution logo image element or content. |
| `cover-page` | `bool` \| `str` | `false` | Enables cover page generation when `true` or set to a style name string. |
| `cover-style` | `str` | `"modern"` | Cover page aesthetic style (`"modern"`, `"swiss"`, `"geometric"`, `"architecture"`, `"minimal"`, `"classic"`, `"editorial"`). |
| `doc-ref` | `str` | `none` | Document reference identifier (used in `architecture` style). |
| `rev` / `revision` | `str` | `none` | Document revision string (used in `architecture` style). |
| `scale` | `str` | `none` | Technical scale notation (used in `architecture` style). |
| `theme` | `str` \| `dictionary` | `"nord-light"` | Color theme (`"nord-light"`, `"catppuccin-latte"`, `"paper"`, `"github-light"`). |
| `primary` | `color` | `none` | Custom primary accent color override. |
| `accent` | `color` | `none` | Custom secondary accent color override. |
| `font` | `str` \| `array` | `("Liberation Sans", ...)` | Primary font family for body text. |
| `code-font` | `str` \| `array` | `("JetBrains Mono", ...)` | Monospace font family for code blocks. |
| `radius` | `length` | `6pt` | Corner radius for callouts, code blocks, and cards. |
| `paper` | `str` | `"a4"` | Paper size identifier (e.g., `"a4"`, `"us-letter"`). |
| `height` | `none` \| `length` \| `relative` | `none` | Explicit page height (or `auto` for continuous page layout). |
| `height-auto` | `bool` | `false` | Enables continuous page height without page breaks. |
| `margin` | `dictionary` \| `length` | `(x: 2.2cm, top: 2.6cm, bottom: 2.4cm)` | Custom page margins. |
| `header-show` | `bool` | `true` | Show or hide running headers on content pages. |
| `footer-show` | `bool` | `true` | Show or hide running footers on content pages. |
| `question-numbering` | `str` | `"1"` | Question numbering pattern for `#question` blocks. |
| `toc` | `bool` | `false` | Automatically insert a Table of Contents. |
| `watermark` | `content` \| `str` | `none` | Diagonal background watermark text or image. |

---

## Cover Page Styles

Quill supports 7 cover page layouts configured via the `cover-style` parameter:

| Style | Description |
| :--- | :--- |
| `"modern"` | Contemporary digital card design with top accent bar and elevated metadata container. |
| `"swiss"` / `"swiss-editorial"` | International Typographic style with asymmetric grid layout, high contrast typography, and vertical accent bar. |
| `"geometric"` | Dynamic modern layout with background geometric shapes, grid cards, and diamond bullets. |
| `"architecture"` | Engineering drafting style with corner crosshairs `+`, technical header bar, annotation strip, and drawing title block. |
| `"minimal"` | Ultra-clean centered typography with generous whitespace and divider accents. |
| `"classic"` | Formal academic centered title page with double horizontal rules and traditional hierarchy. |
| `"editorial"` | Magazine-style layout with large typography and framed accent border card. |

---

## Color Themes

| Theme | Background | Primary | Accent | Description |
| :--- | :--- | :--- | :--- | :--- |
| `"nord-light"` | Soft cool white | Arctic blue | Steel blue | Default cool academic theme. |
| `"catppuccin-latte"` | Warm cream | Lavender | Mauve | Soft, warm palette. |
| `"paper"` | Pure white | Charcoal | Dark gray | High-contrast publication style. |
| `"github-light"` | GitHub light | Primer blue | Dark gray | Modern developer aesthetic. |

---

## Components API

### Question (`#question`)

Creates an automatically numbered question block.

- **Signature**: `#question(title: none, body)` (alias: `#que`)
- **Parameters**:
  - `title` (`str` | `content`): Optional question title or topic.
  - `body` (`content`): Main question text.

### Answer (`#answer`)

Creates a styled container for solutions.

- **Signature**: `#answer(body)` (alias: `#ans`)
- **Parameters**:
  - `body` (`content`): Solution or answer content.

### Note Callout (`#note`)

Displays highlighted note callout boxes.

- **Signature**: `#note(type: "info", title: none, body)`
- **Parameters**:
  - `type` (`str`): Callout variant: `"info"` (blue), `"tip"` (green), `"warning"` (amber), or `"note"` (neutral).
  - `title` (`str` | `content`): Optional custom title header.
  - `body` (`content`): Main note content.

### Key-Value Table (`#kv-table`)

Renders a two-column key-value grid.

- **Signature**: `#kv-table(col: 1, key-color: none, value-color: none, border-color: none, ..items)` (alias: `#kvtable`)
- **Parameters**:
  - `col` (`int`): Number of key-value column pairs (default: `1`).
  - `key-color` (`color`): Background fill for key cells.
  - `value-color` (`color`): Background fill for value cells.
  - `border-color` (`color`): Border stroke color.
  - `..items` (`positional`): Alternating key and value arguments (`"Key 1", "Value 1", "Key 2", "Value 2"`).

### Watermark (`#watermark`)

Inserts a watermark overlay.

- **Signature**: `#watermark(img, width: 100%, mark: none)`
- **Parameters**:
  - `img` (`image`): Image element.
  - `width` (`length` | `relative`): Image width constraint.
  - `mark` (`str` | `content`): Text badge overlaid on the image.
