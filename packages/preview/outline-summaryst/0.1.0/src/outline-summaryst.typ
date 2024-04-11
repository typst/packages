#import "helpers.typ": calc-elem-size, make-title, make-foreword

// randomly generated IDs
#let gs = state("VIvouA", ())
#let elemcounter = counter("k1lRPA")

#let supl = [Custom Heading]


#let outline-summaryst(
  doc, 
  title: none,
  subtitle: none,
  author: none,
  foreword-name: none,
  foreword-contents: none,
) = [
  #set par(
    justify: true,
  )
  
  #if title != none {
    make-title(title, subtitle, author)
  }

  #if foreword-name != none {
    make-foreword(foreword-name, foreword-contents)
  }
  
  #show outline.entry: it => {
    if it.element.supplement != supl {
      return v(-2em)
      return none
    }
    let lvl = it.element.level
    let loc = it.element.location()
    
    context {
      // Get all the elements that were added to the document
      let (cnt, subcnt) = gs.final().at(elemcounter.get().first())
      
      if lvl == 1 {
        return link(loc)[
          #v(30pt)
          #set align(center)
          #smallcaps[#text(
            size: 18pt
          )[#cnt]]
          
          #set align(left)
          #subcnt
        ]
      }
      //else
      return link(loc)[
        #let size = calc-elem-size(it.element)
        
        #set align(center)
        #smallcaps[#text(
          size: size
        )[#cnt]]
        
        #set align(left)
        
        #subcnt #box(width: 1fr, repeat[.]) #it.page
      ]
    }
    
    elemcounter.step()
  }

  #show heading: it => [
    #if it.supplement != supl {
      return none
    }
    
    #let (cnt, subcnt) = gs.get().last()
    
    #cnt
    
    #set align(center)
    #text(size: 11pt, weight: "regular", style: "italic")[
      #box(width: 80%)[#subcnt]
    ]
    #v(1em)
  ]
  
  #text(size: 18pt, weight: 500)[
    #set align(center)
    Table of Contents
  ]
  #outline()
  #pagebreak()
  
  #set page(numbering: "1")
  #counter(page).update(1)
  
  #doc
]




#let make-heading(cnt, subcnt, level: 1) = [
  #gs.update(x => {
    x.push((cnt, subcnt))
    x
  })

  #heading(level: level, supplement: supl)[
    #cnt

    #set align(center)
    #text(size: 11pt, weight: "regular", style: "italic")[
      #box(width: 80%)[#subcnt]
    ]
  ]
]




