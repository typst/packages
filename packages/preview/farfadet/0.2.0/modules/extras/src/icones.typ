// icones.typ (farfadet-extras) — façade publique : icônes Feather (paquet ficons, embarqué dans vendor/).
// Réglages : `setbfextras`, type `icone`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: xcouleur
#import "moteur/complements.typ" as m
#import "reglages.typ": _resoudre

/// Icône Feather à insérer dans le texte (environ 280 pictogrammes : `"book"`, `"check"`, `"alert-triangle"`,
/// `"clock"`, `"edit-2"`, `"help-circle"`…).
///
/// ````typ
/// #icone("book") Lire le cours, #icone("edit-2") faire l'exercice, #icone("check", couleur: green) vérifier.
/// ````
///
/// - nom (str): le nom de l'icône (liste sur feathericons.com).
/// - ..options (any): clés locales : `couleur` (`none` : noir ; couleur Typst ou nom xcolor), `taille` (1 em : hauteur
///   de l'icône), `epaisseur` (2 ; 1 pour un trait fin), `decalage` (0,2 : descente sous la ligne de base, en fraction
///   de la taille), `style`.
/// -> content
#let icone(nom, ..options) = context {
  let r = _resoudre("icone", options)
  m.icone(
    nom,
    couleur: if r.couleur == none { none } else { xcouleur(r.couleur) },
    taille: r.taille,
    epaisseur: r.epaisseur,
    decalage: r.decalage,
  )
}
