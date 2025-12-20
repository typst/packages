#import "@preview/exzellenz-tum-thesis:0.2.0": exzellenz-tum-thesis

#import "utils.typ": inwriting, draft, todo
#import "glossary.typ": glossary
#import "@preview/glossarium:0.5.9": make-glossary, register-glossary, print-glossary, gls, glspl


/** Introduction

  The philosophy of this template is that the template file itself only contains the template of the first pages of the thesis, that are the same for all thesis.

  The formatting for the main part of the thesis is done here in the main.typ file. This looks less clean in the first place but has the advantage that you can easily change the formatting of the thesis, without the need to change the unreachable template file.

**/

/** Drafting

  Set inwriting and draft inside utils.typ.
  
  The "draft" variable is used to show DRAFT in the header and the title. This should be true until the final version is handed-in.
  
  The "inwriting" is used to change the appearance of the document for easier writing. Set to true for yourself but false for handing in a draft or so.

**/


// Global Settings //
#set text(lang: "en", size: 12pt)
#set text(ligatures: false)
#set text(font: "New Computer Modern Sans")

#show: exzellenz-tum-thesis.with(
  degree: "Master",
  program: "Informatics",
  school: "School of Computation, Information and Technology",
  examiner: "Prof. Dr. Albert Einstein",
  supervisors: ("Claude Elwood Shannon", "Kurt Gödel",), // A list of your supervisors. If you have just one, keep it as ("Name",) The template will automatically make it singular
  author: "Max Mustermann",
  titleEn: "This is the Title of the Thesis",
  titleDe: "Das ist der Titel der Arbeit",
  abstractText: [
    #lorem(60)
  ],
  acknowledgements: [
    These are the acknowledgements. Remove this argument if you don't need them.
    
    Alternatively, you can list people, institutions or other entities that contributed to the successful completion of this thesis.
  ],
  submissionDate: datetime.today().display("[day].[month].[year]"),
  showTitleInHeader: true,
  draft: draft, // Do not change this here, rather change it in utils.typ
)

// Settings for Body //
// Set fonts
#set text(font: "New Computer Modern")
#show raw: set text(font: "New Computer Modern Mono")
#show math.equation: set text(font: "New Computer Modern Math")

// Set font size
#show heading.where(level: 3): set text(size: 1.05em)
#show heading.where(level: 4): set text(size: 1.0em)
#show figure: set text(size: 0.9em)

// Set spacing
#set par(leading: 0.9em, first-line-indent: 1.8em, justify: true, spacing: 1em)
#set table(inset: 6.5pt)
#show table: set par(justify: false)
#show figure: it => [#v(1em) #it #v(1em)]

#show heading.where(level: 1): set block(above: 1.95em, below: 1em)
#show heading.where(level: 2): set block(above: 1.85em, below: 1em)
#show heading.where(level: 3): set block(above: 1.75em, below: 1em)
#show heading.where(level: 4): set block(above: 1.55em, below: 1em)

// Pagebreak after level 1 headings
#show heading.where(level: 1): it => [
  #pagebreak(weak: true)
  #it
]

// Names for headings
#set heading(supplement: it => {
  if (it.has("depth")) {
    if it.depth == 1 [Chapter]
    else if it.depth == 2 [Section]
    else [Subsection]
  } else {
    [ERROR, this should not happen]
  }
})

// Set citation style
#set cite(style: "ieee")

// Table stroke
#set table(stroke: 0.5pt + black)

// show reference targets in brackets
#show ref: it => {
  let el = it.element
  if el != none and el.func() == heading {

    [#it (#el.body)]
  } else [#it]
}

// color links and references
#show ref: set text(fill: color.olive)
#show link: set text(fill: blue)

// style table-of-contents
#show outline.entry.where(
  level: 1
): it => {
  v(1em, weak: true)
  strong(it)
}

// Draft Settings //
#show cite: set text(fill: blue) if inwriting
#show footnote: set text(fill: purple) if inwriting
#set cite(style: "chicago-author-date") if inwriting

// Make and register Glossary //
#show: make-glossary
#register-glossary(glossary)

// ------ Content ------

// Table of contents.
#outline(
  title: {
    text(1.3em, weight: 700, "Contents")
    v(10mm)
  },
  indent: 2em,
  depth: 3
)
#pagebreak(weak: false)

// Set numbering mode (and restart for main content)
#set page(numbering: "1")
#counter(page).update(1)
#set math.equation(numbering: "(1)")
#set heading(numbering: "1.1")
// --- Main Chapters ---

#include "Chapter_Introduction.typ"

//#include "Chapter_Background.typ"

//#include "Chapter_RelatedWork.typ"

//#include "Chapter_Methodology.typ"

//#include "Chapter_Experiments.typ"

//#include "Chapter_Discussion.typ"

//#include "Chapter_FutureResearch.typ"


// --- Appendices ---

// restart page numbering using roman numbers
#set page(numbering: "i")
#counter(page).update(1)


#include("Chapter_Appendix.typ")

// List of Acronyms.
#heading(numbering: none)[Glossary]
#print-glossary(glossary)

// List of figures.
#heading(numbering: none)[List of Figures]
#outline(
  title: none,
  target: figure.where(kind: image),
)

// List of tables.
#heading(numbering: none)[List of Tables]
#outline(
  title: none,
  target: figure.where(kind: table)
)  

// --- Bibliography ---

#set par(leading: 0.7em, first-line-indent: 0em, justify: true)
#bibliography("items.bib", style: "apa")