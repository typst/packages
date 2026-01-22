# itmo-report

A Typst template for ITMO University research reports and dissertations.

## Usage

```typst
#import "@preview/itmo-report:0.1.0": report

#show: report.with(
  title: "Your Report Title",
  student: "Your Name",
  faculty: "Faculty of Information Technologies and Programming",
  program: "Software Engineering",
  field-of-study: "09.04.04",
  supervisor: "Prof. John Doe",
  responsible: "Dr. Jane Smith",
)

= Introduction

Your content here...
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | string | `"Untitled Report"` | Report title |
| `student` | string | `"Student Name"` | Student's full name |
| `faculty` | string | `none` | Faculty name |
| `program` | string | `none` | Educational program |
| `field-of-study` | string | `none` | Field of study code |
| `supervisor` | string | `none` | Thesis supervisor |
| `responsible` | string | `none` | Person responsible for research |
| `show-toc` | bool | `true` | Show table of contents |
| `bib-file` | string | `none` | Bibliography file path  |

## Features

- Pre-configured A4 page layout with ITMO margins
- Automatic title page generation with institution header
- Table of contents
- Vancouver-style bibliography
- Proper heading formatting and numbering

## License

MIT
