Rapport is a Typst template designed for reports, papers, and technical documents. It provides consistent typography, refined spacing, styled code blocks, and a polished title and header layout.

# Usage

Import the package and wrap your document body with `rapport`:

```typst
#import "@preview/rapport:0.2.0": *

#show: rapport.with(
  title: "TITLE",
  author: "AUTHOR",
  header: "HEADER",
  date: datetime(
    year: 2026,
    month: 05,
    day: 1,
  )
)
```

# Template Parameters

| Parameter        | Description |
|------------------|-------------|
| `title`          | Document title |
| `author`         | Author |
| `header`         | Text displayed in page header |
| `date`           | A `datetime` value |
| `language`       | Language tag (default: `"en"`) |
| `paper-size`     | Page size (e.g., `"a4"`, `"us-letter"`) |
| `body-font`      | Font for body text |
| `heading-font`   | Font for headings |
| `raw-font`       | Font for code |
| `font-size`      | Base font size |
| `link-color`     | Color for hyperlinks |
| `muted-color`    | Color for secondary text |
| `block-bg-color` | Background for code blocks |

# Fonts

By default, Rapport makes use of the fonts Source Serif 4 and Source Sans 3. This can be overridden with the `body-font` and `heading-font` parameters.

# License

Rapport is licensed under the GNU General Public License v3.0 (GPL‑3.0).
