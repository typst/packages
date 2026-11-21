// habillage.typ (farfadet-extras) — façade publique : habillage d'une figure par du texte (paquet wrap-it,
// embarqué dans vendor/).
// Réglages : `setbfextras` (src/regler.typ), type `habiller`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: environnements
#import "moteur/complements.typ" as m
#import "reglages.typ": _resoudre

/// Place une figure sur un côté et fait couler le texte autour d'elle, sur la hauteur de la figure ; en dessous,
/// le texte reprend toute la largeur. À mettre dans un paragraphe assez long : si le texte est plus court que la
/// figure, la figure déborde en dessous.
///
/// ````typ
/// #let fig = rect(width: 3.2cm, height: 2.4cm, fill: rgb("#dbe8f5"), stroke: 0.6pt + rgb("#2f5d8a"))[
///   #align(center + horizon)[Figure]
/// ]
/// #habiller(fig)[
///   Dans un triangle rectangle, le carré de l'hypoténuse est égal à la somme des carrés des deux autres côtés.
///   Cette égalité permet de calculer une longueur manquante dès que les deux autres sont connues, et sa
///   réciproque permet de prouver qu'un triangle est rectangle. On l'applique en trois temps : repérer
///   l'hypoténuse, écrire l'égalité, puis résoudre l'équation obtenue.
/// ]
/// ````
///
/// La syntaxe environnement donne le même résultat : la figure et les options vont dans `#begin`, le texte
/// entre `#begin` et `#end` : `#begin(habiller, fig, cote: "gauche")` … `#end(habiller)`.
///
/// - figure (content): ce qui est posé sur le côté : une image, une `figure`, un dessin.
/// - texte (content): le texte qui l'habille.
/// - ..options (any): clés locales : `cote` (`"droite"` ou `"gauche"`), `haut` (`true` : figure en haut du texte ;
///   `false` : en bas), `ecart` (1 em : distance figure-texte), `largeur` (`auto` : largeur réservée à la colonne
///   de la figure), `debord` (0 pt : la figure déborde de cette longueur dans la marge), `style`.
/// -> content
#let habiller(figure, texte, ..options) = context {
  let r = _resoudre("habiller", options)
  let texte = if type(texte) == content { environnements(texte) } else { texte }
  m.habiller(figure, texte, cote: r.cote, haut: r.haut, ecart: r.ecart, largeur: r.largeur, debord: r.debord)
}
