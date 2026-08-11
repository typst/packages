# husky-uw-thesis

A [Typst](https://typst.app/) template for doctoral dissertations and master's theses at the **University of Washington**, Seattle.

This template generates the three required preliminary pages — title page, copyright page, and abstract — in compliance with the [UW Graduate School formatting guidelines](https://grad.uw.edu/current-students/enrollment-through-graduation/thesis-dissertation/). Body content follows with automatic page numbering.

## Quick start

### From the Typst CLI

```sh
typst init @preview/husky-uw-thesis:0.1.0 my-dissertation
cd my-dissertation
typst compile main.typ
```

### From the web app

Click **Start from template** and search for `husky-uw-thesis`.

### Manual import

```typst
#import "@preview/husky-uw-thesis:0.1.0": thesis

#show: thesis.with(
  title: [Your Dissertation Title],
  author: "Your Name",
  degree: "Doctor of Philosophy",
  year: "2026",
  program: "Your Department",
  chair: (
    name: "Chair Name",
    department: "Chair's Department",
  ),
  committee: (
    (name: "Chair Name", role: "Chair"),
    (name: "Second Member Name", role: none),
    (name: "Third Member Name", role: none),
  ),
  abstract: [
    Your abstract goes here.
  ],
)

= Introduction

Your content here.
```

## Parameters

| Parameter   | Type            | Default                                                      | Description                                                                 |
|-------------|-----------------|--------------------------------------------------------------|-----------------------------------------------------------------------------|
| `title`     | `content`       | —                                                            | Dissertation or thesis title.                                               |
| `author`    | `str`           | —                                                            | Your full name, matching your UW student record.                            |
| `degree`    | `str`           | `"Doctor of Philosophy"`                                     | Degree title as on your diploma.                                            |
| `year`      | `str`           | `"2026"`                                                     | Year your degree will be conferred.                                         |
| `program`   | `str`           | `"Physics"`                                                  | Department/school. Do **not** prefix with "UW" or "University of Washington". |
| `chair`     | `dictionary`    | —                                                            | `(name: str, department: str)` for committee chair.                         |
| `committee` | `array`         | —                                                            | Reading committee. Each: `(name: str)` or `(name: str, role: str)`.         |
| `abstract`  | `content`       | —                                                            | Abstract text.                                                              |
| `doc-type`  | `str`           | `"dissertation"`                                             | `"dissertation"` or `"thesis"`.                                             |
| `font`      | `str` or `array`| `("Palatino Linotype", "Palatino", "TeX Gyre Pagella", "Libertinus Serif")` | Body text font (with fallbacks).                                            |
| `mono-font` | `str` or `array`| `("Fira Code", "Fira Mono", "DejaVu Sans Mono")`                           | Monospace font for code/`raw` blocks.                                       |
| `font-size` | `length`        | `12pt`                                                       | Base font size.                                                             |
| `margin`    | `dictionary`    | `(top: 1in, bottom: 1in, left: 1.5in, right: 1in)`          | Page margins.                                                               |

## Fonts

The template defaults to **Palatino** for body text and **Fira Code** for monospace.
Fallback chains ensure the template compiles on any platform:

- Palatino Linotype → Palatino → TeX Gyre Pagella → **Libertinus Serif**
- Fira Code → Fira Mono → **DejaVu Sans Mono**

The bolded fonts are embedded in the Typst compiler and guaranteed to be available everywhere. If none of the preferred fonts are found, Typst silently falls back to these without warning.

For the intended appearance, install the preferred fonts on your system or upload them to the Typst web app:

- **Palatino Linotype** (bundled with Windows) or [**TeX Gyre Pagella**](https://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella) (free, cross-platform)
- [**Fira Code**](https://github.com/tonsky/FiraCode) (free, cross-platform)

You can override these via the `font` and `mono-font` parameters.

## Formatting notes

- The title page and copyright page may appear in either order (this template puts the title page first).
- **No images, color, or page headers** are permitted on the first three pages.
- All names, degree titles, and program names must match your MyGrad record exactly.
- Do not include professional titles (Dr., PhD, etc.) before or after committee member names.
- The abstract header and body must be on the same page.
- Body page numbering starts at 1.

For the full checklist, see the [UW ETD Formatting Checklist](https://grad.uw.edu/wp-content/uploads/2019/06/ETD-Formatting-Checklist.pdf).

## Accessibility

Starting with Typst 0.14, all output PDFs are tagged by default, providing baseline accessibility for screen readers. For stricter compliance (e.g., PDF/UA-1), compile with:

```sh
typst compile --pdf-standard ua-1 main.typ
```

Remember to provide `alt` text for all figures and images in your document body.

## License

This template is released under the [Apache 2.0 license](LICENSE), consistent with the original [UW LaTeX thesis class](https://github.com/UWIT-IAM/UWThesis).
