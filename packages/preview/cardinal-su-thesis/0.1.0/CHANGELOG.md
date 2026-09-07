# Changelog

## 0.1.0

Initial release.

- Stanford Ph.D. dissertation and Engineer thesis layout, built to the Office of
  the University Registrar's published format requirements, with a
  clause-by-clause mapping in `REQUIREMENTS.md`.
- Title page generated from `degree` and `department`/`program`, matching the
  official Ph.D. and Engineer sample wording exactly, with `title-page-lines`
  for the GSB, GSE, Law (J.S.D.), and D.M.A. variants.
- Preliminary pages in Roman numerals with the Abstract on iv, Arabic numbering
  restarting at 1 at the first chapter, in one consistent position throughout.
  `blank-page-iv` opts in to the double-sided variant that moves it to v.
- One-and-a-half line spacing by default, measured at 1.502× the font size.
- Chapter-prefixed figures, tables, and equations with per-chapter counter
  resets, plus supplementary notes, supplementary table stubs, and numbered
  methods subsections.
- Running heads with an abbreviation hook for long chapter titles.
- Example document covering abstract, acknowledgements, preface, introduction, a
  feature-complete chapter, conclusions, appendix, and bibliography.
- `table-supplement` for the label on `table` figures, and table captions set
  above the table body.
- `tests/check.py`, asserting 35 properties of the compiled PDF and parsing the
  README's Typst snippets.
