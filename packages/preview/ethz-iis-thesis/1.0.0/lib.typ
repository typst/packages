// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// An IIS Thesis Report Template for Typst

#import "shared/utils.typ": (
  current-semester, eth-header, fieldpar, include-pdf, placeholder,
)
#import "@preview/acrostiche:0.7.0": (
  acr, acrfull, acrpl, init-acronyms, print-index, reset-acronym,
  reset-all-acronyms,
)
#import "@preview/gentle-clues:1.3.1": code, task

/// The Typst Quick Guide appendix, ready to drop into the appendices array.
#let typst-guide = include "shared/typst-guide.typ"

/// The IIS Thesis template
#let thesis(
  /// The title of the thesis
  title: none,
  /// The name of the author
  author: none,
  /// The email of the author
  email: none,
  /// The date of the thesis (defaults to today)
  date: datetime.today(),
  /// The semester the thesis takes place
  semester: current-semester(),
  /// The type of report (e.g. "Master Thesis", "Semester Project")
  reporttype: none,
  /// Array of (name, mail) dicts
  advisors: none,
  /// Array of (name, mail) dicts
  professors: none,
  /// Title page logo. Accepts any content (e.g. image("fig/logo.svg")).
  /// Shows a placeholder task clue by default. Pass `logo: []` to omit.
  logo: none,
  /// Abstract content block. Pass content directly or via `include "/abstract.typ"`.
  abstract: none,
  /// Acknowledgements content block. Pass content directly or via `include "/acknowledgements.typ"`.
  acknowledgements: none,
  /// Acronyms dict in acrostiche format. Define them in a separate acronyms.typ
  /// file and pass the imported dict here: acronyms: acronyms
  acronyms: none,
  /// Assignment description appendix content. Shows placeholder instructions if none.
  assignment-description: none,
  /// Declaration of originality appendix content. Shows placeholder instructions if none.
  declaration-of-originality: none,
  /// Additional appendices. Array of content blocks, each starting with a level-1
  /// heading. Rendered before the assignment description and declaration of originality.
  /// Defaults to the Typst Quick Guide; pass your own array to replace it.
  appendices: (
    include "shared/typst-guide.typ",
  ),
  /// The bibliography, rendered in the backmatter. Pass a bibliography() object.
  bibliography: none,
  /// The actual body of the thesis
  body,
) = {
  // Check for missing cover page fields and substitute placeholders
  let cover-incomplete = (title, author, reporttype, advisors, professors).any(
    v => v == none,
  )
  if title == none { title = fieldpar[title] }
  if author == none { author = fieldpar[author name] }
  if reporttype == none { reporttype = fieldpar[report type] }
  if advisors == none { advisors = ((name: fieldpar[advisors], mail: ""),) }
  if professors == none {
    professors = ((name: fieldpar[professors], mail: ""),)
  }

  // Initialize acronyms (empty dict if none provided)
  init-acronyms(if acronyms != none { acronyms } else { (:) })

  // Global page & typography settings
  set page(paper: "a4", margin: (
    top: 25mm,
    bottom: 25mm,
    left: 30mm,
    right: 30mm,
  ))
  set text(size: 12pt, lang: "en")
  set par(justify: true)
  set list(indent: 1em)

  // Color all links as blue (e.g. email addresses)
  show link: set text(fill: blue)

  // Heading styles
  // Lenny style: large faint chapter number above a rule, title below
  show heading.where(level: 1): it => {
    // Only break for numbered (mainmatter) chapters; frontmatter headings
    // are already inside page() blocks so a break here creates an empty page.
    if it.numbering != none { pagebreak(weak: true) }
    v(2em)
    if it.numbering != none {
      block(text(
        size: 60pt,
        fill: luma(220),
        weight: "bold",
        counter(heading).display(),
      ))
    }
    line(length: 100%, stroke: 0.5pt)
    v(0.5em)
    block(above: 0em, below: 1em, text(size: 22pt, weight: "bold", it.body))
  }
  show heading.where(level: 2): set text(size: 16pt, weight: "bold")
  show heading.where(level: 2): set block(above: 1.2em, below: 0.6em)
  show heading.where(level: 3): set text(
    size: 14pt,
    weight: "bold",
    style: "italic",
  )
  show heading.where(level: 3): set block(above: 1em, below: 0.5em)
  // Level 4: inline paragraph heading — bold text followed by em-space
  show heading.where(level: 4): it => {
    text(weight: "bold", it.body)
    h(1em)
  }

  // Frontmatter uses roman page numbering e.g. i, ii, iii.
  // Set this BEFORE the title page so no extra page break is inserted.
  // The title page overrides numbering to none for just that one page.
  set page(numbering: "i")

  // Cover page
  page(
    numbering: none,
    header: eth-header,
    {
      line(length: 100%)
      v(1em)

      align(center, {
        smallcaps(text(size: 12pt)[
          Department of Information Technology and Electrical Engineering\
          Integrated Systems Laboratory\
          #semester
        ])
        v(2em)
        text(size: 28pt, weight: "bold", title)
        v(1em)
        smallcaps(text(size: 16pt, reporttype))
      })

      v(2em)
      // Show task clue in the logo area when cover fields are missing
      if cover-incomplete {
        placeholder(
          title: "Complete Cover Page",
          description: [Fill in the required fields when calling the template:],
          snippet: "title: \"My Thesis Title\",\n  author: \"Jane Doe\",\n  email: \"jdoe@iis.ee.ethz.ch\",\n  reporttype: \"Master Thesis\",\n  advisors: (\n    (name: \"Dr. Alice Smith\", mail: \"asmith@iis.ee.ethz.ch\"),\n    (name: \"Bob Jones\",       mail: \"bjones@iis.ee.ethz.ch\"),\n  ),\n  professors: (\n    (name: \"Prof. Dr. Carol Miller\", mail: \"cmiller@iis.ee.ethz.ch\"),\n  ),",
        )
      }
      if logo != none {
        align(center, logo)
      } else {
        placeholder(
          title: "Provide a logo",
          description: [Pass an image to the template, or set #raw(lang: "typc", "logo: []") to omit:],
          snippet: "logo: image(\"/figures/logo.svg\"),\n  // Or to omit:\n  logo: [],",
        )
      }

      v(1fr)

      align(center, {
        text(size: 18pt, author)
        linebreak()
        if email != none {
          text(size: 12pt, link("mailto:" + email)[#raw(email)])
          linebreak()
        }
        v(0.5em)
        text(size: 12pt, date.display("[month repr:long] [day], [year]"))
      })

      v(1fr)

      line(length: 100%)
      v(0.5em)
      // List all the advisors
      [Advisors:]
      for advisor in advisors [
        - #advisor.name, #link("mailto:" + advisor.mail)[#raw(advisor.mail)]
      ]

      // List the professor(s)
      [Professor:]
      for professor in professors [
        - #professor.name, #link("mailto:" + professor.mail)[#raw(professor.mail)]
      ]
    },
  )

  // Reset page counter to 1 for frontmatter (after title page)
  counter(page).update(1)

  // Acknowledgements
  page({
    show heading: set heading(numbering: none, outlined: false)
    heading(level: 1)[Acknowledgements]
    if acknowledgements != none {
      acknowledgements
    } else {
      placeholder(
        title: "Write Acknowledgements",
        description: [Pass content directly or load from a separate file:],
        snippet: "acknowledgements: [I would like to thank ...],\n  // Or from a file:\n  acknowledgements: include \"/acknowledgements.typ\",",
      )
    }
  })

  // Abstract
  page({
    show heading: set heading(numbering: none, outlined: false)
    heading(level: 1)[Abstract]
    if abstract != none {
      abstract
    } else {
      placeholder(
        title: "Write Abstract",
        description: [Pass content directly or load from a separate file:],
        snippet: "abstract: [This thesis presents ...],\n  // Or from a file:\n  abstract: include \"/abstract.typ\",",
      )
    }
  })

  // Brief declaration of originality (full version in appendix)
  page({
    show heading: set heading(numbering: none, outlined: false)
    heading(level: 1)[Declaration of Originality]
    [I hereby confirm that I am the sole author of the written work here
      enclosed and that I have compiled it in my own words. Parts excepted
      are corrections of form and content by the supervisor. For a detailed
      version of the declaration of originality, please refer to
      @app:originality.]
  })

  // List of Acronyms (optional, shown before the ToC)
  page({
    show heading: set heading(numbering: none, outlined: false)
    if acronyms != none {
      print-index(
        depth: 1,
        row-gutter: 1em,
        numbering: none,
        delimiter: none,
        outlined: false,
        sorted: "up",
        used-only: false,
        title: "List of Acronyms",
      )
    } else {
      task(title: "Add Acronyms")[
        Step 1 — create an `acronyms.typ` file with your definitions:
        #code[#raw(
          lang: "typc",
          block: true,
          "#let acronyms = (
  \"IIS\": (\"Integrated Systems Laboratory\",),
  \"SoC\": (short: \"SoC\", long: \"System-on-Chip\",
          short-pl: \"SoCs\", long-pl: \"Systems-on-Chip\"),
)",
        )]
        Step 2 — import and pass it to the template:
        #code[#raw(
          lang: "typc",
          block: true,
          "#import \"/acronyms.typ\": acronyms

#show: thesis.with(
  // ...
  acronyms: acronyms,
  // ...
)",
        )]
      ]
    }
  })

  // Table of contents, list of figures and tables
  {
    // Disable number and outline for the ToC heading
    show heading: set heading(numbering: none, outlined: false)
    // Make chapter entries bold
    show outline.entry.where(level: 1): set text(size: 14pt, weight: "bold")
    outline(title: [Contents], depth: 3, indent: 1em)
    pagebreak()
  }
  {
    show heading: set heading(numbering: none, outlined: false)
    outline(title: [List of Figures], target: figure.where(kind: image))
    pagebreak()
    outline(title: [List of Tables], target: figure.where(kind: table))
  }

  // Mainmatter, switching back to arabic numbering and resetting the page counter again.
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: "1.1")

  // The actual body of the thesis
  body

  // Appendix
  pagebreak()
  set heading(numbering: "A.1")
  counter(heading).update(0)

  // User-provided appendices
  if appendices != none {
    for app in appendices {
      app
      pagebreak()
    }
  }

  // Assignment Description
  [= Assignment Description <app:assignment-description>]
  if assignment-description != none {
    assignment-description
  } else {
    placeholder(
      title: "Add Assignment Description",
      description: [Include the assignment description PDF you received from your advisor:],
      snippet: "assignment-description: include-pdf(\"/figures/assignment.pdf\", pages: 3),",
    )
  }

  // Declaration of Originality
  pagebreak()
  [= Declaration of Originality <app:originality>]
  if declaration-of-originality != none {
    declaration-of-originality
  } else {
    placeholder(
      title: "Add Declaration of Originality",
      description: [
        Download, sign, and scan the official ETH Zurich declaration of originality,
        then include it here. The form is available at:
        - #link(
            "https://ethz.ch/content/dam/ethz/main/education/rechtliches-abschluesse/leistungskontrollen/declaration-originality.pdf",
          )[English version]
        - #link(
            "https://ethz.ch/content/dam/ethz/main/education/rechtliches-abschluesse/leistungskontrollen/plagiat-eigenstaendigkeitserklaerung.pdf",
          )[German version]
      ],
      snippet: "declaration-of-originality: include-pdf(\"/figures/declaration_of_originality.pdf\"),",
    )
  }
  // Backmatter with bibliography
  pagebreak()
  if bibliography != none {
    bibliography
  } else {
    placeholder(
      title: "Add Bibliography",
      description: [Create a BibTeX file and pass its path to the template:],
      snippet: "bibliography: bibliography(\"references.bib\", style: \"ieee\", full: true),",
    )
  }
}
