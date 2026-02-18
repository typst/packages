# Simple Unibo Thesis

This is an unofficial thesis template for unibo. While I made it by looking at
the requirements from the Economics department, it's made to be highly
configurable, and hopefully fine for any programme. If not, feel free to open a
PR.

Provides two public functions:

- `thesis-cover`: renders a standalone cover page
- `thesis`: full document setup (cover + abstract + ToC + body)

Typical usage:

```json
#import "@preview/simple-unibo-thesis:0.1.0": thesis

#show: thesis.with(
    title: "My Dissertation",
    author: "Jane Doe",
    student-number: "1234567",
    supervisor: "Prof. John Smith",
    program: "Economics",
    degree: "Master's Degree",
    department: "Department of Economics",
    academic-year: "2024/2025",
    graduation-month: "March",
    abstract: [Your abstract text here.],
    locale: "en", // can also be "it"
)

= Introduction
...
#bibliography("references.bib", style: "apa")
```

If you only need the cover page (e.g. to prepend to an existing document), you
can use thesis-cover directly:

```json
#import "@preview/simple-unibo-thesis:0.1.0": thesis-cover

#thesis-cover(
  title: "My Dissertation",
  author: "Jane Doe",
  ...
)
```

## Configuration

All parameters have what I think are sensible defaults and can be omitted if not
needed.

| Parameter          | Description                                                              | Default                 |
| ------------------ | ------------------------------------------------------------------------ | ----------------------- |
| `title`            | Dissertation title                                                       | `"Dissertation Title"`  |
| `author`           | Candidate's full name                                                    | `"Your Name"`           |
| `student-number`   | Matriculation number                                                     | `"0000000"`             |
| `supervisor`       | Supervisor's name and title                                              | `"Prof. Supervisor Name"` |
| `program`          | Degree programme name                                                    | `"PROGRAM NAME"`        |
| `degree`           | Degree type (e.g. `"Master's Degree"`)                                   | `"DEGREE TYPE"`         |
| `department`       | Full department name                                                     | `"NAME OF DEPARTMENT"`  |
| `academic-year`    | Academic year (e.g. `"2024/2025"`)                                       | `"2013/2014"`           |
| `graduation-month` | Month of the graduation session                                          | `"GRADUATION MONTH"`    |
| `abstract`         | Abstract content block; omit to skip                                     | `none`                  |
| `abstract-title`   | Override the abstract heading text                                       | locale default          |
| `toc`              | Whether to render a table of contents                                    | `true`                  |
| `separate-abstract-toc` | Insert a page break between abstract and ToC                         | `false`                 |
| `font`             | Body font                                                                | `"New Computer Modern"` |
| `cover-font`       | Cover page font (can differ from body)                                   | `"New Computer Modern"` |
| `locale`           | `"en"` or `"it"` (controls built-in label translations, and lang option) | `"en"`                  |
| `labels`           | Override the template's localised strings manually (see below)           | `none`                  |

### Localisation

Setting `locale: "it"` switches the cover labels to Italian (`CANDIDATO`,
`RELATORE`, etc.). For any other language, pass a `labels` dict directly:

```json
#show: thesis.with(
  locale: "de",
  labels: (
    defended-by: "VORGELEGT VON",
    supervisor: "BETREUER",
    in-word: "in",
    graduation-session: "Abschlussprüfung",
    academic-year: "Akademisches Jahr",
    abstract-title: "Zusammenfassung",
  ),
  ...
)
```
