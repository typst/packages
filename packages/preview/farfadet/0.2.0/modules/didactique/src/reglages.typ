// reglages.typ — registres de réglages des environnements didactiques et de l'export Anki, sur le
// mécanisme générique de farfadet-socle (voir REGLAGES.md du paquet farfadet-socle).
//
// Le setter public `setbfenvironments` est dans palettes.typ (il règle aussi les palettes) ; ce
// fichier ne porte que les registres, les styles prédéfinis et `_appliquer-environnements`.
//
// Priorité (de la plus forte à la plus faible) :
//   clé écrite sur l'environnement > style nommé local > réglage du type > réglage global > défaut.
// Les défauts et contrôles des clés sont GÉNÉRÉS (catalogue.typ).
// Les couleurs par défaut sont des couleurs NOMMÉES (marqueur `bf-nommee`, convention 2) : elles sont
// lues au moment du rendu, donc `setbfcolors(defi: …)` les change.
// ATTENTION : interne.typ (fichier généré) reprend tout `#let` public de ce fichier :
// les fonctions publiques vont dans palettes.typ.

#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-nommee, reglages-choix as _choix, reglages-controles as _c, reglages-ou as _ou, reglages-paquet,
  reglages-regler-types,
)
#import "catalogue.typ": _communs, _controles, _types-defauts

// =====================================================================
// Styles prédéfinis (styles tcolorbox LaTeX « voie b »)
// =====================================================================
// Un style est un paquet de clés ; appliqué à un type, il n'agit que par les clés que ce type
// connaît. `bfd theoreme` posé sur bfEnv donne la couleur des théorèmes, etc.
// `bf` et `rd` sont les deux styles de RENDU : `setbfenvironments(style: "rd")` fait rendre chaque
// environnement par la boîte de `rdboites` qui lui correspond (voir style-rd.typ) ; `"bf"`, le
// défaut, est le rendu de bfcours.

#let _styles-predefinis = (
  "bf": (rendu: "bf"),
  "rd": (rendu: "rd"),
  "bfd theoreme": (couleur: "thm"),
  "bfd definition": (couleur: "defi"),
  "bfd propriete": (couleur: "prop"),
  "bfd demonstration": (couleur: "demo", craie: true),
  "bfd methode": (couleur: "meth"),
  "bfd activite": (couleur: "act", breakable: true),
  "bfd vocabulaire": (couleur: "nota"),
  "bfd solution": (couleur: "green"),
  "bfd histoire": (couleur: bf-nommee("histoire"), onglet: [Un peu d'histoire]),
  "exempleboxstyle": (couleur: "gray", couleur-accent: "nota!80!black"),
  "contreexempleboxstyle": (couleur: "red", couleur-accent: "blue!80!black"),
  "bfd edge overlay lignes": (variant: "lignes"),
  "bfd edge overlay minimal": (variant: "minimal"),
  "bfd edge overlay sidebar": (variant: "sidebar"),
)

// =====================================================================
// Registre des environnements
// =====================================================================

#let _R = reglages-paquet(
  "didactique",
  _communs,
  controles: _controles,
  types: _types-defauts,
  commande: "setbfenvironments",
  styles: _styles-predefinis,
)

/// Registre « ombre » de `_R` : mêmes clés, mêmes contrôles, mêmes styles et MÊME état (« bfr-didactique » :
/// deux `state` de même clé partagent leurs mises à jour), mais tous les défauts valent `auto`. Résolu
/// comme `_R`, il ne rend donc que les clés RÉGLÉES par l'utilisateur (sur l'appel, par un style, par
/// `setbfenvironments` global ou par type) ; une clé laissée à son défaut de catalogue vaut `auto`. Sert au
/// style « rd » (ne traduire que les clés réglées) et au champ `explicites` du contrat de skin. Une clé
/// réglée à la même valeur que son défaut (`colback: "white"`) est bien vue comme réglée.
#let _R-explicite = reglages-paquet(
  "didactique",
  _communs.keys().map(k => (k, auto)).to-dict(),
  controles: _controles,
  types: _types-defauts.pairs().map(((t, d)) => (t, d.keys().map(k => (k, auto)).to-dict())).to-dict(),
  commande: "setbfenvironments",
  styles: _styles-predefinis,
)

// Transition : anciens identifiants et anciennes clés,
// acceptés par `_appliquer-environnements` seulement (jamais par la façade publique).
#let _anciens-types = (
  theoreme: "Theoreme", definition: "Definition", propriete: "Propriete", demonstration: "Demonstration",
  methode: "Methode", activite: "Activite", vocabulaire: "Vocabulaire", solution: "Solution", exemple: "Exemple",
  contre-exemple: "ContreExemple", remarque: "Remarque", notation: "Notation", aide: "Aide", histoire: "Histoire",
  environnement: "bfEnv", cadre-dechire: "cracked",
)
#let _anciennes-cles = (
  texte-reference: "nameref", secable: "breakable", avant: "before-skip", apres: "after-skip",
  cadre: "colframe", fond: "colback", fond-titre: "colbacktitle", couleur-titre: "coltitle",
  epaisseur: "boxrule", arrondi: "arc", marge: "boxsep", largeur: "width",
)
#let _traduire(d) = d.pairs().map(((k, v)) => (_anciennes-cles.at(k, default: k), v)).to-dict()

/// Applique le dictionnaire `environnements` du modèle de document : clés `tous` (réglage global),
/// `reinitialiser`, et un dictionnaire de clés par type (`Definition: (numero: true)`). Accepte aussi
/// les anciens noms (transition).
#let _appliquer-environnements(dico) = {
  if dico == none { return }
  let args = (:)
  for (k, v) in dico {
    if k == "reinitialiser" { args.insert(k, v) } else if k == "tous" { args.insert(k, _traduire(v)) } else {
      args.insert(_anciens-types.at(k, default: k), if k in _anciens-types { _traduire(v) } else { v })
    }
  }
  reglages-regler-types(_R, commande: "setbfenvironments", ..args)
}

// =====================================================================
// Anki
// =====================================================================

#let _RA = reglages-paquet(
  "anki",
  (paquet: none, etiquettes: (), format: none),
  controles: (
    paquet: _ou(_c.texte, _choix(none)),
    etiquettes: (v => type(v) == array and v.all(x => type(x) == str), "un tableau de chaînes"),
    format: _choix(none, "png", "svg", "plain"),
  ),
  commande: "setbfenvironments (anki)",
)
