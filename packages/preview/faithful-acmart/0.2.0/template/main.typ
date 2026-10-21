#import "@preview/faithful-acmart:0.2.0": *

#show: acmart.with(
  format: "acmsmall",
  title: "Writing ACM papers with faithful-acmart",

  // These publication details are placeholders; use the values supplied by your venue.
  journal: "JACM",
  acm-volume: 1,
  acm-number: 1,
  acm-article: 1,
  acm-year: 2026,
  acm-month: 7,
  doi: "10.1145/nnnnnnn.nnnnnnn",
  copyright: "acmlicensed",

  authors: (
    (
      name: "Ada Lovelace",
      note: [Both authors contributed equally.],
      email: "ada@example.org",
    ),
    (
      name: "Charles Babbage",
      note: [Both authors contributed equally.],
      corresponding: true,
      email: "charles@example.org",
      // In a journal title block, an affiliation closes the group of authors above it.
      affiliation: (
        institution: "Analytical Engine Institute",
        city: "London",
        country: "UK",
      ),
    ),
  ),
  abstract: [
    This guide shows how to write an ACM-style paper with faithful-acmart.
    It explains the document settings and demonstrates headings, figures, tables, equations, citations, and theorems.
    Open its source file, main.typ, to copy or change an example.
  ],
  keywords: ("ACM", "Typst", "paper template"),
)

= Start your paper

Typst compiles a `.typ` text file into a PDF.
The faithful-acmart package supplies ACM journal and conference layouts, including author information, captions, and bibliography styles based on LaTeX acmart.

Edit the settings at the top of `main.typ`, then replace the text below them with your paper.
The companion file `refs.bib` holds bibliography entries.
Run `typst compile main.typ` to build the PDF with the command-line compiler.

Use Typst 0.14 or later and install the fonts listed in the #link("https://github.com/fzaiser/faithful-acmart")[package README] before compiling.

== The import and show rule

The first line imports the package; keep `*` to include its citation and bibliography functions.
The `#show: acmart.with(...)` rule applies the layout.
Keep one such rule and put your settings inside its parentheses.

In Typst, `#` introduces a function call or other code.
Use quotes for plain text, as in `title: "My paper"`, and square brackets for content that can include formatting, as in `abstract: [My summary.]`.

== Choose a format and add authors

Choose the format requested by your venue; @formats lists common choices.
This guide uses `format: "acmsmall"`.
If you omit `format`, the package uses `"manuscript"`.

Replace the sample names, email addresses, and affiliations in `authors`.
Every affiliation you supply needs a `country`.
The authors of this guide share an affiliation: in a journal title block, put it on the last author in the group.
Identical `note` values share a footnote mark.
Set `corresponding: true` on at most one author.

= Write the body

Write paragraphs as ordinary text, with a blank line between them.
Start a line with `=`, `==`, or `===` for a section, subsection, or third-level heading.
The package supplies the numbering, fonts, and spacing for the chosen format.

== Figures and references

Use `figure` to add a caption and number to an image or diagram, as in @compilation.

#figure(
  stack(
    dir: ltr,
    spacing: 8pt,
    box(inset: 6pt, stroke: 0.5pt)[main.typ],
    [→],
    box(inset: 6pt, stroke: 0.5pt)[Typst],
    [→],
    box(inset: 6pt, stroke: 0.5pt)[main.pdf],
  ),
  placement: none,
  caption: [Compiling a Typst source file produces a PDF.],
) <compilation>

Replace the diagram with `image("plot.png", width: 6cm)` to use your own image file.
The label `<compilation>` after the figure lets `@compilation` insert its number in the text.
Use the same label-and-reference pattern for tables and theorems.

=== Placing figures
Set `placement: none` to keep a figure with its explanation, as above, or `placement: top` to let it float to the top of a page or column.
This paragraph also demonstrates a third-level heading: to let the heading share a line with its paragraph, leave no blank line between them in the source.

== Tables

Use `tabular` inside `figure` for a numbered table with its caption above, as in @formats.

#figure(
  tabular(
    columns: 3,
    toprule(),
    [Format], [Columns], [Typical use],
    midrule(),
    [`manuscript`], [1], [Review manuscript],
    [`acmsmall`], [1], [Journal article],
    [`sigconf`], [2], [Conference paper],
    bottomrule(),
  ),
  placement: none,
  caption: [Three commonly used formats; the README lists all supported formats.],
) <formats>

Read the cells in the source from left to right, with three cells per row.
The rule helpers add horizontal lines and the spacing used by booktabs tables.
Pass `columns` directly to `tabular` so it can identify the header row.

== Equations, theorems, and proofs

Put math between dollar signs: `$n + 1$` produces $n + 1$.
Add spaces inside the dollar signs for a displayed equation; the proof below contains one.
Use `theorem` for a numbered statement and `proof` for its proof; the optional `name` gives the statement a name.

#theorem(name: "Sum of consecutive integers")[
  For every positive integer $n$, the sum of the integers from $1$ to $n$ is $n(n + 1) / 2$.
] <sum-theorem>

#proof[
  Let $S = 1 + 2 + dots + n$.
  Add this sum to the same terms in reverse order, pairing each term with its counterpart:
  $ 2S = (1 + n) + (2 + (n - 1)) + dots + (n + 1) = n(n + 1). $
  Divide by two.
]

Writing `@sum-theorem` produces @sum-theorem.
Numbers update when you insert or move statements and restart in each section.
Lemmas, definitions, and the other numbered theorem environments share the same counter.

= Cite sources

Replace the two example articles in `refs.bib` with your sources.
Each entry has a key, such as `Kahn1962`, that connects citations to the reference list.

Here are three ways to cite those entries:

- `@Kahn1962` gives a single citation: @Kahn1962.
- `@Kahn1962[p. 558]` adds a page number: @Kahn1962[p. 558].
- `#cite(<Kahn1962>, <Tarjan1972>)` groups sources: #cite(<Kahn1962>, <Tarjan1972>).

When an author's name belongs in the sentence, use `cite-text`.
For example, `#cite-text(<Kahn1962>)` produces #cite-text(<Kahn1962>).
The reference list at the end of this guide comes from `#bibliography("refs.bib")`.
Keep that call after the body of your paper.

References use ACM's BibTeX style by default.
Set `cite-style: "author-year"` on the show rule if your venue requests author–year citations.

= Prepare a submission

Use your venue's instructions to choose the format and review settings.
These options have separate effects:

- `anonymous: true` hides authors in the title and PDF author metadata, and suppresses content inside `acks`.
  Wrap identifying passages in `anon` to replace them in anonymous mode; other body text remains visible.
- `review: true` adds line and page numbers and uses acmart's review list spacing.

For example, `#anon[Our project website]` becomes “ANONYMIZED” in anonymous mode.

Replace the sample journal, volume, issue, article number, DOI, and copyright settings with the values supplied for your paper.
For conference papers, use `conference` and `booktitle` to describe the proceedings.
Set `nonacm: true` while trying the layout if you want to suppress ACM publication notices.

The README links to the full reference, including ACM classification concepts, translated abstracts, and publication notices.
Check your PDF after changing formats; TeX and Typst can produce different line and page breaks.

#acks[
  Put acknowledgments inside `acks`, as this paragraph is, so the package can omit them in anonymous mode.
]

#bibliography("refs.bib")
