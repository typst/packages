#import "elements.typ" as elems

#import "partial/affidavit.typ" as affidavit
#import "partial/title.typ" as title-page
#import "partial/glossar.typ" as glossar

#import "languages.typ": get-text

#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": codly-languages
#import "@preview/glossarium:0.5.10": make-glossary

#let whs-thesis(
  // metadata
  title: "",
  title-size: 16pt,
  thesis-type: "Bachelorarbeit",
  author: "",
  first-name: "",
  last-name: "",
  date: datetime.today(),
  date-of-submission: "",
  place-location: "",
  place-birth: "",
  keywords: (),
  degree: "",
  study-course: "",
  department: "",
  first-examiner: "",
  second-examiner: "",
  signature: none,
  // content
  abstract: none,
  appendix: none,
  bibliography: none,
  acronyms: none,
  // settings
  language: "de",
  citation-style: "ieee",
  background: "default",
  font: "TeX Gyre Heros",
  math-font: "New Computer Modern Math",
  raw-font: "Fira Code",
  body,
) = {
  // ========== global definitions ============

  set document(title: title, author: author, date: date, keywords: keywords)


  set text(ligatures: false)

  set page("a4")

  set page(
    margin: (
      bottom: 2cm,
    ),
  )

  set cite(style: citation-style)

  // ========== Plugins ============

  show: make-glossary

  show: codly.lang-set_(languages: codly-languages, display-icon: false)
  show: codly.line-set_(fill: none)
  show raw.where(block: true): codly.new

  // ------ text, paragraph and block ------

  set text(
    12pt,
    font: font,
    lang: language,
  )
  show raw: set text(font: raw-font)
  show math.equation: set text(font: math-font)
  set par(leading: 0.7em, justify: true, spacing: 1.5em)
  set block(below: 1.7em)

  // ----------- headings ----------

  // heading settings
  show heading.where(level: 1): set text(size: 16pt)
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 3): set text(size: 12pt)

  // numbering
  show heading: it => {
    let elems = ()
    if (
      it.numbering != none
        and it.body != [#get-text("table-of-contents", language)]
    ) {
      elems.push(counter(heading).display())
    }
    elems.push(it.body)
    grid(
      columns: 2,
      column-gutter: 4mm,
      ..elems
    )
  }

  show heading: set block(below: 0pt)

  // spacing
  show heading: it => {
    if it.level == 1 {
      it
      v(8mm, weak: true)
      // pad(bottom: 8mm, it)
    } else if it.level == 2 {
      v(3mm)
      it
      v(6mm, weak: true)
    } else {
      pad(top: 0mm, bottom: 4mm, it)
    }
  }

  // -------- figures --------

  set figure(gap: 3.5mm)
  show figure: set block(below: 8mm)

  // --------- outline and bibliography -------

  // add outlines to table of contents, except for itself
  show outline.where(title: [#get-text("table-of-contents", language)]): it => {
    set heading(outlined: false)
    it
  }
  show outline: set heading(outlined: true)
  show outline: set heading(numbering: "1")

  // ------- Common Elements -------------

  //show link: underline

  set list(
    indent: 6mm,
    marker: (
      [$circle.filled.small$],
      [$circle.stroked.small$],
      [$square.filled.tiny$],
    ),
    body-indent: 3mm,
  )
  set enum(
    indent: 6mm,
    numbering: "1.a.i.",
    body-indent: 3mm,
  )

  // =============== Content ==============

  // -------- Predefined pages -------

  let background = if type(background) == str {
    if background == "gray" {
      image("partial/images/background-gray.jpg")
    } else {
      image("partial/images/background.jpg")
    }
  } else {
    background
  }

  title-page.title(
    background,
    thesis-type,
    title,
    degree,
    author,
    place-birth,
    study-course,
    department,
    first-examiner,
    second-examiner,
    date-of-submission,
    title-size,
    language: language,
  )
  affidavit.affidavit(
    background,
    last-name,
    first-name,
    title,
    place-location,
    date,
    title-size,
    signature,
    language: language,
  )
  if (abstract != none) {
    pagebreak()
    abstract
  }
  pagebreak()

  // set correct header margin
  set page(
    margin: (
      top: 3cm,
    ),
  )
  // set common header and footer
  set page(numbering: "I")
  counter(page).update(1)

  set page(
    header: elems.common_header(title),
    footer: none,
  )

  set par(leading: 1em)
  heading(outlined: false, numbering: none)[#get-text(
      "table-of-contents",
      language,
    )]
  show outline.entry: it => link(
    it.element.location(),
    [#it.indented(it.prefix(), it.inner()) #v(12pt, weak: true)],
  )
  set outline.entry(fill: repeat[.])
  show outline.entry.where(level: 1): it => {
    v(18pt, weak: true)
    if it.at("label", default: none) == <modified-entry> {
      // prevent infinite recursion
      if it.element.supplement.text == get-text("section", language) {
        strong(it)
      } else {
        it
      }
    } else {
      if it.element.supplement.text == get-text("section", language) {
        [#outline.entry(
            it.level,
            it.element,
            fill: "",
          ) <modified-entry>]
      } else {
        [#outline.entry(
            it.level,
            it.element,
            fill: "",
          ) <modified-entry>]
      }
    }
  }
  outline(
    title: none,
    indent: 2em,
  )
  set par(leading: 0.65em) // Reset par leading
  pagebreak()

  if (acronyms != none) {
    glossar.glossar(acronyms, language: language)
    pagebreak()
  }

  // Reset outline entries
  show outline.entry: it => link(
    it.element.location(),
    it.indented(it.prefix(), it.inner()),
  )
  set outline.entry(fill: repeat[.])

  [= #get-text("list-of-figures", language)]
  outline(
    title: none,
    target: figure.where(kind: image),
  )

  [= #get-text("list-of-tables", language)]
  outline(
    title: none,
    target: figure.where(kind: table),
  )

  [= #get-text("list-of-code", language)]
  outline(
    title: none,
    target: figure.where(kind: "code"),
  )

  // -------------------------------

  // Set page numbering
  set page(numbering: "1")
  counter(page).update(1)

  set page(
    header: elems.common_header(title),
    footer: none,
    margin: (
      top: 3cm,
    ),
  )

  // Set chapter numbering
  set heading(numbering: "1.1")
  counter(heading).update(0)


  // add pagebreak before each level 1 heading (except for first heading after outline)
  show heading.where(level: 1): it => {
    if counter(heading).at(it.location()).first() != 1 {
      pagebreak()
    }
    it
  }

  // start of actual writing
  body


  // -------- Predefined pages --------

  set page(numbering: "I", number-align: right)
  counter(page).update(1)
  set page(
    header: elems.common_header(title),
    footer: none,
    margin: (
      top: 3cm,
    ),
  )
  set heading(numbering: none)

  // Literaturverzeichnis
  if (bibliography != none) {
    [= #get-text("bibliography", language)]
    bibliography(
      title: none,
      style: citation-style,
    )
  }

  if (appendix != none) {
    [#appendix]
  }
}
