// #import "/moustaches.typ": *

/// Ecrit le quotient a / b  avec a et b flottants (ou a si b = 1) et son écriture sous forme de fraction irréductible (max 6 chiffres après la virgule) 
///```example
/// #simpli(3.6,6.9)
///```
/// -> content
#let simpli(
  /// -> int | float
  a, 
  /// -> int | float
  b
) = {}

/// Calcule le PGCD d'une liste de nombres 
///```example
/// #pgcd(1000, 1200, 1400, 1600, 1800, 2000)
///``` 
/// -> int
#let pgcd(
  /// Liste de nombres -> array
  ..a
) = {}

/// `bandes(valeurs:(), effectifs:(), width:1fr, tourne:(), couleurs:auto, print:false, explication:(), hauteur:40pt)`

/// Dessine un diagramme en bandes 
///```example
///>>> #set text(.7em)
/// #bandes(valeurs:("Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"),effectifs:(25, 18, 17, 10, 5, 20),width:9cm,tourne:(4,),explication: (0,))
///``` 
/// -> content
#let bandes(
  /// Modalités du caractères -> array
  valeurs:(),
  /// Effectifs de chaque valeur -> array
  effectifs:(),
  /// Longueur totale de la bande -> length
  width:1fr,
  /// Pour tourner les labels des rectangles de 90deg -> array
  tourne:(),
  /// Liste des couleurs des rectangles -> auto | array
  couleurs:auto,
  /// Si true, remplace les couleurs par des tilings -> boolean
  print:false,
  /// Explication de la construction : la ou les étapes à expliquer (0,) ou (0,3) -> array
  explication:(),
  /// Hauteur de la bande -> length
  hauteur:40pt,
) = {}

/// Dessine un diagramme (semi-)circulaire
///```example
/// #camembert(valeurs:("foot","basket","tennis","ping-pong","hand","natation","danse"),effectifs: (1, 3, 5, 4, 7, 2, 5),radius:1.5,legende: "d",espace: 0,semi: true)
///``` 
/// -> content
#let camembert(
  /// Modalités du caractères -> array
  valeurs:(),
  /// Effectifs de chaque valeur -> array
  effectifs:(),
  /// Pour garder la possibilité de ne saisir qu'une liste de valeurs -> array
  data:(),
  /// Si true, dessine un diagramme semi-circulaire -> boolean
  semi:false,
  /// Position de la légende : "d", "g", "h", "b" sinon "" rien -> str
  legende:"d",
  /// Espacement des items dans la légende si à gauche ou droite -> int | float
  espace:.1,
  /// Si true, remplace les couleurs par des tilings -> boolean
  print:false,
  /// Liste des couleurs des secteurs -> auto | array
  couleurs:auto,
  /// True, none, false ou passe à inner-label -> boolean | none | dictionnary
  dedans:true,
  /// True, none, false ou passe à outer-label -> boolean | none | dictionnary
  dehors:true,
  /// Autres arguments passés à la fonction piechart de cetz -> arguments
  ..args
) = {}

/// Dessine un VRAI histogramme : les classes n'ont pas forcément la même amplitude et ce sont les aires qui sont proportionnelles 
///
/// #example(`#histogramme(
///   classes: (1000, 1200, 1400, 1600, 1800, 2000),
///   effectifs: (120, 150, 220, 360, 200),
///   px: 50,
///   uaire: 10,
///   s: .5,
///   // textsize: .5em,
///   nom-donnee: [Salaire (en €)],
///   nom-effectifs: [Salariés],
///   mediane: true,
///   quartiles: true,
///   pos-rect: (0,5),
/// )`,dir:ttb)
///
/// -> content
#let histogramme(
  /// Liste des bornes des classes : longueur = longueur de `effectifs` + 1 -> array
  classes: (),
  /// Effectifs de chaque classe : longueur = longueur de `classes` - 1 -> array
  effectifs:(),
  /// Pas sur l'axe des abscisses -> int
  px: 1,
  /// Quantité représentée par un carreau -> int
  uaire: 1,
  /// Echelle cetz du graphique -> int | float | dictionnary
  s: 1,
  /// Affichage ou non d'un quadrillage -> boolean
  grille: true,
  /// Pas du quadrillage -> int | float
  pas-grille:1,
  /// Nom pour la légende ou l'axe des ordonnées le cas échéant -> content
  nom-donnee: [Valeurs],
  /// Nom pour l'axe des abscisses -> content
  nom-effectifs: [effectifs],
  /// Combien "ajouter" à gauche, droite et au dessous, soit un triplet, soit un entier unique -> int | array
  add: (-1, 1, 1),
  /// Pour avoir ou non un axe des ordonnées lorsque les classes ont la même amplitude -> boolean
  lecture: true,
  /// Affichage ou non des effectifs au dessus des rectangles -> boolean
  donnees-sup: true,
  /// Liste des couleurs des rectangles ou une unique couleur white pour l'impression par ex -> auto | color | array
  liste-couleurs: auto,
  /// Position du rectangle de légende par rapport au coin hg du plus petit rectangle -> array
  pos-rect: (0, 2),
  /// Si true, remplace les couleurs par des tilings -> boolean
  print:false,
  /// Transparence des rectangles : mettre à 100% si liste-couleurs: white -> ratio
  transparence:30%,
  /// Affichage des effectifs cumulés croissants -> boolean
  ecc:false,
  /// Affichage ou non de la médiane -> boolean
  mediane:false,
  /// Afficha ou non des quartiles -> boolean
  quartiles:false,
  /// Nombre de décimales des arrondis -> int
  decimales:2,
  /// Position de la valeur de q1 par rapport à l'axe des abscisses (0,-1.5) par défaut -> array
  posq1:(0,-1.5),
  /// Position de la valeur de la médiane par rapport à l'axe des abscisses (0,-1.5) par défaut -> array
  posmediane:(0,-1.5),
  /// Position de la valeur de q3 par rapport à l'axe des abscisses (1,-1.5) par défaut -> array
  posq3:(1,-1.5),
  /// Trait pour représenter la médiane 2pt par défaut -> length | stroke
  stroke-mediane:2pt,
  /// Trait pour représenter les quartiles 2pt par défaut -> length | stroke
  stroke-quartiles:1.5pt,
  /// Taille des textes -> length
  textsize:1em,
) = {}

/// Produit un dictionnaire des caractéristiques : effectif-total, mediane, classe-mediane, q1, q3, d1, d9, ecart-interquartiles, max, min, etendue, modes, effectif-modes, sommex,  sommex2, moyenne, variance, ecart-type, variance-echantillon, ecart-type-echantillon, lqboxplot, cetzboxplot 
///```example
/// #caracteristiques(sondage: (1, 5, 7, 9, 4, 5, 9, 8, 7, 3, 8),)
///``` 
/// -> array
#let caracteristiques(
  /// Modalités du caractère `numérique` -> array
  valeurs:(),
  /// Effectifs de chaque valeur -> array
  effectifs: (),
  /// Bornes des classes le cas échéant : longueur = longueur effectifs + 1 -> array
  classes: (),
  /// Pour un sondage, création automatique des classes de même amplitude si bins > 0 -> int
  bins:0,
  /// Liste de toutes les valeurs dans le cas d'un sondage -> array
  sondage: (),
  /// Pour les des classes et donc de la classe médiane, soit avec des crochets soit des inégalités a <= ... < b -> boolean
  crochets:false,
  /// Prise en compte ou non des déciles pour les moustaches renvoyées dans lqboxplot et cetzboxplot, sinon ±1.5 IQR -> boolean
  deciles:true,
) = {}

/// Fait l'étude statistique et présente les résultats, soit sous forme de tableau avec possibilité d'afficher les `effectifs`, `fréquences` ("f" pour fractions, "d" pour décimales, "t" pour les trois, true ou autre pour %), `angles` pour les diagrammes (semi)-circulaires, `ecc`, `fcc`, `classes` (automatiques si `bins` > 0) et leurs `centres`, et les `diagrammes` : si "hbar" ou "bar" ou "circ" ou "semicirc" ou "box" ou "bande" ou "histo" ou une combinaison dans `diagramme` avec des paramétrages : `liste-couleurs` (petroff10 par défaut) ... Si `multi` != (), possibilité d'afficher un diagramme en barres (h ou v) ou des boites à moustaches avec une option `print` pour avoir des tilings 
///```example
/// #stat(
///   classes: (150, 160, 170, 200),
///   effectifs: (3, 4, 5),
///   frequences: "f",
/// )
///``` 
///```example
/// #stat(sondage: ("Handball","Basket","Football","Handball","Ping-pong","Basket","Ping-pong","Ping-pong"),diagramme: "bar",cbar:(size:(8.2,4)))
///``` 
///```example
/// #stat(valeurs:("Grippe","Angine","Allergies"),multi:((25,12,10),(10,10,17),(2,8,28),),diagramme: "bar",labels:("Mars","Avril","Mai",),tableau: false)
///``` 
/// -> content
#let stat(
  /// Modalités du caractère `numérique` -> array
  valeurs:(),
  /// Effectifs de chaque valeur -> array
  effectifs: (),
  /// Type de caractère -> boolean
  qualitatif: true,
  /// Affichage des totaux dans les tableaux -> boolean
  totaux: false,
  /// Affichage d'un tableau -> boolean
  tableau: true,
  /// Couleur de la première ligne et colonne du tableau -> color
  couleur-tableau: luma(85%),
  /// Inset du tableau -> length
  inset: 5pt,
  /// Nom des données pour la case hg du tableau (et certains graphiques) -> content
  nom-donnee: [],
  /// Nom des effectifs pour la ligne concernée (et certains graphiques) -> content
  nom-effectifs: [Effectifs],
  /// Nombre de décimales des arrondis -> int
  decimales: 0,
  /// false/true pour %, "f" pour fraction, "d" pour décimaux, "t" pour tout ou "v" pour une ligne vide -> boolean | str
  frequences: true,
  /// Toutes les valeurs une à une pour un sondage -> array
  sondage: (),
  /// Si true, toutes les lignes sauf la première sont vides -> boolean
  vide: false,
  /// false/true ou "v" pour une ligne vide -> boolean | str
  angle: false,
  /// false/true ou "v" pour une ligne vide -> boolean | str
  ecc: false,
  /// Bornes des classes dans le cas d'un caractère continu, longueur = longueur (+1) -> array
  classes: (),
  /// Dans le cas d'un sondage, si bins > 0, alors bins classes sont formées automatiquement -> int
  bins:0,
  /// Dans le cas des classes, affichage par défaut a <= ... < b, si crochets:true, [a ; b[ -> boolean
  crochets:false,
  /// false/true ou "v" pour une ligne vide -> boolean | str
  centre: true,
  /// Pour vider les colonnes correspondantes de toutes leurs valeurs -> array
  colonnes-vide: (),
  /// Pour vider une liste de cases, numérotation dans la partie blanche, ligne par ligne -> array
  cases-vide: (),
  /// "hbar" ou "bar" ou "circ" ou "semicirc" ou "box" ou "bande" ou "histo" ou une combinaison -> str
  diagramme: "",
  /// paramètres à passer au canvas de bar ou hbar -> array
  bar: (),
  /// paramètres à passer à barchart ou columnchart de cetz -> array
  cbar:(),
  /// paramètres à passer au canvas des boites à moustaches -> array
  moustaches:(),
  /// paramètres à passer à boxwhiskers de cetz -> array
  cmoustaches:(),
  /// paramètres à passer à la fonction camembert -> dictionnary
  circ:(:),
  /// paramètres à passer à la fonction bandes -> array
  bande:(),
  /// paramètres à passer à la fonction histogramme -> array
  histo:(),
  /// false/true ou "v" pour une ligne vide -> boolean | str
  fcc:false,
  /// si multi != (), possibilité d'afficher un diagramme en barres (h ou v) ou des boites à moustaches -> array
  multi:(),
  /// Labels des différentes séries dans le cas de `multi` -> array
  labels:(),
  /// false/true pour l'affichage de tilings à la place des couleurs dans les graphiques -> boolean
  print:false,
  /// Liste des couleurs pour les graphiques -> auto | color | array
  liste-couleurs:auto,
) = {}

/// Définit une cellule fusionnée ou personnalisée au sein de `math-grid`.
///
/// Reçoit les arguments positionnels et nommés :
///   - *Positionnels* :
///     - `body` (content) : Le contenu à afficher dans la cellule.
///     - `colspan` (int, optionnel) : Nombre de colonnes occupées (si un seul entier est fourni).
///     - `rowspan` (int, optionnel) : Nombre de lignes occupées (si un second entier est fourni).
///     - `align` (alignment, optionnel) : Alignement spécifique du contenu dans le bloc.
///   - *Nommés réservés* :
///     - `colspan` (int, défaut: 1) : Extension horizontale de la cellule.
///     - `rowspan` (int, défaut: 1) : Extension verticale de la cellule.
///     - `align` (alignment, défaut: auto) : Alignement interne du contenu (`left`, `center`, `right`, etc.).
///   - *Nommés supplémentaires* (`..node-args`) :
///     - Tout autre argument nommé (ex: `stroke`, `fill`, `corner-radius`, `extrude`, `def-draw`, etc.)
///       sera transmis directement au nœud Fletcher (`node(...)`) sous-jacent.
/// -> arguments
/// -> content + metadata
#let mblock(
  /// arguments positionnels (body, colspan, rowspan, align, size) et nommés (colspan, rowspan, align, size, ..node-args) -> arguments
  ..args
) = {}


/// Fonction auxiliare pour placer un contenu dans une boite sans prendre de place (avec alignement positionnel ou nommé) -> content
#let zero-box(
  /// Contenu et alignement -> arguments
  ..args
) = {}

/// == Toutes les fonctions suivantes font partie du module "gridmath"
///
/// Dessine un *tableau* de proportionnalité en générant des nœuds Fletcher nommés à partir d'une équation (contenant des alignements ou une matrice), par défaut, tous les nœuds d'une même colonne ont la même largeur et ceux d'une même ligne ont la même hauteur, de plus, tous les nœuds sont collés, fonctionne comme diagram (ou mat) en mode mathématique.
/// 
/// De plus, cette fonction peut être utilisée pour les résolutions d'équations (avec des flèches pour les explications) avec `equation:true` (voir l'exemple du README) ou pour les matrices avec `matrix-mode:true` ou `matrix-mode:"[]"` etc.
/// ```example
/// // Diagramme fletcher avec les mêmes paramètres que les valeurs par défaut de la fonction proportionnalite
/// #diagram($
///   "Grandeur 1" & 5 & 7   & 9    & 3/4 \
///   "Grandeur 2" & 6 & 8.4 & 10.8 & 9/10
/// $,
///   node-stroke: 1pt,
///   node-shape: rect,
///   spacing: 0cm,
///   mark-scale: 1.2, 
///   node-inset: 6pt,)
/// ```
/// ```example
/// #math-grid($
///   "Grandeur 1" & 5 & 7   & 9    & 3/4 \
///   "Grandeur 2" & 6 & 8.4 & 10.8 & 9/10
/// $,
/// )
/// ```
/// ```example
/// #math-grid(
///   $ "Grandeur 1"  & 5 edge("r", "-}>", bend: #70deg, label: times 1.4, label-sep: #(-1pt),shift:#(5pt)) & 7 & 12 & 3/4  \
///   "Grandeur 2" & 6 edge("r", "-|>", bend: #(-70deg), label: times 1.4, label-sep: #(-1pt),shift:#(-5pt)) & 8.4 & 14.4 & 9/10 $,
/// edge-stroke: .6pt+red, coef: $times 1.2$, coef-recip: $div 1.2$, 
/// node-stroke: 1pt)
/// ```
/// ```example
/// #math-grid($"G1" & 5 & 7 & 12 \ "G2" & 6 & 8.4 & 14.4$, 
///   // change l'orientation à un tableau vertical
///   flip:true, 
///   // Arc (au-dessus) à gauche liant la (colonne) ligne 1 et la (colonne) ligne 3
///   col-op(0, 1, 3, $+ 7$, flip:true),
///   // Arc (en dessous) à droite liant la (colonne) ligne 1 et la (colonne) ligne 3
///   col-op(1, 1, 3, $+ 8.4$, flip:true),
///   coef: $times 6/5$,coef-args: (label-sep:2.5pt))
/// ```
/// ```example
/// // Les cases sont automatiquement nommées <colonne-ligne>
/// #math-grid(
///   $
///     "Grandeur 1" & 5 & 7   & 12 \
///     "Grandeur 2" & 6 & 8.4 & 14.4
///   $,
///   // Relie le haut de la cellule (1,0) au haut de la cellule (3,0)
///   edge(<1-0.north>, <3-0.north>, "-|>", bend: 60deg, label: $+ 7$),
///   // Relie le bas-droite de (1,1) au bas-gauche de (2,1)
///   edge(<1-1.south>, <2-1.south>, "-|>", bend: -60deg),
/// )
/// ```
///
/// -> content
#let math-grid(
  /// équation mathématique qui sera traduite en tableau -> math.equation
  eq,
  /// mode équation pour avoir l'alternance des alignements, pas de traits et pas de nœuds vides -> boolean
  equation: false,
  /// mode matrix pour avoir les parenthèses ou crochets, pas de traits etc 
  /// si true, des parenthèses par défaut, sinon le ou les (noms des) symbole(s) peuvent être donnés comme dans la fonction mat de typst.
  // -> boolean | str
  matrix-mode:false,
  /// espacement des parenthèses ou crochets etc -> length
  matrix-sep:0pt,
  /// Dessine des lignes d'augmentation dans une matrice, comme dans la fonction mat de typst. -> none | int | array | dictionary
  augment:none,
  /// force le mode d'affichage mathématique grand format (display) -> boolean
  display: true,
  /// booléen pour indiquer que toutes les colonnes doivent être de même largeur -> boolean
  equal-columns: false,
  /// booléen pour indiquer que toutes les lignes doivent être de même hauteur -> boolean
  equal-rows: false,
  /// caractéristiques des traits du tableau -> none | length | color | stroke
  node-stroke: 1pt,
  /// booléen pour indiquer s'il faut tracer le cadre extérieur du tableau -> boolean
  cadre: true,
  /// alignement à l'intérieur des noeuds -> auto | alignment
  node-align:auto,
  /// forme des nœuds -> function
  node-shape: rect,
  /// inset (h,v) des nœuds en nombre de points -> array
  inset: (4, 4),
  /// espacement des cases du tableau -> length
  spacing: 0cm,
  /// échelle des marques des flèches -> int | float
  mark-scale: 1.2,
  /// booléen pour mettre le tableau vertical -> boolean
  flip: false,
  /// coefficient de proportionnalité (de la 1ère ligne vers la 2nde) -> none | content
  coef: none,
  /// coefficient réciproque (de la 2ème ligne vers la 1ère) -> none | content
  coef-recip: none,
  /// arguments facultatifs à passer à la fonction `edge` pour le coefficient -> dictionary
  coef-args: (),
  /// arguments facultatifs à passer à la fonction `edge` pour le coefficient réciproque -> dictionary
  coef-recip-args: (),
  /// booléen pour indiquer de dessiner les nœuds vides -> boolean
  no-empty-node: true,
  /// Pour donner une couleur aux nœuds vides -> boolean | color
  fill-empty: false,
  /// largeur minimale (utile pour les colonnes vides) -> length
  min-width: 0pt,
  /// hauteur minimale (utile pour les lignes vides) -> length
  min-height: 0pt,
  /// dictionnaire "x-y": color ou fonction (x, y) => color pour colorer des cellules -> dictionary | function
  fill-map: (:),
  /// applique la couleur d'en-tête sur la première ligne (y = 0) -> boolean
  header-row: false,
  /// applique la couleur d'en-tête sur la première colonne (x = 0) -> boolean
  header-col: false,
  /// couleur appliquée aux en-têtes -> color
  header-fill: rgb("d0d0d0"),
  /// pour appliquer un alignement différent aux titres (x = 0 ou y = 0) -> none | alignment
  header-align:none,
  /// évite le doublement de l'épaisseur des bordures internes quand spacing = 0cm -> boolean
  clean-grid: true,
  /// arguments facultatifs à passer à la fonction `diagram` de Fletcher -> arguments
  ..args,
) = {}

/// Fonction pour montrer qu'une colonne est la somme (défaut) ou la différence de 2 autres, au-dessus de la première ligne, 3 modes sont proposés
/// ```example
/// #math-grid(
///   $ "Grandeur 1"  & 5  & 7 & ? & 3/4  \
///   "Grandeur 2" & 6 & 8.4 & thick ? thick & 9/10 $, 
/// lin-up(1,2,3,sign: $ + $,color: blue,),
/// lin-down(1,2,3,sign: $ + $, color: blue,),)
/// ```
/// ```example
/// #math-grid(
///   $ "Grandeur 1"  & 5  & 7 & ? & 3/4  \
///   "Grandeur 2" & 6 & 8.4 & thick ? thick & 9/10 $, 
/// lin-up(1,2,3,sign: $ + $,mode:2,),
/// lin-down(1,2,3,sign: $ + $, mode:2,),)
/// ```
/// ```example
/// #math-grid(
///   $ "Grandeur 1"  & 5  & 7 & ? & 3/4  \
///   "Grandeur 2" & 6 & 8.4 & thick ? thick & 9/10 $, 
/// lin-up(1,2,3,sign: $ + $,mode:3,),
/// lin-down(1,2,3,sign: $ + $, mode:3,),)
/// ```
/// -> content
#let lin-up(
  /// numéro de la première colonne de départ -> int
  a,
  /// numéro de la seconde colonne de départ -> int
  b,
  /// numéro de la colonne d'arrivée -> int
  c,
  /// signe de l'opération -> content | str
  sign:$ + $,
  /// couleur des flèches -> auto | color
  color:auto,
  /// couleur du texte -> auto | color
  text-color:auto, 
  /// 3 modes sont proposés -> int
  mode:1,
  /// "hauteur" des traits du 1er mode -> length
  height:7.24pt,
  /// arguments supplémentaires pour les edges -> dictionary
  ..args,
) = {}

/// Fonction pour montrer qu'une colonne est la somme (défaut) ou la différence de 2 autres, en-dessous de la seconde ligne (ou `n:5` si 5 lignes), 3 modes sont proposés 
/// 
/// ```example
/// #math-grid(
/// $"Grandeur 1" & 5 & 7   & 12   & 3/4 \
///  "Grandeur 2" & 6 & 8.4 & 14.4 & 9/10 \
///  "Grandeur 3" & 6 & 8.4 & 14.4 & 9/10$,
///    lin-up(1,3,2,sign: $ - $,mode:2),
///    lin-down(1,2,3,n:3),
///    node-stroke: 0.6pt+navy,
/// )
/// ```
/// -> content
#let lin-down(
  /// numéro de la première colonne de départ -> int
  a,
  /// numéro de la seconde colonne de départ -> int
  b,
  /// numéro de la colonne d'arrivée -> int
  c,
  /// signe de l'opération -> content | str
  sign:$ + $,
  /// couleur des flèches -> auto | color
  color:auto,
  /// couleur du texte -> auto | color
  text-color:auto, 
  /// 3 modes sont proposés -> int
  mode:1,
  /// nombre de lignes -> int
  n:2,
  /// "hauteur" des traits du 1er mode -> length
  height:7.24pt,
  /// arguments supplémentaires pour les edges -> dictionary
  ..args,
) = {}

/// Fonction pour faire des opérations sur les lignes (d'une matrice ou autre) avec des flèches à angles droits -> content
#let row-op(
  /// numéro de la première ligne de départ -> int
  a,
  /// numéro de la seconde ligne de départ -> none | int
  b:0,
  /// numéro de la ligne de d'arrivée -> int
  c,
  /// label de l'opération -> content | str
  label,
  /// couleur des flèches -> auto | color
  color:auto,
  /// couleur du texte -> auto | color
  text-color:auto, 
  /// nombre de colonnes -> int
  n:2,
  /// "largeur" des traits -> length
  width:3em,
  /// arguments supplémentaires pour les edges -> dictionary
  ..args,
) = {}

/// Fonction pour afficher les croix d'un produit en croix entre deux colonnes 
/// ```example
/// #math-grid(
///   $ "Grandeur 1"  & 5 & 7 & ? & 3/4  \
///   "Grandeur 2" & 6 & 8.4 & 14.4 & 9/10 $, 
/// x-product(2,),)
/// ```
/// -> content
#let x-product(
  /// couleur des flèches -> color
  color:luma(40%),
  /// écart avec les centres des nœuds -> float
  sep:.2,
  /// décalage des extrémités gauches des flèches si besoin -> float
  left-shift:0,
  /// décalage des extrémités droites des flèches si besoin -> float
  right-shift:0,
  /// pour l'utilisation dans les tableaux verticaux -> boolean
  flip:false,
  /// arguments contenant nécessairement le numéro de la première colonne et accessoirement celui d'une seconde colonne (sinon +1), ainsi que des arguments transmis à la fonction edge de Fletcher -> int | arguments
  ..a,
) = {}

/// Trace une flèche d'opération directe d'une colonne vers une autre au-dessus ou en dessous du tableau.
/// - `row` : indice de la ligne (0 ou 1)
/// - `f` : indice de la colonne de départ (ex: 1)
/// - `t` : indice de la colonne d'arrivée (ex: 3)
/// - `label` : libellé de l'opération (ex: $+ 7$ ou $+ "Col 2"$)
/// et accessoirement :
/// - `pos` : "top" (au-dessus) ou "bottom" (en dessous)
/// - `bend` : courbure de l'arc
/// - `flip` : pour indiquer que le tableau est vertical
/// + d'autres arguments pour la commande edge de Fletcher
/// ```example
/// #math-grid($"Grandeur 1" & 5 & 7 & 12 \ "Grandeur 2" & 6 & 8.4 & 14.4$, 
///   // Arc (au-dessus) à gauche liant la (colonne) ligne 1 et la (colonne) ligne 3
///   col-op(0, 1, 3, $+ 7$),
///   // Arc (en dessous) à droite liant la (colonne) ligne 1 et la (colonne) ligne 3
///   col-op(1, 1, 3, $+ 8.4$),
///   coef: $times 6/5$,coef-args: (label-sep:2.5pt,bend:90deg))
/// ```
///-> content
#let col-op(
  /// indice de la ligne (ou colonne si flip:true) de départ -> int
  row,
  /// indice de la colonne (ou ligne si flip:true) de départ -> int
  f,
  /// indice de la colonne (ou ligne si flip:true) d'arrivée -> int
  t,
  /// texte/opération (ex: $+ 12$ ou $+ "col 2"$) -> content | str
  label,
  /// position : "top" (au-dessus) ou "bottom" (en dessous), défaut : auto -> auto | str
  pos: auto,     
  /// courbure de l'arc -> auto | angle
  bend: auto,
  /// pour l'utilisation dans les tableaux verticaux -> boolean 
  flip:false,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..args,
) = {}

/// Double flèche montrant la combinaison (addition/soustraction) de deux colonnes vers une 3e. 
/// ```example
/// #math-grid(
///   $
///     "Grandeur 1" & 5 & 7 & 12 \
///     "Grandeur 2" & 6 & 8.4 & 14.4
///   $, 
///   col-combine(0, 1, 2, 3, label: $+$,),
///   col-combine(1, 1, 2, 3, label: $+$,),
/// )
/// ```
/// -> content
#let col-combine(
  /// indice de la ligne (ou colonne si flip:true) de départ -> int
  row,
  /// indice de la 1ère colonne de départ -> int
  col1,
  /// Indice de la 2ème colonne de départ -> int
  col2,
  /// uindice de la colonne d'arrivée -> int
  to,
  /// texte/opération (ex: $+ 12$ ou $+ "col 2"$) -> content | str
  label: $+$,
  /// position : "top" (au-dessus) ou "bottom" (en dessous), défaut : auto -> auto | str
  pos: auto,
  /// courbure de l'arc -> auto | angle
  bend: auto,
  /// pour l'utilisation dans les tableaux verticaux -> boolean 
  flip:false,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..args,
) = {}

/// Flèche à droite allant vers le bas avec un label -> content
#let rdarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = {}

/// Flèche à droite allant vers le haut avec un label -> content
#let ruarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne montées -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = {}

/// Flèche à gauche allant vers le bas avec un label -> content
#let ldarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = {}

/// Flèche à gauche allant vers le haut avec un label -> content
#let luarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne montées -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = {}

/// Flèche en haut allant vers la droite avec un label -> content
#let urarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = {}

/// Flèche en haut allant vers la gauche avec un label -> content
#let ularrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = {}

/// Flèche en bas allant vers la droite avec un label -> content
#let drarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = {}

/// Flèche en bas allant vers la gauche avec un label -> content
#let dlarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = {}