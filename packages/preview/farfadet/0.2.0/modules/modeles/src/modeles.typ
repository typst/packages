// modeles.typ — `modele` : le point d'entrée des modèles de document. Une clé (le nom du modèle) choisit
// la page, les polices, l'en-tête et les réglages d'un type de document.
//
//   #import "../lib.typ": *
//   #show: modele("cours", niveau: "2nde", theme: [Les vecteurs])
//
// Le modèle « cours » est `farfadet`. Ajouter un modèle : écrire une fonction `_modele-xxx(..., body)` à clés
// nommées, puis une ligne dans `_registre` ; `modele(...)` et le message d'erreur du nom inconnu
// s'en déduisent. Tout ce qui n'est pas un nom public de lib.typ commence par « _ ».

#import "modele.typ": farfadet

#let _liste(elements) = elements.map(e => "« " + str(e) + " »").join(", ")

// Registre : nom du modèle → fonction à clés nommées (dernier argument : le document).
#let _registre = (
  cours: farfadet,
)

/// Point d'entrée unique des modèles de document. Renvoie une fonction `document => …` à employer
/// avec `#show:`. Le nom du modèle est la clé du choix ; un nom inconnu arrête la compilation et
/// liste les modèles disponibles.
///
/// - `"cours"` : `farfadet` (mêmes clés : `niveau`, `theme`, `titres`, `sommaire`, `dys`…).
///
/// ```typ
/// #show: modele("cours", niveau: "2nde", theme: [Les vecteurs])
/// ```
///
/// - nom ("cours"): le modèle à installer.
/// - reglages (arguments): les clés du modèle choisi, toutes nommées.
/// -> function
#let modele(nom, ..reglages) = {
  if type(nom) != str {
    panic("modele : le nom du modèle est une chaîne, par exemple modele(\"cours\") ; reçu : " + repr(nom) + ".")
  }
  if nom not in _registre {
    panic("modele : modèle inconnu « " + nom + " ». Modèles disponibles : " + _liste(_registre.keys()) + ".")
  }
  if reglages.pos().len() > 0 {
    panic(
      "modele(\"" + nom + "\") : seuls des réglages nommés sont acceptés (niveau: \"2nde\", …) ; reçu : "
        + repr(reglages.pos().first()) + ".",
    )
  }
  let fabrique = _registre.at(nom)
  body => fabrique(..reglages.named(), body)
}
