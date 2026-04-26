#import "@preview/juti:0.0.1"

#let authors = (
  (
    name: [First A. Author],
    short: [First A. Author],
    institution-ref: 0,
    email: [first.author\@email.com],
    contribution-refs: (0, 1, 2, 5, 6, 7, 8, 10, 13),
  ),
  (
    name: [Second B. Author],
    short: [Second B. Author],
    institution-ref: 0,
    email: [second.author\@email.com],
    contribution-refs: (6, 9, 11),
  ),
  (
    name: [Third C. Author],
    short: [Third C. Author],
    institution-ref: 1,
    email: [third.author\@email.com],
    contribution-refs: (3, 4, 6, 9, 11, 12),
  ),
)

#show: juti.template.with(
  title: [
    Preparation of Papers for JUTI (JURNAL ILMIAH TEKNOLOGI INFORMASI)
  ],
  authors: authors,
  corresponding-ref: 0,
  institutions: (
    (
      name: [Department and institution name of authors],
      address: [Address of institution],
    ),
    (
      name: [Department and institution name of authors],
      address: [Address of institution],
    ),
  ),
  abstract: [
    These instructions give you guidelines for preparing JUTI (Jurnal Ilmiah Teknologi Informasi) papers. Use this document as a template if you are using Microsoft Word 6.0 or later. The electronic file of your paper will be formatted further by JUTI editorial board. Paper titles should be written in uppercase. Avoid writing long formulas with subscripts in the title; short formulas that identify the elements are fine (e.g., "Nd--Fe--B"). Do not write “(Invited)” in the title. Full names of authors are preferred in the author field but are not required. If you have to shorten the author’s name, leave first name and last name unshorten. Put a space between authors’ initials. Do not cite references in the abstract. The length of abstract must between 150 -- 250 words.
  ],
  keywords: (
    [Keyword1],
    [keyword2],
    [keyword3],
    [keyword4],
  ),
  bib: bibliography("references.bib"),
)

= Introduction

Example of citation @abbas2009automatic, or multiple citations @abbas2009automatic @yuhana2022automatic. #lorem(100)

= Literature Review

#lorem(100)
Table example can be seen on @tab-example.
Image example can be seen on @img-example.
The Schrodinger's famous equation can be seen on @eq-example.

#let hbar = (sym.wj, move(dy: -0.08em, strike(offset: -0.55em, extent: -0.05em, sym.planck)), sym.wj).join()
$ i hbar (diff Psi(x, t)) / (diff t) = -frac(hbar^2, 2m) nabla^2 Psi(x, t) + V(x) Psi(x, t) $ <eq-example>

#figure(
  table(
    columns: 4,
    table.hline(),
    table.header([*No*], [*Year*], [*Climate Change Event*], [*Impact*]),
    table.hline(),
    [1], align(left)[1988], align(left)[Establishment of the IPCC], align(left)[Increased global awareness and scientific assessments],
    [2], align(left)[1997], align(left)[Kyoto Protocol Adopted], align(left)[Legally binding emission reduction targets for developed countries],
    [3], align(left)[2015], align(left)[Paris Agreement Signed], align(left)[Global commitment to limit warming below 2°C],
    [4], align(left)[2021], align(left)[COP26 Held in Glasgow], align(left)[Strengthened climate targets and financial commitments],
    [5], align(left)[2009], align(left)[Copenhagen Accord], align(left)[Pledged climate finance of \$100 billion per year],
    [6], align(left)[2007], align(left)[IPCC Fourth Assessment Report], align(left)[Highlighted human influence on climate change],
    [7], align(left)[2018], align(left)[IPCC Special Report on 1.5°C], align(left)[Urgent need for emission reductions to avoid severe impacts],
    table.hline(),
  ),
  caption: [Table example.],
) <tab-example>

#figure(
  image("figure1.jpg", width: 40%),
  caption: [Logo of JUTI: Jurnal Ilmiah Teknologi Informasi. Note that #quote[Fig.] is abbreviated. There is a period after the figure number, followed by two spaces. It is good practice to explain the significance of the figure in the caption.],
) <img-example>

#lorem(100)

#lorem(100)

#lorem(100)

#set heading(numbering: none)

= CRediT authorship contribution statement

#authors.map(author => [*#author.short:* #juti.get-contributions(author).]).join([ ])

= Declaration of competing interest

The authors declare that they have no known competing financial interests or personal relationships that could have appeared to influence the work reported in this paper.

= Acknowledgement (optional)

This research was funded by ...

= Data availability

Please choose the appropriate data availability statement that applies to this study. If none apply, provide a custom statement.
- The data used to support the findings of this study are available from the corresponding author upon request.
- All relevant data are within the manuscript and its supporting information files.
- The dataset was openly provided [link provided].
- Data sharing is not applicable to this article as no datasets were generated or analyzed during the current study.
- Data sharing is not applicable as the data are secondary data drawn from already published literature.
- The datasets generated during and/or analyzed during the current study are available from the corresponding author on reasonable request.
- Following acceptance and before publication, all data will be provided on a public repository.
- No data are available.
