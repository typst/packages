// alias.typ (farfadet-socle) — raccourcis de commandes : un autre nom, des clés renommées, des défauts.
//
//   #let mc = alias(MultiColonnes, nom: "mc", cles: (columns: "nb"), nb: 3)
//   #mc[…]   #mc(nb: 2)[…]   #begin(mc) … #end(mc)
//
// Typst ne permet pas à une fonction de créer un nom dans la portée de l'appelant : l'alias se nomme
// donc par `#let`. Il fonctionne avec toute commande (de n'importe quel paquet) et avec begin/end, qui
// comparent les fonctions : il suffit d'écrire le même nom dans `begin` et dans `end`.
//
// Nom exporté : alias.

/// Crée un ALIAS d'une commande : un nom court, des clés renommées et des valeurs par défaut. On le
/// nomme par `#let`, puis on l'emploie comme la commande d'origine (syntaxe commande ou begin/end).
///
/// Les clés d'origine restent acceptées à côté des nouveaux noms ; donner les deux à la fois arrête la
/// compilation. Une clé donnée à l'appel l'emporte sur le défaut de l'alias. Les arguments positionnels
/// (titre, corps, nombre de colonnes…) passent tels quels.
///
/// ```example
/// #let mc = alias(multi-colonnes, nom: "mc", cles: (columns: "nb"), nb: 3)
/// #mc[
///   - un
///   - deux
///   - trois
/// ]
/// #begin(mc, nb: 2)
/// - quatre
/// - cinq
/// #end(mc)
/// ```
///
/// - pour (function): la commande d'origine (`multi-colonnes`, `exo`, `crep`…), la fonction elle-même, pas son nom.
/// - nom (none, str): nom de l'alias, repris dans les messages d'erreur. Défaut : `none` (« alias »).
/// - cles (dictionary): renommage des clés, `(clé d'origine: "nouveau nom", …)`. Défaut : `(:)`.
/// - ..defauts (any): valeurs par défaut, sous les nouveaux noms ou les noms d'origine.
/// -> function
#let alias(pour, nom: none, cles: (:), ..defauts) = {
  let quoi = if nom == none { "alias" } else { nom }
  if type(pour) != function {
    panic("alias : `pour` doit être la commande elle-même (par exemple MultiColonnes, sans guillemets) ; reçu : " + repr(pour) + ".")
  }
  if nom != none and type(nom) != str {
    panic("alias : `nom` doit être un texte ; reçu : " + repr(nom) + ".")
  }
  if type(cles) != dictionary {
    panic(quoi + " : `cles` doit être un dictionnaire (clé d'origine: \"nouveau nom\") ; reçu : " + repr(cles) + ".")
  }
  if defauts.pos().len() > 0 {
    panic(quoi + " : les valeurs par défaut s'écrivent en arguments nommés ; reçu : " + repr(defauts.pos().first()) + ".")
  }
  // nouveau nom → clé d'origine
  let origine = (:)
  for (ancien, nouveau) in cles {
    if type(nouveau) != str {
      panic(quoi + " : le nouveau nom de la clé « " + ancien + " » doit être un texte ; reçu : " + repr(nouveau) + ".")
    }
    if nouveau in origine {
      panic(quoi + " : le nom « " + nouveau + " » est donné à deux clés (« " + origine.at(nouveau) + " » et « " + ancien + " »).")
    }
    origine.insert(nouveau, ancien)
  }
  // Traduit les clés nommées vers les noms d'origine ; refuse une clé donnée sous ses deux noms.
  let traduire(nommees, ou) = {
    let res = (:)
    for (k, v) in nommees {
      let cible = origine.at(k, default: k)
      if cible in res {
        panic(quoi + " : la clé « " + cible + " » est donnée deux fois" + ou + " (sous ses deux noms « " + cible + " » et « " + cles.at(cible) + " »).")
      }
      res.insert(cible, v)
    }
    res
  }
  let fixes = traduire(defauts.named(), " dans la définition de l'alias")
  (..args) => pour(..args.pos(), ..(fixes + traduire(args.named(), "")))
}
