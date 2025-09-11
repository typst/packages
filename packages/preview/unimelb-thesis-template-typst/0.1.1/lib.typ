// =================================
// University of Melbourne Thesis Template Library
// =================================

// Import utilities
#import "utils/style.typ": *

// Import page components
#import "pages/title.typ": title-page
#import "pages/abstract.typ": abstract-page
#import "pages/declaration.typ": declaration-page
#import "pages/acknowledgements.typ": acknowledgements-page
#import "pages/preface.typ": preface-page
#import "pages/front-matter.typ": toc-page, lof-page, lot-page, loa-page
#import "pages/landscape-sample.typ": landscape-sample-page
#import "pages/glossary.typ": glossary-page

// Import layout components
#import "layouts/document.typ": front-matter-layout, main-matter-layout, appendix-layout

// =================================
// Main Thesis Template Function
// =================================

#let thesis(
  title: none,
  subtitle: none,
  author: none,
  degree: none,
  department: none,
  school: none,
  university: none,
  supervisor: none,
  co_supervisor: none,
  submission_date: none,
  abstract: none,
  keywords: (),
  acknowledgements: none,
  declaration: none,
  preface: none,
  blind: false,
  double_sided: false,
  body
) = {
  // Set document metadata
  set document(
    title: title,
    author: author,
    keywords: keywords,
  )

  // =================================
  // Front Matter
  // =================================

  front-matter-layout[
    // Title page
    #title-page(
      title: title,
      subtitle: subtitle,
      author: author,
      degree: degree,
      department: department,
      school: school,
      university: university,
      supervisor: supervisor,
      co_supervisor: co_supervisor,
      submission_date: submission_date,
      blind: blind,
    )

    // Abstract
    #if abstract != none {
      abstract-page(abstract, keywords: keywords)
    }

    // Declaration
    #if declaration != none {
      declaration-page(
        candidate_name: author,
        thesis_title: title,
        degree: degree,
        word_count: "approximately XX,XXX",
        includes_publications: false,
        ai_usage: none,
        third_party_assistance: none,
      )
    }

    // Acknowledgements
    #if acknowledgements != none and not blind {
      acknowledgements-page(acknowledgements)
    }

    // Preface
    #if preface != none {
      heading("Preface", numbering: none, outlined: false)
      v(1em)
      preface
      pagebreak()
    }
  ]

  // =================================
  // Main Content
  // =================================

  main-matter-layout(title: title, double-sided: double_sided)[
    #body
  ]
}

// =================================
// Additional Utility Functions
// =================================

// Proof environment
#let proof(body) = {
  block[
    *Proof.*#h(1em)
    #body
    #h(1fr) $square$
  ]
}

// Enhanced figure with subfigures
#let figurex = figure.with(
  kind: "figure",
  supplement: "Figure",
)

// Enhanced table with advanced features
#let tablex-enhanced = tablex.with(
  auto-lines: false,
  header-rows: 1,
  header-hlines-have-priority: true,
  column-gutter: 1em,
)

// Word count display
#let display-word-count(text) = {
  let count = word-count(text)
  [Word count: #count]
}

// Character count display
#let display-char-count(text) = {
  let count = char-count(text)
  [Character count: #count]
}

// Page count display
#let display-page-count = context {
  let count = counter(page).final().first()
  [Page count: #count]
}

// =================================
// Bibliography Setup
// =================================

// Custom bibliography function with APA-like styling
#let thesis-bibliography(path, style: "apa") = {
  heading("Bibliography", numbering: none)
  bibliography(path, style: style)
}

// =================================
// Export all components
// =================================
