// #import "/moustaches.typ": *

/// Ecrit le quotient a / b  avec a et b flottants (ou a si b = 1) et son écriture sous forme de fraction irréductible (max 6 chiffres après la virgule). -> content
#let simpli(
  /// -> int | float
  a, 
  /// -> int | float
  b
) = {}

/// Calcule le PGCD d'une liste de nombres. -> int
#let pgcd(
  /// Liste de nombres -> array
  ..a
) = {}

/// Dessine un diagramme en bandes . -> content
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

/// Dessine un diagramme (semi-)circulaire. -> content
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

/// Dessine un VRAI histogramme : les classes n'ont pas forcément la même amplitude et ce sont les aires qui sont proportionnelles. -> content
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

/// Produit un dictionnaire des caractéristiques : effectif-total, mediane, classe-mediane, q1, q3, d1, d9, ecart-interquartiles, max, min, etendue, modes, effectif-modes, sommex,  sommex2, moyenne, variance, ecart-type, variance-echantillon, ecart-type-echantillon, lqboxplot, cetzboxplot. -> array
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

/// Fait l'étude statistique et présente les résultats, soit sous forme de tableau avec possibilité d'afficher les `effectifs`, `fréquences` ("f" pour fractions, "d" pour décimales, "t" pour les trois, true ou autre pour %), `angles` pour les diagrammes (semi)-circulaires, `ecc`, `fcc`, `classes` (automatiques si `bins` > 0) et leurs `centres`, et les `diagrammes` : si "hbar" ou "bar" ou "circ" ou "semicirc" ou "box" ou "bande" ou "histo" ou une combinaison dans `diagramme` avec des paramétrages : `liste-couleurs` (petroff10 par défaut) ... Si `multi` != (), possibilité d'afficher un diagramme en barres (h ou v) ou des boites à moustaches avec une option `print` pour avoir des tilings. -> content
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

/// Dessine un *tableau* de proportionnalité en générant des nœuds Fletcher nommés à partir d'une équation, par défaut, tous les nœuds d'une même colonne ont la même largeur et ceux d'une même ligne ont la même hauteur, de plus, tous les nœuds sont collés, fonctionne comme diagram en mode mathématique. -> content
#let math-grid(
  /// équation mathématiques qui sera traduite en tableau -> math.equation
  eq,
  /// mode équation pour avoir l'alternance des alignements, pas de traits et pas de nœuds vides -> boolean
  equation: false,
  /// booléen pour indiquer que les cases d'une colonne doivent être de même largeur -> boolean
  equal-columns: true,
  /// booléen pour indiquer que les cases d'une ligne doivent être de même largeur -> boolean
  equal-rows: true,
  /// caractéristiques des traits du tableau -> none | length | color | stroke
  node-stroke: 1pt,
  /// forme des nœuds -> function
  node-shape: rect,
  /// inset (h,v) des nœuds en nombre de points -> array
  inset: (0, -2),
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
  /// arguments facultatifs à passer à la fonction `edge` pour le coefficient -> dictionary
  coef-recip-args: (),
  /// booléen pour indiquer de dessiner les nœuds vides -> boolean
  no-empty-node: true,
  /// largeur minimale (utile pour les colonnes vides) -> length
  min-width:0pt,
  /// hauteur minimale (utile pour les lignes vides) -> length
  min-height:0pt,
  /// arguments facultatifs à passer à la fonction `diagram` de Fletcher -> arguments
  ..args,
) = {}

/// Fonction pour montrer qu'une colonne est la somme (défaut) ou la différence de 2 autres, au-dessus de la première ligne, 3 modes sont proposés. -> content
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
  /// arguments supplémentaires pour les edges -> dictionary
  ..args,
) = {}

/// Fonction pour montrer qu'une colonne est la somme (défaut) ou la différence de 2 autres, en-dessous de la seconde ligne, 3 modes sont proposés -> content
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
  /// arguments supplémentaires pour les edges -> dictionary
  ..args,
) = {}

/// Fonction pour afficher les croix d'un produit en croix entre deux colonnes. -> content
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
/// -> content
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

/// Double flèche montrant la combinaison (addition/soustraction) de deux colonnes vers une 3e. -> content
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