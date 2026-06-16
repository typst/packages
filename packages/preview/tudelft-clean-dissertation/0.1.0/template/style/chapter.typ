#let chapter-cover(
  title: none,
  chapter-label: "",  // reference with @chapter-label in main text for a "Chapter X" in body
  chapter-sidebar-label: "",  // in the UI sidebar, what should this chapter be called (keep it short)
  quote: none,
  quote-credit: none,
  introduction
) = {

  pagebreak(to: "even")  // ensure we always start on an even page for a new chapter
  set page(header: none)

  // left page (quote)

  set align(horizon)

  [
  #set page(foreground: none)

  

    
  #set align(left)
  #set text(fill: luma(100), size: 10pt)
  #set par(leading: 4pt, justify: false, hanging-indent: 5pt)
  #emph[“#quote”]

  
  #if quote-credit != none {
    [
      #set align(left)
      #set text(fill: luma(100), size: 10pt)
      #set par(leading: 4pt, justify: false)
      #emph[— #quote-credit]
    ] 
  }
  ]

  pagebreak()

  // right page (chapter connector and title)

  // we create a fake heading with data in the outlined tab that we can filter back later.
  // The chosen approach is a bit hacky.
  [
    #show heading: it => {  // hide the number (visually only, keep it in outline)
      text(fill: luma(14))[]
    }
    #heading(level: 10, supplement: chapter-label, outlined: false, chapter-sidebar-label)
    #label(chapter-label)  // have the chapter label go to this item (as it is the top of the page)
  ]

  v(-10mm)

  [ // chapter number
    #set align(right)
    #set text(fill: luma(14), size: 70pt, weight: "bold")
    #context{counter(heading).get().first()+1}  //
  ]

  v(-21mm)

  [ // title
    #show heading: it => {  // hide the number (visually only, keep it in outline)
      text(fill: luma(14))[#it.body]
    }
    #set text(fill: luma(14), 15pt, font: "Onest", weight: 500, tracking: -0.3pt)
    #set par(leading: 7pt, justify: false)
    #set align(right)
    = #title
    
  ] 

  v(1mm)

  [
    #set par(
      justify: true,
      justification-limits: (tracking: (min: -0.01em, max: 0.02em))
    )
    #introduction
  ]

  // configuration
  counter(figure.where(kind:image)).update(0)

  // we always start a new page
  pagebreak()
}


// some set and styling rules for the supplementary section
#let supplementary(doc) = {
  counter(figure.where(kind:image)).update(0)
  set figure(numbering: num => {
      let chap_num = counter(heading).at(here()).first()
      if chap_num != none {
        numbering("1.S1", chap_num, num)
      } else {
        numbering("1", num)
      }
  })
  doc
}

#let disclaimer(it) = {
  [
  #set par(leading: 0.4em)
  #emph(text(luma(180), size: 8pt)[#it])
  ]
}




