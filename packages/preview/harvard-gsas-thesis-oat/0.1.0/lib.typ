#let school-color = rgb(165, 28, 48)

#let frontmatter(
  title: none,
  abstract: [],
  author: "John Harvard",
  advisor: "My Dear Advisor",
  doctor-of: "Physics",
  major: "Physics",
  doc
) = {
  set page(
    paper:"us-letter",
    numbering: "I",
  )
  set heading(numbering: "1.1")
  set par(first-line-indent: 3em, justify:true, leading: 1em)
  set text(font:"New Computer Modern", top-edge: 0.7em, bottom-edge: -0.3em, size:12pt)

  show heading.where(
    level: 1, outlined: true
  ): it => [
    #set align(right)
    #set text(20pt, weight: "regular")
    #pagebreak()
    #v(30%)
    #text(100pt, school-color, counter(heading).display())\
    #text(24.88pt, it.body)
    #v(3em)
  ]
  show heading.where(level: 2): smallcaps
  set page(numbering:none)
  set align(center + horizon)
  counter(page).update(1)
  grid(
    [
      #text(school-color, 24.88pt)[_#(title)_]

      #v(1fr)
      #show: smallcaps

      A dissertation presented by\
      #author\
      to\
      The Department of Physics\
      in partial fulfillment of the requirements for the degree of\
      Doctor of #major\
      in the subject of\
      #major
      #v(3fr)
      Harvard University\
      Cambridge, Massachusetts\
      #datetime.today().display("[month repr:long] [year]")
    ]
  )

  pagebreak()
  [
    This work is licensed under #link("https://creativecommons.org/licenses/by/4.0/")[CC BY 4.0]\
    #sym.copyright #datetime.today().display("[year]") #author
  ]
  pagebreak()


  set page(numbering: "I")
  set align(top)
  grid(
    columns:(auto, 1fr, auto),
    [Dissertation Advisor: #advisor],
    [],
    [#author]
  )

  v(5%)
  title
  v(7%)

  [*Abstract*]

  set align(left)
  abstract
  pagebreak()

  outline()


  set page(numbering:none)
  counter(page).update(1)
  set page(numbering:"1")
  doc
}
