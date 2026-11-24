#import "@preview/numbly:0.1.0": numbly
#import "@preview/abbr:0.3.1"

#let text-size = 12pt
#let heading-1 = 20pt
#let heading-2 = 16pt
#let heading-3 = 14pt
#let first-line-indent = 1.5em
#let font-state = state("font", "Libertinus Serif")
#let font-cover-title = "Libertinus Serif"
#let doc-lang = state("doc-lang", "sk")
#let default-variables = (
  title: [Rozšírená šablóna záverečnej práce na FEI STU v Bratislave v systéme Typst],
  author: "RNDr. Juraj Chlpík, PhD.",
  reg-nr: [FEI-xxxx-xxxx],
  date: [31. decembra 2024],
  year: [2024],
  thesis-type: [Bakalárska práca],
  study-programme: [názov študijného programu],
  study-field: [názov študijného odboru],
  school: [Slovenská technická univerzita v Bratislave],
  faculty: [Fakulta elektrotechniky a informatiky],
  supervisor: [tituly Meno Priezvisko, tituly],
  consultant: [tituly Meno Priezvisko, tituly],
  training-workplace: [Názov školiaceho pracoviska],
)
#let variables-state = state("variables", default-variables)
#let i18n = (
  sk: (
    introduction: [Úvod],
    abstract: [Abstrakt],
    appendix-prefix: [Dodatok],
    glossary-title: [Zoznam značiek a skratiek],
    bibliography: [Literatúra],
    outline-code: [Zoznam výpisov kódov],
    outline-figures-tables: [Zoznam obrázkov a tabuliek],
    code-caption: [Výpis kódu],
    conclusion: [Záver],
    ai-declaration: [Použitie nástrojov umelej inteligencie],
    thanks: [Poďakovanie],
    reg-nr-label: [Evidenčné číslo:],
    study-programme-label: [Študijný program:],
    study-field-label: [Študijný odbor:],
    training-workplace-label: [Školiace pracovisko:],
    supervisor-label: [Školiteľ:],
    consultant-label: [Konzultant:],
    keywords: [Kľúčové slová],
    resume: [Rezumé],
    outline-algorithms: [Zoznam algoritmov],
  ),
  en: (
    introduction: [Introduction],
    abstract: [Abstract],
    appendix-prefix: [Appendix],
    glossary-title: [List of Symbols and Abbreviations],
    bibliography: [Bibliography],
    outline-code: [List of listings],
    outline-figures-tables: [List of figures and tables],
    code-caption: [Listing],
    conclusion: [Conclusion],
    ai-declaration: [Usage of artificial intelligence tools],
    thanks: [Thanks],
    reg-nr-label: [Registration number:],
    study-programme-label: [Study Programme:],
    study-field-label: [Study Field:],
    training-workplace-label: [Training Workplace:],
    supervisor-label: [Supervisor:],
    consultant-label: [Consultant:],
    keywords: [Keywords],
    resume: [Résumé],
    outline-algorithms: [List of Algorithms],
  ),
)

#let translate(key, lang: none) = context i18n.at(if lang != none { lang } else { doc-lang.get() }).at(key)

#let fei-thesis(
  language: "sk",
  font: "Libertinus Serif",
  font-math: "Libertinus Math",
  bibliography-style: "iso-690-numeric",
  body,
) = {
  doc-lang.update(language)
  font-state.update(font)
  // Page setup
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 3cm, left: 2.75cm, right: 2.75cm),
    numbering: none,
  )

  set par(leading: 10.5pt, first-line-indent: (amount: first-line-indent, all: false), justify: true, spacing: 1em)

  set text(size: text-size, font: font, lang: language)
  set bibliography(style: bibliography-style, title: [#translate("bibliography")])
  // https://github.com/typst/typst/issues/1975#issuecomment-5004304475
  // Support for formatting within bibliography entries inside *.bib files
  // show bibliography: body => {
  //   show "~": [~]
  //   body
  // }

  set pagebreak(weak: true)

  set table(inset: (x: 0.5em, y: 0.5em))

  show figure.caption: it => block({
    set align(left)
    strong({
      it.supplement
      [ ]
      context it.counter.display(it.numbering)
      it.separator
    })
    [ ]
    it.body
  })

  show heading: set block(below: 1em)

  show heading: it => [
    #if it.level == 1 {
      //Zabezpečí vytlačenie čakajúcich plávajúcich objektov na konci kapitoly
      place.flush()
      pagebreak(weak: true)
    }
    #block(
      if it.numbering != none { counter(heading).display(it.numbering) + h(1.2em) } + it.body,
    )]

  show heading.where(level: 2): set text(size: heading-2)
  show heading.where(level: 3): set text(size: heading-3)
  show heading.where(level: 4): set heading(outlined: false, numbering: none)
  show heading.where(level: 5): set heading(outlined: false, numbering: none)
  show heading.where(level: 6): set heading(outlined: false, numbering: none)

  set figure(numbering: "1")
  set heading(numbering: "1.1")

  set quote(block: true)

  //quote sú defaultne nerovnako odsadené zhora a zdola
  show quote.where(block: true): set block(
    above: 1.5em,
    below: 1.5em,
  )

  //odsadenie citátu sprava a zľava podobne ako v LaTeXu
  show quote.where(block: true): set pad(
    x: 1.75 * first-line-indent,
  )

  //Zabráni ďalšiemu odsadeniu zoznamov v citátoch
  show quote.where(block: true): set enum(indent: 0pt)
  show quote.where(block: true): set list(indent: 0pt)

  set enum(
    full: true,
    numbering: numbly("{1:1}.", "{2:a)}", "{3:i})", "({4})"),
    spacing: 1.1em,
    indent: 1em,
  )

  set list(
    spacing: 1.1em,
    indent: 1em,
  )

  //Správanie číslovaných zoznamov v položkách s viacerými odsekmi
  show enum: it => context {
    set par(
      first-line-indent: 0pt,
      spacing: par.spacing + 0.25em,
    )
    it
  }

  //Správanie nečíslovaných zoznamov v položkách s viacerými odsekmi
  show list: it => context {
    set par(
      first-line-indent: 0pt,
      spacing: par.spacing + 0.25em,
    )
    it
  }

  show math.equation: set text(font: font-math)
  set math.equation(supplement: none, numbering: "1")
  set ref(supplement: none)

  set cite(style: "springer-lecture-notes-in-computer-science")

  set math.equation(numbering: "(1)")

  show figure.where(
    kind: table,
  ): set figure.caption(position: top)

  set figure(gap: 1.5em)
  show figure: set block(spacing: 2em)
  show figure: set place(clearance: 2em)

  show figure.where(kind: raw): set figure(supplement: [#translate("code-caption")])

  //Väčšie medzery pred a po výpise kódu
  show raw.where(block: true): it => {
    context {
      let line-height = measure(text(font: font-state.get(), size: text-size)[H]).height
      set block(
        above: 2 * line-height,
        below: 2 * line-height,
      )
      it
    }
  }

  show figure.where(kind: raw): set block(breakable: true)
  show figure.where(kind: raw): set block(width: 100%)
  show figure.where(kind: raw): set align(start)

  show figure.caption.where(kind: raw): set block(width: auto)
  show figure.caption.where(kind: raw): set align(center)
  //------------------------------

  show: abbr.show-rule

  body
}


#let fei-cover-page() = {
  set text(font: font-cover-title)
  set page(
    margin: (top: 2.1cm, bottom: 2.3cm, left: 2.75cm, right: 2.75cm),
    numbering: none,
  )

  context {
    let vars = variables-state.get()
    let t = vars.at("title")
    let a = vars.at("author")
    let s = vars.at("school")
    let f = vars.at("faculty")
    let y = vars.at("year")
    let tt = vars.at("thesis-type")
    let rn = vars.at("reg-nr")

    align(center)[
      #text(size: 14.5pt, weight: "bold")[#upper(s)] \
      #v(8pt)
      #text(size: 13.5pt, weight: "bold")[#f]
    ]

    v(12.5mm)
    par(first-line-indent: 0pt)[
      #text(size: 12.0pt)[#translate("reg-nr-label") #rn]
    ]

    v(51.5mm)

    align(center)[
      #box(width: 100%, text(size: 20.5pt, weight: "bold")[#t])
      #v(20pt)
      #text(size: 14.5pt, weight: "bold")[#tt]
    ]

    v(1fr)

    grid(
      columns: (1fr, 1fr),
      text(size: 14.5pt, weight: "bold")[#y], align(right, text(size: 14.5pt, weight: "bold")[#a]),
    )

    pagebreak()
  }
}

#let fei-title-page() = {
  set text(font: font-cover-title)
  set page(
    margin: (top: 3.124cm, bottom: 3.3cm, left: 2.75cm, right: 2.75cm),
    numbering: none,
  )
  counter(page).update(1)

  context {
    let vars = variables-state.get()
    let t = vars.at("title")
    let a = vars.at("author")
    let s = vars.at("school")
    let f = vars.at("faculty")
    let y = vars.at("year")
    let tt = vars.at("thesis-type")
    let rn = vars.at("reg-nr")
    let sp = vars.at("study-programme")
    let sf = vars.at("study-field")
    let sv = vars.at("supervisor")
    let c = vars.at("consultant")
    let tw = vars.at("training-workplace")

    align(center)[
      // #par(leading: 18.2pt)[
      #text(size: 14pt, weight: "bold")[#upper(s)]
      #v(4pt)
      #text(size: 13.5pt, weight: "bold")[#f]
      // ]
    ]

    v(13mm)

    par(first-line-indent: 0pt)[
      #text(size: 12.0pt)[#translate("reg-nr-label") #rn]
    ]

    v(42.9mm)

    align(center)[
      #par(leading: 9pt)[#text(size: 20pt, weight: "bold")[#t]]
      #v(20pt)
      #text(size: 14pt, weight: "bold")[#tt]
    ]

    v(4.1cm)

    grid(
      columns: (5cm, 1fr),
      gutter: 0.1em,
      row-gutter: 0.8em,
      [#translate("study-programme-label")], [#sp],
      [#translate("study-field-label")], [#sf],
      [#translate("training-workplace-label")], [#tw],
      if sv != none [#translate("supervisor-label")], if sv != none [#sv],
      if c != none [#translate("consultant-label")], if c != none [#c],
    )

    v(1fr)

    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      text(size: 12pt, weight: "bold")[#y], text(size: 12pt, weight: "bold")[#a],
    )

    pagebreak()
  }
}

/// Sets the thesis variables and the PDF metadata. Use it as a show rule so the
/// document set rule applies to the whole document:
/// `#show: set-variables.with((title: "...", author: "..."))`
/// Keys that are left out fall back to `default-variables`.
#let fei-setup(vars, body) = {
  let vars = default-variables + vars
  variables-state.update(vars)

  set document(
    title: vars.at("title"),
    author: vars.at("author"),
  )

  body
}

#let fei-list-of-glossaries(content) = {
  set heading(outlined: false, numbering: none)
  content
  abbr.list(title: [#translate("glossary-title")], columns: 1)
}

#let fei-list-of-manual-glossaries(content) = {
  heading(outlined: false, numbering: none)[#translate("glossary-title")]
  content
}


#let fei-assignment(pdf-path, pages: 1) = {
  set page(
    margin: (top: 0cm, bottom: 0cm, left: 0cm, right: 0cm),
  )
  for page-num in range(1, pages + 1) {
    image(pdf-path, width: 100%, page: page-num)
  }
}

#let fei-outline() = {
  set par(first-line-indent: (amount: first-line-indent, all: true))

  show outline.entry.where(
    level: 1,
  ): it => [
    #v(0.5em)
    #set par(first-line-indent: (amount: 0em, all: true))
    #link(
      it.element.location(),
      [#strong([#it.prefix() #if it.prefix() != none { h(1em) } #it.body() #box(width: 1fr, repeat(
          gap: 0.15em,
        )[ ]) #it.page() #v(0.1em) ])],
    )]

  // this prevents the place.flush()
  show heading.where(level: 2): set text(size: heading-1)
  show outline: set heading(level: 2)
  outline()
}

#let fei-outline-code() = {
  outline(
    title: [#translate("outline-code")],
    target: figure.where(kind: raw),
  )
}

#let fei-outline-algorithms() = {
  outline(
    title: [#translate("outline-algorithms")],
    target: figure.where(kind: "algorithm"),
  )
}

#let fei-outline-figures-tables() = {
  outline(
    title: [#translate("outline-figures-tables")],
    target: figure.where(kind: image),
  )
  [
    #v(1em)
  ]
  outline(
    title: none,
    target: figure.where(kind: table),
  )
}

/// This function constructs the abstract, which is supposed to come directly after the frontmatter.
#let fei-abstract(
  content,
  /// -> "en" | "sk"
  lang: "sk",
  keywords,
) = {
  heading(numbering: none, outlined: false)[#translate("abstract", lang: lang)]
  v(20pt)

  content

  v(1em)

  heading(numbering: none, outlined: false, level: 4)[#translate("keywords", lang: lang)]

  v(0.7em)

  keywords
}

#let fei-resume(
  content,
  /// -> "en" | "sk"
  lang: "sk",
) = {
  heading(numbering: none, outlined: false)[#translate("resume", lang: lang)]

  content
}

#let fei-introduction(content) = {
  heading(numbering: none)[#translate("introduction")]
  content
}

#let fei-core(content) = {
  content
}

#let fei-conclusion(content) = {
  heading([#translate("conclusion")], numbering: none)
  content
}

#let fei-ai-declaration(content) = {
  heading([#translate("ai-declaration")], numbering: none, level: 2)
  content
}

#let fei-thanks(body) = {
  [
    #v(1fr)
    #heading(level: 2, outlined: false, numbering: none)[#translate("thanks")]
    #body
  ]
}

#let start-numbering(body) = {
  set page(numbering: "1")
  body
}

#let fei-appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(context [#translate("appendix-prefix")
      #counter(heading).display("A"): #it.body])
  }
  body
}


#let noindent(body) = {
  set par(first-line-indent: 0pt)
  body
}

#let indent(body) = {
  set par(first-line-indent: (amount: first-line-indent, all: true))
  body
}
