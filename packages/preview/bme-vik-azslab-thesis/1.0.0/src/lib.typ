#import "aref.typ": _make-aref
#import "internal.typ": _front-back-heading, _main-heading, _make-equation, _make-figure-numbering, _reset-counters
#import "@preview/theorion:0.6.0": *

#let doc-lang = state("lang", "hu")
#let doc-part = state("part", "main")

/// Configures and renders a BME VIK thesis document.
///
/// Sets up document metadata, typography, page layout, localized headings,
/// figures, tables, listings, equations, references, theorem environments,
/// front matter, and the table of contents.
///
/// - `authors`: Author name or array of author names.
/// - `department`: Name of the department.
/// - `font-size`: Base font size of the document.
/// - `industrial-advisors`: Industrial advisors name or array of names.
/// - `lang`: Document language. Supported values are `"hu"` and `"en"`.
/// - `leading`: Line-spacing mode. Supported values are `"simple"`,
///   `"normal"`, and `"double"`.
/// - `physical`: Whether the document is intended for physical output.
/// - `supervising-type`: Label used for supervisors, such as `"advisor"`
///   or `"supervisor"`.
/// - `supervisors`: Supervisor name or array of supervisor names.
/// - `thesis-type`: Type of thesis, such as `"bsc"`, `"msc"`, `"phd"`,
///   or `"tdk"`.
/// - `title`: Title of the thesis.
/// - `body`: Main document content.
#let thesis(
  authors: (),
  department: "Távközlési és Mesterséges Intelligencia Tanszék",
  font-size: 11pt,
  industrial-advisors: (),
  lang: none,
  leading: "normal",
  physical: false,
  supervising-type: "advisor",
  supervisors: (),
  thesis-type: "bsc",
  title: "",
  body
) = {
  import "declaration.typ": declaration
  import "internal.typ": *
  import "libs.typ": *
  import "titlepage.typ": titlepage

  // PREPROCESSING
  if lang == none {panic("Language is not set!")}
  doc-lang.update(lang)
  doc-part.update("main")

  let authors = _as-array(authors)
  let supervisors = _as-array(supervisors)
  let industrial-advisors = _as-array(industrial-advisors)

  let consts = _make-lang-consts(
  authors,
  industrial-advisors,
  supervisors,
  supervising-type,
)

let lang-consts = consts.at(lang)

  // DATE FORMAT
  let date = custom-date-format(datetime.today(), lang: lang, pattern: lang-consts.datify-display-format)

  // DOCUMENTS
  set page(
    margin: if physical {(top: 3.5cm, inside: 3.5cm, rest: 2.5cm)} else {(top: 3.5cm, left:3.5cm, rest: 2.5cm)},
    paper: "a4"
  )

  let leading-size = (
    simple: 0.5em,
    normal: 0.65em,
    double: 1em,
  ).at(leading)

  set par(
    justify: true,
    first-line-indent: if lang == "hu" {(amount: 2em, all: false)} else {0em},
    leading: leading-size,
    spacing: if lang == "hu" {leading-size} else {leading-size*2}
  )

  show heading: set par(
    first-line-indent: 0em,
    leading: 0.65em,
    spacing: 1.3em
  )

  set text(font-size, font: "New Computer Modern", lang: lang)

  set document(author: authors.join(", "), title: title)

  // TITLEPAGE
  set page(numbering: none)
  titlepage(
    authors,
    date,
    department,
    industrial-advisors,
    lang-consts,
    supervisors,
    thesis-type
  )

  if thesis-type in ("bsc", "msc")  {
    declaration(
      authors,
      date,
      lang,
      thesis-type
    )
  }

  // HEADINGS
  set heading(numbering: "1.1.1" + if lang == "hu" {"."} else {""})

  // FRONTMATTER HEADING
  set heading(supplement: [#lang-consts.chapter])
  show heading.where(level: 1): it => _front-back-heading(it)
  
  show heading.where(level: 2): it => block(
    above: 1.5em,
    below: 1em,
  )[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 0.25em,
      [#counter(heading).display()],
      [#it.body],
    )
  ]

  // LISTS AND ENUMS
  show list: set block(
    above: 1.3em,
    below: 1.3em
  )
  show enum: set block(
    above: 1.3em,
    below: 1.3em
  )

  set list(
    indent: 1.3em,
    spacing: 1.3em
  )

  set enum(
    indent: 1.3em,
    spacing: 1.3em
  )

  // FIGURES
  show figure: set block(
    above: 1.5em,
    below: 2em,
  )

  set figure(
    numbering: _make-figure-numbering(lang),
    gap: 1em,
    placement: auto
  )

  show figure.caption: _figure-caption.with(lang)
  show ref: _show-ref.with(doc-part, doc-lang)

  // IMAGES
  show figure.where(kind: image): set figure(
    supplement: if lang == "hu" {"ábra"} else {"Figure"}
  )

  // TABLES
  show figure.where(kind: table): set figure.caption(
    position: top,
    )

  show figure.where(kind: table): set figure(
    supplement: if lang == "hu" {"táblázat"} else {"Table"}
  )

  // LISTINGS
  show: codly-init.with()
  codly(languages: codly-languages)

  show figure.where(kind: raw): set figure(
    supplement: if lang == "hu" {"kódrészlet"} else {"Listing"},
    placement: none
  )
  show figure.where(kind: raw): set block(
    breakable: true,

  )

  // MATH
  set math.mat(delim: "[")
  show: super-T-as-transpose

  show heading.where(level: 2): it => {
    counter(math.equation).update(0)
    it
  }

  show math.equation: set block(
    above: 1.5em,
    below: 1.5em,
  )

  show: show-theorion

  set-inherited-levels(1)
  set-theorion-numbering(if lang == "hu" { "1.1." } else { "1.1" })

  // TABLE OF CONTENTS
  {
    show outline.entry.where(level: 1): it => {
      set block(above: 1.5em)
      set text(weight: "bold")
      it
    }
    show outline.entry.where(level: 1): set outline.entry(fill: none)
    outline()
  }

  // DOCUMENT
  body
}

/* -------------------------------------------------------------------------- */
/*                             DOCUMENT STRUCTURE                             */
/* -------------------------------------------------------------------------- */

/// Configures and renders the front matter.
///
/// Page numbering is reset and uses lowercase Roman numerals.
///
/// - `body`: Content of the front matter.
#let front-matter(body) = {
  pagebreak(weak: true)
  counter(page).update(1)
  set page(numbering: "i")
  body
}

/// Configures and renders the main matter.
///
/// Page numbering is reset and uses Arabic numerals. First-level headings
/// use the main-matter chapter style and reset chapter-local counters.
///
/// - `body`: Content of the main matter.
#let main-matter(body) = {
  pagebreak(weak: true)
  counter(page).update(1)
  set page(numbering: "1")
  show heading.where(level: 1): _main-heading.with(doc-lang)
  body
}

/// Configures and renders the back matter.
///
/// First-level headings use the unnumbered front/back-matter heading style.
/// Chapter-local counters are reset at each first-level heading.
///
/// - `body`: Content of the back matter.
#let back-matter(body) = {
  show heading.where(level: 1): it => {
    _reset-counters()
    _front-back-heading(it)
  }

  body
}

/// Configures and renders the appendix section of the document.
///
/// The appendix:
/// - switches the document part state to `"appendix"`,
/// - inherits two heading levels for theorem numbering,
/// - excludes figures from figure outlines,
/// - switches heading and theorem numbering to alphabetic appendix numbering,
/// - initializes the heading counter so Hungarian appendices start at `F`,
/// - renders an unnumbered appendix title,
/// - changes figure numbering to include both appendix and section numbers.
///
/// - `body`: Content of the appendix.
#let appendix(body) = {
  doc-part.update("appendix")

  // Theorem configuration.
  set-inherited-levels(2)

  // Appendix figures should not appear in figure/table outlines.
  set figure(outlined: false)

  context {
    let lang = doc-lang.get()
    let lang-hu = lang == "hu"

    let appendix-name = if lang-hu {
      "Függelék"
    } else {
      "Appendix"
    }

    // Hungarian appendix numbering starts at F, English at A.
    let counter-start = if lang-hu { 6 } else { 1 }

    let heading-numbering = "A.1.1" + if lang-hu { "." } else { "" }

    set heading(
      numbering: heading-numbering,
      supplement: none,
    )

    set-theorion-numbering(heading-numbering)

    counter(heading).update(counter-start)

    // Appendix title itself is intentionally unnumbered.
    heading(
      level: 1,
      numbering: none,
    )[#appendix-name]

    set figure(
      numbering: _make-figure-numbering(
        levels: 2,
        heading-pattern: "A.1",
        lang,
      ),
    )

    body
  }
}

/// Renders the list of figures.
///
/// Only figures whose kind is `image` are included. Each entry contains the
/// figure number, localized supplement, caption, and page number.
///
/// - `body`: Content rendered after the list of figures.
#let list-of-figures(body) = {
  _figure-outline(
    image,
    [Ábrajegyzék],
    [List of Figures],
    doc-lang
  )

  body
}

/// Renders the list of tables.
///
/// Only figures whose kind is `table` are included. Each entry contains the
/// table number, localized supplement, caption, and page number.
///
/// - `body`: Content rendered after the list of tables.
#let list-of-tables(body) = {
  _figure-outline(
    table,
    [Táblázatjegyzék],
    [List of Tables],
    doc-lang
  )

  body
}

// ---------------------------------------------------------------------------
// -----------------------------------MATH------------------------------------
// ---------------------------------------------------------------------------

/// Renders a numbered block equation using the thesis numbering scheme.
///
/// Equation numbering follows the current document language and document part.
///
/// - `body`: Mathematical content of the equation.
#let eq = _make-equation(doc-lang, doc-part)

/// Renders upright bold text in math mode.
///
/// This is a convenience wrapper around `math.bold` and `math.upright`,
/// intended for mathematical symbols that should be bold but not italic.
///
/// - `text`: Mathematical content to render in bold upright style.
#let mathbf(text) = math.bold(math.upright(text))


/* ---------------------------------- AREF ---------------------------------- */
/// Creates a reference prefixed with the appropriate lowercase Hungarian article.
///
/// Example: `#aref(<fig:example>)` -> `a 4.2.`
#let aref = _make-aref(doc-part)

/// Creates a reference prefixed with the appropriate capitalized Hungarian article.
///
/// Example: `#Aref(<fig:example>)` -> `A 4.2.`
#let Aref = _make-aref(
  capitalized: true,
  doc-part,
)

/* --------------------------- GEN-AI-DECLARATION --------------------------- */

/// Renders the declaration on the use of generative artificial intelligence.
///
/// The declaration indicates whether generative AI tools were used and
/// displays the corresponding statement using ballot symbols. The content
/// is automatically localized according to `doc-lang`.
///
/// - `was-used`: Whether generative AI tools were used.
/// - `body`: Additional declaration content, typically the detailed usage
///   table. It is rendered after the declaration statements.
#let genai-declaration(was-used, body) = context {
  let lang = doc-lang.get()

  let texts = (
    hu: (
      title: [Nyilatkozat generatív mesterséges intelligencia alkalmazásáról],
      not-used: [*Nem használtam* semmilyen generatív MI segédeszközt.],
      used: [
        *Használtam* generatív MI segédeszközt. Az MI-vel generált tartalmakat ellenőriztem, a generált kimenetek valóságtartalmáról meggyőződtem, az alábbi táblázatban megfelelően jelöltem minden használatot.
      ],
    ),
    en: (
      title: [Declaration on the Use of Generative Artificial Intelligence],
      not-used: [*I have not used any* generative AI tools.],
      used: [
        *I have used generative AI tools.* I have verified the content generated by AI, ensured the accuracy of the outputs, and properly indicated each instance of use in the table below.
      ],
    ),
  )

  let text = texts.at(lang)

  [
    == #text.title

    #if was-used { math.ballot } else { math.ballot.cross }
    #text.not-used \
    #if was-used { math.ballot.cross } else { math.ballot }
    #text.used
  ]

  body
}

/// Creates the prompt-summary row of the generative AI declaration table.
///
/// The first cell contains a localized label and the remaining three
/// columns contain the supplied prompt.
///
/// - `prompt`: Brief summary of the prompt. Defaults to `"-"`.
///
/// Returns an array of two table cells and is intended to be spread
/// into a `table` with `..gen-ai-prompt(...)`.
#let gen-ai-prompt(prompt: "-") = {
  (
    context {
      if doc-lang.get() == "hu" {
        [*Prompt lényegi része*]
      } else {
        [*Brief Summary of the Prompt*]
      }
    },
    table.cell(colspan: 3, prompt),
  )
}

/// Creates the aggregated percentage row of the generative AI declaration table.
///
/// The localized label spans the first three columns and the percentage
/// is displayed in the fourth column.
///
/// - `percentage`: Aggregated percentage of generative AI use.
///   If `none`, no percentage sign is displayed.
///
/// Returns an array of two table cells and is intended to be spread
/// into a `table` with `..gen-ai-all-percentage(...)`.
#let gen-ai-all-percentage(percentage: none) = {
  (
    table.cell(
      colspan: 3,
      context {
        if doc-lang.get() == "hu" {
          [*Összesített százalékos érték (a feladat érdemi részére nézve):*]
        } else {
          [*Aggregated Percentage Value (for the core part of the task):*]
        }
      },
    ),
    if percentage != none {[#percentage%]},
  )
}

/// Creates the textual justification row of the generative AI declaration table.
///
/// The cell spans all four columns and contains a localized label followed
/// by the supplied justification.
///
/// - `text`: Brief textual justification of the aggregated value.
///   Defaults to `none`.
///
/// Returns a table cell spanning all four columns.
#let gen-ai-all-text(text: none) = {
  table.cell(
    colspan: 4,
    context {
      if doc-lang.get() == "hu" {
        [*Összesített érték rövid, szöveges indoklása:* ]
      } else {
        [*Brief Textual Justification of the Aggregated Value:* ]
      }
      if text != none {[#text]}
    },
  )
}

/// Localized strings used by the generative AI declaration table.
#let gen-ai-names-all = (
  hu: (
    literature: "Irodalomkutatás",
    codegen: "Programkód generálása",
    ideas: "Új ötletek, megoldási javaslatok generálása",
    outline: "Vázlat létrehozása (szövegstruktúra, vázlatpontok)",
    textblocks: "Szövegblokkok létrehozása",
    figures: "Képek generálása illusztrációs célból",
    plots: "Adatvizualizáció, grafikonok generálása adatpontok alapján",
    presentation: "Prezentáció készítése",
    others: "Egyéb (nevezze meg)",
    titles: (
      types: [*Felhasználási módok*],
      names: [*Generatív MI eszköz(ök) neve*],
      sections: [*Érintett részek* (fejezet, oldalszám, aránya, hivatkozás)],
      usage: [*Használat becsült aránya* (felhasználási módonként)]
    )
  ),
  en: (
    literature: "Literature Review",
    codegen: "Program Code Generation",
    ideas: "Generating New Ideas or Solution Proposals",
    outline: "Creating an Outline (text structure, bullet points)",
    textblocks: "Creating Text Blocks",
    figures: "Generating Images for Illustrative Purposes",
    plots: "Data Visualization, Generating Charts Based on Data Points",
    presentation: "Preparing a Presentation",
    others: "Other (please specify)",
    titles: (
      types: [*Usage type*],
      names: [*Name of Generative AI Tool(s)*],
      sections: [*Affected Sections* (chapter, page, number, reference)],
      usage: [*Estimate Proportion of Use* (per usage type)]
    )
  )
)