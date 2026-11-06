// regler.typ (farfadet-extras) — le setter unique `setbfextras`.
//
// Mécanisme du socle (REGLAGES.md du paquet farfadet-socle) ; description des clés : reglages.typ.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-regler, reglages-definir-style, reglages-reinitialiser
#import "reglages.typ": _E

/// Règle les commandes du paquet pour toute la suite du document. Les clés valables dépendent de la commande
/// visée (`pour:`) ; une clé inconnue ou une valeur invalide arrête la compilation en listant les possibilités.
///
/// Priorité : clé locale > style nommé > réglage du type (`pour:`) > réglage global > défaut.
///
/// Types : `"filmbox"` (mode `"image"`), `"filmbox-rogne"` (mode `"rogne"`), `"filmbox-texte"` (mode `"texte"`),
/// `"filmt"`, `"BFCodePython"`, `"habiller"`, `"icone"`. Le groupe `"film"` vise les quatre types de film d'un
/// coup : chacun reçoit celles des clés qu'il connaît. Styles prédéfinis de `bf-code-python` : `"classique"`,
/// `"sobre"`.
///
/// ```typ
/// #setbfextras(pour: "film", fond: "blue!50!black", perforation-couleur: "yellow")
/// #setbfextras(pour: "BFCodePython", title: "Python")
/// #setbfextras(definir: "rouge", pour: "film", fond: "red!60!black", perforation-couleur: "orange")
/// #filmbox(style: "rouge", rect(width: 3cm, height: 2cm, fill: luma(200)))
/// #setbfextras(reinitialiser: true)
/// ```
///
/// - pour (none, str, array): type, tableau de types ou groupe visé ; `none` : réglage global (chaque commande qui
///   a la clé la reçoit).
/// - reinitialiser (bool, str): `true` : oublie les réglages global et par type (les styles nommés restent) ; avec
///   des clés, repart des défauts puis les applique ; `"tout"` : oublie aussi les styles de l'utilisateur et remet
///   les styles prédéfinis à leur définition.
/// - definir (none, str): définit le style nommé de ce nom, appelé ensuite par la clé `style:` d'une commande ;
///   `pour` contrôle alors les clés contre un type.
/// - ..cles (any): les clés à régler, par exemple `fond: red`, `title: none`, `style: "sobre"`.
/// -> content
#let setbfextras(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("setbfextras : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none { return reglages-definir-style(_E, definir, pour: pour, commande: "setbfextras", ..cles) }
  if reinitialiser == "tout" { reglages-reinitialiser(_E, styles: true) }
  reglages-regler(_E, pour: pour, reinitialiser: reinitialiser != false, commande: "setbfextras", ..cles)
}
