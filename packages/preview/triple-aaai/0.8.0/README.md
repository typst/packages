# Association for the Advancement of Artificial Intelligence (AAAI)

*A template for main track, auxiliary tracks, and workshops.*

The `aaai` template uses the AAAI layout and the local `aaai.csl` bibliography
style based on the 2026 author kit. Rule `aaai2026` is an alias for
compatibility. Import `aaai` and the `appendix` show rule. Provide authors as a
tuple of author records and an affiliation dictionary:

```typst
#import "@preview/triple-aaai.typ:0.8.0": aaai, appendix

#show: aaai.with(
  title: [An Example Paper],
  authors: (
    (
      (name: "Ada Example", affl: "lab", email: "ada@example.org"),
      (name: "Bob Example", affl: ("lab", "other")),
    ),
    (
      lab: (institution: "Example University", country: "Example Country"),
      other: (institution: "Another University"),
    ),
  ),
  abstract: [The paper abstract.],
  accepted: false,
  bibliography: bibliography("main.bib"),
)

= Introduction
The paper body, with a citation @c:83.

#show: appendix

= Additional Results
The appendix appears before the references.
```

Option `accepted: false` anonymizes both the author block and PDF author
metadata. Use `accepted: none` for an identified preprint, or `accepted: true`
for the camera-ready author block and first-page copyright notice. The notice
uses the year from `pubdate`, then an explicit `date`, then the current date.
`date: none` omits the PDF creation date. The legacy `review` argument is
accepted but does not print an OpenReview banner.

Each affiliation value is a dictionary with named fields `department`,
`institution`, `location`, and `country`. An author's `affl` can be a single
affiliation key or a tuple of keys. Shared affiliations are printed once;
multiple affiliations use superscript numbers. Email addresses are optional.

Headings use `numbering: "1.1"` by default. Set `numbering: none` for
unnumbered sections, as in the author-kit example. Appendices use letters when
numbering is enabled. Ethical statements and acknowledgments remain unnumbered.
Place `#show: appendix` after the main text and before the appendix headings,
as in the example above. It resets section numbering to `A`, `B`, etc., with
subsections numbered `A.1`, `A.2`, etc. With `numbering: none`, appendix
headings remain unnumbered. References supplied to `aaai` appear after the
appendix. The `appendix:` template argument is also supported, and
`default-appendix` remains an alias for the show rule.

Third-level and deeper headings run into the following text. Keep that text on
the next source line without an empty line which starts a new paragraph as
follows.

```typst
=== Nonroman Fonts.
If your paper includes symbols in other languages, ...
```

Font overrides use `aux: (font-family: (serif: "Times New Roman"), font-size:
(normal: 10pt))`. Each dictionary is optional.

Run the rendering regressions with Python 3, Typst, and Poppler's `pdftotext`
and `pdfinfo` installed:

```sh
python3 aaai/tests/check.py
python3 aaai/tests/check.py --typst typst-0.13.1
```
