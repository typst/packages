#import "@preview/starter-journal-article:0.3.2": article, author-meta

#let affiliations = (
  "UCL": "UCL Centre for Advanced Spatial Analysis, First Floor, 90 Tottenham Court Road, London W1T 4TJ, United Kingdom",
  "TSU": "Haidian  District, Beijing, 100084, P. R. China"
)

#let author-list(authors, template, affiliations: affiliations) = {
  stack(dir: ltr, spacing: 1em, ..authors.map(it => template(it)))
}

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
  affiliations: affiliations,
  abstract: [#lorem(100)],
  keywords: ("Typst", "Template", "Journal Article"),
  template: (
    title: (title) => {
      set align(left)
      set text(size: 1.5em, weight: "bold", style: "italic")
      title
    }
  )
)


= Section

#lorem(20)
