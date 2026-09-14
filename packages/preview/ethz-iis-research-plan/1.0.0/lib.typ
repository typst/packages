// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// An IIS Research Plan Template for Typst

#import "shared/utils.typ": eth-header, fieldpar, pulp-colors

/// The IIS Research Plan template for PhD candidates.
#let research-plan(
  /// The title of the thesis / research plan
  title: none,
  /// The name of the PhD candidate
  author: none,
  /// The email of the PhD candidate
  email: none,
  /// The date of the document (defaults to today)
  date: datetime.today(),
  /// Chair: (name, mail) dict
  chair: none,
  /// Supervisor: (name, mail) dict
  supervisor: none,
  /// Co-supervisor: (name, mail) dict. Optional — shows "—" if none.
  cosupervisor: none,
  /// Bibliography content, e.g. bibliography("references.bib", style: "ieee", full: true)
  bibliography: none,
  /// The body of the research plan
  body,
) = {
  // Substitute fieldpar placeholders for missing required fields
  if title == none { title = fieldpar[title] }
  if author == none { author = fieldpar[author name] }

  // Global page & typography settings
  set page(
    paper: "a4",
    margin: (top: 25mm, bottom: 25mm, left: 30mm, right: 30mm),
    header: context if counter(page).get().first() == 1 { eth-header },
    numbering: "1",
  )
  set text(size: 12pt, lang: "en")
  set par(justify: true)
  set list(indent: 1em)

  // Color all links blue
  show link: set text(fill: blue)

  // Heading styles
  // Level 1: numbered bold heading, no pagebreak — appropriate for a short document
  set heading(numbering: "1.1")
  show heading.where(level: 1): set text(size: 18pt, weight: "bold")
  show heading.where(level: 1): set block(above: 2em, below: 1em)
  show heading.where(level: 2): set text(size: 14pt, weight: "bold")
  show heading.where(level: 2): set block(above: 1.2em, below: 1em)
  show heading.where(level: 3): set text(
    size: 12pt,
    weight: "bold",
    style: "italic",
  )
  show heading.where(level: 3): set block(above: 1em, below: 0.5em)

  // Cover block — inline at the top of the first page so body follows on the same page
  align(center, {
    v(2em)
    smallcaps(text(size: 16pt)[Research Plan — Ph.D. Thesis])
    v(1em)
    text(size: 24pt, weight: "bold", title)
    v(1em)
    text(size: 16pt, author)
    linebreak()
    if email != none {
      text(size: 12pt, link("mailto:" + email)[#raw(email)])
      linebreak()
    }
    text(size: 12pt, date.display("[month repr:long] [day], [year]"))
  })

  v(1.5em)

  // Body and heading numbering
  body

  // Signatures section
  pagebreak()
  {
    set heading(numbering: none, outlined: false)
    heading(level: 1)[Signatures]
  }
  v(5em)
  line(length: 100%, stroke: 0.5pt)
  grid(
    columns: (1fr, 1fr, 1fr),
    {
      text(weight: "bold")[Chair]
      linebreak()
      if chair != none { chair.name } else { fieldpar[Chair] }
    },
    {
      text(weight: "bold")[Supervisor]
      linebreak()
      if supervisor != none { supervisor.name } else { fieldpar[Supervisor] }
    },
    {
      text(weight: "bold")[Co-Supervisor]
      linebreak()
      if cosupervisor != none { cosupervisor.name } else [—]
    },
  )
  v(8em)
  line(length: 33%, stroke: 0.5pt)
  text(weight: "bold")[PhD Candidate]
  linebreak()
  author

  if bibliography != none {
    pagebreak()
    bibliography
  }
}
