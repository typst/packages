// ECE Paris Typst Reports Template Package
// Package non-officiel pour la rédaction de rapports de TP et de projets à l'ECE Paris

// =============================================================================
// COULEURS DU THÈME
// =============================================================================
#let ece = rgb("#007A7B")
#let gamboge = rgb("#E39B0F")
#let darkpowderblue = rgb("#003399")
#let verylightgray = rgb("#F0F0F0")
#let warning-red = rgb("#D32F2F")

#let logo-ece(width: 5.5cm) = image("assets/images/logo-ece.svg", width: width)


// =============================================================================
// PRESETS DE POLICES
// =============================================================================
#let font-presets = (
  "latex": "New Computer Modern",
  "typst-modern": "Libertinus Serif",
  "modern-sans": ("Helvetica Neue", "Arial"),
  "editorial": ("Charter", "PT Serif", "Times New Roman"),
)
#let polices-presets = font-presets // Alias de compatibilité

// =============================================================================
// FONCTIONS UTILITAIRES DE RÉDACTION
// =============================================================================
#let question(label, body) = [
  #v(0.6em, weak: true)
  #text(fill: ece, weight: "bold")[#label.] #body
  #v(0.4em, weak: true)
]

#let t(num, body) = question("T" + str(num), body)
#let e(num, body) = question("E" + str(num), body)

#let nb(body, prefix: "NB :") = [
  #text(weight: "bold")[#prefix] #body
]

#let note(body, prefix: "Note:") = [
  #text(weight: "bold")[#prefix] #body
]

#let attention(body) = [
  #text(fill: warning-red, weight: "bold")[#body]
]

#let todo(body) = [
  #highlight(fill: rgb("#FFF59D"))[#text(weight: "bold")[#body]]
]

#let callout(
  body,
  title: none,
  type: "info",
  fill: auto,
  stroke: auto,
) = {
  let (default_fill, default_stroke) = if type in ("warning", "avertissement", "warn") {
    (rgb("#FEF8E7"), gamboge)
  } else if type in ("danger", "erreur", "error") {
    (rgb("#FDF0F0"), warning-red)
  } else if type in ("tip", "astuce") {
    (rgb("#EBF0F8"), darkpowderblue)
  } else {
    (rgb("#EBF5F5"), ece)
  }
  let actual_fill = if fill != auto { fill } else { default_fill }
  let actual_stroke = if stroke != auto { stroke } else { default_stroke }
  let title_color = if stroke != auto { stroke } else { default_stroke }

  rect(
    width: 100%,
    fill: actual_fill,
    stroke: 1pt + actual_stroke,
    radius: 4pt,
    inset: 12pt,
  )[
    #if title != none [
      #text(fill: title_color, weight: "bold", size: 1.05em)[#title]
      #v(0.3em)
    ]
    #body
  ]
}

#let note-cadre = callout // Alias de compatibilité

#let table-ece(headers: (), ..args) = {
  let header-row = if headers != () {
    (table.header(..headers.map(h => if type(h) == str { text(weight: "bold")[#h] } else { h })),)
  } else {
    ()
  }
  table(..header-row, ..args)
}
#let ece-table = table-ece
#let tableau-ece = table-ece

#let table-double-entree(
  columns: auto,
  headers: (),
  align: auto,
  inset: 7pt,
  ..cells
) = {
  let cols = if type(columns) == int {
    (1fr,) * columns
  } else if columns == auto {
    if headers != () and type(headers) == array {
      (1.4fr,) + (1fr,) * (headers.len() - 1)
    } else {
      auto
    }
  } else if type(columns) == array {
    columns.map(c => if type(c) in (int, float) { c * 1fr } else { c })
  } else {
    columns
  }

  let header-row = if headers != () {
    (table.header(..headers.map(h => if type(h) == str { text(weight: "bold")[#h] } else { h })),)
  } else {
    ()
  }

  let default-align = (col, row) => if col == 0 { left + horizon } else { center + horizon }

  let stroke-fn = (x, y) => {
    let base = 0.5pt + rgb("#DDDDDD")
    let b = if y == 0 { 1.5pt + ece } else { base }
    let r = if x == 0 { 1.5pt + ece } else { base }
    (top: base, left: base, bottom: b, right: r)
  }

  let fill-fn = (col, row) => {
    if row == 0 or col == 0 {
      rgb("#EBF5F5")
    } else if calc.even(row) {
      rgb("#FAFAFA")
    } else {
      none
    }
  }

  show table.cell.where(x: 0): set text(weight: "bold")

  table(
    columns: cols,
    stroke: stroke-fn,
    fill: fill-fn,
    inset: inset,
    align: if align != auto { align } else { default-align },
    ..header-row,
    ..cells
  )
}
#let tableau-double-entree = table-double-entree
#let table-2entrees = table-double-entree
#let tableau-2entrees = table-double-entree
#let table-matrice = table-double-entree
#let tableau-matrice = table-double-entree

#let table-2col(
  headers: (),
  ratio: (1fr, 2fr),
  align: auto,
  inset: 7pt,
  columns: auto,
  ..cells
) = {
  let cols = if columns != auto {
    columns
  } else if type(ratio) == array {
    ratio.map(r => if type(r) in (int, float) { r * 1fr } else { r })
  } else if ratio == "equal" or ratio == "50/50" {
    (1fr, 1fr)
  } else {
    (1fr, 2fr)
  }
  let header-row = if headers != () {
    (table.header(..headers.map(h => if type(h) == str { text(weight: "bold")[#h] } else { h })),)
  } else {
    ()
  }
  let args = (:)
  if align != auto { args.insert("align", align) }
  table(
    columns: cols,
    inset: inset,
    ..args,
    ..header-row,
    ..cells
  )
}
#let tableau-2col = table-2col
#let table-double-colonne = table-2col
#let tableau-double-colonne = table-2col


#let annexes(body, lang: "fr", title-prefix: auto) = {
  pagebreak()
  counter(heading).update(0)
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  let prefix = if title-prefix != auto {
    title-prefix
  } else if lang == "en" {
    "Appendix "
  } else {
    "Annexe "
  }
  set heading(numbering: (..nums) => {
    let pos = nums.pos()
    if pos.len() == 1 {
      prefix + numbering("A", pos.first()) + " :"
    } else {
      numbering("A.1", ..pos)
    }
  })
  set math.equation(numbering: (..nums) => context {
    let h_count = counter(heading).get().first()
    let letter = numbering("A", calc.max(1, h_count))
    "(" + letter + "." + str(nums.pos().first()) + ")"
  })
  set figure(numbering: (..nums) => context {
    let h_count = counter(heading).get().first()
    let letter = numbering("A", calc.max(1, h_count))
    letter + "." + str(nums.pos().first())
  })
  show heading.where(level: 1): it => {
    it
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)
  }
  body
}
#let appendix = annexes

// =============================================================================
// RACCOURCIS & NOTATIONS D'INGÉNIERIE SCIENTIFIQUE
// =============================================================================
// Résistances & Impédances
#let ohm = $Omega$
#let kohm = $k Omega$
#let mohm = $M Omega$

// Capacités
#let uf = $mu upright("F")$
#let nf = $upright("nF")$
#let pf = $upright("pF")$

// Tensions
#let vpp = $V_("pp")$
#let vrms = $V_("rms")$
#let vdc = $V_("dc")$
#let vac = $V_("ac")$
#let mv = $upright("mV")$
#let uv = $mu upright("V")$

// Courants
#let ma = $upright("mA")$
#let ua = $mu upright("A")$
#let na = $upright("nA")$

// Fréquences
#let hz = $upright("Hz")$
#let khz = $upright("kHz")$
#let mhz = $upright("MHz")$
#let ghz = $upright("GHz")$
#let fcut = $f_0$

// Temps
#let ms = $upright("ms")$
#let us = $mu upright("s")$
#let ns = $upright("ns")$
#let ps = $upright("ps")$

// Puissances & Décibels
#let mw = $upright("mW")$
#let uw = $mu upright("W")$
#let db = $upright("dB")$
#let dbm = $upright("dBm")$

// Température & Notations
#let degc = $degree upright("C")$
#let celsius = $degree upright("C")$

// =============================================================================
// DICTIONNAIRES D'INTERNATIONALISATION (i18n)
// =============================================================================
#let i18n-tp = (
  "fr": (
    type_doc: "RAPPORT DE TP",
    doc_prefix: "TP",
    groupe_prefix: "Groupe",
    default_title: "[Nom du TP]",
    default_date: "JJ/MM/AAAA",
    default_city: "Ville",
    date_connector: ", le ",
    supervisor_prefix: "Sous la direction de : ",
    attestation: "Nous attestons que ce travail est original,\nqu’il est le fruit d’un travail commun au binôme et qu’il a été rédigé de manière autonome.",
    toc_title: "Table des matières",
    supp_figure: [Figure],
    supp_table: [Tableau],
    supp_code: [Code],
    draft_text: "BROUILLON",
  ),
  "en": (
    type_doc: "LABORATORY REPORT",
    doc_prefix: "LAB",
    groupe_prefix: "Group",
    default_title: "[Name of the lab]",
    default_date: "MM/DD/YYYY",
    default_city: "City",
    date_connector: ", ",
    supervisor_prefix: "Supervised by: ",
    attestation: "We certify that this submission is our own original work,\nand meets the Faculty’s Expectation and Originality.",
    toc_title: "Table of Contents",
    supp_figure: [Figure],
    supp_table: [Table],
    supp_code: [Listing],
    draft_text: "DRAFT",
  ),
)

#let i18n-projet = (
  "fr": (
    type_doc: "RAPPORT DE PROJET",
    groupe_prefix: "Groupe",
    default_title: "[Nom du projet]",
    default_date: "JJ/MM/AAAA",
    default_city: "Ville",
    date_connector: ", le ",
    supervisor_prefix: "Sous la direction de : ",
    abstract_title: "RÉSUMÉ",
    default_abstract: [Quel est le contexte et la problématique du projet ? Quels sont les objectifs techniques ? Dans quel contexte faites-vous ce projet ? [maximum 20 lignes]],
    attestation: "Nous attestons que ce travail est original,\nqu’il est le fruit d’un travail commun au binôme et qu’il a été rédigé de manière autonome.",
    toc_title: "Table des matières",
    tof_title: "Liste des figures",
    tot_title: "Liste des tableaux",
    supp_figure: [Figure],
    supp_table: [Tableau],
    supp_code: [Code],
    draft_text: "BROUILLON",
  ),
  "en": (
    type_doc: "PROJECT REPORT",
    groupe_prefix: "Group",
    default_title: "[Project Name]",
    default_date: "MM/DD/YYYY",
    default_city: "City",
    date_connector: ", ",
    supervisor_prefix: "Supervised by: ",
    abstract_title: "ABSTRACT",
    default_abstract: [What is the context and problem statement of the project? What are the technical objectives? In what context are you carrying out this project? [maximum 20 lines]],
    attestation: "We certify that this submission is our own original work,\nand meets the Faculty’s Expectation and Originality.",
    toc_title: "Table of Contents",
    tof_title: "List of Figures",
    tot_title: "List of Tables",
    supp_figure: [Figure],
    supp_table: [Table],
    supp_code: [Listing],
    draft_text: "DRAFT",
  ),
)

// =============================================================================
// GESTION DES ASSETS INTERNES
// =============================================================================
#let _render-logo(logo, width: 5.5cm) = {
  if logo == none {
    none
  } else if type(logo) == content {
    logo
  } else if logo == auto {
    image("assets/images/logo-ece.svg", width: width)
  } else if type(logo) == str {
    image(logo, width: width)
  } else {
    logo
  }
}

#let _render-cover(cover) = {
  if cover == none {
    none
  } else if type(cover) == content {
    cover
  } else if cover == auto {
    image("assets/images/elec.png", width: 100%)
  } else if type(cover) == str {
    image(cover, width: 100%)
  } else {
    cover
  }
}

// =============================================================================
// MODÈLE 1 : RAPPORT DE TP / LABORATORY REPORT
// =============================================================================
#let tp(
  title: none,
  tp-num: "[X]",
  promo: "ING[X]",
  major: none,
  majeure: none,
  groupe: none,
  authors: ("André-Marie AMPÈRE", "Alessandro VOLTA"),
  supervisor: none,
  tuteur: none,
  enseignant: none,
  date: auto,
  city: none,
  logo: auto,
  cover-image: auto,
  attestation: auto,
  type-doc: none,
  doc-prefix: none,
  table-of-contents: false,
  toc-depth: 3,
  draft: false,
  show-roles: true,
  show-role: true,
  show-emails: true,
  show-email: true,
  show-supervisor-email: auto,
  equation-numbering: none,
  font: "New Computer Modern",
  font-size: 11pt,
  lang: "fr",
  body
) = {
  let dict = i18n-tp.at(lang, default: i18n-tp.at("fr"))
  
  let actual_show_roles = if show-roles != true { show-roles } else { show-role }
  let actual_show_emails = if show-emails != true { show-emails } else { show-email }
  let actual_show_sup_email = if show-supervisor-email != auto { show-supervisor-email } else { actual_show_emails }
  let actual_title = if title != none { title } else { dict.default_title }
  let actual_type_doc = if type-doc != none { type-doc } else { dict.type_doc }
  let actual_doc_prefix = if doc-prefix != none { doc-prefix } else { dict.doc_prefix }
  let actual_major = if major != none { major } else if majeure != none { majeure } else { none }
  let actual_groupe = if groupe != none { groupe } else { dict.groupe_prefix + " [X]" }
  let actual_supervisor = if supervisor != none { supervisor } else if tuteur != none { tuteur } else if enseignant != none { enseignant } else { none }
  let actual_date = if date == auto {
    if lang == "fr" {
      datetime.today().display("[day]/[month]/[year]")
    } else {
      datetime.today().display("[month]/[day]/[year]")
    }
  } else if date != none {
    date
  } else {
    dict.default_date
  }
  let actual_city = if city != none { city } else { dict.default_city }
  let actual_attestation = if attestation == auto { dict.attestation } else if attestation == none or attestation == false { none } else { attestation }

  let author_list = if type(authors) == array {
    authors.map(a => if type(a) == dictionary { a.at("name", default: "") } else { str(a) }).join(", ")
  } else {
    str(authors)
  }
  set document(
    title: actual_doc_prefix + " " + str(tp-num) + " : " + str(actual_title),
    author: author_list,
  )

  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
    background: if draft {
      rotate(
        -45deg,
        text(
          size: 90pt,
          weight: "bold",
          fill: rgb(180, 180, 180, 120),
        )[#dict.draft_text]
      )
    } else {
      none
    },
    header: context {
      let current_page = counter(page).get().first()
      if current_page > 1 {
        let headings = query(heading.where(level: 1))
        let has_h1_on_page = headings.any(h => h.location().page() == current_page)
        let current_heading = headings.rev().find(h => h.location().page() <= current_page)
        let promo_label = if actual_major != none { promo + " – " + actual_major } else { promo }
        grid(
          columns: (auto, 1fr, auto),
          align: (left + horizon, center + horizon, right + horizon),
          _render-logo(logo, width: 2.5cm),
          if not has_h1_on_page and current_heading != none [
            #text(size: 9pt, fill: rgb("#666666"), style: "italic")[
              #current_heading.body
            ]
          ],
          text(size: 9.5pt, weight: "bold", hyphenate: false)[#promo_label #h(0.4em) #actual_groupe],
        )
      }
    },
    footer: context {
      let i = counter(page).get().first()
      let total = counter(page).final().first()
      if i > 1 {
        align(center, text(size: 10pt)[#i / #total])
      }
    }
  )

  set text(
    font: font,
    size: font-size,
    lang: lang,
  )

  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 0pt,
  )

  show link: set text(fill: darkpowderblue)

  if equation-numbering != none {
    set math.equation(numbering: equation-numbering)
  }

  set list(marker: ([#text(fill: ece, size: 0.9em)[•]], [--]))

  show raw.where(block: true): it => block(
    fill: rgb("#F8F9FA"),
    inset: (x: 18pt, y: 14pt),
    radius: 6pt,
    width: 100%,
    stroke: 0.8pt + rgb("#D0D7DE"),
    above: 1.2em,
    below: 1.2em,
    align(left, it),
  )
  show raw.where(block: false): it => box(
    fill: rgb("#F1F3F5"),
    inset: (x: 4pt, y: 0pt),
    outset: (y: 2.5pt),
    radius: 3pt,
    it,
  )
  show figure.where(kind: raw): it => pad(x: -1cm, block(width: 100%, it))

  show outline: it => {
    show link: set text(fill: black)
    it
  }

  set bibliography(style: "ieee")
  show figure: set block(above: 1.5em, below: 1.5em)
  set figure(gap: 0.85em)
  show figure.where(kind: table): set figure(supplement: dict.supp_table)
  show figure.where(kind: raw): set figure(supplement: dict.supp_code)
  show figure.where(kind: image): set figure(supplement: dict.supp_figure)
  show figure.caption: it => [
    #text(weight: "bold")[#it.supplement #context { it.counter.display(it.numbering) }] – #it.body
  ]

  set table(
    stroke: (x, y) => if y == 0 { (bottom: 1.5pt + ece) } else { 0.5pt + rgb("#DDDDDD") },
    fill: (col, row) => if row == 0 { rgb("#EBF5F5") } else if calc.even(row) { rgb("#FAFAFA") } else { none },
    inset: 7pt,
    align: horizon,
  )
  show table.cell.where(y: 0): set text(weight: "bold")

  set heading(numbering: (..nums) => {
    let pos = nums.pos()
    if pos.len() == 1 {
      numbering("I.", pos.last())
    } else if pos.len() == 2 {
      numbering("A.", pos.last())
    } else if pos.len() == 3 {
      numbering("(a)", pos.last())
    }
  })

  show heading.where(level: 1): it => {
    set text(size: 18pt, fill: ece, weight: "bold")
    v(1.5em, weak: true)
    it
    v(0.8em, weak: true)
  }

  show heading.where(level: 2): it => {
    set text(size: 16pt, fill: ece, weight: "bold")
    v(1.3em, weak: true)
    it
    v(0.7em, weak: true)
  }

  show heading.where(level: 3): it => {
    set text(size: 15pt, fill: gamboge, weight: "bold")
    v(1.2em, weak: true)
    it
    v(0.7em, weak: true)
  }

  // --- PAGE DE TITRE ---
  {
    grid(
      columns: (1fr, 1fr),
      align: (left + horizon, right + horizon),
      _render-logo(logo, width: 5.5cm),
      align(right)[
        #text(size: 14pt, weight: "bold")[
          #promo #if actual_major != none [ \ #text(size: 11pt, weight: "regular", fill: rgb("#444444"))[#actual_major] ] \
          #actual_groupe
        ]
      ],
    )

    v(1.5cm)
    line(length: 100%, stroke: 1.5pt + black)
    v(0.4cm)

    align(center)[
      #text(size: 13pt, weight: "bold", fill: rgb("#444444"))[#actual_type_doc]
      #v(0.6cm)
      #text(size: 20pt, weight: "bold", fill: ece)[#actual_doc_prefix #tp-num : #actual_title]
    ]

    v(0.4cm)
    line(length: 100%, stroke: 1.5pt + black)
    v(0.8cm)

    if cover-image != none {
      align(center)[
        #_render-cover(cover-image)
      ]
    }

    v(1fr)

    align(center)[
      #if type(authors) == array [
        #grid(
          columns: (1fr,) * authors.len(),
          gutter: 1.5cm,
          align: center,
          ..authors.map(a => {
            if type(a) == dictionary [
              #text(size: 12pt, weight: "bold")[#a.at("name", default: "")]
              #if actual_show_roles and "role" in a and a.role != none and a.role != "" [ \ #text(size: 9pt, style: "italic", fill: rgb("#666666"))[#a.role] ]
              #if actual_show_emails and "email" in a and a.email != none and a.email != "" [ \ #text(size: 9pt, fill: darkpowderblue)[#link("mailto:" + a.email)[#a.email]] ]
            ] else [
              #text(size: 12pt, weight: "bold")[#a]
            ]
          })
        )
      ] else [
        #text(size: 12pt, weight: "bold")[#authors]
      ]

      #if actual_supervisor != none [
        #v(0.3cm)
        #if type(actual_supervisor) == dictionary [
          #let s_name = actual_supervisor.at("name", default: "")
          #let s_email = actual_supervisor.at("email", default: none)
          #text(size: 11pt, style: "italic")[#dict.supervisor_prefix#s_name]
          #if actual_show_sup_email and s_email != none and s_email != "" [
            \ #text(size: 9pt, fill: darkpowderblue)[#link("mailto:" + s_email)[#s_email]]
          ]
        ] else [
          #text(size: 11pt, style: "italic")[#dict.supervisor_prefix#actual_supervisor]
        ]
      ]

      #v(0.8cm)

      #if actual_attestation != none [
        #text(size: 9.5pt, fill: rgb("#333333"))[#actual_attestation]
        #v(0.3cm)
      ]
      #text(size: 11pt, weight: "bold")[#actual_city#dict.date_connector#actual_date]
    ]
  }

  pagebreak()

  if table-of-contents {
    outline(
      title: dict.toc_title,
      depth: toc-depth,
      indent: 1.5em,
    )
    pagebreak()
  }

  body
}

// =============================================================================
// MODÈLE 2 : RAPPORT DE PROJET / PROJECT REPORT
// =============================================================================
#let projet(
  title: none,
  promo: "ING[X]",
  major: none,
  majeure: none,
  groupe: none,
  authors: ("André-Marie AMPÈRE", "Alessandro VOLTA"),
  supervisor: none,
  tuteur: none,
  enseignant: none,
  date: auto,
  city: none,
  logo: auto,
  abstract: none,
  attestation: auto,
  type-doc: none,
  table-of-contents: true,
  table-of-figures: false,
  table-of-tables: false,
  same-page-figures-tables: true,
  group-figures-tables: true,
  same-page-toc: false,
  group-outlines: false,
  toc-depth: 3,
  draft: false,
  show-roles: true,
  show-role: true,
  show-emails: true,
  show-email: true,
  show-supervisor-email: auto,
  numbering-format: "1.1",
  equation-numbering: none,
  font: "New Computer Modern",
  font-size: 11pt,
  lang: "fr",
  body
) = {
  let dict = i18n-projet.at(lang, default: i18n-projet.at("fr"))
  
  let actual_show_roles = if show-roles != true { show-roles } else { show-role }
  let actual_show_emails = if show-emails != true { show-emails } else { show-email }
  let actual_show_sup_email = if show-supervisor-email != auto { show-supervisor-email } else { actual_show_emails }
  let actual_group_fig_tab = if same-page-figures-tables != true { same-page-figures-tables } else { group-figures-tables }
  let actual_same_page_toc = if same-page-toc != false { same-page-toc } else { group-outlines }
  let actual_title = if title != none { title } else { dict.default_title }
  let actual_type_doc = if type-doc != none { type-doc } else { dict.type_doc }
  let actual_major = if major != none { major } else if majeure != none { majeure } else { none }
  let actual_groupe = if groupe != none { groupe } else { dict.groupe_prefix + " [X]" }
  let actual_supervisor = if supervisor != none { supervisor } else if tuteur != none { tuteur } else if enseignant != none { enseignant } else { none }
  let actual_date = if date == auto {
    if lang == "fr" {
      datetime.today().display("[day]/[month]/[year]")
    } else {
      datetime.today().display("[month]/[day]/[year]")
    }
  } else if date != none {
    date
  } else {
    dict.default_date
  }
  let actual_city = if city != none { city } else { dict.default_city }
  let actual_abstract = if abstract != none { abstract } else { dict.default_abstract }
  let actual_attestation = if attestation == auto { dict.attestation } else if attestation == none or attestation == false { none } else { attestation }

  let author_list = if type(authors) == array {
    authors.map(a => if type(a) == dictionary { a.at("name", default: "") } else { str(a) }).join(", ")
  } else {
    str(authors)
  }
  set document(
    title: actual_type_doc + " : " + str(actual_title),
    author: author_list,
  )

  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
    background: if draft {
      rotate(
        -45deg,
        text(
          size: 90pt,
          weight: "bold",
          fill: rgb(180, 180, 180, 120),
        )[#dict.draft_text]
      )
    } else {
      none
    },
    header: context {
      let current_page = counter(page).get().first()
      if current_page > 1 {
        let headings = query(heading.where(level: 1))
        let has_h1_on_page = headings.any(h => h.location().page() == current_page)
        let current_heading = headings.rev().find(h => h.location().page() <= current_page)
        let promo_label = if actual_major != none { promo + " – " + actual_major } else { promo }
        grid(
          columns: (auto, 1fr, auto),
          align: (left + horizon, center + horizon, right + horizon),
          _render-logo(logo, width: 2.5cm),
          if not has_h1_on_page and current_heading != none [
            #text(size: 9pt, fill: rgb("#666666"), style: "italic")[
              #current_heading.body
            ]
          ],
          text(size: 9.5pt, weight: "bold", hyphenate: false)[#promo_label #h(0.4em) #actual_groupe],
        )
      }
    },
    footer: context {
      let i = counter(page).get().first()
      let total = counter(page).final().first()
      if i > 1 {
        align(center, text(size: 10pt)[#i / #total])
      }
    }
  )

  set text(
    font: font,
    size: font-size,
    lang: lang,
  )

  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 0pt,
  )

  show link: set text(fill: darkpowderblue)

  if equation-numbering != none {
    set math.equation(numbering: equation-numbering)
  }

  set list(marker: ([#text(fill: ece, size: 0.9em)[•]], [--]))

  show raw.where(block: true): it => block(
    fill: rgb("#F8F9FA"),
    inset: (x: 18pt, y: 14pt),
    radius: 6pt,
    width: 100%,
    stroke: 0.8pt + rgb("#D0D7DE"),
    above: 1.2em,
    below: 1.2em,
    align(left, it),
  )
  show raw.where(block: false): it => box(
    fill: rgb("#F1F3F5"),
    inset: (x: 4pt, y: 0pt),
    outset: (y: 2.5pt),
    radius: 3pt,
    it,
  )
  show figure.where(kind: raw): it => pad(x: -1cm, block(width: 100%, it))

  show outline: it => {
    show link: set text(fill: black)
    it
  }

  set bibliography(style: "ieee")
  show figure: set block(above: 1.5em, below: 1.5em)
  set figure(gap: 0.85em)
  show figure.where(kind: table): set figure(supplement: dict.supp_table)
  show figure.where(kind: raw): set figure(supplement: dict.supp_code)
  show figure.where(kind: image): set figure(supplement: dict.supp_figure)
  show figure.caption: it => [
    #text(weight: "bold")[#it.supplement #context { it.counter.display(it.numbering) }] – #it.body
  ]

  set table(
    stroke: (x, y) => if y == 0 { (bottom: 1.5pt + ece) } else { 0.5pt + rgb("#DDDDDD") },
    fill: (col, row) => if row == 0 { rgb("#EBF5F5") } else if calc.even(row) { rgb("#FAFAFA") } else { none },
    inset: 7pt,
    align: horizon,
  )
  show table.cell.where(y: 0): set text(weight: "bold")

  set heading(numbering: numbering-format)

  show heading.where(level: 1): it => {
    set text(size: 18pt, fill: ece, weight: "bold")
    v(1.5em, weak: true)
    it
    v(0.8em, weak: true)
  }

  show heading.where(level: 2): it => {
    set text(size: 14pt, fill: ece, weight: "bold")
    v(1.3em, weak: true)
    it
    v(0.7em, weak: true)
  }

  show heading.where(level: 3): it => {
    set text(size: 12pt, fill: gamboge, weight: "bold")
    v(1.2em, weak: true)
    it
    v(0.7em, weak: true)
  }

  // --- PAGE DE TITRE ---
  {
    grid(
      columns: (1fr, 1fr),
      align: (left + horizon, right + horizon),
      _render-logo(logo, width: 5.5cm),
      align(right)[
        #text(size: 14pt, weight: "bold")[
          #promo #if actual_major != none [ \ #text(size: 11pt, weight: "regular", fill: rgb("#444444"))[#actual_major] ] \
          #actual_groupe
        ]
      ],
    )

    v(1.5cm)
    line(length: 100%, stroke: 1.5pt + black)
    v(0.4cm)

    align(center)[
      #text(size: 13pt, weight: "bold", fill: rgb("#444444"))[#actual_type_doc]
      #v(0.6cm)
      #text(size: 22pt, weight: "bold", fill: ece)[#actual_title]
    ]

    v(0.4cm)
    line(length: 100%, stroke: 1.5pt + black)

    if actual_abstract != none {
      v(1cm)
      pad(x: -1cm)[
        #rect(
          fill: verylightgray,
          stroke: none,
          width: 100%,
          inset: (x: 24pt, y: 16pt),
          radius: 4pt,
        )[
          #align(left)[
            #text(weight: "bold")[#dict.abstract_title] -- #actual_abstract
          ]
        ]
      ]
    }

    v(1fr)

    align(center)[
      #if type(authors) == array [
        #grid(
          columns: (1fr,) * authors.len(),
          gutter: 1.5cm,
          align: center,
          ..authors.map(a => {
            if type(a) == dictionary [
              #text(size: 12pt, weight: "bold")[#a.at("name", default: "")]
              #if actual_show_roles and "role" in a and a.role != none and a.role != "" [ \ #text(size: 9pt, style: "italic", fill: rgb("#666666"))[#a.role] ]
              #if actual_show_emails and "email" in a and a.email != none and a.email != "" [ \ #text(size: 9pt, fill: darkpowderblue)[#link("mailto:" + a.email)[#a.email]] ]
            ] else [
              #text(size: 12pt, weight: "bold")[#a]
            ]
          })
        )
      ] else [
        #text(size: 12pt, weight: "bold")[#authors]
      ]

      #if actual_supervisor != none [
        #v(0.3cm)
        #if type(actual_supervisor) == dictionary [
          #let s_name = actual_supervisor.at("name", default: "")
          #let s_email = actual_supervisor.at("email", default: none)
          #text(size: 11pt, style: "italic")[#dict.supervisor_prefix#s_name]
          #if actual_show_sup_email and s_email != none and s_email != "" [
            \ #text(size: 9pt, fill: darkpowderblue)[#link("mailto:" + s_email)[#s_email]]
          ]
        ] else [
          #text(size: 11pt, style: "italic")[#dict.supervisor_prefix#actual_supervisor]
        ]
      ]

      #v(0.8cm)

      #if actual_attestation != none [
        #text(size: 9.5pt, fill: rgb("#333333"))[#actual_attestation]
        #v(0.3cm)
      ]
      #text(size: 11pt, weight: "bold")[#actual_city#dict.date_connector#actual_date]
    ]
  }

  pagebreak()

  if table-of-contents {
    outline(
      title: dict.toc_title,
      depth: toc-depth,
      indent: 1.5em,
    )
    if (table-of-figures or table-of-tables) and actual_same_page_toc {
      v(1.5cm)
    } else {
      pagebreak()
    }
  }

  if table-of-figures or table-of-tables {
    if table-of-figures {
      outline(
        title: dict.tof_title,
        target: figure.where(kind: image),
      )
      if table-of-tables {
        if actual_group_fig_tab {
          v(1.5cm)
        } else {
          pagebreak()
        }
      }
    }

    if table-of-tables {
      outline(
        title: dict.tot_title,
        target: figure.where(kind: table),
      )
    }
    pagebreak()
  }

  body
}

// =============================================================================
// ALIASES DE COMPATIBILITÉ
// =============================================================================
#let conf-tp = tp
#let conf-projet = projet
#let conf = tp
#let rapport-tp = tp
#let lab-report = tp
#let rapport-projet = projet
#let project-report = projet

