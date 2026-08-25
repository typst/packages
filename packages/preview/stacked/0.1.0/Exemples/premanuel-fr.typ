#import "../Colors.typ": *

/// Commande cetz pour un cube -> function
#let cube(
  /// Position -> array
  a,
  /// auto $->$ (rouge à droite, vert en haut, jaune à gauche), sinon une ou 3 couleurs -> auto | color | array
  c:auto,
  /// Lignes en noir ou de la couleur du cube, défaut false -> boolean | color
  border-stroke:false,
  /// Epaisseur des tracés (de 1pt), défaut 100% -> int | float | ratio
  thickness:100%,
  /// De combien éclaircir quand une seule couleur 20% par défaut -> float | ratio | array
  light:20%,
  /// Commande interne pour la vue de côté avec `pile` -> boolean
  side:false,
) = {}

/// Empilement de petits cubes sur une grille, donnés sous forme de liste allant du fond vers l'avant `3251` puis de gauche à droite (séparés par des virgules), une couleur peut être indiquée au début ou à la fin, couleurs de base avec none : avant $->$ jaune, dessus $->$ vert et droite $->$ rouge, sinon une liste de 3 couleurs peut-être donnée dans colors
///
/// ```example
/// #pile(3415,1412,2411,eastern,side:true,
/// iso:1,draw-scale:.6,border-stroke:true)
/// ```
///
/// ```example
/// #pile(4223,4212,4201,colors: (rgb("#fa8072"),rgb("#b0c4de"),teal), side: true,iso: 2,draw-scale: .75)
/// ```
///
/// #example(`#grid(columns: 5*(1fr,), column-gutter: 1.5em, 
/// ..for i in (true,false,1,2,3) {([=== iso: #i
///   #pile("4643",2344,2112, iso: i)
/// ],)}
/// )` , dir:ttb, scale-preview:100%)
///
/// #example(`#grid(columns: 5*(3.2cm,), column-gutter: 2em, 
/// ..for i in (1,2,3,4) {([=== random-mode: #i
///   #pile(random:true, random-mode: i,shadow:true,seed:2*i,plan:true)
/// ],)}
/// )` , dir:ttb, scale-preview:100%)
///
/// `z:0` pour vue de face `y:0, z:(0,-1)` pour vue du dessus `x:0, z:(-1,0)` pour vue de droite -> content
#let pile(
  /// Liste de nombres/string correspondants aux hauteurs de l'arrière vers l'avant, de gauche à droite -> int | str | array | arguments
  ..a,
  /// Active un mode aléatoire : génère automatiquement l'empilement (au lieu des arguments positionnels), avec des hauteurs égales ou décroissantes de rang en rang -> boolean
  random: false,
  /// Largeur (nombre de tranches selon X) en mode aléatoire -> int
  width: 3,
  /// Profondeur (nombre de chiffres par tranche selon Z) en mode aléatoire -> int
  depth: 4,
  /// Hauteur maximale (selon Y) en mode aléatoire -> int
  height: 5,
  /// Graine du générateur pseudo-aléatoire pour la reproductibilité du tirage : même graine $->$ même empilement, à changer pour en obtenir un autre -> int
  seed: 1,
  /// Affiche le plan de niveau (vue de dessus chiffrée) -> boolean
  plan: false,
  /// Affiche les intitulés des vues sur les grids -> boolean
  labels: false,
  /// Direction de la première coordonnée, défaut (1,0) -> array
  x:(1,0),
  /// Direction de la seconde coordonnée, défaut (0,1) -> array
  y:(0,1),
  /// Direction de la troisième coordonnée, défaut (-0.5,-0.5) -> array
  z:(-.5,-.5),
  /// Epaisseur des tracés (de 1pt), défaut 60% soit 0.6pt -> int | float | ratio
  thickness:60%,
  /// Lignes en noir, défaut false -> boolean | color
  border-stroke:false,
  /// Ajout d'une seconde vue de l'assemblage depuis la "droite" -> boolean
  side:false,
  /// De combien éclaircir quand une seule couleur -> float | ratio | array
  light:20%,
  /// Echelle du dessin : modifie la taille des arêtes d'un cube de base -> float | ratio
  draw-scale:.5,
  /// Permet « d’éclater » l’empilement construit vers la droite afin de mieux permettre une visualisation par « tranches » -> float | int
  x-spread:0,
  /// Permet « d’éclater » l’empilement construit vers le haut afin de mieux permettre une visualisation par « couches » -> float | int
  y-spread:0,
  /// Permet « d’éclater » l’empilement construit vers l'avant afin de mieux permettre une visualisation par « tranches » -> float | int
  z-spread:0,
  /// Pour donner une liste de 3 couleurs pour les trois faces (gauche, droite, haut) -> array
  colors:(),
  /// Pour afficher trois grids permettant à l’élève de dessiner directement les vues de face, de dessus et de gauche -> boolean
  grids:false,
  /// Affiche, lorsqu’elle est positionnée à true, les vues de face, de dessus et de gauche du solide associé sur les grids -> boolean
  solution:false,
  /// Écart de la grille du dessous (auto = calculé automatiquement) -> auto | int | float
  below-separation: auto,
  /// Écart de la grille de gauche (auto = calculé automatiquement) -> auto | int | float
  left-separation: auto,
  /// Écart de la grille du fond (auto = calculé automatiquement) -> auto | int | float
  back-separation: auto,
  /// Pour avoir différentes perspectives :
  /// - si true, représentation isométrique,
  /// - si 1 vue tikz3d-fr,
  /// - si 2 première vue de ProfCollege,
  /// - si 3 seconde vue de Profcollege,
  /// - sinon vue par defaut de cetz. -> boolean | int
  iso:false,
  /// Espacement avec la seconde vue -> length | relative length | fraction
  space:2em,
  /// Autorise des "trous" (hauteur nulle) dans l'empilement aléatoire à partir de la deuxième pile ; la première pile reste toujours "pleine" (hauteur >= 1 partout) -> boolean
  holes:false,
  /// Mode aléatoire spécifique :
  /// - 1 (LCG double min par gemini),
  /// - 2 et 4 (LCG décroissant inspiré de ProfCollege par Claude),
  /// - 3 (package suiji) -> auto | int
  random-mode: auto,
  /// Liste des vues à afficher parmi ("dessus", "face", "droite") -> array
  views: ("dessus", "face", "droite"),
  /// Noms des vues affichées parmi ("dessus", "face", "droite") -> array
  views-names: ("Vue de dessus", "Vue de face", "Vue de droite"),
  /// Affiche les repères d'axes (coordonnées) au sol -> boolean
  axes: false,
  /// Opacité des faces des cubes (100% = opaque, 50% = semi-transparent) -> ratio
  opacity: 100%,
  /// Dessine l'empreinte au sol sous l'empilement -> boolean
  shadow: false,
  /// Disposition des grids 2D : "3d" (projetées autour) ou "cote-a-cote" (à côté de la 3D) -> str
  disposition: "3d",
  /// Arguments à passer à la (aux) boite(s) -> dictionary
  box-args:(),
) = {}

/// Assemblage de petits cubes avec mix de couleurs : chaque n° correspond à la position dans la liste de couleurs (16 max : 1 à 9 et a à g + t -> 3 couleurs), le "0" et le "o" représentent un trou, le "x" donne la première couleur, les cubes sont donnés dans une liste de listes : de l'avant vers l'arrière par un nombre/string "5432a" puis étage par étage `btt`, listes de gauches à droite
///
///```example
/// #building((
/// ("ttttt","ttttt","ttttt","ttttt"),
/// // Tranche la plus à gauche de bas en haut
/// ("ttttt","ooooo","ooooo","ttttt"),
/// ("ttttt","ooooo","ooooo","ttttt"),
/// ("ttttt","ooooo","ooooo","ttttt"),
/// ("ttttt","ttttt","ttttt","totot")
/// // Tranche la plus à droite de même
/// ), y-spread:1)
///```
///
///```example
/// #building(((578,"21b",44), ("59a",63,64), (533,66,0),)) 
/// #h(3em)
/// #building(((578,"21b",44), ("59a",63,64), (533,66,0),),
/// y-spread:1.5)
///```
///
/// `z:0` pour vue de face `y:0, z:(0,-1)` pour vue du dessus `x:0, z:(-1,0)` pour vue de droite -> content
#let building(
  /// Liste de nombres/string correspondants aux couleurs de l'arrière vers l'avant, de bas en haut,\ de gauche à droite -> array | arguments
  ..a,
  /// Liste de max 16 couleurs -> array
  color-list:typst16,
  /// Direction de la première coordonnée, défaut (1,0) -> array
  x:(1,0),
  /// Direction de la seconde coordonnée, défaut (0,1) -> array
  y:(0,1),
  /// Direction de la troisième coordonnée, défaut (-0.5,-0.5) -> array
  z:(-.5,-.5),
  /// Epaisseur des tracés (de 1pt), défaut 60% soit 0.6pt -> int | float | ratio
  thickness:60%,
  /// Lignes en noir, défaut false -> boolean | color
  border-stroke:false,
  // Parametre pour certaines vues _rev:false (si true haut vers bas) -> boolean
  _rev:false,
  // Parametre pour la vue du dessous -> boolean
  _dessous:false,
  // Paramètre pour la vue de l'arrière -> boolean
  _back:false,
  /// De combien éclaircir quand une seule couleur -> float | ratio | array
  light:20%,
  /// Echelle du dessin : modifie la taille des arêtes d'un cube de base -> float | ratio
  draw-scale:.5,
  /// Pour avoir différentes perspectives : 
  /// - si true, représentation isométrique, 
  /// - si 1 vue tikz3d-fr, 
  /// - si 2 première vue de ProfCollege, 
  /// - si 3 seconde vue de Profcollege, 
  /// - sinon vue par defaut de cetz -> boolean | int
  iso:false,
  /// Texte à mettre en dessous de l'empilement (pour les vues) -> str | content
  text:none,
  /// Permet « d’éclater » l’empilement construit vers la droite afin de mieux permettre une visualisation par « tranches » -> float | int
  x-spread:0,
  /// Permet « d’éclater » l’empilement construit vers le haut afin de mieux permettre une visualisation par « couches » -> float | int
  y-spread:0,
  /// Permet « d’éclater » l’empilement construit vers l'avant afin de mieux permettre une visualisation par « tranches » -> float | int
  z-spread:0,
  /// Arguments à passer à la boite -> dictionary
  box-args:(),
) = {}

/// Vue du dessus pour une building -> content
#let above-view(
  /// Arguments pour building -> arguments
  ..it,
  /// Nom de la vue -> str | content
  text:"Vue du dessus"
) = {}

/// Vue de droite pour une building -> content
#let right-view(
  /// Arguments pour building -> arguments
  ..it,
   /// Nom de la vue -> str | content
   text:"Vue de droite"
) = {}

/// Vue de face pour une building -> content
#let front-view(
  /// Arguments pour building -> arguments
  ..it,
   /// Nom de la vue -> str | content
   text:"Vue de face"
) = {}

/// Vue du dessous pour une building -> content
#let below-view(
  /// Arguments pour building -> arguments
  ..it,
   /// Nom de la vue -> str | content
   text:"Vue du dessous"
) = {}

/// Vue de gauche pour une building -> content
#let left-view(
  /// Arguments pour building -> arguments
  ..it,
   /// Nom de la vue -> str | content
   text:"Vue de gauche"
) = {}

/// Vue de l'arrière pour une building -> content
#let back-view(
  /// Arguments pour building -> arguments
  ..it,
   /// Nom de la vue -> str | content
   text:"Vue arrière"
) = {}

/// Fonction qui détermine les définitions pour cetz.canvas de `x`, `y` et `z` pour un angle de vue défini par l'élévation (θ) et l'azimut (φ).
/// Il faut la passer directement au canvas, sans oublier les deux points
///
/// #example(`#canvas(..thetaphi(theta:60, phi:150), {
///   import draw:*  
///   repere
/// })`)
///
///  -> dictionary
#let thetaphi(
  /// Elévation θ -> int | angle
  theta:70,
  /// Azimut φ -> int | angle
  phi:110
) = {}

/// Fonction utilisée pour dessiner le dé en 3D.
///
/// Attention, l'utilisation de dice dans un canvas modifie la matrice !
///
/// #example(`#canvas({
///   import draw:*  
///   dice(standalone:false, origin: (0,2), front:2, top:3, s:.8, vue: "D")
///   repere
/// })`)
///
/// #example(`#canvas({
///   import draw:*  
///   dice(standalone: false, origin: (0,2), front: 2, top:3, s:.8, vue: "G")
///   repere
/// })`)
///
/// -> content | function
#let dice(
  /// true si seul, false si déjà dans un canvas -> boolean 
  standalone: true,
  /// Nombre de points sur la face de devant -> int 
  front: 1,
  /// Nombre de points sur la face du dessus -> int 
  top: 2,
  /// Echelle du dessin -> int | float | ratio
  s: 1.0,
  /// Angle theta des coordonnées sphériques -> int | float 
  theta: 70,
  /// Angle phi des coordonnées sphériques-> int | float
  phi: 110,
  /// Vue "D" pour doite ou "G" pour gauche -> str
  vue: "D",
  /// Couleur du dé, par défaut légèrement gris -> color
  color: rgb("d3d3d3"),
  /// Couleur des points -> color
  dot-color: black,
  /// Position de l'origine du dé -> array
  origin:(0,0,0),
  /// Arguments supplémentaires pour la boîte -> dictionary
  box-args:(),
  /// Opacité des dés -> ratio
  opacity:100%,
) = {}

/// Tirage aléatoire ou non de $n$ dés.
///
/// ```example
/// #throws(5, yams: true, colors: (rgb("ef476f"), rgb("ffd166"), rgb("06d6a0"), rgb("118ab2"), rgb("073b4c")), seed: 999, s: 1.2,  yams-h: -.15,  opacity: 70%,)
/// ```
/// -> content
#let throws(
  /// Nombre de dés -> int 
  n,
  /// Liste des jets none par défaut sinon liste des couples (face avant, face du dessus),  -> none | array
  list: none,
  /// Graine du pseudo aléatoire  -> int
  seed: 42,
  /// Dés présentés "collés"  -> boolean
  yams: false,
  /// Avancement des dés dans la ligne si yams  -> int | float
  yams-h:.1,
  /// Espacement horizontal des dés  -> length
  espace-h: 5mm,
  /// Echelle -> int | float | ratio
  s: 1.0,
  /// Liste des couleurs des dés  -> array
  colors: (rgb("d3d3d3"),),
  /// couleur des points -> color
  dot-color: black,
  /// Angle theta des coordonnées sphériques -> int | float
  theta: 70,
  /// Angle phi des coordonnées sphériques -> int | float
  phi: 110,
  /// Vue "D" droite ou "G" gauche -> str
  vue: "D",
  /// Arguments supplémentaires pour la boîte -> dictionary
  box-args:(),
  /// Opacité des dés -> ratio
  opacity:100%,
) = {}

/// Fonction créée par eric1102 sur Discord : dessine une face d'un dé avec la possibilité de changer la couleur du dé, des points et du trait -> content
#let dice-face(
  /// Entier de 1 à 6 -> int
  num,
  /// Couleur du dé -> none | color 
  fill: none,
  /// Noir pour une couleur claire ou blanc pour une couleur sombre ou la couleur choisie -> auto | color
  spot-fill: auto,
  /// Couleur du contour, si le dé est en couleur et stroke:auto alors même couleur -> auto | stroke
  stroke: auto
) = {}

