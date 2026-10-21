// rd-moyennes.typ — boîtes de complexité moyenne : cours, exemples, coin plié, papier déchiré,
// à relier, à cocher, aide, items numérotés, titre vertical, opérations, pellicule, Scratch, liens.
//
// Fichier interne de `rd.typ` (qui en ré-exporte les noms). Les clés sont celles de tcolorbox quand la
// boîte les prend en option (voir `reglages.typ`). Tout ce qui commence par « _ » est privé.

#import "rd-outils.typ" as o
#import "reglages.typ": resoudre-rd, resoudre-rd-global

/// Applique `coltext` au contenu quand il est donné.
#let _t(r, corps) = if r.coltext == auto or r.coltext == none { corps } else { text(fill: r.coltext, corps) }

// =====================================================================
// cours
// =====================================================================

/// Bloc de cours haut de gamme : bandeau de titre dégradé du noir au gris, fond gris
/// clair avec un léger voile en biais dans le coin inférieur droit, coins arrondis. Le titre est précédé
/// d'une puce et suivi de « : ».
///
/// ```typ
/// #rd.cours[Définition][Un triangle rectangle est un triangle qui possède un angle droit.]
/// ```
///
/// - titre (content): titre du bloc.
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colframe` (color, black) et `colframe-fin` (color, gris) : début et fin du dégradé du
///   bandeau ; `colback` (color, gris 10 %) : fond du corps ; `coltitle` (white) ; `coltext` ; `arc` (2mm) ; `width` (100%) ;
///   `puce` (content) : puce avant le titre ; `left`, `right` (length) : marges du corps ; `style`.
/// -> content
#let cours(titre, corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("cours", cles)
  block(
    width: r.width,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    radius: r.arc,
    clip: true,
    fill: gradient.linear(r.colframe, r.colframe-fin),
    {
      // titre : cadre 0,5 mm + boxsep 1 mm à gauche (lefttitle 0), 1 mm au-dessus et au-dessous
      block(width: 100%, above: 0pt, below: 0pt, inset: (left: 1.5mm, right: 3pt, y: 1mm + o.etai-titre), text(font: r.police-sans, weight: "bold", fill: r.coltitle)[#r.puce~#titre :])
      pad(x: 0.5mm, bottom: 0.5mm, o.calque(
        _t(r, corps),
        avant: 0pt,
        apres: 0pt,
        // top et bottom 0,5 ex, plus le boxsep de 1 mm
        inset: (left: r.left, right: r.right, top: 0.25em + 1mm, bottom: 0.25em + 1mm + o.jambage),
        dessous: (l, h) => block(width: l, height: h, clip: true, radius: (bottom: r.arc - 0.5mm), fill: r.colback, {
          // voile noir à 25 % d'opacité, effacé vers la gauche (fondu « coursfade » réduit de moitié)
          let voile = gradient.linear(
            (rgb(0, 0, 0, 0%), 0%),
            (rgb(0, 0, 0, 0%), 35%),
            (rgb(0, 0, 0, 4%), 70%),
            (rgb(0, 0, 0, 16%), 100%),
          )
          place(top + left, curve(
            fill: voile,
            curve.move((l, 0pt)),
            curve.line((l, h)),
            curve.line((0pt, h)),
            curve.cubic((l * 0.9, h), (l, h * 0.9), (l, 0pt)),
            curve.close(mode: "straight"),
          ))
        }),
      ))
    },
  )
})

// =====================================================================
// exemple, exemplereduit
// =====================================================================

#let _exemple(corps, r) = {
  let fond-titre = if r.colbacktitle == auto { o.pale(r.colframe, 80) } else { r.colbacktitle }
  // pastille : \footnotesize\bfseries (romain gras), boxsep 1 mm, 7 pt de part et d'autre, étai du titre
  let pastille = box(
    fill: fond-titre,
    radius: 4pt,
    inset: (x: 1mm + 7pt, y: 1mm + 0.12em),
    text(weight: "bold", size: 0.82em, fill: r.coltitle, r.title),
  )
  let hp = measure(pastille).height
  o.calque(
    _t(r, corps),
    largeur: r.width,
    // la pastille est posée au-dessus du corps : `top` se compte sous la pastille
    inset: (left: r.left, right: r.right, top: hp + r.top, bottom: r.bottom + o.jambage),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => if r.colback != none { rect(width: l, height: h, fill: r.colback.transparentize(100% - r.opacityback)) },
    dessus: (l, h) => {
      let t = r.rule-width + r.colframe
      let dx = if r.decale { -2mm } else { 0pt }
      context {
        let m = measure(pastille)
        place(top + left, dx: dx, dy: 0pt, pastille)
        // filet vertical sous la pastille, filet horizontal à sa droite
        place(top + left, dx: dx + 2mm, dy: m.height, line(length: 1cm, angle: 90deg, stroke: t))
        place(top + left, dx: dx + m.width - 1.5pt, dy: m.height / 2, line(length: 1cm, stroke: t))
      }
      // équerre en bas à droite
      place(top + left, curve(
        stroke: t,
        curve.move((l - 1cm, h)),
        curve.line((l, h)),
        curve.line((l, h - 1cm)),
      ))
    },
  )
}

/// Bloc d'exemples à décor en crochet : pastille grise « Exemple(s) » en haut à
/// gauche, filets gris dessinés sous la pastille, à sa droite et en équerre en bas à droite. Pour illustrer
/// une notion dans un cours.
///
/// À ne pas confondre avec `exemple`, l'environnement didactique du paquet farfadet-didactique : celle-ci est la
/// boîte du module `rd` (toujours appelée `rd.exemple`). Le style nommé prédéfini `exemplewithinterior`
/// ajoute un fond blanc translucide.
///
/// ```typ
/// #rd.exemple[Calculons $3 + 4 times 2 = 3 + 8 = 11$ en respectant les priorités.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `title` (content, [Exemple(s)]) : texte de la pastille ; `colframe` (color, gris) : filets ;
///   `colbacktitle` (auto : le cadre à 80 %) : pastille ; `coltitle` (white) ; `colback` (none, color) : fond du bloc ;
///   `opacityback` (ratio, 100%) ; `coltext` ; `rule-width` (length, 1pt) : épaisseur des filets ; `width` ;
///   `left`, `right`, `top`, `bottom` ; `decale` (bool) ; `style` (par exemple `"exemplewithinterior"`).
/// -> content
#let exemple(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _exemple(corps, resoudre-rd("exemple", cles)) })

/// Exemple réduit, pour un encart étroit ou en marge : comme `exemple`, avec
/// une pastille décalée vers l'extérieur. Se règle par `width` (8 cm par défaut).
///
/// ```typ
/// #rd.exemplereduit(width: 8cm)[On factorise : $2x + 4 = 2(x + 2)$.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): mêmes clés que `exemple`.
/// -> content
#let exemplereduit(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _exemple(corps, resoudre-rd("exemplereduit", cles)) })

// =====================================================================
// coinpli, tccoinpli
// =====================================================================

#let _coinpli(corps, r, en-ligne) = {
  let dessous(l, h) = {
    // le coin replié ne dépasse jamais la boîte : au plus 80 % de sa hauteur (un pli de 8 mm sur une note
    // d'une ligne sortait par le haut)
    let pli = calc.min(r.pli.to-absolute(), 0.8 * h)
    place(top + left, polygon(
      fill: r.colback,
      stroke: r.boxrule + r.colframe,
      (0pt, 0pt),
      (l, 0pt),
      (l, h - pli),
      (l - pli, h),
      (0pt, h),
    ))
    place(top + left, polygon(
      fill: gradient.linear(o.pale(r.colback, 20), o.pale(r.colback, 20, autre: black), angle: 45deg),
      stroke: 0.4pt + r.colframe,
      (l - pli, h),
      (l - 0.75 * pli, h - 0.75 * pli),
      (l, h - pli),
    ))
  }
  let c = text(font: r.police-manuscrite, style: "italic", _t(r, corps))
  if en-ligne {
    o.calque-ligne(c, inset: (left: r.left, right: r.right + 1mm, top: r.top, bottom: r.bottom + o.jambage), dessous: dessous, baseline: 0pt)
  } else {
    o.calque(c, largeur: r.width, inset: (left: r.left, right: r.right, top: r.top, bottom: r.bottom + o.jambage), alignement: center + horizon, dessous: dessous, avant: r.before-skip, apres: r.after-skip)
  }
}

/// Note à coin plié : fond gris clair, coin inférieur droit « replié », contenu
/// centré. Pour une astuce, un mémo, un effet post-it.
///
/// Le texte est en Erewhon italique (clé globale `police-manuscrite`).
///
/// ```typ
/// #rd.coinpli[Note repliée dans le coin.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colback` (gris 10 %) ; `colframe` (black) : contour ; `coltext` ; `boxrule` (0.6pt) ;
///   `pli` (length, 4mm) : taille du coin replié ; `width` ; `left`, `right`, `top`, `bottom` ; `style`.
/// -> content
#let coinpli(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _coinpli(corps, resoudre-rd("coinpli", cles), false) })

/// Note à coin plié EN LIGNE : la version de `coinpli` à la taille du contenu.
///
/// ```typ
/// avant #rd.tccoinpli[coin plié] après
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): mêmes clés que `coinpli` (sans `width`).
/// -> content
#let tccoinpli(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _coinpli(corps, resoudre-rd("tccoinpli", cles), true) })

// =====================================================================
// tornpage, parchemin
// =====================================================================

#let _papier(corps, fond, contour, r) = o.calque(
  _t(r, corps),
  largeur: r.width,
  inset: (left: r.left, right: r.right, top: r.top, bottom: r.bottom + o.jambage),
  avant: r.before-skip,
  apres: r.after-skip,
  dessous: (l, h) => {
    let pts = o.rectangle-dechire(l, h, r.pas, r.amplitude, r.graine)
    if r.ombre {
      place(top + left, dx: 2pt, dy: 2pt, polygon(fill: o.gris.transparentize(50%), stroke: none, ..pts))
    }
    place(top + left, polygon(fill: fond, stroke: 0.5pt + contour, ..pts))
  },
)

/// Feuille de papier déchirée : fond papier, contour irrégulier, ombre portée.
/// Pour une note manuscrite, un extrait « arraché », un aparté décoratif.
///
/// Le contour est tracé par un petit générateur pseudo-aléatoire interne et DÉTERMINISTE : la même
/// `graine` donne toujours le même bord, d'une compilation à l'autre. Changer `graine` donne un autre bord.
///
/// ```typ
/// #rd.tornpage[Une feuille au bord déchiré, parfaite pour une citation manuscrite.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colback` (color, gradient) : couleur du papier ; `colframe` (auto, color) : contour,
///   `auto` = le papier à 50 % de noir ; `coltext` ; `width` ; `graine` (int, 1) ; `ombre` (bool, true) ; `pas` (length, 2.2pt) :
///   longueur des segments du bord ; `amplitude` (length, 1pt) : irrégularité du bord ; `left`, `right`, `top`, `bottom` ; `style`.
/// -> content
#let tornpage(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("tornpage", cles)
  let contour = if r.colframe == auto { o.pale(if type(r.colback) == color { r.colback } else { o.palette.papier }, 50, autre: black) } else { r.colframe }
  _papier(corps, r.colback, contour, r)
})

/// Parchemin : papier déchiré à fond dégradé, plus sombre sur les bords, qui
/// tient lieu de texture. Pour une narration, l'histoire des maths, une énigme à thème.
///
/// ```typ
/// #rd.parchemin[Un vieux parchemin pour présenter un énoncé historique.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): mêmes clés que `tornpage` ; par défaut `colback: auto` (dégradé radial du papier) et `graine` 7.
/// -> content
#let parchemin(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("parchemin", cles)
  let p = o.palette.papier
  let fond = if r.colback == auto {
    gradient.radial(o.pale(p, 55), p, o.pale(p, 80, autre: black), center: (50%, 50%), radius: 90%)
  } else { r.colback }
  let contour = if r.colframe == auto { o.pale(p, 50, autre: black) } else { r.colframe }
  _papier(corps, fond, contour, r)
})

// =====================================================================
// À relier : dottedbox, dottedleftbox, dottedrightbox, leftpoint, rightpoint, boxpointlignesrep
// =====================================================================

/// Point d'ancrage d'une liaison : un petit disque noir dont la position sera retrouvée par
/// `boxpointlignesrep`. Les points sont numérotés dans l'ordre d'apparition, côté gauche et côté droit
/// séparément. Le label est porté par un bloc vide placé au coin haut-gauche du disque : sa position est
/// fiable (celle d'une boîte en ligne ne l'est pas : elle décollait les traits des points) ; le centre du
/// disque est à un rayon de là.
#let _ancre(cote, rayon) = {
  o.compteur(cote).step()
  context {
    let n = o.compteur(cote).get().first()
    box(width: 2 * rayon, height: 2 * rayon, baseline: rayon, {
      circle(radius: rayon, fill: black)
      place(top + left, [#block(width: 0pt, height: 0pt)#label("rd-" + cote + "-" + str(n))])
    })
  }
}

/// Point d'ancrage de `leftpoint` / `rightpoint` : centré sur la PREMIÈRE ligne du texte, à une hauteur qui ne
/// dépend que de la ligne courante. Centré sur la hauteur de sa propre cellule, il montait ou descendait avec le
/// contenu voisin (exposant, deux lignes) : les deux points d'une paire n'étaient plus à la même hauteur et le
/// trait rouge partait de travers (sensible sous `modele`, dont les bords de ligne sont fixes).
#let _ancre-ligne(cote, rayon) = context {
  // hauteur d'une ligne courante, diminuée de 0,3 em : le disque tombe entre le centre d'un texte et celui d'une formule
  let h = calc.max(measure([x]).height - 0.3em.to-absolute(), 2 * rayon)
  block(width: 100%, height: h, above: 0pt, below: 0pt, align(center + horizon, _ancre(cote, rayon)))
}

/// Élément de GAUCHE d'une activité « à relier » : fond gris clair, texte aligné
/// à droite, puis une petite case blanche portant le point d'ancrage. À disposer dans une grille à deux
/// colonnes avec `dottedrightbox`.
///
/// ```typ
/// #grid(columns: (1fr, 1fr), column-gutter: 3cm, row-gutter: 3pt,
///   rd.dottedleftbox[Carré], rd.dottedrightbox[4 côtés égaux],
///   rd.dottedleftbox[Triangle], rd.dottedrightbox[3 côtés])
/// ```
///
/// - corps (content): le texte de l'élément.
/// - cles (arguments): clés de réglage. `colback` (color, gris 10 %) : fond de la partie texte ; `coltext` ; `boxsep` (3pt) ;
///   `anchor-width` (length, 1.5em) : largeur de la case du point ; `sidebyside-gap` (length, 6pt) ; `width` ; `style`.
/// -> content
#let dottedleftbox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("dottedleftbox", cles)
  block(width: r.width, above: 0pt, below: 0pt, breakable: false, {
    grid(
      columns: (1fr, r.anchor-width),
      column-gutter: r.sidebyside-gap,
      block(width: 100%, fill: r.colback, inset: (x: r.boxsep, top: r.boxsep + 0.15em, bottom: r.boxsep + o.jambage), align(right, _t(r, corps))),
      align(center + horizon, _ancre("gauche", r.rayon-point)),
    )
  })
})

/// Élément de DROITE d'une activité « à relier » : un point d'ancrage dans une
/// case blanche, puis le texte sur fond gris clair.
///
/// ```typ
/// #rd.dottedrightbox[4 côtés égaux]
/// ```
///
/// - corps (content): le texte de l'élément.
/// - cles (arguments): mêmes clés que `dottedleftbox`.
/// -> content
#let dottedrightbox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("dottedrightbox", cles)
  block(width: r.width, above: 0pt, below: 0pt, breakable: false, {
    grid(
      columns: (r.anchor-width, 1fr),
      column-gutter: r.sidebyside-gap,
      align(center + horizon, _ancre("droite", r.rayon-point)),
      block(width: 100%, fill: r.colback, inset: (x: r.boxsep, top: r.boxsep + 0.15em, bottom: r.boxsep + o.jambage), align(left, _t(r, corps))),
    )
  })
})

/// Boîte de base des éléments à relier : bloc sans cadre à
/// angles vifs, fond uni, numéroté par un compteur automatique (remis à zéro par
/// `rd.reinitialiser-compteur("dottedbox")`). `dottedleftbox` et `dottedrightbox` en sont les spécialisations.
///
/// ```typ
/// #rd.dottedbox[Un élément]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colback` (color) ; `coltext` ; `boxsep` (3pt) ; `width` ; `style`.
/// -> content
#let dottedbox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("dottedbox", cles)
  o.compteur("dottedbox").step()
  block(width: r.width, above: r.before-skip, below: r.after-skip, breakable: false, fill: r.colback, inset: (x: r.boxsep, top: r.boxsep + 0.15em, bottom: r.boxsep + o.jambage), _t(r, corps))
})

/// Élément de GAUCHE d'une activité « à relier » : texte aligné à droite, point
/// d'ancrage dans la marge droite. Variante sans fond des `dottedleftbox`.
///
/// ```typ
/// #rd.leftpoint[$2^3$]
/// ```
///
/// - corps (content): le texte de l'élément.
/// - cles (arguments): clés de réglage. `boxsep` (length, 3pt) : marge verticale ; `anchor-width` (length, 1.5em) ; `width` ; `style`.
/// -> content
#let leftpoint(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("leftpoint", cles)
  block(width: r.width, above: 0pt, below: 0pt, breakable: false, grid(
    columns: (1fr, r.anchor-width),
    inset: (top: r.boxsep + 0.15em, bottom: r.boxsep + o.jambage),
    align: (right + top, center + top),
    corps,
    _ancre-ligne("gauche", r.rayon-point),
  ))
})

/// Élément de DROITE d'une activité « à relier » : point d'ancrage dans la marge
/// gauche, texte aligné à gauche.
///
/// ```typ
/// #rd.rightpoint[$8$]
/// ```
///
/// - corps (content): le texte de l'élément.
/// - cles (arguments): mêmes clés que `leftpoint`.
/// -> content
#let rightpoint(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("rightpoint", cles)
  block(width: r.width, above: 0pt, below: 0pt, breakable: false, grid(
    columns: (r.anchor-width, 1fr),
    inset: (top: r.boxsep + 0.15em, bottom: r.boxsep + o.jambage),
    align: (center + top, left + top),
    _ancre-ligne("droite", r.rayon-point),
    corps,
  ))
})

/// Trace les liaisons d'une activité « à relier » : un segment rouge entre
/// le point de gauche et le point de droite de chaque paire. Les numéros sont ceux d'apparition, en
/// partant de 1, côté gauche et côté droit séparément.
///
/// Par défaut, les traits n'apparaissent QU'EN VERSION PROFESSEUR (correction). Appeler la fonction
/// après les éléments concernés ; elle remet ensuite les deux compteurs à zéro, ce qui permet d'enchaîner
/// plusieurs activités dans un même document.
///
/// ```typ
/// #grid(columns: (1fr, 1fr), column-gutter: 3cm,
///   rd.leftpoint[$2^3$], rd.rightpoint[$8$],
///   rd.leftpoint[$3^2$], rd.rightpoint[$9$])
/// #rd.boxpointlignesrep((1, 1), (2, 2))
/// ```
///
/// - paires (array): les liaisons, chacune `(i, j)` : l'élément i de gauche est relié à l'élément j de droite.
/// - cles (arguments): clés de réglage. `colframe` (color, red) : couleur des traits ; `boxrule` (length, 1pt) : épaisseur ;
///   `visible` (auto, bool) : `auto` = version professeur seulement ; `style`.
/// -> content
#let boxpointlignesrep(..paires) = o.tranchable(() => {
  let r = resoudre-rd("boxpointlignesrep", arguments(..paires.named()))
  let sonde = label("rd-sonde-" + str(counter("rd-sondes").get().first()))
  counter("rd-sondes").step()
  block(
    height: 0pt,
    above: 0pt,
    below: 0pt,
    breakable: false,
    {
      // sonde : un point de hauteur nulle au sommet du bloc, repère commun des coordonnées (même origine
      // que les `place` qui suivent)
      // (sonde placée par `place` : ni retrait de première ligne ni ligne de base ne la décalent ; une sonde en
      // ligne prenait le retrait de paragraphe du document et décollait les traits des points)
      place(top + left, [#block(width: 0pt, height: 0pt)#sonde])
      context {
      let montrer = if r.visible == auto { o.prof() } else { r.visible }
      let q0 = query(sonde)
      if montrer and q0.len() > 0 {
        let ici = q0.first().location().position()
        let pos(nom) = {
          let q = query(selector(label(nom)).before(here()))
          if q.len() == 0 { panic("boxpointlignesrep : point « " + nom + " » introuvable (les éléments à relier doivent précéder l'appel).") }
          let p = q.last().location().position()
          // la position d'une boîte est son coin haut-gauche : le centre du disque est à un rayon de là
          (p.x - ici.x + r.rayon-point, p.y - ici.y + r.rayon-point)
        }
        for paire in paires.pos() {
          let a = pos("rd-gauche-" + str(paire.at(0)))
          let b = pos("rd-droite-" + str(paire.at(1)))
          let dx = (b.at(0) - a.at(0)).pt()
          let dy = (b.at(1) - a.at(1)).pt()
          let d = calc.sqrt(dx * dx + dy * dy)
          let rp = r.rayon-point.pt()
          let u = (dx / d * rp, dy / d * rp)
          place(top + left, line(
            start: (a.at(0) + u.at(0) * 1pt, a.at(1) + u.at(1) * 1pt),
            end: (b.at(0) - u.at(0) * 1pt, b.at(1) - u.at(1) * 1pt),
            stroke: r.boxrule + r.colframe,
          ))
        }
      }
      o.compteur("gauche").update(0)
      o.compteur("droite").update(0)
      }
    },
  )
})

// =====================================================================
// À cocher : casesvf, acocher, listecocher
// =====================================================================

/// Les deux cases « Vrai » et « Faux » empilées. Avec `reponse`, la bonne case est
/// cochée en version professeur.
///
/// ```typ
/// #rd.casesvf(reponse: true)
/// ```
///
/// - cles (arguments): clés de réglage. `reponse` (none, bool) : `true` = « Vrai » est la bonne réponse, `false` = « Faux » ;
///   `couleur-coche` (color, red) : couleur de la coche ; `coche-size` (length, 3.4mm) : taille des cases ; `style`.
/// -> content
#let casesvf(..cles) = o.tranchable(() => {
  let r = resoudre-rd("casesvf", cles)
  let prof = o.prof()
  grid(
    columns: (auto, auto),
    // cases ombrées (\ding{113} en \Large), 3 pt de plus entre les lignes
    column-gutter: 0.9em,
    row-gutter: 0.6em,
    align: (center + horizon, left + horizon),
    o.case-ombree(cochee: prof and r.reponse == true, taille: r.coche-size, couleur-coche: r.couleur-coche),
    [Vrai],
    o.case-ombree(cochee: prof and r.reponse == false, taille: r.coche-size, couleur-coche: r.couleur-coche),
    [Faux],
  )
})

/// Proposition à cocher : mince colonne bleutée à gauche, qui tient lieu de case, texte centré à
/// droite. En version professeur, une proposition `juste` est cochée en rouge (style nommé prédéfini `br`).
///
/// Le contenu s'affiche à droite de la case.
///
/// ```typ
/// #rd.acocher(juste: true)[Cette affirmation est vraie.]
/// #rd.acocher[Cette affirmation est fausse.]
/// ```
///
/// - corps (content): la proposition.
/// - cles (arguments): clés de réglage. `juste` (bool, false) : proposition correcte, cochée en version professeur ;
///   `colback` (auto : bleu de Seyès à 20 %) : fond de la colonne de la case ; `colframe` (color) ; `coltext` ; `arc` (1mm) ;
///   `boxrule` (0.4pt) ; `leftrule` (length, 0.8em + 6pt) : largeur de la colonne ; `couleur-coche` (color, red) ; `width` ; `style`.
/// -> content
#let acocher(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("acocher", cles)
  let fond = if r.colback == auto { o.pale(o.palette.seyes, 20) } else { r.colback }
  o.calque(
    _t(r, corps),
    largeur: r.width,
    // boxsep 2 pt, écart de 8 pt dont la moitié dans la colonne ; texte centré
    inset: (left: r.leftrule + 4pt, right: 2pt, top: 2pt, bottom: 2pt + o.jambage),
    alignement: center + horizon,
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      place(top + left, rect(width: l, height: h, stroke: r.boxrule + r.colframe, radius: r.arc))
      place(top + left, rect(width: r.leftrule, height: h, fill: fond, radius: (left: r.arc)))
    },
    dessus: (l, h) => context {
      // pas de case dessinée : la colonne bleutée en tient lieu ; la coche rouge seule en version professeur
      if r.juste and o.prof() {
        let c = o.coche(taille: 0.95em, couleur: r.couleur-coche)
        let m = measure(c)
        place(top + left, dx: (r.leftrule.to-absolute() - m.width) / 2, dy: (h - m.height) / 2, c)
      }
    },
  )
})

/// Rangée horizontale de cases à cocher : une case et son libellé par élément,
/// en colonnes égales. En version professeur, la ou les bonnes réponses sont cochées en rouge.
///
/// ```typ
/// #rd.listecocher(([12], [15], [18]), br: 2)
/// ```
///
/// - elements (array): les libellés, un par case.
/// - cles (arguments): clés de réglage. `br` (none, int, array) : numéro (à partir de 1) de la bonne réponse, ou liste de
///   numéros ; `column-gap` (length, 4mm) : écart entre les colonnes ; `couleur-coche` (color, red) ; `style`.
/// -> content
#let listecocher(elements, ..cles) = o.tranchable(() => {
  let r = resoudre-rd("listecocher", cles)
  let bonnes = if r.br == none { () } else if type(r.br) == array { r.br } else { (r.br,) }
  let prof = o.prof()
  grid(
    columns: (1fr,) * elements.len(),
    column-gutter: r.column-gap,
    ..elements.enumerate().map(((i, e)) => [#o.case(cochee: prof and (i + 1) in bonnes, couleur-coche: r.couleur-coche)#box(width: 0.4em)#e]),
  )
})

// =====================================================================
// helpblock
// =====================================================================

/// Bloc d'aide, coup de pouce : cadre turquoise, large bande à gauche portant « Aide »
/// en vertical, partie gauche pour une illustration ou un mot-clé, trait pointillé, puis le texte d'aide.
/// Pour différencier ou étayer un exercice difficile.
///
/// Avec UN seul contenu, la boîte n'a pas de partie gauche.
///
/// ```typ
/// #rd.helpblock[Indice][Pense à utiliser la propriété de Pythagore dans le triangle $A B C$.]
/// ```
///
/// - args (content): la partie gauche (facultative), puis le texte : `[Gauche][Texte]` ou `[Texte]`.
/// - cles (arguments): clés de réglage. `colframe` (color) : cadre et bande ; `colback` (auto : le cadre à 5 %) ; `coltitle` (white) ;
///   `coltext` ; `etiquette` (content, [Aide]) : texte de la bande ; `leftrule` (length, 6mm) : largeur de la bande ;
///   `largeur-gauche` (length, 3cm) ; `arc` (1mm) ; `boxrule` (0.5mm) ; `width` ; `style`.
/// -> content
#let helpblock(..args) = o.tranchable(() => {
  let r = resoudre-rd("helpblock", arguments(..args.named()))
  let (gauche, corps) = o.titre-corps(args, "helpblock")
  let marge = r.leftrule + 7pt
  let fond = if r.colback == auto { o.pale(r.colframe, 5) } else { r.colback }
  o.calque(
    _t(r, if gauche == none { corps } else {
      grid(columns: (r.largeur-gauche, 1fr), column-gutter: 14pt, align(center + horizon, gauche), corps)
    }),
    largeur: r.width,
    inset: (left: marge, right: 7pt, top: 7pt, bottom: 7pt + o.jambage),
    alignement: horizon,
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      place(top + left, rect(width: l, height: h, fill: fond, stroke: r.boxrule + r.colframe, radius: r.arc))
      place(top + left, rect(width: r.leftrule, height: h, fill: r.colframe, radius: (left: r.arc)))
    },
    dessus: (l, h) => {
      place(top + left, box(width: r.leftrule, height: h, align(center + horizon, o.vertical(text(font: r.police-sans, weight: "bold", fill: r.coltitle, r.etiquette)))))
      if gauche != none {
        place(top + left, dx: marge + r.largeur-gauche + 7pt, dy: 0.5mm, line(length: h - 1mm, angle: 90deg, stroke: (paint: r.colframe, thickness: 0.5pt, dash: "dotted")))
      }
    },
  )
})

// =====================================================================
// mytcbitembox, mytcbitemize
// =====================================================================

/// Un item numéroté : numéro « n) » à droite d'une colonne étroite, puis le texte sur fond.
#let _item(n, corps, r) = grid(
  columns: (r.lefthand-width, 1fr),
  column-gutter: r.sidebyside-gap,
  block(width: 100%, above: 0pt, below: 0pt, inset: (top: r.boxsep + 0.15em), align(right, [#n)])),
  block(width: 100%, fill: r.colback, inset: (x: r.boxsep, top: r.boxsep + 0.15em, bottom: r.boxsep + o.jambage), above: 0pt, below: 0pt, {
    set par(justify: true)
    _t(r, corps)
  }),
)

/// Items numérotés disposés en grille : chaque item porte son
/// numéro « 1) » à gauche, texte justifié sur fond gris clair à droite. Pour des questions ou exercices
/// numérotés sur plusieurs colonnes.
///
/// ```typ
/// #rd.mytcbitemize[
///   - Calculer $12 times 11$.
///   - Donner le PGCD de $24$ et $36$.
///   - Simplifier $display(18/24)$.
/// ]
/// ```
///
/// La syntaxe environnement donne le même résultat : `#begin(rd.mytcbitemize)` … `#end(rd.mytcbitemize)`.
///
/// - items (content): le corps : un item par `-` (le numéro est automatique).
/// - cles (arguments): clés de réglage. `raster-columns` (int, 1) : nombre de colonnes de la grille ; `depart` (int, 1) :
///   numéro du premier item ; `colback` (gris 10 %) ; `coltext` ; `raster-column-skip` (length, 4mm) ; `raster-row-skip` (2.5mm) ;
///   `lefthand-width` (length, 1.8em) : colonne du numéro ; `boxsep` (5pt) ; `sidebyside-gap` (10pt) ; `width` ; `style`.
/// -> content
#let mytcbitemize(..items) = o.tranchable(() => {
  let r = resoudre-rd("mytcbitemize", arguments(..items.named()))
  block(width: r.width, above: r.before-skip, below: r.after-skip, breakable: false, grid(
    columns: (1fr,) * r.raster-columns,
    column-gutter: r.raster-column-skip,
    row-gutter: r.raster-row-skip,
    ..o.items-corps("mytcbitemize", items.pos()).enumerate().map(((i, it)) => _item(r.depart + i, it, r)),
  ))
})

/// Un item numéroté isolé : numéro automatique à
/// gauche, texte justifié sur fond gris clair. Le compteur est remis à zéro par `rd.reinitialiser-compteur("mytcbitembox")`.
///
/// ```typ
/// #rd.mytcbitembox[Calculer $12 times 11$.]
/// ```
///
/// - corps (content): le contenu.
/// - cles (arguments): clés de réglage. `numero` (auto, int) : `auto` = compteur ; `colback` ; `coltext` ; `lefthand-width` ;
///   `boxsep` ; `sidebyside-gap` ; `style`.
/// -> content
#let mytcbitembox(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("mytcbitembox", cles)
  let n = if r.numero == auto { o.compteur("mytcbitembox").step() + context o.compteur("mytcbitembox").display() } else { r.numero }
  block(width: 100%, above: r.before-skip, below: r.after-skip, breakable: false, _item(n, corps, r))
})

// =====================================================================
// ltitlebox
// =====================================================================

/// Boîte à titre vertical sur le bord gauche : bande sombre portant le titre écrit
/// de bas en haut, contenu à droite sur fond gris. Pour des encarts à étiquette verticale (« DÉFINITION »).
///
/// La bande s'ajuste à la hauteur du titre, et la boîte est au moins aussi haute que le titre est long. `ltitle-width` impose la largeur.
///
/// ```typ
/// #rd.ltitlebox[Titre][Le titre est écrit verticalement dans la bande de gauche.]
/// ```
///
/// - titre (content): titre vertical.
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `ltitle-width` (auto, length) : largeur de la bande, `auto` = s'ajuste au titre ;
///   `colbacktitle` (color) : bande ; `coltitle` (white) ; `colback` : fond du contenu ; `colframe` ; `coltext` ; `arc` (1pt) ;
///   `boxrule` (0.6pt) ; `width` ; `top`, `bottom`, `right` ; `style`.
/// -> content
#let ltitlebox(titre, corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("ltitlebox", cles)
  let t = text(font: r.police-sans, weight: "bold", fill: r.coltitle, titre)
  let m = measure(t)
  let w = if r.ltitle-width == auto { m.height + 6pt } else { r.ltitle-width }
  o.calque(
    _t(r, corps),
    largeur: r.width,
    hauteur: m.width + 6mm,
    inset: (left: w + 10pt, right: r.right, y: r.top),
    alignement: horizon,
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      place(top + left, rect(width: l, height: h, fill: r.colback, stroke: r.boxrule + r.colframe, radius: r.arc))
      place(top + left, rect(width: w, height: h, fill: r.colbacktitle, radius: (left: r.arc)))
    },
    dessus: (l, h) => place(top + left, box(width: w, height: h, align(center + horizon, o.vertical(t)))),
  )
})

// =====================================================================
// opbox
// =====================================================================

/// Boîte pour poser des opérations : les opérations en colonnes centrées, puis une zone
/// grise où l'élève effectue ses calculs. En version professeur, la zone grise montre la `solution`.
///
/// La zone grise est toujours dessinée ; son contenu ne l'est qu'en version professeur.
///
/// ```typ
/// #rd.opbox(
///   ([347 \ + 126], [58 \ $times$ 7]),
///   solution: ([473], [406]),
/// )
/// ```
///
/// - operations (array): les opérations à poser, un contenu par colonne.
/// - cles (arguments): clés de réglage. `solution` (none, array) : le résultat de chaque opération (visible en version
///   professeur) ; `bottom` (length, 1cm) : hauteur de la zone de travail, sous la ligne des résultats ; `opbox-fill-color` (color, gris 10 %) : fond de la
///   zone de travail ; `coltext` ; `width` ; `style`.
/// -> content
#let opbox(operations, ..cles) = o.tranchable(() => {
  let r = resoudre-rd("opbox", cles)
  let n = operations.len()
  block(width: r.width, above: r.before-skip, below: r.after-skip, breakable: false, {
    grid(columns: (1fr,) * n, align: center + top, ..operations.map(c => _t(r, c)))
    // zone grise : la ligne des résultats (cachée en version élève, sa place reste) puis `bottom` (1 cm) de travail
    block(width: 100%, fill: r.opbox-fill-color, above: 0.3em, below: 0pt, inset: (top: 0.3em, bottom: r.bottom), context {
      if r.solution != none {
        let ligne = grid(columns: (1fr,) * n, align: center + top, ..r.solution.map(c => _t(r, c)))
        if o.prof() { ligne } else { hide(ligne) }
      }
    })
  })
})

// =====================================================================
// cinema
// =====================================================================

/// Cadre « pellicule de film » : deux bandes noires perforées de blanc, en haut et en
/// bas, le contenu entre les deux. Pour le storytelling, des séquences d'images, un thème cinéma.
///
/// ```typ
/// #rd.cinema(width: 6cm)[#align(center)[*Séquence vidéo*]]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `colframe` (color, black) : bandes ; `colback` (none, color) : fond du contenu ;
///   `perforation` (color, white) ; `perforation-pitch` (length, 5mm) ; `perforation-width` (2mm) ; `perforation-height` (3mm) ;
///   `band-height` (length, 5mm) ; `coltext` ; `width` ; `style`.
/// -> content
#let cinema(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("cinema", cles)
  let b = r.band-height
  o.calque(
    _t(r, corps),
    largeur: r.width,
    // la source colle le contenu aux bandes (top=0pt) ; 1 mm de marge ici, pour que le texte ne touche pas la bande
    inset: (x: 2mm, y: b + 1mm),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      if r.colback != none { place(top + left, rect(width: l, height: h, fill: r.colback)) }
      place(top + left, rect(width: l, height: b, fill: r.colframe))
      place(bottom + left, rect(width: l, height: b, fill: r.colframe))
      let marge = (b - r.perforation-height) / 2
      // perforations centrées sur la largeur (même marge à gauche et à droite)
      let n = calc.max(1, calc.floor((l - r.perforation-width - 2mm) / r.perforation-pitch) + 1)
      let x0 = (l - (n - 1) * r.perforation-pitch - r.perforation-width) / 2
      for k in range(n) {
        let x = x0 + k * r.perforation-pitch
        if x >= 0pt and x + r.perforation-width <= l {
          place(top + left, dx: x, dy: marge, rect(width: r.perforation-width, height: r.perforation-height, fill: r.perforation))
          place(bottom + left, dx: x, dy: -marge, rect(width: r.perforation-width, height: r.perforation-height, fill: r.perforation))
        }
      }
    },
  )
})

// =====================================================================
// vf, ernum, jourleague, thermobox, progbox, corrdembox
// =====================================================================

/// Item vrai ou faux numéroté : énoncé à gauche, colonne grise à droite avec deux cases
/// « Vrai » et « Faux » (`casesvf`), numéro sur fond noir dans le coin. En version professeur, la bonne
/// case est cochée si `reponse` est donnée. Le compteur est remis à zéro par `rd.reinitialiser-compteur("vf")`.
///
/// ```typ
/// #rd.vf(reponse: true)[Tout carré est un rectangle.]
/// ```
///
/// - corps (content): l'affirmation.
/// - cles (arguments): clés de réglage. `reponse` (none, bool) : la bonne réponse (`true` : vrai ; `false` : faux), cochée en version
///   professeur ; `colframe` (black) ; `colback` (white) ; `colbacklower` (gris 20 %) : colonne des cases ; `colbacktitle` (black) :
///   numéro ; `coltitle` (white) ; `coltext` ; `boxrule` (0.7pt) ; `righthand-width` (length, 2.2cm) : largeur de la colonne des
///   cases ; `height-min` (1.5cm) ; `left` ; `couleur-coche` (red) ; `width` ; `style`.
/// -> content
#let vf(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("vf", cles)
  let cote = r.righthand-width
  o.compteur("vf").step()
  o.calque(
    _t(r, corps),
    largeur: r.width,
    hauteur: r.height-min,
    inset: (left: r.left, right: cote + 7pt + 14pt, y: 7pt),
    alignement: horizon,
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      place(top + left, rect(width: l, height: h, fill: r.colback, stroke: r.boxrule + r.colframe))
      place(top + left, dx: l - cote - 7pt, rect(width: cote + 7pt, height: h, fill: r.colbacklower, stroke: (left: r.boxrule + r.colframe)))
    },
    dessus: (l, h) => context {
      let n = o.compteur("vf").get().first()
      place(top + left, box(fill: r.colbacktitle, inset: (x: 3pt, y: 2pt), text(font: r.police-sans, weight: "bold", size: r.taille-notes, fill: r.coltitle, o.chiffres(n, 2))))
      place(top + left, dx: l - cote - 7pt + 8pt, dy: (h - 2 * 1.2em.to-absolute()) / 2 - 2pt, casesvf(reponse: r.reponse, couleur-coche: r.couleur-coche))
    },
  )
})

/// Badge numéroté à trois chiffres : « 012 » en gras sans empattement. Sert à
/// numéroter des éléments (c'est le numéro de `exemplerealisation`).
///
/// ```typ
/// #rd.ernum(12) (numéro d'exercice)
/// ```
///
/// - n (int): le numéro.
/// -> content
#let ernum(n) = context { text(font: resoudre-rd-global().police-sans, weight: "bold", o.chiffres(n, 3)) }

/// Carte « journée de championnat » : 5 cm sur 1,5 cm, titre centré sur un bandeau
/// gris, puis les lignes équipe, score, score, équipe. Cas d'usage rare : confrontations, classements.
///
/// ```typ
/// #rd.jourleague([Lundi], ([Calcul mental], [3], [2], [Géométrie]))
/// ```
///
/// - titre (content): titre centré.
/// - lignes (array): chaque ligne est un tableau de quatre contenus.
/// - cles (arguments): clés de réglage. `colframe` (black) ; `colbacktitle` (gris 25 %) : bandeau ; `coltitle` (white) ; `coltext` ;
///   `boxrule` (0.6pt) ; `width` (length, 5cm) ; `style`.
/// -> content
#let jourleague(titre, ..lignes) = o.tranchable(() => {
  let r = resoudre-rd("jourleague", arguments(..lignes.named()))
  // carte de 1,5 cm de haut ; titre en romain gras (\bfseries) ; lignes centrées verticalement
  block(
    width: r.width,
    height: 1.5cm,
    above: r.before-skip,
    below: r.after-skip,
    breakable: false,
    stroke: r.boxrule + r.colframe,
    clip: true,
    grid(
      rows: (auto, 1fr),
      block(width: 100%, fill: r.colbacktitle, inset: (y: 1mm + o.etai-titre), above: 0pt, below: 0pt, align(center, text(weight: "bold", fill: r.coltitle, titre))),
      block(width: 100%, height: 100%, inset: (x: 1.5mm), above: 0pt, below: 0pt, align(horizon, text(size: r.taille-script, fill: if r.coltext == auto { black } else { r.coltext }, grid(
        columns: (1fr, auto, auto, 1fr),
        column-gutter: (8pt, 4pt, 8pt),
        align: (right, center, center, left),
        ..lignes.pos().flatten(),
      )))),
    ),
  )
})

/// Thermomètre graphique : tube bleu de 1,5 cm sur 3 cm avec un niveau de liquide.
/// Pour des problèmes de température, des jauges, des niveaux.
///
/// ```typ
/// #rd.thermobox()
/// ```
///
/// - cles (arguments): clés de réglage. `niveau` (ratio, 60%) : hauteur du liquide, de 0 % (vide) à 100 % (plein) ; `width` (length, 1.5cm) ;
///   `height` (length, 3cm) ; `colframe` (color) : contour ; `colback` (color) : fond du tube ; `colliquid` (color) : liquide ;
///   `arc` (3pt) ; `boxrule` (1pt) ; `style`.
/// -> content
#let thermobox(..cles) = o.tranchable(() => {
  let r = resoudre-rd("thermobox", cles)
  let (largeur, hauteur) = (r.width, r.height)
  box(
    width: largeur,
    height: hauteur,
    clip: true,
    radius: r.arc,
    stroke: r.boxrule + r.colframe,
    fill: r.colback,
    {
      let y = hauteur * (1 - r.niveau / 100%)
      place(top + left, curve(
        fill: r.colliquid,
        curve.move((0pt, y)),
        curve.cubic((largeur * 0.35, y - 0.25cm), (largeur * 0.7, y - 0.1cm), (largeur, y + 0.15cm)),
        curve.line((largeur, hauteur)),
        curve.line((0pt, hauteur)),
        curve.close(mode: "straight"),
      ))
    },
  )
})

/// Boîte de programme ou d'algorithme colorée et titrée : cyan, coins arrondis,
/// ombre floue, dégradé intérieur, titre centré en gras. Version plus affirmée de `boiteprog`.
///
/// ```typ
/// #rd.progbox[Programme de calcul][Choisir un nombre, le multiplier par 3, ajouter 5.]
/// ```
///
/// - titre (content): titre centré.
/// - corps (content): le programme.
/// - cles (arguments): clés de réglage. `colframe` (color) : cadre ; `colback` (color) : bas du dégradé intérieur ; `coltext` ;
///   `arc` (3mm) ; `boxrule` (1pt) ; `ombre` (bool, true) ; `width` ; `style`.
/// -> content
#let progbox(titre, corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("progbox", cles)
  o.calque(
    [#align(center, strong(titre))#_t(r, corps)],
    largeur: r.width,
    inset: (x: 3pt + 1pt, top: 3pt, bottom: 3pt + 3pt + o.jambage),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      if r.ombre { o.ombre-floue(l, h, decalage: 1mm, rayon: r.arc) }
      place(top + left, rect(width: l, height: h, radius: r.arc, stroke: r.boxrule + r.colframe, fill: gradient.linear(white, r.colback, angle: 90deg)))
    },
  )
})

/// Correction de démonstration en rouge : texte rouge en gras, titre blanc centré
/// sur un bandeau rouge, fond gris clair. Surcouche « correction » d'une démonstration.
///
/// Par défaut, la boîte n'apparaît QU'EN VERSION PROFESSEUR ; `visible: true` l'impose partout.
///
/// ```typ
/// #rd.corrdembox[Correction][$x = 7$ est la solution de l'équation $x - 2 = 5$.]
/// ```
///
/// - titre (content): titre du bandeau.
/// - corps (content): le texte de la correction.
/// - cles (arguments): clés de réglage. `visible` (auto, bool) : `auto` = version professeur seulement ; `colframe` (color, rouge pur) :
///   bandeau et texte ; `colback` : fond ; `coltitle` (white) ; `coltext` (auto : le cadre) ; `arc` (0.5mm) ; `width` ; `style`.
/// -> content
#let corrdembox(titre, corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("corrdembox", cles)
  let montrer = if r.visible == auto { o.prof() } else { r.visible }
  if montrer {
    let texte = if r.coltext == auto { r.colframe } else { r.coltext }
    // pas de cadre (frame engine=empty) ; titre détaché au-dessus du fond, mêmes marges que le corps
    // (boxed title size=copy : boxsep 1 mm + left/right 4 mm)
    block(width: r.width, above: r.before-skip, below: r.after-skip, breakable: false, {
      align(center, block(above: 0pt, below: 1mm, fill: r.colframe, radius: 1mm, inset: (x: 5mm, y: 1mm + 0.17em), text(weight: "bold", fill: r.coltitle, titre)))
      pad(x: 0.5mm, block(width: 100%, above: 0pt, below: 0pt, fill: r.colback, radius: r.arc, inset: (x: 5mm, top: 3mm, bottom: 3mm + o.jambage), text(weight: "bold", fill: texte, corps)))
    })
  }
})

// =====================================================================
// Scratch : scratchblock, scratchblockenv, scratchfig, scratchfigbox, scratchcapture
// =====================================================================

#let _scratchblock(corps, r, en-ligne) = {
  o.compteur("scratchblock").step()
  let cadre = if r.colframe == auto { r.colbacktitle } else { r.colframe }
  context {
    let n = o.compteur("scratchblock").get().first()
    // titre \small sans empattement ; boxsep 7 pt autour du titre et du corps
    let titre = align(center, text(font: r.police-sans, size: 0.91em, fill: if r.coltitle == auto { black } else { r.coltitle }, [#r.label #n]))
    let tout(l) = {
      block(width: l, fill: r.colbacktitle, inset: (x: 7pt, y: 7pt), above: 0pt, below: 0pt, titre)
      block(width: l, fill: r.colback, inset: (x: 7pt, top: 7pt, bottom: 7pt + o.jambage), above: 0pt, below: 0pt, corps)
    }
    if en-ligne {
      // en ligne, la boîte prend la largeur de son contenu (titre ou corps)
      let l = calc.max(measure(titre).width, measure(corps).width) + 14pt
      box(stroke: r.boxrule + cadre, radius: r.arc, inset: r.boxrule / 2, clip: true, tout(l))
    } else {
      block(width: r.width, above: r.before-skip, below: r.after-skip, breakable: false, stroke: r.boxrule + cadre, radius: r.arc, inset: r.boxrule / 2, clip: true, tout(100%))
    }
  }
}

/// Bloc de programme Scratch numéroté EN LIGNE : bandeau gris « Programme N »,
/// contenu sur fond blanc. Le numéro s'incrémente à chaque bloc ; `rd.resetScratchCounters()` le remet à zéro.
///
/// ```typ
/// #rd.scratchblock[bloc Scratch]
/// ```
///
/// - corps (content): le programme (texte ou figure).
/// - cles (arguments): clés de réglage. `colbacktitle` (color) : bandeau ; `coltitle` (auto, color) : texte du bandeau ;
///   `colframe` (auto : le bandeau) ; `colback` (white) ; `arc` (1mm) ; `boxrule` (2pt) ; `label` (content, [Programme]) ; `style`.
/// -> content
#let scratchblock(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _scratchblock(corps, resoudre-rd("scratchblock", cles), true) })

/// Bloc de programme Scratch numéroté, version BLOC pleine largeur.
///
/// ```typ
/// #rd.scratchblockenv[quand le drapeau vert est cliqué : avancer de 10 pas.]
/// ```
///
/// - corps (content): le programme.
/// - cles (arguments): mêmes clés que `scratchblock`, plus `width` (100%).
/// -> content
#let scratchblockenv(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _scratchblock(corps, resoudre-rd("scratchblockenv", cles), false) })

#let _scratchfig(corps, r, en-ligne) = {
  o.compteur("scratchfig").step()
  let cadre = if r.colframe == auto { r.colbacktitle } else { r.colframe }
  context {
    let n = o.compteur("scratchfig").get().first()
    // titre \small sans empattement (lefttitle 0) ; boxsep 4 pt autour du titre et du corps
    let titre = text(font: r.police-sans, size: 0.91em, fill: if r.coltitle == auto { black.lighten(10%) } else { r.coltitle })[#r.label #n]
    let tout(l) = {
      block(width: l, fill: r.colbacktitle, inset: (x: 4pt, y: 4pt + o.etai-titre / 2), above: 0pt, below: 0pt, titre)
      block(width: l, fill: r.colback, inset: (x: 4pt, top: 4pt, bottom: 4pt + o.jambage), above: 0pt, below: 0pt, align(center + horizon, corps))
    }
    if en-ligne {
      // en ligne, sans largeur imposée, la boîte prend la largeur de son contenu (titre ou corps)
      let l = if r.width == auto { calc.max(measure(titre).width, measure(corps).width) + 8pt } else { 100% }
      box(width: r.width, stroke: r.boxrule + cadre, radius: r.arc, inset: r.boxrule / 2, clip: true, tout(l))
    } else {
      block(width: r.width, above: r.before-skip, below: r.after-skip, breakable: false, stroke: r.boxrule + cadre, radius: r.arc, inset: r.boxrule / 2, clip: true, tout(100%))
    }
  }
}

/// Figure numérotée EN LIGNE : bandeau beige « Figure N », contenu centré. Le
/// compteur est partagé avec `scratchfigbox`.
///
/// ```typ
/// #rd.scratchfig[figure]
/// ```
///
/// - corps (content): la figure.
/// - cles (arguments): clés de réglage. `width` (auto, length) ; `colbacktitle` (color) : bandeau ; `coltitle` (auto, color) ;
///   `colback` : fond ; `colframe` (auto : le bandeau) ; `arc` (1mm) ; `boxrule` (0.4pt) ; `label` (content, [Figure]) ; `style`.
/// -> content
#let scratchfig(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _scratchfig(corps, resoudre-rd("scratchfig", cles), true) })

/// Figure numérotée, version BLOC ; mêmes numéros que `scratchfig`.
///
/// ```typ
/// #rd.scratchfigbox(width: 5cm)[(figure produite par le programme)]
/// ```
///
/// - corps (content): la figure.
/// - cles (arguments): mêmes clés que `scratchfig`.
/// -> content
#let scratchfigbox(corps, ..cles) = o.tranchable(() => { let corps = o.env-corps(corps); _scratchfig(corps, resoudre-rd("scratchfigbox", cles), false) })

/// Capture d'écran numérotée « Image N » : cadre orange, bandeau orange pâle
/// centré, fond blanc. Pour montrer le résultat visuel d'un programme.
///
/// ```typ
/// #rd.scratchcapture[(capture d'écran d'un programme)]
/// ```
///
/// - corps (content): la capture.
/// - cles (arguments): clés de réglage. `height` (auto, length) : hauteur totale de la boîte, bandeau compris ; `colframe` (color) ;
///   `colbacktitle` (auto : le cadre à 10 %) ; `colback` (white) ; `boxrule` (0.4pt) ; `label` (content, [Image]) ; `width` ; `style`.
/// -> content
#let scratchcapture(corps, ..cles) = {
  let corps = o.env-corps(corps)
  o.compteur("scratchcapture").step()
  context {
    let r = resoudre-rd("scratchcapture", cles)
    let n = o.compteur("scratchcapture").get().first()
    let bande = if r.colbacktitle == auto { o.pale(r.colframe, 10) } else { r.colbacktitle }
    // `height` : hauteur totale (bandeau compris) ; boxsep 5 pt ; filet sous le titre ; corps centré
    block(width: r.width, height: r.height, above: r.before-skip, below: r.after-skip, breakable: false, stroke: r.boxrule + r.colframe, radius: r.arc, inset: r.boxrule / 2, fill: r.colback, clip: true, grid(
      rows: (auto, 1fr),
      block(width: 100%, fill: bande, stroke: (bottom: r.boxrule + r.colframe), inset: (y: 5pt + 0.1em), above: 0pt, below: 0pt, align(center, text(font: r.police-sans, size: 0.91em)[#r.label #n])),
      block(width: 100%, height: if r.height == auto { auto } else { 100% }, inset: (x: 5pt, top: 5pt, bottom: 5pt + o.jambage), above: 0pt, below: 0pt, align(center + horizon, corps)),
    ))
  }
}

// =====================================================================
// mylink, partieDNB
// =====================================================================

/// Bouton « Aide en ligne » EN LIGNE : bande orange foncé portant « Aide en ligne » en
/// blanc, puis le texte (souvent un lien) sur fond orange pâle. Pour marquer un renvoi vers une aide.
///
/// ```typ
/// Voir #rd.mylink[cliquer ici] pour une aide.
/// ```
///
/// - corps (content): le texte du bouton.
/// - cles (arguments): clés de réglage. `etiquette` (content, [Aide en ligne]) : texte de la bande ; `colframe` (color) : bande et
///   cadre ; `colback` (color) : fond du texte (appliqué à 20 %) ; `coltext` (color) : couleur du texte ; `arc` (3pt) ;
///   `boxrule` (0.5pt) ; `label-width` (length, 2.7cm) : largeur de la bande ; `style`.
/// -> content
#let mylink(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("mylink", cles)
  box(
    baseline: 25%,
    stroke: r.boxrule + r.colframe,
    radius: r.arc,
    clip: true,
    fill: o.pale(r.colback, 20),
    grid(
      columns: (r.label-width, auto),
      box(fill: r.colframe, inset: (x: 3pt, y: 2pt), width: 100%, text(font: r.police-sans, weight: "bold", size: r.taille-script, fill: white, r.etiquette)),
      box(inset: (x: 3pt, y: 2pt), text(size: r.taille-script, fill: r.coltext, corps)),
    ),
  )
})

/// Label « ■ Partie X » EN LIGNE : badge gris clair en gras avec une légère ombre,
/// pour marquer les parties d'un sujet de brevet.
///
/// ```typ
/// #rd.partieDNB[1] Activités numériques
/// ```
///
/// - corps (content): le numéro ou le nom de la partie.
/// - cles (arguments): clés de réglage. `colback` (color, gris 15 %) : fond du badge ; `label` (content, [Partie ]) : début du
///   texte ; `ombre` (bool, true) ; `style`.
/// -> content
#let partieDNB(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("partieDNB", cles)
  [#o.calque-ligne(
    text(weight: "bold")[#box(width: 0.55em, height: 0.55em, fill: black)#box(width: 0.5em)#r.label#corps],
    inset: (x: 4mm, top: 2mm, bottom: 2mm + o.jambage),
    baseline: 0pt,
    dessous: (l, h) => {
      if r.ombre { o.ombre-floue(l, h, decalage: 1pt, flou: 1pt, opacite: 40%, rayon: 0pt) }
      place(top + left, rect(width: l, height: h, fill: r.colback))
    },
  )#box(width: 1em)]
})

// =====================================================================
// Cadre sans coin (styles « no top left corner » / « no top right corner »)
// =====================================================================

/// Cadre dont un coin n'est pas dessiné :
/// le trait s'interrompt à l'approche du coin, pour y raccorder un onglet, un ruban ou une autre boîte.
///
/// Seul le coin manque : le reste du cadre est dessiné.
///
/// ```typ
/// #rd.sans-coin(coin: top + left, title: [Coin haut-gauche absent])[Le coin supérieur gauche n'est pas dessiné.]
/// ```
///
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `coin` (alignment) : le coin omis, `top + left` ou `top + right` ; `title` (none, content) :
///   titre facultatif ; `colframe` (color) ; `colback` ; `coltext` ; `arc` (2pt) ; `boxrule` (1.2pt) ; `trou` (length, 8pt) : longueur de
///   trait omise de part et d'autre du coin ; `width` ; `style`.
/// -> content
#let sans-coin(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("sans-coin", cles)
  let trou = r.trou
  o.calque(
    [#if r.title != none { text(font: r.police-sans, weight: "bold", fill: r.colframe, r.title); parbreak() }#_t(r, corps)],
    largeur: r.width,
    inset: (x: 5mm, y: 4mm),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      place(top + left, rect(width: l, height: h, fill: r.colback, radius: r.arc))
      let t = r.boxrule + r.colframe
      if r.coin == top + left {
        place(top + left, curve(
          stroke: t,
          curve.move((0pt, trou)),
          curve.line((0pt, h - 3pt)),
          curve.quad((0pt, h), (3pt, h)),
          curve.line((l - 3pt, h)),
          curve.quad((l, h), (l, h - 3pt)),
          curve.line((l, 3pt)),
          curve.quad((l, 0pt), (l - 3pt, 0pt)),
          curve.line((trou, 0pt)),
        ))
      } else {
        place(top + left, curve(
          stroke: t,
          curve.move((l - trou, 0pt)),
          curve.line((3pt, 0pt)),
          curve.quad((0pt, 0pt), (0pt, 3pt)),
          curve.line((0pt, h - 3pt)),
          curve.quad((0pt, h), (3pt, h)),
          curve.line((l - 3pt, h)),
          curve.quad((l, h), (l, h - 3pt)),
          curve.line((l, trou)),
        ))
      }
    },
  )
})
