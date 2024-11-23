// =================================================================
// Template Version and Date
// =================================================================
#let template-version = version(0, 0, 1)
#let template-date = datetime.today().display("[day]. [month repr:long] [year]")
#let template-info = [*Template Version #template-version from #template-date*]

#let template-purpose = "template-purpose"
#let template-licence = "template-licence"
#let template-owner = "Ferdinand Burkhardt"


// Import Utilities
// =================================================================
#import "../Studi/utilities/textbox.typ": *
#import "../Studi/utilities/reviewer.typ": *
#import "../Studi/utilities/utilities.typ"


// Import Typst Universe Packages - Drawing and Diagrams
// =================================================================
// https://typst.app/universe/package/cetz
#import "@preview/cetz:0.3.1": *

// https://typst.app/universe/package/fletcher
#import "@preview/fletcher:0.5.2" as fletcher: diagram, node, edge
#import fletcher.shapes: diamond

// Gantt Charts
// https://typst.app/universe/package/timeliney
#import "@preview/timeliney:0.0.1": *



// Import Typst Universe Packages - Code
// =================================================================
// https://typst.app/universe/package/codelst
#import "@preview/codly:1.0.0": *

// https://typst.app/universe/package/codly-languages/
#import "@preview/codly-languages:0.1.1": *



// Import Typst Universe Packages - Bibliography
// =================================================================
// Acronyms 
// TODO


// Glossary
// https://typst.app/universe/package/glossarium
#import "@preview/glossarium:0.5.1": make-glossary, register-glossary, print-glossary, gls, glspl


#import "@preview/wrap-it:0.1.0": wrap-content

// =================================================================
// Header
// =================================================================
#let doc-header() = {
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


// =================================================================
// General Document Config
// =================================================================
#let config(body) = {
  
  // Page Configuration
  // https://typst.app/docs/reference/layout/page/
  // --------------------------------------------------------------
  set page(
    paper: "a4",
    margin: (
      top: 2.4cm,
      bottom: 2.7cm,
      left: 2.4cm,
      right: 2.4cm,
    ),
    header: doc-header(),
  )

  // Text Configuration
  // https://typst.app/docs/reference/text/text/
  // --------------------------------------------------------------
  set text(
    lang: "en",
    font: "Lato",
    size: 12pt,
    hyphenate: false,
  )

  // Headings
  // https://typst.app/docs/reference/model/heading/
  // --------------------------------------------------------------
  set heading(
    numbering: none,
    outlined: true, 
    bookmarked: true,
  )

  // Paragraphs
  // https://typst.app/docs/reference/model/par/
  // --------------------------------------------------------------
  set par(
    justify: true,
    leading: 0.52em,
  )

  // Bullet List
  // https://typst.app/docs/reference/model/list/#parameters-indent
  // --------------------------------------------------------------
  set list(
    //tight: true,
    //spacing: 1.2em, // default: 1.2em
    indent: 12pt,
  )

  // Numbered List
  // https://typst.app/docs/reference/model/enum/#parameters-indent
  // --------------------------------------------------------------
  set enum(
    indent: 12pt,
  )

  // Figures
  // https://typst.app/docs/reference/model/figure/
  // --------------------------------------------------------------
  set figure(
    placement: none,
  )
  
  // Body
  // https://typst.app/docs/reference/foundations/function/
  // --------------------------------------------------------------
  body
}
