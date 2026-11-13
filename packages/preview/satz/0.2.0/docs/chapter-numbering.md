# Chapter numbers and references

Use `chapter-numbering` when figures, tables and equations should restart in
each chapter. The scope captures a fixed prefix in each element's numbering
function, so a reference from another chapter uses the target's prefix.

```typst
#import "@local/satz:0.2.0": report, chapter-numbering
#show: report.with(config: (
  headings: (h1-pagebreak: true),
))

#chapter-numbering(chapter: 1)[
  = Introduction
  See @results.
]

#chapter-numbering(chapter: 2)[
  = Results
  #figure(rect(width: 5cm, height: 2cm), caption: [Results.]) <results>
]
```

For appendix table/figure/equation prefixes, pass `appendix: true` and use
`chapter: 1` for A, 2 for B, and so on. The scope resets the native image,
table and equation counters. It does not change heading numbers, heading
counters or page numbers: prepare those separately for an appendix, or use
the book API's appendix policy.

Do not query `counter(heading).get()` inside a shared numbering function that
will also be evaluated at reference sites. A reference in chapter 5 to table
A.2 can otherwise render as 5.2. The function must capture the target chapter
when the element is created, rather than reading the caller's context later.

`headings.h1-pagebreak` defaults to false for compatibility with ordinary report
sections. Enabling it inserts a weak page break before level-one headings;
an existing page break or empty page start does not create an extra blank page.
It does not impose odd-page starts. Journal headings retain their existing policy.

The [renderable specimen](../examples/latex-parity/chapter-numbering.typ)
checks three scopes, native references across them and a numbered equation.
