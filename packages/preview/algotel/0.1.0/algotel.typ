// Algotel Typst Template
// Based on algotel.cls LaTeX class
// For submissions to the AlgoTel conference

// =============================================================================
// Dependencies
// =============================================================================

#import "@preview/lemmify:0.1.8": *

// =============================================================================
// Font Configuration
// =============================================================================

// Libertinus Serif is the primary body font, with TeX Gyre Termes (Times-compatible) as fallback
// TeX Gyre Heros is the Helvetica/Arial-compatible font for headings
// Note: Users may need to install these fonts or adjust fallbacks for their system
#let text-font = ("libertinus serif", "TeX Gyre Termes", "Liberation Serif")
#let heading-font = ("TeX Gyre Heros", "Liberation Sans")
#let mono-font = ("TeX Gyre Cursor", "Liberation Mono")

// =============================================================================
// Language State (for theorem environment names)
// =============================================================================

#let algotel-lang = state("algotel-lang", "en")

// =============================================================================
// Theorem Environments (language-aware)
// =============================================================================
#let algotel-thm-style(
  thm-type,
  name,
  number,
  body
) = block(width: 100%, breakable: true, spacing:1em)[#{
  set align(left)

  strong(thm-type)
  if number != none {
    " " + strong(number)
  }

  if name != none {
     " " + emph[(#name)]
  }
  ". " + emph(body)
}]

#let algotel-proof-style(
  thm-type,
  name,
  number,
  body
) = block(width: 100%, breakable: true, spacing:1em)[#{
  set align(left)
  strong(thm-type)
  if name != none {
    " " + emph[(#name)]
  }
  ". " + body + h(1fr) + $square$
}]

#let theorem-eng-env = default-theorems("thm-group", 
lang: "en", 
thm-numbering: thm-numbering-linear,
max-reset-level: 0,
thm-styling: algotel-thm-style,
proof-styling: algotel-proof-style
)

#let theorem-fra-env = default-theorems("thm-group", 
lang: "fr", 
thm-numbering: thm-numbering-linear,
max-reset-level: 0,
thm-styling: algotel-thm-style,
proof-styling: algotel-proof-style
)
#let (
  definition,
  theorem,
  proof,
  remark,
  lemma,
  proposition,
  example,
  corollary
) = theorem-eng-env

// Remark and example are unnumbered by convention
#let remark = remark.with(numbering: none)
#let example = example.with(numbering: none)

// =============================================================================
// Helper Functions
// =============================================================================

// LaTeX fnsymbol-style footnote symbols (starting from †, skipping *)
#let fnsymbol(n) = {
  let symbols = ("†", "‡", "§", "¶", "‖", "**", "††", "‡‡")
  if n > 0 and n <= symbols.len() {
    symbols.at(n - 1)
  } else {
    str(n)  // Fallback to number if out of range
  }
}

// Process authors and affiliations to create formatted strings
#let process-authors(authors, affiliations, lang: "fr", show-marks: true) = {
  let author-parts = ()

  for author in authors {
    let name = author.name
    if show-marks and author.at("affiliations", default: none) != none {
      let marks = author.affiliations.map(id => str(id)).join(",")
      name = [#name#super[#marks]]
    }
    if author.at("thanks", default: none) != none {
      name = [#name#footnote[#author.thanks]]
    }
    author-parts.push(name)
  }

  let connector = if lang == "fr" { " et " } else { " and " }
  author-parts.join(", ", last: connector)
}

// Get author names only (for headers)
#let author-names(authors, lang: "fr") = {
  let connector = if lang == "fr" { " et " } else { " and " }
  authors.map(a => a.name).join(", ", last: connector)
}

// Format affiliations with superscript numbers
#let format-affiliations(affiliations) = {
  affiliations.map(aff => {
    [#super[#aff.id] #aff.name]
  }).join(linebreak())
}

// =============================================================================
// Main Template Function
// =============================================================================

#let algotel(
  title: none,
  short-title: none,
  authors: (),
  affiliations: (),
  abstract: none,
  keywords: (),
  lang: "fr",
  paper: "a4",  // "a4" (default) or "us-letter"
  front-matter-spacing: auto,  // Optional dictionary to override front matter spacing
  body,
) = {
  
  // Validate required fields
  assert(title != none, message: "Title is required")
  assert(authors.len() > 0, message: "At least one author is required")

  // Front matter spacing defaults (user overrides via front-matter-spacing)
  let fm = (
    after-title: 16pt,
    after-authors: 6pt,
    after-affiliations: 10pt,
    after-rule-top: 2pt,
    after-abstract: 4pt,
    after-keywords: 4pt,
    after-rule-bottom: 10pt,
  )
  if front-matter-spacing != auto {
    for (key, val) in front-matter-spacing {
      fm.insert(key, val)
    }
  }

  // Use short title for headers if provided, otherwise use full title
  let header-title = if short-title != none { short-title } else { title }
  let header-authors = author-names(authors, lang: lang)

  // Language-specific settings
  let keywords-label = if lang == "fr" { "Mots-clefs :" } else { "Keywords:" }

  // Override French supplements (Typst defaults are wrong for academic papers)
  // "Section" not "Chapitre", "Figure" not "Fig.", "Tableau" not "Tab."
  let heading-supplement = if lang == "fr" { [Section] } else { auto }

  // ===========================================================================
  // Page Setup
  // ===========================================================================

  // Margins depend on paper size to maintain 15cm text width and 22cm text height
  let margins = if paper == "us-letter" {
    (left: 3.5cm, right: 3.09cm, top: 4.1cm, bottom: 1.94cm)
  } else {
    // A4 default
    (left: 3.5cm, right: 2.5cm, top: 4.1cm, bottom: 3.6cm)
  }

  set page(
    paper: paper,
    margin: margins,
    header-ascent: 1cm,
    footer-descent: 2cm,
    header: context {
      let page-num = counter(page).get().first()
      if page-num > 1 {
        set text(size: 10pt, style: "italic")
        if calc.rem(page-num, 2) == 1 {
          // Odd pages: title on the left
          header-title
        } else {
          // Even pages: authors on the right
          h(1fr)
          header-authors
        }
      }
    },
  )

  // ===========================================================================
  // Text and Paragraph Settings
  // ===========================================================================

  set text(
    font: text-font,
    size: 10pt,
    lang: lang,
  )

  set par(
    justify: true,
    leading: 0.55em,
    first-line-indent: 10pt, 
    spacing:0.55em
  )

  // ===========================================================================
  // Link Styling (all black, matching LaTeX)
  // ===========================================================================

  show link: set text(fill: black)
  show ref: set text(fill: black)

  // ===========================================================================
  // Heading Styles
  // ===========================================================================

  set heading(numbering: "1.1.1", supplement: heading-supplement)

  // Section (level 1): Sans-serif, 14pt, regular weight
  show heading.where(level: 1): it => {
    set text(font: heading-font, size: 14pt, weight: "regular")
    block(above: 1.4em, below: 0.75em)[
      #counter(heading).display("1") #h(0.3em) #it.body
    ]
  }

  // Subsection (level 2): Sans-serif, 12pt, italic
  show heading.where(level: 2): it => {
    set text(font: heading-font, size: 12pt, weight: "regular", style: "italic")
    block(above: 1.2em, below: 0.65em)[
      #counter(heading).display("1.1") #h(0.3em) #it.body
    ]
  }

  // Subsubsection (level 3): Sans-serif, 12pt, italic
  show heading.where(level: 3): it => {
    set text(font: heading-font, size: 12pt, weight: "regular", style: "italic")
    block(above: 1em, below: 0.55em)[
      #counter(heading).display("1.1.1") #h(0.3em) #it.body
    ]
  }

  // Paragraph (level 4): 10pt, bold, run-in style (inline with text)
  show heading.where(level: 4): it => {
    v(0.6em)
    text(size: 10pt, weight: "bold")[#it.body.]
    h(0.5em)
  }

  // ===========================================================================
  // Figure and Table Captions
  // ===========================================================================

  show figure: set block(spacing: 1.5em)

  // Override figure/table supplements: Typst French defaults are abbreviated ("Fig.", "Tab.")
  show figure.where(kind: image): set figure(supplement: [Figure])
  show figure.where(kind: table): set figure(supplement: if lang == "fr" { [Tableau] } else { [Table] })

  // Captions: small caps + bold label, colon separator, small font
  show figure.caption: it => [
      #set text(size: 9pt)
      #smallcaps(text(weight: "bold")[#it.supplement #context it.counter.display(it.numbering): ])
      #it.body
    ]
  

  // ===========================================================================
  // Code/Raw Text
  // ===========================================================================

  show raw: set text(font: mono-font)

  // ===========================================================================
  // Citations and Bibliography
  // ===========================================================================

  // Use alphanumeric citation style [ABC99] like LaTeX's alpha style
  // TODO: Typst's native alphanumeric style does not disambiguate labels when
  // two entries share the same authors and year (e.g., both get "[New01]"
  // instead of "[New01a]" and "[New01b]"). The Pergamon package
  // (@preview/pergamon) solves this but replaces the entire bibliography
  // pipeline, which is too invasive for now. Revisit when Pergamon stabilizes
  // or Typst adds native disambiguation.
  set cite(style: "alphanumeric")

  // Language-specific bibliography title
  let bib-title = if lang == "fr" { "Références" } else { "References" }
  set bibliography(title: bib-title)

  show bibliography: it => {
    set text(size: 8pt)
    // Remove numbering from bibliography heading
    show heading.where(level: 1): it => {
      set text(font: heading-font, size: 14pt, weight: "regular")
      block(above: 1.4em, below: 0.75em)[#it.body]
    }
    it
  }

  // ===========================================================================
  // Footnotes (using LaTeX fnsymbol style: *, †, ‡, §, ¶, ‖, ...)
  // ===========================================================================

  // Use symbol-based footnote numbering like LaTeX's \fnsymbol
  set footnote(numbering: fnsymbol)

  set footnote.entry(
    separator: line(length: 30%, stroke: 0.8pt),
    indent: 0.7em,
  )

  // ===========================================================================
  // Equations
  // ===========================================================================

  set math.equation(numbering: "(1)")

  // Equation references: "Equation (1)" / "Équation (1)" instead of "Equation 1"
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      let supplement = if lang == "fr" { "Équation" } else { "Equation" }
      let num = numbering(el.numbering, ..counter(math.equation).at(el.location()))
      link(el.location(), [#supplement #num])
    } else {
      it
    }
  }

  // ===========================================================================
  // Lists and Enum
  // ===========================================================================

  set enum(numbering: "1.a)")
  set list(indent: 1em)
  set enum(indent: 1em)
  show list: set block(spacing: 1em)
  show enum: set block(spacing: 1em)

  // ===========================================================================
  // Front Matter (Title Block)
  // ===========================================================================

  // Title: Sans-serif, 22pt, italic
  {
    set text(font: heading-font, size: 22pt, style: "italic")
    set par(first-line-indent: 0pt)
    title
  }

  v(fm.after-title)

  // Authors with affiliation marks: 14pt
  {
    set text(size: 14pt)
    set par(first-line-indent: 0pt)
    process-authors(authors, affiliations, lang: lang)
  }

  v(fm.after-authors)

  // Affiliations: 9pt, italic
  {
    set text(size: 9pt, style: "italic")
    set par(first-line-indent: 0pt)
    format-affiliations(affiliations)
  }

  v(fm.after-affiliations)

  // Horizontal rule
  line(length: 100%, stroke: 1pt)

  v(fm.after-rule-top)

  // Abstract: 9pt
  if abstract != none {
    set text(size: 9pt)
    set par(first-line-indent: 10pt)
    abstract
  }

  v(fm.after-abstract)

  // Keywords: 9pt with bold label
  if keywords.len() > 0 {
    set text(size: 9pt)
    set par(first-line-indent: 0pt)
    [*#keywords-label* #keywords.join(", ")]
  }

  v(fm.after-keywords)

  // Horizontal rule
  line(length: 100%, stroke: 1pt)

  v(fm.after-rule-bottom)

  // ===========================================================================
  // Set Language State (for theorem environments)
  // ===========================================================================

  algotel-lang.update(lang)
  show: (content) => {
    if lang == "fr" {
      theorem-fra-env.at("rules")(content)
    } else {
      theorem-eng-env.at("rules")(content)
    }
  }

  // ===========================================================================
  // Main Body
  // ===========================================================================

  body
}


// =============================================================================
// Convenience Functions
// =============================================================================

// QED symbol for proofs
#let qed = h(1fr) + $square$

