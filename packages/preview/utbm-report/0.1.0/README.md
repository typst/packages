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

`report(`**doc-title**, **doc-author**, **doc-date**, **page-paper**, **page-numbering**, **text-size**, **text-lang**, **text-font**, **par-justify**, **heading-numbering**, **show-outline**, **outline-title**, **course-name**, **doc**`)`

| Parameter           | Type / Example                       | Default                 | Notes                                    |
| ------------------- | ------------------------------------ | ----------------------- | ---------------------------------------- |
| `doc-title`         | content block: `[Title]`             | `[Title]`               | Shown on the title page.                 |
| `doc-author`        | `string`|`array` : `("Alice","Bob")` | `("Author1","Author2")` | Authors on the title page.               |
| `doc-date`          | `auto` or `datetime type`            | `auto`                  | Print date on cover; `auto` uses today.  |
| `page-paper`        | string: `"a4"`                       | `"a4"`                  | Paper size.                              |
| `page-numbering`    | string: `"1"`                        | `"1"`                   | Page number format (e.g., `"1"`).        |
| `text-size`         | length: `12pt`                       | `12pt`                  | Base text size.                          |
| `text-lang`         | language code: `"fr"`                | `"fr"`                  | Sets text language (hyphenation, etc.).  |
| `text-font`         | font family: `"New Computer Modern"` | `"New Computer Modern"` | Base font family.                        |
| `par-justify`       | bool                                 | `true`                  | Paragraph justification toggle.          |
| `heading-numbering` | string: `"11"`                       | `"11"`                  | Heading numbering style (Typst pattern). |
| `show-outline`      | bool                                 | `true`                  | Insert an outline (“Sommaire”) page.     |
| `outline-title`     | string: `"Sommaire"`                 | `"Sommaire"`            | Title used for the outline page.         |
| `course-name`       | string                               | `"Course name"`         | Appears on title area.                   |
| `doc`               | document content                     | *(required)*            | Your report body.                        |

## Full Example

Paste this into a fresh `.typ` file:

```typst
#import "@preview/utbm-report:0.1.0": report

#show: doc => report(
  doc-title: [Rapport TP n°1],
  doc-author: ("Alice Martin", "Bob Dupont"),
  doc-date: datetime(year: 2025, month: 9, day: 14),
  page-paper: "a4",
  page-numbering: "1",
  text-size: 12pt,
  text-lang: "fr",
  text-font: "New Computer Modern",
  par-justify: true,
  heading-numbering: "11",
  show-outline: true,
  outline-title: "Sommaire",
  course-name: "IF2",
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


