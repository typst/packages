// ============================================================
// thETS — Gabarit Typst de rédaction de l'École de technologie
// supérieure (thèse, mémoire, rapport de projet).
//
// Portage du gabarit LaTeX thETS.cls. Point d'entrée unique :
// tout ce qui est destiné au document est réexporté ici.
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": long-date, month-year, tr
#import "state.typ": (
  doc-author, doc-lang, doc-part, doc-title, doc-type, is-doctorate, is-masters,
  is-project, normalize-lang, normalize-type,
)
#import "blocks.typ": (
  clear-double-page, no-folio, preliminary-heading, preliminary-open,
  unnumbered-body-open,
)
#import "titlepage.typ": make-title
#import "jury.typ": make-jury
#import "floats.typ": (
  algo-kind, algo-line, algo-numbering, algo-reset, equation-numbering,
  ets-algorithm, ets-figure, ets-listing, ets-longtable, ets-subfigure,
  ets-table, image-numbering, kw, record-chapter, source-line, table-numbering,
)
#import "frontmatter.typ": abstract, acknowledgements, foreword, resume
#import "lists.typ": (
  list-of-abbreviations, list-of-algorithms, list-of-figures, list-of-symbols,
  list-of-tables, table-of-contents,
)
#import "body.typ": conclusion, introduction, recommendations
#import "backmatter.typ": annexes, appendices, ets-bibliography, ets-references
#import "articles.typ": (
  article-accepted, article-authors, article-published, article-submitted,
)

// Réexports pour le document utilisateur.
#let thets-config = cfg

// ---------------------------------------------------------------------------
// Gabarit principal
// ---------------------------------------------------------------------------
//
//   #show: ets-document.with(
//     type: "these",
//     title: [Titre du document],
//     author: (firstname: "Prénom", lastname: "Nom"),
//     ...
//   )
#let ets-document(
  // --- Identification du document ---
  type: "these",
  lang: "fr",
  licence: "reserved", // "reserved" ou "creativecommons"
  confidential: false,

  // --- Page de titre ---
  title: [],
  author: (firstname: "", lastname: ""),
  copyright-holder: none, // par défaut : « Prénom NOM »
  copyright-year: none, // par défaut : année courante
  concentration: none,
  cotutorship: none,
  defense-date: none,
  deposit-date: none,

  // --- Jury ---
  supervisor: none,
  cosupervisor: none,
  chair: none,
  jury: (),
  external-examiners: (),
  independent-examiner: none,

  // --- Rendu ---
  title-page: true,
  jury-page: true,
  // `auto` : logo Creative Commons fourni avec le gabarit. Sinon, passer une
  // image déjà construite, p. ex. image("mon-logo.svg").
  cc-logo: auto,

  body,
) = {
  let dtype = normalize-type(type)
  let dlang = normalize-lang(lang)
  let s = tr(dlang)
  let author-name = author.firstname + " " + upper(author.lastname)
  let holder = if copyright-holder == none { author-name } else {
    copyright-holder
  }

  // --- Métadonnées PDF ---
  set document(title: title, author: author-name)

  // --- États partagés ---
  doc-lang.update(dlang)
  doc-type.update(dtype)
  doc-title.update(title)
  doc-author.update(author-name)
  doc-part.update("body")

  // --- Mise en page imposée : US Letter, recto-verso, marges du décanat ---
  set page(
    paper: cfg.paper,
    margin: (
      top: cfg.margin-top,
      bottom: cfg.margin-bottom,
      inside: cfg.margin-inside,
      outside: cfg.margin-outside,
    ),
    binding: left,
    numbering: "I",
    header-ascent: cfg.header-ascent,
    footer: none,
    // Folio en tête, côté extérieur. Absent des pages d'ouverture de bloc
    // (titre de niveau chapitre) et des pages marquées sans folio.
    header: context {
      let p = here().page()
      let opens-block = query(heading.where(level: 1)).any(h => (
        h.location().page() == p
      ))
      let suppressed = query(<thets-no-folio>).any(m => (
        m.location().page() == p
      ))
      if opens-block or suppressed { return none }
      let folio = counter(page).display()
      if calc.odd(p) { align(right, folio) } else { align(left, folio) }
    },
  )

  // --- Typographie ---
  set text(
    font: cfg.font-serif,
    size: cfg.size-body,
    lang: dlang,
    region: "CA",
    hyphenate: true,
  )
  show math.equation: set text(font: cfg.font-math)
  set raw(tab-size: 4)
  show raw: set text(font: cfg.font-mono, size: 10pt)

  set par(
    justify: true,
    leading: cfg.leading-onehalf,
    spacing: cfg.par-spacing,
    first-line-indent: cfg.par-indent,
  )

  // --- Listes (équivalent des réglages enumitem) ---
  set enum(indent: 0pt, body-indent: 1em, numbering: "1.a.", tight: true)
  set list(
    indent: 0pt,
    body-indent: 1em,
    marker: ([•], strong[–], [•], strong[–]),
    tight: true,
  )

  // --- Citations longues : 11 pt, interligne simple, retraits de 3 em ---
  show quote.where(block: true): it => block(
    inset: (left: 3em, right: 3em),
    {
      set text(size: 11pt)
      set par(leading: cfg.leading-single)
      it.body
    },
  )

  // --- Notes de bas de page : interligne simple, retrait ÉTS ---
  show footnote.entry: set par(leading: cfg.leading-single, spacing: 0.5em)
  set footnote.entry(indent: 2.5em)

  // --- Titres ---
  set heading(numbering: "1.1")
  show heading: set text(size: cfg.size-body, weight: "bold")

  // Niveau 1 : chapitre ou bloc non numéroté, toujours sur page impaire.
  show heading.where(level: 1): it => {
    clear-double-page()
    // Enregistre l'ouverture du chapitre pour la numérotation des flottants
    // (voir floats.typ). Les compteurs ne sont jamais remis à zéro : c'est le
    // registre qui ramène chaque numéro global à un numéro de chapitre.
    context {
      let part = doc-part.get()
      let pattern = if part == "annex" { "I" } else if part == "appendix" {
        "A"
      } else { "1" }
      let separator = if part == "annex" { "-" } else { "." }
      record-chapter(
        numbering(pattern, counter(heading).get().first()),
        separator,
        part == "annex",
      )
    }

    set par(leading: cfg.leading-single, spacing: 0pt, justify: false)
    if it.numbering == none {
      // Bloc préliminaire ou non numéroté : titre seul + 24 pt.
      align(center, strong(upper(it.body)))
      v(cfg.preliminary-heading-skip, weak: false)
    } else {
      // « CHAPITRE 1 » puis, une ligne plus bas, le titre.
      let word = context {
        let part = doc-part.get()
        if part == "annex" { s.annex } else if part == "appendix" {
          s.appendix
        } else { s.chapter }
      }
      align(center, {
        strong(upper[#word #counter(heading).display(it.numbering)])
        v(cfg.baselineskip, weak: false)
        strong(upper(it.body))
      })
      v(cfg.preliminary-heading-skip, weak: false)
    }
  }

  // Niveaux 2 à 4 : numéro dans un taquet fixe, titre en gras, au fer à gauche.
  show heading
    .where(level: 2)
    .or(heading.where(level: 3))
    .or(heading.where(level: 4)): it => block(
    above: cfg.par-spacing,
    below: 0.5em,
    {
      set par(
        leading: cfg.leading-single,
        justify: false,
        hanging-indent: cfg.heading-number-width,
      )
      box(
        width: cfg.heading-number-width,
        counter(heading).display(it.numbering),
      )
      it.body
    },
  )

  // Niveaux 5 et 6 : paragraphe et sous-paragraphe, sans numéro.
  show heading.where(level: 5): it => block(
    above: cfg.par-spacing,
    below: 0.5em,
    {
      set par(leading: cfg.leading-single, justify: false)
      strong(it.body)
    },
  )
  show heading.where(level: 6): it => {
    set par(leading: cfg.leading-single)
    strong(it.body)
    h(1em)
  }

  // --- Flottants ---
  set figure(gap: cfg.caption-skip)
  set figure.caption(separator: h(1em))
  show figure.caption: set text(size: cfg.size-body, weight: "regular")
  show figure: set block(breakable: false)
  show figure.where(kind: image): set figure(
    supplement: s.figure,
    numbering: image-numbering,
  )
  show figure.where(kind: table): set figure(
    supplement: s.table,
    numbering: table-numbering,
  )
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: algo-kind): set figure(
    supplement: s.algorithm,
    numbering: algo-numbering,
  )
  show figure.where(kind: algo-kind): set figure.caption(position: top)

  // --- Tableaux : filets fins, comme les exemples du gabarit ---
  set table(stroke: 0.4pt + black, inset: 5pt)
  show table.cell.where(y: 0): strong

  // --- Équations ---
  set math.equation(numbering: equation-numbering, supplement: s.equation)

  // --- Pages liminaires ---
  if title-page {
    make-title(
      title: title,
      author: author-name,
      copyright-holder: holder,
      copyright-year: copyright-year,
      doc-type: dtype,
      lang: dlang,
      licence: licence,
      concentration: concentration,
      cotutorship: cotutorship,
      confidential: confidential,
      cc-logo: cc-logo,
      deposit-date: deposit-date,
    )
  }

  if jury-page {
    make-jury(
      doc-type: dtype,
      lang: dlang,
      defense-date: defense-date,
      supervisor: supervisor,
      cosupervisor: cosupervisor,
      chair: chair,
      jury: jury,
      external-examiners: external-examiners,
      independent-examiner: independent-examiner,
    )
  }

  body
}
