## upcoming version

- 2026/06: less space around code blocks
  (Gabriel Scherer)

- 2026/06: increase the spacing of tight lists
  (Gabriel Scherer)

  Note: the space before a list depends on whether it is immediately
  after the previous paragraph or separated by a blank line. The LaTeX
  rendering corresponds to putting a blank line before every list, but
  you also have a more compact rendering if having the list part of
  the same paragram.
  
- 2026/09: change the definition of list bullets
  to fix a regression on newer Typst versions
  (0.15 at least is affected, with first-level bullets below their line).
  (Gabriel Scherer)

## version 0.2.0 (2026-05-12)

- 2026/06: improve the spacing of headings,
  in particular when a subsection follows a section
  (Gabriel Scherer)

- 2026/06: implement the 'review' option
  (Gabriel Scherer)

- 2026/06: all of the sample-acmsmall.tex file
  is now ported in tests/sample-acmsmall.typ
  (Gabriel Scherer)

- 2026/06: provide an 'appendix' function
  (Gabriel Scherer)

- 2026/06: provide an 'acknowledgments' function
  (Gabriel Scherer)

- 2026/06: improve the support for figures
  (Gabriel Scherer)

- 2026/06: better support for the ACM-recommended table style
  (Gabriel Scherer)

## version 0.1.0 (2026-05-08)

- 2026/06: change the API of 'acmart.with' to avoid SnakeCase
  identifiers, as required by the Typst package-repository linter
  checks.
  (Gabriel Scherer)

   ```typst
   /* Before: */
   #show: acmart.with(
     [...]
     acmJournal: "JACM",
     acmVolume: 37,
     acmNumber: 4,
     acmArticle: 111,
     acmYear: 2018,
     acmMonth: 8,
   )

   /* After: */
   #show: acmart.with(
     [...]
     publication: (
       journal: "JACM",
       volume: 37,
       number: 4,
       article-number: 111,
       year: 2018,
       month: 8,
     )
   )
   ```

   (Note the move from `acmArticle` to `article-number` to make the
   parameter meaning and intended value more self-descriptive.)

- 2026/05: support HTML output
  (Gabriel Scherer)

- 2026/05: support the 'anonymous' documentclass option

- 2026/05: improve the placement of code blocks
  (Gabriel Scherer)

- 2026/05: title page: support multiple affiliations for one author
  (Gabriel Scherer)

- 2026/05: improve rendering of lists
  (Gabriel Scherer)

- 2026/05: improve rendering of headings
  (uppercase titles for level 1; paragraph-style placement for levels 3 and 4)
  (Gabriel Scherer)

- 2026/05: support the 'nonacm' documentclass option
  (Gabriel Scherer)

- 2026/05: improve the rendering of `#quote`
  (Gabriel Scherer)

- 2026/05: the template does not enforce a bibliography style anymore,
  users should specify a `.csl` file in their document, for example:
  (Gabriel Scherer)

  ```typst
  set bibliography(style: "ACM-Reference-Format-author-year.csl")
  ```

## initial typst-acmart features

- a titlepage with a title, authors (and affiliations),
  CCS concepts and keywords, abstract
  (Michel Steuwer)

- support for providing journal/conference information (journal name, volume number etc.)
  (Michel Steuwer)

- a CSL presentation of the ACM reference author-year format
  ACM-Reference-Format-author-year.csl
  (Michel Steuwer)

- headers and footers for each page following ACM style
  (Michel Steuwer)
