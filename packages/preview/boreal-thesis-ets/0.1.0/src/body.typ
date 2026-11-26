// ============================================================
// thETS — Blocs du corps du document : introduction, conclusion,
// recommandations (section 12 de thETS.cls).
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": tr
#import "state.typ": doc-lang
#import "blocks.typ": clear-double-page, unnumbered-body-open

// Introduction : bascule la numérotation des pages du romain vers l'arabe
// (redémarrage à 1) et ajoute une entrée de niveau chapitre dans la TDM.
//
// S'emploie comme règle show, de façon que le changement de numérotation
// s'applique à tout ce qui suit :
//
//   #show: introduction
//   Texte de l'introduction…
//
// La forme #introduction[Texte…] est également acceptée.
#let introduction(body) = {
  // Terminer les préliminaires AVANT de repartir à 1, sinon la page blanche
  // intercalaire porterait le numéro 1 à la place de l'introduction.
  clear-double-page()
  set page(numbering: "1")
  counter(page).update(1)
  context unnumbered-body-open(tr(doc-lang.get()).introduction)
  body
}

// Conclusion : bloc non numéroté, entrée de niveau chapitre dans la TDM.
// Le compteur de chapitre avance (comme \stepcounter{chapter}) pour que les
// flottants placés après ne réutilisent pas le numéro du dernier chapitre.
#let conclusion = {
  context unnumbered-body-open(tr(doc-lang.get()).conclusion)
  counter(heading).step()
}

// Recommandations (facultatif) : même comportement que la conclusion.
#let recommendations = {
  context unnumbered-body-open(tr(doc-lang.get()).recommendations)
  counter(heading).step()
}
