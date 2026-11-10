// guide.typ — Getting Started with kinetic-kit
//
// This chapter is part of the template. Replace it with your own content.
// It demonstrates the most common Typst features you will use and explains
// the template-specific parameters you need to configure.
//
// Delete this file (and the #include "guide.typ" line in main.typ) once you
// no longer need it.

#import "@preview/kinetic-kit:0.2.1": flex-caption

= Getting Started with kinetic-kit

This document serves as both a starting point and a quick reference. It explains how to
configure the template and demonstrates the most common features: headings, figures,
tables, equations, code listings, and citations. Delete this chapter and add your own
content once you are ready.

== Configuring the Template

All configuration lives in the `#show: thesis.with(...)` call at the top of `main.typ`.

+ *Format:* `format` is the paper size --- `"a5"` (default, KSP's recommendation for
    doctoral theses), `"17x24"`, or `"a4"`. Font sizes and margins follow from it.
+ *Language:* Set `lang: "de"` or `lang: "en"`. This sets the text language --- driving
    hyphenation and quotation marks --- and the language of everything the template
    generates: the table of contents and list-page titles, chapter and section labels in
    cross-references, figure and table caption prefixes, and the draft watermark. The
    default title page is always in German regardless of this setting. For a section in
    the other language (e.g. a German Kurzfassung in an English thesis), wrap it in a
    block with its own `#set text(lang: …)`.
+ *Author and title:* Fill in `author-firstname`, `author-surname` and `title`. These also
    become the PDF metadata, so the title page takes them from here rather than repeating
    them.
+ *Title page:* Everything printed on the title page lives inside the
    `title-page: doctoral-title-page.with(...)` argument. Fill in `author-title` and
    `author-male` for the grammatical gender used on the German title page, and adjust
    `department`, `university-genitive`, `doc-degree` and `doc-degree-f` to match your
    faculty's official wording. Keep `status-approved: false` until your oral examination
    is scheduled; afterwards set it to `true` and fill in `exam-date`, `main-advisor` and
    `co-advisor`.
+ *Front and back matter:* `front-matter` and `back-matter` are ordinary content. Write
    each section --- Kurzfassung, Abstract, acknowledgements, a page of your own --- with
    its own `=` heading, in the order you want. Numbering is suppressed there, so a bare
    `= Danksagung` renders as an unnumbered section. Put Typst's own `outline()` in
    `front-matter` where the table of contents should appear, and the list pages ---
    `outline(target: figure.where(kind: image))` and friends --- plus your
    `bibliography(...)` in `back-matter`; the template styles and names them. An
    `appendix` argument sits between the two, numbered `A`, `A.1`, …
+ *Headings and figure kinds:* `serif-headings: true` sets headings in Libertinus Serif
    instead of Sans; `heading-numbering-depth` is the deepest numbered level (`3` =
    1.1.1). `figure-kinds` registers caption labels for kinds beyond figures, tables and
    listings --- see the comment on it in `main.typ`.
+ *Layout:* Choose `margin-preset` by page count: `"short"` (< 200 pages), `"medium"`
    (200--399), `"long"` (≥ 400). You may wanto add a `binding-correction` for the bound
    copy. Set `colored-links: false` before printing.
+ *Draft watermark:* the template ships with `draft: false`. Set `draft: true` while
    writing to stamp "ENTWURF" / "DRAFT" on every page, and back to `false` before
    submitting; `draft-info` adds an optional version string beside it.

== Writing Chapters

Headings in Typst use `=` signs. The template maps them as follows:

- `= Chapter Title` --- numbered chapter (1, 2, 3, …)
- `== Section Title` --- numbered section (1.1, 1.2, …)
- `=== Subsection Title` --- numbered subsection (1.1.1, …)

Write your chapters directly after the `#show: thesis.with(...)` call in `main.typ`, or
use `#include "chapter-name.typ"` to keep each chapter in its own file.

== Figures <sec:figures>

Use Typst's built-in `figure()` to insert figures. The template provides `flex-caption`
for cases where you want a short caption in the List of Figures and a longer one in the
body.

#figure(
    rect(width: 7cm, height: 3.5cm, fill: luma(235), stroke: 0.5pt),
    caption: flex-caption(
        short: [A placeholder figure.],
        long: [A placeholder figure demonstrating the use of `flex-caption`. The short
            caption appears in the List of Figures; this longer version appears here in
            the body.],
    ),
) <fig:placeholder>

Cross-reference the figure with `@fig:placeholder`, which renders as @fig:placeholder.

== Tables

Tables go inside `figure()` so they appear in the List of Tables and can be
cross-referenced.

#figure(
    table(
        columns: (1fr, auto, auto),
        inset: 6pt,
        align: (left, center, center),
        table.header([*Method*], [*RMSE*], [*Time (s)*]),
        [Baseline], [0.42], [1.2],
        [Proposed], [0.21], [1.5],
    ),
    caption: [Comparison of two methods.],
) <tab:comparison>

As shown in @tab:comparison, the proposed method reduces the RMSE by 50 %.

== Equations

Displayed equations are written between `$` signs on their own line. Add a label with
`<eq:name>` to enable cross-referencing.

$
    dot(bold(x)) = A bold(x) + B bold(u)
$ <eq:system>

@eq:system describes the continuous-time dynamics. Inline math uses single `$` signs: the
state vector $bold(x) in RR^n$.

== Code Listings

Code blocks inside `figure()` appear in the List of Listings, if you add
`#outline(target: figure.where(kind: raw))` to `back-matter` in `main.typ`.

#figure(
    ```python
    def runge_kutta_step(f, x, u, dt):
        k1 = f(x, u)
        k2 = f(x + 0.5 * dt * k1, u)
        k3 = f(x + 0.5 * dt * k2, u)
        k4 = f(x + dt * k3, u)
        return x + (dt / 6) * (k1 + 2*k2 + 2*k3 + k4)
    ```,
    caption: [Runge--Kutta integration step in Python.],
)

== Abbreviations

Abbreviations are just another front-matter section: add a heading and a list to the
`front-matter` block in `main.typ`. The simplest approach is a manually formatted list:

```typst
front-matter: [
  = List of Abbreviations
  / KIT: Karlsruher Institut für Technologie
  / KSP: KIT Scientific Publishing

  #outline()
],
```

For automatic first-use expansion (e.g. "Karlsruher Institut für Technologie (KIT)" on
first mention, "KIT" thereafter), the #link(
    "https://typst.app/universe/package/glossarium",
)[glossarium] package integrates well with the template. See the full example in
#link(
    "https://github.com/ll-nick/kinetic-kit/blob/main/examples/doctoral-full.typ",
)[`examples/doctoral-full.typ`]
in the repository.

== Citations and the Bibliography

Add your BibTeX entries to `refs.bib`. Cite with `@citekey`, for example
@mustermann2023control or @musterfrau2022deep. The bibliography is printed by the
`#bibliography("refs.bib", title: [Bibliography], style: "ieee")` line in the
`back-matter` block of `main.typ`; move it or add more `bibliography(...)` calls (e.g. a
separate list of your own publications) as needed.

The template uses the IEEE citation style by default. To switch to another style, change
`style: "ieee"` to another #link(
    "https://typst.app/docs/reference/model/bibliography/",
)[supported style].

== Submission Checklist

Before you submit, work through the following items in `main.typ`:

+ Replace the placeholder Kurzfassung and abstract in `front-matter` with your own.
+ Delete this `guide.typ` chapter and replace it with your actual content.
+ If you enabled draft mode, set `draft: false` to remove the watermark.
+ If approved: inside `title-page`, set `status-approved: true` and fill in `exam-date`,
    `main-advisor`, and `co-advisor`.
+ Update `margin-preset` to match your final page count (`"short"`, `"medium"`, or
    `"long"`).
+ A physical copy may require a `binding-correction`.
+ Set `colored-links: false` for the black-link print copy
