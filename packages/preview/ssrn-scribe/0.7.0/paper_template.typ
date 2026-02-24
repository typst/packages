///////////////////////////////
// This Typst template is for working paper draft.
// It is based on the general SSRN paper.
// Copyright (c) 2025
// Author:  Jiaxin Peng
// License: MIT
// Version: 0.7.0
// Date:    2025-01-24
// Email:   jiaxin.peng@outlook.com
///////////////////////////////

#let paper(
  font: "PT Serif",

  fontsize: 11pt,

  title: none,

  subtitle: none,

  maketitle: true,

  authors: (),

  date: none,

  abstract: none,

  keywords: none,

  JEL: none,

  acknowledgments: none,

  bibliography: none,

  doc,
) = {
      set math.equation(numbering: "(1)", supplement: auto)

      set par(leading: 1em)
        // Set and show rules from before.

      set text(
        font: font,
        size: fontsize
      )
      set page(numbering: "1")
      set document(
        title: title,
        author: authors.map(author => author.name),
      )

      if maketitle == true {
          set footnote(numbering: "*")
          set footnote.entry(
            separator: line(length: 100%, stroke: 0.5pt)
          )
          set footnote.entry(indent: 0em)
          set align(left)

          if acknowledgments != none {
            text(17pt, align(center,{title;footnote(acknowledgments)}))
          } else {
            text(17pt, align(center,{title}))
          }
          v(15pt)

          let count = authors.len()
          let ncols = calc.min(count, 3)
          set footnote.entry(indent: 0em)
            for i in range(calc.ceil(authors.len() / 3)) {
              let end = calc.min((i + 1) * 3, authors.len())
              let is-last = authors.len() == end
              let slice = authors.slice(i * 3, end)
              grid(
                columns: slice.len() * (1fr,),
                gutter: 24pt,
                ..slice.map(author => align(center, {
                  text(14pt, {author.name;
                  {
                    if "note" in author {
                      footnote(author.note)
                    }
                  }
                  }
                  )
                  if "department" in author [
                    \ #emph(author.department)
                  ]
                  if "affiliation" in author [
                    \ #emph(author.affiliation)
                  ]
                  if "email" in author [
                    \ #link("mailto:" + author.email)
                  ]
                }))
              )

              if not is-last {
                v(16pt, weak: true)
              }
            }
          v(20pt)
            if date != none {
            align(center,[This Version: #date])
              v(25pt)
              }
            if abstract != none {
            par(justify: true)[
              #align(center, [*Abstract*])
              #abstract
            ]
              v(10pt)
              }
            if keywords != none {
            par(justify: true)[
              #set align(left) 
              #emph([*Keywords:*]) #keywords
            ]
            v(5pt)
            }
              if JEL != none {
              par(justify: true)[
                  #set align(left) 
                  #emph([*JEL Classification:*]) #JEL
              ]
              v(5pt)
              }
            pagebreak()
        
      } else {
          set align(left)
          text(18pt, align(center,{strong(title)}))
          if subtitle != none {
            text(12pt, align(center,{subtitle}))
          }

          let count = authors.len()
          let ncols = calc.min(count, 3)
          set footnote.entry(indent: 0em)
            for i in range(calc.ceil(authors.len() / 3)) {
              let end = calc.min((i + 1) * 3, authors.len())
              let is-last = authors.len() == end
              let slice = authors.slice(i * 3, end)
              grid(
                columns: slice.len() * (1fr,),
                gutter: 24pt,
                ..slice.map(author => align(center, {
                  text(14pt, {author.name;
                  {
                    if "note" in author {
                      footnote(author.note)
                    }
                  }
                  }
                  )
                  if "department" in author [
                    \ #emph(author.department)
                  ]
                  if "affiliation" in author [
                    \ #emph(author.affiliation)
                  ]
                  if "email" in author [
                    \ #link("mailto:" + author.email)
                  ]
                }))
              )

              if not is-last {
                v(16pt, weak: true)
              }
            }
          v(20pt)

          if date != none {
            align(center,[This Version: #date])
              v(25pt)
              }
      }
    
      v(10pt)
      set heading(numbering: "1.",)
      set math.equation(numbering: "(1)")
      set footnote(numbering: "1")
      set footnote.entry(separator: line(length: 100%, stroke: 0.5pt))
      set footnote.entry(indent: 0em)
      set align(left)
  set heading(numbering: "1.")

  show heading: it => [
    #set align(left)
    #counter(heading).display(
        it.numbering
      ) #it.body
    #v(10pt)
  ]

  set text(spacing: 100%)
  set par(
  leading: 1.2em,
  first-line-indent: 0em,
  justify: true,

)

      columns(1, doc)
    
    set par(leading: 1em)
    
      if bibliography != none {
        colbreak()
        show heading: it => [
        #set align(left)
        #it.body
        #v(10pt)
       ]
        bibliography
      }
}
