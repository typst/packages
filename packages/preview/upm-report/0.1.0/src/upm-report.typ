#let upm-report(
  // Cover page info
  title: "Title of the Work",
  author: "Author's name",
  supervisor: "Supervisor's Name",
  date: datetime.today(),
  // Acknowledgements and Abstract
  acknowledgements: none,
  abstract-en: none,
  keywords-en: none,
  // License info
  license-name: "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International",
  license-logo: "assets/cc-by-nc-sa.svg",
  license-link: "https://creativecommons.org/licenses/by-nc-sa/4.0/",
  // School configuration
  university: "Universidad Politécnica de Madrid",
  school-name: "E.T.S. de Ingeniería de Sistemas Informáticos",
  school-address: "Campus Sur UPM, Carretera de Valencia (A-3), km. 7\n28031, Madrid, España",
  school-abbr: "ETSISI",
  report-type: "Bachelor's thesis",
  degree-name: "Grado en Ingeniería de Tecnologías de la Sociedad de la Información",
  school-color: rgb(32, 130, 192),
  school-logo: "assets/etsisi-logo.svg",
  school-watermark: "assets/upm-watermark.png",
  // Bibliography configuration
  bibliography-file: none,
  bibliography-style: "ieee",
  body,
) = {
  // Cover page
  page(
    margin: 0cm,
    numbering: none,
  )[
    // Left colored bar
    #place(
      left + top,
      rect(
        width: 2cm,
        height: 100%,
        fill: school-color,
      ),
    )

    // School watermark
    #if school-watermark != none {
      place(
        right + bottom,
        image(school-watermark, width: 90%),
      )
    }

    // Content
    #pad(
      left: 3cm,
      right: 2cm,
      top: 3cm,
      bottom: 3cm,
      {
        set text(size: 12pt)

        // Header info
        upper(university)
        linebreak()
        text(weight: "bold")[#upper(school-name)]
        linebreak()
        upper(report-type)
        linebreak()
        text(weight: "bold")[#upper(degree-name)]

        v(1fr)

        // Title
        set text(size: 34pt, weight: "bold")
        set par(leading: 0.5em, justify: false)
        title

        v(1fr)

        // Author and supervisor
        set text(size: 14pt, weight: "regular")
        text(weight: "bold")[Written by: ]
        author
        linebreak()
        text(weight: "bold")[Supervised by: ]
        supervisor
        linebreak()
        [Madrid, #date.display("[day]/[month]/[year]")]
      },
    )
  ]

  // Metadata and License
  page(
    header: none,
    numbering: none,
  )[
    #v(1fr)

    #set text(size: 12pt)
    #set par(justify: false, leading: 0.65em)

    // Document metadata
    #emph(title)

    // Tighter paragraph spacing just for author/supervisor/date
    #[
      #set par(spacing: 0.5em)

      *Written by:* #author

      *Supervised by:* #supervisor

      #report-type, #date.display("[day]/[month]/[year]")
    ]

    *#school-name*

    #school-address

    #v(1.5em)
    #line(length: 100%, stroke: 0.5pt)
    #v(1em)

    // License text and logo in grid layout
    #grid(
      columns: (1fr, auto),
      column-gutter: 4em,
      align: (left, right),
      [
        #set par(justify: true)
        This work is licensed under #if license-link != none { link(license-link)[#license-name] } else {
          license-name
        }.
      ],
      if license-logo != none {
        if license-link != none {
          link(license-link)[#image(license-logo, width: 80pt)]
        } else {
          image(license-logo, width: 80pt)
        }
      },
    )

    #v(5em)
  ]

  // Acknowledgements page (optional)
  if acknowledgements != none {
    page(
      header: none,
      numbering: none,
    )[
      #set text(size: 12pt)

      #block(
        above: 0pt,
        below: 25pt,
        {
          set text(size: 30pt, weight: "regular")
          align(right)[Acknowledgements]
          v(-0.9em)
          line(length: 100%, stroke: 0.5pt)
          v(0.5em)
        },
      )

      #set par(justify: true, leading: 0.65em)
      #acknowledgements
    ]
  }

  // Abstract page (optional)
  if abstract-en != none {
    page(
      header: none,
      numbering: none,
    )[
      #set text(size: 12pt)

      #block(
        above: 0pt,
        below: 25pt,
        {
          set text(size: 30pt, weight: "regular")
          align(right)[Abstract]
          v(-0.9em)
          line(length: 100%, stroke: 0.5pt)
          v(0.5em)
        },
      )

      #set par(justify: true, leading: 0.65em)

      #abstract-en

      #if keywords-en != none [
        #v(1em)
        *Keywords:* #keywords-en
      ]
    ]
  }

  // Table of Contents
  page(
    header: none,
    numbering: none,
  )[
    // Style the outline entries
    #show outline.entry.where(level: 1): it => {
      v(18pt, weak: true)
      text(fill: school-color)[#strong(it)]
    }

    // Style level 2 entries in blue
    #show outline.entry.where(level: 2): it => {
      v(12pt, weak: true)
      text(fill: school-color)[#it]
    }

    #set text(size: 12pt)

    // Custom title styled like chapter headings
    #block(
      above: 0pt,
      below: 25pt,
      {
        set text(size: 30pt, weight: "regular")
        align(right)[Table of Contents]
        v(-0.9em)
        line(length: 100%, stroke: 0.5pt)
        v(0.5em)
      },
    )

    #set par(leading: 1.8em)

    #outline(
      title: none,
      depth: 2,
      indent: auto,
    )
  ]

  // List of Figures (optional - only shows if document has figures)
  context {
    let figures = query(figure.where(kind: image))
    if figures.len() > 0 {
      page(
        header: none,
        numbering: none,
      )[
        // Style outline entries in blue with spacing
        #show outline.entry: it => {
          v(12pt, weak: true)
          text(fill: school-color)[#it]
        }

        #set text(size: 12pt)

        #block(
          above: 0pt,
          below: 25pt,
          {
            set text(size: 30pt, weight: "regular")
            align(right)[List of Figures]
            v(-0.9em)
            line(length: 100%, stroke: 0.5pt)
            v(0.5em)
          },
        )

        #set par(leading: 1.8em)

        #outline(
          title: none,
          target: figure.where(kind: image),
        )
      ]
    }
  }

  // List of Tables (optional - only shows if document has tables)
  context {
    let tables = query(figure.where(kind: table))
    if tables.len() > 0 {
      page(
        header: none,
        numbering: none,
      )[
        // Style outline entries in blue with spacing
        #show outline.entry: it => {
          v(12pt, weak: true)
          text(fill: school-color)[#it]
        }

        #set text(size: 12pt)

        #block(
          above: 0pt,
          below: 25pt,
          {
            set text(size: 30pt, weight: "regular")
            align(right)[List of Tables]
            v(-0.9em)
            line(length: 100%, stroke: 0.5pt)
            v(0.5em)
          },
        )

        #set par(leading: 1.8em)

        #outline(
          title: none,
          target: figure.where(kind: table),
        )
      ]
    }
  }

  // Page setup for content
  set page(
    paper: "a4",
    margin: (top: 3.5cm, bottom: 3cm, left: 2.5cm, right: 2.5cm),
    header: context {
      let page-num = counter(page).get().first()

      // Don't show header on first page
      if page-num <= 1 {
        return
      }

      // Check if current page has a chapter heading
      let current-page = here().page()
      let headings-on-page = query(heading.where(level: 1)).filter(h => h.location().page() == current-page)

      // Don't show header on pages with chapter headings
      if headings-on-page.len() > 0 {
        return
      }

      // Show header on all other pages
      set text(fill: school-color, size: 10pt)

      let chapter-title = {
        let elems = query(heading.where(level: 1))
        if elems.len() > 0 {
          let relevant = elems.filter(h => h.location().page() <= current-page)
          if relevant.len() > 0 {
            upper(relevant.last().body)
          }
        }
      }

      grid(
        columns: (1fr, auto),
        align: (left, right),
        chapter-title, counter(page).display(),
      )
      line(length: 100%, stroke: 0.5pt + school-color)
    },
  )

  // Reset page counter for main content
  counter(page).update(1)

  // Text setup
  set text(size: 12pt)

  set par(
    leading: 0.65em,
    spacing: 1em,
    justify: true,
    first-line-indent: 0pt,
  )

  // Chapter headings (level 1)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(size: 30pt, weight: "regular")
    block(
      above: 0pt,
      below: 25pt,
      spacing: 0pt,
      {
        set par(spacing: 0pt)
        if it.numbering != none {
          grid(
            columns: (auto, 1fr),
            column-gutter: 0.6em,
            align: (left, right),
            // Left side: number and dot in blue
            text(fill: school-color)[#counter(heading).display().],
            // Right side: heading text in black
            it.body,
          )
        } else {
          // If no numbering, just right-align the text
          align(right, it.body)
        }
        v(-0.9em)
        line(length: 100%, stroke: 0.5pt)
        v(0.5em)
      },
    )
  }

  // Section headings (level 2)
  show heading.where(level: 2): it => {
    set text(size: 20pt, weight: "medium")
    block(
      above: 1.5em,
      below: 1em,
      {
        if it.numbering != none {
          counter(heading).display()
          [. ]
        }
        h(0.6em)
        it.body
      },
    )
  }

  // Subsection headings (level 3)
  show heading.where(level: 3): it => {
    set text(size: 16pt, weight: "medium")
    block(
      above: 1.2em,
      below: 0.8em,
      {
        if it.numbering != none {
          counter(heading).display()
          [. ]
        }
        h(0.6em)
        it.body
      },
    )
  }

  set heading(numbering: "1.1")

  body

  // Bibliography section
  if bibliography-file != none {
    pagebreak()

    // Style the bibliography heading
    show bibliography: set heading(numbering: none)

    bibliography(
      bibliography-file,
      title: [Bibliography],
      style: bibliography-style,
    )
  }

  // Back cover page
  page(
    margin: 0cm,
    numbering: none,
    header: none,
    fill: black,
  )[
    // School-color rectangle covering top half
    #place(
      top + left,
      rect(
        width: 100%,
        height: 50%,
        fill: school-color,
      ),
    )

    // School logo centered in bottom half
    #place(
      center + horizon,
      dy: 25%,
      image(school-logo, width: 50%),
    )
  ]
}
