#import "universe-packages.typ": * 

// Default Header Config of the Document
#let doc-general-header() = {
  context {

    // Don't print on Title 
    if here().page() == locate(<title>).page() { return }

    
    // Get all headings before this position
    let heading-before = query(selector(heading.where(level: 1).before(here())))
    // Get all headings after this position
    let heading-after = query(selector(heading.where(level: 1).after(here())))

    // Static Text
    let text-left = text(size: 11pt, [])
    let text-right = text(size: 11pt, [])

    // Dynamic Text - Chapter
    let print-center = true
    let print-new = false
    let text-center = []

    
    // Check if Array is empty
    if heading-before.len() == 0 { print-center = false }
    // Don't print Chapter Name on this Page with Level 1 Heading
    else if here().page() == heading-before.last().location().page() { print-center = false }

    // Check if Array is empty
    if heading-after.len() == 0 { print-center = false }
    // Don't print Chapter Name on the Page with the next Level 1 Heading 
    else if here().page() == heading-after.first().location().page() { 
      //if heading-after.first().location().position().y < 110pt { print-center = false }
      if heading-after.first().location().position().y < 110pt { print-new = true }
    }
    

    if print-center {

      // Heading on Page
      if print-new {
        text-center = text(
          size: 12pt, 
          weight: "semibold", 
          tracking: 0.4pt,
          heading-after.first().body
        )  
        
        // Special Pages
        if heading-after.first().supplement == [Affidavit] {
          text-center = text(
            size: 12pt, 
            weight: "semibold", 
            tracking: 0.4pt,
            [Affidavit]
          ) 
        }

        if heading-after.first().supplement == [Appendix] {
          text-center = text(
            size: 12pt, 
            weight: "semibold", 
            tracking: 0.4pt,
            [Appendix]
          ) 
        }
        
      // Headings before
      } else {
        text-center = text(
          size: 12pt, 
          weight: "semibold", 
          tracking: 0.4pt,
          heading-before.last().body
        )        
      }
    }

    rect(
      width: 100%,
      height: 3em,
      stroke: (bottom: 0.7pt,),
      stack(
        dir: ltr,
        box(width: 32%, align(left, text-left)),
        1fr,
        box(width: 34%, align(center, text-center)),
        1fr,
        box(width: 32%, align(right, text-right)),
      )
    )
    
  }
}


// Default Formating Config of the Document
#let format-doc-general(body) = {

  // Set - Pages
  // --------------------------------------------------------
  set page(
    paper: "a4",
    margin: (
      top: 2.4cm,
      bottom: 2.7cm,
      left: 2.4cm,
      right: 2.4cm,
    ),
    header: doc-general-header(),
  )

  
  // Set - Headings
  // --------------------------------------------------------
  set heading(
    numbering: none,
    outlined: true, 
    bookmarked: true,
  )

  // Set - Text
  // --------------------------------------------------------  
  set text(
    lang: "en",
    font: "Lato",
    size: 12pt,
    hyphenate: false,
  )


  // Set - Paragraphs
  // --------------------------------------------------------
  set par(
    justify: true,
    leading: 0.52em,
  )

  // Set - Bullet List
  // --------------------------------------------------------
  set list(
    //tight: true,
    //spacing: 1.2em, // default: 1.2em
    indent: 12pt,
  )

  
  // Set - Numbered List
  // --------------------------------------------------------
  set enum(
    indent: 12pt,
  )

  
  // Set - Figures
  // --------------------------------------------------------
  set figure(
    placement: none,
  )

  
  // Set - Equations
  // --------------------------------------------------------
  set math.equation(numbering: "(1)")

  
  // Typst Universe Packages - Codly
  // --------------------------------------------------------
  show: codly-init.with()
  codly(  
    fill: luma(251),
    zebra-fill: luma(241),
    stroke: 1pt + luma(0),
    inset: 0.35em,
    languages: codly-languages
  )
  
  
  // Typst Universe Packages - Glossary
  // --------------------------------------------------------
  show: make-glossary


  // Styling - Captions
  // --------------------------------------------------------
  //show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: set text(size:11pt, style: "italic")

  
  // Styling - Link Highlighting 
  // --------------------------------------------------------
  show link: this => {
    if type(this.dest) == label {
      if this.body.has("children") and this.body.children.len() == 6 {
        if this.body.children.at(2) == [(] { 
          underline(text(weight: "medium", this)) 
        }
      } 
      else { text(weight: "medium", this) }
    } 
    else if type(this.dest) == str {
      context {
        if here().page() > 2 { underline(text(fill: blue.darken(60%), this)) }
        else { this }
      }
    } 
    else { underline(stroke: green, this) } 
  }


  // Styling - Level 1 Headings
  // --------------------------------------------------------
  show heading.where(level: 1): item => {
    set text(17pt)
    v(1.4em)
    item
    v(0.4em)
  }

  
  // Body
  // --------------------------------------------------------
  body
}
