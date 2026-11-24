// ============================================================
// thETS — Ouverture de blocs et sauts de page recto.
// Portage de \cleardoublepage, \ETSpreliminaryOpen et
// \ETSunnumberedBodyOpen (section 9a de thETS.cls).
// ============================================================

#import "config.typ" as cfg

// Marqueur posé sur les pages qui ne doivent porter ni en-tête ni folio
// (page de titre, verso, page du jury).
#let no-folio = [#metadata("thets-no-folio")<thets-no-folio>]

// Équivalent de \cleardoublepage : passe à la page impaire suivante en
// laissant totalement vide l'éventuelle page intercalaire.
//
// La règle `set page(header: none)` est volontairement placée dans le même
// bloc que le saut : elle ne s'applique qu'aux pages créées par ce saut,
// c'est-à-dire à la page blanche, et l'en-tête reprend ensuite normalement.
#let clear-double-page() = {
  set page(header: none)
  pagebreak(to: "odd", weak: true)
}

// Titre d'un bloc préliminaire : centré, gras, majuscules, suivi de 24 pt.
// (\ETSpreliminaryPageHeading)
#let preliminary-heading(body) = {
  set align(center)
  set par(leading: cfg.leading-single, spacing: 0pt, justify: false)
  strong(upper(body))
  v(cfg.preliminary-heading-skip, weak: false)
}

// Bloc non numéroté SANS entrée dans la table des matières.
// (\ETSpreliminaryOpen)
#let preliminary-open(title) = {
  heading(level: 1, numbering: none, outlined: false, bookmarked: true, title)
}

// Bloc non numéroté AVEC entrée de niveau chapitre dans la table des matières.
// (\ETSunnumberedBodyOpen)
#let unnumbered-body-open(title) = {
  heading(level: 1, numbering: none, outlined: true, bookmarked: true, title)
}
