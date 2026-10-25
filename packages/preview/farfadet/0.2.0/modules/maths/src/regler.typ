// regler.typ (farfadet-maths) — les réglages publics : `setbfmaths` (maths et texte) et `sisetup` (nombres et unités).
//
// Mécanisme du socle (REGLAGES.md du paquet farfadet-socle) ; description des clés : reglages.typ.
// Signature commune des setters : `pour:`, `reinitialiser:`, `definir:`, puis les clés.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-regler, reglages-definir-style, reglages-reinitialiser
#import "reglages.typ": _M, _N

/// Règle la mise en valeur du texte, les connecteurs, les coordonnées, les intervalles et les crochets
/// pour toute la suite du document. Les clés valables dépendent de la commande visée (`pour:`) ;
/// une clé inconnue ou une valeur invalide arrête la compilation en listant les possibilités.
///
/// Priorité : clé locale > style nommé > réglage du type (`pour:`) > réglage global > défaut.
/// Les couleurs par défaut sont des couleurs nommées de bfcours : `setbfcolors` les change.
///
/// ```typ
/// #setbfmaths(pour: "connecteurs", fond: 20)
/// #setbfmaths(pour: "Si", couleur: "orange")
/// #setbfmaths(pour: "encadrer", couleur: "green")
/// #si() $x > 0$, #alors() $sqrt(x)$ existe : #encadrer[$a^2 + b^2$].
/// ```
///
/// - pour (none, str, array): type visé : `"acc"`, `"encadrer"`, `"surligner"`, `"Si"`, `"Alors"`, `"Donc"`, `"Et"`, `"Mais"`, `"Car"`, `"Puisque"`, `"SSI"`, `"connecteurs"` (les huit), `"Coordonnees"`, `"intervalle"`, `"Crochet"`, `"outilcours"`, `"lien"`, `"affiche"`, `"pascalc"`, `"frquote"` ; `none` : réglage global (toutes les commandes qui ont la clé).
/// - reinitialiser (bool, str): `true` : repart des défauts (réglages global et par type effacés ; les styles nommés restent) ; `"tout"` : oublie aussi les styles définis.
/// - definir (none, str): nom d'un style à définir avec les clés données ; on l'appelle ensuite par `style: "nom"` (`pour:` contrôle alors les clés contre un type).
/// - ..cles (any): les clés à régler, par exemple `couleur: red`, `arc: 2pt`, `style: "mon-style"`.
/// -> content
#let setbfmaths(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("setbfmaths : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none {
    return reglages-definir-style(_M, definir, pour: pour, commande: "setbfmaths", ..cles)
  }
  if reinitialiser == "tout" { reglages-reinitialiser(_M, styles: true) }
  reglages-regler(_M, pour: pour, reinitialiser: reinitialiser != false, commande: "setbfmaths", ..cles)
}

/// Règle l'écriture des nombres et des unités qui suivent (`num`, `qty`, `unit`), avec les clés de
/// siunitx. Les valeurs par défaut sont françaises : virgule décimale, espace fine tous les trois chiffres
/// à partir de quatre chiffres. Priorité : clé locale > style > réglage du type > réglage global.
///
/// ```typ
/// #sisetup(round-precision: 2)
/// #num("3.14159") et #num("2")
/// ```
///
/// - pour (none, str): `"num"`, `"qty"` ou `"unit"` ; `none` : toutes les commandes.
/// - reinitialiser (bool, str): `true` : retour aux défauts (styles conservés) ; `"tout"` : oublie aussi les styles.
/// - definir (none, str): nom d'un style à définir, appelé ensuite par la clé locale `style:` de `num`, `qty`, `unit`.
/// - ..cles (any): `output-decimal-marker`, `group-separator`, `group-minimum-digits`, `group-digits`, `round-mode`, `round-precision`, `round-pad`, `exponent-mode`, `exponent-product`, `print-unity-mantissa`, `print-zero-exponent`, `retain-explicit-plus`, `uncertainty-mode`, `per-mode`, `inter-unit-product`, `zero` (clés brutes de zero), `style`.
/// -> content
#let sisetup(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("sisetup : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none {
    return reglages-definir-style(_N, definir, pour: pour, commande: "sisetup", ..cles)
  }
  if reinitialiser == "tout" { reglages-reinitialiser(_N, styles: true) }
  reglages-regler(_N, pour: pour, reinitialiser: reinitialiser != false, commande: "sisetup", ..cles)
}
