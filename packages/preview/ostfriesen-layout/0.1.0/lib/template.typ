// filepath: /Users/tobi/Desktop/Typst-Template/lib/template.typ
#import "translations.typ": translations
#import "pages/cover.typ": create-cover-page
#import "pages/abstract.typ": create-abstract-page
#import "pages/outline.typ": create-outline
#import "pages/list-of-figures.typ": create-list-of-figures
#import "pages/list-of-tables.typ": create-list-of-tables
#import "pages/listings.typ": create-listings
#import "pages/declaration-of-independent-processing.typ": create-declaration-of-independent-processing
#import "pages/dependencies.typ": *  // Import dependencies for the template

#let create-document(
  title: none,
  authors: (),
  matriculation-numbers: (),
  date: none,
  document-type: none,
  faculty: none,
  module: none,
  course-of-studies: none,
  abstract: none,
  keywords: (),
  supervisor1: none,
  supervisor2: none,
  supervisor3: none,
  company: none,
  company-supervisor: none,
  include-declaration: true,
  lang: "en",
  font: "New Computer Modern",
  font-size: 11pt,
  line-spacing: 1.5,
  enable-code-highlighting: true,
  lower-chapter-headings: false,
  body
) = {
  // Define the document (use first author for metadata)
  set document(title: title, author: if authors.len() > 0 { authors.at(0) } else { none })

  // Initialize codly for code highlighting if enabled
  if enable-code-highlighting {
    show: codly-init.with()
    // Configure codly with default settings
    codly(
      languages: codly-languages,
    )
  }
  // Make all table figures breakable across pages
  show figure.where(kind: table): set block(breakable: true)
  
  // Make table header cells bold
  show grid.cell.where(y: 0): set text(weight: "bold")
  
  // Constants for formatting
  let HEADING-1-TOP-MARGIN = if lower-chapter-headings { 20pt } else { 104pt }
  let PAGE-MARGIN-TOP = 37mm
  
  // Set font and typography
  set text(font: font, size: font-size, lang: lang)
  
  // Set up page configuration (page margins as in the original template)
  set page(
    paper: "a4", 
    margin: (left: 31.5mm, right: 31.5mm, top: PAGE-MARGIN-TOP, bottom: 56mm),
    binding: left,
    number-align: right,
    header-ascent: 24pt,
    header: context {
      // Check if we have any main headings
      let headings-before = query(heading.where(level: 1).before(here()))
      if headings-before.len() == 0 {
        return
      }
      
      // Check if we are after the first heading
      let first-heading-page = headings-before.first().location().page()
      if here().page() <= first-heading-page {
        return
      }

      // Find the current heading for this page
      let current-heading = headings-before.last()
      let current-level = counter(heading).at(current-heading.location())
      
      // Check if a new chapter begins on this page (and don't show header if it does)
      let headings-on-page = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
      if headings-on-page.len() > 0 {
        let heading-pos = headings-on-page.first().location().position()
        if heading-pos.y <= (HEADING-1-TOP-MARGIN + PAGE-MARGIN-TOP) {
          // Chapter starts on this page, don't show header
          return
        }
      }

      // Header with line and text
      set text(size: 10pt, style: "oblique")
      box(width: 100%, height: auto, {
        // The horizontal line
        line(length: 100%, stroke: .75pt)
        
        // The chapter title with number above, left-aligned instead of centered
        place(
          top + left,
          dy: -1.25em,
          if current-heading.has("numbering") and current-heading.numbering != none {
            text(weight: "medium")[#numbering(current-heading.numbering, ..current-level) #current-heading.body]
          } else {
            text(weight: "medium")[#current-heading.body]
          }
        )
      })
    },
    footer: context {
      if here().page() > 2 {
        align(right)[
          #text(size: 10pt)[
            #counter(page).display()  // Simply display the current page number format
          ]
        ]
      }
    }
  )
  
  // Set chapter numbering
  set heading(numbering: "1.1")

  // Configure paragraph spacing
  set par(leading: 1em, justify: true)
  
  // Formatting for headings as in the original
  show heading: h => {
    let top-margin = 0pt   
    let bottom-margin = 0pt
    let text-counter = text(counter(heading).display())
    let text-body = text(h.body)

    if h.level == 1 {
      // Level 1 heading (Chapter)
      text-counter = text(counter(heading).display(), font: "New Computer Modern", size: 21pt, weight: 600)
      text-body = text(h.body, font: "New Computer Modern", size: 21pt, weight: 600)
      
      // New page for main chapters
      pagebreak(weak: true)
      
      top-margin = HEADING-1-TOP-MARGIN
      bottom-margin = 20pt
    } else if h.level == 2 {
      // Level 2 heading (Section)
      text-counter = text(counter(heading).display(), size: 14pt)
      text-body = text(h.body, size: 14pt)

      top-margin = 20pt
      bottom-margin = 15pt
    } else {
      // Level 3 heading (Subsection, etc.)
      text-counter = text(counter(heading).display(), size: 12pt)
      text-body = text(h.body, size: 12pt)

      top-margin = 15pt
      bottom-margin = 10pt
    }

    // Draw headings
    v(top-margin)
    if h.numbering != none {
      grid(
        columns: 2,
        gutter: 10pt,
        text-counter,
        text-body
      )
    } else {
      text-body
    }
    v(bottom-margin)
  }

  // Set the language
  set text(lang: lang, region: if lang == "de" { "DE" } else { "US" })

  // Localization
  let t = translations.at(if lang in translations.keys() { lang } else { "en" })

  // Create cover page (no page numbers)
  set page(numbering: none)
  
  create-cover-page(
    title: title,
    authors: authors,
    matriculation-numbers: matriculation-numbers,
    date: date,
    document-type: document-type,
    faculty: faculty,
    module: module,
    course-of-studies: course-of-studies,
    supervisor1: supervisor1,
    supervisor2: supervisor2,
    supervisor3: supervisor3,
    company: company,
    company-supervisor: company-supervisor,
    lang: lang
  )

  // Front matter with Roman numerals
  counter(page).update(3)  // Start at page iii (3)
  set page(numbering: "i", number-align: right)

  // Abstract page
  if abstract != none {
    create-abstract-page(
      abstract: abstract,
      keywords: keywords,
      lang: lang,
      title: title,
      authors: authors
    )
  }

  // Create outline (TOC) - directly after Abstract without page break
  create-outline(
    title: t.at("outline"),
    lang: lang
  )
  // Only insert page break if figures exist
  context {
    if query(figure.where(kind: image)).len() > 0 {
      pagebreak()
      
      // List of figures
      create-list-of-figures(
        title: t.at("list-of-figures"),
        lang: lang
      )
    }
  }
  
  // Only insert page break if tables exist
  context {
    if query(figure.where(kind: table)).len() > 0 {
      pagebreak()
      
      // List of tables
      create-list-of-tables(
        title: t.at("list-of-tables"),
        lang: lang
      )
    }
  }
  
  // Only insert page break if code listings exist
  context {
    if query(figure.where(kind: raw)).len() > 0 {
      pagebreak()
      
      // Listings
      create-listings(
        title: t.at("listings"),
        lang: lang
      )
    }
  }
  
  // Always a page break before the main content
  pagebreak()

  // Reset page counter for main content with Arabic numerals
  counter(page).update(1)
  set page(numbering: "1")
  
  // Main content
  body
  

  // Declaration of independent processing
  if include-declaration {
    pagebreak()
    create-declaration-of-independent-processing(
      authors: authors,
      title: title,
      place: none,
      date: date,
      lang: lang
    )
  }
}