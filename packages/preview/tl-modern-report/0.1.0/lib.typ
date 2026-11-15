#import "@preview/icu-datetime:0.2.2": fmt

#let rep(
          title: "TITLE", 
          subtitle: "SUBTITLE",
          author: "Author",
          position: "",
          date: datetime.today(),
          language: "en",
          logo: "logoipsum.svg",
          page-numbering: "1/1",
          section-numbering: "1.",
          doc) = {
         
  // document setup
  set document(
    title: title,
    author: author,
    date: date
  )
  
  // text
  set text(
    font: "Liberation Sans",
    size: 11pt,
    lang: language
  )
  show link: it => text(fill: blue)[#it]
  show heading: set block(below: 1em)
  
  // page
  set page(
    paper: "a4",
    margin: (top: 3cm),
    header: [
    #grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    [#strong(title)
    #linebreak()
    #emph(subtitle)
    ],
    image(logo, height: 1cm) 
    )   
    #line(length: 100%)
    ],
    footer: auto,
    numbering: page-numbering,
    number-align: right,
    columns: 1,
  )
  set par(justify: true)

  set heading(numbering: section-numbering)

  // title page
  page(header: none, footer: none, margin: (top: 2cm))[
  //#v(1fr)
  
  #align(right)[#image(logo, width: 5cm, height: 5cm, fit: "contain")]
  
  #v(1fr)
  
  #fmt(date, locale: language, length: "long")
  
  #v(-0.7cm)
  
  #text(weight: "bold", size: 3em)[
  #title
  ]
  
  #v(-0.5cm)
  
  #text(weight: "semibold", style: "italic", size: 1.5em)[
  #subtitle
  ]
  
  #v(1cm)
  
  #author
  #linebreak()
  #emph[#position]
  #v(3fr)
  #outline(depth: 1)
  ]
  
  // reset page number
  counter(page).update(1)
  
  doc
}
