#import "@preview/starter-journal-article:0.3.3": article, author-meta

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
    author-info: (authors, affiliations) => {
      set align(center)
      show: block.with(width: 100%, above: 2em, below: 2em)
      let first_insts = authors.map(it => it.insts.at(0)).dedup()
      stack(
        dir: ttb,
        spacing: 1em,
        ..first_insts.map(inst_id => {
          let inst_authors = authors.filter(it => it.insts.at(0) == inst_id)
          stack(
            dir: ttb,
            spacing: 1em,
            {
              inst_authors.map(it => it.name).join(", ")
            },
            {
              set text(0.8em, style: "italic")
              affiliations.values().at(inst_id)
            }
          )
        })
      )
    }
  )
)

= Introduction

#lorem(20)
