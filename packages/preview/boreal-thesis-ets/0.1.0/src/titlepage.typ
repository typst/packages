// ============================================================
// thETS — Page de titre et verso (notice de licence).
// Portage de \maketitle (section 10 de thETS.cls).
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": long-date, tr
#import "state.typ": is-doctorate, is-masters, is-project
#import "blocks.typ": no-folio

#let bl = cfg.baselineskip

// Intitulé du diplôme, selon le type de document, la langue et la
// concentration éventuelle.
#let diploma-text(doc-type, lang, concentration) = {
  let s = tr(lang)
  let conc = if concentration == none { "" } else {
    s.in-field + upper(concentration)
  }
  if is-project(doc-type) {
    s.diploma-project + conc + "\n" + s.diploma-project-suffix
  } else if is-masters(doc-type) {
    s.diploma-masters + conc + "\n" + s.diploma-masters-suffix
  } else {
    s.diploma-doctorate + conc + "\n" + s.diploma-doctorate-suffix
  }
}

// Première ligne du bloc « présenté à » (type de document).
#let presented-text(doc-type, lang) = {
  let s = tr(lang)
  if doc-type == "thesis" { s.presented-thesis } else if (
    doc-type == "manuscriptbasedthesis"
  ) { s.presented-manuscript-thesis } else if doc-type == "projectreport" {
    s.presented-project
  } else if doc-type == "manuscriptbasedmasterdegreethesis" {
    s.presented-manuscript-masters
  } else { s.presented-masters }
}

// Filigrane « CONFIDENTIEL », sur la première page uniquement.
#let confidential-watermark(lang) = place(
  top + right,
  dx: 0.1in,
  dy: -cfg.margin-top + 2cm,
  text(
    size: 14pt,
    fill: luma(50%),
    box(stroke: 0.4pt + luma(50%), inset: 4pt, tr(lang).confidential),
  ),
)

// Logo Creative Commons : `auto` prend celui fourni avec le gabarit (chemin
// résolu depuis ce module, donc indépendant de la racine du projet) ; sinon on
// attend une image déjà construite par le document, p. ex. image("logo.svg").
#let cc-logo-box(cc-logo) = box(
  if cc-logo == auto { image("../Figures/logocc.pdf", width: 50pt) } else {
    cc-logo
  },
)

#let make-title(
  title: [],
  author: "",
  copyright-holder: "",
  copyright-year: none,
  doc-type: "thesis",
  lang: "fr",
  licence: "reserved",
  concentration: none,
  cotutorship: none,
  confidential: false,
  cc-logo: auto,
  deposit-date: none,
) = {
  let s = tr(lang)
  let year = if copyright-year == none { datetime.today().year() } else {
    copyright-year
  }

  // ---- Recto : page de titre ----
  set page(numbering: "I")
  counter(page).update(1)
  no-folio
  if confidential { confidential-watermark(lang) }

  set align(center)
  set par(leading: cfg.leading-single, spacing: 0pt, justify: false)

  text(size: 18pt, title)
  v(3 * bl, weak: false)

  text(size: 16pt, {
    s.by
    linebreak()
    v(bl, weak: false)
    author
  })
  v(4 * bl, weak: false)

  text(size: 14pt, {
    presented-text(doc-type, lang)
    if cotutorship != none { s.cotutorship-mid }
    s.to-ets
    if cotutorship != none { s.cotutorship-and + upper(cotutorship) }
    linebreak()
    s.partial-requirement
    diploma-text(doc-type, lang, concentration)
    v(4 * bl, weak: false)
    s.city-line + upper(long-date(deposit-date, lang))
  })

  v(1fr)

  text(size: 14pt, s.university)
  v(6 * bl, weak: false)

  text(size: 12pt, {
    if licence == "reserved" {
      "© " + s.all-rights + copyright-holder + ", " + str(year)
    } else {
      cc-logo-box(cc-logo)
      h(0.5em)
      copyright-holder + ", " + str(year)
    }
  })

  // ---- Verso : notice de licence, calée en bas de la zone de texte ----
  pagebreak()
  no-folio
  set align(left)
  v(1fr)
  block(
    width: 100%,
    stroke: 0.4pt + black,
    inset: 10pt,
    {
      set text(size: 10pt)
      set par(leading: cfg.leading-onehalf, justify: false)
      if licence == "reserved" {
        "© " + s.licence-reserved-title
        linebreak()
        s.licence-reserved-body
      } else {
        cc-logo-box(cc-logo)
        linebreak()
        s.licence-cc-body-before
        link(
          "https://creativecommons.org/licenses/by-nc-nd/4.0/deed",
          s.licence-cc-link,
        )
        s.licence-cc-body-after
      }
    },
  )
}
