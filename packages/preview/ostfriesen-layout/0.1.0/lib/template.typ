// filepath: /Users/tobi/Desktop/Typst-Template/lib/template.typ
#import "translations.typ": translations
#import "pages/cover.typ": create_cover_page
#import "pages/abstract.typ": create_abstract_page
#import "pages/outline.typ": create_outline
#import "pages/list-of-figures.typ": create_list_of_figures
#import "pages/list-of-tables.typ": create_list_of_tables
#import "pages/listings.typ": create_listings
#import "pages/declaration-of-independent-processing.typ": create_declaration_of_independent_processing
#import "pages/dependencies.typ": *  // Import dependencies for the template

#let create_document(
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
  let HEADING_1_TOP_MARGIN = if lower-chapter-headings { 20pt } else { 104pt }
  let PAGE_MARGIN_TOP = 37mm
  
  // Set font and typography
  set text(font: font, size: font-size, lang: lang)
  
  // Set up page configuration (page margins as in the original template)
  set page(
    paper: "a4", 
    margin: (left: 31.5mm, right: 31.5mm, top: PAGE_MARGIN_TOP, bottom: 56mm),
    binding: left,
    number-align: right,
    header-ascent: 24pt,
    header: context {
      // Check if we have any main headings
      let headings_before = query(heading.where(level: 1).before(here()))
      if headings_before.len() == 0 {
        return
      }
      
      // Check if we are after the first heading
      let first_heading_page = headings_before.first().location().page()
      if here().page() <= first_heading_page {
        return
      }

      // Find the current heading for this page
      let current_heading = headings_before.last()
      let current_level = counter(heading).at(current_heading.location())
      
      // Check if a new chapter begins on this page (and don't show header if it does)
      let headings_on_page = query(heading.where(level: 1)).filter(h => h.location().page() == here().page())
      if headings_on_page.len() > 0 {
        let heading_pos = headings_on_page.first().location().position()
        if heading_pos.y <= (HEADING_1_TOP_MARGIN + PAGE_MARGIN_TOP) {
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
          if current_heading.has("numbering") and current_heading.numbering != none {
            text(weight: "medium")[#numbering(current_heading.numbering, ..current_level) #current_heading.body]
          } else {
            text(weight: "medium")[#current_heading.body]
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
    let top_margin = 0pt   
    let bottom_margin = 0pt
    let text_counter = text(counter(heading).display())
    let text_body = text(h.body)

    if h.level == 1 {
      // Level 1 heading (Chapter)
      text_counter = text(counter(heading).display(), font: "New Computer Modern", size: 21pt, weight: 600)
      text_body = text(h.body, font: "New Computer Modern", size: 21pt, weight: 600)
      
      // New page for main chapters
      pagebreak(weak: true)
      
      top_margin = HEADING_1_TOP_MARGIN
      bottom_margin = 20pt
    } else if h.level == 2 {
      // Level 2 heading (Section)
      text_counter = text(counter(heading).display(), size: 14pt)
      text_body = text(h.body, size: 14pt)

      top_margin = 20pt
      bottom_margin = 20pt
    } else {
      // Level 3 heading (Subsection, etc.)
      text_counter = text(counter(heading).display(), size: 9pt)
      text_body = text(h.body, size: 12pt)

      top_margin = 20pt
      bottom_margin = 20pt
    }

    // Draw headings
    v(top_margin)
    if h.numbering != none {
      grid(
        columns: 2,
        gutter: 10pt,
        text_counter,
        text_body
      )
    } else {
      text_body
    }
    v(bottom_margin)
  }

  // Set the language
  set text(lang: lang, region: if lang == "de" { "DE" } else { "US" })

  // Localization
  let t = translations.at(if lang in translations.keys() { lang } else { "en" })

  // Create cover page (no page numbers)
  set page(numbering: none)
  
  create_cover_page(
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
    create_abstract_page(
      abstract: abstract,
      keywords: keywords,
      lang: lang,
      title: title,
      authors: authors
    )
  }

  // Create outline (TOC) - directly after Abstract without page break
  create_outline(
    title: t.at("outline"),
    lang: lang
  )
  // Only insert page break if figures exist
  context {
    if query(figure.where(kind: image)).len() > 0 {
      pagebreak()
      
      // List of figures
      create_list_of_figures(
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
      create_list_of_tables(
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
      create_listings(
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
    create_declaration_of_independent_processing(
      authors: authors,
      title: title,
      place: none,
      date: date,
      lang: lang
    )
  }
}