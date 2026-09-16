## Upcoming release (0.1.0?)

- 2025/06: change the API of 'acmart.with' to avoid SnakeCase
  identifiers, as required by the Typst package-repository linter
  checks.

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

- 2025/05: support HTML output
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
