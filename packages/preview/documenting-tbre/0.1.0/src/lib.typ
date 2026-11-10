// Export your helper functions
#import "@preview/wordometer:0.1.5": word-count-of

#let hl = highlight

/// Define an abbreviation and optionally display it inline with the full form on first use.
///
/// - abbreviation (string): The abbreviation to define
/// - full (string): The full form of the abbreviation
/// - inline (boolean): Whether to display the abbreviation inline (default: true)
/// -> content | none
/// 
/// Example usage:
/// ```typst
/// #abbrev("TBRe", "Team Bath Racing Electric") // Displays "TBRe (Team Bath Racing Electric)" and logs the abbreviation for the list of abbreviations
/// #abbrev("CAD", "Computer-Aided Design", inline: false) // Only logs the abbreviation without displaying the full form in the text
/// ```
/// 
#let abbrev(abbreviation, full, inline: true) = {
  [
    #metadata((abbrev: abbreviation, full: full)) <acronym>
    #if { inline } { [#abbreviation (#full)] }
  ]
}

/// The main template function
/// 
/// - title (string | content): The document title, shown on the title page
/// - doc-type (string | content): The type of document (e.g. "Design Report", "Technical Paper"), shown on the title page
/// - author (string): The name of the author, shown on the title page
/// - email (string): The email of the author, shown on the title page
/// - reviewers (array): An array of reviewer names, shown on the title page
/// - date (datetime): The date of document creation, shown on the title page (automatically set to today's date by default)
/// - doc-id (string): A unique document identifier, shown on the title page (must be set manually or via an external script)
/// - changelog (content): A changelog table, shown on the title page (optional, can be generated automatically using git-cliff and included as a .typ file)
/// - references (content): A bibliography file, shown on the title page (optional, can be generated automatically using a .bib file and the bibliography function)
/// - show-contents (boolean): Whether to show the table of contents (default: true)
/// - show-abbreviations (boolean): Whether to show the list of abbreviations (default: true)
/// - show-lists (boolean): Whether to show the list of figures and tables (default: true)
/// - auto-pagebreak (boolean): Whether to automatically insert a page break after the title page and table of contents (default: true)
/// -> content
/// 
/// ### Example usage:
/// 
/// ```typst
/// #import "@preview/documenting-tbre:0.1.0": template
/// 
/// #show: template.with(
///   title: "My Design Report",
///   doc-type: "Design Report",
///   author: "John Doe",
///   email: "john.doe@emaildomain.com",
/// )
///
#let template(
  title: "Document Title",
  doc-type: "Template",
  author: "Unknown Author",
  email: "Unknown Email",
  reviewers: (), // Accepts an array of strings
  date: datetime.today(), // Automatically pulls today's date
  doc-id: "TBD", // Must be set manually or via an external script
  changelog: none,
  references: none,
  show-contents: true,
  show-abbreviations: true,
  show-lists: true,
  auto-pagebreak: true,
  body,
) = [
  // ==========================================
  // MARK: PREAMBLE
  // ==========================================
  #let pagebreak-mask() = {
    if auto-pagebreak [#pagebreak()]
    else {none}
  }
  #set page(margin: (top: 2.8cm, rest: 2.5cm))
  #set text(font: "Roboto", size: 11pt)
  #show figure.where(kind: table): set figure.caption(position: top)
  #show figure.caption: set align(left)
  #set page(numbering: "i")
  #show table: set par(justify: false)

  #set figure(
    numbering: (..nums) => {
      let section = counter(heading).get().first()
      let fig = nums.pos()
      ((section,) + fig).map(str).join(".")
    },
  )

  #show heading: it => {
    if it.level == 1 {
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: image)).update(0)
    }
    it
  }

  // Title page IMECHE header and footer
  #set page(
    header: place(top + left, dx: -2.48cm, dy: 0.5cm)[#image(
      "/src/assets/tbre_page_header.svg",
      width: 21cm
    )],
    footer: place(top + left, dx: -2.48cm, dy: -0.5cm)[#image(
      "/src/assets/tbre_page_footer.svg",
      width: 21cm
    )],
  )

  #set par(justify: true)
  #counter(heading).update(0)
  #set heading(numbering: "I")

  #align(center)[
    // Insert the dynamic title
    #text(size: 28pt, fill: rgb("#005dab"), weight: "bold")[#title]
    #table(
      align: left,
      columns: (auto, 2fr),
      [*Document Type*], [#doc-type],
      [*Author*], [#link("mailto:" + email)[#author (#email)]],
      // Join the array of reviewers into a comma-separated string
      [*Reviewers*], [#reviewers.join(", ")],
      // Format the automated date
      [*Created On*], [#date.display("[year]-[month]-[day]")],
      // Automatically output the word count using wordometer
      [*Words*], [#word-count-of(body).words],
      [*Document Id*], [#doc-id],
    )
    // Insert Changelog
    #if changelog != none [
      #text(size: 18pt, fill: rgb("#005dab"), weight: "bold")[Changelog]
      #changelog
    ]
  ]
  #pagebreak-mask()
  #if show-contents [
    #outline(title: [Table of Contents])
    #pagebreak-mask()
  ]

  // Dynamic List of Figures
  #context [
    // Query the document for all image figures
    #let image-figs = query(figure.where(kind: image))

    // Only render the section if the query found at least one image
    #if { image-figs.len() > 0 and show-lists } [
      = List of Figures
      #outline(title: none, target: figure.where(kind: image))
    ]
  ]

  // Dynamic List of Tables
  #context [
    // Query the document for all table figures
    #let table-figs = query(figure.where(kind: table))

    // Only render the section if the query found at least one table
    #if { table-figs.len() > 0 and show-lists } [
      = List of Tables
      #outline(title: none, target: figure.where(kind: table))
    ]
  ]
  // Dynamic List of Abbreviations
  #context [
    #let acronym-data = query(<acronym>)
    #if {acronym-data.len() > 0 and show-abbreviations} [
      = List of Abbreviations
      #table(
        columns: (auto, 1fr),
        align: left + horizon,
        table.header([ *Abbreviation / Acronym* ], [ *Definition* ]),
        // dynamically map over the metadata stored in main.typ
        ..acronym-data.map(a => (a.value.abbrev, a.value.full)).flatten(),
      )
    ]
  ]
  #pagebreak-mask()

  // ==========================================
  // MARK: MAIN BODY SETUP
  // ==========================================
  #set page(numbering: "1")
  #counter(page).update(1)
  #counter(heading).update(0)
  #set heading(numbering: "1.1")

  // Render the actual document body here
  #body

]

// ==========================================
// MARK: APPENDIX TEMPLATE
// ==========================================
#let appendix(body) = {
  pagebreak()
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "A.1", supplement: "")

  body
}
