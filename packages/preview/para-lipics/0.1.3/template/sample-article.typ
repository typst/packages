#import "@preview/para-lipics:0.1.3": *

#let abstract = lorem(39)

#show: para-lipics.with(
  title: [Dummy title],
  title-running: [Dummy short title],
  authors: (
    (
      name: [Jane Open Access],
      email: "johnqpublic@dummyuni.org",
      website: "http://www.myhomepage.edu",
      orcid: "0000-0002-1825-0097",
      affiliations: [
        Dummy University Computing Laboratory, [optional: Address], Country \
        My second affiliation, Country
      ],
    ),
    (
      name: [Joan R. Public#footnote[Optional footnote, e.g. to mark corresponding author]],
      email: "joanrpublic@dummycollege.org",
      orcid: "1234-1234-1234-1234",
      affiliations: [
        Department of Informatics, Dummy College, [optional: Address], Country
      ],
    ),
  ),
  author-running: [J. Open Access and J. R. Public],
  copyright: [Jane Open Access and Joan R. Public],
  ccs-desc: text(red)[Replace ccsdesc argument with valid one],
  abstract: abstract,
  keywords: [Dummy keyword],
  // category: [Invited paper],
  // related-version: [],
  // supplement: [],
  acknowledgements: [I want to thank...],
  funding: [
    _Jane Open Access_: (Optional) author-specific funding acknowledgements \
    _Joan R. Public_: [funding]
  ],
  line-numbers: true,
  // anonymous: true,
  // hide-lipics: true,
  // ============ EDITOR-ONLY ARGUMENTS ============ //
  event-editors: [John Q. Open and Joan R. Access],
  event-no-eds: 2,
  event-long-title: [42nd Conference on Very Important Topics (CVIT 2016)],
  event-short-title: [CVIT 2016],
  event-acronym: "CVIT",
  event-year: "2016",
  event-date: [December 24--27, 2016],
  event-location: [Little Whinging, United Kingdom],
  event-logo: [],
  series-volume: 42,
  article-no: 23,
)


= Typesetting instructions - Summary

LIPIcs is a series of open access high-quality conference proceedings across all fields in informatics established in cooperation with Schloss Dagstuhl.
In order to do justice to the high scientific quality of the conferences that publish their proceedings in the LIPIcs series, which is ensured by the thorough review process of the respective events, we believe that LIPIcs proceedings must have an attractive and consistent layout matching the standard of the series.
Moreover, the quality of the metadata, the typesetting and the layout must also meet the requirements of other external parties such as indexing service, DOI registry, funding agencies, among others.

The present document is an unofficial Typst reproduction of the LaTeX LIPIcs sample paper.
It uses the `para-lipics` template, which largely follows the official `lipics-v2021.cls` LaTeX style.


= Syntax

== Lists and Enumerations

- List bullet @SR14
- List bullet


+ Enumeration @HK15
  + Enumeration
  + Enumeration
+ Enumeration
  + Enumeration
  + Enumeration

== Figures, tables, and listings

#figure(block(fill: yellow, width: 10cm, height: 5cm), caption: [This is my figure])

#figure(
  table(
    columns: (1cm, 1fr, 1fr),
    [A], [2], [3],
    [B], [3], [4 @JM13],
    [C], [3], [4],
    [D], [3], [4],
    [E], [3], [4],
  ),
  caption: [Table],
)

#figure(
  ```python
  print("Hello")
  a = [1, 2, 3, 4]
  def foo(bar):
      print(bar)
  ```,
  caption: [My listing],
)

== Environments

#let content = lorem(21)

#theorem([My Theorem])[#content]

#proof[
#content
]

#lemma([My Lemma])[#content]

#corollary([My Corollary])[#content]

#definition([My Definition])[#content]

#observation[#content]



#bibliography("bibliography.bib")