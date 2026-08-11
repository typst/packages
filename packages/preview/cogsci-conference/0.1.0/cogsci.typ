// CogSci Conference Template

#let _mimic-latex = true // Set to false to disable LaTeX visual mimicry features
// #let _mimic-latex = false


/// Adds _ad hoc_ vertical padding to adjust page layout to better match the LaTeX template output.
///
/// LaTeX uses flexible spacing to align the last line of a column with the bottom of the page, whereas Typst does not. For the sake of matching the appearance of LaTeX output, we add some _ad hoc_ vertical space.
///
/// - amount (fraction, relative): How much spacing to insert.
///
/// -> content, none
#let ad-hoc-padding(amount) = if _mimic-latex { v(amount, weak: false) } else { none }


/// Formats author information according to CogSci conference style.
///
/// Each author's name appears on a separate line in 11pt bold, centered, with optional email address in parentheses. Affiliations appear below names in 10pt regular font.
///
/// ```
/// // Single author with email and affiliation
/// #format-authors(
///   (name: "Author One", email: "a1@ua.edu", affiliation: "Department Details")
/// )
/// ```
///
/// ```
/// // Multiple authors passed as separate arguments
/// #format-authors(
///   (name: "Author One", email: "a1@ua.edu", affiliation: "Department Details"),
///   (name: "Author Two", email: "a2@ub.edu", affiliation: "Department Details"),
/// )
/// ```
///
/// ```
/// // Multiple authors passed as array
/// #let authors = (
///   (name: "Author One", email: "a1@ua.edu", affiliation: "Department Details"),
///   (name: "Author Two", email: "a2@ub.edu", affiliation: "Department Details"),
/// )
/// #format-authors(authors)
/// ```
///
/// Each author dictionary must contain:
/// - `name` (content, str): Author's full name (required)
/// - `email` (str): Email address (optional)
/// - `affiliation` (content, str): Institution and address (optional)
///
/// - authors (dictionary, array): Variable number of author dictionaries, or a single array containing author dictionaries.
///
/// -> content, none
#let format-authors(..authors) = {
  // Extract positional arguments as array of author dictionaries
  let author-list = authors.pos()

  // Support both calling patterns:
  // - format-authors(author-dict-1, author-dict-2, ...)
  // - format-authors((author-dict-1, author-dict-2, ...)) where authors-info is an array
  if author-list.len() == 1 and type(author-list.at(0)) == array {
    author-list = author-list.at(0)
  }

  // Validate each author is a dictionary with required 'name' key
  for (i, author) in author-list.enumerate() {
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
  «In the initial submission, the phrase "Anonymous CogSci submission" should appear below the title, centered, in 11 point bold font. In the final submission, each author's name should appear on a separate line, 11 point bold, and centered, with the author's email address in parentheses. Under each author's name list the author's affiliation and postal address in ordinary 10 point type.»

  __LaTeX__
  \large\bf = 11pt font with 13pt leading (cogsci.sty line 241)
  */
  if author-list.len() > 0 {
    return align(center)[
      #for (i, author) in author-list.enumerate() {
        // Add spacing before each author (including first, which comes after title)
        block(above: if _mimic-latex { 16pt } else { 12pt }, below: 0pt)[
          #text(size: 11pt, weight: "bold")[
            #author.name
            #if "email" in author [(#author.email)]
          ]
          #if "affiliation" in author [#text(size: 10pt, weight: "regular")[#linebreak()#author.affiliation]]
        ]
      }
    ]
  } else {
    return none
  }
}


/// Main CogSci conference template function.
///
/// This function applies the complete CogSci conference paper formatting to
/// your document, including page layout, typography, and structural elements.
/// It matches the official LaTeX template's visual output.
///
/// The template handles all standard conference requirements including title
/// formatting (14pt bold, centered), author blocks, abstract (9pt), keywords,
/// and proper page margins. Use with a show rule to apply the template to
/// your entire document.
///
/// ```
/// #show: cogsci.with(
///   title: [Paper Title],
///   authors: format-authors(
///     (name: "Author One", email: "a1@ua.edu", affiliation: "Department Details")
///   ),
///   abstract: [This is the abstract text...],
///   keywords: ("keyword1", "keyword2"),
/// )
///
/// = Introduction
/// Paper content...
/// ```
///
/// ```
/// // Anonymous submission for review
/// #show: cogsci.with(
///   title: [Paper Title],
///   abstract: [Abstract text...],
///   keywords: ("cognitive science", "research"),
///   anonymize: true,
/// )
/// ```
///
/// - title (content, str, none): Paper title, displayed in 14pt bold and centered.
/// - authors (content, none): Pre-formatted author information from the `format-authors()` function. Ignored if `anonymize` is true.
/// - abstract (content, str, none): Paper abstract, displayed in 9pt font.
/// - keywords (array): Array of keyword strings to display after the abstract.
/// - anonymize (bool): If true, displays "Anonymous CogSci submission" instead of author information for blind review submissions.
/// - hyphenate (bool): If false, disables automatic hyphenation throughout the document.
/// - text-kwargs (dictionary): Additional named arguments to pass to `set text()`.
/// - page-kwargs (dictionary): Additional named arguments to pass to `set page()`.
/// - document-kwargs (dictionary): Additional named arguments to pass to `set document()`.
/// - body (content): The main document content.
///
/// -> content
#let cogsci(
  title: [],
  authors: [],
  abstract: [],
  keywords: (),
  anonymize: false,
  hyphenate: true,
  text-kwargs: (:),
  page-kwargs: (:),
  document-kwargs: (:),
  body,
) = {
  // Runtime type validation for parameters

  assert(
    type(title) == content or type(title) == str or title == none,
    message: "cogsci: title must be content or string, got " + str(type(title)),
  )

  assert(
    type(authors) == content or authors == none,
    message: "cogsci: authors must be content (e.g. the output of the format-authors() helper function), got "
      + str(type(authors)),
  )

  assert(
    type(abstract) == content or type(abstract) == str or abstract == none,
    message: "cogsci: abstract must be content or string, got " + str(type(abstract)),
  )

  assert(
    type(keywords) == array,
    message: "cogsci: keywords must be an array, got " + str(type(keywords)),
  )

  assert(
    type(anonymize) == bool,
    message: "cogsci: anonymize must be a boolean, got " + str(type(anonymize)),
  )

  assert(
    type(hyphenate) == bool,
    message: "cogsci: hyphenate must be a boolean, got " + str(type(hyphenate)),
  )

  /// The anonymous authors placeholder for blind review submissions.
  /// -> content
  let anonymous-authors = {
    align(center)[
      #block(above: 12pt, below: 0pt)[
        #text(size: 11pt, weight: "bold")[
          Anonymous CogSci submission
        ]
      ]
    ]
  }

  // Set document metadata
  let doc-specs = (
    author: (),
    title: title,
    keywords: keywords,
    ..document-kwargs, // Additional user-specified document settings
  )
  if anonymize {
    doc-specs = doc-specs + (author: "Anonymous")
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
  /// - baseline (length): Desired baseline-to-baseline distance.
  /// - font-size (length): Font size.
  ///
  /// -> length
  let calc-leading(baseline, font-size) = {
    baseline - (cap-height-ratio * font-size)
  }

  /* INDENTATION
  __Explicit__
  «Indent the first line of each paragraph by 1/8 inch (except for the first paragraph of a new section). Do not add extra vertical space between paragraphs.»

  __LaTeX__
  \parindent 10pt (cogsci.sty line 192)
  */
  let indent = if _mimic-latex { 10pt } else { 1in / 8 }

  /* PAGE
  __Explicit__
  «The text of the paper should be formatted in two columns with an overall width of 7 inches (17.8 cm) and length of 9.25 inches (23.5 cm), with 0.25 inches between the columns. Leave two line spaces between the last author listed and the text of the paper; the text of the paper (starting with the abstract) should begin no less than 2.75 inches below the top of the page. The left margin should be 0.75 inches and the top margin should be 1 inch. *The right and bottom margins will depend on whether you use U.S. letter or A4 paper, so you must be sure to measure the width of the printed text.* Use 10 point Times Roman with 12 point vertical spacing, unless otherwise specified.»
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
  «Indent the first line of each paragraph by 1/8 inch (except for the first paragraph of a new section). Do not add extra vertical space between paragraphs.»

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

  /* MATH FONT
  __LaTeX__
  The LaTeX template uses \usepackage{pslatex} which is deprecated.
  pslatex uses the mathptm package for math, which provides:
  - Symbol font for Greek letters (upright, not italic)
  - Zapf Chancery for calligraphic alphabet
  - No bold math fonts

  __Typst__
  We use "New Computer Modern Math" as a modern replacement for mathptm.
  Note that "TeX Gyre Termes Math" is a modern OpenType math font that is Times-compatible and provides proper math typography (italic Greek, variants, bold, etc.), but it is not included with Typst by default.
  */
  show math.equation: set text(font: "New Computer Modern Math")

  /* MATH EQUATION SETTINGS
  __LaTeX__ (cogsci.sty lines 228-231)
  \abovedisplayskip 7pt plus2pt minus5pt
  \belowdisplayskip \abovedisplayskip
  \abovedisplayshortskip 0pt plus3pt
  \belowdisplayshortskip 4pt plus3pt minus3pt
  Note: These are smaller than LaTeX defaults (12pt), appropriate for two-column format.

  __Typst__
  Typst doesn't distinguish between "short" and "long" display skips.
  Using the base value (7pt) for spacing.
  */

  // Display equation spacing (matches LaTeX \abovedisplayskip/\belowdisplayskip)
  // show math.equation.where(block: true): set block(
  //   above: 7pt, // LaTeX: 7pt plus 2pt minus 5pt
  //   below: 7pt, // LaTeX: same as above
  // )

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
  «First level headings should be in 12 point, initial caps, bold and centered. Leave one line space above the heading and 1/4 line space below the heading.»

  __LaTeX__
  Section: -1.5ex before, 3pt after, \Large\bf\centering (line 175-176)
  At 10pt, 1ex ≈ 4.3pt (x-height), so -1.5ex ≈ 6.4pt

  Note: Setting bottom-edge to "bounds" ensures spacing is measured from the visual bottom of letters (including descenders), not the baseline.
  */
  show heading.where(level: 1): it => {
    set block(
      above: 12pt,
      below: if _mimic-latex { 6pt } else { 12pt / 4 },
    )
    set text(size: 12pt, weight: "bold", bottom-edge: "bounds")
    align(center, it)
  }

  /* HEADINGS - Level 2
  __Explicit__
  «Second level headings should be 11 point, initial caps, bold, and flush left. Leave one line space above the heading and 1/4 line space below the heading.»

  __LaTeX__
  Subsection: -1.5ex before, 3pt after, \large\bf\raggedright (line 177-178)

  Note: Setting bottom-edge to "bounds" ensures spacing is measured from the visual
  bottom of letters (including descenders), not the baseline.
  */
  show heading.where(level: 2): it => {
    set block(
      above: 12pt,
      below: if _mimic-latex { 6pt } else { 12pt / 4 },
    ) // explicitly, it should be `block(above: 11pt, below: 3pt)`
    set text(size: 11pt, weight: "bold", bottom-edge: "bounds")
    it
  }

  /* HEADINGS - Level 3
  __Explicit__
  «Third level headings should be 10 point, initial caps, bold, and flush left. Leave one line space above the heading, but no space after the heading.»

  __LaTeX__
  Subsubsection: -6pt before, -1em after, \normalsize\bf (line 179-180)
  Negative afterskip means run-in heading (on same line as following text)
  */
  show heading.where(level: 3): it => {
    [#parbreak()
      #if _mimic-latex {
        v(-1pt, weak: true) // Pull back from paragraph spacing context // ad-hoc correction to match LaTeX spacing
      } else { none }
      \ #text(it.body, size: 10pt, weight: "bold")
      #h(1em, weak: false)]
  }

  /* FOOTNOTES
  __Explicit__
  «Indicate footnotes with a number in the text. Place the footnotes in 9 point font at the bottom of the column on which they appear. Precede the footnote block with a horizontal rule.»

  __LaTeX__ (cogsci.sty lines 185-187):
  \skip\footins: 9pt plus 4pt minus 2pt
  ( \skip\footins - |\kern-3pt| = 9pt - 3pt = 6pt clearance )
  \footnoterule: \kern-3pt \hrule width 5pc \kern 2.6pt
  ( 5pc = 60pt wide rule )
  \footnotesep: 6.65pt
  */
  set footnote(numbering: "1")

  set footnote.entry(
    separator: line(length: 60pt, stroke: 0.5pt),
    gap: if _mimic-latex { 4.6pt } else { 0.5em },
    indent: if _mimic-latex { 12pt } else { indent },
    clearance: if _mimic-latex { 6pt } else { 1em },
  )

  show footnote.entry: it => {
    set text(size: 9pt)
    set par(
      first-line-indent: if _mimic-latex { 9pt } else { indent },
      hanging-indent: 0pt,
      leading: calc-leading(9pt, 9pt),
      spacing: calc-leading(9pt, 9pt),
    )
    it
  }

  /* FIGURES
  __Explicit__
  «Number figures sequentially, placing the figure number and caption, in 10 point, after the figure with one line space above the caption and one line space below it»

  __LaTeX__
  \abovecaptionskip default is only 10pt, not 12pt
  */
  set figure(numbering: "1")
  show figure.caption: it => {
    set par(first-line-indent: 0pt)
    it
  }
  show figure: set block(spacing: if _mimic-latex { 10pt } else { 12pt })
  show figure: set figure(gap: if _mimic-latex { 10pt } else { 12pt })

  /* TABLES
  __Explicit__
  «Number tables consecutively. Place the table number and title (in 10 point font) above the table with one line space above the caption and one line space below it»
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
  «Leave two line spaces between the last author listed and the text of the paper; the text of the paper (starting with the abstract) should begin no less than 2.75 inches below the top of the page.»

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
      «The title should be in 14 point bold font, centered.»

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
    v(if _mimic-latex { 2em } else { 12pt * 2 }, weak: false) // LaTeX \vskip 2em at end of titlebox (line 161)
  }

  context {
    let measured = measure(titlebox-content)
    let latex-titlebox-height = 5cm + 2pt
    let max-height-explicit = 2.75in - 1in // Maximum space from top margin (1in) to start of abstract
    let max-height = if _mimic-latex { latex-titlebox-height } else { max-height-explicit }
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

  /// Formats the keywords section following CogSci style.
  ///
  /// Displays keywords in 9pt font with bold "Keywords:" label, separated by semicolons.
  ///
  /// - keywords-array (array): Array of keyword strings.
  ///
  /// -> content
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
  «The abstract should be one paragraph, indented 1/8 inch on both sides, in 9 point font with single spacing.»

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
        leading: if _mimic-latex { calc-leading(9pt, 9pt) } else { calc-leading(10pt, 9pt) }, // Word uses 10pt line spacing, but latex uses 9pt
        spacing: if _mimic-latex { calc-leading(9pt, 9pt) } else { calc-leading(10pt, 9pt) },
      )

      /*
      __Explicit__
      «The heading "*Abstract*" should be 10 point, bold, centered, with one line of space below it.»
      «Following the abstract should be a blank line, followed by the header 'Keywords:' and a list of descriptive keywords separated by semicolons, all in 9 point font»

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
        block(above: if _mimic-latex { 7pt } else { 9pt }, format-keywords(keywords)) // should be 9 but LaTeX uses less
      }
    ]
  ])

  /* BIBLIOGRAPHY
  __Explicit__
  Use a first level section heading, "References", as shown below. Use a hanging indent style, with the first line of the reference flush against the left margin and subsequent lines indented by 1/8 inch.»
  */
  show bibliography: set par(
    first-line-indent: 0pt,
    hanging-indent: indent,
  )
  set bibliography(title: "References", style: "apa")

  /* APA MODIFICATIONS
  __Explicit__
  «Follow the APA Publication Manual for citation format, both within the text and in the reference list, with the following exceptions: (a) do not cite the page numbers of any book, including chapters in edited volumes; (b) use the same format for unpublished references as for published ones. Alphabetize references by the surnames of the authors, with single author entries preceding multiple author entries. Order references by the same authors by the year of publication, with the earliest first.»
  */

  body
}

