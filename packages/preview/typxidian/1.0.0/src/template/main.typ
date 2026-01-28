#import "@preview/typxidian:1.0.0": *
#import "abbreviations.typ": abbreviations

#show: template.with(
  title: [TypXidian],
  subtitle: [A template for academic writing written in Typst],
  department: [Department of Computer Science],
  course: [Master of Science (Computer Science)],
  university: [University of Salerno],
  academic-year: [2024-2025],
  authors: ((name: "Mario Rossi", email: "mario@rossi.it", num: "Registration Number: XXXX"),),
  supervisors: ("Prof. Giuseppe Verdi", "Prof. Mario Bianchi"),
  is-thesis: true,
  thesis-type: [master thesis],
  abbreviations: abbreviations,
  abstract-alignment: center,
  chapter-alignment: right,
  bib: bibliography("bibliography.bib"),
  quote: quote(block: true, quotes: true, attribution: [Some wise guy], [#lorem(25)]),
  abstract: lorem(200),
)

= Welcome to TypXidian!

*TypXidian* is a template for academic writing, thought for theses, disserations and reports.
It has been developed to be customizable to make it adhere to your specific requirements with ease.

#info(
  [
    TypXidian is based, both on color palette and functionalities, on #link("https://obsidian.md")[Obsidian]
    and "Alice in a Differentiable Wonderland" by Simone Scardapane @scardapane2024alicesadventuresdifferentiablewonderland.
    A twin LaTeX version of TypXidian is available at: #link("https://github.com/robertodr01/LaXidiaN")[LaXidiaN].
  ],
  title: "About TypXidian",
)

The purpose of this document is to act both as a showcase and as documentation of the template.

== Bundled Packages <sec:packages>
TypXidian comes with the following packages pre-included:

- `cetz:0.4.2`;
- `cetz-plot:0.1.3`;
- `plotsy-3d:0.2.1`;
- `booktabs:0.0.4`;
- `wrap-it:0.1.1`;
- `subpar:0.2.2`;
- `fontawesome:0.6.0`;
- `decasify:0.10.1`;
- a _custom_ version of `acrostiche:0.6.0`;

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

TypXidian offers two chapter heading styles: "basic" and "wonderland". You can set it by setting the `chapter-style` parameter. Below there is a comparison between the two styles:
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


You can customize the alignment of first-level headings (including table of contents) through the `chapter-alignment` parameter. The abstract, introductiom and acknowledgment pages headings can be aligned through the `abstract-alignment` parameter.

=== Front Matter

This section is dedicated to explaining how to customize the front matter of the template.

==== Cover Page

The cover page is highly customizable and it supports a: _authors-only_ view and _supervisors_ view.

The authors-only view is thought for reports, notes and similar documents, while the supervisor view
should be used for more formal documents such as theses and disseratations. Both view are displayed in @fig:viewmodes.

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
      image("./figures/authors-view.png"),
    ),
    caption: [Supervisors view.],
  ),
  caption: [Cover page view modes.],
  label: <fig:viewmodes>,
)

The authors-only view is triggered when the `supervisor` parameter is left empty. The `authors` parameter
can be either an array of strings or an array of dictionaries. In the latter case, fields will be displayed in
insertion order. Fields are discarded.
#parbreak()
Additional customization can be done via the following parameters:
- `university`: name of the university;
- `logo`: university logo (defaults to `src/preview/figures/logo.svg`);
- `logo-width`: logo width (defaults to `110pt`);
- `academic-year`: the academic year, e.g. *2024/2025* (defaults to `none`);
- `department`: the department name (defaults to `none`);
- `course`: the course you are enlisted to (defaults to `none`);
- `is-thesis`: if `true`, the “AUTHOR(S)” label changes to “CANDIDATE(S)” (defaults to `false`).
- `thesis-type`: arbitrary string that will be displayed in uppercase above the title (defaults to `none`).

==== Miscellaneous

You can add additional content before the main body by passing the `abstract`, `citation`, `introduction` and
`acknowledgments` parameters. If populated, the template will add these pages _before_ the table of contents. The title alignment for these pages can be customized through the `abstract-alignment` parameter.

Additionally, you can populate the `before-content` and `after-content` parameters to add _any_ additional
content _before_ the abstract and _after_ the bibliography (e.g., declaration of originality for PhD theses or
an appendix).


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

= Custom Environments

#tip(
  [
    All custom environments listed in this chapter are referencable like any other figure enviorment.
  ],
  title: "Referencing",
)

== SubFigures

TypXidian uses the `subpar` package (@sec:packages). To ensure consistent numbering of subfigures,
you must use the `subfigure(...args)` function. Its use is the same as `subpar.grid()`. For instance,
the following code:
```typ
#subfigure(
  columns: (1fr, 2fr),
  figure(
    image("assets/dog.jpg"),
    caption: [This is a dog.]
  ),
  <dog>,
  figure(
    image("assets/cat.jpg"),
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

== No Numbered Equations
Sometimes you have the need to write block equations with no numbering. TypXidian provides a built-in function
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
  [This is a paragraph. This is still a pargraph: #lorem(25). Still a paragraph!!],
  title: "LaTeX like paragraph",
)
== Text and Math Callouts

As anticipated, TypXidian is inspired by Obisidian. All main obsidian's callouts are available in the template
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

TypXidian also provide math callouts, mimicing "Alice in a Differentiable Wonderland" boxes. Specifically,
you can use: `definition`, `theorem` and `proof` callouts.
The `definition` and `theorem` callouts share the same signature:
```typ
  body,
  title: "Definition",
  supplement: [Definition.],
```
while the proof box replaces the `title` parameter with the `of` parameter to reference the correspective theorem.

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

