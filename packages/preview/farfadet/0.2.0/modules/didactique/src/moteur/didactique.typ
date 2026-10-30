// didactique.typ — environnements didactiques de bfcours (Définition, Propriété, Exemple…).
//
// Source qui fait foi : new-bfcours-environments.sty (version de production chargée par bfcours.sty).
// Toutes les cotes sont en pt Typst (= bp) et viennent de relevés PyMuPDF sur le PDF LaTeX de référence.
//
// Principes :
// - chaque environnement pose ses couleurs (\CouleurTexteAccent → bf-couleur, \couleurItem →
//   bf-couleur-item) au début de son corps et rend les valeurs précédentes à la fin (groupe TeX) ;
// - chaque environnement « titré » dépose une entrée de sommaire : metadata(…) <bf-toc> ;
// - espacement vertical : un espace FAIBLE avant (block.above) et un espace FORT après (v()),
//   pour reproduire l'addition \after skip + \before skip de tcolorbox (les \write du sommaire
//   empêchent \addvspace de fusionner les deux espaces).

// Couleurs courantes, largeur courante, `bf-vide`, `bf-brut` : farfadet-socle (cycles C1 et C6).
#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
// Tracés « à la craie » (Démonstration) : copie locale de chalks, voir vendor/chalks/PROVENANCE.md.
#import "../../vendor/chalks/lib.typ" as chalks
#import "../../vendor/chalks/src/engine.typ": chalks-decimation

// =====================================================================
// Outils
// =====================================================================

#let _sequence = [a *b*].func()
#let _espace = [ ].func()
/// Blancs (séparateur de mots), compilé une fois : `regex(…)` dans une fonction recompile à chaque appel.
#let _blancs = regex("\s+")

// `bf-vide` : farfadet-socle (contenu.typ).

/// Le contenu se termine-t-il par une équation centrée ? (LaTeX ajoute alors une ligne vide :
/// les macros de remise à zéro des couleurs rouvrent le paragraphe après \].)
#let _finit-par-equation(c) = {
  if type(c) != content { return false }
  if c.func() == math.equation { return c.block }
  if c.func() == _sequence {
    for x in c.children.rev() {
      if x.func() in (_espace, parbreak, metadata) { continue }
      if repr(x.func()) in ("update", "state-update", "counter-update", "step") { continue }
      return _finit-par-equation(x)
    }
    return false
  }
  if c.has("child") { return _finit-par-equation(c.child) }
  false
}

/// Texte brut approximatif d'un contenu : `bf-brut` du socle (contenu.typ).
#let _brut = bf-brut

/// Profondeur naturelle (TeX) de la dernière ligne d'un corps : 2,72 pt si des jambages
/// (g, j, p, q, y, ponctuation, parenthèses, formules) figurent dans ce qui est sans doute
/// la dernière ligne, 0,2 pt sinon. TeX mesure la boîte réelle, Typst des lignes de hauteur fixe.
#let _profondeur(corps) = {
  let t = _brut(corps).trim().split("¶").filter(p => p.trim() != "")
  if t.len() == 0 { return 2.72pt }
  let fin = t.last().trim()
  if fin.clusters().len() > 70 { fin = fin.clusters().slice(-45).join() }
  let jambages = "gjpqyQçµ,;()[]{}/|@"
  if fin.clusters().any(ch => jambages.contains(ch)) { 2.72pt } else { 0.2pt }
}

/// Couleur : nom bfcours/xcolor (« prop », « red!50!black ») ou valeur Typst.
#let _c(x) = if type(x) == str { xcolor(x) } else { x }

/// Couleurs d'un environnement (groupe TeX) : applique `reglage` (\bfdSetColors… de tableaux.typ)
/// puis `accent` / `item`, et compose `corps` avec ces valeurs de bf-couleur (\currentAccentColor),
/// bf-couleur-item (\itemBaseColor) et bf-couleurs-tableaux. Les valeurs sont portées par la chaîne de
/// styles pour `corps` seulement (`bf-porter`) : connues dès le premier tour de mise en page, et rien à
/// rétablir après l'environnement.
#let bf-avec-couleurs(reglage: none, accent: none, item: none, corps) = context {
  let v = bf-couleurs-reglage(reglage, (
    "bf-couleur": bf-lire(bf-couleur-p),
    "bf-couleur-item": bf-lire(bf-couleur-item-p),
    "bf-couleurs-tableaux": bf-lire(bf-couleurs-tableaux-p),
  ))
  if accent != none { v.insert("bf-couleur", accent) }
  if item != none { v.insert("bf-couleur-item", item) }
  // Bords de ligne de TeX (ceux que fixe `bfcours-texte` : 0,75 em au-dessus, 0,25 em au-dessous, à
  // l'échelle Erewhon / Utopia). Les marges basses des environnements (`_profondeur(corps) - 2.75pt`)
  // supposent ces bords : sans eux (document sans le modèle bfcours), le texte de la dernière ligne
  // mordait sur le filet bas de la boîte (guide p. 23, « Bilan »). Sous `bfcours`, règle sans effet.
  set text(top-edge: 0.75em / 1.065, bottom-edge: -0.25em / 1.065)
  // \linewidth intérieur pour les boîtes de points (\tcbitempoint) de listes.typ
  bf-porter(v, bf-avec-largeur(corps))
}

/// Entrée de sommaire façon \bfdLiencontentRegister : « **nom** - sous-titre ».
/// `simple: true` : entrée non graissée sans tiret (\liensubsection de Recette).
#let bf-entree-sommaire(nom, titre, simple: false) = [#metadata((nom: nom, titre: titre, simple: simple))<bf-toc>]

/// Texte d'une banderole : icône facultative, nom, numéro facultatif (« Propriété 2.3 »).
/// Le libellé du sommaire reste `nom` seul (le numéro y serait évalué hors de son contexte).
#let bf-nom-banniere(nom, numero, icone) = {
  if numero == none and icone == none { return nom }
  [#if icone != none [#icone#h(0.35em)]#nom#if numero != none [ #numero]]
}

#let _vecteur(a, b) = {
  let dx = (b.at(0) - a.at(0)) / 1pt
  let dy = (b.at(1) - a.at(1)) / 1pt
  let n = calc.sqrt(dx * dx + dy * dy)
  if n == 0 { (0, 0) } else { (dx / n, dy / n) }
}

/// Polygone à coins arrondis façon TikZ `rounded corners` (un rayon par sommet, 0pt = angle vif).
#let bf-polygone(points, rayons: none, ferme: true, ..style) = {
  if rayons == none {
    // angles vifs partout (cadre déchiré) : les mêmes éléments que la boucle ci-dessous, sans elle
    let morceaux = (curve.move(points.first()),) + points.slice(1).map(curve.line)
    return curve(..style, ..morceaux, ..if ferme { (curve.close(),) } else { () })
  }
  let n = points.len()
  let morceaux = ()
  for i in range(n) {
    let p = points.at(i)
    let r = if rayons == none { 0pt } else { rayons.at(i) }
    let bout = not ferme and (i == 0 or i == n - 1)
    if r == 0pt or bout {
      morceaux.push(if i == 0 { curve.move(p) } else { curve.line(p) })
    } else {
      let u = _vecteur(p, points.at(calc.rem(i - 1 + n, n)))
      let v = _vecteur(p, points.at(calc.rem(i + 1, n)))
      let a = (p.at(0) + r * u.at(0), p.at(1) + r * u.at(1))
      let b = (p.at(0) + r * v.at(0), p.at(1) + r * v.at(1))
      morceaux.push(if i == 0 { curve.move(a) } else { curve.line(a) })
      morceaux.push(curve.quad(p, b))
    }
  }
  if ferme { morceaux.push(curve.close()) }
  curve(..style, ..morceaux)
}

/// Demi-disque supérieur (y vers le bas) sous forme de sous-chemin de curve().
#let _demi-disque(cx, cy, r) = {
  let k = 0.5523
  (
    curve.move((cx + r, cy)),
    curve.cubic((cx + r, cy - k * r), (cx + k * r, cy - r), (cx, cy - r)),
    curve.cubic((cx - k * r, cy - r), (cx - r, cy - k * r), (cx - r, cy)),
    curve.close(),
  )
}

/// Générateur pseudo-aléatoire déterministe : n valeurs dans [-1 ; 1].
#let _aleas(graine, n) = {
  let x = calc.rem(graine * 7919 + 104729, 2147483647)
  let r = ()
  for _ in range(n) {
    x = calc.rem(x * 48271, 2147483647)
    r.push(2 * x / 2147483647 - 1)
  }
  r
}

/// Rectangle « random steps » (décoration TikZ) : sommets tous les `pas`, décalés d'au plus `ampl`.
/// Le décalage suit le générateur de `_aleas` (deux tirages par sommet, x puis y), tiré dans la même
/// boucle que la pose des sommets : mêmes nombres au bit près que `_aleas` + `enumerate().map(…)`, mais
/// sans fermeture ni appel `.at` (un appel de fermeture coûte plus qu'un tour de boucle) : 1,5 → 0,5 ms par
/// rectangle.
#let _rectangle-dechire(l, h, pas, ampl, graine) = {
  let points = ()
  let cotes = (((0pt, 0pt), (l, 0pt)), ((l, 0pt), (l, h)), ((l, h), (0pt, h)), ((0pt, h), (0pt, 0pt)))
  for ((a0, a1), (b0, b1)) in cotes {
    let longueur = calc.max(calc.abs((b0 - a0) / 1pt), calc.abs((b1 - a1) / 1pt)) * 1pt
    let n = calc.max(1, int(calc.round(longueur / pas)))
    for k in range(n) {
      points.push((a0 + (b0 - a0) * k / n, a1 + (b1 - a1) * k / n))
    }
  }
  let x = calc.rem(graine * 7919 + 104729, 2147483647)
  let res = ()
  for (px, py) in points {
    x = calc.rem(x * 48271, 2147483647)
    let u = 2 * x / 2147483647 - 1
    x = calc.rem(x * 48271, 2147483647)
    let w = 2 * x / 2147483647 - 1
    res.push((px + u * ampl, py + w * ampl))
  }
  res
}

// Cotes communes (bp).
#let _D = (
  arc: 1mm, // arc des cadres tcolorbox
  trait: 0.5mm, // filets gauche et bas (line width=0.5mm)
  ombre: 2.55pt, // décalage de « drop shadow »
  ombre-couleur: rgb(128, 128, 128, 50%),
  cote: 4mm + 1mm, // left/right + boxsep
  pad: 2mm + 1mm, // top/bottom + boxsep
  titre-h: 19.32pt, // banderole \large (hauteur de la boîte titre)
  titre-base: 14.59pt, // ligne de base du titre sous le haut de la banderole
  titre-marge: 9.63pt, // marge latérale du titre dans la banderole
  titre-x: 1cm, // xshift de la banderole
  noeud-sep: 3.67pt, // inner sep TikZ (0,3333 em)
  noeud-trait: 0.3985pt, // 0,4 pt TeX
  noeud-arc: 3.985pt, // rounded corners TikZ (4 pt TeX)
  noeud-interligne: 3.85pt,
  espace: 2mm, // before skip / after skip des environnements didactiques
  ligne-vide: 14.45pt, // \baselineskip : ligne vide après une équation finale
)

/// Nœud TikZ « fill=white, draw=…, rounded corners » contenant un texte gras centré.
/// `largeur` : largeur imposée du texte (minipage) ; `largeur-max` : largeur maximale (varwidth).
#let _noeud(contenu, trait, largeur: none, largeur-max: none, graisse: "bold", taille: auto) = {
  // Une ligne : boîte ajustée aux glyphes (comme la minipage de TeX).
  // Plusieurs lignes : lignes de hauteur fixe espacées de \baselineskip.
  let texte(bornes) = {
    set par(justify: false, leading: 14.45pt - 11pt, spacing: 14.45pt - 11pt)
    set text(weight: graisse)
    set text(top-edge: "bounds", bottom-edge: "bounds") if bornes
    set text(size: taille) if taille != auto
    align(center, contenu)
  }
  let lmax = if largeur != none { largeur } else { largeur-max }
  let une-ligne = measure(block(width: lmax, texte(false))).height < 12pt
  let l = if largeur != none { largeur } else { measure(box(texte(false)), width: largeur-max).width }
  box(
    fill: white,
    stroke: _D.noeud-trait + trait,
    radius: _D.noeud-arc,
    inset: if une-ligne { _D.noeud-sep } else { (x: _D.noeud-sep, top: _D.noeud-sep - 0.25pt, bottom: _D.noeud-sep - 0.15pt) },
    block(width: l, texte(une-ligne)),
  )
}

/// Banderole des environnements didactiques (brique « bfd banner arc »).
/// Renvoie (dessin, largeur, hauteur) ; à appeler dans un `context`.
#let _banderole(nom, arcs, ruban, taille: "large", hauteur: auto, base: auto, K: _D, coltitle: white) = {
  // `taille` : nom de taille LaTeX (« large ») ou longueur
  let st = (size: if type(taille) == str { taille-latex(taille) } else { taille }, weight: "bold")
  // La boîte titre suit les glyphes (TeX) : cotes calées sur « Théorème » (19,32 pt, base à 14,59 pt).
  let (hauteur, base) = if hauteur == auto {
    let asc(x) = measure(text(..st, top-edge: "bounds", bottom-edge: "baseline", x)).height
    let desc(x) = measure(text(..st, top-edge: "baseline", bottom-edge: "bounds", x)).height
    let haut = K.titre-base - asc[Théorème]
    let bas = K.titre-h - K.titre-base - desc[Théorème]
    (haut + asc(nom) + desc(nom) + bas, haut + asc(nom))
  } else { (hauteur, base) }
  let t = text(
    ..st,
    fill: coltitle,
    top-edge: base,
    bottom-edge: base - hauteur,
    nom,
  )
  let w = measure(t).width + 2 * K.titre-marge
  let r = K.arc
  let dessin = box(width: w, height: hauteur, {
    place(curve(fill: arcs, .._demi-disque(-2 * r, r, r), .._demi-disque(w + 2 * r, r, r)))
    place(bf-polygone(
      ((-2 * r, 0pt), (w + 2 * r, 0pt), (w + r, r), (w, hauteur), (0pt, hauteur), (-r, r)),
      rayons: (0pt, r, r, r, r, 0pt),
      fill: ruban,
    ))
    place(dx: K.titre-marge, t)
  })
  (dessin: dessin, largeur: w, hauteur: hauteur)
}

/// Cadre blanc à ombre portée, sécable ou non (fond + « drop shadow » + arc 1 mm).
/// `ombre: false` : sans ombre portée ; `trait` : contour complet (variante interne « cadre »).
#let _cadre-ombre(fond, cassable, contenu, K: _D, ombre: true, trait: none) = block(
  width: 100%,
  above: 0pt,
  below: 0pt,
  breakable: cassable,
  fill: if ombre { K.ombre-couleur } else { none },
  radius: K.arc,
  outset: (left: -K.ombre, top: -K.ombre, right: K.ombre, bottom: K.ombre),
  block(width: 100%, breakable: cassable, fill: fond, stroke: trait, radius: K.arc, contenu),
)

/// Espace faible avant un environnement + réserve pour ce qui dépasse au-dessus du cadre.
#let _avant(espace, debord) = block(above: espace, below: 0pt, width: 100%, height: debord, sticky: true)
/// Repère invisible du haut (`"h"`) ou du bas (`"b"`) d'un cadre d'Exemple, posé par `place`.
#let _repere-cadre(sens) = [#metadata(sens)<bf-cadre-repere>]

/// Hauteur du cadre d'Exemple qui contient cet endroit, entre ses repères haut et bas (introspection :
/// `none` au premier tour). Les cadres emboîtés sont appariés par profondeur. Dans un `context`.
#let _hauteur-cadre() = {
  let ici = here()
  let avant = query(selector(<bf-cadre-repere>).before(ici)).rev()
  let apres = query(selector(<bf-cadre-repere>).after(ici))
  let trouver(liste, ouvrant) = {
    let prof = 0
    for m in liste {
      if m.value == ouvrant { prof += 1 } else if prof == 0 { return m } else { prof -= 1 }
    }
    none
  }
  let haut = trouver(avant, "b")
  let bas = trouver(apres, "h")
  if haut == none or bas == none { return none }
  bas.location().position().y - haut.location().position().y
}

/// Hauteur du PROCHAIN cadre (celui dont le repère haut est le premier repère après cet endroit), pour
/// une décision prise juste avant de le poser. `none` au premier tour. Dans un `context`.
#let _hauteur-cadre-suivant() = {
  let apres = query(selector(<bf-cadre-repere>).after(here()))
  if apres.len() == 0 or apres.first().value != "h" { return none }
  let prof = 0
  for m in apres.slice(1) {
    if m.value == "h" { prof += 1 } else if prof == 0 {
      return m.location().position().y - apres.first().location().position().y
    } else { prof -= 1 }
  }
  none
}


// =====================================================================
// Cadres « à la craie » (chalks) — habillage des environnements didactiques
// =====================================================================
//
// Le moteur de chalks perturbe un tracé net (jitter, bombé, largeur variable) à partir d'une
// géométrie donnée en points. Il faut donc connaître la taille de la boîte AVANT de dessiner :
// l'habillage mesure le corps (layout + measure), dessine le cadre à cette taille, puis repose le
// contenu par-dessus. Deux conséquences, traitées ici :
//   - le bloc devient insécable : un corps sécable ou plus haut qu'une page reprend le cadre net ;
//   - la graine du tracé est dérivée de la géométrie (chalks), donc le rendu est reproductible
//     d'une compilation à l'autre, et deux boîtes de dimensions égales ont le même tracé.

/// Style « à la craie » de l'environnement Démonstration (variante retenue le 18/09/2026) :
/// cadre complet, bandeau de titre hachuré à texte blanc, sous-titre croqué, gris-noir de chalks.
#let bf-craie = (
  cotes: "complet", // "complet" : rectangle ; "gauche-bas" : montant gauche et filet bas
  bandeau: "craie", // "craie" : bandeau hachuré ; "net" : banderole ordinaire du paquet
  noeud: "craie", // "craie" : sous-titre entouré d'un croquis ; "net" : nœud ordinaire
  couleur: rgb("#44464a"), // `auto` : la couleur de l'environnement
  trait: (width: 1.6, roughness: 1.3, taper: 0.5, passes: 2, smoothness: 0.2),
  bandeau-spacing: 2.0, // écart des hachures du bandeau (voir _banderole-craie)
)

/// Allègement des PDF. Le moteur échantillonne les contours à résolution fixe (jusqu'à 2 048
/// cubiques par cadre, autant pour le bandeau hachuré) : un cadre à la craie au tracé complet pèse
/// environ 105 Ko. `#bf-craie-allegement(n)`, en tête de document, fusionne les cubiques par
/// paquets de n, ce qui assagit très légèrement le trait sans le dénaturer :
///   n = 1 : tracé complet, 105 Ko par démonstration ;
///   n = 2 : **défaut depuis le 18/09/2026**, 54 Ko (−46 % sur le document), indiscernable à
///           taille d'impression ;
///   n = 3 : 37 Ko (−62 %), assagissement visible seulement à la loupe ;
///   n = 4 : 30 Ko (−71 %).
#let bf-craie-allegement(n) = chalks-decimation.update(n)

/// Couleur du tracé à la craie de l'environnement courant (`none` hors d'un tel environnement).
/// Décision du 18/09/2026 : dans une Démonstration, une boîte sans couleur explicite suit le
/// gris-noir de la craie plutôt que l'accent orange de l'environnement.
#let bf-craie-teinte = state("bf-craie-teinte", none)

/// Éléments du cadre, dans un espace de `l` × `h` points.
#let _cadre-craie(l, h, style, teinte) = {
  let trait = style.trait + (color: teinte)
  if style.cotes == "complet" {
    // `smoothness` fait passer une spline par les quatre sommets : le tracé dépasse le rectangle
    // d'environ 0,13 × smoothness × (plus grand côté). Sur 17 cm et avec 0,2, le cadre sortait de
    // 13 pt des marges. On borne donc le dépassement à environ 0,8 pt, quelle que soit la taille.
    let lissage = calc.min(trait.at("smoothness", default: 0.2), 6.0 / calc.max(l, h, 1.0))
    chalks.rect((0, 0), (l, h), ..trait + (smoothness: lissage))
  } else {
    let gauche = style.at("trait-gauche", default: style.trait) + (color: teinte)
    chalks.line((0, -1.5), (0, h + 1.5), ..gauche) + chalks.line((-1.5, h), (l, h), ..trait)
  }
}

/// Fond hachuré facultatif (style.fond). Rogné : le moteur fait onduler les hachures avec une
/// amplitude proportionnelle à la taille de la zone, et elles sortiraient du cadre sur une grande
/// boîte ; le cadre, lui, a le droit de déborder (une craie ne s'arrête pas au trait).
#let _fond-craie(L, H, style, teinte) = {
  let (l, h, m) = (L.pt(), H.pt(), 6)
  block(width: L, height: H, clip: true, chalks.sketch(
    L,
    H,
    chalks.region(
      (((m, m), (l - m, m), (l - m, h - m), (m, h - m)),),
      ..style.fond + (color: style.fond.at("color", default: teinte)),
    ),
  ))
}

/// Banderole de titre hachurée, aux cotes de `_banderole` (texte blanc sur hachures denses).
/// `espacement` : écart des hachures en pt — c'est le principal poste de poids du PDF (chaque
/// hachure est un chemin vectoriel), le desserrer allège le fichier en éclaircissant le bandeau.
#let _banderole-craie(nom, b, teinte, taille, espacement) = block(width: b.largeur, height: b.hauteur, {
  place(top + left, chalks.sketch(
    b.largeur,
    b.hauteur,
    chalks.rect(
      (0, 0),
      (b.largeur.pt(), b.hauteur.pt()),
      fill: "hachure",
      spacing: espacement,
      angle: 45.0,
      width: 2.2,
      roughness: 0.8,
      color: teinte,
      opacity: 95%,
    ),
  ))
  align(center + horizon, text(size: if type(taille) == str { taille-latex(taille) } else { taille }, weight: "bold", fill: white, nom))
})

/// Nœud de sous-titre entouré d'un croquis (le gabarit `_noeud` donne les cotes exactes).
#let _noeud-craie(contenu, teinte, largeur: none, largeur-max: none, fond: white) = {
  let g = measure(_noeud(contenu, white, largeur: largeur, largeur-max: largeur-max))
  block(width: g.width, height: g.height, fill: fond, {
    place(top + left, chalks.sketch(
      g.width,
      g.height,
      chalks.rect((1, 1), (g.width.pt() - 2, g.height.pt() - 2), width: 1.0, roughness: 1.1, color: teinte),
    ))
    align(center + horizon, text(weight: "bold", fill: teinte, contenu))
  })
}

// =====================================================================
// Squelette des environnements didactiques (style « bfd didactic skin »)
// =====================================================================

/// Environnement didactique générique.
///   couleur : couleur sémantique (#1 de bfd didactic skin) ; nom : texte de la banderole.
///   noeud   : position du sous-titre — "lignes" (variante par défaut : centré entre la banderole
///             et le bord droit, varwidth 0,4 \columnwidth − 1 cm), "large" (minipage 0,5 \textwidth
///             ancrée à 4 cm du bord droit), "bfenv" (minipage \columnwidth − 4 cm − 0,2 \columnwidth
///             ancrée à 0,1 \columnwidth du bord droit, affichée même vide) ; la variante `sidebar`
///             ancre de même le sous-titre, ajusté à son texte (« sidebar »).
///   craie   : `none` (cadre net) ou un style de tracé à la craie (voir `bf-craie`) ; le cadre est
///             alors dessiné à la taille mesurée du corps, et un corps sécable ou plus haut qu'une
///             page reprend automatiquement le cadre net (un tracé d'un tenant ne se coupe pas).
#let bf-environnement(
  couleur,
  nom,
  titre: none,
  fond: white,
  arcs: auto,
  ruban: auto,
  bordure: auto,
  reglage: auto,
  sommaire: true,
  breakable: false,
  noeud: "lignes",
  taille-titre: "large",
  hauteur-titre: auto,
  base-titre: auto,
  bas: auto,
  avant: _D.espace,
  apres: _D.espace,
  entete: none,
  craie: none,
  numero: none,
  icone: none,
  tcb: none,
  k: (:),
  variant: "lignes",
  coltitle: white,
  ombre: true,
  corps,
) = {
  // `k` : cotes qui remplacent celles de `_D` (gauche, droite, pad, bas, arc, trait, titre-x…) ;
  // `variant` : habillage des bords, "lignes" (défaut), "minimal", "sidebar" (\bfdActivateVariant)
  // (la variante interne "cadre" de TheoA a disparu avec cet environnement).
  let K = _D + k
  let g = K.at("gauche", default: K.cote)
  let dr = K.at("droite", default: K.cote)
  let bas = if bas == auto { K.at("bas", default: K.pad) } else { bas }
  let noeud = if variant == "sidebar" { "sidebar" } else { noeud }
  // `nom-banniere` : texte de la banderole (icône, nom, numéro) ; `nom` reste le libellé du sommaire.
  let nom-banniere = bf-nom-banniere(nom, numero, icone)
  let c = _c(couleur)
  let c50 = if bordure == auto { xmix(c, 50) } else { _c(bordure) }
  let arcs = if arcs == auto { xmix(c, 80) } else { _c(arcs) }
  let ruban = if ruban == auto { c } else { _c(ruban) }
  let sans-titre = bf-vide(titre) or variant == "minimal"
  let teinte = if craie == none { c } else {
    let t = craie.at("couleur", default: auto)
    if t == auto { c } else { _c(t) }
  }
  // La banderole garde ses cotes propres (enroulements de 1 mm, `yshift*=1mm` de « bfd banner arc ») :
  // la clé `arc` ne règle que les coins du cadre, comme en LaTeX. (Avant le 08/10/2026, `arc` déformait
  // les enroulements : une bosse à gauche dès 3 mm.)
  let ab = _D.arc
  _avant(avant, ab)
  context {
    // options tcolorbox passées par le convertisseur : seules breakable et colback sont rendues
    let o = lire-options(tcb)
    let breakable = breakable or booleen-latex(o.at("breakable", default: false))
    let fond = if "colback" in o { xcouleur(o.colback) } else { fond }
    let b = _banderole(nom-banniere, arcs, ruban, taille: taille-titre, hauteur: hauteur-titre, base: base-titre, K: K + (arc: ab), coltitle: _c(coltitle))
    let haut = K.pad + b.hauteur - ab
    // Décor (banderole et sous-titre), en coordonnées relatives à la zone de contenu.
    let decor = {
      let banderole = if craie != none and craie.bandeau == "craie" {
        _banderole-craie(nom-banniere, b, teinte, taille-titre, craie.at("bandeau-spacing", default: 2.0))
      } else { b.dessin }
      place(top + left, dx: K.titre-x - g, dy: -haut - ab, banderole)
      if entete != none {
        place(top + left, dx: -g, dy: -haut, layout(s => entete(s.width + g + dr)))
      } else if not sans-titre {
        // (le nœud vide de bfEnv n'est plus dessiné, et le nœud de bfEnv se
        // raccourcit pour ne plus passer sous une banderole au nom long.)
        place(top + left, dx: -g, dy: -haut, layout(s => {
          let L = s.width + g + dr
          let croquis = craie != none and craie.at("noeud", default: "net") == "craie"
          let boite(contenu, ..cotes) = if croquis {
            _noeud-craie(contenu, teinte, fond: fond, ..cotes)
          } else {
            _noeud(contenu, c50, ..cotes)
          }
          // Place libre pour le sous-titre : de la fin de la banderole (enroulement compris, plus 2 mm)
          // au bord droit du cadre (moins 1,5 mm), cadre du nœud déduit. La largeur LaTeX
          // (0,4 \columnwidth − 1 cm) ne vaut que pour une pleine page : en colonne, elle tombait à
          // 1 à 3 cm (« Relation de Chasles » sur deux lignes, mot long qui sortait du nœud) ; la
          // largeur maximale va donc jusqu'à celle d'une pleine page (5,8 cm) tant que la place le
          // permet, et jamais au-delà de la place libre (icône ou numéro qui allongent la banderole).
          // À pleine largeur, rien ne change.
          let debut = K.titre-x + b.largeur + 3 * ab + 2mm
          let fin = L - 1.5mm
          let cadre-noeud = 2 * _D.noeud-sep + _D.noeud-trait
          let pleine-page = 5.8cm // 0,4 × 17 cm − 1 cm
          // Sous-titre ajusté (lignes, sidebar) : largeur maximale `lmax`, place horizontale `place`.
          // Colonne trop étroite : au-delà de deux lignes, le nœud repasse sur deux lignes ; s'il ne
          // tient toujours pas (mot plus long que la place), il est réduit, jusqu'à la moitié.
          let ajuste(lmax, place) = {
            // un mot plus long que `lmax` déborderait du nœud sans l'élargir : le nœud prend la
            // largeur du mot le plus long (puis la réduction ci-dessous le ramène dans la place)
            let mots = _brut(titre).split(_blancs).filter(x => x != "")
            // une seule mesure : la largeur d'une pile de boîtes est celle du mot le plus large
            let mot-max = measure(stack(..mots.map(x => box(text(weight: "bold", x))))).width
            let lmax = calc.max(lmax, mot-max)
            let n = boite(titre, largeur-max: lmax)
            let m = measure(n)
            let deux-lignes = 2 * _D.ligne-vide + 2 * _D.noeud-sep + 2pt
            if lmax < pleine-page and m.height > deux-lignes {
              n = boite(titre, largeur-max: calc.max(lmax, 0.6 * measure(boite(titre, largeur-max: 100 * L)).width))
              m = measure(n)
            }
            if m.width > place { scale(calc.max(place / m.width, 0.5) * 100%, reflow: true, n) } else { n }
          }
          let n = if noeud == "lignes" {
            let dispo = fin - debut - cadre-noeud
            ajuste(calc.max(calc.min(dispo, calc.max(0.4 * L - 1cm, pleine-page)), 1.5cm), fin - debut)
          } else if noeud == "large" {
            boite(titre, largeur: 0.5 * L)
          } else if noeud == "sidebar" {
            // variante sidebar : nœud ancré à 0,1 \columnwidth du bord droit, mais ajusté au texte
            // (la minipage fixe de LaTeX, \columnwidth − 4 cm − 0,2 \columnwidth, donnait un cadre
            // bien plus large qu'un sous-titre court, et presque nul en colonne)
            let dispo = 0.9 * L - debut - cadre-noeud
            ajuste(calc.max(calc.min(dispo, calc.max(0.8 * L - 4cm, pleine-page)), 1.5cm), fin - debut)
          } else {
            let place-libre = 0.9 * L - (K.titre-x + b.largeur) - 3mm
            boite(titre, largeur: calc.min(0.8 * L - 4cm, calc.max(place-libre, 2cm)))
          }
          let m = measure(n)
          if noeud == "lignes" {
            // centré entre title.east et frame.east, à la hauteur du milieu de la banderole ; ramené
            // dans la place libre s'il touchait la banderole ou dépassait du cadre
            let cx = (K.titre-x + b.largeur + L) / 2
            let cy = b.hauteur / 2 - ab
            let x = calc.max(calc.min(cx - m.width / 2, fin - m.width), debut)
            place(dx: x, dy: cy - m.height / 2, n)
          } else if noeud == "large" {
            place(dx: L - 4cm - m.width - _D.noeud-trait / 2, dy: _D.noeud-trait / 2, n)
          } else {
            let x = 0.9 * L - m.width - _D.noeud-trait / 2
            let x = if noeud == "sidebar" { calc.max(calc.min(x, fin - m.width), debut) } else { x }
            place(dx: x, dy: _D.noeud-trait / 2, n)
          }
        }))
      }
    }
    let fin-equation = _finit-par-equation(corps)
    // TeX : la marge basse part de la profondeur réelle de la dernière ligne
    let bas = if fin-equation { bas } else { bas + _profondeur(corps) - 2.75pt }
    let contenu = context {
      // les boîtes filles sans couleur propre suivent la craie de l'environnement, pas son accent ; la teinte
      // est portée par la chaîne de styles (`bf-porter`), pour ce contenu seulement
      bf-porter(("bf-craie-teinte": if craie == none { none } else { teinte }), {
        if sommaire == true { bf-entree-sommaire(nom, titre) } else if sommaire not in (false, none) { sommaire }
        bf-avec-couleurs(reglage: if reglage == auto { bfdsetcolors(c) } else { reglage }, corps)
        if fin-equation { v(_D.ligne-vide + 11.96pt - 2.5pt) }
      })
    }

    // Cadre net : bords selon la variante, fond blanc et ombre portée.
    //   lignes  : filet gauche et filet bas (K.trait) ;
    //   minimal : fin filet gauche (0,2 mm), sans sous-titre ;
    //   sidebar : bande pleine de 3 mm à gauche, sous-titre ancré à droite ;
    let bande = if variant == "sidebar" { K.at("bande", default: 3mm) } else { 0pt }
    let filet = if variant == "lignes" { K.trait } else if variant == "minimal" { K.at("trait-minimal", default: 0.2mm) } else { bande }
    let decale(x) = if bande > 0pt { pad(left: bande / 2, x) } else { x }
    let cadre-net(cassable) = _cadre-ombre(fond, cassable, K: K, ombre: ombre, trait: none, decale(block(
      width: 100%,
      breakable: cassable,
      stroke: (left: filet + c50),
      inset: (left: g - bande / 2, right: dr, top: haut, bottom: bas),
      {
        decor
        contenu
        // dernier morceau : filet bas (et le filet gauche descend de 0,25 mm sous le cadre)
        if variant == "lignes" {
          place(bottom + left, dx: -g, dy: bas, {
            place(line(length: 100% + g + dr, stroke: K.trait + c50))
            place(line(start: (0pt, 0pt), end: (0pt, K.trait / 2), stroke: K.trait + c50))
          })
        }
      },
    )))
    if craie == none {
      cadre-net(breakable)
    } else if breakable {
      // Un tracé d'un seul tenant ne suit pas une coupure de page : cadre net.
      cadre-net(true)
    } else {
      // Le tracé à la craie dépend de la hauteur du cadre. Elle est lue entre deux repères (haut, bas), par
      // le seul tracé, posé par `place` : le contenu n'est composé qu'UNE fois (il l'était deux fois :
      // `measure`, puis rendu). Au premier tour, la hauteur est inconnue : le tracé attend le tour suivant.
      layout(taille => {
        let L = taille.width
        let H-cadre = _hauteur-cadre-suivant()
        let H = if H-cadre == none { none } else { H-cadre + haut + bas }
        // Un cadre plus haut que la page : cadre net, sécable.
        if H != none and H > taille.height {
          cadre-net(true)
        } else {
          block(width: L, breakable: false, fill: fond, inset: (left: g, right: dr, top: haut, bottom: bas), {
            place(top + left, _repere-cadre("h"))
            place(top + left, dx: -g, dy: -haut, context {
              let H-cadre = _hauteur-cadre()
              if H-cadre != none {
                let H = H-cadre + haut + bas
                if "fond" in craie { place(top + left, _fond-craie(L, H, craie, teinte)) }
                place(top + left, chalks.sketch(L, H, _cadre-craie(L.pt(), H.pt(), craie, teinte)))
              }
            })
            // le décor compte en largeur intérieure (son `layout` y lit \columnwidth)
            place(top + left, block(width: L - g - dr, decor))
            contenu
            place(bottom + left, _repere-cadre("b"))
          })
        }
      })
    }
  }
  v(apres)
}

// =====================================================================
// Les douze environnements de \bfdNewSemanticEnv (Section 7)
// =====================================================================

/// \begin{Theoreme}[sous-titre] … \end{Theoreme}
#let theoreme(titre: none, tcb: none, corps) = bf-environnement(couleurs.thm, [Théorème], titre: titre, tcb: tcb, reglage: bfdsetcolorstheoreme(), corps)
/// \begin{Definition}[sous-titre]
#let definition(titre: none, tcb: none, corps) = bf-environnement(couleurs.defi, [Définition], titre: titre, tcb: tcb, reglage: bfdsetcolorsdefinition(), corps)
/// \begin{Propriete}[sous-titre]
#let propriete(titre: none, tcb: none, corps) = bf-environnement(couleurs.prop, [Propriété], titre: titre, tcb: tcb, corps)
/// \begin{Demonstration}[sous-titre]
#let demonstration(titre: none, tcb: none, corps) = bf-environnement(couleurs.demo, [Démonstration], titre: titre, tcb: tcb, craie: bf-craie, corps)
/// \begin{Methode}[sous-titre]
#let methode(titre: none, tcb: none, corps) = bf-environnement(couleurs.meth, [Méthode], titre: titre, tcb: tcb, corps)
/// \begin{Activite}[sous-titre] : seul environnement didactique sécable.
#let activite(titre: none, tcb: none, corps) = bf-environnement(couleurs.act, [Activité], titre: titre, tcb: tcb, breakable: true, corps)
/// \begin{Vocabulaire}[sous-titre]
#let vocabulaire(titre: none, tcb: none, corps) = bf-environnement(couleurs.nota, [Vocabulaire], titre: titre, tcb: tcb, corps)
/// \begin{Solution}[sous-titre] : habillage vert, couleurs du corps green!50!black.
#let solution(titre: none, tcb: none, corps) = {
  let vert = xc.green
  let fonce = xmix(vert, 50, autre: black)
  bf-environnement(
    vert,
    [Solution],
    titre: titre,
    arcs: xmix(vert, 80, autre: black),
    ruban: xmix(vert, 80, autre: black),
    reglage: bfdsetcolors(fonce),
    tcb: tcb,
    corps,
  )
}
// =====================================================================
// Exemple et ContreExemple (Section 9 : habillage « tikz corners »)
// =====================================================================

#let _E = (
  debord: 8.62pt, // la boîte titre dépasse de 8,62 pt au-dessus du cadre
  titre-h: 19.96pt,
  titre-base: 13.46pt,
  titre-marge: 3mm,
  regle: 0.5mm, // boxrule (cadre caché mais compté)
  trait: 1.494pt, // line width = 1.5pt
  avant: 7.22pt,
  apres: 1.55pt,
)

/// Squelette commun de Exemple et ContreExemple.
#let bf-exemple(
  nom,
  titre,
  fond,
  couleur,
  accent,
  corps,
  sommaire: true,
  numero: none,
  icone: none,
  avant: _E.avant,
  apres: _E.apres,
  breakable: false,
  k: (:),
  taille: "large",
) = {
  let E = _E + (coin: 2cm) + k
  _avant(avant, E.debord)
  context {
    let t = text(
      size: (if type(taille) == str { taille-latex(taille) } else { taille }),
      weight: "bold",
      fill: white,
      top-edge: E.titre-base,
      bottom-edge: E.titre-base - E.titre-h,
      bf-nom-banniere(nom, numero, icone),
    )
    let w = measure(t).width + 2 * E.titre-marge
    let cy = E.titre-h / 2 - E.debord // milieu du titre, sous le haut du cadre
    let x-est = -2mm + w
    let fin-equation = _finit-par-equation(corps)
    // `coin-g` : trait vertical sous la banderole ; `coin-d` : équerre en bas à droite. Exemple court (moins
    // haut que l'équerre) : le trait de gauche et l'équerre sont ramenés à la hauteur du cadre, au lieu de
    // dépasser au-dessus ou au-dessous de lui. La hauteur du cadre est lue entre deux repères (haut, bas)
    // par les seuls tracés concernés, posés par `place` : le corps n'en dépend pas, et le cadre n'est
    // composé qu'UNE fois (il l'était deux fois : `measure`, puis rendu). Cadre sécable, ou hauteur encore
    // inconnue (premier tour) : taille réglée (`corner-size`).
    let coin(f) = if breakable { E.coin } else {
      let h = _hauteur-cadre()
      if h == none { E.coin } else { calc.min(E.coin, f(h + 2 * E.regle)) }
    }
    let cadre = block(width: 100%, above: 0pt, below: 0pt, breakable: breakable, inset: E.regle, {
      if not breakable { place(top + left, _repere-cadre("h")) }
      block(
        width: 100%,
        fill: fond,
        radius: (top-left: _D.arc - E.regle),
        breakable: breakable,
        inset: (x: _D.cote, top: _D.pad + 0.5cm, bottom: if fin-equation { _D.pad } else { _D.pad + _profondeur(corps) - 2.75pt }),
        {
          // tracés du haut (banderole, filets, sous-titre) : premier enfant du fond, donc posés
          // sur le premier morceau si l'exemple est sécable ; origine : coin haut gauche du cadre
          place(top + left, dx: -_D.cote - E.regle, dy: -(_D.pad + 0.5cm) - E.regle, {
            place(dx: 2.13pt, dy: 2mm, context line(end: (0pt, coin(h => h - 2mm - E.regle)), stroke: E.trait + couleur))
            if bf-vide(titre) { place(dx: x-est, dy: cy, line(length: 3cm, stroke: E.trait + couleur)) }
            place(dx: -2mm, dy: -E.debord, box(
              width: w,
              height: E.titre-h,
              fill: couleur,
              radius: _D.arc,
              inset: (x: E.titre-marge),
              t,
            ))
            if not bf-vide(titre) {
              layout(s => {
                // Cadre étroit (colonne, MultiColonnes) : le filet de liaison (3 cm) puis le nœud
                // (moitié du cadre) sortiraient du cadre, et de la page ; on raccourcit d'abord le filet
                // (5 mm au moins), puis le nœud. Cadre large : cotes d'origine.
                let cadre-l = s.width + 2 * _D.cote + 2 * E.regle
                let largeur = 0.5 * cadre-l
                // bords du nœud, plus 4 mm pour rester à l'écart de l'équerre du bord droit
                let bords = 2 * _D.noeud-sep + 1.5 * _D.noeud-trait + 4mm
                let dispo = cadre-l - x-est - bords
                let liaison = calc.max(5mm, calc.min(3cm, dispo - largeur))
                let largeur = calc.min(largeur, dispo - liaison)
                place(dx: x-est, dy: cy, line(length: liaison, stroke: E.trait + couleur))
                let n = _noeud(titre, couleur, largeur: largeur)
                let m = measure(n)
                place(dx: x-est + liaison + _D.noeud-trait / 2, dy: cy - m.height / 2, n)
              })
            }
          })
          if sommaire == true { bf-entree-sommaire(nom, titre) } else if sommaire not in (false, none) { sommaire }
          bf-avec-couleurs(accent: accent, corps)
          if fin-equation { v(_D.ligne-vide + 11.96pt - 2.5pt) }
        },
      )
      // équerre en bas à droite (dernier morceau)
      place(bottom + right, dx: E.regle, dy: E.regle, context {
        let coin-d = coin(h => h - 2.13pt)
        box(width: E.coin, height: coin-d + 2.13pt, place(curve(
          stroke: E.trait + couleur,
          curve.move((0pt, coin-d)),
          curve.line((E.coin - 2.13pt, coin-d)),
          curve.line((E.coin - 2.13pt, 0pt)),
        )))
      })
      if not breakable { place(bottom + left, _repere-cadre("b")) }
    })
    cadre
  }
  v(apres)
}

/// \begin{Exemple}[sous-titre]
#let exemple(titre: none, tcb: none, corps) = bf-exemple(
  [Exemple(s)],
  titre,
  xmix(xc.gray, 2),
  xmix(xc.gray, 80, autre: black),
  xmix(couleurs.nota, 80, autre: black),
  corps,
)
/// \begin{ContreExemple}[sous-titre]
#let contreexemple(titre: none, tcb: none, corps) = bf-exemple(
  [Contre-Exemple(s)],
  titre,
  xmix(xc.red, 2),
  xmix(xc.red, 80, autre: black),
  xmix(xc.blue, 80, autre: black),
  corps,
)
#let contre-exemple = contreexemple

// =====================================================================
// Remarque (bclogo : crayon, titre « remarque(s) : », barre en serpentin)
// =====================================================================

#let _R = (
  avant: 6.04pt, // jusqu'au haut de la ligne de titre
  apres: 1.74pt,
  titre-x: 18.93pt,
  corps-x: 20.92pt,
  droite: 3.99pt,
  ecart: 4.15pt, // bas du titre → haut de la première ligne
  serpent-x: 10.46pt,
  serpent-ampl: 2.49pt,
  serpent-pas: 3.31pt,
)

/// Tuile d'une onde complète du serpentin (période 2 × 3,31 pt, trait 1 pt TeX).
/// `barre` : "snake" (serpentin de bclogo), "line" (trait droit) ; `R` : cotes (défaut `_R`).
#let _tuile-serpent(c, barre: "snake", R: _R) = {
  let a = R.serpent-ampl
  let p = R.serpent-pas
  let x0 = R.serpent-x
  tiling(size: (R.corps-x, 2 * p), if barre == "line" {
    curve(stroke: 0.9963pt + c, curve.move((x0, 0pt)), curve.line((x0, 2 * p)))
  } else {
    curve(
      stroke: 0.9963pt + c,
      curve.move((x0, 0pt)),
      curve.cubic((x0 + 0.51 * a, 0.163 * p), (x0 + a, 0.321 * p), (x0 + a, 0.5 * p)),
      curve.cubic((x0 + a, 0.679 * p), (x0 + 0.51 * a, 0.837 * p), (x0, p)),
      curve.cubic((x0 - 0.51 * a, 1.163 * p), (x0 - a, 1.321 * p), (x0 - a, 1.5 * p)),
      curve.cubic((x0 - a, 1.679 * p), (x0 - 0.51 * a, 1.837 * p), (x0, 2 * p)),
    )
  })
}

/// \begin{Remarque} … \end{Remarque} (le sous-titre optionnel est ignoré par bfcours).
///   barre : "snake" (défaut, option bclogo barre=snake), "line" ou "none" ;
///   accent : couleur d'accent du corps (`auto` : thm!80!black, ou couleur!80!black) ;
///   taille-titre : nom de taille LaTeX ou longueur ; taille-logo : côté du logo ;
///   libelle : texte du titre (« Remarque(s) : »).
#let remarque(
  titre: none,
  tcb: none,
  corps,
  sommaire: false,
  numero: none,
  icone: auto,
  avant: _R.avant,
  apres: _R.apres,
  breakable: true,
  couleur: none,
  barre: "snake",
  accent: auto,
  taille-titre: "large",
  taille-logo: 16.9pt,
  libelle: auto,
) = {
  let fin-equation = _finit-par-equation(corps)
  // `couleur` : teinte du titre, du serpentin et de l'accent du corps (none : noir, accent d'origine)
  let teinte = if couleur == none { black } else { _c(couleur) }
  let accent = if accent != auto { _c(accent) } else if couleur == none { xmix(couleurs.thm, 80, autre: black) } else {
    xmix(teinte, 80, autre: black)
  }
  block(width: 100%, above: avant, below: 0pt, breakable: breakable, context {
    let taille = if type(taille-titre) == str { taille-latex(taille-titre) } else { taille-titre }
    block(width: 100%, below: _R.ecart, sticky: true, {
      if sommaire == true { bf-entree-sommaire([Remarque], titre) } else if sommaire not in (false, none) { sommaire }
      let dy = 9.9pt - 11.72pt + (16.9pt - taille-logo) / 2
      if icone == auto {
        place(dx: 1.15pt, dy: dy, image("icones/bccrayon.svg", width: taille-logo))
      } else if icone != none {
        place(dx: 1.15pt, dy: dy, box(width: taille-logo, height: taille-logo, align(center + horizon, icone)))
      }
      let texte = if libelle != auto { libelle } else if numero == none [Remarque(s) :] else [Remarque #numero :]
      pad(left: _R.titre-x, text(size: taille, weight: "bold", fill: teinte, texte))
    })
    grid(
      columns: (_R.corps-x, 1fr, _R.droite),
      fill: (x, y) => if x == 0 and barre != "none" { _tuile-serpent(teinte, barre: barre) },
      [],
      {
        bf-avec-couleurs(accent: accent, corps)
        if fin-equation { v(_D.ligne-vide + 11.96pt - 2.5pt) }
      },
      [],
    )
  })
  v(apres + if _finit-par-equation(corps) { 0pt } else { _profondeur(corps) - 2.75pt })
}

// =====================================================================
// cracked, Notation, Aide (cadre déchiré, titre incliné)
// =====================================================================

#let _K = (
  avant: 4.4pt,
  apres: 7.22pt,
  haut: 10mm + 1mm + 0.5mm,
  cote: 5mm + 1mm + 0.5mm,
  bas: 5mm + 1mm + 0.5mm, // bottom + boxsep + boxrule
  trait: 1.594pt, // ultra thick
  ampl: 2.49pt, // random steps : amplitude 2,5 pt TeX
  titre-taille: 16pt,
  titre-base: 11.22pt,
  titre-interligne: 19.93pt, // \fontsize{16pt}{20pt}
  titre-xsep: 4.98pt,
  titre-ysep: 2.99pt,
)

#let bf-graine-cracked = counter("bf-cracked")

/// Ombre floue (« drop fuzzy shadow ») : dix rectangles de plus en plus opaques.
#let _ombre-floue(l, h) = {
  let opacites = (1, 2, 4, 7, 11, 11, 7, 4, 2, 1)
  for (k, o) in opacites.enumerate() {
    let e = 1.36pt - 0.34pt * k
    place(dx: 1mm - e, dy: 1mm - e, rect(
      width: l + 2 * e,
      height: h + 2 * e,
      radius: calc.max(0pt, 1mm + e),
      fill: rgb(128, 128, 128, o * 1%),
    ))
  }
}

/// \begin{cracked}[titre][sous-titre][couleur][couleur du titre][largeur du titre] … \end{cracked}
#let cracked(
  titre: [Propriété],
  sous-titre: none,
  couleur: "orange",
  couleur-titre: auto,
  largeur: 2.5cm,
  sommaire: none,
  numero: none,
  avant: _K.avant,
  apres: _K.apres,
  k: (:),
  corps,
) = {
  let K = _K + (pas: 0.4cm, pas-titre: 0.2cm, angle: -10deg, ombre: true) + k
  let c = _c(couleur)
  let ct = if couleur-titre == auto { c } else { _c(couleur-titre) }
  let titre = if numero == none { titre } else [#titre #numero]
  bf-graine-cracked.step()
  block(width: 100%, above: avant, below: 0pt, breakable: false, context {
    let graine = bf-graine-cracked.get().first()
    let fin-equation = _finit-par-equation(corps)
    layout(s => {
      let L = s.width
      let bas = if fin-equation { K.bas } else { K.bas + _profondeur(corps) - 2.75pt }
      let gauche = K.at("gauche", default: K.cote)
      // titre incliné
      let tt = {
        set par(justify: false, leading: K.titre-interligne - K.titre-base - 3.45pt)
        set text(
          size: K.titre-taille * bf-lire(bf-police-p).echelle,
          weight: "bold",
          fill: white,
          top-edge: K.titre-base,
          bottom-edge: -3.45pt,
        )
        align(center, titre)
      }
      let tl = largeur + 2 * K.titre-xsep
      let th = measure(block(width: largeur, tt)).height + 2 * K.titre-ysep
      let etiquette = box(width: tl, height: th, {
        place(bf-polygone(
          _rectangle-dechire(tl, th, K.pas-titre, K.ampl, graine * 2 + 1),
          fill: ct,
          stroke: (paint: ct, thickness: K.trait, join: "round"),
        ))
        place(dx: K.titre-xsep, dy: K.titre-ysep, block(width: largeur, tt))
      })
      // Le corps n'est composé qu'UNE fois (il l'était deux fois : `measure`, puis rendu). Le cadre déchiré,
      // l'ombre et le fond blanc dépendent de la hauteur H de la boîte : elle est lue entre deux repères
      // (haut, bas) par le seul décor, posé par `place` sous le corps (même ordre de dessin qu'avant). Au
      // premier tour, la hauteur est inconnue : le décor qui en dépend attend le tour suivant.
      block(width: L, inset: (left: gauche, right: K.at("droite", default: K.cote), top: K.haut, bottom: bas), {
        place(top + left, _repere-cadre("h"))
        place(top + left, dx: -gauche, dy: -K.haut, context {
          let Hc = _hauteur-cadre()
          let H = if Hc == none { none } else { Hc + K.haut + bas }
          block(width: L, height: if H == none { 0pt } else { H }, {
            if H != none {
              if K.ombre {
                place(dx: _D.ombre, dy: _D.ombre, rect(width: L, height: H, radius: _D.arc, fill: _D.ombre-couleur))
                _ombre-floue(L, H)
              }
              place(bf-polygone(
                _rectangle-dechire(L, H, K.pas, K.ampl, graine * 2),
                fill: white,
                stroke: (paint: c, thickness: K.trait, join: "round"),
              ))
            }
            place(dx: -3mm, dy: 3mm, rotate(K.angle, origin: top + left, reflow: false, etiquette))
            if not bf-vide(sous-titre) {
              let n = _noeud(sous-titre, xmix(c, 50), largeur: 0.8 * L - 4cm)
              let m = measure(n)
              place(dx: 0.9 * L - m.width - _D.noeud-trait / 2, dy: 0.25cm + _D.noeud-trait / 2, n)
            }
          })
        })
        if sommaire != none { sommaire }
        bf-avec-couleurs(reglage: bfdsetcolors(c), corps)
        if fin-equation { v(_D.ligne-vide + 11.96pt - 2.5pt) }
        place(bottom + left, _repere-cadre("b"))
      })
    })
  })
  v(apres)
}

/// \begin{Notation}[sous-titre] (cracked vert, titre 3,5 cm)
#let notation(titre: none, tcb: none, corps) = cracked(
  titre: [Notation],
  sous-titre: titre,
  couleur: couleurs.defi,
  largeur: 3.5cm,
  corps,
)
/// \begin{Aide}[sous-titre] (cracked violet, titre 2,5 cm)
#let aide(titre: none, tcb: none, corps) = cracked(titre: [Aide], sous-titre: titre, couleur: couleurs.nota, largeur: 2.5cm, corps)

// =====================================================================
// bfEnv, bfbox, boiteFigure, None, Histoire
// =====================================================================

/// \begin{bfEnv}{titre}[sous-titre][couleur] … \end{bfEnv}
#let bfenv(
  nom,
  titre: none,
  couleur: "prop",
  tcb: none,
  corps,
  sommaire: true,
  breakable: false,
  craie: none,
  numero: none,
  icone: none,
  avant: _D.espace,
  apres: 0pt,
  ..options,
) = {
  let c = _c(couleur)
  bf-environnement(
    c,
    nom,
    titre: titre,
    sommaire: sommaire,
    breakable: breakable,
    craie: craie,
    numero: numero,
    icone: icone,
    avant: avant,
    reglage: {
      couleurstabular("prop", "prop", "white", xmix(c, 5), xmix(c, 50, autre: black))
      couleurssecondarytabular(c, xmix(c, 30), "black", xmix(c, 5), c)
      bf-maj(bf-couleur-p, xmix(c, 80, autre: black))
      bf-maj(bf-couleur-item-p, c)
    },
    noeud: "bfenv",
    tcb: tcb,
    ..((bas: 1mm, apres: apres) + options.named()),
    corps,
  )
}

/// Couleur de \boitecouleur : l'accent courant, gris foncé hors environnement. Dans un `context`.
#let bf-boitecouleur() = {
  // dans un environnement tracé à la craie, la boîte suit la craie (décision du 18/09/2026)
  let craie = bf-porte("bf-craie-teinte")
  if craie != none { return craie }
  let fixe = bf-lire(bf-boitecouleur-fixe-p)
  if fixe != none { return fixe }
  let a = bf-lire(bf-couleur-p)
  if a == black { xmix(xc.gray, 75, autre: black) } else { a }
}

/// Boîte tcolorbox simple (cadre, titre en bandeau) : outil commun à bfbox.
#let _boite-titree(
  titre: none,
  cadre: black,
  fond: white,
  fond-titre: none,
  couleur-titre: white,
  regle: 0.4pt,
  arc: 1mm,
  marges: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  sep: 1mm,
  aligne-titre: left,
  taille-titre: auto,
  largeur: 100%,
  above: 0pt,
  below: 0pt,
  breakable: false,
  corps,
) = {
  let ir = calc.max(0pt, arc - regle)
  block(
    width: largeur,
    above: above,
    below: below,
    fill: cadre,
    radius: arc,
    inset: regle,
    breakable: breakable,
    {
      if not bf-vide(titre) {
        block(
          width: 100%,
          below: regle,
          fill: fond-titre,
          radius: (top: ir),
          inset: (x: sep + 4mm * 0 + marges.left, y: sep),
          {
            set par(justify: false)
            set text(weight: "bold", fill: couleur-titre, top-edge: "bounds", bottom-edge: "bounds")
            set text(size: taille-titre) if taille-titre != auto
            align(aligne-titre, titre)
          },
        )
      }
      block(
        width: 100%,
        above: 0pt,
        breakable: breakable,
        fill: fond,
        radius: if bf-vide(titre) { ir } else { (bottom: ir) },
        inset: (
          left: sep + marges.left,
          right: sep + marges.right,
          top: sep + marges.top,
          bottom: sep + marges.bottom,
        ),
        corps,
      )
    },
  )
}

/// \begin{bfbox}{titre}[options tcolorbox] … \end{bfbox}
/// Options lues : colframe, colback, colbacktitle, coltitle, boxrule, arc, left, right, top, bottom, width.
#let bfbox(titre, tcb: none, corps) = context {
  let o = lire-options(tcb)
  let bc = bf-boitecouleur()
  let lg(cle, defaut) = longueur-latex(o.at(cle, default: none), defaut: defaut)
  _boite-titree(
    titre: titre,
    cadre: if "colframe" in o { xcouleur(o.colframe) } else { bc },
    fond: if "colback" in o { xcouleur(o.colback) } else { white },
    fond-titre: if "colbacktitle" in o { xcouleur(o.colbacktitle) } else { bc },
    couleur-titre: if "coltitle" in o { xcouleur(o.coltitle) } else { white },
    regle: lg("boxrule", 0.4pt),
    arc: lg("arc", 1mm),
    marges: (
      left: lg("left", 0pt),
      right: lg("right", 0pt),
      top: lg("top", 0pt),
      bottom: lg("bottom", 0pt),
    ),
    largeur: lg("width", 100%),
    above: 0.99pt,
    corps,
  )
  // nobeforeafter : la boîte occupe une ligne de paragraphe, suivie d'une ligne vide
  v(_D.ligne-vide)
}

/// Boîte à cadre et titre en bandeau, à clés nommées en couleurs Typst (même rendu que `bfbox`). `cadre` / `fond-titre` : `auto` = couleur d'accent
/// courante (celle de l'environnement dans lequel la boîte est placée, gris foncé sinon).
#let bf-boite(
  titre: none,
  cadre: auto,
  fond: white,
  fond-titre: auto,
  couleur-titre: white,
  epaisseur: 0.4pt,
  arrondi: 1mm,
  marge: 0pt,
  largeur: 100%,
  secable: false,
  avant: 0.99pt,
  apres: _D.ligne-vide,
  corps,
) = context {
  let bc = bf-boitecouleur()
  let cadre = if cadre == auto { bc } else { _c(cadre) }
  _boite-titree(
    titre: titre,
    cadre: cadre,
    fond: _c(fond),
    fond-titre: if fond-titre == auto { cadre } else { _c(fond-titre) },
    couleur-titre: _c(couleur-titre),
    regle: epaisseur,
    arc: arrondi,
    marges: (left: marge, right: marge, top: marge, bottom: marge),
    largeur: largeur,
    above: avant,
    breakable: secable,
    corps,
  )
  v(apres)
}

/// Espacement « balanced » par défaut de tcolorbox (0,5 \baselineskip) : on retient la valeur
/// d'une boîte à une autre (7,23 pt) ; texte → boîte et boîte → texte sont ainsi à ±1,8 pt de TeX.
#let _balance = 0.5 * 14.5pt * 72 / 72.27

/// \begin{boiteFigure}{étiquette} … \end{boiteFigure}
#let boitefigure(
  etiquette,
  corps,
  cadre: auto,
  fond: white,
  arc: 2mm,
  regle: 0.5mm,
  haut: 7mm,
  aligne: center,
  avant: _balance,
  apres: _balance,
) = {
  block(
    width: 100%,
    above: avant,
    below: apres,
    fill: if cadre == auto { xmix(black, 50) } else { _c(cadre) },
    radius: arc,
    inset: regle,
    breakable: false,
    context {
      block(
        width: 100%,
        fill: _c(fond),
        radius: calc.max(0pt, arc - regle),
        inset: (
          x: 4.98pt + 2pt,
          top: 4.98pt + haut,
          bottom: 4.98pt + 2pt + _profondeur(corps) - 2.75pt,
        ),
        {
          set par(justify: false)
          align(aligne, corps)
        },
      )
      // étiquette (nœud TikZ noir, inner sep 3 pt, hauteur 5 mm) par-dessus le fond
      place(top + left, dx: -regle, dy: -regle, box(
        fill: black,
        height: 5mm,
        inset: (x: 3pt * 72 / 72.27),
        align(horizon, text(
          size: taille-latex("scriptsize"),
          weight: "bold",
          fill: white,
          top-edge: "bounds",
          bottom-edge: "bounds",
          etiquette,
        )),
      ))
    },
  )
}

/// \begin{None}[options] … \end{None} : boîte sans cadre ni fond ni marges.
#let neutre(tcb: none, corps, avant: _balance, apres: _balance, breakable: false) = block(
  width: 100%,
  above: avant,
  below: apres,
  breakable: breakable,
  corps,
)
#let none-env = neutre

// ---------- Histoire (skin « syBrisse ») ----------

/// Couleur sépia de l'environnement Histoire (RGB 120, 72, 48).
#let couleur-histoire = rgb(120, 72, 48)

/// \begin{Histoire}{titre}[auteur] … \end{Histoire}
#let histoire(
  titre,
  auteur: none,
  onglet: [Un peu d'histoire],
  couleur: couleur-histoire,
  corps,
  sommaire: true,
  numero: none,
  avant: 3mm,
  apres: 3mm,
  fond: auto,
  regle: auto,
  arc: 4pt,
) = {
  let c = _c(couleur)
  let regle = if regle == auto { 0.8pt * 72 / 72.27 } else { regle }
  let fin-equation = _finit-par-equation(corps)
  let onglet-libelle = onglet
  let onglet = if numero == none { onglet } else [#onglet #numero]
  block(width: 100%, above: avant, below: 0pt, breakable: false, context {
    let taille = bf-lire(bf-taille-base-p)
    // nœud (two) : mesure de l'onglet (texte normal + 0,5 mm, inner xsep 5 pt, hauteur 20 pt)
    let two-l = measure(text(size: taille, onglet)).width + 0.5mm + 2 * 4.98pt
    let two-h = 19.93pt
    let r3 = 2.99pt
    let r4 = 3.985pt
    let bas = 3.5mm + 1mm + if fin-equation { 0pt } else { _profondeur(corps) - 2.75pt }
    let etiquette = text(
      font: "Latin Modern Sans",
      size: 9.96pt,
      weight: "bold",
      fill: white,
      top-edge: "baseline",
      bottom-edge: "baseline",
      [#onglet#h(0.8mm)],
    )
    let l-etiquette = measure(etiquette).width
    block(width: 100%, fill: c, radius: arc, inset: regle, {
      block(
        width: 100%,
        fill: if fond == auto { xmix(c, 6) } else { _c(fond) },
        radius: calc.max(0pt, arc - regle),
        inset: (x: 4mm + 1mm, top: 23pt * 72 / 72.27 + 1mm, bottom: bas),
        {
          // dégradé du bas (underlay : sous le texte, sur le fond)
          place(bottom + left, dx: -(4mm + 1mm) + 0.9pt, dy: bas, box(
            width: 100% + 2 * (4mm + 1mm) - 1.8pt,
            height: 0.8cm,
            radius: (bottom: 3pt),
            fill: gradient.linear(
              (xmix(c, 5).transparentize(50%), 0%),
              (xmix(c, 30).transparentize(50%), 50%),
              (c.transparentize(50%), 100%),
              angle: 90deg,
            ),
          ))
          if sommaire == true { bf-entree-sommaire(onglet-libelle, titre) } else if sommaire not in (false, none) { sommaire }
          if not bf-vide(auteur) {
            block(below: 2.99pt + 14.45pt - 8.25pt - 2.5pt, text(
              size: taille-latex("small"),
              style: "italic",
              fill: xmix(black, 60),
              auteur,
            ))
          }
          bf-avec-couleurs(reglage: bfdsetcolors(c), corps)
          if fin-equation { v(_D.ligne-vide + 11.96pt - 2.5pt) }
        },
      )
      // bandeau, onglet, titre, ombre du pli, rehaut (overlay)
      place(top + left, dx: -regle, dy: -regle, layout(s => {
        let L = s.width + 2 * regle
        let xw = L - two-l
        place(bf-polygone(
          ((0pt, 4.48pt), (xw - 21.92pt, 4.48pt), (xw - 3.98pt, two-h), (L, two-h), (L, 0pt), (0pt, 0pt)),
          rayons: (0pt, r3, 0pt, r4, r4, 0pt),
          fill: c,
          stroke: 0.3985pt + c,
        ))
        for k in range(1, 11) {
          let dy = k * 0.1pt
          place(bf-polygone(
            (
              (0.4pt, 6.48pt - dy),
              (xw - 23.3pt + dy, 6.48pt - dy),
              (xw - 5.28pt + dy, two-h + 1.89pt - dy),
              (L - 0.4pt, two-h + 1.89pt - dy),
            ),
            rayons: (0pt, 3.5pt, 3.5pt, 0pt),
            ferme: false,
            stroke: 0.3985pt + luma(int(255 - 12.7 * k)).transparentize(100% - k * 10%),
          ))
        }
        place(bf-polygone(
          ((0.4pt, 5.18pt), (xw - 22.22pt, 5.18pt), (xw - 4.28pt, two-h + 0.6pt), (L - 0.4pt, two-h + 0.6pt)),
          rayons: (0pt, 3.5pt, 3.5pt, 0pt),
          ferme: false,
          stroke: 1.096pt + white,
        ))
        // titre (nœud three) et libellé de l'onglet (nœud for)
        place(dx: 7.97pt, dy: 18.4pt - 8.25pt, text(weight: "bold", titre))
        place(dx: L - 7.97pt - l-etiquette, dy: 12.11pt, etiquette)
      }))
    })
  })
  v(apres)
}

// =====================================================================
// Ajouts : palette courante, TheoA et Env
// =====================================================================

/// Accroche de couleurs de Theoreme (\bfdSetColorsTheoreme) pour une couleur `k` donnée : la palette
/// courante (\bfdActivatePalette) la fournit ; le socle, lui, fige thm à sa valeur d'origine.
#let bfd-hook-theoreme(k) = {
  bf-maj(bf-couleur-p, k)
  bf-maj(bf-couleurs-tableaux-p, t => (
    primaire: (cadre: k, fond-titre: k, texte-titre: white, fond: xmix(k, 5), texte: "blue!50!black", filets: k),
    secondaire: (cadre: k, fond-titre: "Salmon!30!white", texte-titre: black, fond: "yellow!10!white", texte: k),
  ))
  bf-maj(bf-couleur-item-p, k)
}

/// Accroche de couleurs de Definition (\bfdSetColorsDefinition) pour une couleur `k` donnée.
#let bfd-hook-definition(k) = {
  bf-maj(bf-couleur-p, k)
  bf-maj(bf-couleurs-tableaux-p, t => (
    primaire: (cadre: k, fond-titre: k, texte-titre: white, fond: xmix(k, 5), texte: "blue!50!black", filets: k),
    secondaire: (cadre: k, fond-titre: xmix(k, 30), texte-titre: black, fond: xmix(k, 5), texte: k),
  ))
  bf-maj(bf-couleur-item-p, k)
}
