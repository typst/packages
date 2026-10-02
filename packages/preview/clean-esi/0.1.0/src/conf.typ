// src/conf.typ - ESI Algiers thesis template
// Core configuration following ESI standards

#import "styles.typ": apply-styles, chapter-heading, section-heading, subsection-heading, subsubsection-heading
#import "frontmatter.typ": *
#import "utils.typ": *
#import "colors.typ": *

// ══════════════════════════════════════════════════════════════════════════════
// MAIN THESIS TEMPLATE
// ══════════════════════════════════════════════════════════════════════════════

#let thesis(
  // ─────────────────────────────────────────────────────────────────────────────
  // METADATA (Required for cover page)
  // ─────────────────────────────────────────────────────────────────────────────
  title: "Thesis Title",
  authors: (),
  supervisor: none,
  co-supervisor: (), // Array of co-supervisor names
  report-type: "Final Year Thesis",
  institution: "National Higher School of Computer Science",
  option: "Computer Systems (SIQ)",
  degree-type: "State Engineer Degree in Computer Science",
  host-organization: "",
  promotion: "2024/2025",
  defense-date: "XX/XX/2025", // Defense date (format: DD/MM/YYYY)
  jury: (),
  logo: none,
  // ─────────────────────────────────────────────────────────────────────────────
  // PAGE MARGINS (ESI Standard: 2.5cm all around)
  // ─────────────────────────────────────────────────────────────────────────────
  page-margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  // Document content
  doc,
) = {
  // Set document metadata
  set document(title: title, author: authors.join(", "))

  // ══════════════════════════════════════════════════════════════════════════════
  // COVER PAGE
  // ══════════════════════════════════════════════════════════════════════════════

  esi-cover-page(
    title: title,
    authors: authors,
    supervisor: supervisor,
    co-supervisors: co-supervisor,
    report-type: report-type,
    institution: institution,
    option: option,
    degree-type: degree-type,
    host-organization: host-organization,
    promotion: promotion,
    defense-date: defense-date,
    jury: jury,
    logo-image: logo,
  )

  // ══════════════════════════════════════════════════════════════════════════════
  // PAGE SETUP - FRONTMATTER (Roman numerals)
  // ══════════════════════════════════════════════════════════════════════════════

  set page(
    paper: "a4",
    margin: page-margin,
    numbering: "I",
    header: none,
    footer: context {
      align(right)[#text(size: 12pt, weight: "bold")[#counter(page).display()]]
    },
  )

  counter(page).update(1)

  // Apply all styles
  show: apply-styles

  doc
}

// ══════════════════════════════════════════════════════════════════════════════
// MAIN CONTENT WRAPPER
// Wraps main chapters with Arabic page numbering and running header
// ══════════════════════════════════════════════════════════════════════════════

#let main-content(body) = {
  set page(
    numbering: "1",
    header: context {
      let current-page = here().page()
      // Sectioning units that may name the running header: chapters, intro,
      // conclusion, Part dividers, and appendices. All have depth 1; chapters
      // inside `numbered-part` sit at level 2 only through the heading offset.
      let candidates = query(heading).filter(h => (
        h.location().page() <= current-page and h.depth == 1
      ))

      if candidates.len() > 0 {
        let current = candidates.last()
        if current.location().page() != current-page {
          let header-title = if current.numbering == none {
            // intro / conclusion / Part divider titles
            [#current.body]
          } else if current.numbering == "A.1" {
            let appendix-no = counter(heading).at(current.location()).first()
            [Appendix #numbering("A", appendix-no): #current.body]
          } else {
            // Numbered chapter: level 1 without parts, level 2 inside `numbered-part`.
            let chapter-no = counter(heading).at(current.location()).at(current.level - 1)
            [Chapter #chapter-no: #current.body]
          }
          align(left)[
            #text(size: 10pt, weight: "bold")[#header-title]
          ]
          v(-0.3em)
          line(length: 100%, stroke: 0.7pt + black)
          v(0.6em)
        }
      }
    },
    footer: context {
      v(8pt)
      align(right)[#text(size: 12pt, weight: "bold")[#counter(page).display()]]
    },
  )
  counter(page).update(1)
  body
}

// ══════════════════════════════════════════════════════════════════════════════
// PART WRAPPER
// Wraps the chapters belonging to one Part. The Part itself is a real level-1
// heading (see `part-divider` below), so it owns a collapsible PDF
// bookmark. Here we shift the wrapped chapters one level down (chapter → level 2,
// section → level 3, …) so they nest *under* that Part in the PDF outline, while:
//   • dropping the Part-level component from the numbering keeps chapters 1..N
//     continuous (Parts use `numbering: none`, so they never step/reset the
//     chapter counter);
//   • re-applying the shared heading renderers at the shifted levels keeps the
//     chapter/section/subsection visuals identical to the rest of the thesis;
//   • re-deriving the table/algorithm chapter number from the 2nd counter slot
//     keeps "Table N.M" correct.
// ══════════════════════════════════════════════════════════════════════════════

#let numbered-part(body) = {
  set heading(offset: 1, numbering: (..n) => {
    let nums = n.pos().slice(1) // drop Part-level slot
    if nums.len() > 0 { numbering("1.1.1", ..nums) }
  })

  show heading.where(level: 1): set heading(supplement: [Part])
  show heading.where(level: 2): set heading(supplement: [Chapter])
  show heading.where(level: 2): chapter-heading
  show heading.where(level: 3): section-heading
  show heading.where(level: 4): subsection-heading
  show heading.where(level: 5): subsubsection-heading

  show figure.where(kind: table): set figure(numbering: n => {
    numbering("1.1", counter(heading).get().at(1), n)
  })
  show figure.where(kind: "algorithm"): set figure(numbering: n => {
    numbering("1.1", counter(heading).get().at(1), n)
  })

  body
}

// ══════════════════════════════════════════════════════════════════════════════
// PART DIVIDER
// A real level-1, unnumbered heading so it owns a collapsible PDF bookmark and a
// Contents entry (its chapters nest under it via `numbered-part`). A locally
// scoped show rule renders the heading as a full divider page.
// ══════════════════════════════════════════════════════════════════════════════

#let part-divider(label, title, summary) = [
  #show heading.where(level: 1): it => page(header: none, footer: none)[
    #v(1fr)
    #align(center)[
      #text(size: 13pt, weight: "bold", tracking: 3pt)[#upper(label)]
      #v(1em)
      #line(length: 35%, stroke: 1pt + black)
      #v(1em)
      #text(size: 22pt, weight: "bold")[#title]
    ]
    #v(2.5em)
    #block(width: 100%)[
      #set par(justify: true, first-line-indent: 0pt)
      #text(size: 12pt)[#summary]
    ]
    #v(1fr)
  ]
  #heading(level: 1, numbering: none, outlined: true, bookmarked: true)[#label: #title]
]

// ══════════════════════════════════════════════════════════════════════════════
// APPENDIX CONTENT WRAPPER
// Applies appendix numbering and a simpler first-level heading style locally.
// ══════════════════════════════════════════════════════════════════════════════

#let appendix-content(body) = {
  show figure.where(kind: table): set figure(numbering: n => {
    let appendix-no = counter(heading).get().at(0)
    numbering("A.1", appendix-no, n)
  })

  show heading.where(level: 1): it => context {
    set par(first-line-indent: 0pt, justify: false)
    set align(if text.dir == rtl { right } else { left })
    pagebreak(weak: true)

    if it.numbering != none {
      counter(figure.where(kind: table)).update(0)
      block(above: 30pt, below: 18pt, sticky: true)[
        #text(size: 22pt, weight: "bold")[Appendix #counter(heading).display(): #it.body]
      ]
    } else {
      block(above: 30pt, below: 18pt, sticky: true)[
        #text(size: 22pt, weight: "bold")[#it.body]
      ]
    }
  }

  set heading(numbering: "A.1")
  counter(heading).update(0)
  body
}

// ══════════════════════════════════════════════════════════════════════════════
// RE-EXPORTS
// ══════════════════════════════════════════════════════════════════════════════

#import "frontmatter.typ": list-of-figures, list-of-tables, table-of-contents
#import "utils.typ": definition, divider, info-box, quote-block, todo, warning-box
