// colonnes.typ — tcbraster (et le moteur de boîtes façon tcolorbox : bf-boite, bf-raster, bf-resoudre-tcb).
//
// Sources LaTeX : new-bfcours-environments.sty (MultiColonnes, Colonnes, ColonnesBaseStyle,
// \setColonnesBaseStyle), bfcours.sty (\tcbset global), tcolorbox (tailles prédéfinies, raster).
//
// Un raster tcolorbox place des boîtes en grille ; « raster equal height=rows » donne à toutes
// les boîtes d'un rang la hauteur de la plus haute. Ici : on mesure chaque boîte à sa largeur,
// on prend le maximum par rang et on redessine les boîtes à cette hauteur.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "listes.typ": bf-lire-item, tcbitem

// =====================================================================
// Moteur de boîtes : options tcolorbox → style résolu → dessin
// =====================================================================

#let _tailles-tcb = (
  normal: (boxrule: 0.5mm, boxsep: 1mm, left: 4mm, right: 4mm, top: 2mm, bottom: 2mm, arc: 1mm),
  title: (boxrule: 0.4mm, boxsep: 1mm, left: 2mm, right: 2mm, top: 0.25mm, bottom: 0.25mm, arc: 0.75mm),
  small: (boxrule: 0.3mm, boxsep: 1mm, left: 1mm, right: 1mm, top: 0pt, bottom: 0pt, arc: 0.5mm),
  fbox: (boxrule: ptl(0.4), boxsep: ptl(3), left: 0pt, right: 0pt, top: 0pt, bottom: 0pt, arc: ptl(1)),
  tight: (boxrule: ptl(0.4), boxsep: 0pt, left: 0pt, right: 0pt, top: 0pt, bottom: 0pt, arc: 0pt),
  minimal: (boxrule: 0pt, boxsep: 0pt, left: 0pt, right: 0pt, top: 0pt, bottom: 0pt, arc: 0pt),
)

/// Style tcolorbox par défaut dans un document bfcours :
/// réglages de tcolorbox (size=normal, halign=justify…) + \tcbset global de bfcours.sty
/// (colback=gray!10!white, colframe=black, colbacktitle=gray!30!white, coltitle=black,
/// center title, fonttitle=\bfseries\large). Les couleurs sont des couleurs nommées (`bf-nommee`) lues au
/// rendu : `setbfcolors` les change.
#let bf-tcb-defaut = (
  size: "normal",
  toptitle: 0pt,
  bottomtitle: 0pt,
  colback: bf-nommee("gray!10!white"),
  colframe: bf-nommee("black"),
  colbacktitle: bf-nommee("gray!30!white"),
  coltitle: bf-nommee("currentTitleColor"),
  halign: "justify",
  halign-title: "center",
  valign: "top",
  fonttitle: "\\bfseries\\large",
)

/// Couleur d'une option LaTeX : expression xcolor, avec les macros de couleur courantes de bfcours.
/// À appeler dans un `context`.
#let bf-couleur-tcb(v) = {
  if bf-est-nommee(v) { return bf-couleur-nommee(v, commande: "bf-couleur-tcb") }
  if type(v) != str { return v }
  let perso = bf-lire(bf-couleurs-perso-p) + (bfaccent: bf-lire(bf-couleur-p))
  let e = v
    .replace("\\currentAccentColor", "bfaccent")
    .replace("\\currentBackgroundColor", "white")
    .replace("\\currentFrameColor", "white")
    .replace("\\currentTitleColor", "black")
    .replace("\\boitecouleur", "bfaccent")
    .trim()
  if e == "" { return none }
  xcolor(e, perso: perso)
}

/// Police d'une option LaTeX (« \bfseries\large », « \sffamily\itshape ») → réglages de texte.
#let bf-police-tcb(v) = {
  if type(v) != str { return v }
  let r = (:)
  if v.contains("\\bfseries") or v.contains("\\textbf") { r.insert("weight", "bold") }
  if v.contains("\\mdseries") { r.insert("weight", "regular") }
  if v.contains("\\itshape") or v.contains("\\slshape") { r.insert("style", "italic") }
  if v.contains("\\sffamily") { r.insert("sans", true) }
  for nom in ("tiny", "scriptsize", "footnotesize", "small", "normalsize", "large", "Large", "LARGE", "huge", "Huge") {
    if v.contains("\\" + nom + "\\") or v.ends-with("\\" + nom) or v.contains("\\" + nom + " ") or v.contains("\\" + nom + "{") {
      r.insert("size", nom)
    }
  }
  let m = v.match(regex("\\\\color\\{([^}]*)\\}"))
  if m != none { r.insert("fill", m.captures.at(0)) }
  r
}

#let _cles-longueur = (
  "boxrule", "boxsep", "left", "right", "top", "bottom", "lefttitle", "righttitle",
  "toptitle", "bottomtitle", "titlerule", "arc", "width", "height",
)

/// Applique, dans l'ordre, des dictionnaires d'options tcolorbox (chaînes de lire-options ou valeurs
/// Typst) et renvoie un style complet. À appeler dans un `context`.
#let bf-resoudre-tcb(..couches) = {
  let s = (
    boxrule: 0pt, boxsep: 0pt, left: 0pt, right: 0pt, top: 0pt, bottom: 0pt,
    lefttitle: 0pt, righttitle: 0pt, toptitle: 0pt, bottomtitle: 0pt, titlerule: 0pt, arc: 0pt,
    colback: white, colframe: black, colbacktitle: none, coltitle: black, colupper: none,
    cadre: true, fond: true, titre-rempli: false,
    halign: "justify", halign-title: "justify", valign: "top",
    fonttitle: (:), fontupper: (:), title: none, width: auto, height: auto, multicolonne: 1,
    // false : le contenu n'est pas du texte courant (cases réponse…), pas de compensation de ligne
    compenser: true,
  )
  let appliquer-taille(s, nom) = {
    let t = _tailles-tcb.at(nom, default: _tailles-tcb.normal)
    for (k, v) in t { s.insert(k, v) }
    s + (lefttitle: t.left, righttitle: t.right, titlerule: t.boxrule, toptitle: 0pt, bottomtitle: 0pt)
  }
  let vider(s) = s + (
    boxrule: 0pt, boxsep: 0pt, left: 0pt, right: 0pt, top: 0pt, bottom: 0pt,
    lefttitle: 0pt, righttitle: 0pt, titlerule: 0pt, arc: 0pt, cadre: false, fond: false,
  )
  for couche in couches.pos() {
    let o = if type(couche) == str { lire-options(couche) } else { couche }
    for (cle, v) in o {
      let cle = cle.replace(" ", "-")
      if cle == "size" { s = appliquer-taille(s, v) }
      else if cle in ("blank", "blanker", "blankest") { s = vider(s); if cle == "blankest" { s.title = none } }
      else if cle in _cles-longueur {
        let l = if type(v) == str { longueur-latex(v, defaut: none) } else { v }
        if l != none {
          if cle == "boxrule" { s.titlerule = l }
          if cle == "left" { s.lefttitle = l }
          if cle == "right" { s.righttitle = l }
          s.insert(cle, l)
        }
      }
      else if cle in ("colback", "colframe", "coltitle", "colupper") { s.insert(cle, bf-couleur-tcb(v)) }
      else if cle == "coltext" { s.colupper = bf-couleur-tcb(v) }
      else if cle == "colbacktitle" { s.colbacktitle = bf-couleur-tcb(v); s.titre-rempli = true }
      else if cle == "title-filled" { s.titre-rempli = booleen-latex(v) }
      else if cle == "sharp-corners" { s.arc = 0pt }
      else if cle == "frame-hidden" { s.cadre = false }
      else if cle == "interior-hidden" { s.fond = false }
      else if cle == "opacityback" { if float(v) == 0 { s.fond = false } }
      else if cle in ("halign", "halign-upper") { s.halign = v }
      else if cle in ("valign", "valign-upper") { s.valign = v }
      else if cle == "center-upper" { s.halign = "center" }
      else if cle == "center-title" { s.halign-title = "center" }
      else if cle == "flushleft-title" or cle == "flush-left-title" { s.halign-title = "left" }
      else if cle == "halign-title" { s.halign-title = v }
      else if cle == "fonttitle" { s.fonttitle = bf-police-tcb(v) }
      else if cle == "fontupper" { s.fontupper = bf-police-tcb(v) }
      else if cle == "title" { s.title = if type(v) == str { if v == "" { [] } else { v } } else { v } }
      else if cle == "notitle" { s.title = none }
      else if cle == "raster-multicolumn" { s.multicolonne = int(v) }
      else if cle == "compenser" { s.compenser = booleen-latex(v) }
      // autres clés (enhanced, breakable, nobeforeafter, drop shadow…) : ignorées
    }
  }
  s
}

/// Réglages de texte (police tcolorbox résolue) appliqués à `corps`. À appeler dans un `context`.
#let bf-appliquer-police(p, corps) = {
  let reglages = (:)
  if "weight" in p { reglages.insert("weight", p.weight) }
  if "style" in p { reglages.insert("style", p.style) }
  if "size" in p { reglages.insert("size", taille-latex(p.size)) }
  if "fill" in p { reglages.insert("fill", bf-couleur-tcb(p.fill)) }
  if p.at("sans", default: false) { reglages.insert("font", ("Latin Modern Sans", "TeX Gyre Heros")) }
  text(..reglages, corps)
}

/// Alignement horizontal tcolorbox appliqué à un contenu.
#let bf-halign(mode, corps) = {
  if mode in ("left", "flush left", "flush-left", "raggedright") {
    set par(justify: false)
    align(left, corps)
  } else if mode in ("center", "flush center", "flush-center", "centering") {
    set par(justify: false)
    align(center, corps)
  } else if mode in ("right", "flush right", "flush-right", "raggedleft") {
    set par(justify: false)
    align(right, corps)
  } else {
    set par(justify: true)
    corps
  }
}

/// Dessin d'une boîte au style résolu `s`, de hauteur imposée ou naturelle. À appeler dans un `context`.
/// Le cadre est peint comme tcolorbox : aplat de colframe, puis intérieur colback par-dessus.
/// `texte` : compense les bords de ligne Typst (hauteur de capitale, ligne de base) pour retrouver
/// les boîtes TeX (hauteur d'ascendant en haut, profondeur de jambage en bas).
#let bf-boite(s, corps, hauteur: auto, texte: true) = {
  let m = bf-metriques()
  // compensation signée : les bords de ligne Typst peuvent dépasser l'encre (étai du modèle)
  let (haut-sup, bas-sup) = if texte and s.at("compenser", default: true) { (m.asc - m.haut, m.prof - m.desc) } else { (0pt, 0pt) }
  let r = s.boxrule
  let ext = if s.arc > 0pt { s.arc + r } else { 0pt }
  let fond-titre = if s.titre-rempli { s.colbacktitle } else { none }
  let partie-titre = if s.title != none {
    block(
      width: 100%,
      fill: fond-titre,
      radius: (top: s.arc),
      inset: (
        left: s.boxsep + s.lefttitle,
        right: s.boxsep + s.righttitle,
        top: s.boxsep + s.toptitle + haut-sup,
        bottom: s.boxsep + s.bottomtitle + bas-sup,
      ),
      above: 0pt,
      below: 0pt,
      {
        set text(fill: s.coltitle)
        bf-halign(s.halign-title, bf-appliquer-police(s.fonttitle, s.title))
      },
    )
  }
  let interieur(h) = block(
    width: 100%,
    height: if h == auto { auto } else { 100% },
    fill: if s.fond { s.colback } else { none },
    radius: if s.title != none { (bottom: s.arc) } else { s.arc },
    inset: (
      left: s.boxsep + s.left,
      right: s.boxsep + s.right,
      top: s.boxsep + s.top + haut-sup,
      bottom: s.boxsep + s.bottom + bas-sup,
    ),
    above: 0pt,
    below: 0pt,
    {
      let c = bf-avec-largeur(bf-halign(s.halign, bf-appliquer-police(s.fontupper, bf-sans-espace-initial(corps))))
      if s.colupper != none { c = text(fill: s.colupper, c) }
      let v = if s.valign in ("center", "centre") { horizon } else if s.valign == "bottom" { bottom } else { top }
      if h == auto { c } else { align(v, c) }
    },
  )
  // titre, filet de titre, intérieur : la dernière rangée prend la hauteur restante
  let reste = if hauteur == auto { auto } else { 1fr }
  block(
    width: 100%,
    height: hauteur,
    fill: if s.cadre { s.colframe } else { none },
    radius: ext,
    inset: r,
    above: 0pt,
    below: 0pt,
    if partie-titre == none {
      grid(rows: (reste,), interieur(hauteur))
    } else {
      grid(rows: (auto, s.titlerule, reste), partie-titre, [], interieur(hauteur))
    },
  )
}

/// Raster à hauteurs égales par rang. `elements` : tableau de (corps, style résolu).
/// À appeler dans un `context` ; `largeur` = largeur disponible.
#let bf-raster(elements, colonnes, largeur, ecart-col: ptl(5), ecart-lig: ptl(2), egales: true, valign: top) = {
  let lc = (largeur - (colonnes - 1) * ecart-col) / colonnes
  // rangs (les cellules multicolonnes passent au rang suivant si elles débordent)
  let rangs = ()
  let col = 0
  let rang = 0
  for (corps, s) in elements {
    let n = calc.min(s.multicolonne, colonnes)
    if col + n > colonnes { rang += 1; col = 0 }
    rangs.push(rang)
    col += n
    if col >= colonnes { rang += 1; col = 0 }
  }
  let largeur-cellule(s) = {
    let n = calc.min(s.multicolonne, colonnes)
    n * lc + (n - 1) * ecart-col
  }
  // Une boîte sans cadre, sans fond ni titre ne montre pas sa hauteur : dans une rangée de ce genre, seule la
  // place du contenu (valign) compte, et la grille la donne d'elle-même (cellules d'une rangée « auto »
  // alignées par `align`). On ne mesure donc que les rangées qui ont une boîte visible, et seulement si les
  // hauteurs doivent être égales : chaque mesure met le contenu en page une fois de plus.
  let visible(s) = (s.cadre and s.boxrule > 0pt) or s.fond or s.title != none
  let rangs-mesures = ()
  if egales {
    for (i, (corps, s)) in elements.enumerate() {
      if visible(s) and rangs.at(i) not in rangs-mesures { rangs-mesures.push(rangs.at(i)) }
    }
  }
  let maxima = (:)
  for (i, (corps, s)) in elements.enumerate() {
    if rangs.at(i) in rangs-mesures {
      let h = measure(bf-boite(s, corps), width: largeur-cellule(s)).height
      let k = str(rangs.at(i))
      maxima.insert(k, calc.max(maxima.at(k, default: 0pt), h))
    }
  }
  // placement explicite : une cellule qui ne tient pas dans la place restante du rang
  // laisse une case vide et passe au rang suivant
  let lignes = ()
  for (i, (corps, s)) in elements.enumerate() {
    let r = rangs.at(i)
    while lignes.len() <= r { lignes.push(()) }
    let mesure = r in rangs-mesures
    let place-v = if mesure or not egales { auto } else if s.valign in ("center", "centre") { horizon } else if s.valign == "bottom" { bottom } else { top }
    lignes.at(r).push(grid.cell(
      colspan: calc.min(s.multicolonne, colonnes),
      align: if place-v == auto { valign } else { place-v },
      bf-boite(s, corps, hauteur: if mesure { maxima.at(str(r)) } else { auto }),
    ))
  }
  // un bloc insécable par rang : un rang qui ne tient pas en bas de page passe à la page suivante
  // (une grille unique de cellules à hauteur imposée débordait sur le pied de page)
  lignes
    .enumerate()
    .filter(((k, l)) => l.len() > 0)
    .map(((k, l)) => block(
      width: 100%,
      breakable: false,
      above: if k == 0 { 0pt } else { ecart-lig },
      below: 0pt,
      grid(columns: (lc,) * colonnes, column-gutter: ecart-col, align: valign, ..l),
    ))
    .join()
}

// =====================================================================
// tcolorbox générique
// =====================================================================

/// \begin{tcolorbox}[options] corps [\tcblower bas] \end{tcolorbox}, \tcbox[options]{corps}
///   #tcolorbox(tcb: "colback=white, colframe=black, boxrule=1pt, nobeforeafter")[corps]
///   #tcolorbox(tcb: "…")[haut][bas]                (\tcblower : filet tireté de séparation)
/// Style de départ : tcolorbox standard de bfcours (bf-tcb-defaut). Clés d'espacement lues en plus
/// des clés de boîte : `nobeforeafter`, `before skip`, `after skip`, `width`, `hbox`, `on line`.
#let tcolorbox(tcb: none, ..args) = context {
  let pos = args.pos()
  let o = lire-options(tcb) + args.named()
  let s = bf-resoudre-tcb(bf-tcb-defaut, o)
  let m = bf-metriques()
  let haut = pos.at(0, default: [])
  let bas = pos.at(1, default: none)
  let milieu = longueur-latex(o.at("middle", default: none), defaut: 2mm)
  let contenu = if bas == none { haut } else {
    let debord = s.left + s.boxsep
    [#haut
      #block(above: milieu, below: milieu, move(dx: -debord, line(
        length: 100% + 2 * debord,
        stroke: (paint: s.colframe, thickness: 0.4pt, dash: "dashed"),
      )))
      #bas]
  }
  let en-ligne = "on-line" in o
  let naturelle = "hbox" in o or en-ligne
  let largeur = if naturelle {
    measure(haut).width + 2 * (s.boxrule + s.boxsep) + s.left + s.right
  } else if s.width == auto { 100% } else { s.width }
  let dessin = bf-boite(s, contenu)
  if en-ligne { return box(width: largeur, dessin) }
  let e = if "nobeforeafter" in o {
    // boîte posée comme une ligne haute : \lineskip au-dessus, rien au-dessous
    (above: ptl(1) + m.prof - m.desc, below: m.asc - m.haut)
  } else { bf-espacement-tcb(m) }
  let avant = longueur-latex(o.at("before-skip", default: none), defaut: e.above)
  let apres = longueur-latex(o.at("after-skip", default: none), defaut: e.below)
  block(width: largeur, above: avant, below: apres, breakable: false, dessin)
}

/// \tcbox[options]{corps} : boîte en ligne à la largeur du contenu.
#let tcbox(tcb: none, ..args) = tcolorbox(tcb: lire-options(tcb) + (on-line: true), ..args)

// =====================================================================
// tcbraster
// =====================================================================

#let _options-raster(o) = {
  let r = (colonnes: 2, largeur: 100%, ecart-col: 2mm, ecart-lig: 2mm, avant: 2mm, apres: 2mm, gauche: 0pt, egales: false, valign: horizon)
  for (cle, v) in o {
    let cle = cle.replace(" ", "-")
    let l = if type(v) == str { longueur-latex(v, defaut: none) } else { v }
    if cle == "raster-columns" { r.colonnes = int(v) }
    else if cle == "raster-width" and l != none { r.largeur = l }
    else if cle == "raster-column-skip" and l != none { r.ecart-col = l }
    else if cle == "raster-row-skip" and l != none { r.ecart-lig = l }
    else if cle == "raster-before-skip" and l != none { r.avant = l }
    else if cle == "raster-after-skip" and l != none { r.apres = l }
    else if cle == "raster-equal-skip" and l != none { r += (avant: l, apres: l, ecart-col: l, ecart-lig: l) }
    else if cle == "raster-left-skip" and l != none { r.gauche = l }
    else if cle == "raster-equal-height" { r.egales = v != "none" }
    else if cle == "raster-valign" { r.valign = if v == "top" { top } else if v == "bottom" { bottom } else { horizon } }
  }
  r
}

#let _est-cle-raster(cle) = cle.starts-with("raster")

/// \begin{tcbraster}[options] \begin{tcolorbox}[opts] … \end{tcolorbox} … \end{tcbraster}
///   #tcbraster(tcb: "raster columns=3, raster equal height", tcbitem(tcb: "blankest, raster multicolumn=2")[…], [..])
/// Les options non « raster » de `tcb` s'appliquent à toutes les boîtes (comme en LaTeX) ;
/// `every-box` = « raster every box/.style ». Style de départ : tcolorbox standard de bfcours.
#let tcbraster(tcb: none, every-box: none, ..boites) = context {
  let o = lire-options(tcb)
  let r = _options-raster(o)
  let communes = o.pairs().filter(((k, v)) => not _est-cle-raster(k)).to-dict()
  let elements = boites
    .pos()
    .map(it => {
      let (corps, options) = bf-lire-item(it)
      (corps, bf-resoudre-tcb(bf-tcb-defaut, communes, lire-options(every-box), options))
    })
  block(
    width: 100%,
    above: r.avant,
    below: r.apres,
    pad(left: r.gauche, layout(taille => {
      let l = if type(r.largeur) == ratio { r.largeur * taille.width } else if type(r.largeur) == relative {
        r.largeur.ratio * taille.width + r.largeur.length
      } else { r.largeur }
      bf-raster(elements, r.colonnes, l, ecart-col: r.ecart-col, ecart-lig: r.ecart-lig, egales: r.egales, valign: r.valign)
    })),
  )
}
