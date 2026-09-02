// guide.typ — Getting Started with kinetic-kit
//
// This chapter is part of the template. Replace it with your own content.
// It demonstrates the most common Typst features you will use and explains
// the template-specific parameters you need to configure.
//
// Delete this file (and the #include "guide.typ" line in main.typ) once you
// no longer need it.

#import "@preview/kinetic-kit:0.1.1": flex-caption

= Getting Started with kinetic-kit

This document serves as both a starting point and a quick reference. It explains how to
configure the template and demonstrates the most common features: headings, figures,
tables, equations, code listings, and citations. Delete this chapter and add your own
content once you are ready.

== Configuring the Metadata

All document metadata lives in the `#show: dissertation.with(...)` call at the top of
`main.typ`. Open that file and work through the parameters in order:

+ *Author and degree:* Fill in `author-firstname`, `author-surname`, `author-title`, and
    set `author-male` to match the grammatical gender used on the German title page.
+ *Title:* Replace the placeholder in `title:` with your dissertation title.
+ *Department and degree name:* Adjust `department`, `university-genitive`, `doc-degree`,
    and `doc-degree-f` to match your faculty's official wording.
+ *Status:* Keep `status-approved: false` until your oral examination is scheduled.
    Afterwards set it to `true` and fill in `exam-date`, `main-advisor`, and `co-advisor`.
+ *Language:* Set `lang: "de"` or `lang: "en"`. This controls all auto-generated section
    headings (Table of Contents, List of Figures, etc.). The title page is always in
    German regardless of this setting.
+ *Layout:* Choose `margin-preset` based on your estimated page count: `"short"` for fewer
    than 200 pages, `"medium"` for 200–399, `"long"` for 400 or more. Add
    `binding-correction: 8mm` (or as specified by your print shop) for the physical bound
    copy.
+ *Draft watermark:* the template ships with `draft: false`. Set `draft: true` while
    writing to stamp "ENTWURF" on every page, and back to `false` before submitting.

== Writing Chapters

Headings in Typst use `=` signs. The template maps them as follows:

- `= Chapter Title` — numbered chapter (1, 2, 3, …)
- `== Section Title` — numbered section (1.1, 1.2, …)
- `=== Subsection Title` — numbered subsection (1.1.1, …)

Write your chapters directly after the `#show: dissertation.with(...)` call in `main.typ`,
or use `#include "chapter-name.typ"` to keep each chapter in its own file.

== Figures <sec:figures>

Use Typst's built-in `figure()` to insert figures. The template provides `flex-caption`
for cases where you want a short caption in the List of Figures and a longer one in the
body — a KSP recommendation for captions that would exceed one line in the LoF.

#figure(
    rect(width: 7cm, height: 3.5cm, fill: luma(235), stroke: 0.5pt),
    caption: flex-caption(
        short: [A placeholder figure.],
        long: [A placeholder figure demonstrating the use of `flex-caption`. The short
            caption appears in the List of Figures; this longer version appears here in
            the body.],
    ),
) <fig:placeholder>

Cross-reference the figure with `@fig:placeholder`, which renders as @fig:placeholder. If
your caption is short enough to fit on one line in the LoF, use a plain string in
`caption:` instead of `flex-caption`.

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

$ dot(bold(x)) = A bold(x) + B bold(u) $ <eq:system>

@eq:system describes the continuous-time dynamics. Inline math uses single `$` signs: the
state vector $bold(x) in RR^n$.

== Code Listings

Code blocks inside `figure()` appear in the List of Listings (if `show-lol: true` is set
in `main.typ`).

#figure(
    ```python
    def runge_kutta_step(f, x, u, dt):
        k1 = f(x, u)
        k2 = f(x + 0.5 * dt * k1, u)
        k3 = f(x + 0.5 * dt * k2, u)
        k4 = f(x + dt * k3, u)
        return x + (dt / 6) * (k1 + 2*k2 + 2*k3 + k4)
    ```,
    caption: [Runge–Kutta integration step in Python.],
)

== Abbreviations

Pass any content to the `abbreviations:` parameter in `main.typ` and the template will
render it under a translated section heading. The simplest approach is a manually
formatted list:

```typst
abbreviations: [
  / KIT: Karlsruher Institut für Technologie
  / KSP: KIT Scientific Publishing
],
```

For automatic first-use expansion (e.g. "Karlsruher Institut für Technologie (KIT)" on
first mention, "KIT" thereafter), the #link(
    "https://typst.app/universe/package/glossarium",
)[glossarium] package integrates well with the template. See the full example in
#link(
    "https://github.com/ll-nick/kinetic-kit/blob/main/examples/dissertation-full.typ",
)[`examples/dissertation-full.typ`]
in the repository.

== Citations and the Bibliography

Add your BibTeX entries to `refs.bib`. Cite with `@citekey`, for example
@mustermann2023control or @musterfrau2022deep. The bibliography is printed automatically
at the end of the document using the style and path configured in the `bibliography:`
parameter of `main.typ`.

The template uses the IEEE citation style by default. To switch to another style, change
`style: "ieee"` to another #link(
    "https://typst.app/docs/reference/model/bibliography/",
)[supported style].

== Submission Checklist

Before you submit, work through the following items in `main.typ`:

+ If you enabled draft mode, set `draft: false` to remove the watermark.
+ If approved: set `status-approved: true` and fill in `exam-date`, `main-advisor`, and
    `co-advisor`.
+ Update `margin-preset` to match your final page count (`"short"`, `"medium"`, or
    `"long"`).
+ Add `binding-correction: 8mm` (adjust to your print shop's specification) if you are
    submitting a physical copy.
+ Set `colored-links: false` for the black-link print copy required by KSP (keep
    `colored-links: true` for the digital version).
+ Replace the placeholder abstract texts with your own.
+ Delete this `guide.typ` chapter and replace it with your actual content.
