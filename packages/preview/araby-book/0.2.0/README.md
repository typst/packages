# araby-book

A minimalist Typst template for typesetting Arabic books: novels, essay
collections, dīwāns, or any long-form Arabic text that needs right-to-left
layout, a proper title page, running headers, and a table of contents out
of the box.

## Features

- Right-to-left layout with justified, indented paragraphs tuned for Arabic
  typography (`Amiri` / `Noto Naskh Arabic` by default).
- Eastern Arabic-Indic page numbers (١، ٢، ٣ …), toggleable.
- Automatic title page, optional dedication page, and table of contents.
- Chapter-aware running headers (book title on odd pages, current chapter
  title on even pages), suppressed on the title page and on chapter-opening
  pages.
- Styled level-1 (chapter), level-2 (section), level-3 (subsection) and level-4 (sub-subsection) headings.
- Colored footnotes with a matching entry style, with configurable colors and sizes.
- Customizable header separator and footer styling.
- Helper functions for converting Western Arabic digits to Eastern Arabic digits (`arabic-digits`).
- Helpers for classical Arabic poetry pairs (`poetry`) and Quranic /
  decorative verse callouts (`verse`, `inline-verse`).
- Inline quotation helper (`inline-quotation`) with optional footnotes.

## Usage

```typst
#import "@preview/araby-book:0.2.0": book

#show: book.with(
  title: "عنوان الكتاب",
  subtitle: "عنوان فرعي اختياري",
  author: "اسم المؤلف",
  publisher: "دار النشر",
  edition: "الطبعة الأولى",
  date: "2026",
  dedication: [إهداء اختياري],
)

= الفصل الأول

نص الفصل هنا...
```

Run `typst init @preview/araby-book:0.2.0` to scaffold a new
project from this template, or use the "Start from template" button on
Typst Universe.

### `book` parameters

| Parameter          | Type              | Default                          | Description                                                     |
| ------------------ | ----------------- | -------------------------------- | --------------------------------------------------------------- |
| `title`            | `str`             | `""`                             | Book title, used on the cover and in the running header.        |
| `subtitle`         | `content \| none` | `none`                           | Optional subtitle shown under the title on the cover.           |
| `author`           | `str`             | `""`                             | Author name, shown on the cover.                                |
| `publisher`        | `content \| none` | `none`                           | Publisher name (metadata / cover use).                          |
| `edition`          | `content \| none` | `none`                           | Edition label, shown on the cover.                              |
| `date`             | `content \| none` | `none`                           | Publication date, shown on the cover.                           |
| `paper`            | `str`             | `"a5"`                           | Page size, any Typst-supported paper name.                      |
| `font`             | `array`           | `("Amiri", "Noto Naskh Arabic")` | Font fallback list for body text.                               |
| `font-size`        | `length`          | `11pt`                           | Base body text size.                                            |
| `primary-color`    | `color`           | `rgb("#000000")`                 | Accent color for headings and cover text.                       |
| `footnote-color`   | `color`           | `rgb("#8b0000")`                 | Color for footnote markers and entries.                         |
| `eastern-digits`   | `bool`            | `true`                           | Use Eastern Arabic-Indic digits for page numbers and footnotes. |
| `dedication`       | `content \| none` | `none`                           | Optional dedication page, shown after the cover.                |
| `show-toc`         | `bool`            | `true`                           | Whether to render a table of contents.                          |
| `toc-title`        | `str`             | `"الفهرس"`                       | Table of contents heading text.                                 |
| `chapter-label`    | `str`             | `"فصل"`                          | Word displayed before chapter numbers in heading styling.       |
| `copyright`        | `content \| none` | `none`                           | Copyright notice displayed on verso of title page.              |
| `verse-color`      | `color`           | `rgb("#8b0000")`                 | Default color for verse callouts (`verse` and `inline-verse`).  |
| `footnote-size`    | `length`          | `0.85em`                         | Font size for footnote text relative to base.                   |
| `header-separator` | `stroke`          | `0.3pt + gray.lighten(50%)`      | Stroke style for the line under running headers.                |

### Helper functions

- `arabic-digits(n)` - converts Western Arabic digits to Eastern Arabic digits (e.g., `123` → `"١٢٣"`). Useful for custom numbering.

- `poetry(first, second)` - renders a traditional صدر/عجز poetry pair on
  one line, separated by a centered `***`.

- `verse(body, ref: none, color: rgb("#8b0000"))` - renders a centered,
  boxed verse or quotation with an optional attribution. The `color` parameter
  allows customizing the verse text color.

- `inline-verse(body, ref: none, color: rgb("#8b0000"))` - renders a short
  quotation inline within a paragraph, with an optional attribution. The
  `color` parameter allows customizing the verse text color.

- `inline-quotation(body, ref: none, footnote-entry: none)` - renders a short
  quotation inline within a paragraph in italic style, with optional attribution
  and an optional footnote entry.

See [`template/main.typ`](template/main.typ) for a complete working example.

## License

`lib.typ` is licensed under the [BSD 3-Clause License](LICENSE).

The `template/` scaffold (`main.typ`, copied into your project by
`typst init`) is licensed under the [BSD Zero Clause License](LICENSE-0BSD)
instead, so you can freely use, modify, and distribute your own book —
written starting from that file — without any attribution requirement.
