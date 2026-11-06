# easy-internship

A clean report template for school projects and internship reports: cover page, table of contents, school and company logos in the header, and a footer with author, page number and date. Works in English and French.

<p align="center">
  <img src="https://raw.githubusercontent.com/PierreLapolla/easy-internship/v0.1.0/thumbnail.png" alt="Cover page" width="45%">
</p>

## Getting started

Create a new project from the template:

```sh
typst init @preview/easy-internship:0.1.0
```

Or use it in an existing document:

```typst
#import "@preview/easy-internship:0.1.0": report

#show: report.with(
  title: [My report],
  author: "Jane Doe",
)

= Introduction
Your report content here.
```

Logos and bibliography are passed as content, so their paths are resolved relative to *your* file:

```typst
#show: report.with(
  title: [Internship Report],
  author: "Jane Doe",
  school-logo: image("school-logo.svg"),
  company-logo: image("company-logo.svg"),
  bibliography: bibliography("refs.bib"),
)
```

## Parameters

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | content | `[My report]` | Cover title and document metadata. |
| `author` | string | `"Student Name"` | Cover author, footer and metadata. |
| `subtitle` | content / `none` | `none` | Subtitle on the cover page. |
| `date` | datetime / content | `datetime.today()` | Shown on the cover and in the footer. |
| `language` | string | `"en"` | Text language (e.g. `"en"`, `"fr"`). |
| `font` | string | `"Libertinus Serif"` | Body font, falls back to Libertinus Serif. |
| `text-size` | length | `11pt` | Body text size. |
| `page-margin` | length / dictionary | `2.5cm` | Passed to `page(margin: ..)`. |
| `logo-size` | length | `1cm` | Logo height in the header (doubled on the cover). |
| `footer-font-size` | length | `0.8em` | Size of the footer side texts. |
| `cover-title-size` | length | `30pt` | Cover title size. |
| `cover-subtitle-size` | length | `18pt` | Cover subtitle size. |
| `cover-page` | bool | `true` | Render the cover page. |
| `outline-page` | bool | `true` | Render the table of contents. |
| `keywords` | array | `()` | Document metadata keywords. |
| `description` | content / `none` | `none` | Document metadata description. |
| `school-logo` | content / `none` | `none` | Left header logo, e.g. `image("logo.png")`. |
| `company-logo` | content / `none` | `none` | Right header logo. |
| `footer-content` | content / `none` | `none` | Left footer text, defaults to `author`. |
| `highlight-color` | color | `rgb("#00727A")` | Accent color for title, headings and highlights. |
| `bibliography` | content / `none` | `none` | e.g. `bibliography("refs.bib")`, rendered on a new page at the end. |

## License

[MIT-0](LICENSE): use, modify and share freely, no attribution required in your report.
