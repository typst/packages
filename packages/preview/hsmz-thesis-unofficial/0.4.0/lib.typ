// External package imports
#import "@preview/acrostiche:0.7.0": acr, acrf, acrfpl, acrpl, init-acronyms, print-index // Acronyms - https://typst.app/universe/package/acrostiche/
#import "@preview/wordometer:0.1.6": word-count-of // Word count - https://typst.app/universe/package/wordometer/

// static pages, locale and helper functions
#import "static-pages.typ": declaration-of-originality, restriction-notice, title-page
#import "locale.typ": (
  ABSTRACT, APPENDIX, BIBLIOGRAPHY, DRAFT, FORMULA, LIST_OF_ABBREVIATIONS, LIST_OF_APPENDICES, LIST_OF_FIGURES,
  LIST_OF_FORMULAS, LIST_OF_SYMBOLS, LIST_OF_TABLES, MANAGEMENT_SUMMARY, NOTE, OPEN_TODOS, PAGE, WORDS_GUIDELINE,
  WORDS_OF_MAX, WORD_COUNT,
)
#import "check-attributes.typ": check-attributes
#import "utils.typ": format-number, word-guideline

// outlined outline for figures, tables, etc. that itself is outlined in the table of contents
#let outlined-outline(..args) = {
  show outline: set heading(outlined: true)
  outline(..args)
}

// note below a figure or table, e.g. for the source ("Anmerkung. Eigene Darstellung.")
// usage: #figure(table(...) + figure-note[Eigene Darstellung.], caption: [...])
#let figure-note(body) = context block(width: 100%, above: 0.65em, align(left, text(size: 0.9em)[
  #emph(NOTE.at(text.lang, default: NOTE.en)). #body
]))

// open item, e.g. #todo[Quelle ergänzen]. It is highlighted in the text, listed at the beginning of the document in
// draft mode and not included in the word count. Compilation fails if open items remain with `draft: false`.
#let todo(body) = [#highlight(fill: rgb("#ffe07a"), extent: 1pt)[*TODO:* #body] <no-wc>#metadata(body) <hsmz-todo>]

// page number of a location as it is printed on the page (e.g. "IV" or "12"), or the physical page number for pages
// without a page number
#let printed-page-number(loc) = {
  let page-numbering = loc.page-numbering()
  if page-numbering == none { str(loc.page()) } else { numbering(page-numbering, ..counter(page).at(loc)) }
}

// warning in draft mode, e.g. if a text is too long. Typst packages can't emit compiler warnings, so it is shown in the
// document instead.
#let draft-warning(body) = block(
  width: 100%,
  inset: 8pt,
  stroke: 1pt + red,
  radius: 2pt,
  text(fill: red, size: 10pt, body),
)

// main entrypoint for this template
#let hsmz-thesis-unofficial(
  // thesis data
  thesis-type: none,
  title: none,
  faculty: "Wirtschaft",
  degree-program: none,
  submission-date: none,
  confidentiality-period: none,
  ai-declaration-option: none,
  language: "de",
  acronyms: (:),
  symbols: (),
  bibliography: none,
  appendix: none,
  management-summary: [],
  abstract: [],
  // people
  author: (:),
  company: none,
  supervisor: none,
  // settings
  font: ("Arial", "Liberation Sans", "Arimo"),
  citation-style: "apa",
  print-only-used-acronyms: true,
  show-full-bibliography: false,
  show-restriction-notice: true,
  show-management-summary: false,
  show-abstract: true,
  show-word-count: true,
  draft: false,
  body,
) = {
  check-attributes(
    thesis-type: thesis-type,
    title: title,
    faculty: faculty,
    degree-program: degree-program,
    submission-date: submission-date,
    confidentiality-period: confidentiality-period,
    ai-declaration-option: ai-declaration-option,
    language: language,
    acronyms: acronyms,
    symbols: symbols,
    bibliography: bibliography,
    appendix: appendix,
    author: author,
    company: company,
    supervisor: supervisor,
    font: font,
    citation-style: citation-style,
    print-only-used-acronyms: print-only-used-acronyms,
    show-full-bibliography: show-full-bibliography,
    show-restriction-notice: show-restriction-notice,
    show-management-summary: show-management-summary,
    show-abstract: show-abstract,
    show-word-count: show-word-count,
    draft: draft,
  )

  // global page and text settings (Leitfaden, Section 2.4)
  set text(
    font: font,
    size: 11pt,
    lang: language,
  )
  set document(
    title: title,
    author: author.name,
    // PDF metadata: the submission date if it is given as a date, otherwise the time of compilation
    date: if type(submission-date) == datetime { submission-date } else { auto },
  )
  set page(
    paper: "a4",
    margin: (top: 2cm, bottom: 2cm, left: 4.5cm, right: 1.5cm),
    // watermark in draft mode
    background: if draft {
      rotate(-45deg, text(size: 90pt, weight: "bold", fill: luma(92%), DRAFT.at(language)))
    },
  )
  // Typst's `leading` is the gap between two lines, not the line pitch: with Arial, a leading of 1em results in a
  // baseline-to-baseline distance of ~1.7em, which matches 1.5 line spacing in word processors.
  set par(
    leading: 1em,
    spacing: 2em,
    justify: true,
  )

  // footnotes at the bottom of the page, justified with a hanging indent (Leitfaden, Section 2.4)
  show footnote.entry: it => {
    let loc = it.note.location()
    let number = numbering(it.note.numbering, ..counter(footnote).at(loc))
    grid(
      columns: (1.5em, 1fr),
      link(loc, super(number)), par(justify: true, it.note.body),
    )
  }

  // formulas are numbered on the right and listed in the list of formulas (Leitfaden, Section 2.3). To leave out a
  // single formula, use `#math.equation(block: true, numbering: none, $ ... $)`.
  set math.equation(numbering: "(1)", supplement: FORMULA.at(language))

  // draft mode: list of the open items in front of the document
  if draft {
    context {
      let todos = query(<hsmz-todo>)
      if todos.len() > 0 {
        text([#OPEN_TODOS.at(language) (#todos.len())], size: 18pt, weight: 600)
        v(1em)
        set par(justify: false)
        grid(
          columns: (auto, 1fr),
          column-gutter: 1.5em,
          row-gutter: 1em,
          ..todos
            .map(it => (
              link(it.location(), [#PAGE.at(language) #printed-page-number(it.location())]),
              it.value,
            ))
            .flatten(),
        )
        pagebreak()
      }
    }
  }

  // pre-text
  if show-restriction-notice {
    restriction-notice(title, company, confidentiality-period)
  }

  title-page(
    thesis-type,
    title,
    faculty,
    degree-program,
    submission-date,
    supervisor,
    author,
    language,
  )

  declaration-of-originality(
    ai-declaration-option,
    // no scanned signature on drafts
    if draft { author + (signature-image: none) } else { author },
    title,
    degree-program,
    supervisor,
    submission-date,
  )

  // Styling of individual elements
  // Margin for headings to make them more visually pleasing
  show heading.where(level: 1): set block(below: 1em)
  show heading.where(level: 2): set block(above: 1.5em, below: 1.5em)
  show heading.where(level: 3): set block(above: 1.5em, below: 1.5em)

  // Captions above figures and tables in APA style (Leitfaden, Section 3.10):
  // bold label ("Abbildung 1") followed by the title in italics on the next line
  set figure.caption(position: top)
  show figure.caption: it => block(width: 100%, align(left, [
    #text(weight: "bold")[#it.supplement #context it.counter.display(it.numbering)]\
    #emph(it.body)
  ]))

  // Management Summary (max. 500 words) and Abstract (max. 250 words), Leitfaden, Section 3.5
  let summary-page(title, content, max-words) = {
    heading(title, outlined: false, level: 1)
    content
    let count = word-count-of(content).words
    if draft and count > max-words {
      draft-warning((WORDS_OF_MAX.at(language))(format-number(count, language), format-number(max-words, language)))
    }
    pagebreak()
  }

  if show-management-summary {
    summary-page(MANAGEMENT_SUMMARY.at(language), management-summary, 500)
  }

  if show-abstract {
    summary-page(ABSTRACT.at(language), abstract, 250)
  }

  // reset heading and page numbers for listings
  counter(heading).update(0)
  counter(page).update(1)

  // adjust page numbering and headings for the listings
  set page(
    numbering: "I",
  )
  set heading(
    numbering: none,
  )

  show table: set par(
    leading: 0.8em,
    justify: true,
  )
  set table(stroke: 0.5pt, align: left)
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    fill: (_, y) => if y == 0 { rgb("#e7e6e6") },
  )

  // listings, each on a new page. The weak page breaks don't create empty pages for lists that are left out.
  outline()

  // the lists of figures and tables are only required if figures or tables are used (Leitfaden, Section 2.3)
  context if query(figure.where(kind: image)).len() > 0 {
    pagebreak(weak: true)
    outlined-outline(
      title: [#LIST_OF_FIGURES.at(language)],
      target: figure.where(kind: image),
    )
  }

  context if query(figure.where(kind: table)).len() > 0 {
    pagebreak(weak: true)
    outlined-outline(
      title: [#LIST_OF_TABLES.at(language)],
      target: figure.where(kind: table),
    )
  }

  // the list of abbreviations is only required if abbreviations are used (Leitfaden, Section 2.3)
  init-acronyms(
    acronyms,
  )
  if acronyms.len() > 0 {
    pagebreak(weak: true)
    print-index(
      title: [#LIST_OF_ABBREVIATIONS.at(language)],
      outlined: true,
      used-only: print-only-used-acronyms,
      sorted: "up",
      row-gutter: 10pt,
    )
  }

  // the list of symbols is only required if symbols are used (Leitfaden, Section 2.3)
  if symbols.len() > 0 {
    pagebreak(weak: true)
    heading(LIST_OF_SYMBOLS.at(language), level: 1, outlined: true)
    // same layout as the list of abbreviations (acrostiche: first column 20% of the width)
    grid(
      columns: (20%, 80%),
      row-gutter: 10pt,
      ..symbols.flatten(),
    )
  }

  // the list of formulas is only required if formulas are used (Leitfaden, Section 2.3); it lists every numbered
  // formula with its number, the formula itself and the page
  context if query(math.equation.where(block: true)).any(it => it.numbering != none) {
    pagebreak(weak: true)
    show outline.entry: it => {
      let formula = it.element
      if formula.numbering == none { return none }
      let number = numbering(formula.numbering, ..counter(math.equation).at(formula.location()))
      link(formula.location(), it.indented(number, [
        #math.equation(block: false, formula.body) #box(width: 1fr, it.fill) #it.page()
      ]))
    }
    outlined-outline(
      title: [#LIST_OF_FORMULAS.at(language)],
      target: math.equation.where(block: true),
    )
  }

  [#metadata(none) <hsmz-end-of-listings>] // last page of the listings, see below

  pagebreak()

  // reset counters and switch to numeric numbering for the content
  counter(heading).update(0)
  counter(page).update(1)
  set heading(
    numbering: "1.1",
  )
  set page(
    numbering: "1",
  )

  // content
  body

  // word count of the main text (Leitfaden, Section 2.3). Figures, tables and citations are not counted; any other
  // content can be excluded by attaching the label <no-wc> to it.
  if show-word-count {
    let count = word-count-of(body, exclude: (figure, table, <no-wc>)).words
    let guideline = word-guideline(thesis-type)
    block(above: 2em, [
      #WORD_COUNT.at(language): #format-number(count, language)
      // the guideline for final theses is only shown in draft mode
      #if draft and guideline != none [(#(WORDS_GUIDELINE.at(language))(format-number(guideline, language))) ]
    ])
  }

  // post-text

  // switch back to roman numbering, continuing after the listings
  set heading(
    numbering: none,
  )

  // (changing the page settings starts a new page)
  set page(
    numbering: "I",
  )
  // retrieve last page before the content started from labels using context
  context counter(page).update(counter(page).at(<hsmz-end-of-listings>).first() + 1)

  set std.bibliography(
    title: BIBLIOGRAPHY.at(language),
    style: citation-style,
    full: show-full-bibliography,
  )
  bibliography

  // If appendix is provided, show it here
  if appendix != none {
    pagebreak()

    let appendix-supplement = [#APPENDIX.at(language)]

    outlined-outline(
      title: [#LIST_OF_APPENDICES.at(language)],
      target: heading.where(supplement: appendix-supplement),
    )

    pagebreak()

    set heading(numbering: "A.1", supplement: appendix-supplement)
    counter(heading).update(0)

    appendix
  }

  // open items must be resolved before the final version is created
  if not draft {
    context {
      let todos = query(<hsmz-todo>)
      if todos.len() > 0 {
        let pages = todos.map(it => printed-page-number(it.location())).dedup().join(", ")
        panic(
          "hsmz-thesis-unofficial: "
            + str(todos.len())
            + " open todo(s) on page(s) "
            + pages
            + ". Resolve them, or set draft: true while you are still writing.",
        )
      }
    }
  }
}
