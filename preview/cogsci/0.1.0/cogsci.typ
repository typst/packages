// CogSci Conference Template

// Figure helper with proper formatting
#let cogsci-figure(
  content,
  caption: none,
  placement: auto,
  width: auto,
) = {
  figure(
    content,
    caption: caption,
    placement: placement,
    kind: image,
    supplement: "Figure",
  )
}

// Table helper with proper formatting
#let cogsci-table(
  content,
  caption: none,
  placement: auto,
) = {
  figure(
    content,
    caption: caption,
    placement: placement,
    kind: table,
    supplement: "Table",
  )
}

// Format the title with proper styling
// LaTeX: \LARGE\bf = 14pt font with 17pt leading (cogsci.sty line 243)
// Typst renders tighter, so we use slightly larger leading for visual match
#let format-title(title) = {
  align(center)[
    #set text(size: 14pt, weight: "bold")
    #set par(leading: 3pt)  // LaTeX 17pt total, Typst needs 3pt extra
    #title
  ]
}

// Format a list of authors with proper styling
// LaTeX: \large\bf = 11pt font with 13pt leading (cogsci.sty line 241)
// Typst needs empirically determined 5pt leading to match LaTeX visual spacing
#let format-authors(authors) = {
  if authors.len() > 0 {
    align(center)[
      #set par(leading: 5pt)  // Empirically matches LaTeX \large rendering
      #for (i, author) in authors.enumerate() {
        [#text(size: 11pt, weight: "bold")[
            #author.name
            #if "email" in author [ (#author.email)]
          ]#if "affiliation" in author [ \ #text(size: 10pt, weight: "regular")[#author.affiliation]]]
        if i < authors.len() - 1 {
          v(4.3pt) // Empirically measured to match LaTeX spacing (46.83pt in LaTeX)
        }
      }
    ]
  }
}

#let anonymous-authors = {
  align(center)[
    #text(size: 11pt, weight: "bold")[
      Anonymous CogSci submission
    ]
  ]
}

// Format abstract section - within column layout like LaTeX
// LaTeX: \renewenvironment{abstract}{\centerline{\bf Abstract}\begin{quote}\small}
// The quote environment adds \topsep = 4pt (cogsci.sty line 193)
// Typst requires 3x correction: 4pt × 3 = 12pt
#let format-abstract(abstract-content) = {
  block(width: 100%, above: 0pt, below: 0pt)[
    #align(center)[
      #text(size: 10pt, weight: "bold")[Abstract]
    ]
  ]
  v(12pt) // LaTeX \topsep (4pt) × 3 correction for Typst rendering

  abstract-content
}

// Format keywords section
#let format-keywords(keywords) = {
  text(size: 9pt)[
    #text(weight: "bold")[Keywords:]
    #keywords.join("; ")
  ]
}


#let cogsci(
  /* Document metadata */
  title: none,
  authors: [],
  abstract: none,
  keywords: (),
  /* Bibliography (result of bibliography() function or none) */
  bibliography: none,
  /* Submission control */
  anonymize: false,
  /* Formatting options */
  hyphenate: true, // Set to false to disable hyphenation (useful for spell-checking)
  /* Document body */
  body,
) = {
  // Set document metadata
  set document(
    title: title,
    author: if anonymize {
      ("Anonymous",)
    } else {
      ("Anonymous",) // Authors parameter is formatted content, not extractable
    },
    keywords: keywords,
  )

  // Page setup matching LaTeX exactly
  // LaTeX measurements:
  // - Paper: 8.5" x 11" (US Letter)
  // - Text width: 7in
  // - Text height: 9.25in
  // - Left margin: 0.75in
  // - Top margin: 1in (varies by PDF setting)
  // - Column separation: 0.25in
  // Two-column layout for entire document (title will be placed over it)

  set page(
    paper: "us-letter",
    margin: (
      left: 0.75in,
      right: 0.75in, // 8.5 - 7 - 0.75 = 0.75
      top: 1in,
      bottom: 0.75in, // Proper margin for footnotes
    ),
    header: none,
    footer: none,
    numbering: none,
    columns: 2, // Two-column layout for entire document
  )

  // Font setup - Times Roman 10pt with 12pt leading
  set text(
    font: "Times New Roman",
    size: 10pt,
    lang: "en",
    hyphenate: hyphenate,
  )

  // Paragraph formatting - LaTeX uses \parindent 10pt and \baselineskip 12pt
  set par(
    justify: true,
    leading: 2pt, // LaTeX baselineskip 12pt - font size 10pt = 2pt leading
    first-line-indent: 10pt, // Exact LaTeX measurement
  )

  // List spacing configuration (matches LaTeX cogsci.sty)
  set list(
    tight: false,
    marker: ([•], [◦], [▪]), // Bullet styles
    indent: 10pt, // Matches LaTeX \leftmargin
    body-indent: 0.5em,
    spacing: 1pt, // Matches LaTeX \itemsep
  )

  set enum(
    tight: false,
    indent: 10pt,
    body-indent: 0.5em,
    spacing: 1pt,
  )

  // Heading styles matching LaTeX cogsci.sty
  // Section: -1.5ex before, 3pt after, \Large\bf\centering (line 175-176)
  // At 10pt, 1ex ≈ 4.3pt (x-height), so -1.5ex ≈ 6.4pt
  // Typst requires ~1.9x correction factor: 6.4pt × 1.9 ≈ 12pt
  show heading.where(level: 1): it => {
    align(center, block(
      text(it.body, weight: "bold", size: 12pt),
      sticky: true,
      above: 12pt, // LaTeX -1.5ex (6.4pt) × 1.9 correction
      below: 8pt, // LaTeX 3pt × 2.67 correction (interaction with par spacing)
    ))
  }

  // Subsection: -1.5ex before, 3pt after, \large\bf\raggedright (line 177-178)
  // Uses same structure as level 1 to prevent first-line indent on following paragraph
  show heading.where(level: 2): it => {
    block(
      text(it.body, size: 11pt, weight: "bold"),
      sticky: true,
      above: 12pt, // LaTeX -1.5ex (6.4pt) × 1.9 correction factor
      below: 8pt, // LaTeX 3pt × 2.67 correction factor
    )
  }

  // Subsubsection: -6pt before, -1em after, \normalsize\bf (line 179-180)
  // Negative afterskip means run-in heading (on same line as following text)
  //
  // SPACING EXPLANATION:
  // LaTeX: -6pt beforeskip (absolute value = 6pt, smaller than level 2's 6.4pt)
  // With 1.9x correction: 6pt × 1.9 ≈ 11.4pt (close to level 2's 12pt)
  //
  // But level 3 is inline (run-in), so it appears within paragraph flow.
  // Unlike levels 1-2 which use block() to control spacing independently,
  // level 3 must account for existing paragraph spacing (5.4pt).
  //
  // The v(-2pt) pulls back slightly from the natural paragraph break position.
  // This compensates for the fact that linebreak() occurs within a paragraph context
  // where spacing and leading have already been applied, resulting in the correct
  // visual spacing that matches LaTeX's smaller beforeskip for level 3.
  //
  // NOTE: Do not put blank lines after level 3 headings in source - text must follow immediately
  // or use // comment to suppress the blank line
  show heading.where(level: 3): it => {
    v(-2pt, weak: true) // Pull back from paragraph spacing context
    linebreak()
    text(it.body, size: 10pt, weight: "bold")
    h(0.5em, weak: false)
  }

  // Disable heading numbering
  set heading(numbering: none)

  // Footnote configuration matching LaTeX cogsci.sty
  // LaTeX places footnotes at bottom of page (spanning both columns) in two-column layout
  // footnotesep: 6.65pt (line 185)
  // footnotesize: 9pt (line 238)
  // footnoterule: 5pc wide horizontal rule (line 187)
  //
  // LIMITATION: Typst's page-level columns may cause both columns to reserve space
  // for footnotes even when the footnote only appears in one column, leading to
  // uneven column heights. This is a known Typst limitation as of 2024.
  set footnote(numbering: "1")

  // Custom footnote rule matching LaTeX (5pc = 60pt wide)
  set footnote.entry(
    separator: line(length: 60pt, stroke: 0.5pt),
    gap: 6.65pt, // LaTeX \footnotesep
  )

  show footnote.entry: it => {
    set text(size: 9pt) // LaTeX \footnotesize (line 238): 9pt font, 9pt baselineskip
    set par(
      first-line-indent: 0pt,
      hanging-indent: 0.5em,
      leading: 0pt, // LaTeX: 9pt baselineskip - 9pt font = 0pt leading
    )
    it
    v(-1.9pt, weak: false) // Empirically tuned to match LaTeX 10.70pt inter-footnote spacing
  }

  // Figure and table caption configuration
  // LaTeX default: 10pt font for captions (same as body text)
  // Table captions appear above the table, figure captions below
  set figure(numbering: "1")

  show figure.caption: it => {
    set text(size: 10pt)
    set par(first-line-indent: 0pt)
    it
  }

  // Place table captions above the table (LaTeX default for tables)
  show figure.where(kind: table): set figure(placement: none)
  show figure.where(kind: table): it => {
    set align(center)
    block[
      #it.caption
      #v(0.12in) // LaTeX \vskip 0.12in between caption and table
      #it.body
    ]
  }

  // Figure captions appear below with spacing (LaTeX default for figures)
  // "one line space above the caption and one line space below it"
  // LaTeX produces ~27pt gap between figure and caption
  show figure.where(kind: image): set figure(gap: 15pt)

  // Title box - matches LaTeX \titlebox logic from cogsci.sty
  // LaTeX logic (lines 145-162):
  //   \vbox to \titlebox{         % Minimum 5cm box (line 119)
  //     {\LARGE\bf \@title \par}  % Title
  //     \vskip 1em                % Gap after title (line 148)
  //     \outauthor                % Authors
  //     \vskip 2em                % Gap after authors (line 161)
  //   }
  // The \vskip 2em is INSIDE the vbox, so 5cm includes everything
  // If content < 5cm, the vbox stretches to 5cm
  // If content > 5cm, the vbox grows with content
  //
  // Using place() with parent scope to span full width above columns
  // LaTeX titlebox logic (lines 145-162):
  // \vbox to \titlebox creates a box with minimum height 5cm (line 119: \titlebox = 5cm)
  // Content inside: title + \vskip 1em + authors + \vskip 2em (line 161)
  // The box is exactly 5cm if content is smaller, grows if content is larger
  //
  // NOTE: For 3+ authors, Typst correctly grows the titlebox and pushes columns down.
  // The LaTeX template has a bug where it doesn't include enough space, causing overlap.
  // Our implementation fixes this by properly measuring content and adjusting spacing.
  // Create titlebox content
  let titlebox-content = {
    if title != none {
      format-title(title)
      v(-0.2em) // Counteract most of natural block spacing while leaving proper gap
    }

    if anonymize {
      anonymous-authors
    } else {
      authors
    }

    v(2em) // LaTeX \vskip 2em at end of titlebox (line 161)
  }

  context {
    let measured = measure(titlebox-content)
    let min-height = 5cm + 3.3pt
    let gap-needed = calc.max(0pt, min-height - measured.height)

    place(
      top + center,
      scope: "parent",
      float: true,
      clearance: gap-needed,
      block(width: 100%, breakable: false)[
        #titlebox-content
      ],
    )
  }

  set align(top)

  // Abstract and keywords at start of columns (like LaTeX)
  // LaTeX abstract uses quote environment (1/8" indent) with \small (9pt/9pt)
  // Typst needs 3pt leading for visual match
  block([
    #pad(left: 0.125in, right: 0.125in)[
      #set text(size: 9pt)  // LaTeX \small
      #set par(
        first-line-indent: 0pt,
        leading: 3pt, // Empirically matches LaTeX \small rendering
        justify: true,
      )

      #if abstract != none {
        format-abstract(abstract)
      }

      #if keywords != none and keywords.len() > 0 {
        v(-4pt) // Tight spacing between abstract and keywords
        format-keywords(keywords)
      }
    ]
  ])

  // Document body
  // LaTeX \normalsize: 10pt font with 10pt leading (cogsci.sty line 236)
  // Typst needs empirically determined leading and spacing for visual match
  set par(
    leading: 5.35pt, // Empirically tuned to match LaTeX body text
    spacing: 5.35pt, // Empirically tuned for paragraph spacing
  )
  body

  // Bibliography
  show std.bibliography: set par(first-line-indent: 0pt, hanging-indent: 0.125in)
  set std.bibliography(title: "References", style: "apa")

  bibliography
}
