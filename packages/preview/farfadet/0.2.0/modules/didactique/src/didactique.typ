// didactique.typ — façade publique des environnements didactiques de farfadet-didactique.
//
// FICHIER Fichier généré : ne pas le modifier à la main (relancer le
// script après avoir changé le catalogue). Les constructeurs qui parlent au moteur sont dans
// src/construction.typ ; les défauts et contrôles dans src/catalogue.typ (généré aussi).

#import "construction.typ": _rendre

/// Théorème : énoncé central du cours, en banderole de la couleur `thm`.
///
/// Syntaxe : `#theoreme[Titre][Corps]` ou `#theoreme[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Theoreme", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1529.
///
/// ```example
/// #theoreme[Pythagore][Dans un triangle rectangle, $a^2 + b^2 = c^2$.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `true`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "thm" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `false`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"coeur"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `2mm`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let theoreme(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "Theoreme",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (:)
)

/// Définition d'un mot ou d'une notion, en banderole de la couleur `defi`.
///
/// Syntaxe : `#definition[Titre][Corps]` ou `#definition[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Definition", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1563.
///
/// ```example
/// #definition[Vecteur][Un vecteur est défini par une direction, un sens et une norme.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `true`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "defi" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `false`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"cle"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `2mm`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let definition(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "Definition",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (:)
)

/// Propriété à retenir, en banderole de la couleur `prop`.
///
/// Syntaxe : `#propriete[Titre][Corps]` ou `#propriete[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Propriete", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1564.
///
/// ```example
/// #propriete[Relation de Chasles][$arrow(A B) + arrow(B C) = arrow(A C)$.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `true`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "prop" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `false`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"roue"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `2mm`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let propriete(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "Propriete",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (:)
)

/// Démonstration, en banderole de la couleur `demo` ; cadre tracé à la craie par défaut.
///
/// Syntaxe : `#demonstration[Titre][Corps]` ou `#demonstration[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Demonstration", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1565.
///
/// ```example
/// #demonstration[Chasles][On décompose $arrow(A C)$ en passant par $B$.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "demo" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `true`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"equerre"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `2mm`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let demonstration(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "Demonstration",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (:)
)

/// Méthode de résolution, en banderole de la couleur `meth`.
///
/// Syntaxe : `#methode[Titre][Corps]` ou `#methode[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Methode", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1566.
///
/// ```example
/// #methode[Résoudre une équation][Isoler l'inconnue.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `true`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "meth" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `false`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `2mm`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let methode(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "Methode",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (:)
)

/// Activité de découverte, en banderole de la couleur `act` ; sécable par défaut.
///
/// Syntaxe : `#activite[Titre][Corps]` ou `#activite[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Activite", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1567.
///
/// ```example
/// #activite[Découverte][Tracer deux vecteurs de même direction.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "act" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `true`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `false`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"fanion"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `2mm`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let activite(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "Activite",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (:)
)

/// Encadré de vocabulaire, en banderole de la couleur `nota`.
///
/// Syntaxe : `#vocabulaire[Titre][Corps]` ou `#vocabulaire[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Vocabulaire", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1568.
///
/// ```example
/// #vocabulaire[Hypoténuse][Côté opposé à l'angle droit.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `true`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "nota" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `false`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `2mm`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let vocabulaire(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "Vocabulaire",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (:)
)

/// Solution d'un exercice ou d'une activité, en banderole verte.
///
/// Syntaxe : `#solution[Titre][Corps]` ou `#solution[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Solution", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1570.
///
/// ```example
/// #solution[Question 1][On trouve $x = 3$.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "green" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `false`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"coche"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `2mm`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let solution(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "Solution",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (:)
)

/// Exemple, dans le cadre à équerre de bfcours.
///
/// Syntaxe : `#exemple[Titre][Corps]` ou `#exemple[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Exemple", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1617.
///
/// ```example
/// #exemple[Avec des entiers][$3 + 4 = 7$.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : `auto`. LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"fleche"`. LaTeX : ajout.
/// - colback (color, str, auto): Couleur du fond. Défaut : `auto`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - couleur-accent (color, str, auto): Couleur d'accent du corps (`acc`, `voc`…). `auto` : celle du type. Défaut : `auto`. LaTeX : `\CouleurTexteAccent` du corps.
/// - line-width (length): Épaisseur des traits du cadre. Défaut : `1.494pt`. LaTeX : `line width` / `ultra thick`.
/// - corner-size (length): Longueur des branches de l'équerre et du trait vertical. Défaut : `2cm`. LaTeX : `2cm` de `bfd tikz corners overlay`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let exemple(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  icone: auto,
  embleme: auto,
  colback: auto,
  colframe: auto,
  fonttitle: auto,
  couleur-accent: auto,
  line-width: auto,
  corner-size: auto,
  style: auto,
  ..args,
) = _rendre(
  "Exemple",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, icone: icone, embleme: embleme, colback: colback, colframe: colframe, fonttitle: fonttitle, couleur-accent: couleur-accent, line-width: line-width, corner-size: corner-size, style: style),
  label,
  args,
  (:)
)

/// Contre-exemple, dans le cadre à équerre rouge.
///
/// Syntaxe : `#contre-exemple[Titre][Corps]` ou `#contre-exemple[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "ContreExemple", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1640.
///
/// ```example
/// #contre-exemple[Une fonction][$x |-> |x|$ n'est pas dérivable en $0$.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : `auto`. LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"attention"`. LaTeX : ajout.
/// - colback (color, str, auto): Couleur du fond. Défaut : `auto`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - couleur-accent (color, str, auto): Couleur d'accent du corps (`acc`, `voc`…). `auto` : celle du type. Défaut : `auto`. LaTeX : `\CouleurTexteAccent` du corps.
/// - line-width (length): Épaisseur des traits du cadre. Défaut : `1.494pt`. LaTeX : `line width` / `ultra thick`.
/// - corner-size (length): Longueur des branches de l'équerre et du trait vertical. Défaut : `2cm`. LaTeX : `2cm` de `bfd tikz corners overlay`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let contre-exemple(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  icone: auto,
  embleme: auto,
  colback: auto,
  colframe: auto,
  fonttitle: auto,
  couleur-accent: auto,
  line-width: auto,
  corner-size: auto,
  style: auto,
  ..args,
) = _rendre(
  "ContreExemple",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, icone: icone, embleme: embleme, colback: colback, colframe: colframe, fonttitle: fonttitle, couleur-accent: couleur-accent, line-width: line-width, corner-size: corner-size, style: style),
  label,
  args,
  (:)
)

/// Remarque en marge, avec le crayon et la barre en serpentin. Le titre éventuel n'est pas affiché (il sert au sommaire et aux cartes Anki).
///
/// Syntaxe : `#remarque[Titre][Corps]` ou `#remarque[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Remarque", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1581.
///
/// ```example
/// #remarque[Cette égalité reste vraie pour des vecteurs nuls.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `false`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : `auto`. LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `true`. LaTeX : `breakable`.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `auto`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"loupe"`. LaTeX : ajout.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - couleur-accent (color, str, auto): Couleur d'accent du corps (`acc`, `voc`…). `auto` : celle du type. Défaut : `auto`. LaTeX : `\CouleurTexteAccent` du corps.
/// - barre (str): Barre verticale : serpentin, trait droit ou aucune. Défaut : `"snake"`. LaTeX : option bclogo `barre`.
/// - logo-size (length): Côté du logo (crayon). Défaut : `16.9pt`. LaTeX : taille de `\bccrayon`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let remarque(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  icone: auto,
  embleme: auto,
  fonttitle: auto,
  couleur-accent: auto,
  barre: auto,
  logo-size: auto,
  style: auto,
  ..args,
) = _rendre(
  "Remarque",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, icone: icone, embleme: embleme, fonttitle: fonttitle, couleur-accent: couleur-accent, barre: barre, logo-size: logo-size, style: style),
  label,
  args,
  (:)
)

/// Notation, dans un cadre déchiré à étiquette inclinée de la couleur `defi`.
///
/// Syntaxe : `#notation[Titre][Corps]` ou `#notation[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Notation", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1680.
///
/// ```example
/// #notation[Vecteur][On note $arrow(u)$ un vecteur.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `false`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "defi" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"etoile5"`. LaTeX : ajout.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `16pt`. LaTeX : `fonttitle`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `5mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `5mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `10mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `5mm`. LaTeX : `bottom`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - line-width (length): Épaisseur des traits du cadre. Défaut : `1.594pt`. LaTeX : `line width` / `ultra thick`.
/// - couleur-titre (color, str, auto): Couleur de l'étiquette inclinée. `auto` : celle du cadre. Défaut : `auto`. LaTeX : 4e argument `[couleur titre]`.
/// - largeur-titre (length, auto): Largeur de l'étiquette inclinée. `auto` : celle du type. Défaut : `auto`. LaTeX : 5e argument `[largeur titre]`.
/// - amplitude (length): Amplitude du bord déchiré. Défaut : `2.49pt`. LaTeX : `amplitude` de `random steps`.
/// - segment-length (length): Pas du bord déchiré. Défaut : `0.4cm`. LaTeX : `segment length` de `random steps`.
/// - title-angle (angle): Inclinaison de l'étiquette. Défaut : `-10deg`. LaTeX : `rotate=10` du titre.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let notation(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  embleme: auto,
  fonttitle: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  drop-shadow: auto,
  line-width: auto,
  couleur-titre: auto,
  largeur-titre: auto,
  amplitude: auto,
  segment-length: auto,
  title-angle: auto,
  style: auto,
  ..args,
) = _rendre(
  "Notation",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, embleme: embleme, fonttitle: fonttitle, left: left, right: right, top: top, bottom: bottom, drop-shadow: drop-shadow, line-width: line-width, couleur-titre: couleur-titre, largeur-titre: largeur-titre, amplitude: amplitude, segment-length: segment-length, title-angle: title-angle, style: style),
  label,
  args,
  (:)
)

/// Coup de pouce, dans un cadre déchiré à étiquette inclinée de la couleur `nota`.
///
/// Syntaxe : `#aide[Titre][Corps]` ou `#aide[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Aide", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1687.
///
/// ```example
/// #aide[Pense à factoriser.]
/// ```
///
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `false`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "nota" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `16pt`. LaTeX : `fonttitle`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `5mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `5mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `10mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `5mm`. LaTeX : `bottom`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - line-width (length): Épaisseur des traits du cadre. Défaut : `1.594pt`. LaTeX : `line width` / `ultra thick`.
/// - couleur-titre (color, str, auto): Couleur de l'étiquette inclinée. `auto` : celle du cadre. Défaut : `auto`. LaTeX : 4e argument `[couleur titre]`.
/// - largeur-titre (length, auto): Largeur de l'étiquette inclinée. `auto` : celle du type. Défaut : `auto`. LaTeX : 5e argument `[largeur titre]`.
/// - amplitude (length): Amplitude du bord déchiré. Défaut : `2.49pt`. LaTeX : `amplitude` de `random steps`.
/// - segment-length (length): Pas du bord déchiré. Défaut : `0.4cm`. LaTeX : `segment length` de `random steps`.
/// - title-angle (angle): Inclinaison de l'étiquette. Défaut : `-10deg`. LaTeX : `rotate=10` du titre.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let aide(
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  embleme: auto,
  fonttitle: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  drop-shadow: auto,
  line-width: auto,
  couleur-titre: auto,
  largeur-titre: auto,
  amplitude: auto,
  segment-length: auto,
  title-angle: auto,
  style: auto,
  ..args,
) = _rendre(
  "Aide",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, embleme: embleme, fonttitle: fonttitle, left: left, right: right, top: top, bottom: bottom, drop-shadow: drop-shadow, line-width: line-width, couleur-titre: couleur-titre, largeur-titre: largeur-titre, amplitude: amplitude, segment-length: segment-length, title-angle: title-angle, style: style),
  label,
  args,
  (:)
)

/// Encart « Un peu d'histoire » : onglet sépia, titre (premier contenu, obligatoire) et auteur facultatif.
///
/// Syntaxe : `#histoire[Titre][Corps]` (titre obligatoire, comme en LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "Histoire", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:2610.
///
/// ```example
/// #histoire(auteur: [D'après Euclide])[Les Éléments][Euclide rédige les *Éléments* vers 300 avant notre ère.]
/// ```
///
/// - auteur (content, none): Auteur ou source, en italique sous le titre. Défaut : `none`. LaTeX : `[auteur]` (2e argument, optionnel).
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "histoire" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - colback (color, str, auto): Couleur du fond. Défaut : `auto`. LaTeX : `colback`.
/// - arc (length): Rayon des coins. Défaut : `4pt`. LaTeX : `arc`.
/// - onglet (content): Libellé de l'onglet. Défaut : `[Un peu d'histoire]`. LaTeX : 2e argument de `bfd syBrisse`.
/// - boxrule (length): Épaisseur du cadre. Défaut : `0.8pt * 72 / 72.27`. LaTeX : `boxrule`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre puis le corps.
/// -> content
#let histoire(
  auteur: none,
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  embleme: auto,
  colback: auto,
  arc: auto,
  onglet: auto,
  boxrule: auto,
  style: auto,
  ..args,
) = _rendre(
  "Histoire",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, embleme: embleme, colback: colback, arc: arc, onglet: onglet, boxrule: boxrule, style: style),
  label,
  args,
  (auteur: auteur,)
)

/// Environnement didactique à couleur libre : le titre (premier contenu, obligatoire) est le texte de la banderole.
///
/// Syntaxe : `#bf-env[Titre][Corps]` (titre obligatoire, comme en LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "bfEnv", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:2139.
///
/// ```example
/// #bf-env(sous-titre: [à retenir], couleur: "meth")[Bilan][Ce qu'il faut retenir.]
/// ```
///
/// - sous-titre (content, none): Sous-titre, dans le nœud à droite de la banderole. Défaut : `none`. LaTeX : `[sous-titre]`.
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `true`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "prop" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - craie (bool): Cadre « à la craie » (replié sur le cadre net si l'environnement se coupe). Défaut : `false`. LaTeX : ajout.
/// - icone (content, none, auto): Pictogramme devant le nom dans la banderole (à la place du crayon pour la remarque). Défaut : `none`. LaTeX : ajout ; sur `\begin{Remarque}` : option bclogo `logo`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - variant (str): Habillage des bords : `"lignes"` (filets gauche et bas), `"minimal"` (fin filet gauche, sans sous-titre), `"sidebar"` (bande pleine à gauche). Se règle pour tout le document par `bfd-activate-variant` ou `bfset(variant: …)`. Défaut : `"lignes"`. LaTeX : `\bfdActivateVariant`, `\bfset{variant=…}`.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - banner-arc (color, str, auto): Couleur des deux arcs sous la banderole. `auto` : couleur!80. Défaut : `auto`. LaTeX : 1er argument de `bfd banner arc`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `"large"`. LaTeX : `fonttitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - edge-width (length): Épaisseur des filets gauche et bas. Défaut : `0.5mm`. LaTeX : `line width` de `bfd edge overlay`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `4mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `4mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `2mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `0pt`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - title-xshift (length): Décalage horizontal de la banderole depuis le bord gauche. Défaut : `1cm`. LaTeX : `xshift` de `attach boxed title to top left`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre puis le corps.
/// -> content
#let bf-env(
  sous-titre: none,
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  breakable: auto,
  craie: auto,
  icone: auto,
  embleme: auto,
  variant: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  banner-arc: auto,
  coltitle: auto,
  fonttitle: auto,
  arc: auto,
  edge-width: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  drop-shadow: auto,
  title-xshift: auto,
  style: auto,
  ..args,
) = _rendre(
  "bfEnv",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, breakable: breakable, craie: craie, icone: icone, embleme: embleme, variant: variant, colback: colback, colframe: colframe, colbacktitle: colbacktitle, banner-arc: banner-arc, coltitle: coltitle, fonttitle: fonttitle, arc: arc, edge-width: edge-width, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, drop-shadow: drop-shadow, title-xshift: title-xshift, style: style),
  label,
  args,
  (sous-titre: sous-titre,)
)

/// Cadre à bord déchiré et étiquette inclinée (base de `notation` et `aide`). Le titre de l'étiquette est le premier contenu (facultatif, « Propriété » par défaut). Couleur par défaut : orange.
///
/// Syntaxe : `#cracked[Titre][Corps]` ou `#cracked[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "cracked", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1668.
///
/// ```example
/// #cracked(sous-titre: [rappel])[À savoir][Un cadre à bord déchiré.]
/// ```
///
/// - sous-titre (content, none): Sous-titre, dans le nœud en haut à droite. Défaut : `none`. LaTeX : 2e argument `[sous-titre]`.
/// - label (label, none): Rend l'environnement référençable : avec `label: <chasles>`, `@chasles` affiche « Propriété 2.3 » s'il est numéroté, sinon son titre. Propre à chaque objet. LaTeX : `label`.
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - anki (bool): Dépose une carte Anki (recto : type et titre ou numéro ; verso : corps), invisible dans le PDF. Défaut : `false`. LaTeX : ajout.
/// - sommaire (bool, content): Entrée au sommaire (`tableofcontents`). Un contenu remplace le libellé de l'entrée. Défaut : `false`. LaTeX : ajout (en LaTeX, `\liencontent` met toujours au sommaire).
/// - numero (bool): Numérote l'environnement (« Définition 2.3 »). Défaut : `false`. LaTeX : ajout (les environnements bfcours ne sont pas numérotés).
/// - numerotation (str): Remise à zéro du compteur : `"section"` (numéro « 2.3 ») ou `"globale"` (numéro « 3 »). Défaut : `"section"`. LaTeX : ajout.
/// - compteur (str): `"par-type"` (un compteur par type) ou `"commun"` (un compteur partagé par tous les types qui le choisissent). Défaut : `"par-type"`. LaTeX : ajout.
/// - nameref (content, auto): Texte affiché par `@étiquette` quand l'environnement n'est pas numéroté. `auto` : le titre, sinon le nom du type. Défaut : `auto`. LaTeX : `nameref`.
/// - couleur (color, str, auto): Teinte de l'environnement : couleur Typst ou nom xcolor (`"thm"`, `"red!50!black"`). Par défaut, la couleur nommée de bfcours propre au type, lue au moment du rendu : `setbfcolors(thm: …)`, `definecolor` et les palettes la changent. Défaut : la couleur nommée "orange" (lue au rendu : suit `setbfcolors`). LaTeX : ajout (en LaTeX : palette `\bfset`, `\bfdSetColors`).
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - fonttitle (str, length): Taille du titre : nom de taille LaTeX (`"large"`, `"Large"`…) ou longueur. Défaut : `16pt`. LaTeX : `fonttitle`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `5mm`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `5mm`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `10mm`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `5mm`. LaTeX : `bottom`.
/// - drop-shadow (bool): Ombre portée. Défaut : `true`. LaTeX : `drop shadow` (`drop fuzzy shadow` pour `cracked`).
/// - line-width (length): Épaisseur des traits du cadre. Défaut : `1.594pt`. LaTeX : `line width` / `ultra thick`.
/// - couleur-titre (color, str, auto): Couleur de l'étiquette inclinée. `auto` : celle du cadre. Défaut : `auto`. LaTeX : 4e argument `[couleur titre]`.
/// - largeur-titre (length, auto): Largeur de l'étiquette inclinée. `auto` : celle du type. Défaut : `auto`. LaTeX : 5e argument `[largeur titre]`.
/// - amplitude (length): Amplitude du bord déchiré. Défaut : `2.49pt`. LaTeX : `amplitude` de `random steps`.
/// - segment-length (length): Pas du bord déchiré. Défaut : `0.4cm`. LaTeX : `segment length` de `random steps`.
/// - title-angle (angle): Inclinaison de l'étiquette. Défaut : `-10deg`. LaTeX : `rotate=10` du titre.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let cracked(
  sous-titre: none,
  label: none,
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  anki: auto,
  sommaire: auto,
  numero: auto,
  numerotation: auto,
  compteur: auto,
  nameref: auto,
  couleur: auto,
  embleme: auto,
  fonttitle: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  drop-shadow: auto,
  line-width: auto,
  couleur-titre: auto,
  largeur-titre: auto,
  amplitude: auto,
  segment-length: auto,
  title-angle: auto,
  style: auto,
  ..args,
) = _rendre(
  "cracked",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, anki: anki, sommaire: sommaire, numero: numero, numerotation: numerotation, compteur: compteur, nameref: nameref, couleur: couleur, embleme: embleme, fonttitle: fonttitle, left: left, right: right, top: top, bottom: bottom, drop-shadow: drop-shadow, line-width: line-width, couleur-titre: couleur-titre, largeur-titre: largeur-titre, amplitude: amplitude, segment-length: segment-length, title-angle: title-angle, style: style),
  label,
  args,
  (sous-titre: sous-titre,)
)

/// Conteneur neutre : ni cadre, ni fond, ni marge. (Distinct du mot-clé `none` de Typst.)
///
/// Syntaxe : `#neutre[Corps]`.
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "None", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:2113.
///
/// ```example
/// #neutre[Contenu groupé.]
/// ```
///
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le corps.
/// -> content
#let neutre(
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  breakable: auto,
  style: auto,
  ..args,
) = _rendre(
  "None",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, breakable: breakable, style: style),
  none,
  args,
  (:)
)

/// Boîte à cadre et titre en bandeau, à la couleur d'accent courante (`\boitecouleur`) : gris foncé hors environnement, couleur de l'environnement dedans.
///
/// Syntaxe : `#boite[Titre][Corps]` ou `#boite[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "boite", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : BRI:12.
///
/// ```example
/// #boite[Bilan][Ce qu'il faut retenir.]
/// ```
///
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `0pt`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `0pt`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `0pt`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `0pt`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - boxrule (length): Épaisseur du cadre. Défaut : `0.4pt`. LaTeX : `boxrule`.
/// - width (length, ratio): Largeur de la boîte. Défaut : `100%`. LaTeX : `width`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let boite(
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  breakable: auto,
  embleme: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  coltitle: auto,
  arc: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  boxrule: auto,
  width: auto,
  style: auto,
  ..args,
) = _rendre(
  "boite",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, breakable: breakable, embleme: embleme, colback: colback, colframe: colframe, colbacktitle: colbacktitle, coltitle: coltitle, arc: arc, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, boxrule: boxrule, width: width, style: style),
  none,
  args,
  (:)
)

/// Forme « environnement » de `boite` (même rendu, mêmes clés tcolorbox).
///
/// Syntaxe : `#bfbox[Titre][Corps]` ou `#bfbox[Corps]` (titre facultatif : l'argument optionnel LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "bfbox", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:2199.
///
/// ```example
/// #bfbox(colframe: "defi")[Bilan][Ce qu'il faut retenir.]
/// ```
///
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - breakable (bool): Autorise la coupure entre deux pages. Défaut : `false`. LaTeX : `breakable`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `auto`. LaTeX : `colframe`.
/// - colbacktitle (color, str, auto): Couleur du ruban (ou du bandeau) de titre. `auto` : la couleur de l'environnement. Défaut : `auto`. LaTeX : `colbacktitle`.
/// - coltitle (color, str): Couleur du texte du titre. Défaut : `white`. LaTeX : `coltitle`.
/// - arc (length): Rayon des coins. Défaut : `1mm`. LaTeX : `arc`.
/// - left (length): Marge intérieure gauche (sans `boxsep`). Défaut : `0pt`. LaTeX : `left`.
/// - right (length): Marge intérieure droite (sans `boxsep`). Défaut : `0pt`. LaTeX : `right`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `0pt`. LaTeX : `top`.
/// - bottom (length): Marge intérieure basse (sans `boxsep`). Défaut : `0pt`. LaTeX : `bottom`.
/// - boxsep (length): Marge ajoutée sur les quatre côtés. Défaut : `1mm`. LaTeX : `boxsep`.
/// - boxrule (length): Épaisseur du cadre. Défaut : `0.4pt`. LaTeX : `boxrule`.
/// - width (length, ratio): Largeur de la boîte. Défaut : `100%`. LaTeX : `width`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre (facultatif) puis le corps.
/// -> content
#let bfbox(
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  breakable: auto,
  embleme: auto,
  colback: auto,
  colframe: auto,
  colbacktitle: auto,
  coltitle: auto,
  arc: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  boxrule: auto,
  width: auto,
  style: auto,
  ..args,
) = _rendre(
  "bfbox",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, breakable: breakable, embleme: embleme, colback: colback, colframe: colframe, colbacktitle: colbacktitle, coltitle: coltitle, arc: arc, left: left, right: right, top: top, bottom: bottom, boxsep: boxsep, boxrule: boxrule, width: width, style: style),
  none,
  args,
  (:)
)

/// Cadre de figure légendée : étiquette noire (premier contenu) dans l'angle supérieur gauche, contenu centré.
///
/// Syntaxe : `#boite-figure[Titre][Corps]` (titre obligatoire, comme en LaTeX).
/// Toutes les clés se règlent aussi pour le document : `setbfenvironments(pour: "boiteFigure", …)`,
/// ou par un style nommé (`setbfenvironments(definir: "nom", …)`, clé `style`). Source LaTeX : NBE:1608.
///
/// ```example
/// #boite-figure[Figure 1][Un schéma.]
/// ```
///
/// - version (str): `"toutes"`, `"prof"` ou `"eleve"` : n'affiche l'objet que dans la version indiquée du document. Défaut : `"toutes"`. LaTeX : ajout.
/// - rendu (str, function): Rendu de la boîte : `"bf"` (le rendu de bfcours), `"rd"` (la boîte du paquet `rdboites` qui correspond à l'environnement), un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`), le nom d'un skin enregistré par `setbfskins`, ou un skin (fonction `d => contenu`, ou variante à options figées `bfskin(…)` ; contrat : `skins/CONTRAT.md`). Numérotation, étiquette, sommaire, Anki et version prof/élève restent assurés quel que soit le rendu. `style: "rd"` règle d'un coup tout le document. Défaut : `"bf"`. LaTeX : ajout.
/// - rd (dictionary): Clés passées à la boîte `rdboites` en style `"rd"` (`colframe`, `arc`, `colback`…) ; sans effet en style `"bf"`. Elles l'emportent sur les clés de bfcours réglées (`couleur`, `colback`, `colframe`…), que le style « rd » traduit vers la boîte. Défaut : `(:)`. LaTeX : ajout.
/// - skin (dictionary): Options transmises au skin (champ `d.options`) : `icone`, `epaisseur`… pour un skin intégré (`skin: (icone: "cle")`), libres pour un skin personnel ; elles l'emportent sur celles d'une variante `bfskin`. Sans effet avec les rendus `"bf"` et `"rd"`. Défaut : `(:)`. LaTeX : ajout.
/// - before-skip (length, auto): Espace vertical avant l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `before skip`.
/// - after-skip (length, auto): Espace vertical après l'objet. `auto` : calibrage de bfcours. Défaut : `auto`. LaTeX : `after skip`.
/// - embleme (str, function, content, none, auto): Icône préférentielle du type pour les skins (`"auto"` ou `none` : l'icône propre au skin) : nom d'une icône du jeu commun, fonction `couleur => contenu` ou contenu. Passe après la clé `icone` et l'option `icone` du skin, avant l'icône propre du skin. Sans effet sur le rendu `"bf"` (la clé `icone` règle celui-ci) et sur le style `"rd"`. Défaut : `"auto"`. LaTeX : ajout.
/// - colback (color, str, auto): Couleur du fond. Défaut : `white`. LaTeX : `colback`.
/// - colframe (color, str, auto): Couleur des filets et du cadre du sous-titre. `auto` : couleur!50. Défaut : `"black!50"`. LaTeX : `colframe`.
/// - arc (length): Rayon des coins. Défaut : `2mm`. LaTeX : `arc`.
/// - top (length): Marge intérieure haute (sans `boxsep`). Défaut : `7mm`. LaTeX : `top`.
/// - boxrule (length): Épaisseur du cadre. Défaut : `0.5mm`. LaTeX : `boxrule`.
/// - halign (str): Alignement horizontal du contenu. Défaut : `"center"`. LaTeX : `halign`.
/// - style (str, array, auto): style(s) nommé(s) à appliquer (sous les clés écrites ici).
/// - args (content): le titre puis le corps.
/// -> content
#let boite-figure(
  version: auto,
  rendu: auto,
  rd: auto,
  skin: auto,
  before-skip: auto,
  after-skip: auto,
  embleme: auto,
  colback: auto,
  colframe: auto,
  arc: auto,
  top: auto,
  boxrule: auto,
  halign: auto,
  style: auto,
  ..args,
) = _rendre(
  "boiteFigure",
  (version: version, rendu: rendu, rd: rd, skin: skin, before-skip: before-skip, after-skip: after-skip, embleme: embleme, colback: colback, colframe: colframe, arc: arc, top: top, boxrule: boxrule, halign: halign, style: style),
  none,
  args,
  (:)
)
