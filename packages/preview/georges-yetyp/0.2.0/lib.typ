#let trads = (
  fr: (
    summary: [Résumé],
    student: [Étudiant⋅e],
    year: [Année d'étude dans la spécialité],
    year-value: year => [#year#super[ème] année],
    company: [Entreprise],
    address: [Adresse],
    responsable: [Responsable administratif⋅ve],
    tuteur: [Tuteur⋅ice de stage],
    référent: [Enseignant⋅e référent⋅e],
    title: [Titre],
    bibliography: [Bibliographie],
    figures: [Table des figures],
    glossary: [Glossaire],
    appendices: [Annexes],
    report: year => [Rapport de stage de #year#super[ème] année],
    book-name: [Tome principal \ & \ Annexes],
    uni-year: (from, to) => [Année universitaire #from -- #to],
  ),
  en: (
    summary: [Summary],
    student: [Student],
    year: [Study year in the department],
    year-value: year => [#year#super[th] year],
    company: [Company],
    address: [Address],
    responsable: [Administrative manager],
    tuteur: [Internship mentor],
    référent: [Referent teacher],
    title: [Title],
    bibliography: [Bibliography],
    figures: [Figures],
    glossary: [Glossary],
    appendices: [Appendices],
    report: year => [#year#super(if year == 3 { "rd" } else { "th"}) year internship report],
    book-name: [Main book \ & \ Appendices],
    uni-year: (from, to) => [University year #from -- #to],
  )
)

#let rapport(
  nom: none,
  entreprise: (
    nom: none,
    adresse: none,
    téléphone: none,
    logo: none,
  ),
  filière: "INFO",
  année: 5,
  titre: none,
  référent: none,
  responsable: none,
  tuteur: none,
  période: [25 Mars 2024 -- 25 Août 2024],
  résumé: none,
  fonte: "New Computer Modern",
  glossaire: none,
  lang: "fr",
  bibliographie: none,
  annexes-extra: none,
  body
) = {
  let fontes-dict = if type(fonte) == str {
    (
      corps: fonte,
      titres: fonte,
    )
  } else {
    fonte
  }

  set text(lang: lang, font: fontes-dict.corps, size: 12pt)
  set par(justify: true, leading: 0.8em)
  set heading(numbering: "I.1 -")
  show heading: block.with(spacing: 1.5em)
  show heading: set text(font: fontes-dict.titres)
  set bibliography(title: none)

  show raw.where(block: false, lang: none): set text(fill: purple)
  show link: set text(fill: blue)

  if lang != "fr" and lang != "en" {
    panic("Ce template n'est disponible qu'en français et en anglais")
  }

  if nom == none {
    panic("`nom` doit être une chaîne de caractère (avec votre nom et prénom)")
  }

  if titre == none {
    panic("`titre` doit être une chaîne de caractère (avec le titre du rapport)")
  }

  if type(entreprise) !=  dictionary {
    panic("`entreprise` doit être un dictionnaire contenant `nom`, `adresse` et éventuellemenent `téléphone` et `logo`")    
  }

  if entreprise.nom == none {
    panic("`entreprise.nom` doit être une chaîne de caractères ou un bloc de contenu")
  }

  let trad = trads.at(lang)

  let entreprise-text-info = align(horizon + right, {
    text(size: 14pt, entreprise.nom)
    linebreak()
    entreprise.adresse
  })
  let entreprise-info = if "logo" in entreprise and entreprise.logo != none {
    (
      align(
        right + horizon,
        entreprise.logo
      ),
      [],
      entreprise-text-info
    )
  } else {
    (entreprise-text-info,)
  }

  {    
    grid(
      columns: (1fr, 1fr),
      column-gutter: 5em,
      row-gutter: 1em,
      align(horizon, image("logo-polytech.png")),
      ..entreprise-info
    )

    v(1fr)
    align(center, [
      #set text(size: 16pt)
      #nom \
      #filière \
      #trad.at("report")(année)

      #v(1fr)

      #{
        set par(justify: false)
        box(width: 60%, smallcaps(heading(outlined: false, numbering: none, text(size: 20pt, titre))))
      }

      #v(1fr)

      #trad.book-name

      #v(1fr)

      #let year = datetime.today().year()

      #trad.at("uni-year")(year - 1, year) \
      #période
    ])
  }

  pagebreak()
  {
    set page(header: context {
      let headings-before = query(
        selector(heading.where(outlined: true)).before(here())
      )

      let heading = if headings-before.len() == 0 {
        query(
        selector(heading.where(outlined: true)).after(here())
      ).first()
      } else {
        headings-before.last()
      }

      set text(size: 9pt)
      grid(
        columns: (1fr, auto),
        emph(titre),
        emph([#heading.body])
      )
    }, numbering: "1")

    show figure: it => align(center, block(spacing: 3em, it))

    show raw: set text(font: ("Fira Code", "FiraCode", "FiraCode Nerd Font"))

    show raw.where(block: true): it => {
      block(
        width: 110%,
        stroke: 1pt + gray,
        radius: 0.2em,
        inset: (y: 1em, x: 5%),
        align(left, it)
      )
    }

    {
      set page(header: none)
      v(1fr)

      let summary = (title, contents) => {
        align(center, heading(outlined: false, numbering: none, title))
        align(center, block(width: 80%, align(left, contents)))
        v(0.5fr) 
      }

      if type(résumé) == dictionary {
        for (l, t) in trads {
          if l in résumé {
          summary(t.summary, résumé.at(l))
          }
        }
      } else {
        summary(trad.summary, résumé)
      }

      v(1fr)

      pagebreak()

      outline(indent: auto)
    }

    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      it
    }

    body 

    pagebreak()

    set page(header: none)

    heading(numbering: none, outlined: false, [#trad.appendices])

    if annexes-extra != none {
      annexes-extra
    }

    if glossaire != none {
      heading(numbering: none, outlined: false, level: 2, [#trad.glossary])
      glossaire
    }

    heading(numbering: none, outlined: false, level: 2, [#trad.figures])

    outline(target: figure, title: none)

    if bibliographie != none {
      heading(numbering: none, outlined: false, level: 2, [#trad.bibliography])
      bibliographie
    }
  }

  pagebreak()

  let résumé-contents = if type(résumé) == dictionary {
    résumé.at(lang)
  } else {
    résumé
  }

  let personne = (p) => {
    if "fonction" in p [
      #p.nom, #p.fonction
    ] else {
      p.nom
    }
    linebreak()
    if "téléphone" in p [
      #p.téléphone \
    ]
    if "email" in p [
      #p.email
    ]
  }

  show strong: it => text(size: 10pt, [#it \ ])
  set table.cell(colspan: 2)
  table(
    columns: (1fr, 1fr),
    gutter: 1em,
    stroke: none,
    table.cell(colspan: 1, [*#trad.student* #nom]),
    table.cell(colspan: 1, align(right, [*#trad.year* #trad.at("year-value")(année)])),
    [
      *#trad.company* #entreprise.nom \
      *#trad.address* #entreprise.adresse \
      #if "téléphone" in entreprise [
        *#trad.phone* #entreprise.téléphone
      ]
    ],
    [
      *#trad.responsable* #personne(responsable)
    ],
    [
      *#trad.tuteur* #personne(tuteur)
    ],
    [
      *#trad.référent* #personne(référent)
    ],
    [*#trad.title* #titre],
    [*#trad.summary* #résumé-contents]
  )
}
