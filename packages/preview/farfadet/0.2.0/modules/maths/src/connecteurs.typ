// connecteurs.typ — connecteurs logiques : Si, Alors, Donc, Et, Mais, Car, Puisque, SSI (bfcours-commands.sty).
//
//   #si() un triangle est rectangle, #alors() son hypoténuse est son plus grand côté.
//
// Le mot, coloré, sur un fond pâle de la même teinte. Les huit noms sont des noms de premier niveau : la
// majuscule évite le conflit avec les variables `si`, `et`, `car` (c'est pourquoi l'ancien paquet les rangeait
// dans un module `connecteurs`, supprimé). Réglage de tous les connecteurs à la fois :
// `setbfmaths(pour: "connecteurs", …)`.
//

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "reglages.typ": _M
#import "texte.typ": _boite

/// Rend un connecteur : boîte du type `nom`, suivie de l'espace qui sépare le mot de la suite (`\ ` de LaTeX).
#let _connecteur(nom, couleur, mot, style, options) = context {
  let r = reglages-resoudre(
    _M, pour: nom, commande: nom,
    local: options.named() + (couleur: couleur, mot: mot, style: style),
  )
  let boite = _boite(r.mot, r)
  if r.espace-apres { [#boite ] } else { boite }
}

/// Connecteur « Si » : le mot, coloré, sur un fond pâle de la même teinte (rouge par défaut).
///
/// ```typ
/// #si() $x > 0$, #alors() $sqrt(x)$ existe.
/// #si(couleur: "orange") ou #si(mot: "Supposons que")
/// ```
///
/// - couleur (auto, color, str): couleur du connecteur : couleur Typst ou expression xcolor (`"red"`).
/// - mot (auto, content): le mot affiché (`si`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): clés de la boîte : `fontupper` (taille du mot, `"large"`), `colback`, `colframe`, `colupper`, `fond`, `filet`, `texte` (pourcentages de `couleur`), `arc`, `boxsep`, `boxrule`, `left`, `right`, `top`, `bottom`, `espace-apres` (`true` : espace après le mot).
/// -> content
#let si(couleur: auto, mot: auto, style: auto, ..options) = _connecteur("Si", couleur, mot, style, options)

/// Connecteur « Alors » (bleu par défaut).
///
/// ```typ
/// #si() $x > 0$, #alors() $sqrt(x)$ existe.
/// ```
///
/// - couleur (auto, color, str): couleur du connecteur.
/// - mot (auto, content): le mot affiché (`alors`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): mêmes clés que `si`.
/// -> content
#let alors(couleur: auto, mot: auto, style: auto, ..options) = _connecteur("Alors", couleur, mot, style, options)

/// Connecteur « Donc » (violet par défaut).
///
/// ```typ
/// $A B C$ est rectangle en $A$, #donc() $B C^2 = A B^2 + A C^2$.
/// ```
///
/// - couleur (auto, color, str): couleur du connecteur.
/// - mot (auto, content): le mot affiché (`donc`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): mêmes clés que `si`.
/// -> content
#let donc(couleur: auto, mot: auto, style: auto, ..options) = _connecteur("Donc", couleur, mot, style, options)

/// Connecteur « Et » (vert par défaut).
///
/// ```typ
/// $x > 0$ #et() $x < 5$.
/// ```
///
/// - couleur (auto, color, str): couleur du connecteur.
/// - mot (auto, content): le mot affiché (`et`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): mêmes clés que `si`.
/// -> content
#let et(couleur: auto, mot: auto, style: auto, ..options) = _connecteur("Et", couleur, mot, style, options)

/// Connecteur « Mais » (rouge par défaut).
///
/// ```typ
/// Il est positif, #mais() pas nul.
/// ```
///
/// - couleur (auto, color, str): couleur du connecteur.
/// - mot (auto, content): le mot affiché (`mais`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): mêmes clés que `si`.
/// -> content
#let mais(couleur: auto, mot: auto, style: auto, ..options) = _connecteur("Mais", couleur, mot, style, options)

/// Connecteur « Car » (vert par défaut).
///
/// ```typ
/// $x = 2$ #car() $2 x = 4$.
/// ```
///
/// - couleur (auto, color, str): couleur du connecteur.
/// - mot (auto, content): le mot affiché (`car`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): mêmes clés que `si`.
/// -> content
#let car(couleur: auto, mot: auto, style: auto, ..options) = _connecteur("Car", couleur, mot, style, options)

/// Connecteur « Puisque » (violet par défaut).
///
/// ```typ
/// #puisque() $x = 2$, $x^2 = 4$.
/// ```
///
/// - couleur (auto, color, str): couleur du connecteur.
/// - mot (auto, content): le mot affiché (`puisque`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): mêmes clés que `si`.
/// -> content
#let puisque(couleur: auto, mot: auto, style: auto, ..options) = _connecteur("Puisque", couleur, mot, style, options)

/// Connecteur « si et seulement si » (violet par défaut, taille normale).
///
/// ```typ
/// $a b = 0$ #ssi() $a = 0$ ou $b = 0$.
/// ```
///
/// - couleur (auto, color, str): couleur du connecteur.
/// - mot (auto, content): le mot affiché (`si et seulement si`).
/// - style (auto, str, array): nom d'un style de `setbfmaths(definir: …)`.
/// - ..options (any): mêmes clés que `si`.
/// -> content
#let ssi(couleur: auto, mot: auto, style: auto, ..options) = _connecteur("SSI", couleur, mot, style, options)
