# charged-pace

A Typst package for writing a Pace University computer science thesis or dissertation.

`charged-pace` provides a prebuilt document wrapper for Pace's MSCS thesis / PhD dissertation format, including front matter, chapter styling, figure/table/equation formatting, and bibliography setup.

## Features

- Title page and approval/signature page
- Abstract and acknowledgment pages
- Table of contents
- Automatic lists of tables, figures, and equations
- Chapter and section formatting
- Styled figures, tables, and equation references
- IEEE bibliography formatting

## Usage

Import the package and wrap your document with `manuscript`:

```typ
#import "@preview/charged-pace:0.1.0": manuscript

#show: manuscript.with(
  title: [A Typst Template for a PhDCS Dissertation or MSCS Thesis],
  author: [Forename Surname],
  date: (month: "May", year: 2026),
  degree: "Master's",
  bibliography-decl: bibliography("refs.yaml"),
  abstract: [
    An abstract should be typed single-spaced and contain no more than 350 words.
  ],
)

= Introduction
Your content goes here.
```

The `manuscript` entry point is also aliased as `thesis` and `dissertation` for compatibility with older versions.
