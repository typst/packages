# utbm-report

Minimal, customizable Typst template for UTBM report submissions.

> [!NOTE]
> **Institution & logo attribution**
> The template uses the **Université de Technologie de Belfort-Montbéliard (UTBM)** logo.
> See [https://www.utbm.fr](https://www.utbm.fr) for the institution’s official website.
> Use of this logo is subject to UTBM’s own policies, users should verify the authorization for their context.

## Overview

`utbm-report` provides a simple report wrapper with sensible defaults for UTBM coursework. It sets up the page, title area, optional outline.

## Features

- Pre-made cover page: automatically formatted, only requires title, subject, and authors

- Semester detection: Spring or Autumn semester inferred automatically from the date

- Built-in table of contents (“Sommaire”)

## Install

```typst
#import "@preview/utbm-report:0.1.0": report
```

## Quick Start

Minimal usage:

```typst
#import "@preview/utbm-report:0.1.0": report

#show: doc => report(
  doc_title: [My First UTBM Report],
  doc_author: ("Alice Martin", "Bob Dupont"),
  course_name: "IF2",
  doc
)

= Introduction

Your content starts here.
```

## Parameters

`report(`**doc_title**, **doc_author**, **doc_date**, **page_paper**, **page_numbering**, **text_size**, **text_lang**, **text_font**, **par_justify**, **heading_numbering**, **show_outline**, **outline_title**, **course_name**, **doc**`)`

| Parameter           | Type / Example                       | Default                 | Notes                                    |
| ------------------- | ------------------------------------ | ----------------------- | ---------------------------------------- |
| `doc_title`         | content block: `[Title]`             | `[Title]`               | Shown on the title page.                 |
| `doc_author`        | `string`|`array` : `("Alice","Bob")` | `("Author1","Author2")` | Authors on the title page.               |
| `doc_date`          | `auto` or `datetime type`            | `auto`                  | Print date on cover; `auto` uses today.  |
| `page_paper`        | string: `"a4"`                       | `"a4"`                  | Paper size.                              |
| `page_numbering`    | string: `"1"`                        | `"1"`                   | Page number format (e.g., `"1"`).        |
| `text_size`         | length: `12pt`                       | `12pt`                  | Base text size.                          |
| `text_lang`         | language code: `"fr"`                | `"fr"`                  | Sets text language (hyphenation, etc.).  |
| `text_font`         | font family: `"New Computer Modern"` | `"New Computer Modern"` | Base font family.                        |
| `par_justify`       | bool                                 | `true`                  | Paragraph justification toggle.          |
| `heading_numbering` | string: `"11"`                       | `"11"`                  | Heading numbering style (Typst pattern). |
| `show_outline`      | bool                                 | `true`                  | Insert an outline (“Sommaire”) page.     |
| `outline_title`     | string: `"Sommaire"`                 | `"Sommaire"`            | Title used for the outline page.         |
| `course_name`       | string                               | `"Course name"`         | Appears on title area.                   |
| `doc`               | document content                     | *(required)*            | Your report body.                        |

## Full Example

Paste this into a fresh `.typ` file:

```typst
#import "@preview/utbm-report:0.1.0": report

#show: doc => report(
  doc_title: [Rapport TP n°1],
  doc_author: ("Alice Martin", "Bob Dupont"),
  doc_date: datetime(year: 2025, month: 9, day: 14),
  page_paper: "a4",
  page_numbering: "1",
  text_size: 12pt,
  text_lang: "fr",
  text_font: "New Computer Modern",
  par_justify: true,
  heading_numbering: "11",
  show_outline: true,
  outline_title: "Sommaire",
  course_name: "IF2",
  doc
)

= Introduction

This template helps you meet UTBM conventions with minimal setup.

== Motivation
State the problem you are solving and the expected outcomes.

= Methods

Explain your approach, assumptions, and tools.

== Algorithm
Present your algorithm and its complexity.

= Results

Summarize the key findings, tables, or figures.

= Conclusion

Wrap up with lessons learned and potential improvements.
```

## License

MIT © langonne


