#import "insa-common.typ": *

// TOOLS:

#let insa-translate(translations, key, lang, placeholders: (:)) = {
  let key-translations = translations.at(key)
  let string
  if lang in key-translations {
    string = key-translations.at(lang)
  } else {
    string = key-translations.at("fr")
  }
  for (p-key, p-val) in placeholders.pairs() {
    string = string.replace("{" + p-key + "}", p-val)
  }
  string
}


// PAGINATING

#let insa-page-numbering-state = state("insa-page-numbering", true)

/// Hides the page counter at the bottom right, until the next call to `insa-show-page-counter`.
///
/// -> content
#let insa-hide-page-counter() = {
  insa-page-numbering-state.update(false)
}

/// Shows the page counter at the bottom right, and optionally updates it to a new value.
///
/// - current-page (int | none): page counter from now on, or `none` not to update the counter
/// -> content
#let insa-show-page-counter(current-page: none) = {
  insa-page-numbering-state.update(true)
  if current-page != none {
    counter(page).update(current-page)
  }
}

// FULL DOCUMENT:

#let insa-document(
  cover-type,
  cover-top-left: [],
  cover-middle-left: [],
  cover-bottom-right: [],
  back-cover: [],
  page-header: none,
  page-footer: none,
  include-back-cover: true,
  insa: "rennes",
  lang: "fr",
  metadata-title: none,
  metadata-authors: (),
  metadata-date: auto,
  doc
) = {
  set document(author: metadata-authors, date: metadata-date, title: metadata-title)

  set text(lang: lang, font: insa-heading-fonts)
  set page("a4", margin: 0cm)

  set par(justify: false) // only for the cover

  let back-page

  _ = insa-school-name(insa) // checks that the INSA is supported

  if cover-type == "light" {
    back-page = page(footer: none, header: none, margin: 0cm, image("assets/"+insa+"/back-cover2.png", width: 101%))

    // image
    place(image("assets/"+insa+"/front-cover1.png", width: 100%))

    // top-left
    place(
      dx: 2.5cm,
      dy: 6.5cm,
      block(
        width: 9.5cm,
        text(size: 18pt, cover-top-left)
      )
    )

    // middle-left
    place(
      dx: 2.5cm,
      dy: 13.7cm,
      block(
        width: 6.5cm,
        height: 7cm,
        align(horizon, text(size: 16pt, cover-middle-left))
      )
    )

    // bottom-right
    place(
      dx: 9.5cm,
      dy: 25.5cm,
      box(
        width: 8.5cm,
        text(size: 24pt, cover-bottom-right)
      )
    )

    if back-cover != [] {
      panic("back-cover has content but is incompatible with this cover-type")
    }

  } else if cover-type == "colored" {
    back-page = page(footer: none, header: none, margin: 0cm, image("assets/"+insa+"/back-cover2.png", width: 101%))

    // image
    place(image("assets/"+insa+"/front-cover3.png", width: 100%))

    // top-left
    place(
      dx: 2.5cm,
      dy: 7.5cm,
      block(
        width: 9.5cm,
        text(size: 20pt, fill: white, cover-top-left)
      )
    )

    if cover-middle-left != [] {
      panic("cover-middle-left has content but is incompatible with this cover-type")
    }
    if cover-bottom-right != [] {
      panic("cover-bottom-right has content but is incompatible with this cover-type")
    }
    if back-cover != [] {
      panic("back-cover has content but is incompatible with this cover-type")
    }

  } else if cover-type == "pfe" {
    back-page = page(footer: none, header: none, margin: 0cm)[
      #place(image("assets/"+insa+"/back-cover1.png", width: 100%))
      #place(dx: 1cm, dy: 1.2cm, block(width: 18.5cm, height: 19.6cm, back-cover))
    ]

    // image
    place(image("assets/"+insa+"/front-cover2.png", width: 100%))

    // top-left
    place(
      dx: 2.5cm,
      dy: 6.5cm,
      block(
        width: 9.5cm,
        text(size: 18pt, cover-top-left)
      )
    )

    // middle-left
    place(
      dx: 2.5cm,
      dy: 13.7cm,
      block(
        width: 9.5cm,
        height: 14cm,
        align(horizon, text(size: 16pt, cover-middle-left))
      )
    )

    // bottom-right
    place(
      dx: 12.3cm,
      dy: 25.5cm,
      box(
        width: 7.5cm,
        text(size: 20pt, cover-bottom-right)
      )
    )

  } else {
    panic("Unknown cover-type: only 'light', 'colored' and 'pfe' available.")
  }

  
  counter(page).update(0)
  set page(
    "a4",
    margin: (x: 1.75cm, y: 2.5cm),
    footer: context {
      place(
        right + bottom,
        dx: page.margin.at("right") - 0.6cm,
        dy: -0.6cm,
        box(width: 2.34cm, height: 2.34cm, image("assets/footer.png"))
      )
      if insa-page-numbering-state.get() {
        place(
          right + bottom,
          dx: page.margin.at("right") - 0.6cm,
          dy: -0.6cm,
          box(width: 1.15cm, height: 1.15cm, align(center + horizon, text(fill: white, size: 14pt, font: insa-heading-fonts, weight: "bold", counter(page).display())))
        )
      }
      page-footer
    },
    header: {
      if page-header == none {
        image("assets/"+insa+"/logo.png", width: 4.68cm)
      } else if page-header != [] {
        page-header
        line(length: 100%)
      }
    }
  )
  show heading: set text(font: insa-heading-fonts, weight: "bold")
  set text(font: insa-body-fonts, weight: "regular")
  set par(justify: true, first-line-indent: (amount: 1em, all: true))
  set figure(numbering: "1")
  set outline(indent: auto)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure(supplement: "Figure") // par défaut, Typst affiche "Fig."
  show figure.caption: it => [
    #strong[#it.supplement #context it.counter.display(it.numbering)] : #it.body
  ]
  
  doc

  if (include-back-cover) {
    back-page
  }
}


// REPORT DOCUMENT:

#let insa-report(
  id: 1,
  pre-title: none,
  title : none,
  authors: [],
  date: none,
  insa: "rennes",
  lang: "fr",
  doc,
) = insa-document(
  "light",
  cover-middle-left: authors,
  cover-top-left: [
    #set text(size: 28pt, weight: "bold")
    #if pre-title != none [
      #pre-title #sym.hyph
    ]
    TP #id\
    #set text(size: 22pt, weight: "medium")
    #smallcaps(title)
  ],
  page-header: [
    TP #id #sym.hyph #smallcaps(title)
    #h(1fr)
    #if type(date) == datetime {
      date.display("[day]/[month]/[year]")
     } else {
      date
     }
  ],
  include-back-cover: false,
  lang: lang,
  insa: insa,
  metadata-title: title,
  metadata-date: if type(date) == datetime {date} else {auto},
  {
    set math.equation(numbering: "(1)")
    set text(hyphenate: false)
    set heading(numbering: "I.1.")
    show heading.where(level: 1): it => {
      set text(18pt)
      upper(it)
      // Do not use the `smallcaps` function until Typst implements a fallback in the case the font does not provide smcp capability.
    }
    show raw.where(block: true): it => block(stroke: 0.5pt + black, inset: 5pt, width: 100%, it)
    show raw.line: it => if it.count > 1{
      text(fill: luma(150), str(it.number)) + h(2em) + it.body
    } else {it}
    doc
  }
)


// STAGE DOCUMENT:

#let insa-stage(
  name,
  department,
  year,
  title,
  company,
  company-logo,
  company-tutor,
  gendered-company-tutor: "Maître",
  insa-tutor,
  insa-tutor-suffix: "",
  summary-french,
  summary-english,
  student-suffix: "",
  thanks-page: none,
  omit-outline: false, // can be used to have more control over how the outline is shown
  insa: "rennes",
  lang: "fr",
  doc
) = {
  let insa-stage-translations = (
    title: ("fr": "Stage présenté par", "en": "Internship presented by"),
    student: ("fr": "Élève-ingénieur{gender-suffix} de l'INSA {insa}", "en": "INSA {insa} Engineering Student"),
    department: ("fr": "Spécialité {department}", "en": "Department {department}"),
    location: ("fr": "Lieu du Stage", "en": "Stage Location"),
    company-tutor: ("fr": "{gendered-company-tutor} de Stage", "en": "Training supervisor"),
    insa-tutor: ("fr": "Correspondant{gender-suffix} pédagogique INSA", "en": "Academic supervisor (INSA)"),
    thanks-heading: ("fr": "Remerciements", "en": "Special Thanks")
  )
  let insa-stage-translate(key, lang, placeholders: (:)) = insa-translate(insa-stage-translations, key, lang, placeholders: placeholders)
  
  return insa-document(
    "pfe",
    cover-top-left: [
      #text(size: 16.5pt, font: insa-body-fonts, insa-stage-translate("title", lang))\
      #text(size: 21pt, font: insa-heading-fonts, weight: "bold", name)\
      #text(size: 16.5pt, font: insa-body-fonts)[
        #insa-stage-translate("student", lang, placeholders: ("gender-suffix": student-suffix, "insa": insa-school-name(insa)))\
        #insa-stage-translate("department", lang, placeholders: ("department": department))\
        #year
      ]
    ],
    cover-middle-left: [
      #text(size: 17pt, upper(title))

      #set text(size: 15pt, font: insa-body-fonts)
      *#insa-stage-translate("location", lang)*\
      #company

      *#insa-stage-translate("company-tutor", lang, placeholders: ("gendered-company-tutor": gendered-company-tutor))*\
      #company-tutor

      *#insa-stage-translate("insa-tutor", lang, placeholders: ("gender-suffix": insa-tutor-suffix))*\
      #insa-tutor
    ],
    cover-bottom-right: company-logo,
    insa : insa,
    page-header: [],
    back-cover: {
      set text(font: insa-body-fonts, size: 14pt)
      place(dx: -.2cm, dy: 3.5cm, block(width: 8.9cm, height: 16cm, summary-french))
      place(dx: 9.2cm, block(width: 9.3cm, height: 16cm, inset: 0.2cm, summary-english))
    },
    lang: lang,
    metadata-title: title,
    metadata-authors: (name,),
    {
      insa-hide-page-counter()
      set heading(numbering: "1.1    ")
      show heading.where(level: 1): it => text(size: 18pt, upper(it))
      show heading.where(level: 2): set text(size: 16pt)
      show heading.where(level: 3): set text(size: 15pt)
      show heading.where(level: 4): set text(size: 14pt)
      
      if thanks-page != none and thanks-page != [] {
        heading(insa-stage-translate("thanks-heading", lang), numbering: none, outlined: false)
        thanks-page
        pagebreak()
      }

      if not omit-outline {
        show outline: set heading(outlined: false)
        outline()
        pagebreak()
      }
      insa-show-page-counter(current-page: 1)
      doc
    }
  )
}


// PFE DOCUMENT:

#let insa-pfe(
  name,
  department,
  year,
  title,
  company,
  company-logo,
  company-tutor,
  gendered-company-tutor: "Tuteur",
  insa-tutor,
  insa-tutor-suffix: "",
  summary-french,
  summary-english,
  student-suffix: "",
  defense-date: "TO BE FILLED",
  thanks-page: none,
  omit-outline: false, // can be used to have more control over how the outline is shown
  insa: "rennes",
  lang: "fr",
  doc
) = {
  let insa-pfe-translations = (
    title: ("fr": "Projet de fin d'études présenté par", "en": "End-of-study project presented by"),
    student: ("fr": "Élève-ingénieur{gender-suffix} de l'INSA {insa}", "en": "INSA {insa} Engineering Student"),
    department: ("fr": "Spécialité {department}", "en": "Department {department}"),
    location: ("fr": "Lieu du Projet de Fin d'Études", "en": "End-of-Study Location"),
    company-tutor: ("fr": "{gendered-tutor} du Projet de Fin d'Études", "en": "Training supervisor"),
    insa-tutor: ("fr": "Correspondant{gender-suffix} pédagogique INSA", "en": "Academic supervisor (INSA)"),
    defense-date: ("fr": "PFE soutenu le {date}", "en": "EOS project defense on the {date}"),
    thanks-heading: ("fr": "Remerciements", "en": "Special Thanks")
  )
  let insa-stage-translate(key, lang, placeholders: (:)) = insa-translate(insa-pfe-translations, key, lang, placeholders: placeholders)

  let insa-pfe-autorisation(
    name,
    department,
    title,
    company,
    company-tutor,
    insa-tutor,
    insa
  ) = [
    #set heading(numbering: none, outlined: false)
    #set par(first-line-indent: 0em)
    = Autorisation de diffusion et d'archivage du rapport

    #v(1fr)

    *NOM et Prénom de l'auteur :* #name

    *Spécialité :* #department

    *Titre du projet :* #title

    *Nom de l'entreprise :* #company

    *NOM et Prénom du tuteur du Projet de Fin d'Études :* #company-tutor

    *NOM et Prénom du correspondant pédagogique INSA :* #insa-tutor

    #v(1fr)

    == Archivage du rapport de PFE

    A l'issue de son stage, l'étudiant(e) stagiaire rédigera un rapport qui devra être communiqué aussi bien à l'organisme d'accueil qu'à l'établissement d'enseignement supérieur pour évaluation.
    
    Par obligation réglementaire (instruction 2005-003 parue au B.O du 16 juin 2005), l'INSA #insa-school-name(insa) est tenu de conserver pour archive une version du rapport de PFE. Tout rapport de PFE sera donc systématiquement archivé par le département de l'auteur de l'INSA de Rennes.

    Si le rapport contient des données confidentielles, une version expurgée pourra être archivée à la place de la version intégrale.
    
    #sym.ballot archivage de la version intégrale

    #sym.ballot archivage de la version expurgée, merci de justifier :

    #v(1fr)

    #pagebreak()
    == Diffusion du rapport de PFE
    === Autorisation de diffusion par l'entreprise commanditaire
    Nous, soussignés, représentant de l'entreprise commanditaire

    Nom :

    Prénom :

    Fonction :

    #sym.ballot autorisons le signalement et la diffusion du document désigné ci-dessus sur l'intranet du département de l'auteur de l'INSA

    #sym.ballot autorisons uniquement le signalement du document désigné ci-dessus sur l'intranet du département de l'auteur de l'INSA

    #sym.ballot n'autorisons ni le signalement ni la diffusion du document désigné ci-dessus sur l'intranet du département de l'auteur de l'INSA et demandons la confidentialité (5 ans maximum), jusqu'à la date suivante (mois/année) :

    Fait à #h(8em), le

    Signature et/ou cachet de l'entreprise commanditaire :
    #v(2em)

    === Autorisation de diffusion par l'auteur

    Je soussigné(e),

    Nom :

    Prénom :

    #sym.ballot autorise le signalement et la diffusion du document désigné ci-dessus sur l'intranet du département de l'auteur de l'INSA

    #sym.ballot autorise uniquement le signalement du document désigné ci-dessus sur l'intranet du département de l'auteur de l'INSA

    #sym.ballot n'autorise ni le signalement ni la diffusion du document désigné ci-dessus sur l'intranet du département de l'auteur de l'INSA

    Fait à #h(8em), le

    Signature :
    #v(2em)

    === Autorisation de diffusion par le correspondant pédagogique de l'INSA
    Par défaut, le correspondant pédagogique, membre de l'équipe enseignante, est supposé avoir une contribution mineure sur le rapport et ne pas s'opposer à sa diffusion. Merci de contacter le responsable des stages du département en cas d'opposition.
    #pagebreak()
  ]

  return insa-document(
    "pfe",
    cover-top-left: [
      #text(size: 16.5pt, font: insa-body-fonts, insa-stage-translate("title", lang))\
      #text(size: 21pt, font: insa-heading-fonts, weight: "bold", name)\
      #text(size: 16.5pt, font: insa-body-fonts)[
        #insa-stage-translate("student", lang, placeholders: ("gender-suffix": student-suffix, "insa": insa-school-name(insa)))\
        #insa-stage-translate("department", lang, placeholders: ("department": department))\
        #year
      ]
    ],
    cover-middle-left: [
      #text(size: 17pt, upper(title))

      #set text(size: 15pt, font: insa-body-fonts)
      *#insa-stage-translate("location", lang)*\
      #company

      *#insa-stage-translate("company-tutor", lang, placeholders: ("gendered-tutor": gendered-company-tutor))*\
      #company-tutor

      *#insa-stage-translate("insa-tutor", lang, placeholders: ("gender-suffix": insa-tutor-suffix))*\
      #insa-tutor

      #insa-stage-translate("defense-date", lang, placeholders: ("date": defense-date))
    ],
    cover-bottom-right: company-logo,
    insa : insa,
    page-header: [],
    back-cover: {
      set text(font: insa-body-fonts, size: 14pt)
      place(dx: -.2cm, dy: 3.5cm, block(width: 8.9cm, height: 16cm, summary-french))
      place(dx: 9.2cm, block(width: 9.3cm, height: 16cm, inset: 0.2cm, summary-english))
    },
    lang: lang,
    metadata-title: title,
    metadata-authors: (name,),
    {
      insa-hide-page-counter()
      set heading(numbering: "1.1    ")
      show heading.where(level: 1): it => text(size: 18pt, upper(it))
      show heading.where(level: 2): set text(size: 16pt)
      show heading.where(level: 3): set text(size: 15pt)
      show heading.where(level: 4): set text(size: 14pt)
      show bibliography: set heading(numbering: none)

      insa-pfe-autorisation(
        name,
        department,
        title,
        company,
        company-tutor,
        insa-tutor,
        insa
      )

      if thanks-page != none and thanks-page != [] {
        heading(insa-stage-translate("thanks-heading", lang), numbering: none, outlined: false)
        thanks-page
        pagebreak()
      }

      if not omit-outline {
        show outline: set heading(outlined: true)
        outline()
        pagebreak()
      }

      insa-show-page-counter(current-page: 1)
      doc
    }
  )
}
