#import "@preview/bookletic:0.1.0": sig
#set document(author: "My Name", title: "Bookletic Example")

//Barebones example
#let my_eight_pages = (
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
  contents: my_eight_pages
)

// A Fancier example
#show heading: set align(center)
#set text(size: 16pt, font: "PT Serif", lang: "en")
#set par(justify: true)

#let more_eight_pages = (
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
  signature_paper: "us-legal",
  page_margin_top: 0.5in,
  page_margin_bottom: 0.5in,
  page_margin_binding: 1in,
  page_margin_edge: 0.5in,
  page_border: none,
  draft: false,
  pNum_pattern: (..nums) => 
                  box(inset: 3pt, text(size: 10pt, 
                  sym.lt.curly.double )) + " " 
                  + nums
                    .pos()
                    .map(str)
                    .join(".") 
                  + " " + box(inset: 3pt, text(size: 10pt, sym.gt.curly.double)), 
  pNum_placment: bottom,
  pNum_align_horizontal: center,
  pNum_align_vertical: horizon,
  pNum_size: 16pt,
  pNum_pad_horizontal: 0pt,
  pNum_border: none,
  pad_content: 0pt,
  contents: more_eight_pages
)