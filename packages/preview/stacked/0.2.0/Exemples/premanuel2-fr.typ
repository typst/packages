/// Dessine un polyèdre convexe et sa section par un plan, en projection oblique (CeTZ).
/// Le polyèdre est défini par la liste de ses sommets. Le plan se donne par trois points ou par les quatre coefficients de son équation cartésienne.
/// Ancres : "0", "1", ... pour les sommets (dans l'ordre de `vertices`), puis les points d'intersection des
/// prolongements (voir `show-extensions` et `show-all`) ; `help: true` les numérote.
/// ```example
/// // Exemples d'utilisation :
/// #polysection((-1, -1, 0), (1, 0, 1), (0, 1, -1))
/// ```
/// ```example
/// // Plan donné par trois points nommés, avec les prolongements des côtés de la section
/// #polysection((-1, -1, 0), (1, 0, 1), (0, 1, -1), plane-names: ($A$, $B$, $C$), show-extensions: true)
/// ```
/// ```example
/// // Pyramide régulière (sommets calculés par `regpyramid`) avec le nom des sommets
/// #polysection(0, 1, -0.2, -0.75, vertices: regpyramid(4, side: 2, height: 3),
///   vertices-names: ($A$, $B$, $C$, $D$, $S$), more:({draw.line("4",("0",50%,"2"),stroke:(paint:teal, dash:"dashed")); cetz.angle.right-angle(("0",50%,"2"),"1","4", radius:.2,label:none)}))
/// ```
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
/// `ratio` est un nombre entre 0 et 1 ou un pourcentage.
/// ```example
/// #point-ratio((0, 2, 2), 25%, (4, 0, 10))
/// ```
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
/// Le cylindre est défini par son rayon, sa hauteur, le centre de sa base et la direction de son axe. Le plan se donne comme pour `polysection` (trois points ou quatre coefficients). Les cas particuliers sont traités : plan parallèle à l'axe (rectangle), perpendiculaire à l'axe (cercle) ; l'ellipse peut montrer ses foyers.
/// Ancres : "c0", "c1" (centres des bases), "i0", "i1", ... (extrémités des cordes de la section sur les bases), "sc" (centre de la section quand c'est une ellipse complète), "f0", "f1" (foyers).
/// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
/// ```example
/// // Exemples d'utilisation :
/// #cylsection((0, 0.5, 0.5), (1, 0.3, -0.2), (-0.6, 1.4, 0.1), plane-names: ($A$, $B$, $C$))
/// ```
/// ```example
/// // Plan parallèle à l'axe (rectangle)
/// #cylsection(1, 0, 0, -0.5, radius: 1, height: 2)
/// ```
/// ```example
/// // Ellipse complète avec un rayon, les centres et les foyers
/// #cylsection(0.6, 1, 0, -1, show-radius: true, show-centers: true, show-foci: true,
///   point-labels: (c0: $O$, c1: $O'$, f0: $F$, f1: $F'$))
/// ```
/// ```example
/// // Dimensions de l'ellipse (a, b, c) avec leurs vraies valeurs
/// #cylsection(0.6, 1, 0, -1, show-dims: true, show-foci: true, dims-labels: auto, label-unit: "cm")
/// ```
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
  /// Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Dessine un cône et sa section par un plan, en projection oblique (CeTZ).
/// Le cône est défini par le rayon et le centre de sa base, sa hauteur et la direction de son axe. Le plan se donne comme pour `polysection`. Selon le plan, la section est un cercle, une ellipse, une parabole ou un morceau d'hyperbole ; un plan passant par le sommet donne un triangle. Les foyers sont calculés avec les sphères de Dandelin. 
/// Ancres : "c0" (centre de la base), "s" (sommet), "i0", "i1", ... (extrémités de la corde sur la base), "sc" (centre de la section quand c'est un cercle), "f0", "f1" (foyers).
/// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
/// ```example
/// // Exemples d'utilisation :
/// #conesection((0.3, 0.2, 0.5), (0.6, 0.4, -0.7), (-0.6, 0.3, 0.1), plane-names: ($A$, $B$, $C$))
/// ```
/// ```example
/// // Plan contenant l'axe (triangle)
/// #conesection(1, 0, 0, 0, show-axis: true)
/// ```
/// ```example
/// // Ellipse avec ses foyers
/// #conesection(0.3, 1, 0, -0.9, show-foci: true, point-labels: (f0: $F$, f1: $F'$))
/// ```
/// ```example
/// // Dimensions de l'ellipse et rayon de la base avec leurs vraies valeurs
/// #conesection(0.3, 1, 0, -0.9, show-dims: true, dims-labels: auto, show-radius: true, radius-label: auto)
/// ```
/// -> content
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
  /// Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Dessine un double cône (« sablier ») et sa section par un plan, en projection oblique (CeTZ).
/// Deux cônes de même sommet et de même axe, opposés par le sommet ; chacun a pour hauteur `height` et pour rayon de base `radius`. Les sections possibles : cercle, ellipse, parabole, hyperbole (deux branches, une par nappe), deux droites sécantes (plan passant par le sommet), point ou droite.
/// Ancres : "s" (sommet), "c0" (centre de la base du bas), "c1" (centre de la base du haut), "i0", "i1", ... (extrémités des cordes sur les bases), "sc" (centre d'une section circulaire), "f0", "f1" (foyers).
/// Limite : le tracé suppose que les deux nappes ne se masquent pas l'une l'autre, ce qui est le cas tant que l'angle entre la direction de vue et l'axe dépasse le demi-angle au sommet.
/// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
/// ```example
/// // Exemples d'utilisation :
/// #doubleconesection(1, 0, 0, -0.4, show-foci: true, show-apex: true,
///   point-labels: (s: $S$, f0: $F$, f1: $F'$))
/// ```
/// ```example
/// // Parabole (plan parallèle à une génératrice)
/// #doubleconesection(0.894, -0.447, 0, 0.447, show-foci: true)
/// ```
/// ```example
/// // Plan passant par le sommet
/// #doubleconesection(1, 0, 0, 0, show-axis: true, show-apex: true)
/// ```
/// ```example
/// // Rayon du cercle de section (plan perpendiculaire à l'axe) avec sa vraie valeur
/// #doubleconesection(0, 1, 0, -1, show-dims: true, dims-labels: auto)
/// ```
/// -> content
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
  /// Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Dessine une sphère et sa section par un plan, en projection oblique (CeTZ).
/// Le contour apparent est calculé exactement (c'est une ellipse en projection oblique) ; un équateur facultatif donne l'impression de relief. 
/// Ancres : "o" (centre), "sc" (centre du cercle de section).
/// Avec `show-dims`, le rayon du cercle de section est tracé et étiqueté. Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
/// ```example
/// // Exemples d'utilisation :
/// #spheresection(1, 1, 1, -0.5)
/// ```
/// ```example
/// // Plan horizontal avec un rayon, les centres et des étiquettes
/// #spheresection(0, 1, 0, -0.6, center: (0, 1, 0), show-radius: true, show-centers: true,
///   point-labels: (o: $O$, sc: $I$))
/// ```
/// ```example
/// // Rayon de la sphère et du cercle de section avec leurs vraies valeurs
/// #spheresection(0, 1, 0, -0.6, center: (0, 1, 0), show-radius: true, radius-label: auto, show-dims: true, dims-labels: auto)
/// ```
/// -> content
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
  /// Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Paramètres de vue (x, y, z) d'une projection orthographique centrée sur le point de longitude `lon` et de latitude `lat`. La sphère apparaît alors comme un cercle, avec l'axe sud-nord vertical. À utiliser avec l'orientation par défaut de `globe` (axe (0, 1, 0), Greenwich (0, 0, 1)).
/// Plus `lat` est grand, plus l'équateur s'ouvre (effet de relief) et plus le pôle Nord s'éloigne du bord haut du dessin ; entre 10 et 20, il en paraît pratiquement le point le plus haut.
/// ```example
/// // Exemple d'utilisation :
/// #globe(..globe-view(lon: 0, lat: 15), show-axis: true)
/// ```
/// -> dictionary
#let globe-view(
  /// Longitude du point au centre du dessin, en degrés (est positif) -> int | float
  lon: 20,
  /// Latitude du point au centre du dessin, en degrés (nord positif) -> int | float
  lat: 25,
) = {}

/// Dessine un globe terrestre (variante de `spheresection`) pour expliquer les coordonnées géographiques.
/// Latitude : angle depuis l'équateur, de -90° (sud) à +90° (nord). Longitude : angle depuis le méridien de Greenwich, de -180° (ouest) à +180° (est). Tous les angles se donnent en degrés.
/// On peut afficher l'équateur, les tropiques, le méridien de Greenwich, des parallèles et des méridiens (isolés ou en quadrillage), l'axe sud-nord, des villes (voir `globe-cities` : 50 grandes villes) ou des points de coordonnées quelconques et, pour un point, la construction de ses coordonnées : angle de longitude dans le plan de l'équateur et angle de latitude dans le plan de son méridien. Un plan peut aussi être donné pour dessiner une section (un parallèle est un plan perpendiculaire à l'axe, un méridien un plan qui le contient).
/// La projection oblique déforme la sphère en ellipse : `globe-view` donne une vue orthographique.
/// Ancres : "o" (centre), "n", "s" (pôles), "g" (point de coordonnées (0, 0)), "p0", "p1", ... et le nom de chaque point, "sc" (centre de la section).
/// Avec `angles: auto` pour un point (ou `lon-label: auto` / `lat-label: auto` pour tous), les angles de la construction affichent leurs valeurs en degrés au lieu de θ et φ (`label-digits`, `label-decimal`).
/// ```example
/// // Exemples d'utilisation :
/// #globe(..globe-view(lon: 20, lat: 20), show-axis: true, show-tropics: true, graticule: 30,
///   points: ("Paris", "Le Caire", "Dakar"))
/// ```
/// ```example
/// // Construction de la longitude et de la latitude d'une ville
/// #globe(..globe-view(lon: 60, lat: 20), show-axis: true, show-centers: true,
///   points: (("city": "Tokyo", angles: true),), point-labels: (o: $O$, g: $G$))
/// ```
/// ```example
/// // Point de coordonnées quelconques
/// #globe(..globe-view(lon: 40, lat: 20), points: ((name: "M", lat: 35, lon: 60, angles: true),))
/// ```
/// ```example
/// // Construction avec les valeurs numériques de la longitude et de la latitude
/// #globe(..globe-view(lon: 60, lat: 20), points: (("city": "Tokyo", angles: auto),))
/// ```
/// -> content
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
  /// Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {}

/// Affiche un polyèdre convexe, son patron et les étapes intermédiaires de son dépliage (CeTZ).
/// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat). Les étapes demandées (`steps`) sont dessinées côte à côte, à la même échelle. Le solide est posé sur sa face du dessous, qui reste fixe : les autres faces se déplient autour d'elle. Le patron est choisi parmi plusieurs arbres de dépliage (parcours en largeur et en profondeur) :
/// le premier dont les faces ne se recouvrent pas est retenu. Les faces sont opaques, ombrées et triées de la plus lointaine à la plus proche ; le solide fermé est dessiné sans arêtes cachées.
/// Ancres, suffixées -1, -2, ... s'il y a plusieurs étapes : "f0", "f1", ... (centres des faces) et "v0", "v1", ... (sommets, dans l'ordre de `vertices` ; un sommet est pris sur la première face de l'arbre qui le contient).
/// ```example
/// // Exemples d'utilisation :
/// #move(polyunfold(steps: (0, 0.4, 0.75, 1), labels: ($t = 0$, $t = 0.4$, $t = 0.75$, $t = 1$)),dy:1.85cm)
/// ```
/// ```example
/// // Patron à plat, en vraie grandeur, d'une pyramide
/// #move(polyunfold(vertices: regpyramid(5, side: 2, height: 3), view: "top"),dy:.9cm)
/// ```
/// ```example
/// // Une couleur par face et numéros des sommets
/// #polyunfold(t: 0, length: 1.2cm,
///   palette: (red, green, blue, yellow, orange, purple).map(c => c.lighten(60%)),
///   more: {
///     import cetz.draw: *
///     for i in range(8) {
///       content("v" + str(i), text(size: 8pt, str(i)), anchor: "south-west", padding: 0.05)
///     }
///   })
/// ```
/// -> content
#let polyunfold(
  /// Sommets du polyèdre convexe (par défaut le cube [-1, 1]³), comme pour polysection ; les fonctions de solidvertices en fournissent -> array
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
  /// Couleur de la face qui reste fixe (la base) -> color
  base-fill: rgb("#f5b7b1"),
  /// Couleurs des faces, répétées si besoin ; remplace fill et base-fill -> none | array
  palette: none,
  /// Trait des arêtes -> stroke
  edge-stroke: 0.7pt + black,
  /// Image à l'écran du vecteur unitaire de l'axe x (vue oblique, comme pour polysection) ; sans effet avec view: "top" -> array
  x: (1, 0),
  /// Image à l'écran du vecteur unitaire de l'axe y (vue oblique) -> array
  y: (0, 1),
  /// Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur (vue oblique) ->
  /// array
  z: (-0.5, -0.5),
  /// Commandes CeTZ supplémentaires dessinées dans le même canevas ; la première figure garde ses coordonnées d'origine, les ancres existent pour toutes -> content
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
/// Avec `base-ratio`, on choisit où chaque disque touche la surface latérale du patron (ratio mesuré depuis l'extrémité gauche en vue de dessus) : un nombre pour les deux disques, ou (bas, haut) pour les placer indépendamment.
/// ```example
/// // Exemples d'utilisation :
/// #move(cylunfold(steps: (0, 0.3, 0.6, 1)),dy:1.25cm)
/// ```
/// ```example
/// // Cotes sur le solide fermé
/// #cylunfold(t: 0, cotes: true)
/// ```
/// ```example
/// // Patron à plat avec les vraies valeurs
/// #move(cylunfold(view: "top", cotes: true, radius: 1.5, height: 2.5, cote-labels: auto, cote-unit: "cm"),dy:1.5cm)
/// ```
/// ```example
/// // Disques décalés sur le patron (à 25 % et à 75 % de la longueur du rectangle)
/// #cylunfold(view: "top", cotes: true, base-ratio: (0.25, 0.75))
/// ```
/// -> content
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
  /// Angle de rotation du dessin en vue:"top" -> angle
  angle: 0deg,
) = {}

/// Affiche un cône, son patron et les étapes intermédiaires de son dépliage (CeTZ).
/// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat). Le disque de base reste fixe ; la surface latérale se déroule en un secteur circulaire de rayon égal à la génératrice, tangent au disque. Les faces sont opaques, ombrées et triées de la plus lointaine à la plus proche.
/// Avec `cotes: true`, on ajoute les cotes (r, h, g sur le solide fermé ; g, 2πr, angle du secteur et r sur le patron) ; les étiquettes sont à l'extérieur pour les génératrices et sous les lignes pour les autres.
/// Ancres, suffixées -1, -2, ... s'il y a plusieurs étapes : "c0" (centre de la base), "s" (sommet), "pc" (point de contact), "cote-r", "cote-h", "cote-g", "cote-p", "cote-a" (milieux des lignes de cote).
/// Avec `base-ratio`, on choisit où le disque de base touche l'arc du secteur (ratio mesuré depuis l'extrémité gauche de l'arc en vue de dessus).
/// ```example
/// // Exemples d'utilisation :
/// #move(coneunfold(steps: (0, 0.3, 0.6, 1)), dy:2em)
/// ```
/// ```example
/// // Cotes sur le solide fermé, avec les vraies valeurs
/// #coneunfold(t: 0, cotes: true, radius: 1.5, height: 2.5, cote-labels: auto, cote-unit: "cm")
/// ```
/// ```example
/// // Patron à plat : génératrice, longueur 2πr de l'arc et angle du secteur
/// #coneunfold(view: "top", cotes: true, radius: 3, height: 4, cote-labels: auto, cote-unit: "cm", length: 0.6cm)
/// ```
/// ```example
/// // Disque de base placé à 20 % de l'arc, depuis la gauche
/// #coneunfold(view: "top", cotes: true, base-ratio: 0.2,)
/// ```
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
  /// Angle de rotation du dessin en vue:"top" -> angle
  angle: 0deg,
) = {}

/// Sommets d'un polygone régulier dans le plan perpendiculaire à `axis`, dans le sens direct autour de l'axe.
/// Le polygone est défini par son nombre de côtés et par son rayon circonscrit ou la longueur de son côté. Les points sont plans : ils servent à tracer le polygone, mais pas de `vertices` pour un solide.
/// ```example
/// // Exemple d'utilisation :
/// #cetz.canvas({
///   import cetz.draw: *
///   line(..regpolygon(5, side: 2, axis: (0, 0, 1)), close: true)
/// })
/// ```
/// -> array (de points (x, y, z))
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

/// Sommets d'une pyramide régulière : les n sommets de la base (dans le sens direct autour de l'axe), puis le sommet de la pyramide en dernier. À utiliser comme `vertices:` de `polysection` ou de `polyunfold`.
/// ```example
/// // Exemples d'utilisation :
/// #polysection(1, 1, 0, -0.1, vertices: regpyramid(5, side: 2, height: 3))
/// ```
/// ```example
/// // Dépliage d'une pyramide à base carrée
/// #polyunfold(vertices: regpyramid(4, side: 2, height: 3), steps: (0, 0.5, 1), length: 0.5cm)
/// ```
/// -> array (de points (x, y, z))
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

/// Sommets d'un prisme droit à base régulière : les n sommets de la base, puis les n sommets de la face supérieure dans le même ordre. À utiliser comme `vertices:` de `polysection` ou de `polyunfold`.
/// ```example
/// // Exemples d'utilisation :
/// #polysection(1, 0.4, 0, 0.2, vertices: regprism(6, radius: 1.2, height: 2.5))
/// ```
/// ```example
/// // Patron à plat d'un prisme à base triangulaire
/// #polyunfold(vertices: regprism(3, side: 1, height: 2), view: "top")
/// ```
/// -> array (de points (x, y, z))
#let regprism(
  /// Nombre de côtés de la base (au moins 3) -> int
  n,
  /// Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ; donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
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
  /// "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ; "vertex" : c'est un sommet -> str
  start: "side",
  /// true : `center` est le milieu de la hauteur au lieu du centre de la base -> bool
  centered: false,
) = {}

/// Sommets d'un antiprisme : comme un prisme, mais la face supérieure est tournée de 180°/n par rapport à la base, ce qui donne des faces latérales triangulaires. Mêmes conventions que `regprism`.
/// ```example
/// // Exemple d'utilisation :
/// #polyunfold(vertices: regantiprism(5, radius: 1.2, height: 1.2), view: "top")
/// ```
/// -> array (de points (x, y, z))
#let regantiprism(
  /// Nombre de côtés de chaque base (au moins 3) -> int
  n,
  /// Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ; donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
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
  /// "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ; "vertex" : c'est un sommet -> str
  start: "side",
  /// true : `center` est le milieu de la hauteur au lieu du centre de la base -> bool
  centered: false,
) = {}

/// Sommets d'une bipyramide : les n sommets du polygone du milieu, puis le sommet du haut, puis celui du bas.
/// ```example
/// // Exemple d'utilisation :
/// #polysection(0, 1, 0, -0.5, vertices: regbipyramid(5, side: 2, height: 3))
/// ```
/// -> array (de points (x, y, z))
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

/// Sommets d'un polyèdre régulier (solide de Platon) : "tétraèdre", "cube", "octaèdre", "dodécaèdre" ou "icosaèdre" (les noms anglais sont acceptés). Le solide est posé sur l'une de ses faces, l'axe pointant vers le haut, et un côté de cette face fait face à l'observateur ; c'est aussi la face que `polyunfold` laisse fixe par défaut.
/// ```example
/// // Exemples d'utilisation :
/// #polysection(0.3, 1, 0.2, 0, vertices: regpolyhedron("dodécaèdre", side: 1))
/// ```
/// ```example
/// // Patron à plat d'un icosaèdre
/// #polyunfold(vertices: regpolyhedron("icosaèdre", side: 1.5), view: "top", length: 0.6cm)
/// ```
/// -> array (de points (x, y, z))
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