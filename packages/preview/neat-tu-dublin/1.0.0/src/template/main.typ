#import "@preview/neat-tu-dublin:1.0.0": *
#import "abbreviations.typ": abbreviations

#show: template.with(
  title: [Neat-TU-Dublin],
  subtitle: [A Typst template for TU Dublin reports],
  department: [School of Computer Science],
  course-code: [TU123],
  course: [BSc in Special Course],
  university: [Technological University Dublin],
  authors: (
    (
      name: "Max Mustermann",
      num: "C12345678",
    ),
  ),
  // This comma at the end is vital or it will not compile as it does not stay as an array
  supervisors: ("Dr. Serious Person",),
  declaration-signature: "./template/figures/signature.png",
  is-thesis: true,
  thesis-type: [Project Report],
  abbreviations: abbreviations,
  abstract-alignment: left,
  chapter-alignment: right,
  bib: bibliography("bibliography.bib"),
  abstract: lorem(200),
  acknowledgments: [#lorem(50)],
  appendix-ai: (
    report-writing: (
      "No AI was used to create this template!",
      "But you might use AI for yours."
    ),
    research: (),
    design: (),
    coding: (),
    other: ()
  )
)


= Welcome to Neat-TU-Dublin!

*Neat-TU-Dublin* is a template for academic writing, designed for theses, dissertations, and reports at TU Dublin.

#info(
  [
    Neat-TU-Dublin is built from Angelo Nazzaro's #link("https://github.com/angelonazzaro/typxidian")[Typxidian] template@typxidian.
    It draws its colour palette from TU Dublin's brand guidelines.
  ],
  title: "About Neat-TU-Dublin",
)

The purpose of this document is to act both as a showcase and as documentation of the template.

== Bundled Packages <sec:packages>
Neat-TU-Dublin comes with the following packages pre-included:

- `cetz:0.4.2`;
- `cetz-plot:0.1.3`;
- `booktabs:0.0.4`;
- `wrap-it:0.1.1`;
- `subpar:0.2.2`;
- `fontawesome:0.6.0`;
- `decasify:0.11.3`;
- `codly:1.3.0`;
- `codly-languages:0.1.10`;
- a custom local version of `acrostiche`.

Optional dependency in `dependencies.typ`:
- `plotsy-3d:0.2.1` (currently commented out).

All functionalities can be accessed directly from the template.

#danger(
  [
    Typst does not currently support _textual inclusion_, meaning that you can use only dependencies
    directly imported in the current file. For this reason, if you plan to split your document into
    standalone chapters, you must include the package in each file to access its functions.],
  title: "Working with Chapters",
)

== Template Structure

The template separates each chapter (first level heading) with one or two blank pages. Each new chapter starts
on an odd page. You may customize the 'Chapter' supplement by overwriting the `chapter-supplement` parameter.

Neat-TU-Dublin offers two chapter heading styles: "basic" and "wonderland". You can set it by setting the `chapter-style` parameter. Below there is a comparison between the two styles:
#subfigure(
  columns: (1fr, 1fr),

  figure(
    block(
      stroke: 1pt + black,
      image("./figures/basic.png"),
    ),
    caption: [Basic style.],
  ),
  figure(
    block(
      stroke: 1pt + black,
      image("./figures/wonderland.png"),
    ),
    caption: [Wonderland style.],
  ),
  caption: [Basic vs Wonderland chapter heading styles.],
)


You can customize the alignment of first-level headings (including table of contents) through the `chapter-alignment` parameter. The abstract, introduction and acknowledgment page headings can be aligned through the `abstract-alignment` parameter.

=== Front Matter

This section is dedicated to explaining how to customize the front matter of the template.

==== Cover Page

The cover page is highly customizable and supports an _authors-only_ view and a _supervisors_ view.

The authors-only view is designed for reports, notes and similar documents, while the supervisors view
is intended for more formal documents such as theses and dissertations. Both views are displayed in @fig:viewmodes.

#subfigure(
  columns: (1fr, 1fr),
  placement: auto,
  figure(
    block(
      stroke: 1pt + black,
      image("./figures/authors-view.png"),
    ),
    caption: [Authors only view.],
  ),
  figure(
    block(
      stroke: 1pt + black,
      image("./figures/supervisors-view.png"),
    ),
    caption: [Supervisors view.],
  ),
  caption: [Cover page view modes.],
  label: <fig:viewmodes>,
)

The authors-only view is triggered when the `supervisors` parameter is left empty. The `authors` parameter
can be either an array of strings or an array of dictionaries. In the latter case, fields will be displayed in
insertion order. Fields are discarded.
#parbreak()
Additional customization can be done via the following parameters:
- `university`: name of the university - Defaults to TU Dublin;
- `logo`: university logo (defaults to `src/figures/logo.svg`);
- `logo-width`: logo width (defaults to `150pt`);
- `department`: the department name (defaults to `none`);
- `course`: the course you are enlisted to (defaults to `none`);
- `course-code`: the CAO course code you are enlisted to (defaults to `none`);
- `is-thesis`: if `true`, the thesis type is emphasized on the cover (defaults to `false`);
- `thesis-type`: arbitrary string that will be displayed in uppercase above the title (defaults to `none`).

==== Declaration

Since most reports in TU Dublin require a declaration, the text has already been added.
To sign this, you must populate the `declaration-signature` parameter.

\
The date under the signature and the cover page are filled by today's date automatically, but can be set through the `date` parameter.

==== Miscellaneous

You can add additional content before the main body by passing the `abstract`, `quote`, `introduction` and
`acknowledgments` parameters. If populated, the template will add these pages _before_ the table of contents. The title alignment for these pages can be customized through the `abstract-alignment` parameter.

Additionally, you can populate `before-content` and `after-content` to add _any_ additional
content _before_ the abstract and _after_ the bibliography. For AI usage disclosure, use
the `appendix-ai` template argument with the sections `report-writing`, `research`, `design`, `coding`, and `other`.
#pagebreak()

=== Fonts

You can customize both the main font and math font through the `font` and `math-font` parameters respectively.
Also, you can set custom font sizes by passing a dictionary to the `font-sizes` parameter. The default font sizes used
are the following:
```typ
#let sizes = (
  chapter: 26pt,
  section: 18pt,
  subsection: 16pt,
  subsubsection: 14pt,
  subsubsubsection: 12pt,
  body: 11pt,
)```
Note that the dictionary passed to the `font-sizes` parameter must have the same fields as above.

=== Links, citations and References

You can customize links, citations and references appearance.
Citations are customizable through the `citation-style` and `cite-color` parameters.
For links and references you can customize their color through the `link-color` and `ref-color` parameters respectively.

=== Table of Contents and Numbering

Figures, tables, equations and custom environments numbering is dependent on the current chapter. For instance,
a figure under the first chapter will be numbered as 'Figure 1.x' and so on. The counter resets on each chapter.

The table of contents contains dynamic list of figures, tables, definitions and theorems meaning that they will be
rendered only if there is at least one element.
#pagebreak()

= Custom Environments

#tip(
  [
    All custom environments listed in this chapter are referenceable like any other figure environment.
  ],
  title: "Referencing",
)

== SubFigures

Neat-TU-Dublin uses the `subpar` package (@sec:packages). To ensure consistent numbering of subfigures,
you must use the `subfigure(...args)` function. Its use is the same as `subpar.grid()`. For instance,
the following code:
```typ
#subfigure(
  columns: (1fr, 2fr),
  figure(
    image("./figures/dog.jpg"),
    caption: [This is a dog.]
  ),
  <dog>,
  figure(
    image("./figures/cat.jpg"),
    caption: [This is a cat.]
  ),
  <cat>,
  caption: [This is a figure with subfigures.],
  label: <fig:example>
)
```
will output the following subfigure:

#subfigure(
  columns: (1fr, 2fr),
  figure(
    image("./figures/dog.jpg", width: 100pt),
    caption: [This is a dog.],
  ),
  <dog>,
  figure(
    image("./figures/cat.jpg", width: 200pt),
    caption: [This is a cat.],
  ),
  <cat>,
  caption: [This is a figure with subfigures.],
  label: <fig:example>,
)

== Wide Tables

Use `widetable(..args)` for full-width styled tables. It wraps `table` and adds a final spanning row so the table reliably occupies the full text width.

Typst tables do not fill the width of the page by default. The `widetable()` method can be used for pre-styled tables that take up the full width of the page and alternate highlighted rows for easier visibility.

```typ
#figure(
  widetable(
    columns: (1fr, 2fr, 1fr),
    table.header([Component], [Purpose], [Source]),
    [Cover page], [Generates the title page layout], [pages/cover.typ],
    [Table of contents], [Renders TOC entries up to depth 3], [pages/toc.typ],
    [AI appendix], [Prints grouped AI prompt disclosures], [pages/appendixAi.typ],
  ),
  caption: [Example wide table in Neat-TU-Dublin.],
  kind: table,
  supplement: [Table],
)
```

#figure(
  widetable(
    columns: (1fr, 2fr, 1fr),
    table.header([Component], [Purpose], [Source]),
    [Cover page], [Generates the title page layout], [pages/cover.typ],
    [Table of contents], [Renders TOC entries up to depth 3], [pages/toc.typ],
    [AI appendix], [Prints grouped AI prompt disclosures], [pages/appendixAi.typ],
  ),
  caption: [Example wide table in Neat-TU-Dublin.],
  kind: table,
  supplement: [Table],
)

== Code Blocks
Due to the inclusion of the `codly` packages, code blocks are improved from standard Typst ones. Certain syntax highlighting is supported, as well as line numbers. Refer to the #link("https://typst.app/universe/package/codly/", "Codly Docs") for how to use these fully.

== Acronyms

The custom version of Acrostiche developed for Typxidian and included in Neat-TU-Dublin allows you to define acronyms and then consume them later, which hyperlink to the relevant abbreviation in the table of abbreviations.

The first time an acronym appears, i.e. #ac("UI"), it appears fully and provides the acronym. In future occurrences, #ac("UI"), it uses just the acronym with a link to the table. If you create an array in the abbreviations, you can add support for acronym plurals, i.e. #acp("UI").

The bullet pointing only occurs if it can match the words to the abbreviation, for example, #ac("2FA") will not bold as the word `two` can not be connected to the number `2`, the remainder of Acrostiche's features are supported.

== No Numbered Equations
Sometimes you have the need to write block equations with no numbering. Neat-TU-Dublin provides a built-in function
so that you don't have to manually set the numbering to `none` when writing such equations. All you have
to do is call the `equation(content, numbering: false)` function. For instance,
`#equation($ sigma(x) = frac(1,1 + exp(-x)) $)` will display:

#equation($ sigma(x) = frac(1, 1 + exp(-x)) $)

== Paragraphs

The `paragraph(body, title: "", kind: "par", supplement: "Paragraph")` function mimics LaTeX's `\paragraph{}` command. For instance, the following code:
```typ
#paragraph([This is a paragraph], title: "LaTeX like paragraph")
```

#paragraph(
  [This is a paragraph. This is still a paragraph: #lorem(25) Still a paragraph!!],
  title: "LaTeX like paragraph",
)
#pagebreak()

== Text and Math Callouts

As anticipated, Neat-TU-Dublin's parent, Typxidian is inspired by Obsidian. The main Obsidian callouts are available in the template
through the following functions: `info`, `danger`, `success`, `tip`, `faq`.

All functions share the same signature, we will report only the `info` signature:
```typ
    title: "Info",
    icon: fa-icon("info-circle"),
    fill: colors.info.bg.saturate(5%),
    title-color: colors.info.title,
    supplement: [Info],
```
Below is a showcase of each callout:

#info([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $

  #acr("AI"): #lorem(10)
])
#faq([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $

  #acr("ML"): #lorem(10)
])
#tip([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $

  #acr("ANN"): #lorem(10)
])
#success([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $

  #acr("AF"): #lorem(10)
])
#danger([
  #lorem(25)

  $ x + y = integral_0^inf x y d x $

  #lorem(10)
])

Neat-TU-Dublin also provides math callouts, mimicking "Alice in a Differentiable Wonderland" boxes. Specifically,
you can use: `definition`, `theorem` and `proof` callouts.
The `definition` and `theorem` callouts share the same signature:
```typ
  body,
  title: "Definition",
  supplement: [Definition.],
```
while the proof box replaces the `title` parameter with the `of` parameter to reference the corresponding theorem.

#definition([
  #lorem(20)

  $ x + y = 1 $
])

#theorem([
  #lorem(20)

  $ x + y = 1 $
])
<th-1>

#proof(
  [
    #lorem(20)

    $ x + y = 1 $
  ],
  [@th-1],
)

== Appendix Subsection
Depending on the `chapter-numbering` parameter, the appendix will show the relative numbering for sections automatically.

The environment also handles the template's page header so to avoid showing a ghost chapter in the title. This is visible on the top of the @appendix_subsubsection page, where an example of how to correctly show the numbering for subfigures is also given.

#pagebreak()

When using the `#figure` environment, the template automatically takes care of the numbering. The `#subfigure` environment however requires additional help, as it uses `subpar.grid` underneath which is not aware of the prefix change.

To correctly display a `#subfigure` so that its numbering is coherent with the chapter, one must pass the "prefix" parameter (using @fig:example as reference):

```typ
#subfigure(
  columns: (1fr, 2fr),
  figure(
    image("./figures/dog.jpg"),
    caption: [This is a dog.]
  ),
  <dog>,
  figure(
    image("./figures/cat.jpg"),
    caption: [This is a cat.]
  ),
  <cat>,
  prefix: "A",
  caption: [This is a figure with subfigures.],
  label: <fig:example2>
)
```
will output the following subfigure having coherent prefix with the Appendix:

#subfigure(
  columns: (1fr, 2fr),
  figure(
    image("./figures/dog.jpg", width: 100pt),
    caption: [This is a dog.],
  ),
  <dog>,
  figure(
    image("./figures/cat.jpg", width: 200pt),
    caption: [This is a cat.],
  ),
  <cat>,
  prefix: "A",
  caption: [This is a figure with subfigures, but in the Appendix.],
  label: <fig:example2>,
)

#linebreak()

The `prefix` parameter allows figures, tables and similar environments to also be correctly displayed in the Table of Contents.

#pagebreak()

=== Appendix Subsubsection
<appendix_subsubsection>
Example of a subsubsection and of the page header being appropriately set for the Appendix environment.
