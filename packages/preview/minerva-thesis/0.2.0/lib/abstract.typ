#import "@preview/alexandria:0.2.1": *
#import "@preview/subpar:0.2.2"
#import "states.typ": * 
#import "main.typ":  set-figures, start-at-odd-page, hide-page-number

#let extended-abstract(
  authors: auto,
  title: auto,
  supervisors: auto,
  multiple-supervisors: auto,
  counsellors: auto,
  multiple-counsellors: auto,
  font: auto,
  font-size: 10pt,
  math-font: auto,
  math-font-size: auto,
  figure-font: auto,
  figure-font-size: auto,
  caption-font: auto,
  caption-font-size: auto,
  title-font: auto,
  title-font-size: auto,
  author-font: auto,
  author-font-size: auto,
  equation-left-margin: auto,
  bibliography: none,
  read: none,
  body
) = context{

  let the-authors= if authors==auto {thesis-authors.get()} else {authors}
  let the-title= if title==auto {thesis-title.get()} else {title}

  let the-supervisors= if supervisors==auto {thesis-supervisors.get()} else {supervisors}
  let the-multiple-supervisors= if multiple-supervisors==auto or type(multiple-supervisors)!=bool { 
    thesis-multiple-supervisors.get()
  } else {multiple-supervisors}
  
  let the-counsellors= if counsellors==auto {thesis-counsellors.get()} else {counsellors}
  let the-multiple-counsellors= if multiple-counsellors==auto or type(multiple-counsellors)!=bool { 
    thesis-multiple-counsellors.get()
  } else {multiple-counsellors}
    

  if show-heading.get() {
    [= Extended Abstract]
    hide-page-number()
    start-at-odd-page()
  }
  set page(columns: 2)
  if not show-heading.get() [= Extended Abstract]
    
  set text(font: font) if font != auto 
  set text(size: font-size)
  
  context {
  
    let base-font-size=text.size
  
    set figure(outlined: false)
    show figure: set text(font: figure-font) if figure-font != auto
    show figure: set text(size: if figure-font-size==auto {0.9*base-font-size} else {figure-font-size})
  
    store.update("ea")
  
    show: set-figures(image-style:"1", table-style:"I", raw-style:"1", store: "ea")  

    show figure.caption: it => context{
      set text(font: caption-font)  if caption-font != auto
      set text(size: if caption-font-size==auto {0.9*base-font-size} else {caption-font-size} )
      align(left, [
      #it.supplement #it.counter.display(it.numbering)#it.separator #it.body
      ])
    }

    show math.equation: set text(font: math-font) if math-font != auto 
    show math.equation: set text(size: if math-font-size==auto {base-font-size} else {math-font-size})

    set math.equation(numbering: "(1)")  

    show ref: it => {
      let eq = math.equation
      let el = it.element
      set text(weight:"regular")
      if el != none and el.func() == eq {
        link(el.location(), numbering(el.numbering,..counter(eq).at(el.location()))) 
      } else { it }
    }
  
 
    let heading-numbering=("I.", "A.", "a.", "i.", "1.")  
    set heading(outlined: false, bookmarked: false, numbering: (..num) => numbering(heading-numbering.at(num.pos().len()-1), num.pos().last() )   )

  // for level 1 it could be simply this:
  // show heading.where(level:1): set heading(numbering: "I.")
  
    counter(heading).update(0)
    show heading: set text(
      size: 1*base-font-size,
      weight:"regular",
      style: "italic"
    )
  
    show heading.where(level: 1): it => {
      set text(style:"normal")
      align(center, 
        smallcaps(if it.numbering!=none {numbering(it.numbering, ..counter(heading).get())+h(0.35em)}+it.body))
    }


    place(top + center, float: true, scope: "parent", {
      par({
        set text(font: title-font) if title-font!=auto
        text(
          size: if title-font-size==auto {2.4*base-font-size} else {title-font-size}, 
          hyphenate: false, 
          the-title
        )
        }
      )
      set text(font: author-font) if author-font!=auto
      set text(size: if author-font-size==auto{1.2*base-font-size} else {author-font-size})
      par(if type(the-authors)==array {the-authors.join(", ", last:" and ")} else {the-authors} )
      par({
        if the-multiple-supervisors [Supervisors: ] else [Supervisor: ]
        if type(the-supervisors)==array {the-supervisors.join(", ", last: " and ")} else {the-supervisors}
        if the-counsellors!=none {
          linebreak()
          if the-multiple-counsellors [Counsellors: ] else [Counsellor: ] 
          if type(the-counsellors)==array {the-counsellors.join(", ", last: " and ")} else {the-counsellors}
        }
      })
      v(1em)
      }
    )
  
    show: alexandria(prefix: "eab-", read: path => read(path))
  
    body
  
    if bibliography!=none {
      set heading(numbering: none)
      bibliographyx(bibliography, title: [References])
    }
  }
  pagebreak()
  set page(columns: 1)
  store.update("m")
}


#let abstract-keywords(keywords: auto, body)=context{
  set text(size: 0.9em, weight:"semibold") if store.get()=="ea"
  
  if body!=none {
    block(context{
      set par(spacing: 0.65em, first-line-indent: 1.5em)
      [_*Abstract*_ --- ]
      body
    })
  }
  
  let the-keywords = if keywords==auto {thesis-keywords.get()} else {keywords}
  if the-keywords != none {
    block({
      [_*Keywords*_ --- ]
      if type(the-keywords) == array {the-keywords.join(", ")} else {the-keywords}
    })
  }
}
