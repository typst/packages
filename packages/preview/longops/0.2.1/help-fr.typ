#set text(lang: "fr")
#import "/Operations.typ"

/// conversion en décimal depuis une autre base (défaut : 2). -> str | int | float
#let from-base(
  /// nombre à convertir -> int | float | str
  val, 
  /// base depuis laquelle convertir -> int
  base: 2,
  /// mode fr pour avoir des virgules à la place des points -> boolean
  fr:false,
  /// indique en indice que le résultat est en base 10 -> boolean
  show-base: false,
) = {}

/// conversion d'un nombre en écriture décimale vers une autre base (défaut : 2). -> str | int | float
#let to-base(
  /// nombre à convertir -> int | float | str
  val, 
  /// base vers laquelle convertir -> int
  base: 2,
  /// mode fr pour avoir des virgules à la place des points -> boolean
  fr:false,
  /// indique en indice que le résultat est en base 10 -> boolean
  show-base: false,
  /// permet de limiter le nombre de chiffres après la virgule si le développement est infini -> int
  precision: 6,
) = {}

/// conversion d'un nombre d'une base (défaut : 2) vers une autre base (défaut : 10). -> str | int | float
#let base-to-base(
  /// nombre à convertir -> int | float | str
  val,
  /// base depuis laquelle convertir -> int
  base-from: 2,
  /// base vers laquelle convertir -> int
  base-to: 10,
  /// pour avoir le détail de la convertion -> boolean
  explain: false,
  /// pour avoir l'égalité de la convertion -> boolean
  equal: false,
  /// permet de limiter le nombre de chiffres après la virgule si le développement est infini -> int
  precision: 6,
  /// mode fr pour avoir des virgules à la place des points -> boolean
  fr: false,
  /// différents modes de présentation "paren", "line", "simple" -> str
  mode:"paren",
) = {}

/// Pose l'addition de 2 ou plusieurs nombres avec possibilité de cacher la ligne de résultat avec `hide-result`, une `list` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc. -> content
#let addition(
  /// Base numérique (de 2 à 36) -> int
  base: 10,
  /// Montrer ou non dans quelle base l'addition est posée -> boolean
  show-base:false,
  /// Montrer ou non les retenues -> boolean
  show-carry: true, 
  /// couleur des retenues -> color
  carries-color:red,
  /// Taille des colonnes  -> length | relative length
  size:1em,
  /// Affichage des nombres à la française "," ou pas -> boolean
  fr: true,
  /// Cache les retenues et le résultat -> boolean
  hide-result:false,
  /// Couleur du cadre des chiffres cachés -> color
  border-color:blue.mix(gray),
  /// Couleur des chiffres cachés si solution = true -> color
  solution-color:red,
  /// Comment les chiffres sont cachés : soient "rect" pour un rectangle arrondi soit ... -> str
  type-mask:"rect",
  /// list des chiffres à cacher dans une addition à trous -> array
  list:(),
  /// Montrer les retenues et le résultat en mode hide-result (pour les corrections) -> boolean
  solution:false,
  /// sign d'égalité, false ou true [=] ou un symbole \$ = \$ -> boolean | content
  sign:false,
  /// Espacement si plusieurs sur la même ligne - -> length | relative length | fraction
  space:1fr,
  /// taille du des chiffres : 1em  -> length | relative length
  text-size:1em,
  /// termes à additionner -> array | arguments
  ..args
) = {}

/// Pose la soustraction de 2 ou plusieurs nombres avec possibilité de cacher la ligne de résultat avec `hide-result`, une `list` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc. -> content
#let soustraction(
  /// Base de calcul (de 2 à 36) -> int
  base: 10,
  /// Montrer ou non dans quelle base l'addition est posée -> boolean
  show-base:false,
  /// Montrer ou non les retenues -> boolean
  show-borrow: true, 
  /// Si fr:false, montrer ou non le nombre initial barré -> boolean
  canceled:false, 
  /// Ecriture française ou avec emprunts à l'anglaise -> boolean
  fr:true, 
  /// couleur des retenues -> color
  carries-color:red,
  /// Taille des colonnes  -> length | relative length
  size:1em,
  /// Ajoute ou non des zéros -> boolean
  zeros:true,
  /// Cache les retenues et le résultat -> boolean
  hide-result:false,
  /// Couleur du cadre des chiffres cachés -> color
  border-color:blue.mix(gray),
  /// Couleur des chiffres cachés si solution = true -> color
  solution-color:red,
  /// Comment les chiffres sont cachés : soient "rect" pour un rectangle arrondi soit ... -> str
  type-mask:"rect",
  /// list des chiffres à cacher dans une addition à trous -> array
  list:(),
  /// Montrer les retenues et le résultat en mode hide-result (pour les corrections) -> boolean
  solution:false,
  /// sign d'égalité, false ou true [=] ou un symbole \$ = \$ -> boolean | content
  sign:false,
  /// taille du des chiffres : 1em  -> length | relative length
  text-size:1em,
  /// Espacement si plusieurs sur la même ligne -> length | relative length | fraction
  space:1fr,
  /// termes de la soustraction -> array | arguments
  ..args
) = {}

/// Pose la multiplication de 2 nombres entiers ou décimaux avec possibilité de cacher les lignes avec `hide-result`, une `list` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc. -> content
#let multiplication(
  /// premier facteur -> int | float | str
  a, 
  /// second facteur -> int | float | str
  b,
  /// Base de numération (2 à 36) -> int
  base: 10,
  /// Montrer ou non dans quelle base l'addition est posée -> boolean
  show-base:false,
  /// Afficher les retenues : false, true ("all"), "mult", "add" -> boolean | str
  carries: false,
  /// Couleur des retenues -> color | array
  carries-color: red,
  /// Présentation des décalages : "g" (défaut) pour 0 en gris, "0" pour des 0 normaux, "p" pour des petits points et "gp" pour des points plus gros, "" ou autre pour rien -> str
  mode: "g",
  /// Afficher les + des additions et le égal du résultat si true, seulement les + si "+", seulement le = si "=", rien si false, sinon donner une list du sign ($+$, $=$) par ex -> boolean | str | array
  sym: true,
  /// Mode fr:true, le séparateur décimal est "," sinon "." -> boolean | str
  fr: true,
  /// Largeur des colonnes -> length | relative length
  size: 1em,
  /// Masquer les lignes intermédiaires et le résultat final pour les exercices -> boolean
  hide-result: false,
  /// list des indices de cases à masquer (pour multiplication à trous) -> array
  list: (),
  /// Afficher ou non la solution dans les masques -> boolean
  solution: false,
  /// Type de masque ("rect" ou "line") -> str
  type-mask: "rect",
  /// Couleur de la bordure des cadres de masque -> color
  border-color: blue.mix(gray),
  /// Couleur du texte de la solution -> color
  solution-color: red,
  /// Espacement si plusieurs sur la même ligne -> length | relative length | fraction
  space: 1fr,
) = {}

/// Ecrit l'égalité d'une division euclidienne. -> content
#let egalite-euclidienne(
  /// dividende -> int | float
  a,
  /// diviseur -> int | float
  b
) = {}

/// Ecrit l'égalité d'une division décimale. -> content
#let egalite-decimale(
  /// dividende -> int | float
  a,
  /// diviseur -> int | float
  b,
  /// signe "e" pour =, sinon approx -> str
  s:"e"
) = {}

/// Division du décimal a par le second b
///
/// avec : `extradigits` chiffres en plus après la virgule que dans a (si cycle:false), ils apparaissent en gris (`mode:`"g" par défaut) ou blanc (mode:"0") ou des points (mode:"p" ou "gp") ou rien (mode:""), `s:`true/false pour avoir ou non les soustractions, 
/// Possibilité de sousligner en couleur (`cycle-color`) le cycle dans le quotient avec `cycle:true` ou de l'avoir entre parenthèses `cycle:""` ou en couleur `cycle:red`
/// Possibilité de présenter des divisions à trous avec `hide-result`, `list` et `solution` (de paramètres `type-mask`, `border-color` et `solution-color`). -> content
#let division(
  /// dividende -> int | float
  a, 
  /// diviseur -> int | float
  b,
  /// Base de numération (2 à 36) -> int
  base: 10,
  /// Montrer ou non dans quelle base l'addition est posée -> boolean
  show-base:false,
  /// Mode pour les zéros ajoutés au dividende : "g" (gris), "0" (noir), "p" (petit point), "gp" (grand point), "" (vide) -> str
  mode: "g",
  /// Nombre de décimales supplémentaires à calculer au quotient -> int
  extradigits: 0,
  /// s: true/false pour afficher ou masquer les soustractions -> boolean
  s: true,
  /// Détection et affichage automatique du cycle périodique -> boolean | str | color
  cycle: false, 
  /// couleur du cycle ou du soulignage -> color
  cycle-color: luma(50%),
  /// Mode fr:true, le séparateur décimal est "," sinon "." -> boolean
  fr:true,
  /// Taille des colonnes du tableau -> length | relative length
  size: .7em,
  /// dx for the ) in mode fr:false -> length | relative length
  dx:.6em,
  /// dy for the ) in mode fr:false -> length | relative length
  dy:-.82em,
  /// Masquer les étapes et le quotient pour le mode exercice -> boolean
  hide-result: false,
  /// list des indices de cases à masquer (exercice à trous : a, b, étapes, quotient) -> array
  list: (),
  /// Afficher ou non la solution dans les masques -> boolean
  solution: false,
  /// Type de masque ("rect" ou "line") -> str
  type-mask: "rect",
  /// Couleur de la bordure des cadres de masque -> color
  border-color: blue.mix(gray),
  /// Couleur du texte de la solution -> color
  solution-color: red,
  /// Espacement si plusieurs sur la même ligne -> length | relative length | fraction
  space:1fr,
) = {}

/// Calcul de la racine carrée de a, avec `extradigits` décimales en plus, en montrant les `groups` de 2 en `groups-color`, avec possibilité d'afficher les étapes avec `step`, de cacher les soustractions avec `s`, de cacher les résultats ou une `list` de chiffres. -> content
#let racine(
  /// nombre -> int | float
  a,
  /// Nombre de tranches de "00" supplémentaires à calculer après la virgule -> int
  extradigits: 0,
  /// Afficher des crochets au-dessus des tranches de 2 chiffres -> boolean
  groups: false,
  /// Couleur des crochets -> color
  groups-color: blue.darken(20%),
  /// Étape de résolution pas à pas -> none | int
  step: none,
  /// couleur de l'étape -> color
  step-color: blue.darken(20%),
  /// Afficher ou masquer les soustractions sous le dividende -> boolean
  s: true,
  /// Mode fr:true, le séparateur décimal est "," sinon "." -> boolean
  fr:true,
  /// Largeur des colonnes -> length | relative length
  size: 0.65em,
  /// Masquer les étapes, les opérations et le résultat (mode exercice) -> boolean
  hide-result: false,
  /// list des indices de cases à masquer (exercice à trous) -> array
  list: (),
  /// Afficher ou non la solution dans les masques -> boolean
  solution: false,
  /// Type de masque ("rect" ou "line") -> str
  type: "rect",
  /// Couleur de la bordure des cadres de masque -> color
  border-color: blue.mix(gray),
  /// Couleur du texte de la solution -> color
  solution-color: red,
  /// espacement à droite -> length | relative length | fraction
  space: 1fr,
  /// autres arguments à la racine, ex: [...] -> arguments
  ..args
) = {}

/// Pour avoir la somme en ligne de tous les nombres saisis. -> content
#let add-en-ligne(
  /// termes de l'addition -> arguments
  ..ops
) = {}

/// Pour avoir la différence en ligne de tous les nombres saisis. -> content
#let sous-en-ligne(
  /// termes de la soustraction -> arguments
  ..ops,
  /// nombre de chiffres de l'arrondi -> auto | int
  digits:auto
) = {}

/// Fait le calcul détaillé de expr-str (sauf si todo:true) avec possibilité d'avoir les calculs indépendants de même priorité fait simultanément avec concomitant, en mode vertical ou horizontal, et mise en avant de l'étape en cours (highlight) avec un mode fraction forcant la poursuite des calculs avec des fractions. -> content
#let etapes-calcul(
  /// l'expression à calculer -> str
  expr-str, 
  /// mode "fr" ou "en" pour le séparateur décimal -> str
  mode: "fr", 
  /// Passer à true pour avoir les calculs indépendants de même priorité fait simultanément -> boolean
  concomitant: false,
  /// Pour avoir une présentation "en colonne" du calcul -> boolean
  vertical: false,
  /// Nombre de décimales dans les calculs avec pi ... -> int
  digits: 2,
  /// Nombre d'étapes (comptées depuis la fin) auquel remplacer le = par un approx si besoin -> int
  n: 0,
  /// Nom à ajouter au début de l'expression -> str | content
  name: "",
  /// Mode énoncé, seul l'expression proposé + un = apparaît -> boolean
  todo: false,
  /// Espacement horizontal entre deux etapes-calcul -> length | relative length | fraction
  space: 1fr,
  /// En mode fraction, le calcul reste exact : soit en mode fraction soit en s'arrêtant à 5pi par ex. -> boolean
  fraction: false,
  /// Soit une couleur qui met en avant les calculs en cours soit false pour du gras ou none pour rien du tout -> color | boolean | none
  highlight: rgb("#1e88e5"),
  /// list des étapes à sauter si nécessaire -> array
  skip: ()
) = {}

/// Fonction pour détailler les calculs manuellement. -> content
#let detail(
  /// Le calcul détaillé -> str
  expr-str,
  /// mode vertical ou non -> boolean
  vertical:false,
  /// Si ajout d'un arrondi à la fin ou non -> boolean
  add-rounded:false,
  /// le nombre de chiffres de l'arrondi -> int
  digits:2,
  /// rang à partir duquel remplacer les = par des ≈ si besoin -> int
  appro:0,
  /// si todo:true, seul l'expression initiale est affichée -> boolean
  todo:false,
  /// l'espace de séparation avant le calcul suivant -> length | relative length | fraction
  space:1fr,
  /// a:aqua peut être changée de la couleur typst par défaut si besoin -> color
  a: aqua,
  /// b: blue peut être changée de la couleur typst par défaut si besoin -> color
  b: blue,
  /// f: fuchsia peut être changée de la couleur typst par défaut si besoin -> color
  f: fuchsia,
  /// g: green peut être changée de la couleur typst par défaut si besoin -> color
  g: green,
  /// r: red peut être changée de la couleur typst par défaut si besoin -> color
  r: red,
  /// l: gray peut être changée de la couleur typst par défaut si besoin -> color
  l: gray,
  /// m: maroon peut être changée de la couleur typst par défaut si besoin -> color
  m: maroon,
  /// n:rgb(8, 111, 189) -> navy peut être changée si besoin -> color
  n: rgb("#086fbd"),
  /// o: orange peut être changée de la couleur typst par défaut si besoin -> color
  o: orange,
  /// t: rgb(0,128,128) -> teal peut être changée si besoin -> color
  t: rgb(0,128,128),
  /// p: purple peut être changée de la couleur typst par défaut si besoin -> color
  p: purple,
  /// y: yellow peut être changée de la couleur typst par défaut si besoin -> color
  y: yellow,
  /// choix du mode "cancel" ou "circle" ou "color" -> str
  c: "color",
) = {}

/// Convertis des durées décimales ou fractionnaires en durées entières -> array
#let prepa-duree(
  /// list de 2 à 4 nombres (j,h,min,s) à (min, s) -> array | arguments
  ..args
) = {}

/// Pose l’addition de deux ou plusieurs durées.
///
/// Chaque durée est un tableau de l'une des formes suivantes :
/// - `(jours, heures, minutes, secondes)`.
/// - `(heures, minutes, secondes)`.
/// - `(minutes, secondes)`. -> content
#let addition-durees(
  /// Afficher les retenues. -> boolean
  show-carry: true,
  /// Couleur des retenues. -> color
  carries-color: red,
  /// Taille des retenues et des symboles + et =, max 1em. -> length | relative length
  carry-size:.8em,
  /// Largeur des colonnes correspondant aux unités. -> length | relative length
  size: 2.5em,
  /// Mode convertion du résultat à la place des retenues. -> boolean
  convertion: false,
  /// Cacher les colonnes n'ayant que des zéros -> boolean
  hide-empty:true,
  /// Masquer le résultat. -> boolean
  hide-result: false,
  /// Couleur du cadre des valeurs masquées. -> color
  border-color: blue.mix(gray),
  /// Couleur des valeurs dans la correction. -> color
  solution-color: red,
  /// Type de masque : "rect" ou "line". -> str
  type-mask: "rect",
  /// Indices des cellules à masquer. -> array
  list: (),
  /// Afficher la solution des cellules masquées. -> boolean
  solution: false,
  /// sign placé devant le résultat. -> boolean | content
  sign: false,
  /// Taille du texte. -> length | relative length
  text-size: 1em,
  /// Afficher les noms des unités. -> boolean
  show-units: true,
  /// Noms des quatre unités. -> array
  units: ([j], [h], [min], [s]),
  /// Taille des unités, max 1em --> length | relative length
  units-size:.75em,
  /// couleur des unités -> color
  units-color:gray,
  /// Afficher heures, minutes et secondes sur deux chiffres. -> boolean
  zero-pad: true,
  /// Aligner les chiffres des unités. -> boolean
  align: true,
  /// Pointillés verticaux pour séparer les colonnes -> boolean
  verticals: false,
  /// liste des durées -> array | arguments
  ..args
) = {}

/// Pose la soustraction de deux durées.
///
/// Chaque durée est un tableau de l’une des formes suivantes :
/// - `(jours, heures, minutes, secondes)` ;
/// - `(heures, minutes, secondes)` ;
/// - `(minutes, secondes)`.
///
/// La première durée doit être supérieure ou égale à la seconde. -> content
#let soustraction-durees(
  /// Afficher les emprunts et les retenues. -> boolean
  show-borrow: true,
  /// Couleur des emprunts et retenues. -> color
  carries-color: red,
  /// Taille des retenues et des symboles + et =, max 1em. -> length | relative length
  carry-size:.7em,
  /// Largeur des colonnes. -> length | relative length
  size: 2.5em,
  /// Mode convertion du minuende à la place des retenues -> boolean
  convertion: false,
  /// Cacher les colonnes n'ayant que des zéros -> boolean
  hide-empty:true,
  /// Masquer le résultat. -> boolean
  hide-result: false,
  /// Couleur du cadre des valeurs masquées. -> color
  border-color: blue.mix(gray),
  /// Couleur des valeurs dans la correction. -> color
  solution-color: red,
  /// Type de masque : "rect" ou "line". -> str
  type-mask: "rect",
  /// Indices des cellules à masquer. -> array
  list: (),
  /// Afficher la solution. -> boolean
  solution: false,
  /// sign placé devant le résultat. -> boolean | content
  sign: false,
  /// Taille du texte. -> length | relative length
  text-size: 1em,
  /// Afficher les noms des unités. -> boolean
  show-units: true,
  /// Noms des quatre unités. -> array
  units: ([j], [h], [min], [s]),
  /// Taille des unités, max 1em. -> length | relative length
  units-size:.75em,
  /// couleur des unités. -> color
  units-color:gray,
  /// Afficher heures, minutes et secondes sur deux chiffres. -> boolean
  zero-pad: true,
  /// Aligner les chiffres des unités. -> boolean
  align:true,
  /// Pointillés verticaux pour séparer les colonnes -> boolean
  verticals: false,
  /// liste des durées -> array | arguments
  ..args
) = {}

/// Affiche la multiplication par jalousie (grille avec diagonales).
/// Cette fonction génère une grille où chaque case est séparée par une diagonale (dizaines en haut à gauche, unités en bas à droite). Les sommes sont effectuées le long des diagonales. -> content
#let grid-multiplication(
  /// Premier facteur (inscrit en haut) -> int | float | decimal | str
  a, 
  /// Second facteur (inscrit à droite) -> int | float | decimal | str
  b,
  /// Taille des cases de la grille. -> length
  cell-size: 1.1cm,
  /// Couleur de la grille -> color
  grid-color: rgb("1f2937"),
  /// Couleur des traits indiquant la position de la virgule -> color
  comma-lines-color: rgb("ef4444"),
  /// Couleur des diagonales -> color
  diag-color: rgb("ef4444"),
  /// Couleur du résultat -> color
  result-color: rgb("059669"),
  /// Couleur de la partie décimal du résultat -> none | color
  decimal-part-color: none,
  /// Couleur des facteurs -> color
  numbers-color: black,
  /// Couleur des produits -> color
  prod-color: luma(80),
    /// Couleur des dizaines des produits -> none | color
  tens-color: none,
  /// Couleur des unités des produits -> none | color
  units-color: none,
  /// Couleur d'affichage de la solution -> color
  solution-color: rgb("2563eb"),
  /// Base de numération (défaut: 10) -> int
  base: 10,
  /// Montrer la base des nombres -> bool
  show-base:false,
  /// Masquage : false (tout afficher), true ou "result" (masquer le résultat), 
  /// "grid" ou "grid-only" ou "all" (grille vide + facteurs uniquement), 
  /// "calculations" (calculs masqués mais résultat affiché) -> bool | str
  hide-result: false,
  /// Style du masque quand une valeur est cachée ("blank", "box", "question", "dots", content ou fonction) -> str | content | function
  type-mask: "blank",
  /// Liste d'éléments cibles ou coordonnées (col, row) spécifiques à masquer -> array | none
  list: none,
  /// Active le mode correction : affiche les valeurs masquées dans solution-color -> bool
  solution: false,
  /// Virgule comme séparateur décimal ou pas -> bool
  fr: true
) = {}

/// Affiche la multiplication éthiopienne sous forme de tableau. 
/// Cette méthode repose sur la décomposition binaire du premier facteur, donc sur des divisions successives par 2 (colonne de gauche) et des multiplications par 2 (colonne de droite). Les lignes où le nombre de gauche est pair (0 dans l'écriture binaire) sont biffées, et on additionne les nombres restants à droite. -> content
#let binary-multiplication(
  /// Premier facteur -> int | float | decimal | str
  a, 
  /// Second facteur -> int | float | decimal | str
  b,
  /// explique la décomposition en produits partiels -> bool
  numbers:false,
  /// Affiche ÷ 2, × 2 pour expliquer les calculs -> bool
  rule:true,
  /// Affiche une dernière ligne avec les sommes -> bool
  sums:false,
  /// Symbole de sommation -> content
  sum-symbol:$sum$,
  /// Barre les lignes des nombres pairs -> bool
  biffer-pairs: true,
  /// Affiche une égalité sous le tableau -> bool
  show-equality: true,
  /// Couleur des lignes avec nombres pairs -> color
  fill-even: rgb("ffebee"),
  /// Couleur des lignes avec nombres impairs -> color
  fill-odd: rgb("e8f5e9"),
  /// Traits du tableau -> stroke
  stroke: 0.5pt + luma(180),
  /// Virgule comme séparateur décimal ou pas -> bool
  fr:true
) = {}

/// Multiplication japonaise (méthode des traits).
/// Représente chaque chiffre par un faisceau de droites parallèles. Les intersections indiquent le nombre d'unités, dizaines et centaines. -> content
#let lines-multiplication(
  /// premier facteur -> int | float | decimal | str
  a, 
  /// second facteur -> int | float | decimal | str
  b,
  /// couleur des traits issus de a -> color
  color-a: rgb("2563eb"),
  /// couleur des traits issus de b -> color
  color-b: rgb("dc2626"),
  /// couleur des traits « zéro » pointillés -> color
  color-zero: gray,
  /// facteur d'échelle du dessin -> int | float
  draw-scale: .8,
  /// affichage de la virgule ou du point comme séparateur décimal -> bool
  fr:true,
  /// couleurs des points d'intersection valant 1, de ceux des unités vers ceux des rangs élevés -> array | color
  points-color: (green, purple, orange, olive, black, red, blue,),
  /// couleur des blocs autour des points d'intersection -> color | none
  color-blocs: none,
  /// coefficient d'échelle des blocs -> float | int
  blocs-scale:0.7,
  /// épaisseur des traits des unités -> length
  lines-thickness: 0.6pt,
  /// épaisseur minimale (chiffres décimaux) -> length
  min-thickness: 0.4pt,
  /// points aux intersections (ex-mode « Baguettes ») -> bool
  points: false,
  /// facteur d'écartement des chiffres -> float
  digits-spread-factor: 1,
  /// facteur d'écartement des lignes pour un chiffre -> float
  lines-spread-factor: 1,
  /// facteur d'écartement horizontal des résultats par zone -> float
  counts-x-spread-factor:1,
  /// facteur d'écartement vertical des résultats par zone -> float
  counts-y-spread-factor:1,
  /// remplace 5 traits par un seul trait de la couleur opposée (chiffres ≥ 5) -> bool
  improved: false,
  /// couleur des traits valant 5 pour le 1er facteur -> color | none
  color-5a:none,
  /// couleur des traits valant 5 pour le 2ème facteur -> color | none
  color-5b:none,
  /// couleur des points d'intersection valant 5 -> color
  color-5: black,
  /// couleur des points d'intersection valant 25 (deux traits condensés croisés) -> color
  color-25: white,
  /// blocs indiquant les rangs, true/false or "rect"/"circ" -> bool | str
  blocs: false,
  /// affiche sous le dessin les sommes, retenues et chiffres -> bool
  counts: true,
  /// affichage du résultat après prise en compte des retenues -> bool
  result: true,
  /// ne trace que le dessin -> bool
  only-drawing: false,
  /// n'affiche que l'explication du calcul -> bool
  only-calculation: false,
  /// affichage de l'égalité obtenue -> bool
  equal: true,
  /// affichage des retenues -> bool
  carries:true,
  /// affichage de la somme -> bool
  sum:true,
  /// mode impression pour avoir les traits de même épaisseur et les traits valant 5 d'épaisseur doublée -> bool
  print: false,
) = {}

/// Visualisation d'une multiplication de décimaux : rectangle de dimensions
/// a × b, case « 1 × 1 » colorée, traits fins tous les dixièmes (si le facteur
/// correspondant est décimal), traits épais toutes les unités, cotations. -> content
#let area-multiplication(
  /// premier facteur -> int | float | str
  a,
  /// second facteur -> int | float | str
  b,
  /// côté d'une unité -> length
  unit: 2cm,
  /// couleur des traits des dixièmes -> color
  tenths-color: orange,
  /// couleur des traits des unités -> color
  ones-color: rgb("006400"),
  /// remplissage de la case « 1×1 » (auto : version claire de ones-color) -> color | auto
  unit-color: auto,
  /// traits des dixièmes suivant a : auto (tracés si a est décimal) | true | false -> bool | auto
  tenths-a: auto,
  /// traits des dixièmes suivant b : auto (tracés si b est décimal) | true | false -> bool | auto
  tenths-b: auto,
  /// affichage de la virgule ou du point comme séparateur décimal -> bool
  fr: true,
  /// épaisseur des traits des dixièmes -> length
  tenths-thickness: 0.5pt,
  /// épaisseur des traits des unités -> length
  units-thickness: 1.2pt,
  show-result:true,
) = {}