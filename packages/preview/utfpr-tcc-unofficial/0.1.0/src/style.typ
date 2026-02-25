#import "@preview/linguify:0.4.2": *

#let formatting(
  body,
) = {

// ===============================================
// Page
// ===============================================
set page(
  margin: (left: 3cm, right: 2cm, top: 3cm, bottom: 2cm),
  number-align: top+right,
)

// ===============================================
// Normal Text
// ===============================================
set par(
  justify: true, 
  first-line-indent: (amount: 1.5cm, all: true),
  leading: 1.0em,
  spacing: 1.0em,
)
set text(size: 12pt)
set underline(offset: 0.2em, evade: false, extent: 0.08em)

// ===============================================
// Headings
// ===============================================
set heading(numbering: "1.1")
show heading : it =>{
  set text(
    size:12pt,
    weight: if it.level < 3 {700} else {0}
  )
  if it.level == 1 {pagebreak();upper(it)}
  else if it.level == 4 {underline(it)}
  else if it.level == 5 {emph(it)}
  else {it}
}

// ===============================================
// Figures
// ===============================================
set figure.caption(position: top,separator: " - ")
show figure: set text(size: 10pt)
show figure: set par(spacing: 0.5em, leading: 0.5em)
show figure.caption: set text(size: 10pt, weight: 700)


show figure.where(kind: "photograph"): set figure(supplement: linguify("photograph"))
show figure.where(kind: "graph"): set figure(supplement: linguify("graph"))
show figure.where(kind: "frame"): set figure(supplement: linguify("frame"))

// ===============================================
// Frames
// ===============================================

show figure.where(kind:"frame") : it => {
  set table(stroke: 0.5pt)
  set block(breakable: true)
  it  
}

// ===============================================
// Tables
// ===============================================

show figure.where(kind:table) : it => {
  set table(stroke: 0.5pt)
  set table.header(repeat: true)
  set block(breakable: true)
  set table(
    stroke: (_, y) => (
       top: if y < 1 { 0.5pt } else { 0pt },
       bottom: 0.5pt,
      ),
  )
  let header-args(children) = (
    ..children.map(c => {
      let c_fields = c.fields()
      let body = c_fields.remove("body")
      table.cell(
        ..c_fields,
        body,
        stroke: ( bottom: 0.5pt, top: 0.5pt),
      )
    }),
  )

  show table: it => {
    let fields = it.fields()
  
    if fields.at("label", default: none) == <table-show-recursion-stop> { it } else {
      let children = fields.remove("children")

      let header-elem = ()
      let index-list = ()
      for (index, child) in children.enumerate() {
        if child.func() == table.header {
          header-elem.push(children.at(index).children)
          index-list.push(index)
        }
      }
      for i in index-list { if i != 0{
          children.at(i)=[] // avoids linter problem
          children.remove(i)
      }}
      
      {
        let new = ()
        for (i, h) in header-elem.enumerate() {
          if i == 0 {
            new.push(h)
          } else {
            new.push(header-args(h))
          }
        }
        header-elem = new
      }
      let final-args = ()
      for elem in header-elem{for e in elem {
        final-args.push(e)
      }}

      if children.at(0).func() == table.header {
        children.at(0) = table.header(..final-args)
      }

      [#table(..fields, ..children) <table-show-recursion-stop>]
    }
  }
  
  it
}
// ===============================================
// Outlines
// ===============================================
set outline(indent: 0cm)
show outline: it => {
  show heading: set align(center)
  it
}
show outline.entry: it => {
  if it.element.func() == heading{link(
    it.element.location(),
    grid(columns: (10%,auto), it.prefix(),it.inner()),
  )}
  else {link(
    it.element.location(),
    it.prefix()+[ \- ]+it.inner()+[\ ],
  )}
}
show outline.entry: it => {
  set text(weight: 700)
   if it.element.func() == heading {
      set text(
        size:12pt,
        weight: if it.level < 3 {700} else {0}
      )
      if it.level == 1 {upper(it)}
      else if it.level == 4 {underline(it)}
      else if it.level == 5 {emph(it)}
      else {it}
    }else {it}
}

// ===============================================
// Citations
// ===============================================

set cite(style: "associacao-brasileira-de-normas-tecnicas")
set bibliography(
  title: none, 
  style: "associacao-brasileira-de-normas-tecnicas",
)
show bibliography: it => {
  align(heading(linguify("bibliography")),center)
  linebreak()
  set par(leading: 0.5em)
  it
}

// ===============================================
// Quotation
// ===============================================

show quote.where(block: true): it => {
  set text(size: 10pt)
  set par(
    leading: 0.5em, 
    first-line-indent: (amount:4cm, all:true),
    hanging-indent: 4cm
  )

  if it.attribution == none {
    panic("Block quotes need attribution parameter to not be none")
  }
  par(it.body + [ ] + it.attribution + ".")
}

show quote.where(block: false): it => {
  if it.attribution == none {
    it
  } else {
  it+[ ]+it.attribution
  }
}

// ===============================================
// Lists
// ===============================================

set list(indent: 1.25cm)
set enum(indent: 1.25cm)

  body
}