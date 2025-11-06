// CogSci Conference Template

#let latex-mimic = true // Set to false to disable LaTeX visual mimicry features
// #let latex-mimic = false

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

/// Formats author information according to CogSci conference style.
///
/// Each author's name appears on a separate line in 11pt bold, centered, with optional
/// email address in parentheses. Affiliations appear below names in 10pt regular font.
///
/// Arguments:
///   authors (array, dictionary, or none): Author information. Can be:
///     - An array of author dictionaries
///     - A single author dictionary (will be converted to array)
///     - none (returns anonymous placeholder)
///
/// Author Dictionary Format:
///   Each author dictionary must contain:
///   - name (content or str): Author's full name (required)
///   - email (str, optional): Email address (shown in parentheses after name)
///   - affiliation (content or str, optional): Institution and address
///
/// Returns: Formatted author content block
///
/// Example:
///   ```
///   #let authors = format-authors(
///     (name: [Author One], email: "a1@university.edu", affiliation: [Department Details]),
///     (name: [Author Two], email: "a2@university.edu", affiliation: [Department Details]),
///   )
///   ```
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


  /* AUTHORS
  __Explicit__
  <<In the initial submission, the phrase "Anonymous CogSci submission" should appear below the title, centered, in 11 point bold font. In the final submission, each author's name should appear on a separate line, 11 point bold, and centered, with the author's email address in parentheses. Under each author's name list the author's affiliation and postal address in ordinary 10 point type.>>

  __LaTeX__
  \large\bf = 11pt font with 13pt leading (cogsci.sty line 241)
  */
  if authors.len() > 0 {
    align(center)[
      #for (i, author) in authors.enumerate() {
        // Add spacing before each author (including first, which comes after title)
        block(above: if latex-mimic { 16pt } else { 12pt }, below: 0pt)[
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
///   abstract (content or str): Paper abstract (displayed in 9pt)
///   keywords (array): List of keyword strings
///   anonymize (bool): If true, shows "Anonymous CogSci submission" instead of authors
///   hyphenate (bool): If false, disables hyphenation
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
///     authors: format-authors(...),
///     abstract: [This is the abstract...],
///     keywords: ("keyword1", "keyword2"),
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
  hyphenate: true,
  /* Document body */
  text-kwargs: (:),
  page-kwargs: (:),
  document-kwargs: (:),
  body,
) = {
  // Runtime type validation for parameters
  assert(
    type(anonymize) == bool,
    message: "cogsci: anonymize must be a boolean, got " + str(type(anonymize)),
  )

  assert(
    type(hyphenate) == bool,
    message: "cogsci: hyphenate must be a boolean, got " + str(type(hyphenate)),
  )

  assert(
    type(keywords) == array,
    message: "cogsci: keywords must be an array, got " + str(type(keywords)),
  )

  if title != none {
    assert(
      type(title) == content or type(title) == str,
      message: "cogsci: title must be content or string, got " + str(type(title)),
    )
  }

  if abstract != none {
    assert(
      type(abstract) == content or type(abstract) == str,
      message: "cogsci: abstract must be content or string, got " + str(type(abstract)),
    )
  }

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

  // Typst leading calculation constants for Times New Roman
  //
  // Times New Roman cap-height is 66.21% of font size
  // Source: https://www.readz.com/web-fonts-and-typography
  //
  // Typst's leading parameter measures space between bottom of one line and top of next.
  // With default settings (top-edge: "cap-height", bottom-edge: "baseline"):
  //   baseline-to-baseline = leading + cap-height
  //   leading = baseline-to-baseline - cap-height
  //   leading = baseline-to-baseline - (cap-height-ratio * font_size)
  let cap-height-ratio = 0.6621

  /// Calculate Typst leading parameter for desired baseline-to-baseline spacing.
  ///
  /// Arguments:
  ///   baseline (length): Desired baseline-to-baseline distance
  ///   font-size (length): Font size
  ///
  /// Returns: The leading value to use in set par(leading: ...)
  let calc-leading(baseline, font-size) = {
    baseline - (cap-height-ratio * font-size)
  }

  /* INDENTATION
  __Explicit__
  <<Indent the first line of each paragraph by 1/8 inch (except for the first paragraph of a new section). Do not add extra vertical space between paragraphs.>>

  __LaTeX__
  \parindent 10pt (cogsci.sty line 192)
  */
  let indent = if latex-mimic { 10pt } else { 1in / 8 }

  /* PAGE
  __Explicit__
  <<The text of the paper should be formatted in two columns with an overall width of 7 inches (17.8 cm) and length of 9.25 inches (23.5 cm), with 0.25 inches between the columns. Leave two line spaces between the last author listed and the text of the paper; the text of the paper (starting with the abstract) should begin no less than 2.75 inches below the top of the page. The left margin should be 0.75 inches and the top margin should be 1 inch. *The right and bottom margins will depend on whether you use U.S. letter or A4 paper, so you must be sure to measure the width of the printed text.* Use 10 point Times Roman with 12 point vertical spacing, unless otherwise specified.>>
  */
  let text-width = 7in // 17.8cm
  let text-height = 9.25in // 23.5cm
  let column-gap = 0.25in
  set page(
    paper: "us-letter", // 8.5" x 11"
    margin: (
      left: 0.75in, // fixed
      right: 0.75in, // based on paper size. For US Letter: 8.5" - 7" - 0.75" = 0.75"
      top: 1in, // fixed
      bottom: 0.75in, // based on paper size. For US Letter: 11" - 9.25" - 1" = 0.75"
    ),
    header: none,
    footer: none,
    numbering: none,
    columns: 2,
    ..page-kwargs, // Additional user-specified page settings
  )
  set columns(gutter: column-gap)

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

  /* BODY
  __Explicit__
  <<Indent the first line of each paragraph by 1/8 inch (except for the first paragraph of a new section). Do not add extra vertical space between paragraphs.>>

  __LaTeX__
  \normalsize (cogsci.sty line 236)
  */
  set par(
    /* Global settings */
    justify: true,
    /* Body settings */
    first-line-indent: indent,
    leading: calc-leading(12pt, 10pt), // 12pt baseline - (0.6621 × 10pt) = 5.379pt
    spacing: calc-leading(12pt, 10pt),
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
    indent: indent, // 10pt matches LaTeX \leftmargin
    body-indent: 0.5em,
    spacing: 1pt, // Matches LaTeX \itemsep
  )

  set enum(
    tight: false,
    indent: indent,
    body-indent: 0.5em,
    spacing: 1pt,
  )

  // Disable heading numbering
  set heading(numbering: none)

  /* HEADINGS - Level 1
  __Explicit__
  <<First level headings should be in 12 point, initial caps, bold and centered. Leave one line space above the heading and 1/4 line space below the heading.>>

  __LaTeX__
  Section: -1.5ex before, 3pt after, \Large\bf\centering (line 175-176)
  At 10pt, 1ex ≈ 4.3pt (x-height), so -1.5ex ≈ 6.4pt

  Note: Setting bottom-edge to "bounds" ensures spacing is measured from the visual bottom of letters (including descenders), not the baseline.
  */
  show heading.where(level: 1): it => {
    set block(
      above: 12pt,
      below: if latex-mimic { 6pt } else { 12pt / 4 },
    )
    set text(size: 12pt, weight: "bold", bottom-edge: "bounds")
    align(center, it)
  }

  /* HEADINGS - Level 2
  __Explicit__
  <<Second level headings should be 11 point, initial caps, bold, and flush left. Leave one line space above the heading and 1/4 line space below the heading.>>

  __LaTeX__
  Subsection: -1.5ex before, 3pt after, \large\bf\raggedright (line 177-178)

  Note: Setting bottom-edge to "bounds" ensures spacing is measured from the visual
  bottom of letters (including descenders), not the baseline.
  */
  show heading.where(level: 2): it => {
    set block(
      above: 12pt,
      below: if latex-mimic { 6pt } else { 12pt / 4 },
    ) // explicitly, it should be `block(above: 11pt, below: 3pt)`
    set text(size: 11pt, weight: "bold", bottom-edge: "bounds")
    it
  }

  /* HEADINGS - Level 3
  __Explicit__
  <<Third level headings should be 10 point, initial caps, bold, and flush left. Leave one line space above the heading, but no space after the heading.>>

  __LaTeX__
  Subsubsection: -6pt before, -1em after, \normalsize\bf (line 179-180)
  Negative afterskip means run-in heading (on same line as following text)
  */
  show heading.where(level: 3): it => {
    v(-1pt, weak: true) // Pull back from paragraph spacing context // ad-hoc correction to match LaTeX spacing
    // parbreak()
    linebreak()
    box[#text(it.body, size: 10pt, weight: "bold")#h(1em, weak: false)]
  }

  // Footnote configuration matching LaTeX cogsci.sty
  // LaTeX places footnotes at bottom of page (spanning both columns) in two-column layout
  // footnotesep: 6.65pt (line 185)
  // footnotesize: 9pt (line 238)
  // footnoterule: 5pc wide horizontal rule (line 187)
  set footnote(numbering: "1")

  // Custom footnote rule matching LaTeX (5pc = 60pt wide)
  set footnote.entry(
    separator: line(length: 60pt, stroke: 0.5pt),
    gap: 5pt, // LaTeX \footnotesep
  )

  show footnote.entry: it => {
    set text(size: 9pt) // LaTeX \footnotesize (line 238): 9pt font, 9pt baselineskip
    set par(
      first-line-indent: 0pt,
      hanging-indent: 0.5em,
      leading: calc-leading(9pt, 9pt), // Single spacing: 9pt baseline - (0.6621 × 9pt) = 3.04pt
    )
    it
  }

  // Figure and table caption configuration
  // LaTeX default: 10pt font for captions (same as body text)
  // Table captions appear above the table, figure captions below
  set figure(numbering: "1")

  show figure.caption: it => {
    set par(first-line-indent: 0pt)
    it
  }

  /* FIGURES
  __Explicit__
  <<Number figures sequentially, placing the figure number and caption, in 10 point, after the figure with one line space above the caption and one line space below it>>

  __LaTeX__
  \abovecaptionskip default is only 10pt, not 12pt
  */
  show figure: set block(spacing: if latex-mimic { 10pt } else { 12pt })
  show figure: set figure(gap: if latex-mimic { 10pt } else { 12pt })

  /* TABLES
  __Explicit__
  <<Number tables consecutively. Place the table number and title (in 10 point font) above the table with one line space above the caption and one line space below it>>
  */
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

  /* TITLEBOX
  __Explicit__
  <<Leave two line spaces between the last author listed and the text of the paper; the text of the paper (starting with the abstract) should begin no less than 2.75 inches below the top of the page.>>

  __LaTeX__ (lines 145-162):
  \vbox to \titlebox{         % Minimum 5cm box (line 119)
    {\LARGE\bf \@title \par}  % Title
    \vskip 1em                % Gap after title (line 148)
    \outauthor                % Authors
    \vskip 2em                % Gap after authors (line 161)
  }
  */
  let titlebox-content = {
    if title != none {
      /* TITLE
      __Explicit__
      <<The title should be in 14 point bold font, centered.>>

      __LaTeX__
      \LARGE\bf = 14pt font with 17pt leading (cogsci.sty line 243)
      */
      align(center)[
        #block(text(title, size: 14pt, weight: "bold", bottom-edge: "bounds"))
        #v(12pt, weak: true)
      ]
    }
    block(above: 12pt, below: 12pt)[
      #if anonymize {
        anonymous-authors
      } else {
        authors
      }
    ]
    v(if latex-mimic { 2em } else { 12pt * 2 }, weak: false) // LaTeX \vskip 2em at end of titlebox (line 161)
  }

  context {
    let measured = measure(titlebox-content)
    let latex-titlebox-height = 5cm + 2pt
    let max-height-explicit = 2.75in - 1in // Maximum space from top margin (1in) to start of abstract
    let max-height = if latex-mimic { latex-titlebox-height } else { max-height-explicit }
    let actual-height = measured.height
    let exceeds-max = actual-height > max-height

    // Red background if content exceeds maximum allowed height
    let background = if exceeds-max { rgb("#d100003f") } else { none }

    // If content is smaller than max-height, add gap to reach max-height
    // If content exceeds max-height, no additional gap needed (content pushes it down)
    let gap-needed = calc.max(0pt, max-height - actual-height)

    place(
      top + center,
      scope: "parent",
      float: true,
      clearance: gap-needed,
      block(
        width: 100%,
        height: if exceeds-max { max-height } else { auto },
        breakable: false,
        fill: background,
        clip: exceeds-max, // Only clip if content exceeds max height
        titlebox-content,
      ),
    )
  }

  set align(top)

  // Internal helper: Format keywords section
  let format-keywords(keywords-array) = {
    // Runtime type validation
    assert(
      type(keywords-array) == array,
      message: "format-keywords: must be an array, got " + str(type(keywords-array)),
    )

    text(size: 9pt)[
      #text(weight: "bold")[Keywords:]
      #keywords-array.join("; ")
    ]
  }


  /* ABSTRACT
  __Explicit__
  <<The abstract should be one paragraph, indented 1/8 inch on both sides, in 9 point font with single spacing.>>

  __Word__
  9pt font with exact 10pt line spacing

  __LaTeX__
  abstract uses quote environment (1/8" indent) with \small (9pt/9pt)
  */
  block([
    #pad(x: indent, top: 1pt, bottom: 2pt)[
      #set text(size: 9pt)  // LaTeX \small
      #set par(
        first-line-indent: indent,
        justify: true,
        leading: if latex-mimic { calc-leading(9pt, 9pt) } else { calc-leading(10pt, 9pt) }, // Word uses 10pt line spacing, but latex uses 9pt
        spacing: if latex-mimic { calc-leading(9pt, 9pt) } else { calc-leading(10pt, 9pt) },
      )

      /*
      __Explicit__
      <<The heading "*Abstract*" should be 10 point, bold, centered, with one line of space below it.>>
      <<Following the abstract should be a blank line, followed by the header 'Keywords:' and a list of descriptive keywords separated by semicolons, all in 9 point font>>

      __Word__
      10pt bold centered heading "Abstract" with 6pt space below

      __LaTeX__
      \renewenvironment{abstract}{\centerline{\bf Abstract}\begin{quote}\small}
      The quote environment adds \topsep = 4pt (cogsci.sty line 193)
      */
      #if abstract != none {
        block(width: 100%, above: 0pt, below: 12pt)[
          #align(center, heading(
            outlined: false,
            numbering: none,
            text([Abstract], size: 10pt, weight: "bold", bottom-edge: "bounds"),
          ))
        ]
        abstract
      }

      #if keywords != none and keywords.len() > 0 {
        block(above: if latex-mimic { 7pt } else { 9pt }, format-keywords(keywords)) // should be 9 but LaTeX uses less
      }
    ]
  ])

  /* BIBLIOGRAPHY
  __Explicit__
  Use a first level section heading, "References", as shown below. Use a hanging indent style, with the first line of the reference flush against the left margin and subsequent lines indented by 1/8 inch.>>
  */
  show bibliography: set par(
    first-line-indent: 0pt,
    hanging-indent: indent,
  )
  set bibliography(title: "References", style: "apa")

  /* APA MODIFICATIONS
  __Explicit__
  <<Follow the APA Publication Manual for citation format, both within the text and in the reference list, with the following exceptions: (a) do not cite the page numbers of any book, including chapters in edited volumes; (b) use the same format for unpublished references as for published ones. Alphabetize references by the surnames of the authors, with single author entries preceding multiple author entries. Order references by the same authors by the year of publication, with the earliest first.>>
  */

  body
}

