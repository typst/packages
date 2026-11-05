// publique.typ (farfadet-socle) — FAÇADE publique du socle, aux noms LaTeX exacts (phase 2, 06/10/2026 ;
// épurage du 07/10/2026).
//
// - Version professeur / élève : `ifcorrection` (bfcours-use_rdexo_rdcrep.sty:285 ; trois formes).
// - Réglages : `setbfsocle` (version, style des corrections), `setbfcolors` (couleurs nommées de
//   bfcours et macros d'état), `definir-style` (styles nommés communs à tous les paquets).
// - Couleurs : port fidèle de bfcours-colors.sty (`couleurs-tabular`, `couleurs-secondary-tabular`,
//   `reset-couleurs-tabular`, `reset-couleurs-secondary-tabular`, `couleur-texte-accent`,
//   `reset-couleur-texte-accent`, `couleur-item`, `reset-item-base-color`, les 4 macros d'état lues dans les
//   cours en lecture), plus `definecolor`, `colorlet`, `textcolor` de xcolor et l'ajout `xcolor`
//   (expression → couleur, qui lit aussi toute macro d'état : `xcolor("currentFrameColor")`).
//
// Anciens noms SUPPRIMÉS sans alias : `si-prof`, `selon-version`, `est-version-prof`, `si-eleve`,
// `est-version-eleve` ; `SiCorrection`, `TFCorrection` (→ `ifcorrection`), `regler-socle`
// (→ `setbfsocle`, ses clés de macros → `setbfcolors`), les lecteurs de 15 macros jamais lues dans le
// corpus (`currentFrameColor()`… → `xcolor("currentFrameColor")`) (épurage, 07/10/2026).
// Toutes les fonctions s'appuient sur le moteur (src/*.typ, exporté par interne.typ) : un autre paquet
// qui veut réexporter une de ces commandes la reconstruit en une ligne sur le nom `bf-…` du moteur.

#import "version.typ" as _v
#import "couleurs.typ" as _c
#import "reglages.typ" as _r

// =====================================================================
// Version professeur / version élève
// =====================================================================

/// `\ifcorrection … \else … \fi` : la conditionnelle professeur / élève, en trois formes.
///
/// - `ifcorrection[prof][élève]` : deux branches ;
/// - `ifcorrection[prof]` : rien en version élève ; `ifcorrection[][élève]` : rien en version professeur ;
/// - `ifcorrection()` sans argument : renvoie le booléen (vrai en version professeur), dans un `context`.
///
/// La version se choisit par la clé `correction` du modèle ou de `setbfsocle` ;
/// `--input correction=true|false` à la compilation l'emporte toujours.
///
/// ```example
/// #ifcorrection[Corrigé : $x = 3$.][Cadre à compléter.]
/// #ifcorrection[][Complète la phrase ci-dessous.]
/// #context if ifcorrection() [Version professeur.] else [Version élève.]
/// ```
///
/// - ..branches (content): zéro, un ou deux contenus (professeur, élève).
/// -> content | bool
#let ifcorrection(..branches) = _v.bf-ifcorrection(commande: "ifcorrection", ..branches)

// =====================================================================
// Réglages du socle et styles nommés communs
// =====================================================================

/// Réglage du socle (convention commune des setters `setbf…`). Les appels s'ajoutent clé par clé ; une
/// clé inconnue ou une valeur invalide arrête la compilation avec la liste des possibilités.
///
/// Clés :
/// - `correction` : version du document (`true` professeur, `false` élève ; équivaut à
///   `\setrdcrep{correction=…}`), sans effet si `--input correction=…` est donné ;
/// - `correction-color`, `correction-font`, `style` : couleur et police des corrections, lues par les
///   zones de réponse de farfadet-crep et par les objets rd (`\setrdcrep{correction color=…, correction font=…}`) ;
///   `setrdcrep(correction-color: …)` les remplace pour les zones de réponse et recopie sa valeur ici.
///
/// Les couleurs (macros d'état `current-accent-color`…, couleurs nommées `thm`…) se règlent par
/// `setbfcolors`.
///
/// ```example
/// #setbfsocle(correction-color: "prop", correction-font: (size: "normalsize", style: "italic"))
/// #setbfsocle(definir: "discret", correction-color: "gray", correction-font: (size: "small"))
/// #setbfsocle(style: "discret")
/// #setbfsocle(reinitialiser: true)
/// #ifcorrection[Version professeur.][Version élève.]
/// ```
///
/// - pour (none): sans objet pour le socle, qui n'a pas de types d'objets (gardé pour la signature commune des setters). Défaut : `none`.
/// - reinitialiser (bool, str): `true` repart des défauts avant d'appliquer les clés (styles gardés) ; `"tout"` ramène aussi les styles du socle à ceux d'origine. Défaut : `false`.
/// - definir (none, str): définit le style nommé du socle de ce nom avec les clés données, au lieu de régler. Défaut : `none`.
/// - correction (auto, bool): version du document. Défaut : `auto` (inchangée).
/// - correction-color (color, str): couleur des corrections. Défaut : la couleur nommée `monrose` (suit `setbfcolors(monrose: …)`).
/// - correction-font (dictionary, function): police des corrections, `(size: "large", weight: "bold", style:, font:)` ou fonction. Défaut : `(size: "large", weight: "bold")`.
/// - style (str, array): style(s) nommé(s) appliqué(s) au réglage global.
/// -> content
#let setbfsocle(pour: none, reinitialiser: false, definir: none, correction: auto, ..cles) = {
  let commande = "setbfsocle"
  let r = _v.bf-reglages-socle
  if cles.pos().len() > 0 {
    panic(commande + " : seuls des arguments nommés sont acceptés ; reçu : " + repr(cles.pos().first()) + ".")
  }
  if pour != none {
    panic(commande + " : le socle n'a pas de types d'objets : la clé « pour » est sans objet ; reçu : " + repr(pour) + ".")
  }
  if reinitialiser not in (true, false, "tout") {
    panic(commande + " : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if correction != auto and type(correction) != bool {
    panic(commande + " : valeur invalide pour la clé « correction » : " + repr(correction) + ". Valeurs possibles : auto, true ou false.")
  }
  for k in cles.named().keys() {
    if k in r.controles or k == "style" { continue }
    if k in _c.couleurs-courantes-defauts or k in _c.bf-noms-couleurs-nommees {
      panic(commande + " : « " + k + " » est une couleur : elle se règle par setbfcolors(" + k + ": …).")
    }
    panic(
      commande + " : clé inconnue « " + k + " ». Clés possibles : "
        + _r.reglages-liste(("pour", "reinitialiser", "definir", "correction") + r.controles.keys() + ("style",)) + ".",
    )
  }
  if definir != none {
    if correction != auto { panic(commande + " : la clé « correction » ne peut pas entrer dans un style nommé.") }
    return _r.reglages-definir-style(r, definir, commande: commande, ..cles.named())
  }
  if correction != auto { _v.set-correction(correction) }
  if reinitialiser == "tout" { _r.reglages-reinitialiser(r, styles: true) }
  _r.reglages-regler(r, reinitialiser: reinitialiser != false, commande: commande, ..cles.named())
}

/// Change la valeur de base des COULEURS NOMMÉES de bfcours (`\colorlet{thm}{…}` de bfcours-colors) et
/// des macros d'état (`\renewcommand{\currentAccentColor}{…}`), pour la suite du document.
///
/// Ces couleurs sont les couleurs par défaut de TOUS les paquets farfadet-* (environnements, tableaux,
/// zones de réponse, exercices, QCM, listes…) : elles sont lues au moment du rendu, donc
/// `setbfcolors(thm: …)` recolore partout ce qui suit. Le setter d'un paquet peut ensuite les remplacer
/// pour lui seul (`setrdcrep(correction-color: red)`).
///
/// Comme en LaTeX, `defi` colore à la fois `definition` et `notation`, `nota` `vocabulaire` et `aide`,
/// `act` `activite`, `BaseColor` les bandeaux de section. Les valeurs sont évaluées tout de suite (comme
/// `\colorlet`) : `setbfcolors(defi: "thm")` copie la valeur actuelle de `thm`. `boitecouleur: auto` rend
/// à `boite` la couleur d'accent.
///
/// ```example
/// #setbfcolors(thm: "teal", currentAccentColor: "red!60!black")
/// #textcolor("thm")[Théorème], #context text(fill: current-accent-color())[accent].
/// #setbfcolors(reinitialiser: true)
/// #textcolor("thm")[Théorème d'origine.]
/// ```
///
/// - reinitialiser (bool): ramène d'abord toutes les couleurs nommées et toutes les macros d'état à leur valeur d'origine, puis applique les autres clés. Défaut : `false`.
/// - ..couleurs (color, str): un argument nommé par couleur nommée (`defi`, `thm`, `prop`, `ex`, `nota`, `rem`, `demo`, `act`, `meth`, `monrose`, `nombres`, `geo`…) ou par macro d'état (`current-accent-color`, `item-base-color`, `currentTableFrameColor`, `boitecouleur`…) ; valeur : couleur Typst ou expression xcolor. Un nom inconnu liste les noms possibles.
/// -> content
#let setbfcolors(reinitialiser: false, ..couleurs) = _c.bf-regler-couleurs(commande: "setbfcolors", reinitialiser: reinitialiser, ..couleurs)

/// Définit (ou remplace) un STYLE NOMMÉ commun à tous les paquets farfadet-* (ajout ; équivalent de
/// `\tcbset{mon style/.style={…}}`). On l'appelle ensuite par la clé `style:` de n'importe quelle commande
/// réglable, ou dans un réglage global (`setbfsocle(style: …)`, `setrdcrep(style: …)`…).
///
/// Les clés sont contrôlées à l'emploi, contre celles de la commande qui appelle le style. Un style peut en
/// appeler un autre (`style:` à l'intérieur : héritage). Priorité : clé locale > style nommé > réglage du
/// type > réglage global > défaut.
///
/// ```example
/// #definir-style("discret", correction-color: "gray", correction-font: (size: "small"))
/// #definir-style("discret-vert", style: "discret", correction-color: "defi")
/// #setbfsocle(style: "discret-vert")
/// #setbfsocle(reinitialiser: true)
/// Style défini ; à appeler par `style: "discret"` (par exemple `crep(style: "discret")[…]`).
/// ```
///
/// - nom (str): nom du style (les espaces sont permises : `"bfd theoreme"`).
/// - ..cles (any): clés du style (`style:` pour hériter d'un autre style).
/// -> content
#let definir-style(nom, ..cles) = _r.reglages-definir-style-commun(nom, commande: "definir-style", ..cles)

// =====================================================================
// Couleurs : bfcours-colors.sty
// =====================================================================

// Vérifie (dans un `context`) une liste de couleurs et les renvoie résolues.
#let _resoudre-toutes(commande, ..cs) = cs.pos().map(c => _c.bf-xcolor(c, commande: commande))

/// `\CouleursTabular{cadre}{fond titre}{texte titre}{fond}{texte}` : couleurs des tableaux PRIMAIRES
/// (`tcbtab`, `TableauBox`, `CompTab`) pour la suite du document ; les filets (`\arrayrulecolor`) prennent
/// la couleur du cadre. Les environnements didactiques les règlent eux-mêmes à leur ouverture.
///
/// ```example
/// #couleurs-tabular("defi", "defi", "white", "defi!5", "black")
/// #context {
///   let (titre, fond) = (current-table-colback-title-color(), xcolor("currentTableColbackColor"))
///   table(columns: 2, stroke: xcolor("currentTableFrameColor"), fill: (x, y) => if y == 0 { titre } else { fond },
///     text(fill: current-table-col-title-color())[$x$], text(fill: current-table-col-title-color())[$f(x)$],
///     [1], [3])
/// }
/// #reset-couleurs-tabular()
/// ```
///
/// - cadre (color, str): `\currentTableFrameColor` et filets. Défaut LaTeX : `"blue!50!black"`.
/// - fond-titre (color, str): `\currentTableColbackTitleColor`. Défaut : `"blue!50!black"`.
/// - texte-titre (color, str): `\currentTableColTitleColor`. Défaut : `"white"`.
/// - fond (color, str): `\currentTableColbackColor`. Défaut : `"white"`.
/// - texte (color, str): `\currentTableColupperColor`. Défaut : `"red!50!black"`.
/// -> content
#let couleurs-tabular(cadre, fond-titre, texte-titre, fond, texte) = context {
  _c.couleurstabular(.._resoudre-toutes("CouleursTabular", cadre, fond-titre, texte-titre, fond, texte))
}

/// `\CouleursSecondaryTabular{cadre}{fond titre}{texte titre}{fond}{texte}` : couleurs des tableaux
/// SECONDAIRES (`tcbtabx`) pour la suite du document.
///
/// ```example
/// #couleurs-secondary-tabular("prop", "prop!30!white", "black", "prop!5", "prop")
/// #context box(fill: xcolor("currentSecondaryTableColbackTitleColor"), inset: 4pt,
///   stroke: xcolor("currentSecondaryTableFrameColor"))[Titre secondaire]
/// #reset-couleurs-secondary-tabular()
/// ```
///
/// - cadre (color, str): `\currentSecondaryTableFrameColor`. Défaut : `"red!50!black"`.
/// - fond-titre (color, str): `\currentSecondaryTableColbackTitleColor`. Défaut : `"Salmon!30!white"`.
/// - texte-titre (color, str): `\currentSecondaryTableColTitleColor`. Défaut : `"black"`.
/// - fond (color, str): `\currentSecondaryTableColbackColor`. Défaut : `"yellow!10!white"`.
/// - texte (color, str): `\currentSecondaryTableColupperColor`. Défaut : `"red!50!black"`.
/// -> content
#let couleurs-secondary-tabular(cadre, fond-titre, texte-titre, fond, texte) = context {
  _c.couleurssecondarytabular(.._resoudre-toutes("CouleursSecondaryTabular", cadre, fond-titre, texte-titre, fond, texte))
}

/// `\ResetCouleursTabular` : couleurs des tableaux primaires par défaut (`blue!50!black`, `blue!50!black`,
/// `white`, `white`, `red!50!black`) et filets noirs (`couleur_theme`).
///
/// ```example
/// #couleurs-tabular("thm", "thm", "white", "white", "thm")
/// #reset-couleurs-tabular()
/// #textcolor("currentTableFrameColor")[Cadre par défaut.]
/// ```
///
/// -> content
#let reset-couleurs-tabular() = _c.resetcouleurstabular()

/// `\ResetCouleursSecondaryTabular` : couleurs des tableaux secondaires par défaut (`red!50!black`,
/// `Salmon!30!white`, `black`, `yellow!10!white`, `red!50!black`).
///
/// ```example
/// #reset-couleurs-secondary-tabular()
/// #context box(fill: xcolor("currentSecondaryTableColbackColor"), inset: 4pt)[Fond secondaire par défaut.]
/// ```
///
/// -> content
#let reset-couleurs-secondary-tabular() = _c.resetcouleurssecondarytabular()

/// `\CouleurTexteAccent{couleur}` : couleur d'accent du texte (`\currentAccentColor`, lue par `acc`,
/// `voc`…) ET couleur des boîtes `boite`/`bfbox` (`\boitecouleur`), pour la suite du document.
///
/// ```example
/// #couleur-texte-accent("meth")
/// #context text(fill: current-accent-color())[Mot accentué.]
/// #reset-couleur-texte-accent()
/// ```
///
/// - couleur (color, str): couleur Typst ou expression xcolor.
/// -> content
#let couleur-texte-accent(couleur) = context {
  let (c,) = _resoudre-toutes("CouleurTexteAccent", couleur)
  _c.couleurtexteaccent(c)
}

/// `\ResetCouleurTexteAccent` : accent noir et `\boitecouleur` = `gray!75!black`.
///
/// ```example
/// #reset-couleur-texte-accent()
/// #textcolor("boitecouleur")[Couleur des boîtes par défaut.]
/// ```
///
/// -> content
#let reset-couleur-texte-accent() = _c.resetcouleurtexteaccent()

/// `\couleurItem{couleur}` : couleur des pastilles numérotées (`\itemBaseColor`) de `tcbenumerate` et
/// des énumérations, pour la suite du document.
///
/// ```example
/// #couleur-item("geo")
/// #context circle(radius: 6pt, fill: item-base-color())
/// #reset-item-base-color()
/// ```
///
/// - couleur (color, str): couleur Typst ou expression xcolor.
/// -> content
#let couleur-item(couleur) = context {
  let (c,) = _resoudre-toutes("couleurItem", couleur)
  _c.couleuritem(c)
}

/// `\resetItemBaseColor` : pastilles en `gray!80!black`.
///
/// ```example
/// #reset-item-base-color()
/// #context circle(radius: 6pt, fill: item-base-color())
/// ```
///
/// -> content
#let reset-item-base-color() = _c.resetitembasecolor()

/// `\definecolor{nom}{modèle}{valeur}` (xcolor) : définit une couleur nommée, utilisable ensuite dans toute
/// expression xcolor (`"macouleur!30!white"`) de tous les paquets farfadet-*.
///
/// Modèles : `"RGB"` (0-255), `"rgb"` (0-1), `"HTML"` (`"FF1493"`), `"cmyk"`, `"cmy"`, `"gray"` (0-1),
/// `"Gray"` (0-15), `"hsb"` (0-1), `"HSB"` (0-240), `"Hsb"` (teinte en degrés). La valeur s'écrit comme en
/// LaTeX (`"56,128,77"`) ou en tableau (`(56, 128, 77)`).
///
/// ```example
/// #definecolor("vertlycee", "RGB", "34,139,34")
/// #definecolor("orangevif", "HTML", "FF6600")
/// #textcolor("vertlycee")[Vert lycée] et #textcolor("orangevif!60!black")[orange assombri].
/// ```
///
/// - nom (str): nom de la couleur (sans espace ni `!`).
/// - modele (str): modèle de couleur xcolor.
/// - valeur (str, array): composantes.
/// -> content
#let definecolor(nom, modele, valeur) = _c.bf-definecolor(nom, modele, valeur, commande: "definecolor")

/// `\colorlet{nom}{expression}` (xcolor) : nomme une couleur obtenue par une expression xcolor, évaluée
/// immédiatement. Redéfinir un nom de bfcours (`"thm"`, `"defi"`…) le change dans toutes les expressions
/// xcolor qui suivent, donc aussi dans les défauts de tous les paquets (même effet que `setbfcolors`).
///
/// ```example
/// #colorlet("fondclair", "prop!10!white")
/// #box(fill: rgb("#ffffff"), inset: 3pt)[#textcolor("fondclair!50!black")[Bleu assombri.]]
/// ```
///
/// - nom (str): nom de la couleur.
/// - expression (color, str): couleur Typst ou expression xcolor.
/// -> content
#let colorlet(nom, expression) = _c.bf-colorlet(nom, expression, commande: "colorlet")

/// `\textcolor{couleur}{texte}` (xcolor) : écrit le texte dans une couleur nommée ou une expression xcolor.
///
/// ```example
/// #textcolor("thm")[Théorème], #textcolor("defi!80!black")[définition],
/// #textcolor("currentAccentColor")[accent courant], #textcolor(blue)[couleur Typst].
/// ```
///
/// - couleur (color, str): couleur Typst ou expression xcolor (couleurs de bfcours, xcolor, svgnames, definecolor, macros d'état).
/// - corps (content): texte.
/// -> content
#let textcolor(couleur, corps) = context text(fill: _c.bf-xcolor(couleur, commande: "textcolor"), corps)

/// Expression xcolor → couleur Typst (ajout : en LaTeX, l'expression s'écrit directement dans les
/// options). Erreur explicite sur un nom inconnu. À appeler dans un `context`.
///
/// ```example
/// #context rect(width: 2cm, height: 0.5cm, fill: xcolor("thm!20!white"), stroke: xcolor("thm"))
/// ```
///
/// - expression (color, str): `"thm"`, `"red!50!black"`, `"currentAccentColor!30"`, `"-thm"` (complémentaire)…
/// -> color
#let xcolor(expression) = _c.bf-xcolor(expression, commande: "xcolor")

// ---------- Macros d'état (lecture) ----------
// En LaTeX : `\currentAccentColor` se développe en une expression de couleur. En Typst : une fonction
// qui renvoie la couleur effective à cet endroit du document (à appeler dans un `context`). Seules les
// quatre macros lues dans les cours ont leur fonction ; toutes se lisent par `xcolor("<macro>")`. Pour
// en changer : les commandes ci-dessus ou `setbfcolors(<macro>: …)`.

/// `\currentAccentColor` : couleur d'accent courante (noir hors environnement didactique). Dans un `context`.
///
/// ```example
/// #context text(fill: current-accent-color())[Accent courant.]
/// ```
/// -> color
#let current-accent-color() = _c.bf-couleur-courante("currentAccentColor")

/// `\currentTableColbackTitleColor` : fond du titre des tableaux primaires (`blue!50!black`). Dans un `context`.
///
/// ```example
/// #context box(fill: current-table-colback-title-color(), inset: 3pt, text(fill: white)[Titre])
/// ```
/// -> color
#let current-table-colback-title-color() = _c.bf-couleur-courante("currentTableColbackTitleColor")

/// `\currentTableColTitleColor` : texte du titre des tableaux primaires (`white`). Dans un `context`.
///
/// ```example
/// #context box(fill: black, inset: 3pt, text(fill: current-table-col-title-color())[Titre])
/// ```
/// -> color
#let current-table-col-title-color() = _c.bf-couleur-courante("currentTableColTitleColor")

/// `\itemBaseColor` : couleur des pastilles numérotées (`gray!80!black`). Dans un `context`.
///
/// ```example
/// #context circle(radius: 6pt, fill: item-base-color())
/// ```
/// -> color
#let item-base-color() = _c.bf-couleur-courante("itemBaseColor")

// =====================================================================
// Caractères (\oe, \OE, \euro de LaTeX) : un source en ASCII
// =====================================================================

/// Ligatures du français œ et Œ (`\oe` et `\OE` de LaTeX). Au milieu d'un mot, terminer l'appel par `;`
/// (ou l'écrire entre parenthèses), sinon Typst lit `#oeur` comme un seul nom.
///
/// ```example
/// Le c#oe;ur du n#oe;ud, une #oe-maj;uvre, un b#(oe)uf.
/// ```
/// -> str
#let oe = "\u{153}"
#let oe-maj = "\u{152}"

/// Symbole euro € (`\euro`, `\texteuro` de LaTeX). Dans une formule, il s'écrit sans `#` : `$12 euro$`.
///
/// ```example
/// Le livre coûte 12~#euro, soit $3 times 4 euro$.
/// ```
/// -> str
#let euro = "\u{20AC}"
