// rd-fortes.typ — boîtes de complexité forte : méthode, tâche complexe, designbox, GeoGebra.
//
// Fichier interne de `rd.typ` (qui en ré-exporte les noms). Les clés sont celles de tcolorbox quand la
// boîte les prend en option (voir `reglages.typ`). Tout ce qui commence par « _ » est privé.

#import "rd-outils.typ" as o
#import "reglages.typ": resoudre-rd

/// Applique `coltext` au contenu quand il est donné.
#let _t(r, corps) = if r.coltext == auto or r.coltext == none { corps } else { text(fill: r.coltext, corps) }

// =====================================================================
// methode
// =====================================================================

/// Bloc « méthode » : un onglet sombre à gauche portant le titre, un ruban dégradé
/// du noir au gris qui court en haut, et en bas un filet qui se termine en bosse avec un petit rond blanc.
/// Le texte s'écrit à droite de l'onglet. Pour présenter une technique pas à pas.
///
/// Le titre est « Méthode ». Pour d'autres titres (« Technique », « Astuce »…), utiliser `title:`.
///
/// ```typ
/// #rd.methode[*1.* Repérer l'angle droit. *2.* Identifier l'hypoténuse. *3.* Appliquer la relation de Pythagore.]
/// ```
///
/// - corps (content): contenu de la méthode.
/// - cles (arguments): clés de réglage. `title` (content, [Méthode]) : titre dans l'onglet ; `sep-title` (length, 1em) : espace de
///   part et d'autre du titre dans l'onglet ; `colframe` (color, black) : couleur de base du dégradé ;
///   `coltitle` (white) ; `coltext` ; `tab-height` (length, 0.8cm) : hauteur de l'onglet ; `ribbon-height` (length, 0.1cm) : épaisseur
///   du ruban ; `width` ; `style`.
/// -> content
#let methode(corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("methode", cles)
  let t = text(font: r.police-sans, weight: "bold", fill: r.coltitle, r.title)
  let w = measure(t).width + 2 * r.sep-title.to-absolute()
  let tab = r.tab-height
  let sombre = o.pale(r.colframe, 70)
  let clair = o.pale(r.colframe, 30)
  o.calque(
    _t(r, corps),
    largeur: r.width,
    // boxsep 6 pt ; top 0,5 ex, bottom 1 ex, right 0 : la hauteur suit le texte
    inset: (left: w + 6pt, right: 6pt, top: 0.25em + 6pt, bottom: 0.45em + 6pt + o.jambage),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      // ruban supérieur et onglet
      place(top + left, o.courbe-ronde(
        ((l, 0pt), (0pt, 0pt), (0pt, tab), (w, tab), (w, r.ribbon-height), (l, r.ribbon-height)),
        (0, 0, 4, 4, 0, 0),
        fill: gradient.linear(sombre, clair),
        stroke: none,
      ))
      // filet inférieur en bosse
      place(top + left, curve(
        fill: gradient.linear(clair, sombre),
        curve.move((2cm, h)),
        curve.line((l, h)),
        curve.line((l, h - 4.5mm)),
        curve.cubic((l - 5mm, h - 4.5mm), (l - 1cm + 5mm, h - 0.5mm), (l - 1cm, h - 0.5mm)),
        curve.line((2cm, h - 0.5mm)),
        curve.close(mode: "straight"),
      ))
    },
    dessus: (l, h) => {
      // titre centré 3,5 mm au-dessus du bas de l'onglet
      place(top + left, box(width: w, height: 2 * (tab - 3.5mm), align(center + horizon, t)))
      place(top + left, dx: l - 2pt - 0.375em.to-absolute() * 2, dy: h - 2pt - 0.375em.to-absolute() * 2, circle(radius: 0.375em, fill: white))
    },
  )
})

// =====================================================================
// tache
// =====================================================================

/// Tâche complexe, au format des problèmes ouverts : fond arrondi vert pâle sans cadre, avec ombre
/// floue, titre en gras en haut, et un ruban orange légèrement incliné, accroché au bord gauche, portant
/// l'étiquette (« Défi », « Tâche complexe »…) en blanc ; sous son bout gauche, un pli sombre en demi-disque
/// déborde du fond. Pour une situation-problème ou un problème ouvert.
///
/// Le ruban mesure 1,2 cm ; il s'allonge si l'étiquette n'y tient pas, et le titre se décale d'autant :
/// le ruban ne le recouvre jamais.
///
/// ```typ
/// #rd.tache[Défi][Construire un cerf-volant][À partir de deux diagonales perpendiculaires, construis un cerf-volant.]
/// ```
///
/// - etiquette (content): texte du ruban orange.
/// - titre (content): titre de la tâche.
/// - corps (content): l'énoncé.
/// - cles (arguments): clés de réglage. `colback` (color) : fond vert pâle ; `colframe` (color) : cadre, dessiné seulement avec un
///   `boxrule` positif ; `ruban` (color) : ruban ; `coltitle` (color, white) : texte du ruban ; `coltext` ; `arc` (3mm) ;
///   `boxrule` (0pt : pas de cadre) ; `ombre` (bool, true) ; `width` ; `style`.
/// -> content
#let tache(etiquette, titre, corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("tache", cles)
  // rayon des arrondis du ruban : 0,5 em du corps de texte
  let rr = 0.5em.to-absolute()
  let texte = text(font: r.police-sans, weight: "bold", fill: r.coltitle, top-edge: "cap-height", bottom-edge: "baseline", etiquette)
  let lt = measure(texte).width
  // le ruban mesure 1,2 cm ; il s'allonge seulement si l'étiquette n'y tient pas
  let lg = calc.max(1.2cm, lt + 1.5mm)
  // pente du ruban : 1 mm de montée pour 1,2 cm
  let pente = 1mm / 1.2cm
  let angle = calc.atan(pente)
  o.calque(
    _t(r, corps),
    largeur: r.width,
    inset: (left: 5pt, right: 5pt, top: 1cm + 5pt, bottom: 5pt + o.jambage),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      if r.ombre { o.ombre-floue(l, h, decalage: 1mm, rayon: r.arc) }
      // pas de cadre dessiné par défaut (`boxrule: 0pt`) : seul le fond porte la forme
      let trait = if r.boxrule > 0pt { r.boxrule + r.colframe } else { none }
      place(top + left, rect(width: l, height: h, radius: r.arc, fill: r.colback, stroke: trait))
    },
    dessus: (l, h) => {
      // titre : à 1,34 cm du bord gauche (repoussé si le ruban s'allonge), haut des lettres à 3,3 mm du haut
      place(top + left, dx: calc.max(1.34cm, lg + 1.4mm), dy: 3.7mm, text(font: r.police-sans, weight: "bold", titre))
      // ruban : bas du pli à 1,1 cm du haut du cadre ; bord inférieur du ruban 2 rr plus haut
      let y = 1.1cm
      let yb = y - 2 * rr
      let k = 0.5523
      // quart de cercle de p à q, de centre c (approximation de Bézier)
      let quart(p, q, c) = curve.cubic(
        (p.at(0) + k * (q.at(0) - c.at(0)), p.at(1) + k * (q.at(1) - c.at(1))),
        (q.at(0) + k * (p.at(0) - c.at(0)), q.at(1) + k * (p.at(1) - c.at(1))),
        q,
      )
      // ruban orange : incliné (1 mm de montée sur 1,2 cm), 4 mm de large, bout gauche arrondi qui
      // déborde de rr à gauche du cadre et descend jusqu'au pli
      place(top + left, curve(
        fill: r.ruban,
        curve.move((0pt, yb)),
        curve.line((lg, yb - lg * pente)),
        curve.line((lg, yb - lg * pente - 4mm)),
        curve.line((0pt, yb - 4mm)),
        quart((0pt, yb - 4mm), (-rr, yb - 4mm + rr), (0pt, yb - 4mm + rr)),
        curve.line((-rr, y - rr)),
        quart((-rr, y - rr), (0pt, y), (0pt, y - rr)),
        curve.close(mode: "straight"),
      ))
      // pli : demi-disque gauche, noir à 80 %, posé sur le bout du ruban
      place(top + left, curve(
        fill: o.pale(black, 80),
        curve.move((0pt, y)),
        quart((0pt, y), (-rr, y - rr), (0pt, y - rr)),
        quart((-rr, y - rr), (0pt, yb), (0pt, y - rr)),
        curve.close(mode: "straight"),
      ))
      // étiquette en blanc, posée sur une ligne parallèle au ruban, 0,8 mm au-dessus de son bord inférieur
      place(top + left, dx: 0pt, dy: yb - 0.8mm - measure(texte).height, rotate(-angle, origin: left + bottom, box(texte)))
    },
  )
})

// =====================================================================
// designbox
// =====================================================================

/// Encart « design » sophistiqué, inspiré d'InDesign : cadre arrondi, bandeau de
/// titre sombre à droite dont le bord se creuse en biseau (effet de coin « pelé »), fond dégradé vers le bas,
/// sous-texte facultatif à gauche du titre. Pour l'ouverture d'un chapitre ou un contenu vedette.
///
/// Avec `flat: false`, le bandeau reçoit un dégradé et le titre une ombre portée (`shadow-title`). Le style nommé
/// `designboxstyle` (vide par défaut) est appliqué d'office.
///
/// ```typ
/// #rd.designbox(sous-texte: [Pythagore])[Théorème][Le carré de l'hypoténuse est égal à la somme des carrés des deux autres côtés.]
/// ```
///
/// - titre (content): titre, à droite du bandeau.
/// - corps (content): contenu.
/// - cles (arguments): clés de réglage. `sous-texte` (none, content) : texte à gauche du bandeau ; `color` (auto, color) : fixe
///   `colback` et `colframe` d'un coup ; `colframe`, `colback` (color) : cadre, bandeau et dégradé ;
///   `coltitle` (white) ; `coltext` ; `arc` (2mm) ; `boxrule` (1pt) ; `flat` (bool, true) : bandeau uni ; `shadow-title` (bool, true) :
///   ombre du titre quand `flat: false` ; `sub-align` (alignment, left) ; `sub-color` (color, black) ; `width` ; `style`.
/// -> content
#let designbox(titre, corps, ..cles) = o.tranchable(() => {
  let corps = o.env-corps(corps)
  let r = resoudre-rd("designbox", cles)
  let couleur = if r.color != auto { r.color } else { r.colframe }
  let fond-base = if r.color != auto { r.color } else { r.colback }
  // titre en romain gras (fonttitle=\bfseries)
  let t = text(weight: "bold", fill: r.coltitle, titre)
  let tm = measure(t)
  let arc = r.arc
  // le sous-texte s'écrit dans le creux blanc, sous le liseré sombre du haut (épaisseur arc + 1 pt) :
  // le bandeau est assez haut pour qu'il n'y touche pas
  let hs = if r.sous-texte == none { 0pt } else { measure(text(fill: r.sub-color, r.sous-texte)).height }
  // bandeau : boxsep 2 pt + toptitle 3 pt, au-dessus et au-dessous du titre (avec son étai)
  let bh = calc.max(tm.height + 10pt + (3 * o.etai-titre).to-absolute(), if r.sous-texte == none { 0pt } else { arc + 1pt + hs + 3pt })
  let fond = o.pale(fond-base, 5)
  let ombre-titre = box({
    place(dx: 0.6pt, dy: 0.6pt, text(weight: "bold", fill: couleur.lighten(10%).darken(30%), titre))
    t
  })
  let rangee = grid(
    columns: (1fr, auto),
    rows: (bh - 1pt,),
    column-gutter: 40pt,
    align: (r.sub-align + bottom, right + horizon),
    if r.sous-texte == none { [] } else { box(inset: (bottom: 1pt + 1mm), text(fill: r.sub-color, r.sous-texte)) },
    box(inset: (y: 3pt), if r.flat or not r.shadow-title { t } else { ombre-titre }),
  )
  o.calque(
    {
      // corps : boxsep 2 pt + top 2 mm sous le bandeau ; bottom 2 mm + boxsep 2 pt + cadre 1 pt
      block(width: 100%, height: bh - 1pt, above: 0pt, below: 2pt + 2mm, rangee)
      _t(r, corps)
    },
    largeur: r.width,
    inset: (x: 3pt + 1pt + 2pt, top: 1pt, bottom: 2mm + 2pt + 1pt + o.jambage),
    avant: r.before-skip,
    apres: r.after-skip,
    dessous: (l, h) => {
      let y0 = arc + 1pt
      let x1 = l - tm.width - 35pt
      let x2 = l - tm.width - 17pt
      place(top + left, rect(width: l, height: h, radius: arc, fill: couleur, stroke: r.boxrule + couleur))
      if not r.flat {
        place(top + left, rect(width: l, height: bh + 4pt, fill: gradient.linear(couleur, o.pale(couleur, 40), couleur, angle: 90deg)))
      }
      // intérieur : plein en haut à gauche, creusé en biseau sous le titre
      place(top + left, o.courbe-ronde(
        ((1pt, y0), (x1, y0), (x2, bh), (l - 1pt, bh), (l - 1pt, h - 1pt), (1pt, h - 1pt)),
        (0, 3, 3.5, 0, 2mm.pt(), 2mm.pt()),
        fill: fond,
        stroke: none,
      ))
      // dégradé du bas
      place(top + left, dx: 1pt, dy: h - 1pt - 0.8cm, block(width: l - 2pt, height: 0.8cm, radius: (bottom: arc - 1pt), fill: gradient.linear(
        (fond.transparentize(100%), 0%),
        (o.pale(fond-base, 30).transparentize(50%), 50%),
        (fond-base.transparentize(50%), 100%),
        angle: 90deg,
      )))
      // liseré blanc le long du creux
      place(top + left, curve(
        stroke: (paint: white, thickness: 1.1pt),
        curve.move((1pt, y0)),
        curve.line((x1 - 3pt, y0)),
        curve.quad((x1, y0), (x1 + 3pt, y0 + 3pt)),
        curve.line((x2 - 3pt, bh - 3pt)),
        curve.quad((x2, bh), (x2 + 3.5pt, bh)),
        curve.line((l - 1pt, bh)),
      ))
    },
  )
})

// =====================================================================
// ggbentrainer
// =====================================================================

/// Dessin d'une tablette : cadre gris, écran bleu, bouton.
///
/// ```typ
/// #rd.icone-tablette(hauteur: 1cm)
/// ```
///
/// - hauteur (length): hauteur de la tablette.
/// - couleur (color): couleur de l'écran.
/// -> content
#let icone-tablette(hauteur: 1cm, couleur: o.palette.ggb) = o.tranchable(() => {
  let w = hauteur * 0.62
  box(width: w, height: hauteur, {
    place(top + left, rect(width: w, height: hauteur, fill: luma(215), radius: 0.12 * w))
    place(top + left, dx: 0.1 * w, dy: 0.08 * hauteur, rect(width: 0.8 * w, height: 0.74 * hauteur, fill: couleur))
    place(top + left, dx: w / 2 - 0.06 * w, dy: 0.87 * hauteur, circle(radius: 0.06 * w, fill: white))
    place(center + horizon, dy: -0.05 * hauteur, text(font: o.sans, size: 0.17 * hauteur, fill: white, tracking: 0.05em)[GGB])
  })
})

/// Bloc « S'entraîner en autonomie » : un cadre bleu à angle supérieur gauche vif,
/// un onglet « S'entraîner / en autonomie » en haut à gauche, une tablette dessinée, puis une colonne de
/// droite (10 cm) pour la consigne. Pour un entraînement adossé à une ressource en ligne.
///
/// Les textes utilisent la police sans empattement du paquet (clé globale `police-sans`).
///
/// ```typ
/// #rd.ggbentrainer[Suis le lien pour t'entraîner.][Construire un triangle équilatéral avec GeoGebra.]
/// ```
///
/// - args (content): la partie gauche (texte d'accompagnement), puis la partie droite (consigne) : `[Gauche][Droite]`.
/// - cles (arguments): clés de réglage. `title` (content, [S'entraîner]) : première partie de l'onglet (sur fond plein) ;
///   `sous-titre` (content, [en autonomie]) : seconde partie (en italique) ; `largeur-droite` (length, 10cm) : colonne de droite ;
///   `colframe` (color) : cadre et onglet ; `coltext` ; `arc` (2mm) ; `boxrule` (0.5mm) ; `width` ; `style`.
/// -> content
#let ggbentrainer(..args) = o.tranchable(() => {
  let r = resoudre-rd("ggbentrainer", arguments(..args.named()))
  let (gauche, droite) = o.titre-corps(args, "ggbentrainer")
  let marge = 5pt + 1mm
  let ecart = 5mm
  let t1 = text(font: r.police-sans, weight: "bold", fill: white, r.title)
  let t2 = text(font: r.police-sans, style: "oblique", fill: r.colframe, r.sous-titre)
  block(width: 100%, above: 12pt, below: r.after-skip, layout(s => {
    let L = o.resoudre(r.width, s.width)
    if gauche == none { panic("ggbentrainer : deux contenus attendus, [Gauche][Droite].") }
    let cg = L - r.largeur-droite - ecart - 2 * marge
    let contenu = block(width: L, inset: (x: marge, y: 5pt), breakable: false, grid(
      columns: (cg, r.largeur-droite),
      column-gutter: ecart,
      block(inset: (top: 18pt), text(font: r.police-sans, size: r.taille-notes, _t(r, gauche))),
      align(center + horizon, _t(r, droite)),
    ))
    let H = measure(contenu).height
    block(width: L, height: H, breakable: false, {
      place(top + left, rect(width: L, height: H, radius: (top-left: 0pt, rest: r.arc), stroke: r.boxrule + r.colframe))
      contenu
      context {
        let p1 = box(inset: (x: 5pt, y: 3pt), t1)
        let p2 = box(inset: (x: 5pt, y: 3pt), t2)
        let a = measure(p1)
        let b = measure(p2)
        place(top + left, p1)
        place(top + left, dx: a.width, p2)
        place(top + left, curve(
          stroke: 0.6pt + r.colframe,
          curve.move((0pt, a.height)),
          curve.line((a.width + b.width - 2mm, a.height)),
          curve.quad((a.width + b.width, a.height), (a.width + b.width, a.height - 2mm)),
          curve.line((a.width + b.width, 0pt)),
        ))
        place(top + left, dx: 0pt, dy: 0pt, rect(width: a.width, height: a.height, fill: r.colframe, radius: (top-left: 0pt)))
        place(top + left, dx: 0pt, dy: 0pt, p1)
        place(top + left, dx: marge + cg + ecart / 2 - 1cm * 0.62, dy: 3pt, icone-tablette(hauteur: 1cm, couleur: r.colframe))
      }
    })
  }))
})

// =====================================================================
// ggbqr, ggbqrenv
// =====================================================================

#let _prefixe(genre) = {
  if genre == "file" { "https://ggbm.at/" } else if genre == "classroom" { "https://www.geogebra.org/classroom/" } else {
    panic("ggbqr : `type` doit valoir « file » ou « classroom » ; reçu : " + repr(genre) + ".")
  }
}

#let _place-reservee(etiquette, h, larg, r) = box(
  width: larg,
  height: h,
  stroke: (paint: o.gris, thickness: 0.6pt, dash: "dashed"),
  fill: o.pale(o.gris, 8),
  align(center + horizon, text(font: r.police-sans, size: r.taille-script, fill: o.gris, etiquette)),
)

#let _ggb(url, r, en-ligne) = {
  let adresse = _prefixe(r.type) + url
  let hauteur = r.height
  let c = if r.capture == none { _place-reservee([capture d'écran], hauteur, hauteur * 1.6, r) } else { box(height: hauteur, r.capture) }
  let q = link(adresse, if r.qr == none { _place-reservee([QR code], hauteur, hauteur, r) } else { box(height: hauteur, r.qr) })
  let interieur = if en-ligne { [#c#box(width: 0.5em)#q] } else { grid(columns: (1fr, 1fr), align: center + horizon, c, q) }
  // en ligne, la boîte épouse les images : le bandeau du lien prend leur largeur
  let lien = text(font: r.police-sans, weight: "bold", size: r.taille-notes, adresse)
  let lb = if en-ligne { calc.max(measure(interieur).width, measure(lien).width) + 6pt } else { 100% }
  let bas = box(width: lb, fill: o.pale(r.colframe, 75), inset: (y: 2pt), align(center, text(font: r.police-sans, weight: "bold", size: r.taille-notes, fill: white, link(adresse, text(fill: white, adresse)))))
  let cadre = block(width: if en-ligne { auto } else { r.width }, above: r.before-skip, below: r.after-skip, breakable: false, stroke: 0.5mm + o.pale(r.colframe, 75), radius: 2mm, clip: true, {
    block(width: lb, inset: (x: 3pt, top: 3pt, bottom: 3pt), above: 0pt, below: 0pt, align(center, interieur))
    bas
  })
  if en-ligne { box(cadre) } else { cadre }
}

/// Encart GeoGebra : capture d'écran et QR code vers une ressource. Le titre, en bas,
/// est le lien lui-même. La boîte épouse la taille de son contenu.
///
/// Les images ne sont plus cherchées par nom de fichier (`capture_ggb_<clé>`) : on passe directement le
/// contenu, par exemple `image("capture.png")`. Le QR code de l'adresse sera généré par le paquet de QR
/// code embarqué ; tant qu'il ne l'est pas, une place réservée en pointillés le remplace (ou on passe
/// l'image d'un QR code dans `qr:`). Sans `capture`, une place réservée en pointillés la remplace aussi.
///
/// ```typ
/// #rd.ggbqr("demo123", height: 1.6cm)
/// ```
///
/// - url (str): la fin de l'adresse (l'identifiant de la ressource).
/// - cles (arguments): clés de réglage. `capture` (none, content) : la capture d'écran ; `qr` (none, content) : l'image du QR code ;
///   `height` (length, 2cm) : hauteur des images ; `type` (str) : `"file"` (adresse `https://ggbm.at/…`) ou `"classroom"`
///   (`https://www.geogebra.org/classroom/…`) ; `colframe` (color) : cadre et bandeau du lien ; `style`.
/// -> content
#let ggbqr(url, ..cles) = o.tranchable(() => { _ggb(url, resoudre-rd("ggbqr", cles), true) })

/// Encart GeoGebra pleine largeur : comme `ggbqr`, mais la boîte occupe la largeur
/// disponible, capture et QR code centrés chacun dans une colonne.
///
/// ```typ
/// #rd.ggbqrenv("demo123", height: 1.6cm)
/// ```
///
/// - url (str): la fin de l'adresse.
/// - cles (arguments): mêmes clés que `ggbqr`, plus `width` (length, ratio, 100%).
/// -> content
#let ggbqrenv(url, ..cles) = o.tranchable(() => { _ggb(url, resoudre-rd("ggbqrenv", cles), false) })
