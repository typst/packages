// APMCM (Asia and Pacific Mathematical Contest in Modeling) Typst Template
// Converted from the official apmcmthesis.cls, apmcmthesis.cfg, and ControlSheet.tex

// --- Theorem / Environment Helpers ---
#let _thm-counter = counter("apmcm-thm")

#let _thm-box(kind, title: none, body) = {
  _thm-counter.step()
  block(
    above: 0.8em,
    below: 0.8em,
    breakable: true,
    [
      #strong[#kind #context _thm-counter.display()]#if title != none [ (#title)]#strong[.] #emph(body)
    ],
  )
}

#let definition(title: none, body) = _thm-box("Definition", title: title, body)
#let theorem(title: none, body) = _thm-box("Theorem", title: title, body)
#let lemma(title: none, body) = _thm-box("Lemma", title: title, body)
#let corollary(title: none, body) = _thm-box("Corollary", title: title, body)
#let assumption(title: none, body) = _thm-box("Assumption", title: title, body)
#let conjecture(title: none, body) = _thm-box("Conjecture", title: title, body)
#let axiom(title: none, body) = _thm-box("Axiom", title: title, body)
#let principle(title: none, body) = _thm-box("Principle", title: title, body)
#let problem-env(title: none, body) = _thm-box("Problem", title: title, body)

#let proof(body) = block(
  above: 0.6em,
  below: 0.8em,
  breakable: true,
  [
    #emph[*Proof.*] #body #h(1fr) $square$
  ],
)

// --- Code Block Helper (matching apmcmthesis.cls listings style) ---
#let code-block(caption: none, body) = {
  figure(
    kind: "code",
    supplement: "Listing",
    caption: caption,
    block(
      width: 100%,
      fill: luma(245),
      stroke: (
        top: 1pt + luma(190),
        bottom: 1pt + luma(190),
      ),
      inset: (x: 8pt, y: 8pt),
      breakable: true,
      align(left, text(size: 9.5pt, body)),
    ),
  )
}

// --- Three-line Table Helper (booktabs style) ---
#let three-line-table(columns: auto, align: center, ..cells) = {
  set table(
    stroke: (_, y) => (
      top: if y == 0 { 1.2pt + black } else if y == 1 { 0.6pt + black } else { none },
      bottom: 1.2pt + black,
    ),
    inset: (x: 8pt, y: 5pt),
  )
  table(
    columns: columns,
    align: align,
    ..cells,
  )
}

// --- Heading Numbering Helpers ---
#let _body-heading-numbering(..nums) = {
  let n = nums.pos()
  if n.len() == 1 {
    numbering("I.", n.at(0))
  } else if n.len() == 2 {
    [#n.at(0).#n.at(1)]
  } else {
    [#n.at(0).#n.at(1).#n.at(2)]
  }
}

#let _toc-heading-numbering(..nums) = {
  let n = nums.pos()
  if n.len() == 1 {
    [#n.at(0).]
  } else if n.len() == 2 {
    [#n.at(0).#n.at(1)]
  } else {
    [#n.at(0).#n.at(1).#n.at(2)]
  }
}

#let _resolve-year(year) = {
  if year == auto {
    let today = datetime.today()
    if today != none { today.year() } else { 2026 }
  } else {
    year
  }
}

// --- Main Paper Template ---
#let apmcm-paper(
  team-number: "apmcm263XXXXX",
  problem: "A",
  year: auto,
  title: none,
  keywords: (),
  summary: [],
  header-prefix: "Team # ",
  font-family: ("Times New Roman", "Libertinus Serif"),
  mono-font: ("DejaVu Sans Mono",),
  body,
) = {
  let resolved-year = _resolve-year(year)

  set document(
    title: if title != none { title } else { [#resolved-year APMCM Solution Paper - #team-number] },
  )

  // State to track frontmatter vs mainmatter for header & page numbering
  let in-mainmatter = state("apmcm-in-mainmatter", false)

  // Page layout matching apmcmthesis.cls: A4, top/bottom=26.4mm, left/right=31.8mm
  set page(
    paper: "a4",
    margin: (top: 26.4mm, bottom: 26.4mm, left: 31.8mm, right: 31.8mm),
    header-ascent: 18pt,
    header: context {
      let is-main = in-mainmatter.get()
      let total-pages = counter(page).final().first()
      let cur-page = counter(page).get().first()
      let left-text = [#header-prefix#team-number]
      let right-text = if is-main {
        [Page #cur-page of #total-pages]
      } else {
        []
      }
      set text(size: 10pt, font: font-family)
      stack(
        dir: ttb,
        spacing: 3pt,
        grid(
          columns: (1fr, auto),
          align: (left, right),
          left-text, right-text,
        ),
        line(length: 100%, stroke: 0.4pt + black),
      )
    },
    footer: none,
  )

  // Typography matching 12pt + \baselinestretch{1.38} + 2em indent
  set text(
    font: font-family,
    size: 12pt,
    lang: "en",
  )
  show raw: set text(font: mono-font, size: 10pt)
  set par(
    leading: 0.78em,
    spacing: 0.85em,
    first-line-indent: (amount: 2em, all: true),
    justify: true,
  )

  // Lists
  set list(indent: 2em, body-indent: 0.5em)
  set enum(indent: 2em, body-indent: 0.5em)

  // Equations: numbered (1), (2), ...
  set math.equation(numbering: "(1)")

  // Figures & Tables captions matching apmcmthesis.cls
  set figure(gap: 0.7em)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => {
    set text(size: 11pt, weight: "bold")
    it
  }

  // ==================== PAGE 1: SUMMARY SHEET ====================
  {
    set par(first-line-indent: 0pt)
    align(center)[
      #table(
        columns: (4cm, 4cm),
        align: (left, left),
        stroke: 0.6pt + black,
        inset: (x: 6pt, y: 5pt),
        [Team Number:], [#team-number],
        [Problem Chosen:], [#problem],
      )
    ]
    v(0.2em)
    line(length: 100%, stroke: 2pt + black)
    v(0.3em)
    align(center)[
      #text(size: 12pt)[#resolved-year APMCM summary sheet]
    ]
    if title != none {
      v(0.3em)
      align(center)[
        #text(size: 14pt, weight: "bold")[#title]
      ]
    }
    v(0.5em)
  }

  // Summary content (indented paragraphs)
  summary

  // Keywords
  if keywords.len() > 0 {
    v(0.4em)
    par(first-line-indent: 0pt)[
      #strong[Keywords:] #keywords.join(h(1em))
    ]
  }

  pagebreak()

  // ==================== PAGE 2: CONTENTS ====================
  {
    set par(first-line-indent: 0pt)
    align(center)[
      #text(size: 14pt, weight: "bold")[Contents]
    ]
    v(0.5em)

    // Match apmcmthesis.cls TOC styling:
    // Level 1: bold, "1. Title"
    // Level 2: indented 13pt, regular, "1.1 Title"
    // Level 3: indented 35pt, upright number + italic title
    set heading(numbering: _toc-heading-numbering)
    show outline.entry.where(level: 1): it => {
      set text(weight: "bold")
      v(0.25em, weak: true)
      link(it.element.location(), it.indented(it.prefix(), it.inner()))
    }
    show outline.entry.where(level: 2): it => {
      pad(left: 13pt, link(it.element.location(), it.indented(it.prefix(), it.inner())))
    }
    show outline.entry.where(level: 3): it => {
      pad(
        left: 35pt,
        link(
          it.element.location(),
          it.indented(
            it.prefix(),
            {
              // Keep page number upright, title italic, matching leader spacing
              emph(it.body())
              h(0.3em)
              box(width: 1fr, it.fill)
              h(0.3em)
              it.page()
            },
          ),
        ),
      )
    }

    outline(
      title: none,
      depth: 3,
      indent: 0pt,
    )
  }

  in-mainmatter.update(true)
  counter(page).update(0)
  pagebreak()

  // ==================== MAINMATTER (Page counter resets to 1) ====================

  // Heading styles matching apmcmthesis.cls L318-332
  set heading(numbering: _body-heading-numbering)
  show heading.where(level: 1): it => {
    v(1.0em, weak: true)
    block(sticky: true)[
      #align(center)[
        #set text(size: 14.4pt, weight: "bold")
        #if it.numbering != none {
          counter(heading).display(_body-heading-numbering)
          h(0.5em)
        }
        #it.body
      ]
    ]
    v(0.6em, weak: true)
  }
  show heading.where(level: 2): it => {
    v(0.9em, weak: true)
    block(sticky: true)[
      #set text(size: 13pt, weight: "bold")
      #if it.numbering != none {
        counter(heading).display(_body-heading-numbering)
        h(0.5em)
      }
      #it.body
    ]
    v(0.4em, weak: true)
  }
  show heading.where(level: 3): it => {
    v(0.7em, weak: true)
    block(sticky: true)[
      #set text(size: 12pt, weight: "bold")
      #if it.numbering != none {
        counter(heading).display(_body-heading-numbering)
        h(0.5em)
      }
      #emph(it.body)
    ]
    v(0.3em, weak: true)
  }

  body
}

// --- Control Sheet Template (matching ControlSheet.tex & apmcmthesis.cfg) ---
#let apmcm-control-sheet(
  problem: "A",
  team-number: "263XXXXX",
  school: "XXX University",
  members: ("First Member", "Second Member", "Third Member"),
  supervisor: "Supervisor",
  date: "November 28, 2026",
  year: auto,
  font-family: ("Times New Roman", "Libertinus Serif"),
  _body,
) = {
  let resolved-year = _resolve-year(year)

  set document(title: [#resolved-year APMCM Control Sheet - #team-number])
  set page(
    paper: "a4",
    margin: (top: 26.4mm, bottom: 26.4mm, left: 31.8mm, right: 31.8mm),
    header: none,
    footer: none,
  )
  set text(font: font-family, size: 12pt, lang: "en")
  set par(leading: 0.85em, spacing: 0.9em, justify: true)

  align(center)[
    #text(size: 20pt, weight: "bold")[#resolved-year APMCM Control Sheet]
  ]
  v(0.5em)

  par(first-line-indent: 2em)[
    *Each team member must sign the statement below:*
  ]
  par(first-line-indent: 2em)[
    (Failure to obtain signatures from each team member will result in disqualification of the entire team.)
  ]
  par(first-line-indent: 2em)[
    Each of us hereby testifies that our team abided by all of the contest's rules and did not consult with anyone who was not on this team in developing the enclosed solution paper. Our submission and all rights to its publication become the property of APMCM. APMCM may use, edit, excerpt, and publish this submission for promotional use or any other purpose, including placing it online, distributing it electronically or otherwise, without compensation of any kind. APMCM reserves the right to use in materials relating to this contest, the names of the team members, their advisor(s), and their affiliations, without further notification, permission, or compensation. Team members assert that All images, figures, photographs, tables, and drawings in their submission were either created by the team or else, if reproduced from another source, the submission cites a specific reference for each at its location in the submission. All direct quotations in the submission are enclosed in quotation marks or otherwise identified as such, with a specific reference cited for each at its location in the submission.
  ]

  v(0.6em)

  let field-row(label, value) = {
    table(
      columns: (auto, 1fr),
      stroke: (x, _) => if x == 1 { (bottom: 0.6pt + black) } else { none },
      inset: (x: 4pt, y: 4pt),
      align: (left, left),
      [#label], [#h(0.5em)#value],
    )
    v(0.25em)
  }

  field-row([Problem chosen is (A, B , C or D) :], problem)
  field-row([Team control number is (team number) :], team-number)
  field-row([School (Please fill in the full name) :], school)

  // Member names (1, 2, 3)
  let m1 = if members.len() >= 1 { members.at(0) } else { "" }
  let m2 = if members.len() >= 2 { members.at(1) } else { "" }
  let m3 = if members.len() >= 3 { members.at(2) } else { "" }

  table(
    columns: (auto, auto, 1fr),
    stroke: (x, _) => if x == 2 { (bottom: 0.6pt + black) } else { none },
    inset: (x: 4pt, y: 4pt),
    align: (left, left, left),
    [Member name (Handwriting signature) :], [1.], [#h(0.3em)#m1],
    [], [2.], [#h(0.3em)#m2],
    [], [3.], [#h(0.3em)#m3],
  )
  v(0.25em)

  field-row([Team adviser name :], supervisor)

  v(0.3em)
  par(first-line-indent: 2em)[
    (Please check the above content carefully, *fill in English*, and will not be allowed to make any changes after submission. Such as fill in error, the thesis may be canceled qualification awards.)
  ]

  v(0.8em)
  align(right)[
    #box(width: 6.2cm)[
      #table(
        columns: (auto, 1fr),
        stroke: (x, _) => if x == 1 { (bottom: 0.6pt + black) } else { none },
        inset: (x: 4pt, y: 4pt),
        align: (left, left),
        [Date:], [#h(0.4em)#date],
      )
    ]
  ]
}
