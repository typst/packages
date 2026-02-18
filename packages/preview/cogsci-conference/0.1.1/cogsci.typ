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


/// Formats author and affiliation information according to CogSci conference style.
///
/// Authors appear on a single line in 11pt bold, centered, joined with commas
/// and ampersand. Optional superscript numbers link authors to affiliations.
/// Affiliations appear below in 10pt regular font.
///
/// Accepts multiple input patterns:
///
/// #example(```
/// // Named parameters with full dictionary structure
/// #format-authors(
///   authors: (
///     (name: [Author One], email: "a1@ua.edu", super: [1]),
///     (name: [Author Two], super: [2]),
///   ),
///   affiliations: (
///     (super: [1], affil: [Department A]),
///     (super: [2], affil: [Department B]),
///   ),
/// )
/// ```)
///
/// #example(```
/// // Positional arguments with tuple affiliations
/// #format-authors(
///   (
///     (name: [Author One], email: "a1@ua.edu", super: [1]),
///     (name: [Author Two], super: [2]),
///   ),
///   (
///     ([1], [Department A]),
///     ([2], [Department B]),
///   ),
/// )
/// ```)
///
/// #example(```
/// // Single shared affiliation (simplest form)
/// #format-authors(
///   (
///     (name: [Author One], email: "a1@ua.edu"),
///     (name: [Author Two]),
///   ),
///   [Department A],
/// )
/// ```)
///
/// Each author dictionary must contain:
/// - `name` (content): Author's full name (required)
/// - `email` (str): Email address (optional)
/// - `super` (content): Superscript linking to affiliation (optional)
///
/// Affiliations can be:
/// - Array of dictionaries: `((super: [1], affil: [Dept A]), ...)`
/// - Array of tuples: `(([1], [Dept A]), ...)`
/// - Single content: `[Shared Department]`
///
/// - authors (array): Array of author dictionaries, or first positional argument
/// - affiliations (array, content): Affiliation data, or second positional argument
/// -> content, none
#let format-authors(..args, authors: none, affiliations: none) = {
  // Internal: Normalizes heterogeneous author/affiliation input formats.
  //
  // Parameters:
  //   authors (array, none): Array of author dicts, or first positional arg
  //   affiliations (array, content, str, none): Affiliation data, or second positional arg
  //
  // Returns (dictionary):
  //   authors (array): ((name: content, email: str|none, super: content), ...)
  //   affiliations (array): ((super: content, affil: content), ...)
  let authors-structure-input(
    authors: none,
    affiliations: none,
    ..args,
  ) = {
    // Resolve authors and affiliations from either named or positional args
    let resolved-authors = if authors != none {
      authors
    } else if args.pos().len() >= 1 {
      args.pos().at(0)
    } else {
      ()
    }

    let resolved-affiliations = if affiliations != none {
      affiliations
    } else if args.pos().len() >= 2 {
      args.pos().at(1)
    } else {
      ()
    }

    // Validate resolved-authors is an array
    if resolved-authors != () {
      assert(
        type(resolved-authors) == array,
        message: "format-authors: 'authors' must be an array, got " + str(type(resolved-authors)),
      )
    }

    // Normalize affiliations to standard format
    let normalize-affiliations(affils) = {
      // Case: Empty/none
      if affils == none or affils == () {
        return ()
      }

      // Case: Single content value (one shared affiliation)
      if type(affils) == content {
        return ((super: [], affil: affils),)
      }

      // Case: Single string value
      if type(affils) == str {
        return ((super: [], affil: [#affils]),)
      }

      // Case: Array of affiliations
      if type(affils) == array {
        return affils
          .enumerate()
          .map(((idx, a)) => {
            // Already in dict format with affil key
            if type(a) == dictionary and "affil" in a {
              (
                super: a.at("super", default: []),
                affil: a.affil,
              )
            } // Tuple format: (super, affil)
            else if type(a) == array and a.len() >= 2 {
              (
                super: a.at(0),
                affil: a.at(1),
              )
            } // Single-element tuple: (affil,) - no super
            else if type(a) == array and a.len() == 1 {
              (super: [], affil: a.at(0))
            } // Single content in array (no super)
            else if type(a) == content {
              (super: [], affil: a)
            } // Single string in array
            else if type(a) == str {
              (super: [], affil: [#a])
            } else {
              assert(
                false,
                message: "format-authors: affiliation at index "
                  + str(idx)
                  + " has invalid type: "
                  + str(type(a))
                  + ". Expected dictionary with 'affil' key, array (super, affil), or content.",
              )
            }
          })
      }

      assert(
        false,
        message: "format-authors: 'affiliations' has invalid type: "
          + str(type(affils))
          + ". Expected array, content, or string.",
      )
    }

    // Normalize authors to standard format
    let normalize-authors(auths) = {
      if auths == () or auths == none {
        return ()
      }

      auths
        .enumerate()
        .map(((idx, a)) => {
          // Validate author entry is a dictionary
          assert(
            type(a) == dictionary,
            message: "format-authors: author at index " + str(idx) + " must be a dictionary, got " + str(type(a)),
          )
          assert(
            "name" in a,
            message: "format-authors: author at index " + str(idx) + " must have a 'name' key",
          )

          let name = a.name
          let email = a.at("email", default: none)

          // Normalize super: treat none and [] as equivalent (no superscript)
          let super-val = a.at("super", default: [])
          if super-val == none {
            super-val = []
          }

          (
            name: name,
            email: email,
            super: super-val,
          )
        })
    }

    // Process affiliations first
    let normalized-affiliations = normalize-affiliations(resolved-affiliations)

    // Process authors
    let normalized-authors = normalize-authors(resolved-authors)

    // Return standardized structure
    (
      authors: normalized-authors,
      affiliations: normalized-affiliations,
    )
  }

  // Use authors-structure-input to normalize all input formats
  let data = authors-structure-input(..args, authors: authors, affiliations: affiliations)
  let author-list = data.authors
  let affil-list = data.affiliations

  if author-list.len() == 0 {
    return none
  }

  // Helper to check if super is "empty" (none or empty content)
  let is-empty-super(s) = s == none or s == []

  // Build author entries: name + optional superscript + optional email
  let author-entries = author-list.map(entry => {
    let has-super = not is-empty-super(entry.super)
    let has-email = entry.email != none

    if has-email {
      if has-super {
        [#entry.name (#entry.email)#super[#entry.super]]
      } else {
        [#entry.name (#entry.email)]
      }
    } else {
      if has-super {
        [#entry.name#super[#entry.super]]
      } else {
        [#entry.name]
      }
    }
  })

  // Join with comma/ampersand, boxing to maintain baseline alignment
  let authors-line = if author-entries.len() == 0 {
    []
  } else if author-entries.len() == 1 {
    box(author-entries.at(0))
  } else if author-entries.len() == 2 {
    box(author-entries.at(0)) + [ ] + box([&~] + author-entries.at(1))
  } else {
    // 3+ authors: "A, B, ... & Z"
    let parts = author-entries.slice(0, -1).map(e => box[#e,])
    parts.join([ ]) + [ ] + box([&~] + author-entries.last())
  }

  // Build affiliation lines: superscript label + affiliation text
  let affil-lines = affil-list.map(entry => {
    let has-super = not is-empty-super(entry.super)
    if has-super {
      super[#entry.super~] + entry.affil
    } else {
      entry.affil
    }
  })

  let divider = linebreak
  return align(center)[
    #set par(justify: false)

    #set par(
      leading: 3pt,
      spacing: 3pt,
    ) if _mimic-latex

    #if _mimic-latex { v(0.7pt) }

    #text(size: 11pt, weight: "bold")[#authors-line]
    #if affil-lines.len() > 0 {
      divider()
      text(size: 10pt, weight: "regular")[#affil-lines.join(divider())]
    }
  ]
}


/// Main CogSci conference template function.
///
/// This function applies the complete CogSci conference paper formatting to your document, including page layout, typography, and structural elements. It matches the official LaTeX template's visual output.
///
/// The template handles all standard conference requirements including title formatting (14pt bold, centered), author blocks, abstract (9pt), keywords, and proper page margins. Use with a show rule to apply the template to your entire document.
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
  author-info: [],
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
    type(author-info) == content or author-info == none,
    message: "cogsci: author-info must be content (e.g. the output of the format-authors() helper function), got "
      + str(type(author-info)),
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

  let x-target = sys.inputs.at("x-target", default: "pdf")

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
  set document(..doc-specs) if x-target == "pdf"

  // Typst leading calculation constants for Times New Roman
  //
  // Sources:
  //   https://www.readz.com/web-fonts-and-typography
  //   https://typedrawers.com/discussion/4949/reasons-to-not-standardize-cap-height-across-font-library
  //
  // Typst's leading parameter measures space between bottom of one line and top of next.
  // With default settings (top-edge: "cap-height", bottom-edge: "baseline"):
  //   baseline-to-baseline = leading + cap-height
  //   leading = baseline-to-baseline - cap-height
  //   leading = baseline-to-baseline - (cap-height-ratio * font_size)

  // let cap-height-ratio = 0.6621
  let cap-height-ratio = 2 / 3

  /// Calculate Typst leading parameter for desired baseline-to-baseline spacing.
  ///
  /// - baseline (length): Desired baseline-to-baseline distance.
  /// - font-size (length): Font size.
  ///
  /// -> length
  // let calc-leading(baseline, font-size) = {
  //   baseline - (cap-height-ratio * font-size)
  // }

  /* Possible update: to make leading calculations more accurate, we could set:
  top-edge: "ascender",
  bottom-edge: "descender",
  and then use ascender + descender for the calculations.
  */
  let line-height-ratio = 0.8835 // ascender + descender for Times New Roman
  let calc-leading(baseline, font-size) = {
    baseline - (line-height-ratio * font-size)
  }

  /* INDENTATION
  __Explicit__
  «Indent the first line of each paragraph by 1/8 inch (except for the first paragraph of a new section). Do not add extra vertical space between paragraphs.»

  __LaTeX__
  \parindent 10pt (cogsci.sty line 192)
  */
  let indent = 1in / 8

  /* LINE HEIGHT
  __Explicit__
  «Use 10 point Times Roman with 12 point vertical spacing, unless otherwise specified.»

  __LaTeX__
  \setlength\baselineskip{12pt}
  \documentclass[10pt,letterpaper]{article}
  */
  let line-height = 12pt

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
  ) if x-target == "pdf"
  set columns(gutter: column-gap)

  set text(
    /* Global settings */
    font: (
      "TeX Gyre Termes",
      "Times New Roman",
    ),
    top-edge: "cap-height",
    bottom-edge: "descender",
    lang: "en", // ISO 639-1/2/3 language code
    region: "US", // ISO 3166-1 alpha-2 region code
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
  show math.equation: set text(font: (
    "TeX Gyre Termes Math",
    "New Computer Modern Math",
  ))

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
    leading: calc-leading(line-height, 10pt), // 12pt baseline - (cap-height-ratio × 10pt)
    spacing: calc-leading(line-height, 10pt),
    /* Microtypography */
    linebreaks: "optimized",
    // justification-limits: (
    //   spacing: (min: 95%, max: 140%), // The spacing entry defines how much the width of spaces between words may be adjusted.
    //   tracking: (min: -0.005em, max: 0.015em), // The tracking entry defines how much the spacing between letters may be adjusted.
    // ),
  )

  /* LISTS
  List and enum spacing configuration to match LaTeX cogsci.sty
  */

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

  /* HEADINGS */

  // Disable heading numbering
  set heading(numbering: none)

  /* HEADINGS - Level 1
  __Explicit__
  «First level headings should be in 12 point, initial caps, bold and centered. Leave one line space above the heading and 1/4 line space below the heading.»

  __LaTeX__
  Section: -1.5ex before, 3pt after, \Large\bf\centering (line 175-176)
  At 10pt, 1ex ≈ 4.3pt (x-height), so -1.5ex ≈ 6.4pt

  Note: Setting bottom-edge to "descender" ensures spacing is measured from the visual bottom of letters (including descenders), not the baseline.
  */
  show heading.where(level: 1): it => {
    set block(
      above: line-height,
      below: if _mimic-latex { 5.5pt } else { line-height / 4 },
    )
    set text(
      size: 12pt,
      weight: "bold",
    )
    align(center, it)
  }

  /* HEADINGS - Level 2
  __Explicit__
  «Second level headings should be 11 point, initial caps, bold, and flush left. Leave one line space above the heading and 1/4 line space below the heading.»

  __LaTeX__
  Subsection: -1.5ex before, 3pt after, \large\bf\raggedright (line 177-178)

  Note: Setting bottom-edge to "descender" ensures spacing is measured from the visual
  bottom of letters (including descenders), not the baseline.
  */
  show heading.where(level: 2): it => {
    set block(
      above: if _mimic-latex { line-height + 0.3pt } else { line-height },
      below: if _mimic-latex { 5.1pt } else { line-height / 4 },
    ) // explicitly, it should be `block(above: 11pt, below: 3pt)`
    set text(size: 11pt, weight: "bold")
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
    v(line-height, weak: true)
    (
      block(above: 0pt, below: 0pt)
        + box(text(it.body, size: 10pt, weight: "bold") + h(1em, weak: false), baseline: 0.2em)
    )
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

  /* With `top-edge: "ascender", bottom-edge: "baseline"`: `gap: 4.4pt` :: */
  set footnote.entry(
    separator: line(length: 60pt, stroke: 0.5pt),
    gap: if _mimic-latex { 4.7pt } else { 0.5em },
    indent: if _mimic-latex { 12.7pt } else { indent },
    clearance: if _mimic-latex { 7pt } else { 1em },
  )

  show footnote.entry: it => {
    set text(
      size: 9pt,
      top-edge: "cap-height",
      bottom-edge: "baseline",
    )
    set par(
      first-line-indent: indent,
      hanging-indent: 0pt,
      leading: calc-leading(12pt, 9pt),
      spacing: calc-leading(12pt, 9pt),
    )
    it
  }

  /* With `top-edge: "cap-height", bottom-edge: "baseline"`: `gap: 5pt` ::

  set footnote.entry(
    separator: line(length: 60pt, stroke: 0.5pt),
    gap: if _mimic-latex {5pt } else { 0.5em },
    indent: if _mimic-latex { 12pt } else { indent },
    clearance: if _mimic-latex { 12pt } else { 1em },
  )

  show footnote.entry: it => {
    set text(size: 9pt, top-edge: "cap-height", bottom-edge: "baseline")
    set par(
      first-line-indent: if _mimic-latex { 9pt } else { indent },
      hanging-indent: 0pt,
      leading: calc-leading(11pt, 9pt),
      spacing: calc-leading(11pt, 9pt),
    )
    it
  }
  */

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
  show figure: set block(
    above: if _mimic-latex { 11pt } else { line-height },
    below: if _mimic-latex { 17pt } else { line-height },
  )
  show figure: set figure(gap: if _mimic-latex { 17.5pt } else { line-height })

  /* TABLES
  __Explicit__
  «Number tables consecutively. Place the table number and title (in 10 point font) above the table with one line space above the caption and one line space below it»
  */
  show figure.where(kind: table): set block(
    above: if _mimic-latex { 21pt } else { line-height },
    below: if _mimic-latex { 22.5pt } else { line-height },
  )
  show figure.where(kind: table): set figure(gap: if _mimic-latex { 10pt } else { line-height })
  show figure.where(kind: table): set figure.caption(position: top)

  // Table styling to match LaTeX tabular
  // LaTeX aligns text baseline so ascenders are near the top of cells
  // Typst centers text vertically, so we use asymmetric inset to match LaTeX
  set table.hline(stroke: 0.4pt)
  set table.vline(stroke: 0.4pt)

  show table: set text(
    top-edge: "cap-height", /// "cap-height" is correct, don't change to "ascender"
    bottom-edge: "descender",
  )
  show table: set table(
    stroke: none,
    gutter: 0em,
    // align: left, // LaTeX default, but intentionally leaving out here
    inset: (top: 2pt, bottom: 1.3pt, x: indent),
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
        #block(text(
          title,
          size: 14pt,
          weight: "bold",
          top-edge: "cap-height",
          bottom-edge: "descender",
        ))
        #v(12pt, weak: true)
      ]
    }
    block(above: line-height, below: line-height)[
      #if anonymize {
        format-authors(((name: [Anonymous CogSci submission]),))
      } else {
        author-info
      }
    ]
    v(if _mimic-latex { 2em } else { line-height * 2 }, weak: false) // LaTeX \vskip 2em at end of titlebox (line 161)
  }

  context {
    let min-height-explicit = 2.75in - 1in // Minimum space from top margin (1in) to start of abstract
    // let latex-titlebox-height = 1.75in + 2pt
    // let min-height = if _mimic-latex { latex-titlebox-height } else { min-height-explicit }

    let min-height = min-height-explicit

    let content-size = measure(titlebox-content)

    let actual-height = content-size.height
    let expanding = actual-height > min-height

    // let height-calculated = calc.max(min-height, content-size.height)
    let gap-needed = calc.max(0pt, min-height - actual-height)

    place(
      top + center,
      scope: "parent",
      float: true,
      clearance: gap-needed,
      block(
        width: 100%,
        height: auto,
        breakable: false,
        clip: false,
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
      message: "format-keywords: keywords-array must be an array, got " + str(type(keywords-array)),
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
  block(above: 0pt, below: 0pt, inset: 0pt, outset: 0pt)[
    #pad(x: indent, top: 1pt, bottom: 2pt)[
      #set text(size: 9pt)  // LaTeX \small
      #set par(
        first-line-indent: indent,
        justify: true,
        leading: calc-leading(10pt, 9pt),
        spacing: calc-leading(10pt, 9pt),
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
        block(width: 100%, above: 0pt, below: line-height)[
          #align(center, heading(
            outlined: false,
            numbering: none,
            text(
              [Abstract],
              size: 10pt,
              weight: "bold",
              bottom-edge: "descender",
            ),
          ))
        ]
        abstract
      }

      #if keywords != none and keywords.len() > 0 {
        block(above: 12pt, format-keywords(keywords)) // should be 9 but LaTeX uses less
      }
    ]
  ]

  /* BIBLIOGRAPHY
  __Explicit__
  Use a first level section heading, "References", as shown below. Use a hanging indent style, with the first line of the reference flush against the left margin and subsequent lines indented by 1/8 inch.»

  __Typst__
  Extremely hackly solution since `#show bibliography: set par(...)` no longer works in the latest Typst versions.
  */
  show bibliography: bib-it => {
    show block: block-it => context {
      if block-it.body == auto {
        block-it
      } else {
        if block-it.body.func() != [].func() {
          // block-it.body
          // parbreak()
          block-it
        } else {
          // par(block-it.body)
          // block-it.body
          set par(
            first-line-indent: 0pt,
            hanging-indent: -6pt,
          )
          pad(left: 15pt)[
            #par(block-it.body)]
        }
      }
    }
    bib-it
  }

  set bibliography(title: "References", style: "apa")

  /* APA MODIFICATIONS
  __Explicit__
  «Follow the APA Publication Manual for citation format, both within the text and in the reference list, with the following exceptions: (a) do not cite the page numbers of any book, including chapters in edited volumes; (b) use the same format for unpublished references as for published ones. Alphabetize references by the surnames of the authors, with single author entries preceding multiple author entries. Order references by the same authors by the year of publication, with the earliest first.»
  */

  body
}

