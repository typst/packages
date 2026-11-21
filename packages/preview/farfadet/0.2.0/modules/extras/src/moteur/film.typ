// film.typ (moteur de farfadet-extras) — pellicule de film.
//
// MOTEUR : noms exportés par ../../interne.typ (STABLES). Les paramètres sont DÉJÀ RÉSOLUS (couleurs
// Typst, longueurs absolues) : la résolution des réglages se fait dans la façade (../film.typ).
// Cotes (corps 10 pt) :
//   - cadre noir de 3,2 cm ; 9 perforations de 1,8 × 2,8 mm, réparties par `\hfill` (donc centrées dans
//     9 cellules égales) ; marge de 1 mm au-dessus de la bande haute et sous la bande basse ;
//   - image de 3 cm, à 3,83 pt sous la bande haute (1 mm + 1 pt d interligne), 4,02 pt au-dessus
//     de la bande basse.

/// Rangée de perforations : `couleurs` (une par perforation) réparties sur la largeur disponible.
///
/// - couleurs (array): couleur de chaque perforation, de gauche à droite.
/// - largeur (length): largeur d'une perforation.
/// - hauteur (length): hauteur d'une perforation.
/// -> content
#let bf-film-perforations(couleurs, largeur, hauteur) = grid(
  columns: (1fr,) * couleurs.len(),
  rows: hauteur,
  align: center,
  ..couleurs.map(c => rect(width: largeur, height: hauteur, fill: c, stroke: none, inset: 0pt)),
)

/// Couleurs de la bande haute : une perforation colorée (`coloree`) sur deux en partant de la première,
/// les autres blanches (`blanche`) : « \ColoredSmallBox\whitebox\ColoredSmallBox… ».
#let bf-film-couleurs-haut(n, coloree, blanche, alterner: true) = range(n).map(i => {
  if alterner and calc.even(i) { coloree } else { blanche }
})

/// Cadre de film : fond plein, bande haute, contenu, bande basse.
///
/// - haut (content): bande de perforations du haut.
/// - milieu (content): contenu (image, texte, boîte).
/// - bas (content): bande de perforations du bas.
/// - largeur (length): largeur du cadre.
/// - fond (color): couleur du cadre.
/// - marge (length): marge au-dessus de la bande haute et sous la bande basse.
/// - ecart-haut (length): distance bande haute → contenu.
/// - ecart-bas (length): distance contenu → bande basse.
/// - texte (color, auto): couleur du texte du contenu (`auto` : inchangée).
/// -> content
#let bf-film-cadre(haut, milieu, bas, largeur, fond, marge, ecart-haut, ecart-bas, texte: auto) = box(
  width: largeur,
  fill: fond,
  inset: 0pt,
  {
    set text(fill: texte) if texte != auto
    stack(
      dir: ttb,
      spacing: 0pt,
      v(marge),
      haut,
      v(ecart-haut),
      align(center, milieu),
      v(ecart-bas),
      bas,
      v(marge),
    )
  },
)

/// Dimensions naturelles d'un contenu (image…), à appeler dans un `context`.
#let _naturel(contenu) = measure(contenu)

/// Contenu mis à la largeur `largeur` en gardant ses proportions (`\includegraphics[width=…]`).
///
/// - contenu (content): une image (`image("a.png")`) ou tout autre contenu.
/// - largeur (length): largeur voulue.
/// -> content
#let bf-film-image-largeur(contenu, largeur) = context {
  let n = _naturel(contenu)
  let k = largeur / n.width
  box(width: largeur, height: n.height * k, place(top + left, scale(x: k * 100%, y: k * 100%, origin: top + left, reflow: false, contenu)))
}

/// `\ClipImage{largeur}{hauteur}{image}` : l'image est mise à l'échelle pour couvrir `largeur × hauteur`,
/// puis rognée à droite ou en bas (le coin haut gauche est conservé).
///
/// - largeur (length): largeur de la zone.
/// - hauteur (length): hauteur de la zone.
/// - contenu (content): l'image.
/// -> content
#let bf-film-clip(largeur, hauteur, contenu) = context {
  let n = _naturel(contenu)
  let k = calc.max(largeur / n.width, hauteur / n.height)
  box(
    width: largeur,
    height: hauteur,
    clip: true,
    place(top + left, scale(x: k * 100%, y: k * 100%, origin: top + left, reflow: false, contenu)),
  )
}

/// Boîte bicolore de `\filmt` (tcolorbox `bicolor`) : partie haute `colback`, partie basse `colbacklower`
/// qui occupe le reste de la hauteur, cadre `colframe` de `boxrule`, coins arrondis de `arc`.
///
/// - haut (content): contenu de la partie haute.
/// - bas (content): contenu de la partie basse.
/// - r (dictionary): `hauteur`, `colback`, `colbacklower`, `colframe`, `boxrule`, `arc`, `gauche`, `droite`,
///   `dessus`, `dessous` (paddings déjà additionnés de `boxsep`).
/// -> content
#let bf-film-boite-bicolore(haut, bas, r) = block(
  width: 100%,
  height: r.hauteur,
  fill: r.colframe,
  radius: r.arc,
  inset: r.boxrule,
  clip: true,
  breakable: false,
  block(
    width: 100%,
    height: 100%,
    radius: calc.max(r.arc - r.boxrule, 0pt),
    clip: true,
    grid(
      columns: 1fr,
      rows: (auto, 1fr),
      grid.cell(fill: r.colback, inset: (left: r.gauche, right: r.droite, top: r.dessus, bottom: r.dessous), align(left, haut)),
      grid.cell(fill: r.colbacklower, inset: (left: r.gauche, right: r.droite, top: r.dessus, bottom: r.dessous), align(left, bas)),
    ),
  ),
)
