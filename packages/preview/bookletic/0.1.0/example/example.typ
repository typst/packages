#import "@preview/bookletic:0.1.0": sig 
#set document(author: "My Name", title: "Bookletic Example")

//Barebones example
#let my-eight-pages = (
  [
    = Cover Page
  ],

  [
    = Page One

    #lorem(80)
  ],

  [
    = Page Two

    #lorem(80)
  ],

  [
    = Page Three

    #lorem(80)
  ],

  [
    = Page Four

    #lorem(80)
  ],

  [
    = Page Five

    #lorem(80)
  ],

  [ 
    = Page Six

    #lorem(80)
  ],

  [ 
  = Back Cover
  ],
)


// provide your content pages in order and they
// are placed into the booklet positions.
// the content is wrapped before movement so that
// padding and alignment are respected.
#sig(
  contents: my-eight-pages
)

// A Fancier example
#show heading: set align(center)
#set text(size: 16pt, font: "PT Serif", lang: "en")
#set par(justify: true)

#let more-eight-pages = (
  [
    #v(45%)
    = Cover Page
  ],

  [
    = Page One
    \
    #lorem(80)
  ],

  [
    = Page Two
    \
    #lorem(100)
  ],

  [
    = Page Three
    \
    #lorem(80)
  ],

  [
    = Page Four
    \
    #lorem(40)

    #lorem(40)
    
    #lorem(40)
  ],

  [
    = Page Five
    \
    #lorem(80)
  ],

  [ 
    = Page Six
    \
    #lorem(120)
  ],

  [ 
    #v(45%)
    = Back Cover
  ],
)

#sig(
  signature-paper: "us-legal",
  page-margin-top: 0.5in,
  page-margin-bottom: 0.5in,
  page-margin-binding: 1in,
  page-margin-edge: 0.5in,
  page-border: none,
  draft: false,
  p-num-pattern: (..nums) => 
                  box(inset: 3pt, text(size: 10pt, 
                  sym.lt.curly.double )) + " " 
                  + nums
                    .pos()
                    .map(str)
                    .join(".") 
                  + " " + box(inset: 3pt, text(size: 10pt, sym.gt.curly.double)), 
  p-num-placment: bottom,
  p-num-align-horizontal: center,
  p-num-align-vertical: horizon,
  p-num-size: 16pt,
  p-num-pad-horizontal: 0pt,
  p-num-border: none,
  pad-content: 0pt,
  contents: more-eight-pages
)