#let frontmatter(
  title: "thesis-title",
  author: "thesis-author",
  degree: "thesis-degree",
  field: "thesis-field",
  committee-members: (
    (name: "thesis-chair", role: "thesis-chair-role"),
    (name: "thesis-member-1", role: "thesis-member-1-role")
  ),
  semester: "Spring",
  year: 2026,

  abstract: [#lorem(150)],
  acknowledgement: [#lorem(150)]
) = [
  #align(center)[
    #v(2.2cm)
    #title
    #v(1.2cm)
    by #linebreak()
    #author
    #v(1.2cm)
    A thesis submitted in partial satisfaction of the requirements for the degree of
    #v(0.5cm)
    #degree
    #v(0.5cm)
    in
    #v(0.5cm)
    #field
    #v(1.2cm)
    in the Graduate Division of the University of California, Berkeley
    #v(0.8cm)
    Committee in charge:
    #v(0.3cm)

    #for (idx, committee-member) in committee-members.enumerate() {
      [#committee-member.at("name"), #committee-member.at("role")]
      if idx != committee-members.len() - 1 {
        [#linebreak()]
      }
    }
    // #thesis.at("thesis-chair"), #thesis.at("thesis-chair-role") #linebreak()
    // #thesis.at("thesis-member-1"), #thesis.at("thesis-member-1-role")
    #v(1.2cm)
    #semester #year
  ]
  
  #pagebreak()
  
  /* Copyright page
  #align(center)[
    #title
    #v(8cm)
    Copyright © #year
    #linebreak()
    by
    #linebreak()
    #author
  ]
  #pagebreak()
  */

  // abstract must be arabic numerals
  #counter(page).update(1)
  #set page(numbering: "1")
  = Abstract
  #abstract
  #pagebreak()

  // roman numerals for frontmatter numbering, skipping the first page
  #counter(page).update(1)
  #set page(numbering: "i")
  
  /* Acknowledgement page
  #align(center)[
    #v(4cm)
    To my family
  ]
  #pagebreak()
  */

  // nicer spacing for table of contents / figures / tables
  #let heading-selector = outline.entry.where(
    level: 1
  )
  #show heading-selector: set block(above: 1.2em)

  = Contents
    #v(1em)
    // custom styling for contents: bold text for section titles, 
    // dot fill only for subsections
    #[
    #let toc-inner(it) = [
      #if it.level == 1 [
        #text(it.body(), weight: "bold")
        #box(width: 1fr)
        #it.page()
      ] else [
        #it.body()
        #box(width: 1fr, repeat(".", gap: 0.5em))
        #it.page()
      ]
    ]

    #show outline.entry: it => link(
      it.element.location(),
      it.indented(it.prefix(), toc-inner(it)),
    )

    #let numbered-headings = heading.where(level: 1).or(heading.where(level: 2))
    #outline(title: none, target: numbered-headings)
    ]
    #pagebreak()

  // include both images and code listings
  = List of Figures
    #v(1em)
    #outline(title: none, target: figure.where(kind: image).or(figure.where(kind: raw)))
    #pagebreak()

  = List of Tables
    #v(1em)
    #outline(title: none, target: figure.where(kind: table))
    #pagebreak()

  = Acknowledgements
  #acknowledgement
]