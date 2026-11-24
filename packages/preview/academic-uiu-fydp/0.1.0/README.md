# UIU CSE Final Year Design Project Report

`academic-uiu-fydp` provides a community report template for the Computer Science
and Engineering Final Year Design Project at United International University.
Shaad Ahmmed adapted Swakkhar Shatabda's original LaTeX template to Typst.

It includes FYDP-1 and final report variants, configurable title and front matter,
six editable chapter files, engineering mapping tables, an example context diagram,
automatic contents and figure/table lists, and an IEEE numeric bibliography.
The layout uses A4 paper, 3 cm margins, 11 pt New Computer Modern, Roman front-matter
pages, and Arabic body pages. No university logo is included.

## Start a report

Install the latest stable [Typst compiler](https://github.com/typst/typst/releases/latest),
version 0.15.0 or newer. After this package is accepted on Typst Universe:

```sh
typst init @preview/academic-uiu-fydp:0.1.0 my-fydp
cd my-fydp
typst compile main.typ report.pdf
```

In the Typst web app, open this template's Universe page and choose **Start from
template** after publication. Before acceptance, use the local instructions in
the [source repository](https://github.com/shaadahmmed/uiu-fydp-template).

1. Edit `project.typ` with the title, student names and IDs, date, and supervisors.
2. Replace the examples in `front-matter/`, `chapters/`, and `assets/`.
3. Add your bibliography entries to `references.bib` and cite them with `@key`.
4. Compile the report and review all numbering, captions, tables, and references.

For FYDP-1, compile with `typst compile --input stage=fydp-1 main.typ report.pdf`.
This omits the implementation chapter. To make this the default in the web app,
change the stage default in `content.typ`. Confirm required sections with your educator.

## Minimal example

```typst
#import "@preview/academic-uiu-fydp:0.1.0": fydp-report

#show: fydp-report.with(
  title: [My Final Year Design Project],
  students: ((name: "Student Name", id: "011234567"),),
  date: [November 2026],
  show-figure-list: false,
  show-table-list: false,
)

= Introduction
Introduce the problem and your objectives.
```

## Configuration

Apply `fydp-report` as a show rule. The body is supplied automatically by the rule.

| Option | Default | Purpose |
| --- | --- | --- |
| `title` | Example title | Cover title content |
| `students` | One example student | Nonempty array of `(name: "…", id: "…")` dictionaries |
| `date` | `[Month Year]` | Explicit submission date |
| `university` | United International University | Cover institution |
| `department` | Department of Computer Science and Engineering | Cover department |
| `degree` | Bachelor of Science in Computer Science and Engineering | Degree wording |
| `supervisors` | `()` | Array of supervisor content, e.g. `([Name],)` |
| `logo` | `none` | User-provided image/content |
| `abstract` | `none` | Abstract content; omit with `none` |
| `acknowledgements` | `none` | Acknowledgements content; omit with `none` |
| `publications` | `none` | Optional publication-list content |
| `show-figure-list` | `true` | Include List of Figures |
| `show-table-list` | `true` | Include List of Tables |
| `outline-depth` | `3` | Contents heading depth |
| `font` | `"New Computer Modern"` | Body font |
| `font-size` | `11pt` | Body text size |
| `margin` | `3cm` | Page margins |

The starter enables the abstract and acknowledgements using local files.
`guidance(body)` is also exported for optional instructional callouts:

```typst
#import "@preview/academic-uiu-fydp:0.1.0": guidance
#guidance[Replace this instruction with your own project content.]
```

Detailed guides: [configuration](docs/CONFIGURATION.md),
[students](docs/STUDENTS.md), [educators](docs/EDUCATORS.md),
[conversion notes](docs/MIGRATION.md), and [publishing](docs/PUBLISHING.md).
Repository-only build commands in those guides apply to a source checkout;
an initialized project builds directly through its `main.typ`.

## Updates

Imports select an exact package version. New releases require a new Universe
submission, and existing projects choose when to update their imports. Updating
the package does not overwrite copied chapter files, assets, or configuration.
See the [changelog](CHANGELOG.md).

## Attribution and license

The [original Overleaf template](https://www.overleaf.com/latex/templates/united-international-university-fydp-template-department-of-cse/xbkpdgkgjdhc)
by **Swakkhar Shatabda** is listed under **CC BY 4.0**. This Typst adaptation by
**Shaad Ahmmed** uses the same license. See [LICENSE](LICENSE), [NOTICE](NOTICE),
and [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Retain appropriate attribution, link the license, and identify changes when
sharing adapted template material. The starter includes a credit in its
acknowledgements and a `NOTICE.md`. Your original project prose, results, and data
do not automatically acquire the template's license.

This is a community adaptation without a claim of university endorsement.
University names and trademarks are not licensed by this project.
