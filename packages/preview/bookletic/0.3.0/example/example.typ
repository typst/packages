#import "@preview/bookletic:0.3.0" // To use through preview
//#import "..\src\lib.typ" // To use on a local clone of the library
//#import "bookletic.typ" // To use on a clone to the Typst app
#set document(author: "My Name", title: "Bookletic Example")

//Barebones example
#let my-eight-pages = (
  [
    = Cover Page (or Page One)

    The content given within each bracket will appear as a single page in the booklet.
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
    = Page Seven

    #lorem(80)
  ],
  [ 
    = Back Cover (or Page Eight)
  ], 
)

// provide your content pages in order and they
// are placed into the booklet positions.
// the content is wrapped before movement so that
// padding and alignment are respected.
#set page(flipped: true, paper: "us-letter")
#bookletic.sig(
  contents: my-eight-pages // Content to be laid out in the booklet
)


// Styling Options Example
// Note: Normal show and set rules work just like normal!
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

// Note: You can use the regular page function to set the paper size, and outside margins
#set page(flipped: true, paper: "us-legal", margin: (top: 0.5in, bottom: 0.5in, left: 0.5in, right: 0.5in))

// Use bookletic's sig function to set booklet specific settings
#bookletic.sig(
  page-margin-binding: 0.5in, // Binding margin for each page
  page-border: none, // Whether to draw a border around each page eg, luma(0)
  draft: false, // Whether to output draft or final layout
  p-num-layout: ( // Refer to example below for further explination of page number usage
    bookletic.num-layout(
      p-num-start: 1,
      p-num-alt-start: none,
      p-num-pattern: "~ 1 ~", 
      p-num-placement: bottom,
      p-num-align-horizontal: right,
      p-num-halign-alternate: true,
      p-num-align-vertical: horizon,
      p-num-pad-left: 0pt,
      p-num-pad-horizontal: 0pt,
      p-num-size: 16pt,
      p-num-border: none,
    ),
  ),
  pad-content: 0pt, // Padding around page content
  contents: more-eight-pages
)

//Example of how to specify specific page numbers for different page ranges
// This example removes page numbers on the front and back cover, adds roman numberal page numbers on the table of contents page and starts numbering from one for content pages. 

#let more-more-my-eight-pages = (
  [
    = Cover Page 
    
    This page has no page number
  ],

  [
    = Table of Contents
    
    This page has a roman numeral page number
    + #lorem(10)

    + #lorem(10)

    + #lorem(10)

    + #lorem(10)
  ],

  [
    = Page One of the Book
  
    This page starts fresh numbering the books actual content

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
  = Back Cover 
  
  This page also has no page number
  ],
)

#set page(flipped: true, paper: "us-letter")
#bookletic.sig(
  draft:true,
  page-border: luma(0), // Whether to draw a border around each page eg, luma(0)
  page-margin-binding: 0.2in, // Binding margin for each page
  p-num-layout: ( // Each entry in the p-num-layout array allows defining a specific style of page numbers starting from the specified page
    bookletic.num-layout(
      p-num-start: 1, // Beginning Page for this page number layout
      p-num-pattern: none, // Adding none here will remove page numbers for this section
    ),
    bookletic.num-layout(
      p-num-start: 2,
      p-num-alt-start: none, // Adding none here will continue numbering the pages using their physical page number 
      p-num-pattern: "I", // Pattern for page numbering
      p-num-placement: bottom, // Placement of page numbers (top or bottom)
      p-num-align-horizontal: center, // Horizontal alignment of page numbers
      p-num-halign-alternate: false,
      p-num-align-vertical: top, // Vertical alignment of page numbers
      p-num-pad-left: 90%, // Extra padding added to page number
      //Note: Extra padding does not work when horizontal alignment is set to left or right
      p-num-pad-horizontal: 5pt, // Horizontal padding for page numbers
      p-num-size: 20pt, // Size of page numbers
      p-num-border: none, // Border color for page numbers
    ),
    bookletic.num-layout(
      p-num-start: 3,
      p-num-alt-start: 1, // Specifing a number here will start numbering this section from that number. In this case starting from one again
      p-num-pattern: (..nums) => 
                  box(inset: 3pt, text(size: 10pt, 
                  sym.lt.curly.double )) + " " 
                  + nums
                    .pos()
                    .map(str)
                    .join(".") 
                  + " " + box(inset: 3pt, text(size: 10pt, sym.gt.curly.double)), 
                  // This is how to use custom symbols around page numbers
      p-num-placement: top, 
      p-num-align-horizontal: center, 
      p-num-halign-alternate: false,
      p-num-align-vertical: horizon, 
      p-num-pad-left: 0pt,
      p-num-pad-horizontal: 1pt, 
      p-num-size: 18pt, 
      p-num-border: oklab(27%, 20%, -3%, 50%), 
    ),
    bookletic.num-layout(
      p-num-start: 8,
      p-num-pattern: none
    ),
  ),
  contents: more-more-my-eight-pages
)
