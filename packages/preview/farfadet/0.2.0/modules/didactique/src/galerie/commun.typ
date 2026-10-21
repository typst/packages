// commun.typ (farfadet-didactique) — aides partagées par les skins intégrés (src/galerie/*.typ).
//
// Un skin extérieur (dans un paquet personnel) n'a pas besoin de ce fichier : il reçoit l'icône par
// `d.outils.icone` (ou `d.outils.icone-choisie`, qui applique la priorité de `choisir-icone`) et lit ses options
// dans `d.options`. Les fonctions ci-dessous rangent ces gestes une fois pour toutes pour les six skins intégrés.

/// Largeur disponible, mémorisée par `sonde-largeur`.
#let _largeur = state("bfd-skin-largeur", 10cm)

/// Sonde de largeur : à poser en premier dans le bloc du skin. Elle ne prend aucune place et mémorise la
/// largeur intérieure du bloc ; `largeur-ici()` la rend, dans un `context` placé APRÈS la sonde.
///
/// DÉCONSEILLÉE (gardée pour les skins extérieurs qui l'emploient) : la largeur passe par un état, donc la
/// première passe de mise en page lit la valeur par défaut (10 cm) et Typst refait un tour complet. Les skins
/// intégrés lisent la largeur directement : `layout(taille => { … taille.width … ; d.corps })`. Depuis Typst
/// 0.12, le contenu d'un `layout` se coupe entre deux pages comme le reste : le bloc reste sécable.
#let sonde-largeur() = place(top + left, layout(taille => _largeur.update(taille.width)))

/// Largeur mémorisée par la dernière `sonde-largeur()` (à appeler dans un `context`).
#let largeur-ici() = _largeur.get()

/// Valide les options d'un skin et complète les manquantes par les défauts.
///
/// - d (dictionary): le dictionnaire du skin ; ses options sont `d.options` (clé `skin:` de l'environnement).
/// - nom (str): nom du skin, pour le message d'erreur.
/// - defauts (dictionary): options connues et leur valeur par défaut.
/// -> dictionary
#let options-skin(d, nom, defauts) = {
  for cle in d.options.keys() {
    if cle not in defauts {
      panic(
        "skin « " + nom + " » : option inconnue « " + cle + " ». Options possibles : "
          + defauts.keys().join(", ") + ". (clé skin: de l'environnement ou de bfskin)",
      )
    }
  }
  defauts + d.options
}

/// Icône d'un skin. Priorité :
/// 1. la clé `icone` de bfcours (`d.icone`, si elle est réglée) ;
/// 2. l'option `icone` du skin (`d.options.icone`, par `skin: (icone: …)` ou `bfskin(…, icone: …)`) ;
/// 3. l'emblème du type (`d.embleme`, clé `embleme`), sauf s'il vaut `auto` ou `none` ;
/// 4. `defaut`, l'icône propre au skin.
/// Les choix 2 à 4 sont des noms du jeu commun, des fonctions `couleur => contenu`, du contenu ou `none`
/// (aucune icône, pour l'option seulement).
///
/// Un skin personnel obtient la même priorité par `d.outils.icone-choisie` (même signature, sans `d`).
///
/// - d (dictionary): le dictionnaire du skin.
/// - defaut (str): icône propre au skin.
/// - taille (length): côté de l'icône.
/// - couleur (color, auto): teinte (`auto` : celle de l'environnement).
/// - pastille (auto, bool): voir `icone` (disque plein à glyphe blanc).
/// -> content
#let choisir-icone(d, defaut, taille: 1em, couleur: auto, pastille: auto) = {
  if d.icone != none {
    if pastille == true { (d.outils.icone)(d.icone, taille: taille, couleur: couleur, pastille: true) } else { d.icone }
  } else {
    let choix = d.options.at("icone", default: auto)
    let embleme = d.at("embleme", default: auto)
    let nom = if choix != auto { choix } else if embleme != auto and embleme != none { embleme } else { defaut }
    (d.outils.icone)(nom, taille: taille, couleur: couleur, pastille: pastille)
  }
}
