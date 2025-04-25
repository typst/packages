#import "@preview/starter-journal-article:0.3.2": article, author-meta

#set page(margin: 12pt, width: 6in, height: 5in)

#show: article.with(
  title: "Artile Title",
  authors: (
    "Author One": author-meta("UCL", email: "author.one@inst.ac.uk"),
    "Author Two": author-meta("TSU")
  ),
  affiliations: (
    "UCL": "UCL Centre for Advanced Spatial Analysis, First Floor, 90 Tottenham Court Road, London W1T 4TJ, United Kingdom",
    "TSU": "Haidian  District, Beijing, 100084, P. R. China"
  ),
  abstract: [#lorem(20)],
  keywords: ("Typst", "Template", "Journal Article")
)

= Introduction

#lorem(20)
