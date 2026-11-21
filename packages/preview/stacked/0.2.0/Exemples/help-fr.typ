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
#let maincoords(
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

/// Dessine un polyèdre convexe et sa section par un plan, en projection oblique (CeTZ).
/// Le polyèdre est défini par la liste de ses sommets : les faces sont déduites automatiquement (enveloppe
/// convexe). Les arêtes cachées sont en pointillés ; la section est remplie et ses parties cachées sont en
/// pointillés. Le plan se donne par trois points ou par les quatre coefficients de son équation cartésienne.
/// Ancres : "0", "1", ... pour les sommets (dans l'ordre de `vertices`), puis les points d'intersection des
/// prolongements (voir `show-extensions` et `show-all`) ; `help: true` les numérote.
/// -> content
#let polysection(
  /// Sommets du polyèdre convexe, sous forme de points (x, y, z) ; par défaut le cube [-1, 1]³. Les
  /// fonctions de solidvertices (regpyramid, regprism, regpolyhedron...) en fournissent -> array
  vertices: (
    (-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
    (-1, -1,  1), (1, -1,  1), (1, 1,  1), (-1, 1,  1)
  ),
  /// Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by +
  /// cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de
  /// 3 points) -> array | dictionary
  ..plane-args,
  /// Noms des sommets, dans l'ordre de `vertices` -> none | array
  vertices-names: none,
  /// Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné
  /// par une équation) -> none | array
  plane-names: none,
  /// Calcule et affiche les prolongements des côtés de la section et leurs points d'intersection -> bool
  show-extensions: false,
  /// Affiche aussi les intersections des droites portant les côtés de la section avec les droites
  /// portant les arêtes du solide -> bool
  show-all: false,
  /// Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5,
  /// -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  /// Tolérance numérique (distances) -> float
  eps: 1e-6,
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres)
  /// -> cetz commands
  more: (),
  /// Couleur du contour de la section -> color
  section-border: blue,
  /// Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  /// Affiche en rouge le numéro des ancres (sommets, puis points d'intersection) -> bool
  help: false,
  /// Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) ->
  /// str | array | dictionary
  hidden-style:"dashed",
  /// Style des lignes de rappel des prolongements -> str | array | dictionary
  extensions-style:"dotted"
) = {}

/// Point situé à une fraction du segment [A C], en partant de A (en 2D ou en 3D).
/// Pratique pour placer des points dans `more`, par exemple le milieu d'une arête ou d'un segment de section.
/// `ratio` est un nombre entre 0 et 1 ou un pourcentage : point-ratio((0, 0, 0), 25%, (4, 0, 0)) donne (1, 0, 0).
/// -> array
#let point-ratio(
  /// Point de départ (x, y) ou (x, y, z) -> array
  A,
  /// Fraction du segment [A C] : nombre (0.25) ou pourcentage (25%) -> int | float | ratio
  ratio,
  /// Point d'arrivée, de même dimension que A -> array
  C,
) = {}

/// Dessine un cylindre et sa section par un plan, en projection oblique (CeTZ).
/// Le cylindre est défini par son rayon, sa hauteur, le centre de sa base et la direction de son axe. Le plan se donne comme pour `polysection` (trois points ou quatre coefficients). Les arêtes et les parties cachées de la section sont en pointillés. Les cas particuliers sont traités : plan parallèle à l'axe (rectangle), perpendiculaire à l'axe (cercle) ; l'ellipse peut montrer ses foyers.
/// Ancres : "c0", "c1" (centres des bases), "i0", "i1", ... (extrémités des cordes de la section sur les bases), "sc" (centre de la section quand c'est une ellipse complète), "f0", "f1" (foyers).
/// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
/// -> content
#let cylsection(
  /// Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by + cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de 3 points) -> array | dictionary
  ..plane-args,
  /// Rayon du cylindre -> int | float
  radius: 1,
  /// Hauteur du cylindre (distance entre les deux bases) -> int | float
  height: 2,
  /// Centre de la base « inférieure » -> array
  base: (0, 0, 0),
  /// Direction de l'axe, de la base vers la face supérieure (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné par une équation) -> none | array
  plane-names: none,
  /// Trace l'axe en tirets-points -> bool
  show-axis: false,
  /// Marque les foyers de la section quand ils existent (ellipse, parabole, hyperbole) -> bool
  show-foci: false,
  /// Trace un rayon, avec son étiquette, sur la base visible -> bool
  show-radius: false,
  /// Étiquette du rayon ; auto : sa valeur numérique ; none pour ne pas en mettre -> auto | none | content
  radius-label: $r$,
  /// Trait du rayon -> stroke
  radius-stroke: black + 0.8pt,
  /// Marque les centres des bases et le centre de la section quand il est évident -> bool
  show-centers: false,
  /// Trace les dimensions de la section avec leurs étiquettes : rayon d'un cercle, ou demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec show-foci) -> bool
  show-dims: false,
  /// Étiquettes des dimensions de la section : dictionnaire (r:, a:, b:, c:) dont les valeurs remplacent les étiquettes symboliques ($r'$, $a$, $b$, $c$) (la valeur auto donne la vraie valeur), ou auto pour tout remplacer -> auto | dictionary
  dims-labels: (:),
  /// Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (c0: $O$, s: $S$) ; elles se placent vers l'extérieur du solide -> dictionary
  point-labels: (:),
  /// Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  label-unit: none,
  /// Nombre de décimales en mode auto -> int
  label-digits: 2,
  /// Séparateur décimal en mode auto : "," ou "." -> str
  label-decimal: ",",
  /// Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5, -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  /// Tolérance numérique (distances) -> float
  eps: 1e-6,
  /// Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres) -> content
  more: (),
  /// Couleur du contour de la section -> color
  section-border: blue,
  /// Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  /// Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) -> str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Dessine un cône et sa section par un plan, en projection oblique (CeTZ).
/// Le cône est défini par le rayon et le centre de sa base, sa hauteur et la direction de son axe. Le plan se donne comme pour `polysection`. Selon le plan, la section est un cercle, une ellipse, une parabole ou un morceau d'hyperbole ; un plan passant par le sommet donne un triangle. Les foyers sont calculés avec les sphères de Dandelin. Les parties cachées sont en pointillés.
/// Ancres : "c0" (centre de la base), "s" (sommet), "i0", "i1", ... (extrémités de la corde sur la base), "sc" (centre de la section quand c'est un cercle), "f0", "f1" (foyers).
/// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`). -> content
#let conesection(
  /// Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by + cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de 3 points) -> array | dictionary
  ..plane-args,
  /// Rayon de la base -> int | float
  radius: 1,
  /// Hauteur du cône (distance de la base au sommet) -> int | float
  height: 2,
  /// Centre de la base -> array
  base: (0, 0, 0),
  /// Direction de l'axe, de la base vers le sommet (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné par une équation) -> none | array
  plane-names: none,
  /// Trace l'axe en tirets-points -> bool
  show-axis: false,
  /// Marque les foyers de la section quand ils existent (ellipse, parabole, hyperbole) -> bool
  show-foci: false,
  /// Trace un rayon, avec son étiquette, sur la base (en pointillés si elle est cachée) -> bool
  show-radius: false,
  /// Étiquette du rayon ; auto : sa valeur numérique ; none pour ne pas en mettre -> auto | none | content
  radius-label: $r$,
  /// Trait du rayon -> stroke
  radius-stroke: black + 0.8pt,
  /// Marque le centre de la base et le centre de la section quand c'est un cercle -> bool
  show-centers: false,
  /// Marque le sommet -> bool
  show-apex: false,
  /// Trace les dimensions de la section avec leurs étiquettes : rayon d'un cercle, ou demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec show-foci) -> bool
  show-dims: false,
  /// Étiquettes des dimensions de la section : dictionnaire (r:, a:, b:, c:) dont les valeurs remplacent les étiquettes symboliques ($r'$, $a$, $b$, $c$) (la valeur auto donne la vraie valeur), ou auto pour tout remplacer -> auto | dictionary
  dims-labels: (:),
  /// Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (c0: $O$, s: $S$) ; elles se placent vers l'extérieur du solide -> dictionary
  point-labels: (:),
  /// Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  label-unit: none,
  /// Nombre de décimales en mode auto -> int
  label-digits: 2,
  /// Séparateur décimal en mode auto : "," ou "." -> str
  label-decimal: ",",
  /// Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5,
  /// -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  /// Tolérance numérique (distances) -> float
  eps: 1e-6,
  /// Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres) -> content
  more: (),
  /// Couleur du contour de la section -> color
  section-border: blue,
  /// Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  /// Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) -> str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Dessine un double cône (« sablier ») et sa section par un plan, en projection oblique (CeTZ).
/// Deux cônes de même sommet et de même axe, opposés par le sommet ; chacun a pour hauteur `height` et pour rayon de base `radius`. Les sections possibles : cercle, ellipse, parabole, hyperbole (deux branches, une par nappe), deux droites sécantes (plan passant par le sommet), point ou droite.
/// Ancres : "s" (sommet), "c0" (centre de la base du bas), "c1" (centre de la base du haut), "i0", "i1", ... (extrémités des cordes sur les bases), "sc" (centre d'une section circulaire), "f0", "f1" (foyers).
/// Limite : le tracé suppose que les deux nappes ne se masquent pas l'une l'autre, ce qui est le cas tant que l'angle entre la direction de vue et l'axe dépasse le demi-angle au sommet.
/// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`). -> content
#let doubleconesection(
  /// Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by + cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de 3 points) -> array | dictionary
  ..plane-args,
  /// Rayon de la base de chaque nappe -> int | float
  radius: 1,
  /// Hauteur de chaque nappe (distance du sommet à chaque base) -> int | float
  height: 2,
  /// Sommet commun des deux cônes -> array
  apex: (0, 0, 0),
  /// Direction de l'axe, de la nappe du bas vers la nappe du haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné par une équation) -> none | array
  plane-names: none,
  /// Trace l'axe en tirets-points -> bool
  show-axis: false,
  /// Marque les foyers de la section quand ils existent (ellipse, parabole, hyperbole) -> bool
  show-foci: false,
  /// Trace un rayon, avec son étiquette, sur la base tournée vers l'observateur -> bool
  show-radius: false,
  /// Étiquette du rayon ; auto : sa valeur numérique ; none pour ne pas en mettre -> auto | none | content
  radius-label: $r$,
  /// Trait du rayon -> stroke
  radius-stroke: black + 0.8pt,
  /// Marque les centres des deux bases et le centre de la section quand c'est un cercle -> bool
  show-centers: false,
  /// Marque le sommet -> bool
  show-apex: false,
  /// Trace les dimensions de la section avec leurs étiquettes : rayon d'un cercle, ou demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec show-foci) -> bool
  show-dims: false,
  /// Étiquettes des dimensions de la section : dictionnaire (r:, a:, b:, c:) dont les valeurs remplacent les étiquettes symboliques ($r'$, $a$, $b$, $c$) (la valeur auto donne la vraie valeur), ou auto pour tout remplacer -> auto | dictionary
  dims-labels: (:),
  /// Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (c0: $O$, s: $S$) ; elles se placent vers l'extérieur du solide -> dictionary
  point-labels: (:),
  /// Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  label-unit: none,
  /// Nombre de décimales en mode auto -> int
  label-digits: 2,
  /// Séparateur décimal en mode auto : "," ou "." -> str
  label-decimal: ",",
  /// Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5, -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  /// Tolérance numérique (distances) -> float
  eps: 1e-6,
  /// Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres) -> content
  more: (),
  /// Couleur du contour de la section -> color
  section-border: blue,
  /// Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  /// Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) -> str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Dessine une sphère et sa section par un plan, en projection oblique (CeTZ).
/// Le contour apparent est calculé exactement (c'est une ellipse en projection oblique) ; un équateur facultatif donne l'impression de relief. La section est un cercle dont les parties cachées sont en pointillés.
/// Ancres : "o" (centre), "sc" (centre du cercle de section).
/// Avec `show-dims`, le rayon du cercle de section est tracé et étiqueté. Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`). -> content
#let spheresection(
  /// Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by + cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de 3 points) -> array | dictionary
  ..plane-args,
  /// Rayon de la sphère -> int | float
  radius: 1,
  /// Centre de la sphère -> array
  center: (0, 0, 0),
  /// Direction des pôles (sert seulement à tracer l'équateur) -> array
  axis: (0, 1, 0),
  /// Trace l'équateur (cercle perpendiculaire à l'axe), qui donne du relief -> bool
  show-equator: true,
  /// Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné par une équation) -> none | array
  plane-names: none,
  /// Trace un rayon sur le contour apparent, où il apparaît en vraie grandeur -> bool
  show-radius: false,
  /// Étiquette du rayon ; auto : sa valeur numérique ; none pour ne pas en mettre -> auto | none | content
  radius-label: $r$,
  /// Trait du rayon -> stroke
  radius-stroke: black + 0.8pt,
  /// Marque le centre de la sphère et celui du cercle de section -> bool
  show-centers: false,
  /// Trace les dimensions de la section avec leurs étiquettes : le rayon du cercle de section -> bool
  show-dims: false,
  /// Étiquettes des dimensions de la section : dictionnaire (r:, a:, b:, c:) dont les valeurs remplacent les étiquettes symboliques ($r'$, $a$, $b$, $c$) (la valeur auto donne la vraie valeur), ou auto pour tout remplacer -> auto | dictionary
  dims-labels: (:),
  /// Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (o: $O$, sc: $I$) -> dictionary
  point-labels: (:),
  /// Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  label-unit: none,
  /// Nombre de décimales en mode auto -> int
  label-digits: 2,
  /// Séparateur décimal en mode auto : "," ou "." -> str
  label-decimal: ",",
  /// Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5, -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  /// Tolérance numérique (distances) -> float
  eps: 1e-6,
  /// Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres) -> content
  more: (),
  /// Couleur du contour de la section -> color
  section-border: blue,
  /// Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  /// Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) -> str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Paramètres de vue (x, y, z) d'une projection orthographique centrée sur le point de longitude `lon` et de
/// latitude `lat`. La sphère apparaît alors comme un cercle, avec l'axe sud-nord vertical. À utiliser avec
/// l'orientation par défaut de `globe` (axe (0, 1, 0), Greenwich (0, 0, 1)).
/// Plus `lat` est grand, plus l'équateur s'ouvre (effet de relief) et plus le pôle Nord s'éloigne du bord haut
/// du dessin ; entre 10 et 20 il en paraît pratiquement le point le plus haut. -> dictionary
#let globe-view(
  /// Longitude du point au centre du dessin, en degrés (est positif) -> int | float
  lon: 20,
  /// Latitude du point au centre du dessin, en degrés (nord positif) -> int | float
  lat: 25,
) = {}

/// Dessine un globe terrestre (variante de `spheresection`) pour expliquer les coordonnées géographiques.
/// Latitude : angle depuis l'équateur, de -90° (sud) à +90° (nord). Longitude : angle depuis le méridien de Greenwich, de -180° (ouest) à +180° (est). Tous les angles se donnent en degrés.
/// On peut afficher l'équateur, les tropiques, le méridien de Greenwich, des parallèles et des méridiens (isolés ou en quadrillage), l'axe sud-nord, des villes (voir `globe-cities`) ou des points de coordonnées quelconques et, pour un point, la construction de ses coordonnées : angle de longitude dans le plan de l'équateur et angle de latitude dans le plan de son méridien. Un plan peut aussi être donné pour dessiner une section (un parallèle est un plan perpendiculaire à l'axe, un méridien un plan qui le contient).
/// La projection oblique déforme la sphère en ellipse : `globe-view` donne une vue orthographique.
/// Ancres : "o" (centre), "n", "s" (pôles), "g" (point de coordonnées (0, 0)), "p0", "p1", ... et le nom de chaque point, "sc" (centre de la section).
/// Avec `angles: auto` pour un point (ou `lon-label: auto` / `lat-label: auto` pour tous), les angles de la construction affichent leurs valeurs en degrés au lieu de θ et φ (`label-digits`, `label-decimal`). -> content
#let globe(
  /// Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by + cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de 3 points) -> array | dictionary
  ..plane-args,
  /// Rayon de la sphère -> int | float
  radius: 1,
  /// Centre de la sphère -> array
  center: (0, 0, 0),
  /// Direction de l'axe sud-nord, du pôle Sud vers le pôle Nord -> array
  axis: (0, 1, 0),
  /// Direction du point de latitude 0 et de longitude 0, projetée perpendiculairement à l'axe ; avec les valeurs par défaut, le méridien de Greenwich fait face à l'observateur et l'est est à droite -> array
  greenwich: (0, 0, 1),
  /// Trace l'équateur -> bool
  show-equator: true,
  /// Trace le méridien de Greenwich (demi-cercle de pôle à pôle) -> bool
  show-greenwich: true,
  /// Trace les tropiques du Cancer et du Capricorne (latitudes ±23,44°) -> bool
  show-tropics: false,
  /// Latitudes supplémentaires à tracer, en degrés, par exemple (30, -45) -> array
  parallels: (),
  /// Longitudes supplémentaires à tracer, en degrés, par exemple (90, -120) -> array
  meridians: (),
  /// Pas, en degrés, d'un quadrillage de parallèles et de méridiens (par exemple 30) ; none pour aucun -> none | int | float
  graticule: none,
  /// Trace l'axe sud-nord (en pointillés à l'intérieur de la sphère et derrière elle) -> bool
  show-axis: false,
  /// Longueur dont l'axe dépasse chaque pôle, en fraction du rayon -> int | float
  axis-extension: 0.3,
  /// Marque le centre de la sphère et celui de la section -> bool
  show-centers: false,
  /// Points à placer : noms de villes de `globe-cities` ou dictionnaires (name:, lat:, lon:, color:, label:, angles:) ; `angles: true` ajoute la construction des coordonnées du point, `angles: auto` la fait avec les valeurs numériques des angles -> array
  points: (),
  /// Étiquette de l'angle de longitude ; auto : sa valeur en degrés -> auto | content
  lon-label: $theta$,
  /// Étiquette de l'angle de latitude ; auto : sa valeur en degrés -> auto | content
  lat-label: $phi$,
  /// Nombre de décimales des angles en mode auto -> int
  label-digits: 2,
  /// Séparateur décimal des angles en mode auto : "," ou "." -> str
  label-decimal: ",",
  /// Couleur de la construction des angles -> color
  angle-color: rgb("#8e44ad"),
  /// Trait de l'équateur -> stroke
  equator-stroke: rgb("#c0392b") + 1pt,
  /// Trait du méridien de Greenwich -> stroke
  greenwich-stroke: rgb("#2a9d4a") + 1pt,
  /// Trait des tropiques -> stroke
  tropics-stroke: rgb("#e67e22") + 0.8pt,
  /// Trait des parallèles et méridiens du quadrillage -> stroke
  grid-stroke: gray + 0.4pt,
  /// Trait de l'axe sud-nord -> stroke
  axis-stroke: black + 0.8pt,
  /// Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné par une équation) -> none | array
  plane-names: none,
  /// Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (o: $O$, n: $N$) -> dictionary
  point-labels: (:),
  /// Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5, -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  /// Tolérance numérique (distances) -> float
  eps: 1e-6,
  /// Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres) -> content
  more: (),
  /// Couleur du contour de la section -> color
  section-border: blue,
  /// Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  /// Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) -> str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Affiche un polyèdre convexe, son patron et les étapes intermédiaires de son dépliage (CeTZ).
/// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat). Les étapes demandées (`steps`) sont dessinées
/// côte à côte, à la même échelle. Le solide est posé sur sa face du dessous, qui reste fixe : les autres faces se
/// déplient autour d'elle. Le patron est choisi parmi plusieurs arbres de dépliage (parcours en largeur et en profondeur) :
/// le premier dont les faces ne se recouvrent pas est retenu. Les faces sont opaques, ombrées et triées de la plus
/// lointaine à la plus proche ; le solide fermé est dessiné sans arêtes cachées.
/// Ancres, suffixées -1, -2, ... s'il y a plusieurs étapes : "f0", "f1", ... (centres des faces) et "v0", "v1", ...
/// (sommets, dans l'ordre de `vertices` ; un sommet est pris sur la première face de l'arbre qui le contient). -> content
#let polyunfold(
  /// Sommets du polyèdre convexe (par défaut le cube [-1, 1]³), comme pour polysection ; les fonctions
  /// de solidvertices en fournissent -> array
  vertices: (
    (-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
    (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1),
  ),
  /// Valeurs du paramètre de dépliage t à afficher côte à côte, de 0 (solide fermé) à 1 (patron à plat).
  /// Par défaut (0, 0.5, 1), ou (1,) avec view: "top" -> auto | array
  steps: auto,
  /// Une seule valeur de t (prioritaire sur steps) -> none | int | float
  t: none,
  /// Indice de la face qui reste fixe ; auto : la face du dessous -> auto | int
  root: auto,
  /// Direction « vers le haut », utilisée pour reconnaître la face du dessous -> array
  up: (0, 1, 0),
  /// "oblique" : projection oblique x, y, z (par défaut) ; "top" : patron à plat vu de dessus, en vraie
  /// grandeur, orienté comme la vue oblique -> str
  view: "oblique",
  /// Nombre de figures par ligne ; auto : toutes sur une seule ligne -> auto | int
  columns: auto,
  /// Espace entre les figures (unités du repère) -> int | float
  gap: 0.8,
  /// Légendes placées sous les figures (une par étape) -> none | array
  labels: none,
  /// Flèches entre deux figures consécutives d'une même ligne -> bool
  arrows: true,
  /// Couleur des faces -> color
  fill: rgb("#a9cce3"),
  /// Couleur de la face qui reste fixe (la base) -> color
  base-fill: rgb("#f5b7b1"),
  /// Couleurs des faces, répétées si besoin ; remplace fill et base-fill -> none | array
  palette: none,
  /// Trait des arêtes -> stroke
  edge-stroke: 0.7pt + black,
  /// Image à l'écran du vecteur unitaire de l'axe x (vue oblique, comme pour polysection) ; sans effet
  /// avec view: "top" -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (vue oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur (vue oblique) ->
  /// array
  z: (-0.5, -0.5),
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas ; la première figure garde ses
  /// coordonnées d'origine, les ancres existent pour toutes -> content
  more: (),
  /// Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
  /// Angle de rotation du dessin en view:"top" -> angle
  angle: 0deg,
) = {}

/// Affiche un cylindre, son patron et les étapes intermédiaires de son dépliage (CeTZ).
/// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat). Le disque de base reste fixe ; la surface latérale se déroule (la longueur de ses arcs est conservée) en un rectangle de longueur 2πr tangent au disque, et le second disque bascule avec elle. Les faces sont opaques, ombrées et triées de la plus lointaine à la plus proche.
/// Avec `cotes: true`, on ajoute les cotes (r, h sur le solide fermé ; 2πr, h, r sur le patron) ; les étiquettes sont à l'extérieur pour les hauteurs et sous les lignes pour les autres.
/// Ancres, suffixées -1, -2, ... s'il y a plusieurs étapes : "c0" (centre du disque fixe), "c1" (centre du second disque), "pc", "qc" (points de contact, en bas et en haut), "cote-r", "cote-h", "cote-p" (milieux des lignes de cote). 
/// Avec `base-ratio`, on choisit où chaque disque touche la surface latérale du patron (ratio mesuré depuis l'extrémité gauche en vue de dessus) : un nombre pour les deux disques, ou (bas, haut) pour les placer indépendamment. -> content
#let cylunfold(
  /// Rayon du cylindre -> int | float
  radius: 1,
  /// Hauteur du cylindre -> int | float
  height: 2,
  /// Centre du disque de base, qui reste fixe -> array
  base: (0, 0, 0),
  /// Direction de l'axe, du disque de base vers l'autre disque (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Direction, dans le plan de la base, du point où le solide touche son patron ; auto : le côté opposé
  /// à l'observateur, le patron se déplie alors vers le fond -> auto | array
  contact: auto,
  /// Position du ou des disques le long de la surface latérale du patron : ratio entre 0 et 1 mesuré depuis l'extrémité gauche du rectangle en vue de dessus (0.5 : au milieu) ; un nombre pour les deux disques, ou un tableau (bas, haut) pour les placer indépendamment -> int | float | array
  base-ratio: 0.5,
  /// Valeurs du paramètre de dépliage t à afficher côte à côte, de 0 (solide fermé) à 1 (patron à plat).
  /// Par défaut (0, 0.5, 1), ou (1,) avec view: "top" -> auto | array
  steps: auto,
  /// Une seule valeur de t (prioritaire sur steps) -> none | int | float
  t: none,
  /// "oblique" : projection oblique x, y, z (par défaut) ; "top" : patron à plat vu de dessus, en vraie grandeur, orienté comme la vue oblique -> str
  view: "oblique",
  /// Nombre de figures par ligne ; auto : toutes sur une seule ligne -> auto | int
  columns: auto,
  /// Espace entre les figures (unités du repère) -> int | float
  gap: 0.8,
  /// Légendes placées sous les figures (une par étape) -> none | array
  labels: none,
  /// Flèches entre deux figures consécutives d'une même ligne -> bool
  arrows: true,
  /// Couleur des faces -> color
  fill: rgb("#a9cce3"),
  /// Couleur du disque fixe -> color
  base-fill: rgb("#f5b7b1"),
  /// Couleur du second disque -> color
  top-fill: rgb("#f9e79f"),
  /// Finesse du maillage de la surface latérale (nombre de facettes par tour) -> int
  segments: 60,
  /// Ajoute les cotes : r et h sur le solide fermé (t = 0, vue oblique) ; 2πr, h et r sur le patron (view: "top") -> bool
  cotes: false,
  /// Étiquettes des cotes : dictionnaire (r:, h:, g:, p:, a:) dont les valeurs remplacent les étiquettes symboliques (la valeur auto donne la vraie valeur), ou auto pour tout remplacer
  /// -> auto | dictionary
  cote-labels: (:),
  /// Couleur des cotes -> color
  cote-color: rgb("#7b241c"),
  /// Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  cote-unit: none,
  /// Nombre de décimales en mode auto -> int
  cote-digits: 2,
  /// Séparateur décimal en mode auto : "," ou "." -> str
  cote-decimal: ",",
  /// Trait des arêtes -> stroke
  edge-stroke: 0.7pt + black,
  /// Image à l'écran du vecteur unitaire de l'axe x (vue oblique, comme pour polysection) ; sans effet avec view: "top" -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (vue oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur (vue oblique) -> array
  z: (-0.5, -0.5),
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas ; la première figure garde ses coordonnées d'origine, les ancres existent pour toutes -> content
  more: (),
  /// Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
  /// Angle de rotation du dessin en view:"top" -> angle
  angle: 0deg,
) = {}

/// Affiche un cône, son patron et les étapes intermédiaires de son dépliage (CeTZ).
/// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat). Le disque de base reste fixe ; la surface latérale se déroule en un secteur circulaire de rayon égal à la génératrice, tangent au disque. Les faces sont opaques, ombrées et triées de la plus lointaine à la plus proche.
/// Avec `cotes: true`, on ajoute les cotes (r, h, g sur le solide fermé ; g, 2πr, angle du secteur et r sur le patron) ; les étiquettes sont à l'extérieur pour les génératrices et sous les lignes pour les autres.
/// Ancres, suffixées -1, -2, ... s'il y a plusieurs étapes : "c0" (centre de la base), "s" (sommet), "pc" (point de contact), "cote-r", "cote-h", "cote-g", "cote-p", "cote-a" (milieux des lignes de cote).
/// Avec `base-ratio`, on choisit où le disque de base touche l'arc du secteur (ratio mesuré depuis l'extrémité gauche de l'arc en vue de dessus).
/// -> content
#let coneunfold(
  /// Rayon du cône -> int | float
  radius: 1,
  /// Hauteur du cône -> int | float
  height: 2,
  /// Centre de la base, qui reste fixe -> array
  base: (0, 0, 0),
  /// Direction de l'axe, de la base vers le sommet (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Direction, dans le plan de la base, du point où le solide touche son patron ; auto : le côté opposé à l'observateur, le patron se déplie alors vers le fond -> auto | array
  contact: auto,
  /// Position du disque de base le long de l'arc du secteur : ratio entre 0 et 1 mesuré depuis l'extrémité gauche de l'arc en vue de dessus (0.5 : au milieu) -> int | float
  base-ratio: 0.5,
  /// Valeurs du paramètre de dépliage t à afficher côte à côte, de 0 (solide fermé) à 1 (patron à plat).
  /// Par défaut (0, 0.5, 1), ou (1,) avec view: "top" -> auto | array
  steps: auto,
  /// Une seule valeur de t (prioritaire sur steps) -> none | int | float
  t: none,
  /// "oblique" : projection oblique x, y, z (par défaut) ; "top" : patron à plat vu de dessus, en vraie grandeur, orienté comme la vue oblique -> str
  view: "oblique",
  /// Nombre de figures par ligne ; auto : toutes sur une seule ligne -> auto | int
  columns: auto,
  /// Espace entre les figures (unités du repère) -> int | float
  gap: 0.8,
  /// Légendes placées sous les figures (une par étape) -> none | array
  labels: none,
  /// Flèches entre deux figures consécutives d'une même ligne -> bool
  arrows: true,
  /// Couleur des faces -> color
  fill: rgb("#a9cce3"),
  /// Couleur de la base -> color
  base-fill: rgb("#f5b7b1"),
  /// Finesse du maillage de la surface latérale (nombre de facettes par tour) -> int
  segments: 60,
  /// Ajoute les cotes : r, h et g sur le solide fermé (t = 0, vue oblique) ; g, 2πr, angle du secteur (clé a) et r sur le patron (view: "top") -> bool
  cotes: false,
  /// Étiquettes des cotes : dictionnaire (r:, h:, g:, p:, a:) dont les valeurs remplacent les étiquettes symboliques (la valeur auto donne la vraie valeur), ou auto pour tout remplacer
  /// -> auto | dictionary
  cote-labels: (:),
  /// Couleur des cotes -> color
  cote-color: rgb("#7b241c"),
  /// Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  cote-unit: none,
  /// Nombre de décimales en mode auto -> int
  cote-digits: 2,
  /// Séparateur décimal en mode auto : "," ou "." -> str
  cote-decimal: ",",
  /// Trait des arêtes -> stroke
  edge-stroke: 0.7pt + black,
  /// Image à l'écran du vecteur unitaire de l'axe x (vue oblique, comme pour polysection) ; sans effet avec view: "top" -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (vue oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur (vue oblique) -> array
  z: (-0.5, -0.5),
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas ; la première figure garde ses coordonnées d'origine, les ancres existent pour toutes -> content
  more: (),
  /// Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
  /// Angle de rotation du dessin en view:"top" -> angle
  angle: 0deg,
) = {}

/// Sommets d'un polygone régulier dans le plan perpendiculaire à `axis`, dans le sens direct autour de l'axe.
/// Le polygone est défini par son nombre de côtés et par son rayon circonscrit ou la longueur de son côté. Les
/// points sont plans : ils servent à tracer le polygone, mais pas de `vertices` pour un solide. -> array (de points (x, y, z))
#let regpolygon(
  /// Nombre de côtés (au moins 3) -> int
  n,
  /// Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  /// donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  /// Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  /// Centre du polygone -> array
  center: (0, 0, 0),
  /// Normale au plan du polygone (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  /// "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  /// "vertex" : c'est un sommet -> str
  start: "side",
) = {}

/// Sommets d'une pyramide régulière : les n sommets de la base (dans le sens direct autour de l'axe), puis le
/// sommet de la pyramide en dernier. À utiliser comme `vertices:` de `polysection` ou de `polyunfold`. -> array (de points (x, y, z))
#let regpyramid(
  /// Nombre de côtés de la base (au moins 3) -> int
  n,
  /// Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  /// donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  /// Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  /// Hauteur de la pyramide -> int | float
  height: 1,
  /// Centre de la base (ou milieu de la hauteur avec centered: true) -> array
  center: (0, 0, 0),
  /// Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  /// "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  /// "vertex" : c'est un sommet -> str
  start: "side",
  /// true : `center` est le milieu de la hauteur au lieu du centre de la base -> bool
  centered: false,
) = {}

/// Sommets d'un prisme droit à base régulière : les n sommets de la base, puis les n sommets de la face
/// supérieure dans le même ordre. À utiliser comme `vertices:` de `polysection` ou de `polyunfold`. -> array (de points (x, y, z))
#let regprism(
  /// Nombre de côtés de la base (au moins 3) -> int
  n,
  /// Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  /// donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  /// Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  /// Hauteur du prisme -> int | float
  height: 1,
  /// Centre de la base (ou milieu de la hauteur avec centered: true) -> array
  center: (0, 0, 0),
  /// Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  /// "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  /// "vertex" : c'est un sommet -> str
  start: "side",
  /// true : `center` est le milieu de la hauteur au lieu du centre de la base -> bool
  centered: false,
) = {}

/// Sommets d'un antiprisme : comme un prisme, mais la face supérieure est tournée de 180°/n par rapport à la base, ce qui donne des faces latérales triangulaires. Mêmes conventions que `regprism`. -> array (de points (x, y, z))
#let regantiprism(
  /// Nombre de côtés de chaque base (au moins 3) -> int
  n,
  /// Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  /// donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  /// Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  /// Distance entre les plans des deux bases -> int | float
  height: 1,
  /// Centre de la base (ou milieu de la hauteur avec centered: true) -> array
  center: (0, 0, 0),
  /// Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  /// "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  /// "vertex" : c'est un sommet -> str
  start: "side",
  /// true : `center` est le milieu de la hauteur au lieu du centre de la base -> bool
  centered: false,
) = {}

/// Sommets d'une bipyramide : les n sommets du polygone du milieu, puis le sommet du haut, puis celui du bas. -> array (de points (x, y, z))
#let regbipyramid(
  /// Nombre de côtés du polygone du milieu (au moins 3) -> int
  n,
  /// Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  /// donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  /// Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  /// Hauteur de chaque pyramide (distance du polygone du milieu à chaque sommet) -> int | float
  height: 1,
  /// Centre du polygone du milieu -> array
  center: (0, 0, 0),
  /// Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  /// "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  /// "vertex" : c'est un sommet -> str
  start: "side",
) = {}

/// Sommets d'un polyèdre régulier (solide de Platon) : "tétraèdre", "cube", "octaèdre", "dodécaèdre" ou
/// "icosaèdre" (les noms anglais sont acceptés). Le solide est posé sur l'une de ses faces, l'axe pointant vers le haut,
/// et un côté de cette face fait face à l'observateur ; c'est aussi la face que `polyunfold` laisse fixe par défaut. -> array (de points (x, y, z))
#let regpolyhedron(
  /// Nom du polyèdre : "tétraèdre", "cube", "octaèdre", "dodécaèdre" ou "icosaèdre" -> str
  name,
  /// Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  /// donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  /// Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  /// Centre du solide -> array
  center: (0, 0, 0),
  /// Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  /// Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
) = {}