// ──────────────────────────────────────────────────────────────────────────────
// Paket:  hak-imst
// Zweck:  Diplomarbeits-Vorlage für HAK/HAS und Kolleg Imst
//
// Exportierte Symbole:
//   hak            – Template-Funktion für die HAK-Variante
//   kolleg         – Template-Funktion für die Kolleg-Variante
//   running-header – Kopfzeile mit aktuellem Kapitel/Abschnitt
//   set-responsible – Verantwortliche Person für Footer umschalten
// ──────────────────────────────────────────────────────────────────────────────

// ── Laufende Kopfzeile ────────────────────────────────────────────────────────

// = Package imports
#import "@preview/mmdr:0.2.2": mermaid

#let running-header(fallback: [Projektarbeit]) = context {
  let chapter = none
  let section = none
  let heads = query(selector(heading).before(here()))

  for h in heads {
    if h.level == 1 {
      chapter = h.body
      section = none
    } else if h.level == 2 {
      section = h.body
    }
  }

  let left_text = if chapter == none { fallback } else { chapter }
  let right_text = if section == none { left_text } else { section }

  set text(size: 9pt)
  stack(
    spacing: 2pt,
    grid(
      columns: (1fr, 1fr),
      column-gutter: 1em,
      [#left_text],
      [#align(end)[#right_text]],
    ),
    line(length: 100%),
  )
}

#let _responsible_key = "hak-imst.responsible"

#let set-responsible(name) = state(_responsible_key, none).update(_ => name)

#let _current_responsible(default) = context {
  let value = state(_responsible_key, none).get()
  if value == none { default } else { value }
}

// ── Interne Template-Funktion ─────────────────────────────────────────────────

#let _diplomarbeit(
  title: none,
  subtitle: none,
  projecttype: "Diplomarbeit",
  titlepage-variant: "hak",
  team: none,
  supervisors: none,
  location: none,
  date: datetime.today().display("[year]-[month]-[day]"),
  abstract: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "a4",
  lang: "de",
  region: "AT",
  font: none,
  fontsize: 12.5pt,
  sectionnumbering: none,
  responsible-default: [Gabi Sorglos],
  eidesstattliche-erklaerung-text: [Ich erklare an Eides statt, dass ich die vorliegende Diplomarbeit selbst verfasst und keine anderen als die angefuhrten Behelfe verwendet habe. Alle Stellen, die wortlich oder inhaltlich den angegebenen Quellen entnommen wurden, sind als solche kenntlich gemacht. Diese Versicherung umfasst auch verwendete bildliche Darstellungen, Tabellen, Skizzen und Zeichnungen. Etwaig verwendete Behelfe generativer KI-Tools wurden vollstandig und wahrheitsgetreu inkl. Produktversion und Prompt ausgewiesen. Ich bin damit einverstanden, dass meine Arbeit offentlich zuganglich gemacht wird.],
  abnahmeerklaerung-text: [Hiermit bestatigt der Auftraggeber, dass das ubergebene Produkt dieser Diplomarbeit den dokumentierten Vorgaben entspricht. Des Weiteren verzichtet der Auftraggeber auf unentgeltliche Wartung und Weiterentwicklung des Produktes durch die Projektmitglieder bzw. die Schule.],
  vorwort-text: [Hinweise, wie das bearbeitete Thema gefunden wurde, sowie Danksagungen fur Betreuung und Unterstutzung.],
  kurzfassung-text: [Kurzbeschreibung von Aufgabenstellung und Problemlosung.],
  abstract-text: [Englische Version der Kurzfassung.],
  project-partner-logo: none,
  school-logo: none,
  doc,
) = {
  // "hak" im Fließtext → Logo + vollständiger Name
  // show "hak": _ => box[
  //   #box(image("template/typst_media/logos/Logo_HAK_Imst.png", height: 0.7em))
  //   Handelsakademie und Handelsschule Imst
  // ]

  show terms: it => {
    it.children
      .map(child => [
        #strong[#child.term]
        #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
      .join()
  }

  set page(paper: paper, margin: margin, footer: none)
  set par(justify: true, leading: 0.55em)

  if font == none {
    set text(lang: lang, region: region, size: fontsize)
  } else {
    set text(lang: lang, region: region, font: font, size: fontsize)
  }

  set heading(numbering: sectionnumbering)
  show heading.where(level: 1): it => [
    #pagebreak(weak: true)
    #block(above: 1.8em, below: 1.0em)[#it]
  ]
  show heading.where(level: 2): set block(above: 1.25em, below: 0.65em)
  show heading.where(level: 3): set block(above: 0.95em, below: 0.5em)
  show figure.where(kind: "listing"): set block(breakable: true)
  show figure.where(kind: image): set figure(placement: auto)
  show figure.where(kind: table): set figure(placement: auto)
  show bibliography: set bibliography(title: [Literaturverzeichnis])

  // ── Titelseite ──────────────────────────────────────────────────────────────
  if title != none {
    let school_logo_final = if school-logo != none {
        school-logo
    } else {
        image("template/typst_media/logos/Logo_Schule.png")
    }

    let project_partner_logo_final = if project-partner-logo != none {
        project-partner-logo
    } else {
        image("template/typst_media/logos/Logo_Projektpartner.png")
    }    

    align(center)[
      #grid(
        columns: (auto, 1fr),
        align: (left, right),
        column-gutter: 1.5cm,
        [
          #set image(height: 2.2cm)
          #project_partner_logo_final
        ],
        [
          #set image(height: 2.2cm)
          #school_logo_final
        ]
      )
      #v(1.2cm)
      #text(weight: "semibold", size: 1.05em)[#projecttype]
      #v(0.5cm)
      #text(weight: "bold", size: 1.9em)[#title]
      #if subtitle != none [
        #v(0.4cm)
        #text(size: 1.15em)[#subtitle]
      ]

      #if titlepage-variant == "kolleg" [
        #if team != none [
          #v(1.2cm)
          #text(weight: "semibold")[Ausgearbeitet von]
          #v(0.3cm)
          #for entry in team [#entry.name#linebreak()]
        ]
        #if supervisors != none [
          #v(0.7cm)
          #text(weight: "semibold")[Betreut durch]
          #v(0.3cm)
          #for supervisor in supervisors [#supervisor#linebreak()]
        ]
      ] else [
        #if team != none [
          #v(1.2cm)
          #text(weight: "semibold")[Eingereicht von]
          #v(0.3cm)
          #table(
            columns: (auto, 1fr),
            align: (left, left),
            inset: 4pt,
            stroke: none,
            ..team.map(entry => (entry.name, entry.responsibility)).flatten(),
          )
        ]
        #if supervisors != none [
          #v(0.7cm)
          #text(weight: "semibold")[Eingereicht bei]
          #v(0.3cm)
          #for supervisor in supervisors [#supervisor#linebreak()]
        ]
      ]

      #if date != none [
        #v(0.9cm)

        #if location != none [
          #location,
        ] #date
      ]

    ]
    pagebreak()

    // ── Eidesstattliche Erklärung ─────────────────────────────────────────────
    if eidesstattliche-erklaerung-text != none {
      heading(level: 1, numbering: none, outlined: false)[Eidesstattliche Erklarung]
      eidesstattliche-erklaerung-text
      v(1.2cm)
      grid(
        columns: (1fr, 1fr),
        row-gutter: 1.1cm,
        [#stack(spacing: 2mm, line(length: 5cm), [Ort, Datum])],
        [#stack(spacing: 2mm, line(length: 5cm), [Unterschrift])],
        [#stack(spacing: 2mm, line(length: 5cm), [Unterschrift])],
        [#stack(spacing: 2mm, line(length: 5cm), [Unterschrift])],
      )
      pagebreak()
    }

    // ── Abnahmeerklärung ──────────────────────────────────────────────────────
    if abnahmeerklaerung-text != none {
      heading(level: 1, numbering: none, outlined: false)[Abnahmeerklarung]
      abnahmeerklaerung-text
      v(1.2cm)
      [#stack(spacing: 2mm, line(length: 5cm), [Ort, Datum])]
      v(1.8cm)
      [#stack(spacing: 2mm, line(length: 5cm), [Auftraggeber])]
      pagebreak()
    }

    // ── Vorwort / Kurzfassung / Abstract ─────────────────────────────────────
    if vorwort-text != none {
      heading(level: 1, numbering: none, outlined: false)[Vorwort]
      vorwort-text
      pagebreak()
    }

    if kurzfassung-text != none {
      heading(level: 1, numbering: none, outlined: false)[Kurzfassung]
      kurzfassung-text
      pagebreak()
    }

    if abstract-text != none {
      heading(level: 1, numbering: none, outlined: false)[Abstract]
      abstract-text
      pagebreak()
    }

    // ── Verzeichnisse ─────────────────────────────────────────────────────────
    outline(title: [Inhaltsverzeichnis])
    pagebreak()
    outline(title: [Abbildungsverzeichnis], target: figure.where(kind: image))
    pagebreak()
    outline(title: [Tabellenverzeichnis], target: figure.where(kind: table))
    pagebreak()
    outline(title: [Quelltextverzeichnis], target: figure.where(kind: "listing"))
    pagebreak()
  }

  if abstract != none {
    block(inset: 2em)[
      #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  let header_fallback = if title == none { [Projektarbeit] } else { title }

  set page(
    header: [#running-header(fallback: header_fallback)],
    footer: context [
      #set text(size: 9pt)
      #grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        [Verantwortlich fur den Inhalt: #_current_responsible(responsible-default)],
        [Seite #counter(page).display("1 / 1")],
      )
    ],
  )

  if cols == 1 { doc } else { columns(cols, doc) }
}

#let report(
  title: none,
  subtitle: none,
  projecttype: "Bericht",
  titlepage-variant: "hak",
  author: none,
  location: none,
  date: datetime.today().display("[year]-[month]-[day]"),
  kurzfassung-text: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "a4",
  lang: "de",
  region: "AT",
  font: none,
  fontsize: 12.5pt,
  sectionnumbering: none,
  responsible-default: none,
  project-partner-logo: none,
  school-logo: none, 
  doc,
) = {  

  // = Shortcuts
  // "hak" im Fließtext → Logo + vollständiger Name
  // show regex("(?i)\\bhak\\b"): _ => box[
  //   #box(image("template/typst_media/logos/Logo_HAK_Imst.png", height: 0.7em))
  //   Handelsakademie und Handelsschule Imst
  // ]

  // show regex("(?i)\\bkol\\b"): _ => box[
  //   #box(image("template/typst_media/logos/Logo_Kolleg_Imst.png", height: 0.7em))
  //   IT-KOLLEG IMST
  // ]

  show terms: it => {
    it.children
      .map(child => [
        #strong[#child.term]
        #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
      .join()
  }

  set page(paper: paper, margin: margin, footer: none)
  set par(justify: true, leading: 0.55em)

  if font == none {
    set text(lang: lang, region: region, size: fontsize)
  } else {
    set text(lang: lang, region: region, font: font, size: fontsize)
  }

  set heading(numbering: sectionnumbering)
  show heading.where(level: 1): it => [
    #block(above: 1.8em, below: 1.0em)[#it]
  ]
  show heading.where(level: 2): set block(above: 1.25em, below: 0.65em)
  show heading.where(level: 3): set block(above: 0.95em, below: 0.5em)
  show figure.where(kind: "listing"): set block(breakable: true)
  show figure.where(kind: image): set figure(placement: auto)
  show figure.where(kind: table): set figure(placement: auto)
  show bibliography: set bibliography(title: [Literaturverzeichnis])

  let header_fallback = if title == none { [Projektarbeit] } else { title }

  set page(
    // header: [#running-header(fallback: header_fallback)],
    footer: context [
      #set text(size: 9pt)
      #grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        [Verantwortlich fur den Inhalt: #_current_responsible(responsible-default)],
        [Seite #counter(page).display("1 / 1")],
      )
    ],
  )

  // ── Titelseite ──────────────────────────────────────────────────────────────
  if title != none {
    let school_logo_final = if school-logo != none {
        school-logo
    } else {
        image("template/typst_media/logos/Logo_Schule.png")
    }

    let project_partner_logo_final = if project-partner-logo != none {
        project-partner-logo
    } else {
        image("template/typst_media/logos/Logo_Projektpartner.png")
    }    

    align(left)[
      #grid(
        columns: (auto, 1fr),
        align: (left, right),
        column-gutter: 1.5cm,
        [
          
        ],
        [
          #set image(height: 2.2cm)
          #school_logo_final
        ]
      )
      #v(0.0cm)
      #text(weight: "semibold", size: 1.55em)[#projecttype]
      #v(0.0cm)
      #text(weight: "bold", size: 1.9em)[#title]
      #if subtitle != none [
        #v(0.0cm)
        #text(size: 1.15em)[#subtitle]
      ]
      #if author != none [
          #v(0.5cm)
          #author
      ]

      #if date != none [
        #v(0.0cm)

        #if location != none [
          #location,
        ] #date
      ]
    ]
    
  }

  if kurzfassung-text != none {
    v(2em) 
    pad(
      x: 1.5cm, 
      [ #kurzfassung-text ]
    )
    v(2em) 
  }

  if cols == 1 { doc } else { columns(cols, doc) }
}

// ── Öffentliche Template-Funktionen ──────────────────────────────────────────

/// HAK-Variante der Diplomarbeits-Vorlage.
/// Verwendung:  #show: hak.with(title: [...], ...)
#let hak = _diplomarbeit.with(titlepage-variant: "hak")

/// Kolleg-Variante der Diplomarbeits-Vorlage.
/// Verwendung:  #show: kolleg.with(title: [...], ...)
#let kolleg = _diplomarbeit.with(titlepage-variant: "kolleg")
