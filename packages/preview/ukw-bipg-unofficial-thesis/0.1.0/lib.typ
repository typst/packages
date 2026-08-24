// ukw-bipg-unofficial-thesis — szablon pracy dyplomowej
// Kierunek: Badanie i Projektowanie Gier, Wydział Nauk o Kulturze, UKW w Bydgoszczy
// Zgodny z Regulaminem dyplomowania zatwierdzonym 27 stycznia 2026 r.

#let ukw-lang-strings = (
  pl: (
    toc: "Spis treści",
    figures: "Spis rysunków",
    tables: "Spis tabel",
    charts: "Spis wykresów",
    appendices: "Wykaz załączników",
    bibliography: "Spis literatury",
    abstract: "Streszczenie pracy dyplomowej",
    topic: "Temat pracy dyplomowej",
    author: "Imię i nazwisko autora pracy",
    album: "Nr albumu",
    supervisor: "Imię i nazwisko promotora pracy",
    keywords: "Słowa kluczowe (max. 10)",
    abstract-body: "Treść streszczenia (max. 1000 znaków)",
    figure: "Rys.",
    table: "Tab.",
    bachelor: "Praca licencjacka napisana pod kierunkiem",
    master: "Praca magisterska napisana pod kierunkiem",
    declaration-title: "OŚWIADCZENIE",
    declaration-sub: "autora pracy dyplomowej",
    faculty: "WYDZIAŁ NAUK O KULTURZE",
    college: "KOLEGIUM I",
    university: "UNIWERSYTET KAZIMIERZA WIELKIEGO",
  ),
  en: (
    toc: "Table of Contents",
    figures: "List of Figures",
    tables: "List of Tables",
    charts: "List of Charts",
    appendices: "List of Appendices",
    bibliography: "Bibliography",
    abstract: "Abstract",
    topic: "Title of the thesis",
    author: "Author",
    album: "Student ID",
    supervisor: "Supervisor",
    keywords: "Keywords (max. 10)",
    abstract-body: "Abstract (max. 1000 characters)",
    figure: "Fig.",
    table: "Tab.",
    bachelor: "BA thesis written under the supervision of",
    master: "MA thesis written under the supervision of",
    declaration-title: "DECLARATION",
    declaration-sub: "of the author of the thesis",
    faculty: "FACULTY OF CULTURAL STUDIES",
    college: "COLLEGE I",
    university: "KAZIMIERZ WIELKI UNIVERSITY",
  ),
)

#let ukw-line(width: 60%) = box(width: width, repeat[.])

// ——— Strona tytułowa (zał. nr 2 do Zarz. 53/2022/2023) ———
#let ukw-title-page(meta, s) = {
  set align(center)
  set par(justify: false, leading: 0.65em)
  v(1cm)
  text(14pt, weight: "bold")[#s.university]
  linebreak()
  text(13pt)[#s.college]
  linebreak()
  text(13pt)[#s.faculty]
  v(2.5cm)
  text(12pt)[#meta.author]
  linebreak()
  text(12pt)[#s.album: #meta.album]
  v(3cm)
  text(15pt, weight: "bold", upper(meta.title))
  if meta.subtitle != none {
    v(0.4cm)
    text(13pt, meta.subtitle)
  }
  v(3cm)
  text(12pt, if meta.degree == "master" { s.master } else { s.bachelor })
  v(0.6cm)
  text(12pt, weight: "bold")[#meta.supervisor]
  v(1fr)
  text(12pt)[BYDGOSZCZ #meta.year]
  pagebreak(to: "odd")
}

// ——— Oświadczenie (zał. nr 1) ———
#let ukw-declaration(meta, s) = {
  set par(justify: true, leading: 1em)
  align(right)[Załącznik nr 1 do Zarządzenia Nr 53/2022/2023 \ Rektora UKW z dnia 10 maja 2023 r.]
  v(0.8cm)
  grid(columns: 1, row-gutter: 0.8em,
    [#meta.author \ #text(9pt)[nazwisko i imię]],
    [#meta.album \ #text(9pt)[nr albumu]],
    [#meta.field \ #text(9pt)[kierunek studiów]],
    [#meta.study-type \ #text(9pt)[typ studiów i forma kształcenia]],
  )
  v(0.8cm)
  align(center)[#text(13pt, weight: "bold")[#s.declaration-title] \ #s.declaration-sub]
  v(0.6cm)
  [
    Świadoma(y) odpowiedzialności prawnej oświadczam, że praca dyplomowa
    #emph(meta.title)
    została wykonana samodzielnie i nie zawiera treści uzyskanych w sposób niezgodny
    z obowiązującymi przepisami.

    Oświadczam również, że:

    1) przedstawiona praca nie była wcześniej przedmiotem procedur związanych z uzyskaniem
    tytułu zawodowego w uczelni;

    2) drukowana wersja pracy dyplomowej jest identyczna z wprowadzoną do systemu APD
    wersją elektroniczną.
  ]
  v(0.8cm)
  align(right)[#ukw-line(width: 45%) \ #h(6em) #text(9pt)[(podpis studentki/a)]]
  v(0.8cm)
  [Bydgoszcz, dn. #ukw-line(width: 30%)]
  v(0.8cm)
  [Wyrażam zgodę / nie wyrażam zgody\* na udostępnienie przez Uniwersytet pracy dyplomowej
   dla potrzeb działalności badawczej i dydaktycznej.]
  v(0.8cm)
  align(right)[#ukw-line(width: 45%) \ #h(6em) #text(9pt)[(podpis studentki/a)]]
  v(1fr)
  text(9pt)[\* niepotrzebne skreślić]
  pagebreak(to: "odd")
}

// ——— Streszczenie i słowa kluczowe (zał. nr 3) ———
#let ukw-abstract(meta, s, abstract, keywords) = {
  set par(justify: true, leading: 1em)
  align(right)[Załącznik nr 3 do Zarządzenia Nr 53/2022/2023 \ Rektora UKW z dnia 10 maja 2023 r.]
  v(0.8cm)
  align(center)[#text(13pt, weight: "bold")[#s.abstract]]
  v(0.8cm)
  [*#s.topic:* #meta.title]
  parbreak()
  [*#s.author:* #meta.author]
  parbreak()
  [*#s.album:* #meta.album]
  parbreak()
  [*#s.supervisor:* #meta.supervisor]
  v(0.5cm)
  [*#s.keywords:*]
  parbreak()
  keywords.join(", ")
  v(0.5cm)
  [*#s.abstract-body:*]
  parbreak()
  abstract
  v(0.5cm)
  context {
    let n = if type(abstract) == str { abstract.len() }
            else if abstract.has("text") { abstract.text.len() } else { none }
    if n != none {
      text(9pt, fill: if n > 1000 { red } else { gray })[
        Licznik pomocniczy (nie drukować): #n / 1000 znaków.
      ]
    }
  }
  pagebreak(to: "odd")
}

// ——— Główna funkcja szablonu ———
#let ukw-thesis(
  title: "Tytuł pracy dyplomowej",
  subtitle: none,
  author: "Imię Nazwisko",
  album: "000000",
  supervisor: "dr hab. Imię Nazwisko, prof. UKW",
  field: "Badanie i Projektowanie Gier",
  study-type: "studia stacjonarne pierwszego stopnia",
  degree: "bachelor",          // "bachelor" | "master"
  year: "2026",
  lang: "pl",                  // "pl" | "en" — zgodnie z §2 ust. 1
  abstract: [],
  keywords: (),
  bibliography-file: none,
  bibliography-style: "apa",
  list-of-figures: true,
  list-of-tables: true,
  draft: false,                // true = wydruk jednostronny, bez pustych stron
  body,
) = {
  let s = ukw-lang-strings.at(lang, default: ukw-lang-strings.pl)
  let meta = (
    title: title, subtitle: subtitle, author: author, album: album,
    supervisor: supervisor, field: field, study-type: study-type,
    degree: degree, year: year,
  )

  set document(title: title, author: author, keywords: keywords.map(str))

  // §2 ust. 2: A4, Times New Roman 12 pkt, interlinia 1½, marginesy 2,5 cm, justowanie
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    number-align: center,
  )
  set text(
    font: ("Times New Roman", "TeX Gyre Termes", "Liberation Serif", "FreeSerif"),
    size: 12pt,
    lang: lang,
    hyphenate: true,
  )
  set par(justify: true, leading: 1em, first-line-indent: 1.25cm, spacing: 1em)

  // §2 ust. 4: jednolita numeracja rozdziałów, przypisy z numeracją ciągłą
  set heading(numbering: "1.1.1.")
  set footnote(numbering: "1")
  counter(footnote).update(0)

  show heading: it => {
    set text(font: ("Times New Roman", "TeX Gyre Termes"), weight: "bold")
    set par(justify: false, first-line-indent: 0cm)
    if it.level == 1 {
      // §2 ust. 4: każdy rozdział zaczyna się od strony nieparzystej
      pagebreak(weak: true, to: if draft { none } else { "odd" })
      v(1cm)
      text(16pt, it)
      v(0.8cm)
    } else if it.level == 2 {
      v(0.8em); text(14pt, it); v(0.4em)
    } else {
      v(0.6em); text(12pt, it); v(0.3em)
    }
  }

  set figure(numbering: "1")
  show figure.caption: set text(10pt)
  show figure.where(kind: table): set figure.caption(position: top)

  set enum(indent: 0.5cm)
  set list(indent: 0.5cm)
  show link: set text(fill: rgb("#12365c"))
  show cite: set text(fill: black)

  // ——— Elementy wstępne (§2 ust. 5) ———
  set page(numbering: none)
  ukw-title-page(meta, s)
  ukw-declaration(meta, s)
  ukw-abstract(meta, s, abstract, keywords)

  set page(numbering: "1")
  counter(page).update(7)

  // b) spis treści
  {
    set par(first-line-indent: 0cm, justify: false)
    show outline.entry.where(level: 1): it => { v(0.6em); strong(it) }
    outline(title: s.toc, depth: 3, indent: auto)
    pagebreak(to: if draft { none } else { "odd" })
  }

  // c) część zasadnicza
  body

  // d) spis literatury
  if bibliography-file != none {
    pagebreak(weak: true, to: if draft { none } else { "odd" })
    set par(first-line-indent: 0cm)
    bibliography(bibliography-file, title: s.bibliography, style: bibliography-style)
  }

  // e) spis rysunków, tabel, wykresów
  set par(first-line-indent: 0cm, justify: false)
  if list-of-figures {
    pagebreak(weak: true, to: if draft { none } else { "odd" })
    outline(title: s.figures, target: figure.where(kind: image))
  }
  if list-of-tables {
    pagebreak(weak: true)
    outline(title: s.tables, target: figure.where(kind: table))
  }
}

// Pomocnicze: załącznik
#let zalacznik(nr, tytul, body) = {
  pagebreak(weak: true, to: "odd")
  heading(numbering: none, level: 1)[Załącznik nr #nr. #tytul]
  body
}
