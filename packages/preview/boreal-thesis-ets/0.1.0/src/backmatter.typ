// ============================================================
// thETS — Annexes, appendices et bibliographies
// (sections 13 et 14 de thETS.cls).
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": tr
#import "state.typ": doc-lang, doc-part
#import "blocks.typ": unnumbered-body-open
#import "floats.typ": algo-kind

// Libellés de flottants d'annexe, résolus à l'affichage pour suivre la langue
// du document.
#let annex-supplement(key) = context tr(doc-lang.get()).at(key)

// ---------------------------------------------------------------------------
// Annexes — chapitres numérotés I, II, III, …
// ---------------------------------------------------------------------------
// Les flottants d'annexe sont renommés (Figure-A, Tableau-A, Algorithme-A) et
// renumérotés « I-1 ».
//
// S'emploie comme règle show, pour que la renumérotation s'applique à tout
// ce qui suit :   #show: annexes
// La forme #annexes[…] est également acceptée.
#let annexes(body) = {
  doc-part.update("annex")
  counter(heading).update(0)

  // Interligne simple ; seul le niveau chapitre figure dans la table des
  // matières (\setcounter{tocdepth}{0}) ; les flottants sortent des listes
  // principales (\thETS@truncateLoaHere).
  set par(leading: cfg.leading-single)
  show heading.where(level: 2): set heading(outlined: false)
  show heading.where(level: 3): set heading(outlined: false)
  show heading.where(level: 4): set heading(outlined: false)
  set figure(outlined: false)
  set heading(numbering: "I.1")

  // Seuls les libellés changent : la numérotation « I-3 » est produite par le
  // registre de chapitres (floats.typ), à partir de l'état doc-part.
  show figure.where(kind: image): set figure(
    supplement: annex-supplement("figure-annex"),
  )
  show figure.where(kind: table): set figure(
    supplement: annex-supplement("table-annex"),
  )
  show figure.where(kind: algo-kind): set figure(
    supplement: annex-supplement("algorithm-annex"),
  )

  body
}

// ---------------------------------------------------------------------------
// Appendices — chapitres numérotés A, B, C, …
// ---------------------------------------------------------------------------
// Contrairement aux annexes, les libellés des flottants restent inchangés :
// c'est le comportement de \appendix dans thETS.cls.
#let appendices(body) = {
  doc-part.update("appendix")
  counter(heading).update(0)

  set par(leading: cfg.leading-single)
  show heading.where(level: 2): set heading(outlined: false)
  show heading.where(level: 3): set heading(outlined: false)
  show heading.where(level: 4): set heading(outlined: false)
  set figure(outlined: false)
  set heading(numbering: "A.1")

  body
}

// ---------------------------------------------------------------------------
// Bibliographies
// ---------------------------------------------------------------------------
// Interligne simple, entrées séparées d'une ligne, retrait suspendu de 3 em,
// titre de niveau chapitre dans la table des matières.
//
// `sources` accepte deux formes :
//   - un nom de fichier .bib ou .yml placé À CÔTÉ du document, par exemple
//     "biblio_fr.bib" (ou un tableau de plusieurs noms) ;
//   - le contenu du fichier, lu depuis le document : bytes(read("mabiblio.bib")).
//
// La seconde forme est la seule qui fonctionne si la base bibliographique est
// ailleurs que dans le dossier du gabarit : `read` est alors résolu depuis
// VOTRE fichier. Aucun chemin n'est résolu depuis la racine du projet, car
// celle-ci dépend de l'éditeur (l'extension Tinymist prend la racine de
// l'espace de travail, la ligne de commande le dossier du document).
#let resolve-sources(sources) = {
  if type(sources) == str { "../" + sources } else if type(sources) == array {
    sources.map(resolve-sources)
  } else { sources }
}

#let ets-bibliography(
  sources,
  title: auto,
  style: "../ets.csl",
  full: true,
) = context {
  let s = tr(doc-lang.get())
  let heading-title = if title == auto { s.bibname } else { title }
  unnumbered-body-open(heading-title)
  // Le retrait suspendu de 3 em est défini dans ets.csl (hanging-indent) :
  // Typst compose les entrées dans une grille, hors de portée de par().
  set par(leading: cfg.leading-single, spacing: cfg.baselineskip)
  bibliography(resolve-sources(sources), title: none, style: style, full: full)
}

// Liste de références secondaire (« BIBLIOGRAPHIE »), équivalent des commandes
// multibib de suffixe « refs » du gabarit LaTeX. Typst accepte plusieurs
// éléments bibliography : chaque citation est résolue dans le fichier qui la
// contient, sans passe BibTeX supplémentaire.
#let ets-references(sources, style: "../ets.csl", full: true) = context {
  ets-bibliography(
    sources,
    title: tr(doc-lang.get()).refsname,
    style: style,
    full: full,
  )
}
