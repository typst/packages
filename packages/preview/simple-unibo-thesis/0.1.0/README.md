# Simple Unibo Thesis

This is an unofficial thesis template for unibo. While I made it by looking at
the requirements from the Economics department, it's made to be highly
configurable, and hopefully fine for any programme. If not, feel free to open a
PR.

Provides two public functions:

- `thesis-cover`: renders a standalone cover page
- `thesis`: full document setup (cover + abstract + ToC + body)

Typical usage:

```text
#import "@preview/simple-unibo-thesis:0.1.0": thesis

#show: thesis.with(
    title: "My Dissertation",
    author: "Jane Doe",
    student-number: "1234567",
    supervisor: "Prof. John Smith",
    topic: "Economics",
    degree: "Master's Degree",
    degree-name: "Economics and Econometrics",
    department: "Department of Economics",
    academic-year: "2024/2025",
    graduation-session: "ZERO-TH",
    graduation-month: "March",
    abstract: [Your abstract text here.],
    locale: "en", // can also be "it"
)

= Introduction
...
#bibliography("references.bib", style: "apa")
```

If you only need the cover page (e.g. to prepend to an existing document), you
can use `thesis-cover` directly:

```text
#import "@preview/simple-unibo-thesis:0.1.0": thesis-cover

#thesis-cover(
  title: "My Dissertation",
  author: "Jane Doe",
  ...
)
```


## Procuring the Logo

I can't technically bundle the logo by default. It can be found [in this page](https://www.unibo.it/en/university/statute-standards-strategies-and-reports/image-identity-brand), or downloaded directly from [this link (which I found simply in the previous link)](https://www.unibo.it/en/images/copy_of_logo.jpg).

Just pass the logo image as the logo argument, and it'll all work

## Configuration

All parameters have what I think are sensible defaults and can be omitted if not
needed.

| Parameter               | Description                                                                     | Default                                          |
| ----------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------ |
| `title`                 | Dissertation title                                                              | `"Dissertation Title"`                           |
| `author`                | Candidate's full name                                                           | `"Your Name"`                                    |
| `student-number`        | Matriculation number                                                            | `"0000000"`                                      |
| `supervisor`            | Supervisor's name and title                                                     | `"Prof. Supervisor Name"`                        |
| `co-supervisor`         | Co-supervisor's name and title; omit to skip                                    | `none`                                           |
| `topic`                 | Topic or subject area of the dissertation                                       | `"TOPIC"`                                        |
| `university`            | Name of the University / Institution                                            | `"ALMA MATER STUDIORUM — UNIVERSITÀ DI BOLOGNA"` |
| `degree`                | Degree type (e.g. `"Master's Degree"`)                                          | `"DEGREE TYPE"`                                  |
| `degree-name`           | Full name of the degree programme (e.g. `"Economics and Econometrics"`)         | `"DEGREE NAME"`                                  |
| `department`            | Full department name                                                            | `"NAME OF DEPARTMENT"`                           |
| `academic-year`         | Academic year (e.g. `"2024/2025"`)                                              | `"ACADEMIC YEAR"`                                |
| `graduation-session`    | Session identifier (e.g. `"ZERO-TH"`)                                           | `"GRADUATION SESSION"`                           |
| `graduation-month`      | Month of the graduation session                                                 | `"GRADUATION MONTH"`                             |
| `abstract`              | Abstract content block; omit to skip                                            | `none`                                           |
| `abstract-title`        | Override the abstract heading text                                              | locale default                                   |
| `toc`                   | Whether to render a table of contents                                           | `true`                                           |
| `separate-abstract-toc` | Insert a page break between abstract and ToC                                    | `false`                                          |
| `font`                  | Body font                                                                       | `"New Computer Modern"`                          |
| `cover-font`            | Cover page font (can differ from body)                                          | `"New Computer Modern"`                          |
| `layout`                | Cover layout: `"logo"` (official UniBo style) or `"no-logo"` (Econ dept. style) | `"logo"`                                         |
| `logo`                  | Logo content (e.g. `image("unibo-logo.png")`); only used with `"logo"` layout   | `none`                                           |
| `locale`                | `"en"` or `"it"` (controls built-in label translations and lang option)         | `"en"`                                           |
| `labels`                | Override the template's localised strings manually (see below)                  | `none`                                           |

### Localisation

Setting `locale: "it"` switches the cover labels to Italian (`CANDIDATO`,
`RELATORE`, etc.). For any other language, pass a `labels` dict directly:

```text
#show: thesis.with(
  locale: "de",
  labels: (
    defended-by: "VORGELEGT VON",
    supervisor: "BETREUER",
    co-supervisor: "KORREFERENT",
    in-word: "in",
    dissertation: "Dissertation",
    graduation-session: "Abschlussprüfung",
    academic-year: "Akademisches Jahr",
    abstract-title: "Zusammenfassung",
  ),
  ...
)
```

## Licensing

The library (`lib.typ`) is licensed under LGPL-3.0, ensuring that modifications
to the library itself remain open source. The `template/` directory is licensed
under MIT-0, so that documents produced using this template are not encumbered
by the library's copyleft.
