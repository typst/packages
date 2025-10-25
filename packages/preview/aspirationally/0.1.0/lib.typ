#import "@preview/blinky:0.2.0": link-bib-urls

#let aspirationally(
  name: [Laurenz Typsetterson],
  title: [Research Statement],
  current-department: [Department of Literary Studies],
  has-references: false,
  bib-references: "./references.bib",
  bib-style: "style.csl",
  logo: image("school-logo.png", height: 0.6in),
  leader: [],
  body
) = {
  let subsidiarytextsize = 8pt;

  show link: it => { text(fill: rgb("#2563eb"))[#it] }

  show heading.where(level: 1): it => [ 
    #set text(size: 12pt) 
    #pad(bottom: 0.3em)[#it]
  ]

  set page(
    margin: 1in,
    header-ascent: 0.3in,
    header: context {
      if counter(page).get().first() == 1 {
        // First page header with Brown logo
        grid(
          columns: (auto, 1fr),
          column-gutter: 12pt,
          align: bottom,
          logo,
          block(
            width: 100%,
            stack(
              spacing: 6pt,
              [*#name* --- #title],
              text(size: subsidiarytextsize)[#current-department],
              line(length: 100%, stroke: 0.5pt)
            )
          )
        )
      } else {
        // Subsequent pages header
        
        show text: smallcaps
        align(right)[#title: #name]
      }
    }
  )

  set par(leading: 0.5em)

  text(size: subsidiarytextsize)[#leader]

  body

  if has-references [
  #pagebreak()
  = Bibliography
  #link-bib-urls(link-fill: blue)[
    #bibliography(bib-references, style: bib-style, title: none)
  ]]
}


