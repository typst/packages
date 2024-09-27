#import "@preview/hydra:0.3.0": hydra
#import "@preview/codly:1.0.0": *

#let small-line = line(length: 100%, stroke: 0.045em)

#let get-current-heading-hydra(loc, top-level: false, top-margin) = {
    if(top-level){
      return hydra(1, top-margin:top-margin)
    }

    return hydra(2, top-margin:top-margin)
}

#show par: it => [#it <meta:content>]

#let project(
  title: "",
  subtitle: "",
  author: "",
  author-email: "",
  matrikelnummer: 0,
  prof: none,
  second-prof: none,
  date: none,
  glossary-columns: 1,
  enable-glossary: false,
  enable-abbildungsverzeichnis: false,
  bibliography: none,
  body,
) = {
  // Set the document's basic properties.
  set document(author: author, title: title)
  set page("a4")
  let top-margin = 3.75cm

  set page(margin: (inside: 3.5cm, outside: 2cm, y: top-margin))
  //set page(margin: (inside: 2.75cm, outside: 2.75cm, y: 1.75cm))

  set par(justify: true)
  show table : set table.cell(align: left)

  set text(font: "Arial", lang: "de", size: 12pt, hyphenate: false) // replaced this font: New Computer Modern
  show math.equation: set text(weight: 400)


  // heading size
  show heading.where(
  level: 1
): it => pad(bottom: 1em)[
  #set text(2em)
  #it
]

  // heading size
  show heading.where(
  level: 2
): it => pad(bottom: 0.4em, top: 0.4em)[
  #set text(1.3em)
  #it
]

  // heading size
  show heading.where(
  level: 3
): it => pad(bottom: 0.4em, top: 0.4em)[
  #set text(1.25em)
  #it
]

  // heading size
  show heading.where(
  level: 9
): it => pad(rest: 0em, bottom: -1.45em)[
  #it
]

  show heading.where(level: 1): set heading(supplement: [Kapitel])

  show heading.where(level: 2): set heading(supplement: [Abschnitt])

  show heading.where(level: 3): set heading(supplement: [Unterabschnitt])

  show heading.where(level: 9): set heading(supplement: [])

  show figure.where(kind: "code"): it => {
  if "label" in it.fields() {
    state("codly-label").update((_) => it.label)
    it
    state("codly-label").update((_) => none)
  } else {
    it
  }
}

  show: codly-init.with()
  show figure: set block(breakable: true);
  codly(
    zebra-fill: white,
    breakable: true,
    reference-sep: ", Zeile ",
    default-color: rgb("#7d7d7d")
  )


  // Title page.
  v(0.6fr)
  align(left, image("Wortmarke.svg", width: 26%))
  v(1.6fr)


  text(2em, weight: 700, title)
  v(1.2em, weak: true)
  text(author)
  v(1.2em, weak: true)
  text(subtitle)
  v(1.2em, weak: true)
  text(1.1em, date)

  align(right, image("Logo.svg", width: 26%))
  pagebreak()
  pagebreak()

  // Author
  grid(
    columns: (1fr, 4fr),
    rows: (auto),
    row-gutter: 3em,
    gutter: 13pt,
    text("Autor:", weight: "bold"),
    [#author\
    #link("mailto:" + author-email)\
    Matrikelnummer: #matrikelnummer
    ],
    text("Erstprüfer:", weight: "bold"),
    prof,
    text("Zweitprüfer:", weight: "bold"),
    second-prof,
  )

  align(bottom)[
  #align(center, text("Selbständigkeitserklärung", weight: "bold"))
  Hiermit erkläre ich, dass ich die eingereichte Bachelorarbeit selbständig und ohne fremde Hilfe verfasst, andere als die von mir angegebenen Quellen und Hilfsmittel nicht benutzt und die den benutzten Werken wörtlich oder inhaltlich entnommenen Stellen als solche kenntlich gemacht habe.


  #v(5.2em, weak: true)

    #grid(
    columns: (auto, 4fr),
    gutter: 13pt,
    [Hannover, den #date],
    align(right)[Unterschrift],
  )
  ]

  pagebreak()



  // Table of contents.
  show outline.entry.where(
    level: 1
  ): it => {
    if(it.element.has("level")){
      v(2em, weak: true)
       strong(it)
    }
    else{
      v(1.2em, weak: true)
      it
    }

  }
  outline(depth: 3, indent: true)
  pagebreak()

  if(enable-abbildungsverzeichnis){
    // table of figures
set page(numbering: "I")
counter(page).update(1)
  {
  show heading: none
  heading[Abbildungsverzeichnis]
}
outline(
  title: [Abbildungsverzeichnis],
  target: figure,
  indent: true
)

pagebreak()
  }


  // glossary

  if(enable-glossary){
    show figure.where(kind: "jkrb_glossary"): it => {emph(it.body)}
  [
    = Glossar <Glossary>

    #columns(glossary-columns)[
        #make-glossary(glossary-pool)
    ]
  ]
  }


    // header
    import "@preview/hydra:0.3.0": hydra
    set page(header: locate(loc => {

      // dont print anything when the first element on the page is a level 1 heading
      let chapter = hydra(1, loc: loc, top-margin: top-margin)
      //chapter = get-current-heading-hydra(loc, top-margin)

      if(chapter == none){
        return
      }


      if calc.even(loc.page()) {
        align(left, smallcaps(get-current-heading-hydra(loc, top-level: true, top-margin)))
      }
      else{
        align(right, emph(get-current-heading-hydra(loc, top-margin)))
      }

    small-line
  }))


  // footer
  set page(footer: locate(
    loc => if calc.even(loc.page()) {
      small-line
      align(left, counter(page).display("1"));
    } else {
      small-line
      align(right, counter(page).display("1"));
    }
  ))

  // ensure, that a level 1 heading always starts on an empty page
  show heading.where(level:1) : it => { pagebreak(weak:true, to: "even"); it}


  // Main body.
  set page(numbering: "1", number-align: center)
  counter(page).update(1)
  set heading(
    numbering: "1.1."
  )

  body

  set page(header: none)

  // bibliography
  if bibliography != none {
    bibliography
  }

  pagebreak()
  hide("white page")

  //todo-outline
}
