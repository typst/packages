#import "@preview/i-figured:0.2.4"

#let praca-dyplomowa(
  tytul: "Tytuł pracy dyplomowej",
  autor: "Imię i Nazwisko",
  kierunek: [],
  specjalnosc: [],
  rodzaj_pracy: [],
  slowa_kluczowe: [],
  krotkie_streszczenie: [],
  opiekun: [],
  rok: [],
  streszczenie: [],
  abstract: [],
  biblio: none,
  spis-rysunkow: true,
  spis-tabel: true,
  zalaczniki: none,
  body
) = {

  set text(font: "Times New Roman", size: 12pt, lang: "pl")

  set page(
    paper: "a4",
    margin: (left: 3.0cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    numbering: "1",
    number-align: center,
  )
  
  show math.equation: set par(leading: 0.65em, spacing: 1.2em)
  
  set heading(numbering: "1.1.")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  show heading.where(level: 1): set text(size: 14pt, weight: "bold")
  show heading.where(level: 1): set block(above: 12pt, below: 8pt)
  show heading.where(level: 1): set align(left)

  show heading.where(level: 2): set text(size: 13pt, weight: "bold")
  show heading.where(level: 2): set block(above: 6pt, below: 8pt)
  show heading.where(level: 2): set align(left)

  show heading.where(level: 3): set text(size: 12pt, weight: "bold")
  show heading.where(level: 3): set block(above: 6pt , below: 8pt)
  show heading.where(level: 3): set align(left)

  show footnote.entry: set text(size: 10pt)

  show figure: set text(size: 10pt)
  show table: set text(top-edge: "cap-height")
  set table(align: left)

  
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: bottom)
  set figure(numbering: "1.1")

  show heading: i-figured.reset-counters
  show figure: i-figured.show-figure

  
  show figure: set block(above: 10pt, below: 10pt)
  show figure.caption: set par(leading: 0.3em) 

  set math.equation(numbering: "(1.1)")

  set list(indent: 1cm, marker: ([•], [--]))
  show list: it => {
    set list(indent: 0em)
    it
  }

  set enum(indent: 1cm)
  show enum: it => {
    set enum(indent: 0em)
    it
  }

  //Strona tytułowa
  page(numbering: none)[
    #table(
    columns: (2cm, 1fr),
    stroke: none,
    table.cell(
      colspan: 2, 
      inset: 0pt, 
      align: left + top,
      stroke: (bottom: 0.5pt)
    )[#image("images/logoPWr_PL_poziom_czarne.png", width: 61%)],
    table.cell(fill: rgb("ebebeb"), align: bottom+right, inset: 0pt, stroke: (right: 0.5pt))[
      #v(86%)
      #rect(fill: black, height: 1.15cm, width: 1cm)
    ],
    table.cell(inset: (left: 10pt))[
      #text(weight: "bold", size: 14pt)[Wydział zarządzania] \
      #text( size: 14pt)[kierunek studiów: #kierunek]\
      specjalność: #specjalnosc
      #v(1fr)
      #align(center)[
        #text(size: 18pt)[Praca dyplomowa - #rodzaj_pracy]
      ]
      #v(1fr)
      #align(center)[
        #text(size: 16pt, weight: "bold")[#tytul]
      ]
      #v(1fr)
      #align(center)[
        #text(size: 14pt)[#autor]
      ]
      #v(1fr)
      #text(size: 11pt)[
        #grid(
        columns: (1fr,auto),
        [],[słowa kluczowe: \ #slowa_kluczowe]
      )

      #pad(left: 1cm)[
        krótkie streszczenie: \
        #krotkie_streszczenie
        ]
      ]

      
      #align(bottom)[
      #text(size: 9pt)[
        #table(
        stroke: 0.5pt,
        align: center + horizon,
        columns: (auto, 1fr, 2cm, 2.8cm),
        table.cell(rowspan: 2, align: left)[Opiekun/ka \ pracy \ dyplomowej],
        table.cell(colspan: 3, inset: 10pt)[ #text(size: 16pt)[#opiekun ]],
        table.cell(colspan: 3, inset: 3pt)[ _Tytuł/stopień naukowy/imię i nazwisko_ ],
        table.cell(colspan: 4, inset: (top: 14pt))[#text(size: 12pt)[Ostateczna ocena za pracę dyplomową]],
        table.cell(rowspan: 2, align: left)[Przewodniczący/a \ Komisji egzaminu \ dyplomowego],
        table.cell(inset: 16pt)[],
        [],[],
        table.cell(inset: 3pt)[_Tytuł/stopień naukowy/imię i nazwisko_], 
        table.cell(inset: 3pt)[_Ocena_],
        table.cell(inset: 3pt)[_podpis_]
      )
      ]

      #text(size: 10pt, style: "italic")[
        Do celów archiwalnych pracę dyplomową zakwalifikowano do: \*
        #enum(numbering: "a)", indent: 1em,
        [kategorii A (akta wieczyste)],
        [kategorii BE 50 (po 50 latach podlegające ekspertyzie)]
        )
        \* niepotrzebne skreślić
      ]
      #text(size: 10pt)[
        #align(right)[
        #rect(stroke: 0.5pt, width: 4cm, inset: 3pt)[
          #align(left)[pieczątka wydziałowa]
        ]
      ]
      ]

      #align(center)[
        #text(size: 14pt)[Wrocław, #rok]
      ]
      
    ]]
  )
  ]

  page(numbering: none)[]

  set par(justify: true, first-line-indent: (amount: 0.7cm, all: true) )
  set text(top-edge: 1em)
  set par(leading: 0.2em, spacing: 0.7em)

  //Strona na Streszczenia
  page(numbering: none)[
    #grid(
      columns: 100%,
      rows: (50%, 50%),
      
      [
        #text(size: 14pt, weight: "bold")[Streszczenie] 
        
        #streszczenie
      ],
      
      [
        #text(size: 14pt, weight: "bold")[Abstract] 
        
        #abstract
      ]
    )
  ]
  

  page(numbering: none)[]
  
  counter(page).update(1)

  //Spis treści
  outline(
    title: "Spis treści", 
    indent: auto
  )

  show outline: set heading(outlined: true)

  body

  if biblio != none {
    bibliography(biblio, full: true, style: "resources/cite-them-right-12th-edition-harvard.csl", title: "Bibliografia", group: "")
  }

  if spis-rysunkow {
    i-figured.outline(target-kind: image, title: [Spis rysunków])
  }

  if spis-tabel {
    i-figured.outline(target-kind: table, title: [Spis tabel])
  }

  if zalaczniki != none {
    heading(numbering: none)[Załączniki]

    zalaczniki
  }
}

// ==========================================
// FUNKCJE POMOCNICZE
// ==========================================

// Funkcja do załączników (wymaganie nr 10)
#let counter-zalacznik = counter("zalacznik")
#let zalacznik(tytul) = {
  counter-zalacznik.step()
  // pagebreak(weak: true)
  align(center)[
    #block(above: 10pt, below: 10pt)[
      #text(size: 14pt, weight: "bold",)[
        // DODANO SŁOWO KLUCZOWE #context
        Załącznik #context counter-zalacznik.display(). #tytul
      ]
    ]
  ]
}

// Funkcja do dodawania źródła pod tabelą/rysunkiem (wymaganie nr 8)
#let zrodlo(tekst) = block(
  width: 100%, 
  above: 0pt,
  below: 10pt,
  align(center)[#text(size: 10pt)[#v(-0.7em) Źródło: #tekst]]
)