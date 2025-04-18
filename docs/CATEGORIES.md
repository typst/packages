# Typst Package Categories

Categories help users explore packages, make finding the right one easier, and
provide package authors with a reference for best-practices in similar packages.
In addition to categories, packages can also specify a list of [disciplines]
describing their target audience.

Each package can declare itself a part of up to three categories.

There are two kinds of package categories: Functional categories that describe
what a package does on a technical level and publication categories that
describe for which kind of deliverable a package may be used.

Package authors are not required to pick a category from each of the two
groups. Instead, they can omit one group completely if it is not applicable to
their package, or use two categories for another group. Publication categories,
for example, are of big relevance to template packages and less so to a general
utility package that may apply to most publication kinds.

## Functional Categories

- **`components`:** Building blocks for documents. This includes boxes, layout
  elements, marginals, icon packs, color palettes, and more.
- **`visualization`:** Packages producing compelling visual representations of
  data, information, and models.
- **`model`:** Tools for managing semantic information and references. Examples
  could be glossaries and bibliographic tools.
- **`layout`:** Primitives and helpers to achieve advanced layouts and set up a
  page with headers, margins, and multiple content flows.
- **`text`:** Packages that transform text and strings or are focused on fonts.
- **`languages`:** Tools for localization and internationalization as well as
  dealing with different scripts and languages in the same document.
- **`scripting`:** Packages/libraries focused on the programmatic aspect of
  Typst, useful for automating documents.
- **`integration`:** Integrations with third-party tools and formats. In
  particular, this includes packages that embed a third-party binary as a
  plugin.
- **`utility`:** Auxiliary packages/tools, for example for creating
  compatibility and authoring packages.
- **`fun`:** Unique uses of Typst that are not necessarily practical, but
  always entertaining.

## Publication Categories

- **`book`:** Long-form fiction and non-fiction books with multiple chapters.
- **`report`:** A multipage informational or investigative document focused on
  a single topic. This category contains templates for tech reports, homework,
  proposals and more.
- **`paper`:** A scientific treatment on a research question. Usually published
  in a journal or conference proceedings.
- **`thesis`:** A final long-form deliverable concluding an academic degree.
- **`poster`:** A large-scale graphics-heavy presentation of a topic. A poster
  is intended to give its reader a first overview over a topic at a glance.
- **`flyer`:** Graphics-heavy, small leaflets intended for massive circulation
  and to inform or convince.
- **`presentation`:** Slides for a projected, oral presentation.
- **`cv`:** A résumé or curriculum vitæ presenting the author's professional
  achievements in a compelling manner.
- **`office`:** Staples for the day-to-day in an office, such as a letter or an
  invoice.

[disciplines]: https://github.com/typst/packages/blob/main/DISCIPLINES.md
