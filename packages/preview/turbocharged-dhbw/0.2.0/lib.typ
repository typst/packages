#import "template-files/listings-lib.typ": code
#import "template-files/titlepage.typ": titlepage
#import "template-files/lists.typ": lists
#import "template-files/ai-tools.typ": ai-tools-table, ai-acknowledgement
#import "template-files/source.typ": source, in-outline
#let report(
  author: [author],
  module: none,
  title: [title],
  program: [program],
  submission-date: none,
  duration: none,
  student-id: none,
  course: none,
  company-name: none,
  city: none,
  company-supervisor: none,
  university-supervisor: none,
  document-type: [document-type],
  confidential: true,
  confidential-text: none,
  abstract-content: none,
  company-logo: none,
  acronyms: (),
  university-logo: none,
  university: none,
  show-declaration: true,
  // `auto` appends the AI sentence when `ai-tools` is set. `false` turns it off.
  show-ai-declaration: auto,
  declaration-text: none,
  declaration-title: none,
  bibliography-content: none,
  appendix-content: none,
  ai-tools: none,
  cover-page: none,
  lang: "de",
  body,
) = {
  import "@preview/acrostiche:0.7.0": *

  if acronyms.len() > 0 {
    init-acronyms(acronyms)
  }

  set page(
    paper: "a4",
    margin: (x: 3cm, top: 2.5cm, bottom: 2.5cm),
    header: none,
  )
  set text(
    font: "New Computer Modern",
    size: 12pt,
  )
  set par(
    justify: true,
    spacing: 1em,
    leading: 0.8em,
  )
  set text(lang: lang)

  // Gender-inclusive language: No line break at gender sign
  show ":innen": ":\u{2060}innen"
  show ":in": ":\u{2060}in"
  show "*innen": "*\u{2060}innen"
  show "*in": "*\u{2060}in"
  show "_innen": "_\u{2060}innen"
  show "_in": "_\u{2060}in"
  show "/-innen": "\u{2060}/-\u{2060}innen"
  show "/-in": "\u{2060}/-\u{2060}in"

  set math.equation(numbering: "(1)")
  set figure(numbering: "1")

  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  titlepage(
    title: title,
    document-type: document-type,
    program: program,
    module: module,
    university: university,
    author: author,
    submission-date: submission-date,
    duration: duration,
    student-id: student-id,
    course: course,
    company-name: company-name,
    city: city,
    company-supervisor: company-supervisor,
    university-supervisor: university-supervisor,
    company-logo: company-logo,
    university-logo: university-logo,
    cover-page: cover-page,
    lang: lang,
  )

  // Declaration
  import "template-files/declaration.typ": declaration

  let ai-tools-given = ai-tools != none and ai-tools.len() > 0
  let include-ai-declaration = if show-ai-declaration == auto {
    ai-tools-given
  } else {
    show-ai-declaration
  }

  declaration(
    author: author,
    company-city: city,
    confidential: confidential,
    confidential-text: confidential-text,
    declaration-text: declaration-text,
    declaration-title: declaration-title,
    show-declaration: show-declaration,
    show-ai-declaration: include-ai-declaration,
    lang: lang,
  )

  show figure.where(kind: table): set block(breakable: true)
  set table.cell(breakable: false)

  show table.cell.where(y: 0): strong

  show table: it => {
    // Prevent infinite recursion from the show rule below
    if type(it.stroke) == function {
      return it
    }

    table(
      columns: it.columns,
      align: (x, y) => if x > 0 { left } else { left },
      inset: 10pt,
      row-gutter: (4pt, auto),

      stroke: (x, y) => (
        left: none,
        right: none,

        top: if y == 0 { 0.7pt + black } else { none },
        bottom: if y == 0 { 0.7pt + black } else { none },
      ),

      ..it.children,
      table.hline(stroke: 0.7pt + black),
    )
  }

  lists(
    body,
    abstract-content: abstract-content,
    bibliography-content: bibliography-content,
    appendix-content: appendix-content,
    ai-tools: ai-tools,
    acronyms: acronyms,
    lang: lang,
  )
}

#let small-todo = (..args) => {
  import "@preview/dashy-todo:0.1.3": todo
  text(size: 0.8em)[#todo(..args)]
}
