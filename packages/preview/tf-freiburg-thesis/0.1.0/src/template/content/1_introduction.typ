#import "@preview/tf-freiburg-thesis:0.1.0": *


= Introduction <intro>

This starter thesis demonstrates the Faculty of Engineering Freiburg thesis template and gives you a compact place to try the most common writing patterns before replacing the example text with your own work.

The template keeps the thesis structure close to a traditional book layout while using Typst's fast preview and readable markup. In the default mirrored book layout, 
#sidenote[
  Sidenotes are unnumbered by default. This keeps the margin quiet when the note is only a local aside.
] sidenotes appear in the outer page margin, which is useful for short comments, source hints, or reminders that should stay visually connected to a sentence.

If a sidenote should be referenced from the main text, keep a visible marker by setting `numbered: true`.
#sidenote(numbered: true)[
  This note is numbered, so the marker in the text and the marker in the margin match.
] Numbered sidenotes are useful when the exact note matters for the argument rather than acting as background context.

For one-sided drafts or a more conventional layout, set `mirror-book: false` in `thesis.with(...)`. In that mode, the same `#sidenote[...]` calls are rendered as regular footnotes, so you can switch between margin notes and footnotes without rewriting chapter content.
#sidenote()[
  This note is not numbered, so there is no marker in the text.
]

By the end of this tutorial#footnote()[
  This note is a footnote, so it appears at the bottom of the page and is automatically numbered.
], you should be familiar with the template's thesis structure, front matter, citations, cross-references, mathematical formulas, figures, tables, and draft helpers.
