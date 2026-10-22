// listes.typ (farfadet-enum) — façade publique des énumérations : tcbenumerate, itemize, enumerate
// et les compteurs bfdEnumNum, bfdEnumLabel, bfdEnumLevel. Noms et clés = ceux de LaTeX.
// Réglages : `setbfenum` (reglages.typ). Le moteur (interne.typ) garde ses noms.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "moteur/listes.typ" as m
#import "reglages.typ": registre-enum
#import "items.typ": items-boites, items-liste

// =====================================================================
// tcbenumerate
// =====================================================================

/// Énumération à pastilles, qui peut se répartir en colonnes : la liste des questions d'un exercice, en une
/// colonne ou en plusieurs quand les questions sont courtes. Le corps est UN SEUL bloc `[…]` où chaque
/// question s'écrit `+` (ou `#tcbitem(…)[…]` quand elle a des options) ; elle est numérotée par une pastille.
/// Une question peut contenir un autre `tcbenumerate`, qui prend alors le niveau suivant (1., 2. puis a., b.
/// puis i., ii.). Du texte écrit après une question lui est rattaché ; du texte avant la première question
/// est une erreur.
///
/// Les trois arguments optionnels de `\begin{tcbenumerate}[colonnes][début][format]` deviennent des clés :
/// `raster-columns` (alias `columns`), `depart`, `format`. Les clés de cadre sont celles de tcolorbox : avec
/// `colframe` ou `colback`, chaque question devient une boîte, toutes de même hauteur dans une rangée.
///
/// Un numéro écrit à la main sur la première question (`5. Texte`) vaut `depart` si cette clé est absente ;
/// les numéros des questions suivantes sont ignorés (la pastille compte seule).
///
/// ```typ
/// #tcbenumerate(columns: 2)[
///   + $x^2 = 4$
///   + $x^2 = -1$
///   + $x^2 = 0$
///   + $x^2 = 9$
/// ]
/// #tcbenumerate(format: "alph", depart: 3)[
///   + Première question
///   + Seconde question
/// ]
/// ```
///
/// La syntaxe environnement donne le même résultat : `#begin(tcbenumerate, columns: 2)` … `#end(tcbenumerate)`.
///
/// - raster-columns (int): nombre de colonnes (1 : une question par ligne). Alias : `columns`.
/// - title (content): titre par défaut des questions qui n'ont pas le leur (bandeau à la couleur des pastilles) ; un contenu `[…]` ou une chaîne.
/// - depart (int): numéro de la première question (1).
/// - format (str): `"auto"` (1., 2. au niveau 1 ; a., b. au niveau 2 ; i., ii. au niveau 3), `"num"`, `"arabic"`, `"alph"`, `"Alph"`, `"roman"`, `"Roman"`, ou un motif Typst `"1"`, `"a"`, `"A"`, `"i"`, `"I"` (`"auto"`).
/// - raster-column-skip (length, auto): espace entre deux colonnes. `auto` : un demi-quad, valeur de bfcours.
/// - raster-row-skip (length, auto): espace entre deux questions. `auto` : 5 pt.
/// - colframe (color, str, none): couleur du cadre de chaque question (`none` : pas de cadre).
/// - boxrule (length): épaisseur du cadre (0,4 pt).
/// - colback (color, str, none): fond de chaque question (`none`).
/// - arc (length): rayon des coins des boîtes (3 pt).
/// - boxsep (length): espace entre le bord d'une boîte et la question (3 pt).
/// - couleur-badge (color, str, auto): couleur des pastilles (défaut : la couleur nommée `item-base-color`, que `couleur-item` et `setbfcolors(itemBaseColor: …)` règlent ; `auto` : idem).
/// - ecart-badge (length, auto): espace entre la pastille et le texte. `auto` : 3 pt TeX.
/// - rayon-badge (length, auto): rayon des coins de la pastille. `auto` : 2 pt TeX.
/// - format-auto (array, auto): motifs de `format: "auto"` aux niveaux 1, 2, 3 (`("1", "a", "i")`).
/// - bfdEnumIndentI (length, auto): retrait de la liste au niveau 1. `auto` : 0 em.
/// - bfdEnumIndentII (length, auto): retrait au niveau 2. `auto` : 1,5 em.
/// - bfdEnumIndentIII (length, auto): retrait au niveau 3. `auto` : 3 em.
/// - raster-equal-height (str): `"rows"` : les boîtes d'une rangée ont la hauteur de la plus haute ; `"none"` : hauteur naturelle (`"rows"`, fixe en LaTeX).
/// - halign (str): alignement du texte des questions : `"left"` (LaTeX), `"justify"`, `"center"`, `"right"`. Un `tcbitem(halign: …)` le règle pour une question.
/// - style (str, array): style(s) nommé(s) (voir `setbfenum(definir: …)`).
/// - questions (content): le corps, un seul bloc : une question par `+`, ou `#tcbitem(…)[…]` ; `tcbitem(title: […])` ajoute un bandeau de titre à la couleur des pastilles (`colbacktitle`, `coltitle` pour le changer), `tcbitem(numerote: false)` fait une case de transition sans pastille.
/// -> content
#let tcbenumerate(..args) = {
  let cles = args.named()
  if "columns" in cles {
    if "raster-columns" in cles {
      panic("tcbenumerate : `columns` est l'alias de `raster-columns` ; ne donner qu'une des deux clés.")
    }
    cles.insert("raster-columns", cles.remove("columns"))
  }
  let titre = cles.remove("title", default: none)
  let lus = items-boites("tcbenumerate", args.pos(), "+", titre: titre)
  if lus.depart != none and "depart" not in cles { cles.insert("depart", lus.depart) }
  m.tcbenumerate-cles(cles, lus.items)
}

// =====================================================================
// Compteurs de tcbenumerate (\bfdEnumNum, \bfdEnumLabel, \bfdEnumLevel…)
// =====================================================================

/// Numéro de la question courante d'un `tcbenumerate` (`\bfdEnumNum`), à placer dans le texte d'une
/// question : « (réponse à la question #bfd-enum-num()) ». La clé `niveau` donne le numéro d'un niveau précis
/// (`niveau: 1`, `2`, `3` : les `\bfdEnumNumI`, `II`, `III` de LaTeX) ; 0 hors liste.
///
/// ```typ
/// #tcbenumerate[Question #bfd-enum-num() #tcbenumerate[Sous-question #bfd-enum-num(niveau: 1).#bfd-enum-num(niveau: 2)]]
/// ```
///
/// - niveau (int, auto): niveau de la liste (1, 2, 3…) ; `auto` : le niveau courant.
/// -> content
#let bfd-enum-num(niveau: auto) = m.bfd-enum-num(niveau: niveau)

/// Étiquette de la question courante (`\bfdEnumLabel`), au format du niveau, sans le point : « b » pour la
/// deuxième sous-question. La clé `niveau` choisit le niveau ; la clé `format` impose un motif (`"1"`, `"a"`,
/// `"i"`, ou `"alph"`, `"roman"`…) : `bfd-enum-label(niveau: 2, format: "a")` est le `\bfdEnumLabelII` de LaTeX,
/// qui garde son format quel que soit celui de la liste.
///
/// ```typ
/// #tcbenumerate(format: "Alph")[Voir la question #bfd-enum-label().]
/// ```
///
/// - niveau (int, auto): niveau de la liste ; `auto` : le niveau courant.
/// - format (str, auto): motif de numérotation ; `auto` : celui de la liste.
/// -> content
#let bfd-enum-label(niveau: auto, format: auto) = m.bfd-enum-label(niveau: niveau, format: format)

/// Profondeur d'imbrication courante des `tcbenumerate` (`\bfdEnumLevel`) : 1, 2, 3… (0 hors liste).
///
/// ```typ
/// #tcbenumerate[Niveau #bfd-enum-level() #tcbenumerate[Niveau #bfd-enum-level()]]
/// ```
/// -> content
#let bfd-enum-level = m.bfd-enum-level

// =====================================================================
// itemize, enumerate
// =====================================================================

#let _refuser-options(commande, args) = {
  if "options" in args.named() {
    panic(
      commande + " : la clé `options` (chaîne enumitem) n'existe plus ; écrivez chaque option enumitem comme une clé : "
        + commande + "(leftmargin: 1cm, itemsep: 2pt)[…].",
    )
  }
}

/// Liste à puces de bfcours (`\begin{itemize}[options]`, puces `•` à tous les niveaux) : le corps est un seul
/// bloc `[…]` où chaque item s'écrit `-`. Les options enumitem sont des clés. La syntaxe `- item` de Typst
/// donne la même mise en page dans un document bfcours ; cette fonction sert quand on veut des options
/// propres à une liste.
///
/// ```typ
/// #itemize[
///   - Premier item
///   - Deuxième item #itemize[
///       - Imbriqué
///       - Autre
///     ]
/// ]
/// #itemize(label: [--], itemsep: 4pt)[
///   - Tiret
///   - Autre tiret
/// ]
/// ```
///
/// - leftmargin (length, auto): retrait des items. `auto` : valeur du niveau (`leftmargini`…).
/// - labelsep (length, auto): espace entre la puce et le texte (5,475 pt).
/// - itemsep (length, auto): espace supplémentaire entre deux items.
/// - topsep (length, auto): espace avant la liste.
/// - nosep (bool): supprime tous les espaces verticaux (`false`).
/// - label (content, array, auto): la puce ; un tableau donne une puce par niveau (`auto` : `•`).
/// - leftmargini (length, auto): retrait au niveau 1 (27,37 pt). Idem `leftmarginii` (24,09 pt), `leftmarginiii` (20,81 pt), `leftmarginiv`, `leftmarginv`, `leftmarginvi`.
/// - couleur-puce (color, str, auto): couleur des puces (`auto` : celle du texte).
/// - style (str, array): style(s) nommé(s) (voir `setbfenum(definir: …)`).
/// - items (content): le corps, un item par `-`.
/// -> content
#let itemize(..args) = {
  _refuser-options("itemize", args)
  let lus = items-liste("itemize", args.pos(), "-")
  m.itemize(..args.named(), ..lus.items)
}

/// Liste numérotée de bfcours (`\begin{enumerate}[options]`) : numéros dans une pastille de la couleur des
/// items, « 1. », « a. », « i. » selon le niveau. Le corps est un seul bloc `[…]` où chaque item s'écrit `+`.
/// Les options enumitem sont des clés. Un numéro écrit sur le premier item (`3. Texte`) vaut `start` si cette
/// clé est absente ; les suivants sont ignorés.
///
/// ```typ
/// #enumerate[
///   + Premier
///   + Deuxième #enumerate[
///       + a
///       + b
///     ]
/// ]
/// #enumerate(start: 3, couleur-etiquette: "red!70!black")[
///   + Troisième
///   + Quatrième
/// ]
/// ```
///
/// - leftmargin (length, auto): retrait des items. `auto` : valeur du niveau.
/// - labelsep (length, auto): espace entre le numéro et le texte (5,475 pt).
/// - itemsep (length, auto): espace supplémentaire entre deux items.
/// - topsep (length, auto): espace avant la liste.
/// - nosep (bool): supprime tous les espaces verticaux (`false`).
/// - label (str, function, array, auto): motif de numérotation (`"a)"`) ou fonction `n => contenu` ; un tableau donne un motif par niveau. `auto` : pastille bfcours.
/// - start (int, auto): numéro du premier item (1).
/// - leftmargini (length, auto): retrait au niveau 1 (27,37 pt). Idem `leftmarginii` à `leftmarginvi`.
/// - couleur-etiquette (color, str, auto): couleur de la pastille (défaut : la couleur nommée `item-base-color` ; `auto` : idem).
/// - motifs (array, auto): motifs de la pastille par niveau (`("1", "a", "i", "A")`).
/// - style (str, array): style(s) nommé(s) (voir `setbfenum(definir: …)`).
/// - items (content): le corps, un item par `+`.
/// -> content
#let enumerate(..args) = {
  _refuser-options("enumerate", args)
  let cles = args.named()
  let lus = items-liste("enumerate", args.pos(), "+")
  if lus.depart != none and "start" not in cles { cles.insert("start", lus.depart) }
  m.enumerate(..cles, ..lus.items)
}
