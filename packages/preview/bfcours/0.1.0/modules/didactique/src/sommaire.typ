// sommaire.typ — table des matières (\tableofcontents), entrée de sommaire (\liencontent) et setter des
// titres (`setbfsections` : bandeaux SectionBox / SubSectionBox de bfcours-sectionning et jeux de titres).
// (Les liens \liensecretcontent, \lienhautpage, \liensubsection et \addblocktoc, jamais utilisés, ont été
// supprimés de la façade à l'épurage du 08/10/2026.)

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-definir-style, reglages-regler, reglages-reinitialiser
#import "moteur/sectionnement.typ": _RS, tableofcontents as _tableofcontents
#import "moteur/didactique.typ": bf-entree-sommaire

/// Table des matières sur plusieurs colonnes (`\tableofcontents` de bfcours) : titres de section et
/// de sous-section, et environnements didactiques titrés (« **Définition** - sous-titre »).
///
/// ```example
/// #tableofcontents(titre: [Sommaire], colonnes: 2)
/// ```
///
/// - titre (content): titre de la table (LaTeX : `\contentsname`). Défaut : `[Table des matières]`.
/// - colonnes (int): nombre de colonnes (LaTeX : `multicols{2}`). Défaut : `2`.
/// - profondeur (int): niveau de titre le plus profond retenu (LaTeX : `tocdepth`). Défaut : `2`.
/// -> content
#let tableofcontents(titre: [Table des matières], colonnes: 2, profondeur: 2) = _tableofcontents(
  titre: titre,
  colonnes: colonnes,
  profondeur: profondeur,
)

/// Règle les titres (`=`, `==`, `===`, `====`) pour la suite du document : le setter de bfcours-didactique
/// pour le sectionnement (signature commune de tous les setters de bfcours). Ajout : en LaTeX on
/// redéfinit les styles `SectionBox` et `SubSectionBox` par `\tcbset`.
///
/// **Jeux de titres.** Quatre jeux prédéfinis, choisis par la clé `jeu` (ou par la clé `titres:` du
/// modèle `bfcours`) :
///
/// | Jeu | Rendu |
/// |---|---|
/// | `"bfcours"` (défaut) | bandeau gris-noir arrondi pour `=` (`SectionBox`), cadre ouvert à numéro pour `==` (`SubSectionBox`), niveau 3 gras numéroté, niveau 4 gras non numéroté |
/// | `"sobre"` | numéro coloré et filet fin sous les niveaux 1 et 2, sans grande taille (fiches, activités) |
/// | `"classique"` | titres gras d'article, sans bandeau ni filet (documents denses, copies) |
/// | `"documentation"` | rendu des documentations : gros numéro coloré, filet pâle sous le niveau 1 |
///
/// **Clés communes à tous les jeux** (réglage global, ou d'un niveau par `pour: "SectionBox"` pour le
/// niveau 1 et `pour: "SubSectionBox"` pour le niveau 2) : `couleur` (couleur du bandeau, du numéro ou
/// du filet ; défaut : une couleur nommée de bfcours propre au jeu, lue au rendu), `hauteur` (hauteur
/// du bandeau, ou hauteur minimale de la zone du titre), `numerotation` (`false` : titres sans
/// numéro), `coltitle`, `fonttitle`, `before-skip`, `after-skip`. Clés de `SectionBox` : `left` (3mm),
/// `arc` (1mm) ; de `SubSectionBox` : `lefthand-width` (1cm), `sidebyside-gap` (5mm), `left-skip` (1cm),
/// `right` (20pt), `line-width` (2pt), `arc` (10pt), `width-extra` (3cm, ajout de `\calcwidth`),
/// `width-max` (80 %). La couleur de base du jeu `bfcours` se règle aussi comme en LaTeX :
/// `setbfcolors(BaseColor: …)`.
///
/// | Appel | Effet |
/// |---|---|
/// | `setbfsections(jeu: "sobre")` | change de jeu de titres |
/// | `setbfsections(cle: v)` | réglage global (les deux niveaux de bandeau) |
/// | `setbfsections(pour: "SectionBox", cle: v)` | réglage du niveau 1 (ou `"SubSectionBox"`, niveau 2) |
/// | `setbfsections(definir: "nom", cle: v)` | définit un style nommé (appel : `style: "nom"`) |
/// | `setbfsections(reinitialiser: true)` | retour aux défauts (jeu `bfcours`) ; styles gardés |
/// | `setbfsections(reinitialiser: "tout")` | idem, et oublie les styles |
///
/// ```example
/// #setbfsections(pour: "SectionBox", couleur: "prop!70!black", hauteur: 1cm)
/// #setbfsections(couleur: "defi")
/// #setbfsections(jeu: "sobre", numerotation: false)
/// #setbfsections(reinitialiser: true)
/// ```
///
/// - pour (str, array, none): `"SectionBox"`, `"SubSectionBox"`, un tableau des deux ; `none` : les deux niveaux.
/// - reinitialiser (bool, str): `true`, `false` ou `"tout"`.
/// - definir (str, none): nom d'un style à définir.
/// - cles (any): les clés à régler.
/// -> content
#let setbfsections(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("setbfsections : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none { return reglages-definir-style(_RS, definir, pour: pour, ..cles) }
  if reinitialiser == "tout" { reglages-reinitialiser(_RS, styles: true) }
  reglages-regler(_RS, pour: pour, reinitialiser: reinitialiser != false, ..cles)
}

/// Affiche une catégorie en gras et dépose une entrée au sommaire « **catégorie** - titre »
/// (`\liencontent{catégorie}{titre}`, avec la mise au sommaire de `\bfdLiencontentRegister`).
///
/// ```example
/// #liencontent[Définition][Vecteur nul]
/// ```
///
/// - categorie (content): catégorie, affichée en gras.
/// - titre (content, none): titre de l'entrée.
/// -> content
#let liencontent(categorie, titre) = [#bf-entree-sommaire(categorie, titre)#strong(categorie)]
