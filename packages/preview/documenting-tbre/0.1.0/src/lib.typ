// Export your helper functions
#import "@preview/wordometer:0.1.5": word-count-of

#let hl = highlight
#let abbrev(abbreviation, full, inline: true) = {
  [
    #metadata((abbrev: abbreviation, full: full)) <acronym>
    #if { inline } { [#abbreviation (#full)] }
  ]
}

// The main template function
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
