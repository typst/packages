///////////////////////////////
// This Typst template is for working paper draft.
// It is based on the general SSRN paper.
// Copyright (c) 2024
// Author:  Jiaxin Peng
// License: MIT
// Version: 0.4.8
// Date:    2024-03-18
// Email:   jiaxin.peng@outlook.com
///////////////////////////////

#import "@preview/ctheorems:1.1.0": *

#import "@preview/mitex:0.2.2": *

#import "@preview/cetz:0.2.1"

#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx, hlinex

#import "@preview/tablem:0.1.0": tablem


#let paper(
  font: "PT Serif",

  fontsize: 11pt,

  title: none,

  subtitle: none,

  maketitle: true,

  authors: (),

  date: "",

  abstract: [],

  keywords: [],

  JEL: [],

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

          if acknowledgments != none and acknowledgments != "" {
            text(17pt, align(center,{title;footnote(acknowledgments)}))
          } else {
            text(17pt, align(center,{title}))
          }
          v(15pt)

          let count = authors.len()
          let ncols = calc.min(count, 3)
          set footnote.entry(indent: 0em)
            grid(
              columns: (1fr,) * ncols,
              row-gutter: 24pt,
              ..authors.map(author => {
                text(14pt,align(center,{author.name; 
                {
                  if author.note != ""  {
                    footnote(author.note)
                    }
                };[\ ]
                author.affiliation; [\ ]
                link("mailto:" + author.email)})
                )
          }),
            )
          v(20pt)
            if date != "" {
            align(center,[This Version: #date])
              v(25pt)
              }
            if abstract != [] {
            par(justify: true)[
              #align(center, [*Abstract*])
              #abstract
            ]
              v(10pt)
              }
            if keywords != [] {
            par(justify: true)[
              #set align(left) 
              #emph([*Keywords:*]) #keywords
            ]
            v(5pt)
            }
              if JEL != [] {
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
      }
    
      v(10pt)
      set heading(numbering: "1.",)
      set math.equation(numbering: "(1)")
      set footnote(numbering: "1")
      set footnote.entry(separator: line(length: 100%, stroke: 0.5pt))
      set footnote.entry(indent: 0em)
      set align(left)
      columns(1, doc)
    

      if bibliography != none {
        colbreak()
        bibliography
      }
}

#let _treemap(is-root: false, max-columns: 3, is-child-of-root: false, tree) = {
  if is-root {
    table(
      inset: (x: 0.2em, y: 0.6em),
      columns: calc.min(tree.children.len(), max-columns),
      ..tree.children.map(_treemap.with(is-child-of-root: true)),
    )
  } else {
    if tree.children == () {
      box(inset: (x: 0.2em, y: 0em), rect(tree.title))
    } else {
      let res = stack(
        {
          set align(center)
          set text(size: 1.25em, weight: "bold")
          tree.title
        },
        v(0.8em),
        {
          tree.children.map(_treemap).sum()
        },
      )
      if is-child-of-root {
        res
      } else {
        box(
          inset: (x: 0.2em, y: 0em),
          rect(
            width: 100%,
            inset: (x: 0.2em, y: 0.6em),
            res,
          ),
        )
      }
    }
  }
}


#let _list-title(cont) = {
  let res = ([],)
  for child in cont.children {
    if child.func() != list.item {
      res.push(child)
    } else {
      break
    }
  }
  res.sum()
}


#let _treemap-converter(cont) = {
  if not cont.has("children") {
    if cont.func() == list.item {
      (title: cont.body, children: ())
    } else {
      (title: cont, children: ())
    }
  } else {
    (
      title: _list-title(cont),
      children: cont.children
        .filter(it => it.func() == list.item)
        .map(it => _treemap-converter(it.body))
    )
  }
}


#let treemap(cont) = _treemap(is-root: true, _treemap-converter(cont))


#let theorem = thmbox(
  "theorem", 
  "Theorem", 
  fill: rgb("#eeffee"),
  base_level: 1,
  separator:none
  )

#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong
)

#let definition = thmbox(
  "definition", 
  "Definition",
  base_level: 1,
  stroke: rgb("#0000ff") + 0.5pt,
  fill: rgb("#eeeeff"),
  separator:none
)

#let lemma = thmbox(
  "theorem", 
  "Lemma",
  base: "theorem",
  base_level: 1,
  fill: rgb("#eeffee"),
  titlefmt: strong,
  separator:none)

#let example = thmplain("example", "Example")

#let proof = thmplain(
  "proof",
  "Proof",
  base: "theorem",
  bodyfmt: body => [
    #body #h(1fr) $square$
    ]
).with(numbering: none)

#let remark = thmplain(
  "remark", 
  "Remark"
  ).with(numbering: none)


#let eq(content) = math.equation(
  block: true,
  numbering: none,
  supplement: auto,
  content,
)