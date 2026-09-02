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
- Styled level-1 ("فصل") and level-2 headings.
- Colored footnotes with a matching entry style.
- Helpers for classical Arabic poetry pairs (`poetry`) and Quranic /
  decorative verse callouts (`verse`, `inline_verse`).

## Usage

```typst
#import "@preview/araby-book:0.1.0": book

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

Run `typst init @preview/araby-book:0.1.0` to scaffold a new
project from this template, or use the "Start from template" button on
Typst Universe.

### `book` parameters

| Parameter        | Type              | Default                          | Description                                              |
| ---------------- | ----------------- | -------------------------------- | -------------------------------------------------------- |
| `title`          | `str`             | `""`                             | Book title, used on the cover and in the running header. |
| `subtitle`       | `content \| none` | `none`                           | Optional subtitle shown under the title on the cover.    |
| `author`         | `str`             | `""`                             | Author name, shown on the cover.                         |
| `publisher`      | `content \| none` | `none`                           | Publisher name (metadata / cover use).                   |
| `edition`        | `content \| none` | `none`                           | Edition label, shown on the cover.                       |
| `date`           | `content \| none` | `none`                           | Publication date, shown on the cover.                    |
| `paper`          | `str`             | `"a5"`                           | Page size, any Typst-supported paper name.               |
| `font`           | `array`           | `("Amiri", "Noto Naskh Arabic")` | Font fallback list for body text.                        |
| `font-size`      | `length`          | `11pt`                           | Base body text size.                                     |
| `primary-color`  | `color`           | `rgb("#000000")`                 | Accent color for headings and cover text.                |
| `footnote-color` | `color`           | `rgb("#8b0000")`                 | Color for footnote markers and entries.                  |
| `eastern-digits` | `bool`            | `true`                           | Use Eastern Arabic-Indic digits for page numbers.        |
| `dedication`     | `content \| none` | `none`                           | Optional dedication page, shown after the cover.         |
| `show-toc`       | `bool`            | `true`                           | Whether to render a table of contents.                   |
| `toc-title`      | `str`             | `"الفهرس"`                       | Table of contents heading text.                          |

### Helper functions

- `poetry(first, second)` - renders a traditional صدر/عجز poetry pair on
  one line, separated by a centered `***`.
- `verse(body, ref: none, color: rgb("#8b0000"))` - renders a centered,
  boxed verse or quotation with an optional attribution.
- `inline_verse(body, ref: none, color: rgb("#8b0000"))` - renders a short
  quotation inline within a paragraph, with an optional attribution.
- `inline_quotation(body, ref: none)` - renders a short quotation inline within a
  paragraph, in italic style, with an optional attribution.

See [`main.typ`](main.typ) for a complete working example.

## License

This template is licensed under the [BSD 3-Clause License](LICENSE).
