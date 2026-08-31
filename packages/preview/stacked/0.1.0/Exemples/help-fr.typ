/// empilement de petits cubes sur une grille, donnés sous forme de liste allant du fond vers l'avant `3251` puis de gauche à droite (séparés par des virgules), une couleur peut être indiquée au début ou à la fin, couleurs de base avec none : avant $->$ jaune, dessus $->$ vert et droite $->$ rouge, sinon une liste de 3 couleurs peut-être donnée dans colors
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
  /// coefficient multiplicateur des tracés (de 1pt), défaut 60% soit 0.6pt -> int | float | ratio
  thickness:60%,
  /// Lignes en noir, défaut false -> boolean | color
  border-stroke:false,
  /// Ajout d'une seconde vue de l'assemblage depuis la "droite" -> boolean
  side:false,
  /// light:20% -> de combien éclaircir quand une seule couleur -> float | ratio | array
  light:20%,
  /// modifie la taille des arêtes d'un cube de base -> float | ratio
  draw-scale:.5,
  /// permet « d’éclater » l’empilement construit vers la droite afin de mieux permettre une visualisation par « tranches » -> float | int
  x-spread:0,
  /// permet « d’éclater » l’empilement construit vers le haut afin de mieux permettre une visualisation par « couches » -> float | int
  y-spread:0,
  /// permet « d’éclater » l’empilement construit vers l'avant afin de mieux permettre une visualisation par « tranches » -> float | int
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
  /// Pour avoir différentes perspectives : si true, représentation isométrique, si 1 vue tikz3d-fr, si 2 première vue de ProfCollege, si 3 seconde vue de Profcollege, sinon vue par defaut de cetz -> boolean | int
  iso:false,
  /// Espacement avec la seconde vue -> length | relative length | fraction
  space:2em,
  /// Autorise des "trous" (hauteur nulle) dans l'empilement aléatoire à partir de la deuxième pile ; la première pile reste toujours "pleine" (hauteur >= 1 partout) -> boolean
  holes:false,
  /// Mode aléatoire spécifique : 1 (LCG double min par gemini), 2 et 4 (LCG décroissant inspiré de ProfCollege par Claude), 3 (package suiji) -> auto | int
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

/// Assemblage de petits cubes avec mix de couleurs : chaque n° correspond à la position dans la liste de couleurs (16 max : 1 à 9 et a à g), le "0" et le "o" représentent un trou, le "x" donne la première couleur, les cubes sont donnés dans une liste de listes : de l'avant vers l'arrière par un nombre/string \"5432a\" puis étage par étage `btt`, listes de gauches à droite
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
  /// coefficient multiplicateur des tracés (de 1pt), défaut 60% soit 0.6pt -> int | float | ratio
  thickness:60%,
  /// Lignes en noir, défaut false -> boolean | color
  border-stroke:false,
  // parametre pour certaines vues _rev:false (si true haut vers bas) -> boolean
  _rev:false,
  // parametre pour la vue du dessous -> boolean
  _dessous:false,
  // paramètre pour la vue de l'arrière -> boolean
  _back:false,
  /// light:20% -> de combien éclaircir quand une seule couleur -> float | ratio | array
  light:20%,
  /// modifie la taille des arêtes d'un cube de base -> float | ratio
  draw-scale:.5,
  /// Pour avoir différentes perspectives : si true, représentation isométrique, si 1 vue tikz3d-fr, si 2 première vue de ProfCollege, si 3 seconde vue de Profcollege, sinon vue par defaut de cetz -> boolean | int
  iso:false,
  /// Texte à mettre en dessous de l'empilement (pour les vues) -> str | content
  text:none,
  /// permet « d’éclater » l’empilement construit vers la droite afin de mieux permettre une visualisation par « tranches » -> float | int
  x-spread:0,
  /// permet « d’éclater » l’empilement construit vers le haut afin de mieux permettre une visualisation par « couches » -> float | int
  y-spread:0,
  /// permet « d’éclater » l’empilement construit vers l'avant afin de mieux permettre une visualisation par « tranches » -> float | int
  z-spread:0,
  /// Arguments à passer à la boite -> dictionary
  box-args:(),
) = {}

/// fonction qui détermine les définitions pour cetz.canvas de `x`, `y` et `z` pour un angle de vue défini par l'élévation (θ) et l'azimut (φ).
/// Il faut la passer directement au canvas, sans oublier les deux points
///
///  -> dictionary
#let thetaphi(
  /// élévation θ -> int | angle
  theta:70,
  /// azimut φ -> int | angle
  phi:110
) = {}

/// fonction utilisée pour dessiner le dé en 3D, paramètres : pour indiquer si déjà dans canvas ou non `standalone:` true, points devant `front:` 1, point au dessus `top:` 2, échelle `s:` 1.0, couleur `color:` rgb("d3d3d3"), couleur des points `dot-color:` black, angles des coordonnées sphériques `theta:` 70 et `phi:` 110, vue droite ou gauche `vue:` "D", position du dé `origin:` (0, 0, 0) 
///
/// Attention, l'utilisation de dice dans un canvas modifie la matrice !
///
/// -> content | function
#let dice(
  /// standalone:true si seul, false si déjà dans un canvas -> boolean 
  standalone: true,
  /// nombre de points sur la face de devant -> int 
  front: 1,
  /// nombre de points sur la face du dessus -> int 
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

/// Tirage aléatoire ou non de $n$ dés. -> content
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