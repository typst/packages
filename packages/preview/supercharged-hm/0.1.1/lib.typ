// Copyright 2024 Danny Seidel https://github.com/DannySeidel
// Copyright 2025 Felix Schladt https://github.com/FelixSchladt

#import "imports.typ": *

#let std-bibliography = bibliography

#let hm-template(
  title: none,
  subtitle: none,
  doc-type: none,
  top-remark: none,
  show-table-of-contents: true,
  toc-depth: 2,
  appendix: none,
  language: "de",
  glossary: none,
  bibliography: none,
  bib-style: "ieee",
  font: "Roboto",
  version: "0.1",
  authors: "",
  date: datetime.today(),
  project-logo: none,
  project-logo-dimensions: (auto, auto),
  titlepage-logo: none,
  titlepage-logo-dimensions: (auto, auto),
  lastpage: none,
  text-size: 12pt, //textsize for non header & footer text
  body,
) = {
  // Setup glossary
  if glossary != none {
    show: make-glossary
    register-glossary(glossary)
  }
  
  // Default to subtitle but enable manual setting
  if top-remark == none {
    top-remark = subtitle
  }
  
  // Design  configurations
  let accent_line = line(length: 100%, stroke: (paint: hm-black, thickness: 1pt));

  // Fonts
  let body-font = font 
  let heading-font = font

  let text-size-template = 10pt
  set text(font: body-font, lang: language, text-size-template) //template text size
  set par(justify: true)
  show heading: set text(weight: "semibold", font: heading-font, fill: hm-grey-dark)

  set page(
    margin: (
      top: 6em, 
      bottom: 6em, 
      rest: 6em // Side margins
      ))

  titlepage(
    title: title,
    subtitle: subtitle,
    authors: authors,
    logo: titlepage-logo,
    logo-dimensions: titlepage-logo-dimensions,
    toc-depth: toc-depth,
    text-size: text-size-template,
  )
  
  set page(
    header: context {
        set text(text-size-template)
        grid(
          columns: (40%, 20%, 40%),
          align(left)[
            #doc-type
          ],
          align(center)[
            #set align(bottom)
            #set image(height: 25pt)
            #image("assets/HM_Logo_RGB.png")
          ],
          align(right)[
            #set par(justify: false)
            #top-remark
          ]
        )
      
      accent_line
    }, 
    footer: context{
      //accent_line
      set text(text-size-template)
      grid(
        columns: (1fr, 1fr),
        align(left)[
          #if version != none [
            #authors #date.display("[year]")\
            Version #version
          ] else [
            #authors
          ]
          
        ],
        align(right)[
          #numbering(
            "1 / 1",
            ..counter(page).get(),
            ..counter(page).at(<end>),
          )
        ]
      )
    }
  )
  
  // Heading settings
  show heading.where(level: 1): it => {
    pagebreak()
    text(size: 20pt, it)
    v(1.25em)
  }
  show heading.where(level: 2): it => v(1em) + it + v(1em)
  show heading.where(level: 3): it => v(1em) + it + v(0.75em)

  set text(text-size)

  // --------- Space for Glossary Abstract etc ----------

  
  // Display glossary.
  if glossary != none {
    heading(level: 1, linguify("base_glossary", from: lang-db))
    // This uses Glossarium to print the glossary
    // for configuration please refer to glossarium documentation
    set par(justify: false)
    set list(spacing: 0.2em)
    set block(spacing: 0.2em)
    print-glossary(
      glossary, 
      disable-back-references: true
    )
  }

  // ---------- Setup Chapter Headings -------------------

  // Do numbered headings
  set heading(numbering: "1.")

  // ----------- Setup Completed - Content ---------------

  body

  // ----------- Other stuff - Bib gloss appendix etc ----

  
  // Non numbered headings
  set heading(numbering: none)


  // Display bibliography.
  if bibliography != none {
    heading(level: 1, linguify("base_references", from: lang-db))
    set std-bibliography(
      title: none,
      style: bib-style
      )
    bibliography
  }

  [#metadata(none)<end>]
  // reset page numbering and set to alphabetic numbering
  set page(
    numbering: "a",
    footer: context align(right, numbering(
      "a/a", 
      ..counter(page).get(),
      ..counter(page).at(<end_app>)
    ))
  )
  counter(page).update(1)

  // Display appendix.
  if appendix != none {
    heading(level: 1, linguify("base_appendix", from: lang-db))
    appendix
  }

  // Last Page, possible for reference, versioning & contact information
  if lastpage != none {
    lastpage
  }

  [#metadata(none)<end_app>]
}
