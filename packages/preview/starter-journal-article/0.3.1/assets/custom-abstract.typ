#import "@preview/starter-journal-article:0.3.1": article, author-meta

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
  keywords: ("Typst", "Template", "Journal Article"),
  template: (
    abstract: (abstract, keywords) => {
      show: block.with(
        width: 100%,
        stroke: (y: 0.5pt + black),
        inset: (y: 1em)
      )
      show heading: set text(size: 12pt)
      heading(numbering: none, outlined: false, bookmarked: false, [Abstract])
      par(abstract)
      stack(
        dir: ltr,
        spacing: 4pt,
        strong([Keywords]),
        keywords.join(", ")
      )
    }
  )
)

= Introduction

#lorem(20)
