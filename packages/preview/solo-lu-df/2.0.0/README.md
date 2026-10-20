# solo-lu-df

**Warning:** `solo-lu-df` made breaking changes in `2.0`. See the
[migration guide](#v20-migration-guide) and [changelog](#changelog) for more
information.

A Typst template to write qualification papers, bachelor’s theses, and master’s
theses for Latvijas Universitāte (Faculty of Exact Sciences, Computer Science).
The package provides university-compliant layout rules, helpers for
title/abstract/appendices, and a ready-to-edit example.

## Usage

Use the template in the Typst web app by clicking "Start from template" and
searching for `solo-lu-df`, or initialize a new project with the CLI:

```sh
typst init @preview/solo-lu-df
```

Typst will create a new directory with the files needed to get started.

## Configuration

This template exports the `ludf` function which accepts named arguments to
configure the whole document, `bibliography-here()` marker and `appendix` helper
function. Important arguments:

- `title`: Document title (content).
- `authors`: Array of author dictionaries. Each author must have `name` and
  `code` and may include `location` and `email`.
- `advisors`: Array of advisor dictionaries with `title` and `name`.
- `reviewer`: Reviewer dictionary with `name`. Used on the documentary page for thesis types that include a reviewer.
- `thesis-type`: Type of thesis - `"bachelor"`, `"master"`, `"course"`, or `"qualification"`. The documentary page adapts its content based on this value.
- `submission-date`: `datetime(...)` value for the thesis submission date. Defaults to `today`.
- `defense-date`: `datetime(...)` value for the thesis defense or presentation date. Used on the documentary page for thesis types that include it. Defaults to `today`.
- `place`: Place string (e.g., `"Rīga"`).
- `abstract`: A record with `primary` and `secondary` abstracts. These are role-based sections, not fixed languages: `primary` is the main abstract and `secondary` is the additional required abstract. By default `primary` is Latvian and `secondary` is English, but both can be overridden. Each has `text` (content) and `keywords` (array) as well as `title`, `lang` and `keywords-title`.
- `bibliography`: Result of `bibliography("path/to/file.yml")` or `none`. Place `#bibliography-here()` in the body where the references section should appear.
- `locale`: Built-in locale preset name. Currently `"lv"` and `"en"` are provided. Defaults to `"lv"`.
- `labels`: Optional nested dictionary of label overrides merged into the selected locale preset.
- `outline-title`: Title for the table of contents. Defaults to `"Saturs"`.
- `show-documentary-page`: Whether to display the documentary page at the end. Defaults to `true`.
- `description`: Document description for PDF metadata. Defaults to `none`.
- Positional argument: the document body follows the `ludf.with(...)` call.

**Note:** The template automatically extracts keywords from both `primary` and `secondary` abstracts and sets them as PDF document metadata.

The function also accepts a single, positional argument for the body of the paper.

The template will initialize your package with a sample call to the `ludf`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typst
#import "@preview/solo-lu-df:2.0.0": *

#show: ludf.with(
  title: "Darba Nosaukums",
  authors: (
    (name: "Jānis Bērziņš", code: "jb12345", email: "jb12345@edu.lu.lv"),
  ),
  advisors: (
    (title: "Mg. dat.", name: "Ivars Ozoliņš"),
  ),
  reviewer: (title: "", name: "Prof. Anna Liepa"),
  submission-date: datetime(year: 2025, month: 1, day: 1),
  defense-date: datetime(year: 2025, month: 1, day: 15),
  place: "Rīga",
  bibliography: bibliography("bibliography.yml"),
  abstract: (
    primary: (text: [ Anotācijas teksts... ], keywords: ("Foo", "Bar")),
    secondary: (text: [ Abstract text... ], keywords: ("Foo", "Bar")),
  ),
)

// Your content goes here.

#bibliography-here()

= Pielikumi
#appendix(
  caption: "Attachment table",
  label: <table-1>,
  table(
    columns: (1fr, 1fr),
    [Column 1], [Column 2],
  ),
)
// or
#figure(
  caption: "Another table",
  kind: "appendix",
  table(
    columns: (1fr, 1fr),
    [Column 1], [Column 2],
  ),
) <table-2>
```

If you use `bibliography`, place `#bibliography-here()` exactly once.

## v2.0 Migration Guide

Apply these changes to your existing document:

1. Rename `attachment(...)` to `appendix(...)`.
2. Remove the `attachments` and `attachment-title` arguments from `ludf.with(...)`.
3. Move appendices into the document body instead of adding them through `attachments`.
4. Replace `date` with `submission-date` and `defense-date`.
5. Rename `display-documentary` to `show-documentary-page`.
6. Place `#bibliography-here()` exactly once where you want the references section to appear.
7. If you override abstract labels, rename `keyword-title` to `keywords-title`.
8. If you override labels, convert flat overrides to the new nested `labels` structure.

```diff
 #show: ludf.with(
-  date: datetime(year: 2025, month: 1, day: 1),
-  display-documentary: true,
+  submission-date: datetime(year: 2025, month: 1, day: 1),
+  defense-date: datetime(year: 2025, month: 1, day: 15),
+  show-documentary-page: true,
-  attachments: (
-    attachment(caption: "Attachment table", table()),
-  ),
 )
```

Appendix and bibliography placement in `v2.0.0`:

```typst
#bibliography-here()

= Pielikumi
#appendix(
  caption: "Attachment table",
  label: <label>,
  table(),
)
// same as
#figure(
  caption: "Attachment table",
  kind: "appendix",
  table(),
) <label>
```

## Examples

Ready-to-edit examples for different thesis types are included:

- **Qualification thesis**: [`examples/qualification-thesis/`](https://github.com/kristoferssolo/LU-DF-Typst-Template/tree/v2.0.0/examples/qualification-thesis)
- **Course work**: [`examples/course-work/`](https://github.com/kristoferssolo/LU-DF-Typst-Template/tree/v2.0.0/examples/course-work)
- **Bachelor thesis**: [`examples/bachelor-thesis/`](https://github.com/kristoferssolo/LU-DF-Typst-Template/tree/v2.0.0/examples/bachelor-thesis)
- **Master thesis**: [`examples/master-thesis/`](https://github.com/kristoferssolo/LU-DF-Typst-Template/tree/v2.0.0/examples/master-thesis)

Browse all examples on GitHub: <https://github.com/kristoferssolo/LU-DF-Typst-Template/tree/v2.0.0/examples>

The qualification thesis example contains `main.typ`, `bibliography.yml` and
small helpers under `utils/`. Use it as a starting point or copy it into a new
project.

## Tips

- Install the fonts used by the template (Times family, JetBrains Mono) to
  reproduce exact layout, or change font names in `src/lib.typ`. You can
  override font by setting [text font](https://typst.app/docs/reference/text/text#parameters-font) to your desired one.
- Bibliography: use Typst's `bibliography(...)` call with a YAML or Bib file.
- Diagrams: the example imports the fletcher package and includes small
  helpers under `examples/.../utils/`, but you can also use exported
    images from [draw.io (diagrams.net)](https://app.diagrams.net/) or any other diagram editor.

### Recommend packages

Depending on your thesis content, these Typst packages can pair well with this template:

- [`zero`](https://typst.app/universe/package/zero) or [`unify`](https://typst.app/universe/package/unify) for advanced scientific number and unit formatting, depending on which better fits your use case.
- [`fletcher`](https://typst.app/universe/package/fletcher) for diagrams.
- [`equate`](https://typst.app/universe/package/equate) for equation helpers.
- [`lilaq`](https://typst.app/universe/package/lilaq) for plots.
- [`lovelace`](https://typst.app/universe/package/lovelace) for flexible pseudocode and algorithms.
- [`codly`](https://typst.app/universe/package/codly) for better code listings.

## Locale Labels

Localized strings are stored in nested dictionaries. Override them through the
`labels` argument using the same structure as the built-in locale preset:

```typst
#show: ludf.with(
  locale: "en",
  labels: (
    title: (
      page: (
        advisors: (
          plural: "supervisors:",
        ),
      ),
    ),
    documentary: (
      page: (
        reviewer_label: "External Reviewer",
      ),
    ),
  ),
)
```

Common paths include:

- `labels.title.page.authors.singular`
- `labels.title.page.authors.plural`
- `labels.title.page.student_number.prefix.singular`
- `labels.title.page.student_number.prefix.plural`
- `labels.title.page.student_number.label`
- `labels.title.page.advisors.prefix`
- `labels.title.page.advisors.singular`
- `labels.title.page.advisors.plural`
- `labels.documentary.page.title`
- `labels.documentary.page.reviewer_label`
- `labels.abstract.primary.title`
- `labels.abstract.primary.keywords_title`
- `labels.abstract.secondary.title`
- `labels.abstract.secondary.keywords_title`
- `labels.bibliography.title`
- `labels.supplement.figure`
- `labels.supplement.table`
- `labels.supplement.appendix`

Partial nested overrides are supported, so you only need to provide the leaf
values you want to change.

For the full set of available labels, see [`src/locale.typ`](https://github.com/kristoferssolo/LU-DF-Typst-Template/blob/v2.0.0/src/locale.typ).

## Changelog

### v2.0.0

- **Breaking**: rename `attachment(...)` to `appendix(...)`.
- **Breaking**: remove the `attachments` and `attachment-title` arguments. Appendices now live directly in the document body.
- **Breaking**: replace `date` with `submission-date` and `defense-date`.
- **Breaking**: rename `display-documentary` to `show-documentary-page`.
- **Breaking**: place references explicitly with `#bibliography-here()`.
- Changed: clarify abstract roles and rename `keyword-title` to `keywords-title`.
- Added: locale presets via `locale` and nested label overrides via `labels`.
- Fixed: title-page author alignment, documentary authorized-person wording, appendix supplement localization, and appendix caption formatting.
- Docs: add nested locale override examples and optional Typst package suggestions.

### v1.1.2

- Fixed documentary page thesis-title normalization before rendering.
- Docs: pin example links to the tagged release.
- Chore: add GitHub issue templates.

### v1.1.1

- Added short `thesis-type` keys such as `"bachelor"`, `"course"`, and `"qualification"`.
- Added master thesis support plus bachelor-thesis and course-work examples.
- Improved the bachelor thesis documentary page.
- Fixed reviewer handling, title-page justification, and duplicate spacing in title content.
- Docs: refresh README examples and thumbnail.

### v1.0.0

- Added an embedded fallback font.
- Added the `description` field to the template and documented the reviewer example.
- Docs: document `outline-title` and `attachment-title`.
- Chore: clean up template internals and bump the version.

### v0.1.5

- Added attachments to the outline.
- Docs: document new fields, the `description` field, and PDF keyword metadata behavior.

### v0.1.4

- Refactored the documentary page.
- Fixed paragraph spacing.

### v0.1.3

- Added the `display-documentary` parameter.
- Docs: fix the package version in the README.

### v0.1.2

- Added sticky captions and heading behavior.
- Fixed documentary-page line breaks and typos.

### v0.1.1

- Fixed the submission date typo in `utils.typ`.
- Updated font sizes.

### v0.1.0

- Added the base template, qualification thesis example, documentary page, and attachment support.
- Improved figure and table captions, reference numbering, and reference supplements.
- Docs: add README files and advisor example fixes.

## License

This project is licensed under the MIT-0 License – see the [LICENSE](./LICENSE) file for details.
