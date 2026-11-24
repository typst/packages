// ============================================================
// thETS — Table des matières, listes de flottants, listes
// d'abréviations et de symboles (section 11 de thETS.cls).
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": tr
#import "state.typ": doc-lang, doc-part
#import "blocks.typ": preliminary-open
#import "floats.typ": algo-kind

// Largeur du taquet réservé au numéro, par niveau (\tocLeftMarginSecondLine*).
#let toc-width = (
  cfg.toc-hang-chapter,
  cfg.toc-hang-section,
  cfg.toc-hang-subsection,
  cfg.toc-hang-subsubsection,
)

// Retrait de la première ligne : cumul des taquets des niveaux précédents,
// comme le \parindent de \l@subsection et \l@subsubsection.
#let toc-indent(level) = {
  if level <= 2 { 0pt } else { toc-width.slice(1, level - 1).sum() }
}

// Ligne « Page » alignée à droite, au-dessus de chaque table.
#let page-header-line(lang) = {
  set par(leading: cfg.leading-single, spacing: 0pt, justify: false)
  align(right, tr(lang).page)
}

// Une entrée : corps à gauche, points de conduite, folio à droite,
// indentation suspendue pour les lignes de continuation.
#let toc-line(body, page, target, hang: 0pt, indent: 0pt, above: 0.5em) = block(
  above: above,
  below: 0pt,
  {
    set par(
      hanging-indent: hang + indent,
      first-line-indent: 0pt,
      justify: false,
    )
    h(indent)
    link(target, body)
    box(width: 1fr, inset: (x: 0.4em), repeat(justify: false, gap: 2.5pt)[.])
    link(target, page)
  },
)

// ---------------------------------------------------------------------------
// Table des matières
// ---------------------------------------------------------------------------

#let table-of-contents() = context {
  let lang = doc-lang.get()
  preliminary-open(tr(lang).contents)
  page-header-line(lang)

  set par(leading: cfg.leading-single, spacing: 0pt)

  show outline.entry: it => {
    let el = it.element
    let loc = el.location()
    let lvl = it.level

    if lvl == 1 {
      // « CHAPITRE 1  TITRE DU CHAPITRE », entièrement en majuscules.
      let body = if el.numbering == none {
        upper(el.body)
      } else {
        let word = if doc-part.at(loc) == "annex" { tr(lang).annex } else if (
          doc-part.at(loc) == "appendix"
        ) { tr(lang).appendix } else { tr(lang).chapter }
        upper(box(width: toc-width.at(0), word + " " + it.prefix()) + el.body)
      }
      toc-line(body, it.page(), loc, hang: toc-width.at(0), above: 1em)
    } else {
      let width = toc-width.at(calc.min(lvl - 1, toc-width.len() - 1))
      let indent = toc-indent(lvl)
      toc-line(
        box(width: width, it.prefix()) + el.body,
        it.page(),
        loc,
        hang: width,
        indent: indent,
      )
    }
  }

  outline(title: none, depth: 4)
}

// ---------------------------------------------------------------------------
// Listes de flottants
// ---------------------------------------------------------------------------

#let float-list(title, kind) = context {
  let lang = doc-lang.get()
  preliminary-open(title)
  page-header-line(lang)
  set par(leading: cfg.leading-single, spacing: 0pt)

  show outline.entry: it => {
    toc-line(
      box(width: cfg.toc-hang-chapter, it.prefix()) + it.element.caption.body,
      it.page(),
      it.element.location(),
      hang: cfg.toc-hang-chapter,
    )
  }

  outline(title: none, target: figure.where(kind: kind))
}

#let list-of-figures() = context float-list(
  tr(doc-lang.get()).list-of-figures,
  image,
)
#let list-of-tables() = context float-list(
  tr(doc-lang.get()).list-of-tables,
  table,
)
#let list-of-algorithms() = context float-list(
  tr(doc-lang.get()).list-of-algorithms,
  algo-kind,
)

// ---------------------------------------------------------------------------
// Listes d'abréviations et de symboles
// ---------------------------------------------------------------------------

// `entries` : liste de paires (étiquette, description).
#let definition-list(title, entries, label-width: cfg.label-column-width) = {
  preliminary-open(title)
  set par(leading: cfg.leading-single, spacing: 0pt, justify: false)
  grid(
    columns: (label-width, 1fr),
    row-gutter: cfg.par-spacing,
    column-gutter: 1mm,
    ..entries.map(e => (e.at(0), e.at(1))).flatten(),
  )
}

// Liste des abréviations, sigles et acronymes.
// `sorted: true` trie les entrées alphabétiquement (équivalent de
// l'environnement listeabreviationstriee).
#let list-of-abbreviations(
  entries,
  label-width: cfg.label-column-width,
  sorted: false,
) = context {
  let e = if sorted { entries.sorted(key: x => upper(x.at(0))) } else {
    entries
  }
  definition-list(tr(doc-lang.get()).list-of-abbr, e, label-width: label-width)
}

// Liste des symboles et unités de mesure.
#let list-of-symbols(entries, label-width: cfg.label-column-width) = context {
  definition-list(
    tr(doc-lang.get()).list-of-symbols,
    entries,
    label-width: label-width,
  )
}
