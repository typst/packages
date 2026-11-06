#let school-color = rgb(165, 28, 48)

#let frontmatter(
  title: none,
  abstract: [],
  author: "John Harvard",
  advisor: "Dear Advisor",
  department: "Department of Physics",
  doctor-of: "Philosophy",
  major: "Physics",
  completion-date: datetime.today().display("[month repr:long] [year]"),
  creative-commons: true,
  doc
) = {
  set page(
    paper:"us-letter",
    // margin is automatically 2.5/11 times the short side of us-letter
    // which is about 1.01 inch
    margin: auto,
    numbering: "I",
  )
  set text(font:"New Computer Modern", size:12pt)

  // to mimic Double Spacing
  // https://github.com/typst/typst/issues/106#issuecomment-2041051807
  set text(top-edge: 0.7em, bottom-edge: -0.3em)
  set par(first-line-indent: 3em, justify:true, leading: 1em)

  set heading(numbering: "1.1")
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
  show heading.where(level: 1): smallcaps
  set page(numbering:none)
  set align(center + horizon)
  counter(page).update(1)
  grid(
    [
      #text(school-color, 24.88pt)[_#(title)_]

      #v(1fr)
      #show: smallcaps

      A dissertation presented\
      by\
      #author\
      to\
      The #department\
      in partial fulfillment of the requirements\
      for the degree of\
      Doctor of #doctor-of\
      in the subject of\
      #major
      #v(3fr)
      Harvard University\
      Cambridge, Massachusetts\
      #completion-date
    ]
  )

  pagebreak()
  show link: it => {set text(fill: school-color); it}

  [
    #if creative-commons [
      This work is licensed via #underline[
        #link("https://creativecommons.org/licenses/by/4.0/")[CC BY 4.0]
      ]
    ]
  
    Copyright #sym.copyright #datetime.today().display("[year]") #author
  ]
  pagebreak()

  // "Preliminary pages (abstract, table of contents, list of tables, graphs, illustrations, and
  // preface) should use small Roman numerals"
  set page(numbering: "I")
  set align(top)
  grid(
    columns:(auto, 1fr, auto),
    [Dissertation Advisor: #advisor],
    [],
    [#author]
  )

  v(5%)
  text(school-color, 24.88pt)[_#(title)_]
  v(7%)

  [*Abstract*]

  set align(left)
  abstract
  pagebreak()

  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): it => {smallcaps(it)}

  outline(
    title: grid([
      #set text(23pt)
      #h(1fr)
      Contents
      #v(2em)
    ])
)


  set page(numbering:none)
  counter(page).update(1)
  set page(numbering:"1")
  doc
}
