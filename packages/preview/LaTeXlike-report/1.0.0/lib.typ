#import "@preview/chic-hdr:0.5.0":*
#import "@preview/equate:0.3.1":*
#let latexlike-report(
 // ======== Cover ============
  author: none,
  title: [Report Title],
  subtitle: [Report Subtitle],
  
  participants: none, // In case of several authors (the name in author parameter will go first) Use content [] or none.
  
  affiliation: none,
  year: none,
  class: none,
  other: none,
  date: none,

  logo : none,

  //==========Theme ===============
  theme-color: rgb(128, 128, 128),
  lang: "en", 
   participants-supplement: "Authors:", //Change it if you change the language
 
            
  //=========Font =================
  title-font: "Noto Sans",
  font: "New Computer Modern",
  font-size : 12pt,
  font-weight: 400,

  //============ Math =============
  math-font: "New Computer Modern Sans Math",
  math-weight: 400,
  math-ref-supplement: none, //Use none for no supplement, auto for language based or any other function or string you like
  math-numbering: "(1.1)", // The numbering style you like
  
  // ---- Equate package ---
  // For more information you can refer to equate documentation
  
  math-number-mode: "label", //Can be "label" or "line" 
  math-sub-numbering: true,  // true or false

  //===========Style===============
  pagebreak-section: true, //For pagebreak after adding a new level one heading (=)
  show-outline:true, //true or false 
  page-paper:"a4",

  //-----chic header package----
  // customize the left/center/right header and left/center/right footer
  // you can add images, text, the number of current page, etc, or put none if you dont want some part of the header or footer.
  //some usefull function: chic-page-number(), chic-heading-name()
  
  h-l : "",
  h-r : "",
  h-c : none,

  f-l : "",
  f-r : "",
  f-c : chic-page-number(),
  
  doc
) = {



  set document(author: author, title: title)
  set page(page-paper)


  //fuentes
  set text(font: font,lang: lang ,size: font-size, weight: font-weight )
  /////////////////////////////////// MAtEMATICAS //////////////////
  show: equate.with(number-mode: math-number-mode, sub-numbering: math-sub-numbering)

  set math.equation(numbering: math-numbering ,supplement: math-ref-supplement )
  show math.equation: set text(font: math-font, weight: math-weight)
  
  ///////////////////////Figuras //////////////////////////////////
  
  
 show figure.caption: it => [
    #strong[#it.supplement
    #context it.counter.display(it.numbering) 
    #it.separator]
    #it.body
 ]


  set figure(gap: 1.2em)
  show figure.where( kind: table): set figure.caption(position: top)
  
  
  
  
  
  
  
  
  
  //////////////////////////colors ///////////////
  let primary-color = rgb(theme-color.lighten((10%))) 
  let secondary-color = color.mix(color.rgb(100%, 100%, 100%, 50%), primary-color, space:rgb)
  let bg-color = theme-color.lighten(90%)
  let font-color = theme-color.darken(30%)
/////////////////// SECTIONS ///////////////////////////

 set heading(
    numbering: 
      (..nums) => [
        #nums.pos().map(str).join(".")
        #h(0.1em)
        #box(width: 1.2pt, height: 1em, fill: font-color.darken(30%), baseline: 15%)
        #h(0.1em)
      ]
  )
  show heading: it => text(fill: font-color, font: title-font)[#it #v(0.5em)]
  show heading.where(level: 1): set text()
  show heading.where(level: 2): set text()
  show heading.where(level: 3): set text()
  show heading.where(level: 4): set text()
  show heading.where(level: 1):  it => if pagebreak-section {pagebreak(weak: true);it} else {it}

  

  show selector(<nonumber>): set heading(numbering: none,outlined: false) // use <nonumber> to unnumber the heading
                                                           
                                                           
                                                          
  //////////////////////// Cover begin////////////////////////////



  if logo != none {
    set image(width: 4cm)
    place(top + left, logo)
  }
 
  
  v(3fr)

  align(center, text(font: title-font, 2.5em, weight: 700, title, fill:font-color))

  v(2.5em, weak: true)

  if subtitle != none {
  line(length: 100%,stroke: 1.5pt + primary-color.darken(30%) )
  v(-0.3em)
  align(center, text(font: title-font, 1.5em, weight: 700, subtitle))
  v(-0.2em)
  line(length: 100%,stroke: 1pt + primary-color.darken(30%) )
  v(2em, weak: true)
  }

  //////////// Date
  
  align(center, text(1.1em, date))

  //////////  Participants
  align(left)[
    #if participants != none {strong(participants-supplement);linebreak(); (author);linebreak();participants}
  ]

  v(2fr)

  // Author and other information.
  align(center)[
      #if author != "" and participants == none {strong(author); linebreak();v(0.5fr)}
      #if affiliation != none {affiliation; linebreak();}
      #if year != none {year; linebreak();}
      #if class != none {emph(class); linebreak();}
      #if other != none {emph(other); linebreak();}
    ]

  pagebreak()

  //////////////////////// Cover end////////////////////////////

  // Outline begin
  
  if show-outline {outline(title: auto, depth: 3,indent: auto)}

  // Outline end
 
 /////////////////////// HEADER /////////////////////
  show: chic.with(
  chic-footer(
    left-side: f-l,
    right-side: f-r,
    center-side: f-c
  ),

  //header
  chic-header(
    left-side: h-l,
    right-side:h-r,
    center-side: h-c,
  ),
  chic-separator( stroke(0.7pt + theme-color.darken(40%))),
  chic-offset(20pt),
  chic-height(3cm)
)

  //////////////////////////PARRAFOO/////////////////////////////////
  set par(first-line-indent: (amount: 1em, all: true) , justify: true)
  show table.cell: set par(justify: false)
  doc
}
