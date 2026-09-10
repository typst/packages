// Makra
#let ang(it) = [(ang.~#text(lang: "en", style: "italic", it))]

// Szablon
#let praca-dyplomowa(
  /// ścieżka do pliku pdf strony tytułowej
  /// path
  title-page-path: path("example/assets/strona-tytulowa.pdf"),
  /// ścieżka do pliku pdf z oświadczeniem o samodzielnej pracy
  /// path
  disclaimer-page-path: path("example/assets/oswiadczenie.pdf"),

  /// treść streszczenia w języku polskim
  /// -> content
  abstract-pl: [],
  /// słowa kluczowe w języku polskim
  /// -> str
  keywords-pl: "",
  /// dziedzina nauki i techniki, zgodnie z wymogami OECD w języku polskim
  /// -> str
  oecd-pl: "",

  /// treść streszczenia w języku angielskim
  /// -> content
  abstract-eng: [],
  /// słowa kluczowe w języku angielskim
  /// -> str
  keywords-eng: "",
  /// dziedzina nauki i techniki, zgodnie z wymogami OECD w języku angielskim
  /// -> str
  oecd-eng: "",

  /// treść wykazu skrótów, zalecane jest użycie wbudowanego elementu listy definicji (term list) w typst
  /// -> content
  abbreviations: [],
  /// ścieżka do pliku .bib z bibliografią,
  /// .yaml w formacie Hayagriva powinien też działać bez większych problemów, aczkolwiek nie było to testowane
  /// -> path
  bibliography-path: path("example/bibliography.bib"),

  /// lista bloków contentu które zostaną dołączone w tej kolejności na końcu dokumentu
  /// zaleca się zaimportowanie ich pokolei przy pomocy dorektywy `include`, np. `appendices: (include "a.typ", include "b.typ")`
  /// nazwy "Dodatek A","Dodatek B" itd. są automatycznie dołączane do nagłówka.
  /// -> array
  appendices: (),

  body,
) = {
  // === FORMATOWANIE ===
  set page(
    paper: "a4",
    margin: (
      top: 2.5cm,
      bottom: 2.5cm,
      inside: 3.5cm,
      outside: 2.5cm,
    ),
    footer: align(
      center,
      text(
        size: 9pt,
        context counter(page).display("1"),
      ),
    ),
  )

  set text(
    font: "Arial",
    size: 10pt,
    lang: "pl",
    hyphenate: true,
  )

  set par(
    leading: 1.5em, // interlinia
    first-line-indent: (
      amount: 1.25cm,
      all: true,
    ),
    justify: true,
  )

  show heading: set block(
    above: 12pt + 1.5em,
    below: 6pt + 1.5em,
  ) // odstępy przy nagłówkach
  show heading.where(level: 1): upper // ALL CAPS
  show heading.where(level: 1): set text(size: 12pt)
  show heading.where(level: 1): it => {
    // Reset numeracji każdego z liczników po rozpoczęciu nowego rozdziału
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)

    pagebreak(weak: true) // rodziały na nowych stronach
    it
  }

  show heading.where(level: 2): set text(size: 10pt, style: "italic")
  show heading.where(level: 3): set text(size: 10pt, style: "italic", weight: 400)

  // Zmiana funkcji numerowania rysunków na taką co dokleja numer rodziału z przodu
  set figure(
    numbering: (..num) => numbering(
      "1.1",
      counter(heading).get().first(),
      num.pos().first(),
    ),
  )
  set figure.caption(separator: [. ]) // kropka zamiast dwukropku po numerze rysunku/tabeli w caption

  // Formatowanie obrazków
  show figure.where(kind: image): set text(size: 9pt)
  show figure.where(kind: image): set figure(
    supplement: "Rys.",
    gap: 6pt,
  )
  show figure.where(kind: image): set block(
    above: 12pt,
    below: 12pt,
  )

  // Formatowianie tabel
  show figure.where(kind: table): set text(size: 9pt)
  show figure.where(kind: table): set figure(
    gap: 6pt,
  )
  show figure.where(kind: table): set block(
    above: 12pt,
    below: 12pt,
    // załamanie tabeli po przepełnieniu strony
    // WAŻNE: nagłówek tabeli pojawi się na drugiej stronie tylko jeżeli oznaczy się co jest nagłówkiem podczas tworzenia tabeli przy użyciu `table.header`
    breakable: true,
  )
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): it => {
    // zmiana formatowania captionu tabeli na pogrubienie i wyrównanie do lewej
    // zawinięte w `block` zamiast [] żeby nie dziedziczyło po paragrafie
    show figure.caption: it => align(left, block({
      strong({
        it.supplement
        " "
        it.counter.display(it.numbering)
        it.separator
      })
      it.body
    }))

    it
  }

  // Formatowanie listingów
  show figure.where(kind: raw): set text(size: 9pt)
  show figure.where(kind: raw): set figure(
    gap: 6pt,
  )
  show figure.where(kind: raw): set block(
    above: 12pt,
    below: 12pt,
  )
  show figure.where(kind: raw): set par(leading: 0.75em)

  // Formatowanie równań
  set math.equation(
    numbering: (..num) => numbering(
      "(1.1)",
      counter(heading).get().first(),
      num.pos().first(),
    ),
  )

  set list(
    marker: ([•], [--]),
    indent: 1.5em,
  )
  set enum(
    indent: 1.5em,
  )

  set terms(
    separator: [
      #hide([#sym.space] * 4)--#hide([#sym.space] * 4)
    ],
    spacing: 6pt + 1.5em,
  )

  // Formatowanie spisu treści
  show outline.entry: set block(
    above: 0pt,
    below: 1em,
  )
  show outline.entry: set par(leading: 9pt)
  show outline.entry: set text(size: 9pt)
  set outline.entry(fill: repeat(gap: 0.45em)[.])
  set outline(
    indent: 0.75cm,
  )

  // === KONIEC FORMATOWANIA ===
  // Tytuł i Oświadczenie
  page(margin: 0pt)[
    #image(title-page-path)
  ]
  pagebreak()

  page(margin: 0pt)[
    #image(disclaimer-page-path)
  ]
  pagebreak()

  // Abstract (pl)
  [
    #set heading(outlined: false, bookmarked: true)
    = Streszczenie

    #abstract-pl

    #set par(first-line-indent: 0pt)
    \ *Słowa kluczowe:* #keywords-pl

    \ *Dziedzina nauki i~techniki, zgodnie z~wymogami OECD:* #emph(oecd-pl)
  ]

  // Abstract (eng)
  [
    #set heading(outlined: false, bookmarked: true)
    = Abstract

    #abstract-eng

    #set par(first-line-indent: 0pt)
    \ *Keywords:* #keywords-eng

    \ *OECD field of science and technology:* #emph(oecd-eng)
  ]

  // Spis Treści
  [
    #show outline.entry.where(level: 1): strong
    #outline()
  ]

  // Wykaz Skrótów
  [
    // Konwersja na tabelke w celu wyrównania myślników w tabeli
    #show terms: it => grid(
      columns: 5,
      row-gutter: 6pt + 1.5em,
      ..it
        .children
        .map(it => (
          strong(it.term),
          h(1em),
          [--],
          h(1em),
          it.description,
        ))
        .flatten()
    )

    = Wykaz Ważniejszych Oznaczeń i Skrótów

    #abbreviations
  ]

  // GŁÓWNA CZĘŚĆ PRACY
  {
    pagebreak()
    set heading(numbering: "1.1.") // numerowanie tylko dla ciała pracy
    body
  }

  {
    bibliography(
      bibliography-path,
      title: [Wykaz Literatury],
      style: "ieee",
    )
  }

  show outline: set heading(outlined: true)

  // Wykaz Rysunków
  [
    #outline(
      title: [Wykaz Rysunków],
      target: figure.where(kind: image),
    )
  ]

  // Wykaz Tabel
  [
    #outline(
      title: [Wykaz Tabel],
      target: figure.where(kind: table),
    )
  ]

  // Reset numerowania nagłówków przez startem dodatków + zmiana formatowania
  counter(heading).update(0)
  show heading.where(level: 1): set heading(
    numbering: (..n) => "Dodatek " + numbering("A", ..n) + ":",
  )

  // Dodatki
  for appendix in appendices {
    if type(appendix) != content {
      panic("Dodatek nie jest typu 'content'")
    }

    pagebreak(weak: true)
    appendix
  }
}
