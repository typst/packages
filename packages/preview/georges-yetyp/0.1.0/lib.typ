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
  body
) = {
  set text(lang: lang, font: fonte, size: 12pt)
  set par(justify: true, leading: 0.8em)
  set heading(numbering: "I.1 -")
  show heading: block.with(spacing: 1.5em)

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
    Rapport de stage de #année#super[ème] année

    #v(1fr)

    #smallcaps(text(size: 20pt, titre))

    #v(1fr)
    
    Tome principal \ & \ Annexes

    #v(1fr)

    #let year = datetime.today().year()

    Année universitaire #{year - 1}--#{year} \
    #période
  ])


  pagebreak()
  {
    set page(header: context {
      let headings-after = query(
        selector(heading.where(outlined: true)).after(here())
      )
      let heading = if headings-after.len() == 0 {
        query(
          selector(heading.where(outlined: true)).before(here())
        ).last()
      } else {
        headings-after.first()
      }
      grid(
        columns: (1fr, auto),
        emph(titre),
        emph(heading.body)
      )
    }, numbering: "1")

    show figure: it => align(center, block(spacing: 3em, it))
    
    show raw.where(block: true): it => {
      set text(font: "Fira Code")
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
      align(center, heading(outlined: false, numbering: none, [Résumé]))
      align(center, block(width: 80%, align(left, résumé)))
      v(1fr)
  
      pagebreak()
  
      outline(indent: auto)
    }
    
    body 

    pagebreak()

    set page(header: none)

    heading(numbering: none, outlined: false, [Annexes])

    if glossaire != none {
      heading(numbering: none, outlined: false, level: 2, [Glossaire])
      glossaire
    }
    
    heading(numbering: none, outlined: false, level: 2, [Table des figures])

    outline(target: figure, title: none)
  }

  pagebreak()

  show strong: it => text(size: 10pt, [#it \ ])
  set table.cell(colspan: 2)
  table(
    columns: (1fr, 1fr),
    gutter: 1em,
    stroke: none,
    table.cell(colspan: 1, [*Étudiant⋅e* #nom]),
    table.cell(colspan: 1, align(right, [*Année d'étude dans la spécialité* #année#super[ème] année])),
    [
      *Entreprise* #entreprise.nom \
      *Adresse* #entreprise.adresse \
      #if "téléphone" in entreprise [
        *Téléphone* #entreprise.téléphone
      ]
    ],
    [
      *Responsable administratif⋅ve* #responsable.nom, #responsable.fonction \
      #responsable.téléphone \
      #responsable.email
    ],
    [
      *Tuteur⋅ice de stage* #tuteur.nom \
      #tuteur.téléphone \
      #tuteur.email
    ],
    [
      *Enseignant⋅e référent⋅e* #référent.nom \
      #référent.téléphone \
      #référent.email
    ],
    [*Titre* #titre],
    [*Résumé* #résumé]
  )
}
