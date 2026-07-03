# OHDSI Symposium Submission

`ohdsi-symposium-submission` is a minimal Typst template package for OHDSI
symposium-style brief reports.

## Usage

Create a new project from the template:

```bash
typst init @preview/ohdsi-symposium-submission:0.1.0
```

The generated starter includes:

- `main.typ` with a title block and standard report sections
- `refs.bib` with sample BibTeX entries

## Package API

```typst
#import "@preview/ohdsi-symposium-submission:0.1.0": submission, references-section
```

Use `submission` as a document wrapper:

```typst
#show: doc => submission(
  title: "OHDSI Symposium Submission Title",
  authors: (
    (name: "First Author", affiliations: ("1",)),
    (name: "Second Author", affiliations: ("1", "2")),
  ),
  affiliations: (
    (id: "1", name: "Department or Organization, City, Country"),
    (id: "2", name: "Second Department or Organization, City, Country"),
  ),
  doc,
)
```

Render the bibliography with:

```typst
#references-section[
  #bibliography("refs.bib", title: none, style: "vancouver-superscript")
]
```

## Notes

- The template uses an OHDSI-style paper layout with serif typography, single-ish
  line spacing, and `6pt` paragraph spacing after each paragraph.
- The sample starter uses the `vancouver-superscript` bibliography style so
  in-text citations render as superscript numbers and the reference list uses
  `1.`, `2.`, `3.` numbering.
- The template uses `Libertinus Serif` by default for reliable cross-platform
  rendering. You can override the font in your project if you need exact
  institution-specific typography.
- If there is only one affiliation, superscript affiliation markers are hidden.

## License

This package is distributed under the `MIT` license. See
[`LICENSE`](LICENSE).
