// rd-simples.typ — boîtes de complexité faible : encadrés, titrés, formules, cases, utilitaires.
//
// Fichier interne de `rd.typ` (qui en ré-exporte les noms). Les clés des boîtes sont celles de
// tcolorbox (`colframe`, `colback`, `arc`…) : voir
// `reglages.typ` pour la liste complète, les défauts et les contrôles. Tout ce qui commence par « _ » est privé.
//
// Chaque boîte résout ses clés dans un `context` (`resoudre-rd`) : clé locale, style nommé, réglage de la
// boîte, réglage global, défaut.

#import "rd-outils.typ" as o
#import "reglages.typ": resoudre-rd

// =====================================================================
// Briques privées
// =====================================================================

/// Applique `coltext` au contenu quand il est donné.
#let _t(r, corps) = if r.coltext == auto or r.coltext == none { corps } else { text(fill: r.coltext, corps) }

/// Marges intérieures de la boîte (left, right, top, bottom) tirées des clés.
#let _marges(r) = (left: r.left, right: r.right, top: r.top, bottom: r.bottom)

/// Boîte à bandeau de titre plein largeur (scratchuse, mydoc, etiquette, schemamainlevee).
#let _titree(titre, corps, r, x-titre: none, hauteur: none) = {
  let bande = if r.colbacktitle == auto { r.colframe } else { r.colbacktitle }
  let fond = if r.colback == auto { o.pale(r.colframe, 10) } else { r.colback }
  // le titre commence où commence le corps (dans tcolorbox, `left` règle aussi `lefttitle`)
  let xt = if x-titre == none { r.left } else { x-titre }
  let bandeau = block(
    width: 100%,
    fill: bande,
    inset: (x: xt, y: r.toptitle + o.etai-titre),
    above: 0pt,
    below: 0pt,
    align(r.halign, text(font: r.police-sans, weight: "bold", size: r.fonttitle-size, fill: r.coltitle, titre)),
  )
  block(
    width: r.width,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    stroke: r.boxrule + r.colframe,
    radius: r.arc,
    // `hauteur` : hauteur TOTALE de la boîte (comme `height` de tcolorbox), bandeau compris
    height: if hauteur == none { auto } else { hauteur },
    clip: true,
    fill: fond,
    {
      bandeau
      block(width: 100%, inset: (left: r.left, right: r.right, top: r.top, bottom: r.bottom + o.jambage), above: 0pt, below: 0pt, {
        set par(justify: r.justify)
        _t(r, corps)
      })
    },
  )
}

/// Boîte de formule ou de rappel : onglet vertical à gauche, fond teinté.
#let _formule(corps, r, en-ligne) = {
  let c = r.colframe
  let fond = if r.colback == auto { o.pale(c, 20) } else { r.colback }
  let onglet = if r.colbacktitle == auto { o.pale(c, 75) } else { r.colbacktitle }
  let dessous(l, h) = rect(width: l, height: h, radius: r.arc, fill: fond, stroke: r.boxrule + c)
  let dessus(l, h) = {
    // l'étiquette garde sa largeur naturelle (sinon la largeur de l'onglet, avant rotation, la coupait
    // en « For-mule ») ; plus longue que l'onglet n'est haut, elle est réduite pour y tenir
    let lab = text(font: r.police-sans, weight: "bold", size: r.fonttitle-size, fill: r.coltitle, hyphenate: false, r.etiquette)
    let m = measure(lab)
    let dispo = calc.max(h - 2pt, 1pt)
    let k = if m.width > dispo { dispo / m.width * 100% } else { 100% }
    box(width: r.tab-width, height: h, radius: (left: r.arc), fill: onglet, {
      place(center + horizon, rotate(-90deg, reflow: true, scale(k, reflow: true, box(width: m.width, lab))))
    })
  }
  // left 4 mm + 3 pt, right, top, bottom 3 pt, boxsep 2 pt (en bloc : jambage en plus, l'exposant monte)
  let marges = if en-ligne { (left: r.tab-width + 5pt, right: 5pt, y: 5pt) } else {
    (left: r.tab-width + 5pt, right: 5pt, top: 5pt + 0.15em, bottom: 5pt + o.jambage)
  }
  if en-ligne {
    // bords « bounds » : la boîte mesure tout le contenu (fraction, indice, jambage) ; avec les bords
    // par défaut (hauteur de capitale, ligne de base), une fraction débordait en haut et en bas du cadre
    // la boîte prend la ligne de base de son contenu : aucun décalage (un `baseline: 3pt` l'abaissait de 3 pt
    // sous la ligne de texte)
    o.calque-ligne(text(fill: r.coltext, top-edge: "bounds", bottom-edge: "bounds", corps), inset: marges, dessous: dessous, dessus: dessus, baseline: 0pt)
  } else {
    o.calque(_t(r, corps), largeur: r.width, inset: marges, dessous: dessous, dessus: dessus, alignement: horizon, avant: r.before-skip, apres: r.after-skip)
  }
}

// =====================================================================
// attention
// =====================================================================

/// Boîte d'alerte : large bande rouge à gauche portant un triangle d'avertissement,
/// fond rose très pâle. Pour avertir d'un piège ou d'un danger.
///
/// L'icône est dessinée en Typst (`rd.icone-alerte`), pas une image. `leftrule` règle la largeur de la bande.
///
/// ```typ
/// #rd.attention[*Attention !* On ne peut pas diviser par zéro.]
/// ```
///
/// - corps (content): le message.
/// - cles (arguments): clés de réglage. `colframe` (color, défaut rouge d'alerte) : cadre et bande ;
///   `colback` (auto, color) : fond, `auto` = le cadre à 5 % ; `coltext` (auto, color) ; `leftrule` (length, 12mm) :
///   largeur de la bande ; `boxrule` (length, 0.5mm) ; `width` (length, ratio, 100%) ; `height-min` (length, 14mm) ;
///   `icone` (bool, true) ; `icone-size` (length, 8mm) ; `icone-fill`, `icone-contour` (color) ; `top`, `right` (length) ;
///   `style` (str, array).
/// -> content
#let attention(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("attention", cles)
  let fond = if r.colback == auto { o.pale(r.colframe, 5) } else { r.colback }
  o.calque(
    _t(r, corps),
    largeur: r.width,
    hauteur: r.height-min,
    inset: (left: r.leftrule + 4mm, right: r.right, y: r.top),
    alignement: horizon,
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      place(top + left, rect(width: l, height: h, fill: fond, stroke: r.boxrule + r.colframe))
      place(top + left, rect(width: r.leftrule, height: h, fill: r.colframe))
    },
    dessus: (l, h) => if r.icone {
      place(top + left, dx: 2pt + r.boxrule, dy: 2pt + r.boxrule, o.icone-alerte(taille: r.icone-size, couleur: r.icone-fill, contour: r.icone-contour))
    },
  )
})

// =====================================================================
// regularcell, regulartcbitemize
// =====================================================================

/// Une cellule de grille bordée : fond blanc, filet noir, contenu centré.
/// La grille complète, avec hauteurs égales, est `regulartcbitemize`.
///
/// ```typ
/// #rd.regularcell(width: 3cm)[$2 times 3 = 6$]
/// ```
///
/// - corps (content): contenu de la cellule.
/// - cles (arguments): clés de réglage. `width` (auto, length, ratio) ; `height` (auto, length) ; `arc` (length, 0pt) :
///   arrondi des coins (coins vifs par défaut) ; `colback` (color, white) ; `colframe` (color, black) ;
///   `boxrule` (length, 0.6pt) ; `coltext` ; `boxsep` (length, 3pt) ; `halign`, `valign` (alignment) ; `style`.
/// -> content
#let regularcell(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("regularcell", cles)
  block(
    width: r.width,
    height: r.height,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    fill: r.colback,
    stroke: r.boxrule + r.colframe,
    radius: r.arc,
    inset: (x: r.boxsep, top: r.boxsep, bottom: r.boxsep + 0.13em),
    align(r.halign + r.valign, _t(r, corps)),
  )
})

/// Grille de cellules bordées, de hauteurs égales par rangée. Le premier
/// argument est le nombre de colonnes (`raster columns`) ; le corps est UN SEUL bloc `[…]`, une cellule par `-`.
///
/// ```typ
/// #rd.regulartcbitemize(3)[
///   - $2 times 3 = 6$
///   - $5 + 7 = 12$
///   - $9 - 4 = 5$
///   - $8 div 2 = 4$
/// ]
/// ```
///
/// La syntaxe environnement donne le même résultat : `#begin(rd.regulartcbitemize, 3)` … `#end(rd.regulartcbitemize)`.
///
/// - colonnes (int): nombre de colonnes.
/// - cellules (content): le corps : une cellule par `-` ; du texte écrit après une cellule lui est rattaché.
/// - cles (arguments): clés de réglage. `raster-column-skip` (length, 2mm) : écart horizontal ;
///   `raster-row-skip` (length, 2mm) : écart vertical ; `arc` (length, 2mm) ; `colback` (white) ; `colframe` (black) ;
///   `boxrule` (0.6pt) ; `coltext` ; `boxsep` (3pt) ; `halign`, `valign` ; `width` (ratio, 100%) ; `style`.
/// -> content
#let regulartcbitemize(colonnes, ..cellules) = o.tranchable(() => {
  let r = resoudre-rd("regulartcbitemize", arguments(..cellules.named()))
  let cs = o.items-corps("regulartcbitemize", cellules.pos())
  block(width: r.width, above: r.before-skip, below: r.after-skip, breakable: false, layout(s => {
    let w = (s.width - (colonnes - 1) * r.raster-column-skip) / colonnes
    // les cellules d'un tcbitemize ont la hauteur d'une ligne de texte complète (étai) : +0,15 em en haut, +0,3 em en bas
    let ins = (x: r.boxsep, top: r.boxsep + 0.15em, bottom: r.boxsep + 0.3em)
    let mesures = cs.map(c => measure(block(width: w, inset: ins, c)).height)
    let lignes = calc.ceil(cs.len() / colonnes)
    let hauteurs = range(lignes).map(k => calc.max(..mesures.slice(k * colonnes, calc.min(cs.len(), (k + 1) * colonnes))))
    grid(
      columns: (w,) * colonnes,
      column-gutter: r.raster-column-skip,
      row-gutter: r.raster-row-skip,
      ..cs.enumerate().map(((i, c)) => block(
        width: w,
        height: hauteurs.at(calc.quo(i, colonnes)),
        breakable: false,
        fill: r.colback,
        stroke: r.boxrule + r.colframe,
        radius: r.arc,
        inset: ins,
        align(r.halign + r.valign, _t(r, c)),
      )),
    )
  }))
})

// =====================================================================
// scratchuse, mydoc, schemamainlevee
// =====================================================================

/// Encadré coloré à bandeau de titre : magenta de Scratch par défaut, fond de la
/// même teinte à 10 %. Pour une consigne ou une explication liée à un usage de Scratch, ou plus
/// généralement un encart coloré titré.
///
/// ```typ
/// #rd.scratchuse[Bloc Scratch utilisé][On déplace le lutin de *10 pas*.]
/// ```
///
/// - titre (content): titre dans le bandeau.
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colframe` (color, magenta de Scratch) ; `colback` (auto, color : le cadre à 10 %) ;
///   `coltitle` (white) ; `colbacktitle` (auto : le cadre) ; `coltext` ; `arc` (1mm) ; `boxrule` (0.4pt) ;
///   `width` (100%) ; `halign` (alignment, left) : alignement du titre ; `fonttitle-size` (1em) ; `toptitle` (2pt) ;
///   `left`, `right`, `top`, `bottom` : marges du corps ; `justify` (bool) ; `style`.
/// -> content
#let scratchuse(titre, corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _titree(titre, corps, resoudre-rd("scratchuse", cles)) })

/// Encadré gris titré, façon « document » : bandeau gris foncé, fond gris clair.
/// Pour un extrait de programme, une fiche, un encart neutre. Le style nommé `mydoc` (vide par défaut) est
/// appliqué d'office.
///
/// ```typ
/// #rd.mydoc[Document de référence][Extrait du programme officiel.]
/// ```
///
/// - titre (content): titre dans le bandeau.
/// - corps (content): contenu.
/// - cles (arguments): mêmes clés que `scratchuse` ; par défaut `colframe` gris foncé et `colback` gris clair.
/// -> content
#let mydoc(titre, corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _titree(titre, corps, resoudre-rd("mydoc", cles)) })

/// Zone « Schéma à main levée » : invite l'élève à tracer un croquis. Le style
/// nommé `schemamainleveetyle` (vide par défaut) est appliqué d'office.
///
/// ```typ
/// #rd.schemamainlevee(height: 2cm)[Dessine un triangle approximatif.]
/// ```
///
/// - corps (content): consigne.
/// - titre (content): titre du bandeau.
/// - cles (arguments): mêmes clés que `scratchuse` ; `height` (auto, length) : hauteur totale de la boîte, bandeau compris ;
///   par défaut bandeau et corps plus compacts.
/// -> content
#let schemamainlevee(corps, titre: [Schéma à main levée], ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("schemamainlevee", cles)
  // titre décalé de 1ex de plus que le corps (lefttitle=1ex)
  _titree(titre, corps, r, x-titre: r.left + 0.45em, hauteur: if r.height == auto { none } else { r.height })
})

// =====================================================================
// encadreOB, encadre, encadregrille
// =====================================================================

/// Encadré « flottant » sans cadre mais avec une ombre floue : fond gris clair.
/// Pour une note secondaire ou un aparté qui doit se détacher de la page. Le style nommé `encadreOB`
/// (vide par défaut) est appliqué d'office.
///
/// ```typ
/// #rd.encadreOB[Un encadré simple avec une ombre douce.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colback` (color, gris 10 %) ; `coltext` ; `width` (100%) ; `boxsep` (length, 3pt) ;
///   `ombre` (bool, true) ; `ombre-decalage` (4pt) ; `ombre-flou` (1.4pt) ; `ombre-opacite` (ratio, 35%) ;
///   `ombre-couleur` (color, black) ; `style`.
/// -> content
#let encadreOB(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("encadreOB", cles)
  o.calque(
    _t(r, corps),
    largeur: r.width,
    inset: (x: r.boxsep, top: r.boxsep, bottom: r.boxsep + o.jambage),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      if r.ombre {
        o.ombre-floue(l, h, decalage: r.ombre-decalage, flou: r.ombre-flou, couleur: r.ombre-couleur, opacite: r.ombre-opacite, rayon: 0pt)
      }
      rect(width: l, height: h, fill: r.colback)
    },
  )
})

/// Encadré gris générique, la boîte la plus neutre du lot : fond gris clair, cadre fin.
///
/// ```typ
/// #rd.encadre[Résultat : $x = 5$.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colback` (gris 10 %) ; `colframe` (gris) ; `coltext` ; `arc` (1mm) ;
///   `boxrule` (0.4pt) ; `boxsep` (7pt) ; `width` (100%) ; `style`.
/// -> content
#let encadre(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("encadre", cles)
  block(
    width: r.width,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    fill: r.colback,
    stroke: r.boxrule + r.colframe,
    radius: r.arc,
    inset: (x: r.boxsep, top: r.boxsep, bottom: r.boxsep + o.jambage),
    _t(r, corps),
  )
})

/// Encadré à fond quadrillé pointillé, au pas de 7,5 mm : espace de calcul,
/// zone pour tracer une figure à main levée, réponse de l'élève sur quadrillage.
///
/// ```typ
/// #rd.encadregrille(height: 2.5cm)[]
/// ```
///
/// - corps (content): contenu (souvent vide).
/// - cles (arguments): clés de réglage. `height` (auto, length) : hauteur minimale ; `pas` (length, 7.5mm) : pas du
///   quadrillage ; `couleur-grille`, `epaisseur-grille` (0.4pt), `style-grille` ("densely-dashed") : traits du quadrillage ;
///   `colback` ; `colframe` ; `coltext` ; `arc` (1mm) ; `boxrule` ; `boxsep` (5pt) ; `width` ; `style`.
/// -> content
#let encadregrille(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("encadregrille", cles)
  o.calque(
    _t(r, corps),
    largeur: r.width,
    hauteur: r.height,
    inset: r.boxsep,
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => block(width: l, height: h, clip: true, radius: r.arc, fill: r.colback, stroke: r.boxrule + r.colframe, {
      let trait = (paint: r.couleur-grille, thickness: r.epaisseur-grille, dash: r.style-grille)
      for k in range(1, calc.ceil(l / r.pas)) { place(top + left, dx: k * r.pas, line(length: h, angle: 90deg, stroke: trait)) }
      for k in range(1, calc.ceil(h / r.pas)) { place(top + left, dy: h - k * r.pas, line(length: l, stroke: trait)) }
    }),
  )
})

// =====================================================================
// entete
// =====================================================================

/// Bannière dégradée : filets haut et bas dégradés du noir au blanc, fond dégradé gris.
/// Pour un titre de page ou un bandeau d'ouverture de section. Le texte est en gras et en grand, dans la
/// police de titre du paquet (clé globale `police-titre`).
///
/// ```typ
/// #rd.entete[Chapitre 3 — Le théorème de Pythagore]
/// ```
///
/// - corps (content): le titre.
/// - cles (arguments): clés de réglage. `colframe` (color, black) : couleur de départ des filets (à gauche), qui s'éclaircit
///   vers la droite ; `colback` (auto, color) : `auto` = dégradé du cadre à 10 % vers le blanc ; `coltext` ; `width` ;
///   `rule-width` (length, 1.5pt) : épaisseur des filets ; `left`, `right`, `top`, `bottom` ; `style`.
/// -> content
#let entete(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("entete", cles)
  o.calque(
    // \Large en gras (Antykwa Toruńska grasse étroite dans la source ; police de titre du paquet ici)
    text(font: r.police-titre, weight: "bold", size: 1.31em, _t(r, corps)),
    largeur: r.width,
    inset: _marges(r),
    alignement: horizon,
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      // gray!20 (le gris de xcolor est déjà à 50 %) : le cadre à 10 %, vers le blanc
      rect(width: l, height: h, fill: if r.colback == auto { gradient.linear(o.pale(r.colframe, 10), white) } else { r.colback })
      let g = gradient.linear(r.colframe, white)
      place(top + left, line(length: l, stroke: (paint: g, thickness: r.rule-width)))
      place(bottom + left, line(length: l, stroke: (paint: g, thickness: r.rule-width)))
    },
  )
})

// =====================================================================
// zone, ficheno
// =====================================================================

/// Zone thématique à titre en ruban : cadre arrondi bleu, titre blanc dans un bandeau
/// plein, contenu centré. Pour « À retenir », un objectif de séance, un encart thématique.
///
/// ```typ
/// #rd.zone[Objectif de la séance][Savoir reconnaître un triangle rectangle.]
/// ```
///
/// - titre (content): titre dans le bandeau.
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colframe` (color) : cadre et bandeau ; `colback` (none, color) : fond ;
///   `coltitle` (white) ; `colbacktitle` (auto : le cadre) ; `coltext` ; `arc` (5pt) ; `boxrule` (1pt) ; `width` (100%) ;
///   `halign` (alignment, center) : alignement du contenu ; `toptitle` (0pt) : marge au-dessus du titre (1 mm de plus dessous) ; `left`, `right`, `top`, `bottom` ; `style`.
/// -> content
#let zone(titre, corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("zone", cles)
  let bande = if r.colbacktitle == auto { r.colframe } else { r.colbacktitle }
  block(
    width: r.width,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    stroke: r.boxrule + r.colframe,
    radius: r.arc,
    fill: r.colback,
    clip: true,
    {
      // titre précédé de 1 em, 1 mm sous le titre (bottomtitle)
      block(width: 100%, fill: bande, inset: (left: 1em, right: 1em, top: r.toptitle + o.etai-titre, bottom: r.toptitle + 1mm + o.etai-titre), above: 0pt, below: 0pt, text(font: r.police-sans, weight: "bold", fill: r.coltitle, titre))
      block(width: 100%, inset: (left: r.left, right: r.right, top: r.top, bottom: r.bottom + o.jambage), above: 0pt, below: 0pt, align(r.halign, _t(r, corps)))
    },
  )
})

/// Fiche numérotée : boîte de 7 cm, bandeau « Fiche n° X ».
///
/// Toutes les clés de tcolorbox (`colframe`, `coltext`…) sont prises en compte. Le numéro peut être automatique (compteur qui s'incrémente à chaque fiche) ou imposé.
///
/// ```typ
/// #rd.ficheno[Cette fiche regroupe les exercices d'application directe.]
/// #rd.ficheno(numero: 7, colframe: rgb("#2a9d8f"))[Fiche de révision.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `numero` (auto, int, str, content) : `auto` = compteur ; `etiquette` (content) : texte
///   du bandeau avant le numéro ; `colframe` (color) : cadre (le bandeau est cette couleur à 75 %) ; `coltext` ; `coltitle` ;
///   `colback` ; `arc` (2mm) ; `boxrule` (0.5mm) ; `width` (7cm) ; `halign` (center) ; `toptitle` (2.2pt) ; `fonttitle-size` ;
///   `style`.
/// -> content
#let ficheno(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("ficheno", cles)
  let n = if r.numero == auto { o.compteur("ficheno").step() + context o.compteur("ficheno").display() } else { r.numero }
  let c = o.pale(r.colframe, 75)
  block(
    width: r.width,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    stroke: r.boxrule + c,
    radius: r.arc,
    fill: r.colback,
    clip: true,
    {
      block(width: 100%, fill: c, inset: (left: 5mm, y: r.toptitle + 0.15em), above: 0pt, below: 0pt, text(weight: "bold", size: r.fonttitle-size, fill: r.coltitle)[#r.etiquette#n])
      // boxsep 2 pt + left/right 4 mm, top/bottom 2 mm
      block(width: 100%, inset: (x: 2pt + 4mm, top: 2pt + 2mm, bottom: 2pt + 2mm + o.jambage), above: 0pt, below: 0pt, align(r.halign + horizon, _t(r, corps)))
    },
  )
})

// =====================================================================
// exemplerealisation
// =====================================================================

/// Exemple de réalisation numéroté : bandeau bleu portant un badge « 001 »
/// et le titre, corps en deux colonnes (texte à gauche, figure ou réponse à droite).
///
/// Le titre peut renvoyer à une cible du document (`cible: <fiche-med>`) : il devient alors un lien
/// cliquable. Le titre est blanc sur le bandeau.
///
/// ```typ
/// #rd.exemplerealisation(lateral: [Schéma])[Tracer une médiatrice][On trace un arc de cercle de chaque côté.]
/// ```
///
/// - args (content): le titre (facultatif), puis le corps : `[Titre][Corps]` ou `[Corps]`.
/// - cles (arguments): clés de réglage. `cible` (none, label) : cible du lien du titre ; `lateral` (none, content) : colonne de
///   droite ; `largeur-lateral` (length, 3cm) ; `numero` (auto, int) ; `colframe` (color) ; `colback` ; `coltitle` ;
///   `colbacktitle` (auto : le cadre) ; `coltext` ; `arc` (3mm) ; `boxrule` (0.4pt) ; `width` ; `style`.
/// -> content
#let exemplerealisation(..args) = o.tranchable(() => {
  let r = resoudre-rd("exemplerealisation", arguments(..args.named()))
  let (titre, corps) = o.titre-corps(args, "exemplerealisation")
  let n = if r.numero == auto { context o.chiffres(o.compteur("exemplerealisation").get().first(), 3) } else { o.chiffres(r.numero, 3) }
  let t = if titre == none { none } else if r.cible == none { titre } else { link(r.cible, titre) }
  let bande = if r.colbacktitle == auto { r.colframe } else { r.colbacktitle }
  block(
    width: r.width,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    stroke: r.boxrule + r.colframe,
    radius: (top: r.arc),
    fill: r.colback,
    clip: true,
    {
      if r.numero == auto { o.compteur("exemplerealisation").step() }
      // le numéro est un nœud TikZ (marge de 1/3 em tout autour), suivi de 1 cm ; boxsep 2 pt, left 4 pt
      block(width: 100%, fill: bande, inset: (x: 2pt + 4pt + 0.33em, y: 2pt + 0.33em), above: 0pt, below: 0pt, text(font: r.police-sans, weight: "bold", fill: r.coltitle, grid(
        columns: (auto, 1fr),
        column-gutter: 1cm + 0.33em,
        n,
        if t == none { [] } else { text(fill: r.coltitle, t) },
      )))
      // boxsep 2 pt + left/right/top/bottom 4 pt, 2 pt, 2 pt
      block(width: 100%, inset: (x: 6pt, top: 4pt, bottom: 4pt + o.jambage), above: 0pt, below: 0pt, _t(r, if r.lateral == none { corps } else {
        grid(columns: (1fr, r.largeur-lateral), column-gutter: 12pt, corps, align(horizon + center, r.lateral))
      }))
    },
  )
})

// =====================================================================
// domino
// =====================================================================

/// Domino à deux moitiés égales : trait de séparation central, ombre floue, contenu
/// centré. Pour des jeux d'association (question et réponse, mot et traduction) et des cartes à découper.
///
/// ```typ
/// #rd.domino[$7 times 8$][$56$]
/// ```
///
/// - gauche (content): moitié de gauche.
/// - droite (content): moitié de droite.
/// - cles (arguments): clés de réglage. `colframe` (color, black) : cadre et trait central ; `colback` (white) ; `coltext` ;
///   `arc` (1mm) ; `boxrule` (0.8pt) ; `boxsep` (5pt) ; `width` ; `ombre` (bool, true) ; `style`.
/// -> content
#let domino(gauche, droite, ..cles) = o.tranchable(() => {
  let r = resoudre-rd("domino", cles)
  o.calque(
    grid(columns: (1fr, 1fr), align: center + horizon, _t(r, gauche), _t(r, droite)),
    largeur: r.width,
    inset: (x: r.boxsep, top: r.boxsep, bottom: r.boxsep + o.jambage),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      if r.ombre { o.ombre-floue(l, h, decalage: 1mm) }
      rect(width: l, height: h, fill: r.colback, stroke: r.boxrule + r.colframe, radius: r.arc)
    },
    dessus: (l, h) => place(top + left, dx: l / 2, line(length: h, angle: 90deg, stroke: r.boxrule + r.colframe)),
  )
})

// =====================================================================
// formula, myformule, rappelbox
// =====================================================================

/// Formule mise en avant, avec onglet vertical « Formule » : fond teinté, bande
/// sombre à gauche. Version bloc ; `myformule` est la version en ligne.
///
/// ```typ
/// #rd.formula[$a^2 + b^2 = c^2$]
/// ```
///
/// - corps (content): la formule.
/// - cles (arguments): clés de réglage. `colframe` (color, black) : cadre (le fond est cette couleur à 20 %, l'onglet à 75 %) ;
///   `colback`, `colbacktitle` (auto, color) ; `coltitle` (white) ; `coltext` ; `etiquette` (content) : texte de l'onglet ;
///   `tab-width` (length, 4mm) ; `boxrule` (0.4pt) ; `arc` (1pt) ; `fonttitle-size` ; `width` ; `style`.
/// -> content
#let formula(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _formule(corps, resoudre-rd("formula", cles), false) })

/// Formule mise en avant, EN LIGNE : même aspect que `formula`, à la taille du
/// contenu, dans le fil du texte.
///
/// ```typ
/// On retient #rd.myformule[$E = m c^2$] pour la suite.
/// ```
///
/// - corps (content): la formule.
/// - cles (arguments): mêmes clés que `formula` (sans `width`).
/// -> content
#let myformule(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _formule(corps, resoudre-rd("myformule", cles), true) })

/// Rappel en ligne : comme `myformule`, avec l'onglet « Rappel ». Pour rappeler
/// une propriété déjà vue.
///
/// ```typ
/// #rd.rappelbox[un rappel]
/// ```
///
/// - corps (content): le texte rappelé.
/// - cles (arguments): mêmes clés que `formula` (sans `width`).
/// -> content
#let rappelbox(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _formule(corps, resoudre-rd("rappelbox", cles), true) })

// =====================================================================
// miniexemple, exem
// =====================================================================

/// Petit encart à coins en crochets : fond gris, deux crochets dessinés au milieu
/// des bords (en haut à gauche et en bas à droite), contenu centré. Pour un mini-exemple ou une citation.
///
/// ```typ
/// #rd.miniexemple[$2/3 + 1/6 = 5/6$]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colframe` (color, gris) : crochets ; `colback` ; `coltext` ; `boxrule` (length, 1pt) :
///   épaisseur des crochets ; `width` ; `left`, `right`, `top`, `bottom` ; `style`.
/// -> content
#let miniexemple(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("miniexemple", cles)
  o.calque(
    _t(r, corps),
    largeur: r.width,
    // top/bottom 3 mm, plus le filet de 1 pt réservé (frame engine=empty)
    inset: (left: r.left, right: r.right, top: r.top + 1pt, bottom: r.bottom + 1pt + o.jambage),
    alignement: center + horizon,
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => rect(width: l, height: h, fill: r.colback),
    dessus: (l, h) => {
      let t = r.boxrule
      place(top + left, curve(
        stroke: (paint: r.colframe, thickness: t, join: "miter"),
        curve.move((t / 2, h / 2)),
        curve.line((t / 2, t / 2)),
        curve.line((l / 2, t / 2)),
      ))
      place(top + left, curve(
        stroke: (paint: r.colframe, thickness: t, join: "miter"),
        curve.move((l - t / 2, h / 2)),
        curve.line((l - t / 2, h - t / 2)),
        curve.line((l / 2, h - t / 2)),
      ))
    },
  )
})

/// Exemple compact : petit titre italique « ▸ Exemple » au-dessus d'une boîte grise à
/// angles vifs. Plus discret que `exemple`, pour un exemple court dans le fil du cours.
///
/// ```typ
/// #rd.exem[$(-3)^2 = 9$ tandis que $-3^2 = -9$.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `title` (content, [Exemple]) ; `colframe` (color) : cadre et titre ; `colback` ; `coltext` ;
///   `boxrule` (0.6pt) ; `width` ; `left`, `right`, `top`, `bottom` ; `style`.
/// -> content
#let exem(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("exem", cles)
  block(
    width: r.width,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    {
      // titre posé sur le cadre : left 6 pt (lefttitle), triangle relevé de la moitié de la hauteur du titre
      pad(left: 6pt, top: 2.2mm, bottom: 1.4mm, text(size: 0.91em, fill: r.colframe, style: "italic", {
        box(baseline: -0.5pt, polygon(fill: r.colframe, (0pt, 0pt), (3pt, 2pt), (0pt, 4pt)))
        box(width: 0.6em)
        r.title
      }))
      block(width: 100%, above: 0pt, below: 0pt, fill: r.colback, stroke: r.boxrule + r.colframe, inset: (left: r.left, right: r.right, top: r.top, bottom: r.bottom + o.jambage), _t(r, corps))
    },
  )
})

// =====================================================================
// boiteprog, casio
// =====================================================================

/// Listing de programme ou pseudo-code sobre : fond gris très clair, filet noir
/// de 2 pt à gauche, texte sans empattement réduit.
///
/// ```typ
/// #rd.boiteprog[Tant que le reste est non nul, on continue les divisions successives.]
/// ```
///
/// - corps (content): le code ou l'algorithme.
/// - cles (arguments): clés de réglage. `colframe` (color, black) : filet de gauche ; `colback` ; `coltext` ; `leftrule` (length, 2pt) :
///   épaisseur du filet ; `fonttitle-size` (1em → 0.9em) : taille du texte ; `width` ; `style`.
/// -> content
#let boiteprog(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("boiteprog", cles)
  block(
    width: r.width,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    fill: r.colback,
    stroke: (left: r.leftrule + r.colframe),
    // left=0pt, boxsep=0pt : le texte suit immédiatement le filet ; top et bottom 0,5 ex
    inset: (left: 1pt + r.leftrule / 2, right: 0pt, top: 0.2em, bottom: 0.2em + o.jambage),
    text(font: r.police-sans, size: r.fonttitle-size, _t(r, corps)),
  )
})

/// Mode d'emploi de calculatrice : fond vert pâle, cadre vert, large bande à gauche
/// portant « Calculatrice » en vertical.
///
/// La boîte est au moins aussi haute que son étiquette : le mot ne déborde jamais, même pour un contenu
/// d'une ligne.
///
/// ```typ
/// #rd.casio[Menu RUN-MAT, puis taper `2 + 3 EXE` affiche `5`.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colframe` (color, vert-de-gris) : cadre et bande ; `colback` (color, vert à 25 % ; `auto` :
///   le cadre à 25 %) ; `coltitle` (color, vert à 50 % ; `auto` : le cadre à 50 %) ; `coltext` ; `etiquette` (content) : texte de la bande ; `leftrule` (length, 2em) : largeur de la bande ;
///   `boxrule` (0.5mm) ; `width` ; `style`.
/// -> content
#let casio(corps, ..cles) = {
  let corps = o.env-corps(corps)
  context {
    let r = resoudre-rd("casio", cles)
    let t = text(font: r.police-sans, weight: "bold", size: r.taille-notes, if r.coltitle == auto { o.pale(r.colframe, 50) } else { r.coltitle }, r.etiquette)
    let long = measure(t).width + 6mm
    let fond = if r.colback == auto { o.pale(r.colframe, 25) } else { r.colback }
    o.calque(
      _t(r, corps),
      largeur: r.width,
      hauteur: long,
      inset: (left: r.leftrule + 4pt, right: 4pt, y: 4pt),
      alignement: horizon,
      avant: r.before-skip,
      apres: r.after-skip,
      dessous: (l, h) => {
        place(top + left, rect(width: l, height: h, fill: fond, stroke: r.boxrule + r.colframe))
        place(top + left, rect(width: r.leftrule, height: h, fill: r.colframe))
      },
      dessus: (l, h) => place(top + left, box(width: r.leftrule, height: h, align(center + horizon, o.vertical(t)))),
    )
  }
}

// =====================================================================
// Boîtes de mise en page et boîtes en ligne simples
// =====================================================================

/// Boîte invisible qui centre son contenu horizontalement et verticalement.
/// Sert à aligner des cellules dans une grille ou à neutraliser des marges.
///
/// ```typ
/// #rd.alignbox(width: 4cm, height: 1.2cm)[Centré]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `width` (auto, length, ratio) ; `height` (auto, length) ; `halign`, `valign` (alignment,
///   center et horizon) ; `boxsep` (length, 0pt) : marge intérieure ; `style`.
/// -> content
#let alignbox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("alignbox", cles)
  block(
    width: r.width,
    height: r.height,
    above: 0pt,
    below: 0pt,
    breakable: false,
    inset: r.boxsep,
    align(r.halign + r.valign, corps),
  )
})

/// Comme `alignbox`, mais avec l'espace vertical habituel autour de la boîte
/// (les sauts avant et après sont conservés).
///
/// ```typ
/// #rd.centragebox(width: 5cm)[Contenu centré dans sa boîte.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage : `width`, `height`, `halign`, `valign`, `style` (voir `alignbox`) et les espaces
///   `before-skip`, `after-skip`.
/// -> content
#let centragebox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("centragebox", cles)
  block(
    width: r.width,
    height: r.height,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    align(r.halign + r.valign, corps),
  )
})

/// Version EN LIGNE de `alignbox` : une boîte sans cadre qui centre son contenu.
///
/// ```typ
/// avant #rd.tcalignbox(width: 2cm)[aligné] après
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage : `width`, `height`, `halign`, `valign`, `style`.
/// -> content
#let tcalignbox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("tcalignbox", cles)
  box(width: r.width, height: r.height, align(r.halign + r.valign, corps))
})

/// Boîte vide en ligne : même chose que `tcalignbox`, sans cadre ni fond.
///
/// ```typ
/// avant #rd.blankbox[vide stylé] après
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage : `width`, `height`, `halign`, `valign`, `style`.
/// -> content
#let blankbox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("blankbox", cles)
  box(width: r.width, height: r.height, align(r.halign + r.valign, corps))
})

/// Conteneur de figure avec titre : sans cadre, titre en haut à gauche, contenu centré.
///
/// ```typ
/// #rd.figbox(title: [Figure 1], width: 5cm, height: 2cm)[Aire d'un disque]
/// ```
///
/// - corps (content): la figure.
/// - cles (arguments): clés de réglage. `title` (none, content) : titre en haut à gauche ; `width`, `height` ; `halign`, `valign` :
///   alignement de la figure ; `style`.
/// -> content
#let figbox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("figbox", cles)
  block(
    width: r.width,
    height: r.height,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    {
      if r.title != none { align(left, r.title) }
      align(r.halign + r.valign, corps)
    },
  )
})

/// Étiquette ou carte de largeur fixe : cadre noir arrondi, titre blanc
/// sur un bandeau noir, fond gris clair. Pour des cartes de vocabulaire ou des étiquettes à découper.
///
/// ```typ
/// #rd.etiquette[Vocabulaire][Hypoténuse : le plus grand côté d'un triangle rectangle.]
/// ```
///
/// - titre (content): titre du bandeau.
/// - corps (content): contenu.
/// - cles (arguments): mêmes clés que `scratchuse` ; par défaut `width` 5.5cm, cadre noir de 0.5mm, titre à gauche
///   (`halign: center` pour le centrer), texte justifié.
/// -> content
#let etiquette(titre, corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _titree(titre, corps, resoudre-rd("etiquette", cles)) })

/// Boîte blanche semi-transparente EN LIGNE : fond blanc à 70 %, coins arrondis,
/// sans cadre. Pour poser du texte lisible par-dessus une image ou une figure.
///
/// ```typ
/// #rd.tcwhite[boîte blanche]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colback` (color, white) ; `opacityback` (ratio, 70%) : opacité du fond ; `arc` (2mm) ;
///   `boxsep` (3pt) ; `style`.
/// -> content
#let tcwhite(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("tcwhite", cles)
  box(fill: r.colback.transparentize(100% - r.opacityback), radius: r.arc, inset: (x: r.boxsep, y: r.boxsep), outset: (y: 2pt), corps)
})

/// Encadré gris EN LIGNE : un mot ou une courte expression dans un cadre arrondi
/// gris clair.
///
/// ```typ
/// Le mot #rd.tcencadre[encadré] est entouré.
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colback` ; `colframe` ; `arc` (1mm) ; `boxrule` (0.4pt) ; `left`, `right`, `top`, `bottom` ;
///   `style`.
/// -> content
#let tcencadre(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("tcencadre", cles)
  box(
    fill: r.colback,
    stroke: r.boxrule + r.colframe,
    radius: r.arc,
    // boxsep 7 pt tout autour (comme la version bloc `encadre`)
    inset: (left: r.left, right: r.right, top: r.top, bottom: r.bottom + o.jambage),
    corps,
  )
})
