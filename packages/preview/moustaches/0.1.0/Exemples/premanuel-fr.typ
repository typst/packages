// #import "/moustaches.typ": *

/// Ecrit le quotient a / b  avec a et b flottants (ou a si b = 1) et son écriture sous forme de fraction irréductible (max 6 chiffres après la virgule) 
///```example
/// #simpli(3.6,6.9)
///```
/// -> content
#let simpli(
  /// int | float
  a, 
  /// int |float
  b
) = {}

/// Calcule le PGCD d'une liste de nombres 
///```example
/// #pgcd(1000, 1200, 1400, 1600, 1800, 2000)
///``` 
///-> int
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