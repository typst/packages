#import "@preview/numbly:0.1.0": numbly
#import "@preview/abbr:0.3.1"

#let text-size = 12pt
#let heading-1 = 20pt
#let heading-2 = 16pt
#let heading-3 = 14pt
#let first-line-indent = 1.5em
#let font = "New Computer Modern"
#let doc-lang = state("doc-lang", "sk")
#let variables-state = state("variables", (
  title: "Rozšírená šablóna záverečnej práce na FEI STU v Bratislave v systéme Typst",
  author: "RNDr. Juraj Chlpík, PhD.",
  reg-nr: "FEI-xxxx-xxxx",
  date: "31. decembra 2024",
  year: "2024",
  thesis-type: "Bakalárska práca",
  keywords: "záverečná práca, šablóna, Typst, formátovanie textu, citácie",
  keywords-en: "Final thesis, template, Typst, text formatting, citations",
  study-programme: "názov študijného programu",
  study-field: "názov študijného odboru",
  school: "Slovenská technická univerzita v Bratislave",
  faculty: "Fakulta elektrotechniky a informatiky",
  supervisor: "tituly Meno Priezvisko, tituly",
  consultant: "tituly Meno Priezvisko, tituly",
  training-workplace: "Názov školiaceho pracoviska",
))
#let i18n = (
  sk: (
    introduction: "Úvod",
    abstract: "Abstrakt",
    appendix-suffix: "Dodatok",
    glossary-title: "Zoznam značiek a skratiek",
    bibliography: "Literatúra",
    outline-code: "Zoznam výpisov kódov",
    outline-table: "Zoznam výpisov tabuliek",
    outline-image: "Zoznam výpisov obrázkov",
    code-caption: "Výpis kódu",
    conclusion: "Záver",
    ai-declaration: "Použitie nástrojov umelej inteligencie",
    thanks: "Poďakovanie",
    reg-nr-label: "Evidenčné číslo:",
    study-programme-label: "Študijný program:",
    study-field-label: "Študijný odbor:",
    training-workplace-label: "Školiace pracovisko:",
    supervisor-label: "Školiteľ:",
    consultant-label: "Konzultant:",
  ),
  en: (
    introduction: "Introduction",
    abstract: "Abstract",
    appendix-suffix: "Appendix",
    glossary-title: "List of Symbols and Abbreviations",
    bibliography: "Bibliography",
    outline-code: "List of listings",
    outline-table: "List of tables",
    outline-image: "List of images",
    code-caption: "Listing",
    conclusion: "Conclusion",
    ai-declaration: "Usage of artificial intelligence tools",
    thanks: "Thanks",
    reg-nr-label: "Registration number:",
    study-programme-label: "Study Programme:",
    study-field-label: "Study Field:",
    training-workplace-label: "Training Workplace:",
    supervisor-label: "Supervisor:",
    consultant-label: "Consultant:",
  ),
)

#let translate(key, lang: none) = context i18n.at(if lang != none { lang } else { doc-lang.get() }).at(key)

#let fei-thesis(
  language: "sk",
  bibliography-style: "iso-690-numeric",
  body,
) = {
  doc-lang.update(language)
  // Page setup
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 3cm, left: 2.75cm, right: 2.75cm),
  )

  set par(leading: 10.5pt, first-line-indent: (amount: first-line-indent, all: false), justify: true, spacing: 1em)

  set text(size: text-size, font: font, lang: language)
  set bibliography(style: bibliography-style, title: [#translate("bibliography")])
  set pagebreak(weak: true)
  show heading: set block(below: 1em)

  show heading.where(level: 1): set text(size: heading-1)
  show heading.where(level: 2): set text(size: heading-2)
  show heading.where(level: 3): set text(size: heading-3)
  show heading.where(level: 4): set heading(outlined: false, numbering: none)
  show heading.where(level: 5): set heading(outlined: false, numbering: none)
  show heading.where(level: 6): set heading(outlined: false, numbering: none)

  set figure(numbering: "1")
  set heading(numbering: "1.1")
  show heading: it => block(
    if it.numbering != none { counter(heading).display(it.numbering) + h(1.2em) } + it.body,
  )

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

  set math.equation(supplement: none, numbering: "1")
  set ref(supplement: none)
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      [(#it)]
    } else {
      it
    }
  }

  set cite(style: "springer-lecture-notes-in-computer-science")

  set math.equation(numbering: "(1)")

  show figure.where(
    kind: table,
  ): set figure.caption(position: top)

  set figure(gap: 15pt)
  show figure: it => {
    set par(first-line-indent: (amount: first-line-indent, all: true))
    block(it, spacing: 2em)
  }

  show figure.where(kind: raw): set figure(supplement: [#translate("code-caption")])

  show figure.where(kind: raw): it => {
    align(left,  it.body)
    align(center, it.caption)
  }

  show: abbr.show-rule

  body
}

#let title-page() = {
  set page(
    margin: (top: 3.024cm, bottom: 2.775cm, left: 2.75cm, right: 2.75cm),
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
    let sp = vars.at("study-programme")
    let sf = vars.at("study-field")
    let sv = vars.at("supervisor")
    let c = vars.at("consultant")
    let tw = vars.at("training-workplace")

    align(center)[
      #par(leading: 18.2pt)[
        #text(size: 14pt, weight: "black")[#upper(s)]
        #linebreak()
        #text(size: 13.5pt, weight: "black")[#f]
      ]
    ]

    v(9mm)

    par(first-line-indent: 0pt)[
    #text(size: 12.0pt)[#translate("reg-nr-label") #rn]
    ]

    v(40.9mm)

    align(center)[
      #par(leading: 18.1pt)[#text(size: 20pt, weight: "black")[#t]]
      #v(22pt)
      #text(size: 14pt, weight: "black")[#tt]
    ]

    v(1fr)

    grid(
      columns: (5cm, 1fr),
      gutter: 0.5em,
      row-gutter: 0.8em,
      [#translate("study-programme-label")], [#sp],
      [#translate("study-field-label")], [#sf],
      [#translate("training-workplace-label")], [#tw],
      if sv != none [#translate("supervisor-label")], if sv != none [#sv],
      if c != none 
        [#translate("consultant-label")], if c != none [#c],
      
    )

    v(3.43cm)

    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      text(size: 12pt, weight: "black")[#y],
      text(size: 12pt, weight: "black")[#a],
    )

    pagebreak()
  }
}

#let cover-page() = {
  set page(
    margin: (top: 2cm, bottom: 1.8cm, left: 2.75cm, right: 2.75cm),
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
      #text(size: 14.0pt, weight: "black")[#upper(s)] \
      #v(3.5mm)
      #text(size: 13.5pt, weight: "black")[#f]
    ]

    v(9mm)
    par(first-line-indent: 0pt)[
    #text(size: 12.0pt)[#translate("reg-nr-label") #rn]
    ]

    v(51.5mm)

    align(center)[
      #box(width: 100%, text(size: 20.5pt, weight: "black")[#t])
      #v(29pt)
      #text(size: 14.5pt, weight: "black")[#tt]
    ]

    v(1fr)

    grid(
      columns: (1fr, 1fr),
      text(size: 14.5pt, weight: "black")[#y],
      align(right, text(size: 14.5pt, weight: "black")[#a]),
    )

    pagebreak()
  }
}

#let set-variables(vars) = {
  variables-state.update(vars)
}

#let fei-bibliography() = {
  [
    #bibliography("@template/bibliography.bib", style: "iso-690-numeric", title: [#translate("bibliography")])
  ]
}

#let fei-list-of-glossaries(content) = {
  set heading(outlined: false, numbering: none)
  content
  abbr.list(title: [#translate("glossary-title")], columns: 1)
  pagebreak()
}

#let fei-list-of-manual-glossaries(content) = {
  heading(outlined: false, numbering: none)[#translate("glossary-title")]
  // include "includes/manual_glossary.typ"
  content
  pagebreak()
}


#let fei-assignment(pdf-path, pages: 1) = {
  set page(
    margin: (top: 0cm, bottom: 0cm, left: 0cm, right: 0cm),
  )
  for page-num in range(1, pages + 1) {
    image(pdf-path, width: 100%, page: page-num)
    pagebreak()
  }
}

#let fei-outline() = {
  show outline.entry.where(
    level: 1,
  ): it => link(
    it.element.location(),
    [#strong([#it.prefix()   #it.body() #box(width: 1fr, repeat(gap: 0.15em)[ ]) #it.page() \ ])],
  )
  outline()
  pagebreak()
}

#let fei-outline-code() = {
  outline(
    title: [#translate("outline-code")],
    target: figure.where(kind: raw),
  )
  pagebreak()
}

#let fei-outline-tables() = {
  outline(
    title: [#translate("outline-table")],
    target: figure.where(kind: table),
  )
  pagebreak()
}

#let fei-outline-image() = {
  outline(
    title: [#translate("outline-image")],
    target: figure.where(kind: image),
  )
  pagebreak()
}

#let print-keywordsSK() = {
  set text(heading-2)
  align(left, text(font: font, strong([Kľúčové slová])))
  set text(text-size)

  [#context {
    let vars = variables-state.get()
    vars.at("keywords")
    }]

  pagebreak()
}

#let print-keywordsEN() = {
  set text(heading-3)
  align(left, text(font: font, strong([Keywords])))
  set text(text-size)

    [#context {
    let vars = variables-state.get()
    vars.at("keywords")
    }]

  pagebreak()
}

/// This function constructs the abstract, which is supposed to come directly after the frontmatter.
/// -> content
#let abstract(
  content,
  /// The font, which is only used for the heading of the abstract paragraph.
  /// -> string
  // font: title-font,
  /// The title which the abstract paragraph should have.
  /// -> "en" | "sk"
  lang: "sk",
) = {
  // English abstract
  // v(50pt, weak: true)
  set par(first-line-indent: 0pt)
  set text(heading-1)
  // show: pad.with(x: 1cm)
  align(left, text(font: font, strong(translate("abstract", lang: lang))))
  v(20pt)
  set text(text-size)

  content

  v(20pt)
  if lang == "sk" [
    #print-keywordsSK()
  ] else [
    #print-keywordsEN()
  ]
}

#let introduction(content) = {
  heading(numbering: none)[#translate("introduction")]
  content
  pagebreak()
}

#let main-matter(content) = {
  content
  pagebreak()
}

#let fei-conclusion(content) = {
  heading([#translate("conclusion")], numbering: none)
  content
  pagebreak()
}

#let fei-ai-declaration(content) = {
  heading([#translate("ai-declaration")], numbering: none, outlined: false)
  content
  pagebreak()
}

#let fei-thanks(body) = {
  [
    #v(1fr)
    #heading(level: 2, outlined: false, numbering: none)[#translate("thanks")]
    #body
    #pagebreak()

  ]
}

#let start-numbering(body) = {
  set page(numbering: "1")
  body
}

#let appendix-counter = counter("appendix")

#let noindent(body) = {
  set par(first-line-indent: 0pt)
  body
}

#let indent(body) = {
  set par(first-line-indent: (amount: first-line-indent, all: true))
  body
}

#let appendix(content, title) = {
  appendix-counter.step()
  context {
    let suffix = translate("appendix-suffix")
    let letter = numbering("A", appendix-counter.get().first())
    heading(numbering: none)[#suffix #letter: #title]
  }

  content

  pagebreak()
}

//[x] cislovanie a nadpis medzera vatsia ok
//[x]pozriet ostatne skolske sablony, best practises.... najlepšia: https://github.com/npikall/vienna-tech
//[x] postupne prepisovat sablonu
//[x] Zoznam algoritmov, obrazkov a tabuliek
//[x] Zoznam výpisov kódov
//[x] conclusion
//[x] ==== Mená tvorcov v latechu je to ako \paragraph -> najst alternativu v typst
//    heading level 4 a viac nie je v outline
//[x]   show heading.where(level: 4): set heading(outlined: false, numbering: none) spravit tak aby 4 a vatsie
//[x] po nadpisoch vypnut first line indent a math , po ostatnych ako figure treba mat first line indent
// ale niekedy uzivatel aby vedel sam vypnut first line indent
// po nadpisoch neodsadzovat inak odsadzovat, ale mat moznost vypnut
// #[
// #set par(first-line-indent: 0pt)
// asdfasfd
//
// ]
//
// dalksdfi
//[ ] https://github.com/typst/typst/issues/1093 ciarka v math
//[x] upravit codeblock podla latex
//[x] vyhodit prefix na odkazy ako Tabuľka 2., Výpis 1., nechat iba 2., 1.
// [x] caption kodu Výpis 1 zmenit na Výpis kódu 1.
// low prio:
//[ ]

//[x] bakalarka, diplomovka
//[x] doupravit titulne stranu podla latex
//[x] appendix podoplnat
//[] upravit strukturu
//[] publish to typst universe
// nice to have:
// [] dizertacka
