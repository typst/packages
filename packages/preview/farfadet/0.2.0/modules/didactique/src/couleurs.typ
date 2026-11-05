// couleurs.typ (farfadet-didactique) — carrés de couleur (\coloredsquare, \dimcoloredsquare).
//
// La façade des COULEURS n'est plus ici (épurage du 08/10/2026, convention 2) : elle est celle de
// farfadet-socle (`setbfcolors`, `definecolor`, `colorlet`, `couleurs-tabular`, `couleur-texte-accent`,
// `couleur-item`, `Reset…`, `textcolor`). Il ne reste que ces deux commandes de légende, qui lisent la
// couleur au rendu (nom xcolor ou couleur nommée de bfcours, donc sensibles à `setbfcolors`).

#import "../../socle/lib.typ": interne as _socle
#import _socle: bf-resoudre-couleur

/// Carré plein de 3 ex de côté (`\coloredsquare{couleur}`).
///
/// ```example
/// Légende : #coloredsquare("thm") théorèmes, #coloredsquare(teal) autre.
/// ```
///
/// - couleur (color, str): la couleur.
/// - taille (int, float): côté en ex. Défaut : `3`.
/// -> content
#let coloredsquare(couleur, taille: 3) = context box(
  width: taille * 0.43em,
  height: taille * 0.43em,
  fill: bf-resoudre-couleur(couleur),
)

/// Carré plein de côté choisi en ex (`\dimcoloredsquare{couleur}{taille}`).
///
/// ```example
/// #dimcoloredsquare("prop", 2) #dimcoloredsquare("prop", 4)
/// ```
///
/// - couleur (color, str): la couleur.
/// - taille (int, float): côté en ex.
/// -> content
#let dimcoloredsquare(couleur, taille) = coloredsquare(couleur, taille: taille)
