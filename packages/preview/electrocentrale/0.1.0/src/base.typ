// Moteur de base commun à tous les modèles de rapport ECE Paris (TP, Projet, Stage)

#import "theme.typ": *
#import "utils.typ": *
#import "i18n.typ": *

// En-tête standard de page de garde (Logo ECE + Promotion / Majeure / Groupe)
#let cover-header(ctx) = {
  grid(
    columns: (1fr, 1fr),
    align: (left + horizon, right + horizon),
    _render-logo(ctx.logo, width: 5.5cm),
    align(right)[
      #text(size: 14pt, weight: "bold")[
        #ctx.promo #if ctx.major != none [ \ #text(size: 11pt, weight: "regular", fill: rgb("#444444"))[#ctx.major] ] \
        #ctx.groupe
      ]
    ],
  )
  v(1.5cm)
  line(length: 100%, stroke: 1.5pt + black)
  v(0.4cm)
}

// Bas de page standard de page de garde (Auteurs, Tuteur, Attestation d'intégrité, Date)
#let cover-footer(ctx) = {
  v(1fr)

  align(center)[
    #if type(ctx.authors) == array [
      #grid(
        columns: (1fr,) * ctx.authors.len(),
        gutter: 1.5cm,
        align: center,
        ..ctx.authors.map(a => {
          if type(a) == dictionary [
            #text(size: 12pt, weight: "bold")[#a.at("name", default: "")]
            #if ctx.show-roles and "role" in a and a.role != none and a.role != "" [ \ #text(size: 9pt, style: "italic", fill: rgb("#666666"))[#a.role] ]
            #if ctx.show-emails and "email" in a and a.email != none and a.email != "" [ \ #text(size: 9pt, fill: darkpowderblue)[#link("mailto:" + a.email)[#a.email]] ]
          ] else [
            #text(size: 12pt, weight: "bold")[#a]
          ]
        })
      )
    ] else [
      #text(size: 12pt, weight: "bold")[#ctx.authors]
    ]

    #if ctx.supervisor != none [
      #v(0.3cm)
      #if type(ctx.supervisor) == dictionary [
        #let s_name = ctx.supervisor.at("name", default: "")
        #let s_email = ctx.supervisor.at("email", default: none)
        #text(size: 11pt, style: "italic")[#ctx.dict.supervisor_prefix#s_name]
        #if ctx.show-supervisor-email and s_email != none and s_email != "" [
          \ #text(size: 9pt, fill: darkpowderblue)[#link("mailto:" + s_email)[#s_email]]
        ]
      ] else [
        #text(size: 11pt, style: "italic")[#ctx.dict.supervisor_prefix#ctx.supervisor]
      ]
    ]

    #v(0.8cm)

    #if ctx.attestation != none [
      #text(size: 9.5pt, fill: rgb("#333333"))[#ctx.attestation]
      #v(0.3cm)
    ]
    #text(size: 11pt, weight: "bold")[#ctx.city#ctx.dict.date_connector#ctx.date]
  ]
}

// Moteur de mise en page mutualisé pour l'ensemble des rapports ECE
#let base-report(
  // Métadonnées & Identification
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
  cover-image: none,
  attestation: auto,
  type-doc: none,
  doc-prefix: none,
  tp-num: none,
  abstract: none,

  // Visibilité & Options d'affichage
  show-roles: true,
  show-role: true,
  show-emails: true,
  show-email: true,
  show-supervisor-email: auto,
  show-header: true,
  header: auto,
  show-footer: true,
  footer: auto,
  draft: false,

  // Sommaires et listes
  table-of-contents: false,
  table-of-figures: false,
  table-of-tables: false,
  same-page-figures-tables: true,
  group-figures-tables: true,
  same-page-toc: false,
  group-outlines: false,
  toc-depth: 3,

  // Typographie & Numérotation
  font: "New Computer Modern",
  font-size: 11pt,
  leading: 0.65em,
  lang: "fr",
  numbering-format: auto,
  equation-numbering: none,
  heading-sizes: (18pt, 14pt, 12pt),

  // Configuration interne du modèle
  dict: none,
  cover: none,

  ..sink,
  body
) = {
  // Sélection du dictionnaire i18n
  let actual_dict = if type(dict) == dictionary {
    if lang in dict { dict.at(lang) } else { dict.at("fr", default: dict) }
  } else {
    i18n-tp.at(lang, default: i18n-tp.at("fr"))
  }

  // Normalisation des paramètres
  let actual_show_roles = if show-roles != true { show-roles } else { show-role }
  let actual_show_emails = if show-emails != true { show-emails } else { show-email }
  let actual_show_sup_email = if show-supervisor-email != auto { show-supervisor-email } else { actual_show_emails }
  let actual_group_fig_tab = if same-page-figures-tables != true { same-page-figures-tables } else { group-figures-tables }
  let actual_same_page_toc = if same-page-toc != false { same-page-toc } else { group-outlines }
  let actual_title = if title != none { title } else { actual_dict.default_title }
  let actual_type_doc = if type-doc != none { type-doc } else { actual_dict.type_doc }
  let actual_doc_prefix = if doc-prefix != none { doc-prefix } else { actual_dict.at("doc_prefix", default: "") }
  let actual_tp_num = if tp-num != none { str(tp-num) } else { "" }
  let actual_major = if major != none { major } else if majeure != none { majeure } else { none }
  let actual_groupe = if groupe != none { groupe } else { actual_dict.groupe_prefix + " [X]" }
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
    actual_dict.default_date
  }
  let actual_city = if city != none { city } else { actual_dict.default_city }
  let actual_attestation = if attestation == auto { actual_dict.attestation } else if attestation == none or attestation == false { none } else { attestation }

  // Métadonnées du document PDF
  let author_list = if type(authors) == array {
    authors.map(a => if type(a) == dictionary { a.at("name", default: "") } else { str(a) }).join(", ")
  } else {
    str(authors)
  }
  let doc_title = if actual_tp_num != "" and actual_doc_prefix != "" {
    actual_doc_prefix + " " + actual_tp_num + " : " + str(actual_title)
  } else if actual_type_doc != "" {
    actual_type_doc + " : " + str(actual_title)
  } else {
    str(actual_title)
  }
  set document(
    title: doc_title,
    author: author_list,
  )

  // Configuration de la page
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
        )[#actual_dict.draft_text]
      )
    } else {
      none
    },
    header: if not show-header or header == none {
      none
    } else if header != auto {
      header
    } else {
      context {
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
      }
    },
    footer: if not show-footer or footer == none {
      none
    } else if footer != auto {
      footer
    } else {
      context {
        let i = counter(page).get().first()
        let total = counter(page).final().first()
        if i > 1 {
          align(center, text(size: 10pt)[#i / #total])
        }
      }
    }
  )

  // Typographie générale
  set text(
    font: font,
    size: font-size,
    lang: lang,
  )

  set par(
    justify: true,
    leading: leading,
    first-line-indent: 0pt,
  )

  show link: set text(fill: darkpowderblue)

  if equation-numbering != none {
    set math.equation(numbering: equation-numbering)
  }

  set list(marker: ([#text(fill: ece, size: 0.9em)[•]], [--]))

  // Code source
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

  // Figures, tableaux et bibliographie
  set bibliography(style: "ieee")
  show figure: set block(above: 1.5em, below: 1.5em)
  set figure(gap: 0.85em)
  show figure.where(kind: table): set figure(supplement: actual_dict.supp_table)
  show figure.where(kind: raw): set figure(supplement: actual_dict.supp_code)
  show figure.where(kind: image): set figure(supplement: actual_dict.supp_figure)
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

  // Titres de section
  set heading(numbering: (..nums) => {
    let vals = nums.pos()
    if numbering-format == auto {
      if vals.len() == 1 {
        numbering("I.", vals.last())
      } else if vals.len() == 2 {
        numbering("A.", vals.last())
      } else if vals.len() == 3 {
        numbering("(a)", vals.last())
      }
    } else if numbering-format != none {
      numbering(numbering-format, ..nums)
    } else {
      none
    }
  })

  let h1_size = heading-sizes.at(0, default: 18pt)
  let h2_size = heading-sizes.at(1, default: 14pt)
  let h3_size = heading-sizes.at(2, default: 12pt)

  show heading.where(level: 1): it => {
    set text(size: h1_size, fill: ece, weight: "bold")
    v(1.5em, weak: true)
    it
    v(0.8em, weak: true)
  }

  show heading.where(level: 2): it => {
    set text(size: h2_size, fill: ece, weight: "bold")
    v(1.3em, weak: true)
    it
    v(0.7em, weak: true)
  }

  show heading.where(level: 3): it => {
    set text(size: h3_size, fill: gamboge, weight: "bold")
    v(1.2em, weak: true)
    it
    v(0.7em, weak: true)
  }

  // Contexte pour la page de garde
  let ctx = (
    title: actual_title,
    type-doc: actual_type_doc,
    doc-prefix: actual_doc_prefix,
    tp-num: actual_tp_num,
    promo: promo,
    major: actual_major,
    groupe: actual_groupe,
    authors: authors,
    supervisor: actual_supervisor,
    date: actual_date,
    city: actual_city,
    logo: logo,
    cover-image: cover-image,
    abstract: abstract,
    attestation: actual_attestation,
    show-roles: actual_show_roles,
    show-emails: actual_show_emails,
    show-supervisor-email: actual_show_sup_email,
    dict: actual_dict,
    lang: lang,
  )

  // Page de garde
  if cover != none {
    cover(ctx)
  }

  pagebreak()

  // Sommaires et listes
  if table-of-contents {
    outline(
      title: actual_dict.toc_title,
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
        title: actual_dict.tof_title,
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
        title: actual_dict.tot_title,
        target: figure.where(kind: table),
      )
    }
    pagebreak()
  }

  body
}
