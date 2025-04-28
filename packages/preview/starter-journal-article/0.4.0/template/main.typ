#import "@preview/starter-journal-article:0.4.0": article, author-meta

#show: article.with(
  title: "Article Title",
  authors: (
    "Author One": author-meta(
      "UCL", "TSU",
      email: "author.one@inst.ac.uk",
    ),
    "Author Two": author-meta(
      "TSU",
      cofirst: true
    ),
    "Author Three": author-meta(
      "TSU"
    )
  ),
  affiliations: (
    "UCL": "UCL Centre for Advanced Spatial Analysis, First Floor, 90 Tottenham Court Road, London W1T 4TJ, United Kingdom",
    "TSU": "Haidian  District, Beijing, 100084, P. R. China"
  ),
  abstract: [#lorem(100)],
  keywords: ("Typst", "Template", "Journal Article")
)

= Section

#lorem(20) @netwok2020

== Subsection

#lorem(50)

=== Subsubsection

#lorem(80)

#bibliography("./ref.bib")
