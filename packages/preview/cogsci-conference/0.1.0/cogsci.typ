// CogSci Conference Template

/// Displays the anonymous author placeholder for blind review submissions.
///
/// Returns: Content showing "Anonymous CogSci submission" in the required style.
#let anonymous-authors = {
  align(center)[
    #block(above: 12pt, below: 0pt)[
      #text(size: 11pt, weight: "bold")[
        Anonymous CogSci submission
      ]
    ]
  ]
}

// Format a list of authors with proper styling
// LaTeX: \large\bf = 11pt font with 13pt leading (cogsci.sty line 241)
// Each author block should have 12pt spacing before it (consistent with title spacing)
#let format-authors(authors) = {
  // Normalize to an array of author dictionaries
  let authors = if authors == none {
    ()
  } else if type(authors) == array {
    authors
  } else if type(authors) == dictionary {
    (authors,)
  } else {
    assert(
      false,
      message: "format-authors: argument must be array, dictionary, or none; got " + str(type(authors)),
    )
    ()
  }

  // Validate each author is a dictionary with required 'name' key
  for (i, author) in authors.enumerate() {
    assert(
      type(author) == dictionary,
      message: "format-authors: author at index " + str(i) + " must be a dictionary, got " + str(type(author)),
    )
    assert(
      "name" in author,
      message: "format-authors: author at index " + str(i) + " must have a 'name' key",
    )
  }

  // Render authors block
  if authors.len() > 0 {
    align(center)[
      #for (i, author) in authors.enumerate() {
        // Add spacing before each author (including first, which comes after title)
        block(above: 14pt, below: 0pt)[  // Seems like it should be above: 12pt, but 14pt give better empirical match
          #text(size: 11pt, weight: "bold")[
            #author.name
            #if "email" in author [ (#author.email)]
          ]
          #if "affiliation" in author [#text(size: 10pt, weight: "regular")[#linebreak()#author.affiliation]]
        ]
      }
    ]
  } else {
    anonymous-authors
  }
}

/// Main CogSci conference template function.
///
/// This function applies the complete CogSci conference paper formatting to your document,
/// including page layout, typography, and structural elements. It matches the official
/// LaTeX template's visual output.
///
/// Arguments:
///   title (content or str): Paper title (displayed in 14pt bold, centered)
///   authors (content): Pre-formatted author information from format-authors() function
///   abstract (content or str): Paper abstract (displayed in 9pt with quote indentation)
///   keywords (array): List of keyword strings (displayed after abstract)
///   references (content): Bibliography content from bibliography() function call
///   anonymize (bool): If true, shows "Anonymous CogSci submission" instead of authors
///   hyphenate (bool): If true, enables hyphenation (set false for spell-checking)
///   text-kwargs (dict): Additional arguments to pass to set text()
///   page-kwargs (dict): Additional arguments to pass to set page()
///   document-kwargs (dict): Additional arguments to pass to set document()
///   body (content): The main document content
///
/// Returns: Formatted document content
///
/// Example:
///   ```
///   #show: cogsci.with(
///     title: [My Paper Title],
///     authors: format-authors((...)),
///     abstract: [This is the abstract...],
///     keywords: ("keyword1", "keyword2"),
///     references: bibliography("refs.bib", style: "apa"),
///   )
///   ```
#let cogsci(
  /* Document metadata */
  title: none,
  authors: none,
  abstract: none,
  keywords: (),
  /* Submission control */
  anonymize: false,
  /* Formatting options */
  hyphenate: true, // Set to false to disable hyphenation (useful for spell-checking)
  /* Document body */
  text-kwargs: (:),
  page-kwargs: (:),
  document-kwargs: (:),
  body,
) = {
  // Runtime type validation for parameters
  assert(
    type(anonymize) == bool,
    message: "cogsci: anonymize must be a boolean (true or false), got " + str(type(anonymize)),
  )

  assert(
    type(hyphenate) == bool,
    message: "cogsci: hyphenate must be a boolean (true or false), got " + str(type(hyphenate)),
  )

  assert(
    type(keywords) == array,
    message: "cogsci: keywords must be an array, got " + str(type(keywords)),
  )

  // Validate title is content or none
  if title != none {
    assert(
      type(title) == content or type(title) == str,
      message: "cogsci: title must be content or string, got " + str(type(title)),
    )
  }

  // Validate abstract is content or none
  if abstract != none {
    assert(
      type(abstract) == content or type(abstract) == str,
      message: "cogsci: abstract must be content or string, got " + str(type(abstract)),
    )
  }

  // Validate authors is content or none (it's pre-formatted by format-authors())
  if authors != none {
    assert(
      type(authors) == content,
      message: "cogsci: authors must be content (use format-authors() helper function), got " + str(type(authors)),
    )
  }

  // Set document metadata
  let doc-specs = (
    author: ("The Authors",),
    title: title,
    keywords: keywords,
    ..document-kwargs, // Additional user-specified document settings
  )
  if anonymize {
    doc-specs = doc-specs + (author: ("Anonymous",))
  }
  set document(..doc-specs)

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
    ..page-kwargs, // Additional user-specified page settings
  )

  // Font setup - Times Roman 10pt with 12pt leading
  set text(
    /* Global settings */
    font: "Times New Roman",
    lang: "en", // ISO 639-1/2/3 language code
    // region: "US", // ISO 3166-1 alpha-2 region code
    /* Typography */
    kerning: true,
    ligatures: true,
    discretionary-ligatures: false,
    historical-ligatures: false,
    number-type: "lining",
    slashed-zero: false,
    overhang: false, // Default: true; allows punctuation to hang in the margin for more pleasing edge alignment in justified text. This looks better, but we're disabling it to respect the specified margins exactly.
    /* Body settings */
    size: 10pt,
    /* Draft settings */
    hyphenate: hyphenate,
    /* User overrides */
    ..text-kwargs, // Additional user-specified text settings
  )

  // Document body
  // LaTeX \normalsize: 10pt font with 10pt leading (cogsci.sty line 236)
  // Typst needs empirically determined leading and spacing for visual match
  set par(
    /* Global settings */
    justify: true,
    /* Body settings */
    first-line-indent: 10pt, // Exact LaTeX measurement
    leading: 5.35pt, // Empirically tuned to match LaTeX body text
    spacing: 5.35pt, // Empirically tuned for paragraph spacing
    /* Microtypography */
    linebreaks: "optimized",
    // justification-limits: (
    //   spacing: (min: 100% * 2 / 3, max: 150%), // The spacing entry defines how much the width of spaces between words may be adjusted.
    //   tracking: (min: -0.01em, max: 0.01em), // The tracking entry defines how much the spacing between letters may be adjusted.
    // ),
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
    box[#text(it.body, size: 10pt, weight: "bold")#h(0.5em, weak: false)]
  }

  // Disable heading numbering
  set heading(numbering: none)

  // Footnote configuration matching LaTeX cogsci.sty
  // LaTeX places footnotes at bottom of page (spanning both columns) in two-column layout
  // footnotesep: 6.65pt (line 185)
  // footnotesize: 9pt (line 238)
  // footnoterule: 5pc wide horizontal rule (line 187)
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

  // Figure and table spacing per template instructions
  // "one line space above the caption and one line space below it"
  // With 12pt baselineskip, one line space = 12pt
  // NOTE: LaTeX \abovecaptionskip default is only 10pt, not 12pt, so the LaTeX
  // template doesn't actually follow its own written instructions
  show figure: set block(spacing: 12pt)
  show figure: set figure(gap: 12pt)

  // Table-specific: caption above table instead of below
  show figure.where(kind: table): set figure.caption(position: top)

  // Table styling to match LaTeX tabular
  // LaTeX aligns text baseline so ascenders are near the top of cells
  // Typst centers text vertically, so we use asymmetric inset to match LaTeX
  set table.hline(stroke: 0.4pt)
  set table.vline(stroke: 0.4pt)

  show table: set table(
    stroke: none,
    gutter: 0em,
    // align: left, // LaTeX default, but intentionally leaving out here
    inset: (top: 2pt, bottom: 4pt, x: 8pt), // Less top padding, more bottom for descenders
    /* Debugging */
    // stroke: 1pt,
    // gutter: 1em,
    // inset: 1.1em,
  )

  // Internal helper: Format the title section
  // LaTeX: \LARGE\bf = 14pt font with 17pt leading (cogsci.sty line 243)
  // Typst renders tighter, so we use slightly larger leading for visual match
  let format-title(content) = {
    align(center)[
      #set text(size: 14pt, weight: "bold")
      #content
    ]
  }

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
      // v(1em, weak: true)
      v(14pt, weak: true) // Seems like it should be above: 12pt, but 14pt give better empirical match
      // v(12pt, weak: true)
    }
    block(above: 12pt, below: 12pt)[
      #if anonymize {
        anonymous-authors
      } else {
        authors
      }
    ]
    v(2em, weak: false) // LaTeX \vskip 2em at end of titlebox (line 161)
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
      block(titlebox-content, width: 100%, breakable: false),
    )
  }

  set align(top)

  // Internal helper: Format abstract section - within column layout like LaTeX
  // LaTeX: \renewenvironment{abstract}{\centerline{\bf Abstract}\begin{quote}\small}
  // The quote environment adds \topsep = 4pt (cogsci.sty line 193)
  // Typst requires 3x correction: 4pt × 3 = 12pt
  let format-abstract(content) = {
    block(width: 100%, above: 0pt, below: 0pt)[
      #align(center)[
        #text(size: 10pt, weight: "bold")[Abstract]
      ]
    ]
    v(12pt) // LaTeX \topsep (4pt) × 3 correction for Typst rendering
    content
  }

  // Internal helper: Format keywords section
  let format-keywords(keywords-array) = {
    // Runtime type validation
    assert(
      type(keywords-array) == array,
      message: "format-keywords: keywords-array must be an array, got " + str(type(keywords-array)),
    )

    text(size: 9pt)[
      #text(weight: "bold")[Keywords:]
      #keywords-array.join("; ")
    ]
  }

  // Abstract and keywords at start of columns (like LaTeX)
  // LaTeX abstract uses quote environment (1/8" indent) with \small (9pt/9pt)
  // Typst needs 3pt leading for visual match
  block([
    #pad(left: 0.125in, right: 0.125in)[
      #set text(size: 9pt)  // LaTeX \small
      #set par(
        first-line-indent: 10pt,
        justify: true,
        leading: 3pt, // Empirically matches LaTeX \small rendering
        spacing: 3pt,
      )

      #if abstract != none {
        format-abstract(abstract)
      }

      #if keywords != none and keywords.len() > 0 {
        linebreak() // Tight spacing between abstract and keywords
        format-keywords(keywords)
      }
    ]
  ])

  // Bibliography
  show bibliography: set par(
    first-line-indent: 0pt,
    hanging-indent: 0.125in,
  )
  set bibliography(title: "References")

  body
}

