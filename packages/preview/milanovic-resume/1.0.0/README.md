# milanovic-resume

A one-page, single-column resume for software engineers. One column means the order you see is the order an applicant tracking system (ATS) reads. Ligatures are off by default, so words like "efficient" stay plain text for keyword search. Your name, keywords and title go into the PDF metadata.

The same design exists as a LaTeX class at [github.com/milanm/Milanovic-Resume](https://github.com/milanm/Milanovic-Resume), with a matching cover letter and a CI check for page count and text extraction.

![Resume made with milanovic-resume](https://raw.githubusercontent.com/milanm/Milanovic-Resume/v1.0.0/images/resume.png)

## Start

```bash
typst init @preview/milanovic-resume:1.0.0
```

On [typst.app](https://typst.app), choose **Start from template** and search for `milanovic-resume`.

## Font

The template uses [Source Sans 3](https://github.com/adobe-fonts/source-sans/releases) (SIL Open Font License). Typst packages can't ship fonts, so add it once:

- **typst.app**: upload the `.otf` files to your project.
- **CLI**: install the font, or keep the `.otf` files in a folder and run `typst compile --font-path fonts main.typ`.

Prefer another font? Pass it: `font: "Source Sans Pro"`.

## Example

```typ
#import "@preview/milanovic-resume:1.0.0": *

#show: resume.with(
  name: "Your Name",
  contact: ([City, Country], link("mailto:you@example.com")[you\@example.com]),
  headline: "Senior Backend Engineer",
  tagline: "Ships payment APIs that handle 2M transactions a day",
  keywords: ("Go", "PostgreSQL", "Kubernetes"),
)

#summary[Backend engineer with 6 years building high-traffic APIs in Go and PostgreSQL.]

= Skills
#skills([Go, Python], [PostgreSQL], [Kubernetes], [AWS])

= Professional Experience
#job("Company", title: "Senior Engineer", location: "Berlin, Germany", dates: "2023 – Present")[
  - Cut p95 latency from 900 ms to 180 ms by moving reads to a cache.
]

= Education
- #education("M.Sc. in Computer Science", school: "University", year: "2019")
```

## Settings

| Argument | Default | Notes |
|---|---|---|
| `paper` | `"a4"` | or `"us-letter"` |
| `accent` | `rgb("#003366")` | heading and name colour |
| `font-size` | `11pt` | go down to `10pt` before you cut content you need |
| `font` | `"Source Sans 3"` | any installed font |
| `ligatures` | `false` | `true` looks nicer and is harder to parse |

## Building blocks

| Function | What it does |
|---|---|
| `resume.with(..)` | Page setup and header: `name`, `contact`, `headline`, `tagline`, `keywords` |
| `summary[..]` | Short paragraph under the header |
| `= Heading` | Centred section heading with rules above and below |
| `skills(..)` | Two-column bullet list, read left column first |
| `job(company, title:, location:, dates:)[..]` | Position header, bullets in the body |
| `project(name, info:, stack:)[..]` | Project header, bullets in the body |
| `education(degree, school:, year:)` | Education line, use inside a list |
| `inline[..][..]` | Certifications, languages: items joined with a middle dot |
| `letter(recipient:, date:, signature:)[..]` | Cover letter body in the same style |

## License

The package code (`lib.typ`) is MIT. The template directory (`template/main.typ`, the file `typst init` copies into your project) is MIT-0, so your finished resume carries no license obligations. Both texts are in `LICENSE`. Source Sans 3 is by Adobe, licensed under the SIL Open Font License 1.1, and is not part of this package.
