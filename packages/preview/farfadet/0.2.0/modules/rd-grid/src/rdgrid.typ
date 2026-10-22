// rdgrid.typ (façade) — `rdgrid` et `setrdgrid`. Les quatre formes de grille se choisissent par la clé
// `type:` de `rdgrid`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "moteur/rdgrid.typ" as _m

/// `rdgrid(xmax, ymax)` : grille de `xmax` × `ymax` polygones, dont la forme se choisit par
/// la clé `type` : triangles équilatéraux (`"equi"`, défaut), hexagones (`"hexa"`), hexagones tournés
/// (`"rhexa"`) ou grille isométrique (`"iso"`).
///
/// Chaque polygone porte un nom (`trg-<i>-<j>` pour equi et iso, `hexa-<i>-<j>` pour les hexagones), et ses
/// sommets un point nommé (`trg-1-3-north east`, `hexa-0-2-center`…), à la manière des ancres de TikZ. Pour
/// dessiner par-dessus (polygones copiés depuis le livret GeoGebra), on passe une fonction à `code-after` :
/// elle reçoit `pt(nom)`, `path(chemin-tikz, stroke:, fill:)`, `node(point, contenu)`, `xy(x, y)` (unités
/// TikZ) et le dictionnaire `points`.
///
/// ```example
/// #rdgrid(grid: -1, 10, 7, code-after: g => (g.path)(
///   "[color = red, line width=1.5pt] (trg-8-4-north east)--(trg-3-0-south east)--(trg-1-0-south east)--(trg-0-2-north west)--(trg-0-2-north east)--(trg-2-0-north east)--(trg-7-5-north east)--cycle"))
/// ```
///
/// - type (str): `"equi"`, `"hexa"`, `"rhexa"` ou `"iso"`. Défaut : `"equi"`.
/// - xmax (int): nombre de polygones en largeur.
/// - ymax (int): nombre de polygones en hauteur.
/// - width (auto, int, float, length): taille d'un polygone (côté, ou rayon des hexagones), en cm si sans unité. Défaut : `1` (`0.7` pour hexa et rhexa).
/// - radius (auto, int, float, length): autre nom de `width`. Défaut : `auto`.
/// - grid (auto, int): disposition : equi et iso : `1` ou `-1` (premier triangle vers le haut / la droite, ou l'inverse) ; rhexa : `1`, `-1`, `2`, `-2` (décalage des lignes impaires) ; hexa : signe = décalage des colonnes impaires. Défaut : `1`.
/// - orientation (auto, bool): orientation d'un polygone isolé (pics TikZ) ; sans effet sur une grille, où le type la fixe. Défaut : `true`.
/// - dot (auto, bool): un point à chaque sommet. Défaut : `false`.
/// - dot-style (auto, dictionary): style des points. Défaut : `(shape: "circle", min-width: 1.5pt, fill: "gray")`.
/// - dot-style-app (auto, none, dictionary): style ajouté à `dot-style`. Défaut : `none`.
/// - show-grid (auto, bool): trace les polygones. Défaut : `true`.
/// - show-num (auto, bool): numéro `i-j` au centre de chaque polygone. Défaut : `false`.
/// - num-style (auto, dictionary): style des numéros. Défaut : sans empattement, gras, `footnotesize`.
/// - only-dot (auto, bool): papier pointé (`show-grid: false, dot: true`). Défaut : `false`.
/// - scope-style (auto, dictionary): style des traits de la grille. Défaut : `(draw: "gray", line-width: 0.5pt)`.
/// - scope-style-app (auto, none, dictionary): style ajouté à `scope-style`. Défaut : `none`.
/// - frame (auto, bool): cadre autour de la grille (iso seulement). Défaut : `true`.
/// - lines (auto, bool): lignes verticales (iso seulement). Défaut : `true`.
/// - polygon-style (auto, none, dictionary): style de polygones nommés (ajout, comme `tikzset` en LaTeX) : `("hexa-0-0": (fill: red))`. Défaut : `none`.
/// - code-after (auto, none, function): dessin ajouté par-dessus la grille (ajout ; le `tikzpicture` de l'utilisateur). Défaut : `none`.
/// - line-join (auto, str): jointure des traits (ajout ; `line join=bevel`). Défaut : `"bevel"`.
/// - style (auto, str, array): style(s) nommé(s) (`setrdgrid(definir: …)`). Défaut : `auto`.
/// -> content
#let rdgrid(
  type: "equi",
  width: auto,
  radius: auto,
  grid: auto,
  orientation: auto,
  dot: auto,
  dot-style: auto,
  dot-style-app: auto,
  show-grid: auto,
  show-num: auto,
  num-style: auto,
  only-dot: auto,
  scope-style: auto,
  scope-style-app: auto,
  frame: auto,
  lines: auto,
  polygon-style: auto,
  code-after: auto,
  line-join: auto,
  style: auto,
  xmax,
  ymax,
) = {
  let genre = type
  let local = (
    width: width, radius: radius, grid: grid, orientation: orientation, dot: dot, dot-style: dot-style,
    dot-style-app: dot-style-app, show-grid: show-grid, show-num: show-num, num-style: num-style,
    only-dot: only-dot, scope-style: scope-style, scope-style-app: scope-style-app, frame: frame,
    lines: lines, polygon-style: polygon-style, code-after: code-after, line-join: line-join, style: style,
  )
  if genre not in _m.rdgrid-types {
    panic("rdgrid : type de grille inconnu « " + str(genre) + " ». Types possibles : « equi », « hexa », « rhexa », « iso ».")
  }
  for (n, v) in (("xmax", xmax), ("ymax", ymax)) {
    if std.type(v) != int or v < 1 { panic("rdgrid : " + n + " doit être un entier positif ; reçu : " + repr(v) + ".") }
  }
  context {
    let r = reglages-resoudre(_m.rdgrid-reglages, pour: genre, local: _m.rd-local(local), commande: "rdgrid")
    _m.rdgrid-rendu(r, genre, xmax, ymax, commande: "rdgrid")
  }
}

/// `setrdgrid(clés)` : le réglage de `rdgrid`, sous ses quatre formes (mêmes clés que `rdgrid`).
///
/// - `setrdgrid(cle: v, …)` : réglage global, pour la suite du document ; les appels s'ajoutent clé par clé.
/// - `setrdgrid(pour: "hexa", cle: v, …)` : réglage d'un seul type de grille (`"equi"`, `"hexa"`,
///   `"rhexa"`, `"iso"`, ou un tableau de types).
/// - `setrdgrid(definir: "nom", cle: v, …)` : définit le style nommé « nom »,
///   appelé ensuite par `style: "nom"` ; `pour:` contrôle alors les clés contre un type.
/// - `setrdgrid(reinitialiser: true)` : oublie les réglages global et par type (styles gardés) ; avec des
///   clés, repart des défauts puis les applique. `reinitialiser: "tout"` oublie aussi les styles.
///
/// ```example
/// #setrdgrid(scope-style: (draw: "blue!50", line-width: 0.3pt))
/// #setrdgrid(pour: "iso", frame: false)
/// #setrdgrid(definir: "pointe", only-dot: true, dot-style-app: (fill: "red"))
/// #rdgrid(type: "iso", 6, 4, width: 0.5) #rdgrid(style: "pointe", 5, 3, width: 0.5)
/// ```
///
/// - pour (none, str, array): type visé (`"equi"`, `"hexa"`, `"rhexa"`, `"iso"`) ou `none` (tous). Défaut : `none`.
/// - reinitialiser (bool, str): `true` : oublie les réglages ; `"tout"` : oublie aussi les styles. Défaut : `false`.
/// - definir (none, str): nom du style à définir avec les clés données. Défaut : `none`.
/// - ..cles (any): clés de `rdgrid` (et `style:`), hors `type`.
/// -> content
#let setrdgrid(pour: none, reinitialiser: false, definir: none, ..cles) = _m.rd-regler(
  _m.rdgrid-reglages, "setrdgrid", pour, reinitialiser, definir, cles,
)
