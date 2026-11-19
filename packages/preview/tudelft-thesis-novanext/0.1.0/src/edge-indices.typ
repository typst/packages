//  https://forum.typst.app/t/how-to-create-a-chapter-edge-index-thumb-index/3883/7

#import "@preview/hydra:0.6.3": hydra, anchor
#import "@preview/tudelft-tools-novanext:0.1.0": *
#let current-page() = {
  if page.numbering == none {} else {
    numbering(page.numbering, counter(page).get().at(0))
  }
}

#let thesis-header() = context{
  if hydra(1) == none {
    // empty on chapter opening pages
  } else {
    if calc.odd(here().page()) {
      current-page()
      h(1fr)
      hydra(1)
    } else {
      hydra(2)
      h(1fr)
      current-page()
    }
    v(-0.7em)
    line(stroke: tud-blue, length: 100%)
  }
  anchor()
}

#let thesis-footer() = context{
  if hydra(1) == none {
    align(center, current-page())
  }
} 

#set page(
  header: thesis-header(),
  footer: thesis-footer(),
)
  
#let front-matter(side: "odd", it) = {
  pagebreak(to: side, weak: true)
  //set page(footer: align(center, context counter(page).display("1")))
  set heading(numbering: none)
  set page(numbering: "i")
  counter(page).update(1)
  it
}

#let main-matter(side: "odd", it) = {
  pagebreak(to: side, weak: true)
  set heading(numbering: "1.1")
  set page(numbering: "1")
  counter(page).update(1)
  it
}

#let appendix(side: "odd", it) = {
  pagebreak(to: side, weak: true)
  //set page(footer: align(center, context counter(page).display("1")))
  counter(heading).update(0)
  set heading(numbering: "A.1")
  it
}

#let back-matter(side: "odd", it) = {
  pagebreak(to: side, weak: true)
  set heading(numbering: none)
  it
}

#let thumb-index-color = gray
#let thumb-index(height: 1cm, width: 1cm) = context{
  let total-headings = counter(heading.where(level: 1)).final().first()
  let previous-headings = query(selector(heading).before(here()))
  let next-headings = query(selector(heading).after(here()))
  let number = none
  if heading.numbering == none {return}
  if hydra(1) == none {return}
  if previous-headings.len() == 0 and next-headings.len() == 0 {
    // if there are no headings in the document, return none
    return
  }
  if next-headings.len() == 0{
    // if there are no more headings after, the numbering continues indefinitely
    number = counter(heading).at(previous-headings.last().location()).first()
  } else if previous-headings.len() == 0 {
    // if there are no previous headings, use the first heading found
    number = counter(heading).at(next-headings.first().location()).first()
  } else {
    let current-page = here().page()
    let next-heading-page = next-headings.first().location().page()
    if next-heading-page == current-page {
      // if the next heading is on the current page, use the next heading's number
      number = counter(heading).at(next-headings.first().location()).first()
    } else {
      // otherwise (general case) use the previous heading's number
      number = counter(heading).at(previous-headings.last().location()).first()
    } 
  }
  // vertical offset for the thumb markers
  let offset = (number - 1 - (total-headings - 1) / 2) * height

  if calc.odd(here().page()) {
    place(
      horizon + right,
      dy: offset,
      dx: width,
      block(width: 2 * width, height: height, fill: thumb-index-color, radius: 4pt,)[
        #set align(center)
        #text(fill: white, weight: "bold", size: 25pt)[#numbering(heading.numbering.at(0), number)#h(width)]
      ]
    )
  } else {
    place(
      horizon + left,
      dy: offset,
      dx: -width,
      block(width: 2 * width, height: height, fill: thumb-index-color, radius: 4pt,)[
        #set align(center)
        #text(fill: white, weight: "bold", size: 25pt)[#h(width)#numbering(heading.numbering.at(0), number) ]
      ]
    )
  }  
}

#show heading.where(level: 1): it => {
  pagebreak(to: "odd", weak: true)
  it
}

#set page(
  background: thumb-index(height: 2cm),
  height: 10cm,
)

#{
  set align(center)
  text(weight: "bold", size: 25pt)[Title]
}

#show: front-matter
#outline()

= Front matter
== Section

= One more chapter
== Section

#show: main-matter

= Main matter
== Section

#lorem(100)
#pagebreak()

== One more section
#lorem(500)

= One more chapter
== Section

= One more chapter
== Section

#show: appendix

= Appendix
== Section

= One more chapter
== Section


#show: back-matter

== Back matter
== Section

= One more chapter
== Section
