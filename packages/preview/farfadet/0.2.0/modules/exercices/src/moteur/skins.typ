// skins.typ (farfadet-exo) — thèmes (skins) : en-têtes d'exercice et en-têtes de correction
// (bouyachakka, default, pooja, rikid, griba, objiva, exobac, exobrevet, exolombards).
//
// Chaque thème fournit trois en-têtes, selon `exo-header` :
//   "tcolorbox" : bandeau sur sa propre ligne (défaut) ;
//   "tcbox"     : étiquette compacte EN LIGNE, l'énoncé suit sur la même ligne ;
//   "none"      : titre de la boîte (`exo title style`), proche du bandeau.
// et un en-tête de correction (\rdexocorrection).
//
// Un en-tête reçoit `info` (dictionnaire préparé par exo.typ) :
//   n, id, label, display-numexo, display-score, display-level, display-exotitle, titre, grille (la grille
//   MI / MF / MS / TBM d'EXOEVAL, none pour EXO), score, niveau, score-label, tags, montrer-tags, cible, police-titre, couleur-titre,
//   header-skip, c (couleurs résolues du thème), skin, exo-header, extra (dictionnaire propre au thème).
// Il renvoie un dictionnaire : (bloc: contenu en pleine largeur) ou (ligne: contenu en ligne),
// plus `tags` (bloc d'étiquettes sous le bandeau) ou `marge` (étiquettes dans la marge gauche).
//
// Un thème peut aussi fournir, facultatives, `cadre` et `cadre-correction` : fonctions `(info, contenu) => contenu`
// qui habillent l'exercice entier / chaque bloc de correction. Les thèmes intégrés n'en ont pas : on les pose par
// la clé `cadre` de `setrdexo` ou d'`exo` (voir exo.typ). `info` reçoit alors en plus `couleur`, `fond`, `breakable`
// et `correction`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "../../../zones-reponse/lib.typ": interne as _crep
#import _crep: tccrep
#import "reglages.typ": bf-exo-sans, bf-exo-taille-sans, bf-exo-couleur, bf-exo-police, bf-divers-registre
#import "etoiles.typ": bf-rdexostars
#import "listes.typ": bf-rdexotikzlist

#let _sans = bf-exo-sans
#let _taille-sans = bf-exo-taille-sans

// =====================================================================
// Briques communes
// =====================================================================

/// Largeur de la partie gauche de l'en-tête bouyachakka (minipage de tcolorbox : \textwidth y vaut
/// cette largeur). `droite` : largeur de la partie droite (righthand width). À appeler dans un `context`.
#let bf-largeur-entete(droite: 2.8cm) = bf-largeur-courante() - droite - ptl(6)

/// \ding{110} (ZapfDingbats a110 : chasse 0,761 em, carré plein de 0,691 em posé sur la ligne de base).
/// `couleur` : `auto` = couleur du texte courant (un glyphe de LaTeX prend la couleur du titre).
#let bf-ding110(taille, couleur: auto) = box(width: 0.761 * taille, context {
  let f = if couleur == auto { text.fill } else { couleur }
  place(bottom + left, dx: 0.035 * taille, rect(width: 0.691 * taille, height: 0.691 * taille, fill: f, stroke: none))
})

/// \ding{113} (ZapfDingbats a113 ❑ : carré blanc à ombre portée en bas à droite, chasse 0,761 em).
/// `couleur` : `auto` = couleur du texte courant.
#let bf-ding113(taille, couleur: auto) = box(width: 0.761 * taille, context {
  let couleur = if couleur == auto { text.fill } else { couleur }
  let c = 0.62 * taille
  let o = 0.07 * taille
  place(bottom + left, dx: 0.035 * taille + o, dy: 0pt, rect(width: c, height: c, fill: couleur, stroke: none))
  place(bottom + left, dx: 0.035 * taille, dy: -o, rect(width: c, height: c, fill: white, stroke: 0.045 * taille + couleur))
})

/// Couleur du carré devant « Exercice n » (clé `square-color` du thème ; `auto` : texte du bandeau).
#let _carre(c) = c.at("square-color", default: auto)

/// Montant invisible \vphantom{Ép} de la police d'en-tête. À appeler dans un `context`.
#let _strut(t) = {
  let h = measure(text(font: _sans, weight: "bold", size: t, top-edge: "bounds", bottom-edge: "baseline", [Ép])).height
  let d = measure(text(font: _sans, weight: "bold", size: t, top-edge: "baseline", bottom-edge: "bounds", [Ép])).height
  box(width: 0pt, height: h + d, baseline: d)
}

/// « Exercice n » (\thelabel\thenumexo*[~]).
#let _etiquette-num(info) = [#info.label#if info.display-numexo [~#info.n]]

/// Lien vers la solution (\rdexoEnonceLabel), sans changer la couleur du texte.
#let _lien(info, c, couleur: auto) = {
  if info.cible == none { return c }
  let couleur = if couleur == auto { info.c.fg-color } else { couleur }
  link(info.cible, text(fill: couleur, c))
}

/// Le titre est-il affiché ?
#let _titre-visible(info) = info.display-exotitle and info.titre != none and info.titre != [] and info.titre != ""

/// Contenu de la zone « titre » : le titre (s'il est affiché) et, pour EXOEVAL, la grille MI / MF / MS / TBM
/// (`info.grille`), centrée dans l'espace restant. Les thèmes qui n'ont pas de place dédiée à la grille
/// (tous sauf bouyachakka en `tcolorbox`) la rangent à la suite du titre.
#let _contenu-titre(info) = {
  let t = if _titre-visible(info) { info.titre }
  // la grille est centrée sur la hauteur des capitales du titre (son milieu à 0,35 em au-dessus de la ligne
  // de base), pour que le libellé et le titre soient au milieu de la grille et non collés en bas
  if info.grille == none { t } else {
    [#t#h(1fr)#box(baseline: 50% - 0.35em, inset: (y: ptl(2)), info.grille)#h(1fr)]
  }
}

/// Titre (et grille) dans la police et la couleur de titre (\theExotitle).
#let _titre(info) = text(..info.police-titre, fill: info.couleur-titre, _contenu-titre(info))

/// La zone « titre » a-t-elle quelque chose à montrer (titre affiché ou grille d'évaluation) ?
#let _a-titre(info) = _titre-visible(info) or info.grille != none

/// \theScore : « 3 points », « 1 point » (score label, pluriel au-delà de 1).
#let bf-the-score(score, score-label) = [#bf-nombre(score)~#if score > 1 { score-label.at(1) } else { score-label.at(0) }]

/// Étoiles de niveau aux couleurs du thème (\rdexostars[star color=…, …]{\thelevel}{3}).
/// `em` : quad de la police d'en-tête (Latin Modern Sans gras étendu : 1,0958 × taille).
#let _etoiles(info, t, ..cles) = bf-rdexostars(
  info.niveau,
  3,
  em: 1.0958 * t,
  star-color: info.c.star-fg-color,
  star-background: info.c.star-bg-color,
  line-color: info.c.star-line-color,
  ..cles,
)

/// Pastille de score (`score style` : fond score bg, texte score fg, \sffamily\bfseries\tiny, boxsep 2 pt).
#let _pastille-score(info, contour: false, radius: 1mm) = {
  let c = info.c
  let t = text(font: _sans, weight: "bold", size: _taille-sans("tiny"), fill: c.score-fg-color, top-edge: "bounds", bottom-edge: "bounds", bf-the-score(info.score, info.score-label))
  box(
    fill: if contour { none } else { c.score-bg-color },
    stroke: if contour { ptl(0.4) + c.score-fg-color } else { none },
    radius: radius,
    inset: ptl(2),
    baseline: ptl(2),
    t,
  )
}

/// Une étiquette (`tag style` du thème). À appeler dans un `context`.
#let bf-exo-etiquette(t, c, skin: "bouyachakka") = {
  if skin in ("exobac", "exobrevet") {
    // \scriptsize\itshape, coins vifs, boxsep 2,5 pt
    let taille = taille-latex("scriptsize")
    return box(fill: c.tags-bg-color, inset: ptl(2.5), text(size: taille, style: "italic", fill: c.tags-fg-color, t))
  }
  if skin == "exolombards" {
    let taille = taille-latex("scriptsize")
    return box(inset: ptl(2), text(size: taille, style: "italic", t))
  }
  // fond black!70, texte blanc \sffamily\bfseries\tiny, boxsep 3 pt, coins 1 mm, \vphantom{Éy}
  let taille = _taille-sans("tiny")
  let strut = box(width: 0pt, height: 1.09 * taille, baseline: 0.21 * taille)
  box(
    fill: c.tags-bg-color,
    radius: 1mm,
    inset: ptl(3),
    text(font: _sans, size: taille, weight: "bold", fill: c.tags-fg-color, top-edge: "baseline", bottom-edge: "baseline", [#strut#t]),
  )
}

/// \thetags[max cols] : étiquettes en matrice (0 = autant de colonnes que la ligne en tient).
#let bf-thetags(tags, c, skin: "bouyachakka", max-cols: 0) = bf-rdexotikzlist(
  tags,
  max-cols: max-cols,
  macro: t => bf-exo-etiquette(t, c, skin: skin),
)

/// Bloc d'étiquettes sous le bandeau (`tags tcolorbox` : blankest, halign=right, before skip=1ex).
#let _bloc-tags(info, avant: 0.5em) = if info.montrer-tags {
  block(width: 100%, above: avant, below: 0pt, align(right, bf-thetags(info.tags, info.c, skin: info.skin)))
}

/// Étiquettes dans la marge gauche, en colonne, 1 em à gauche de l'en-tête (\thetags[1]).
#let _marge-tags(info) = if info.montrer-tags {
  bf-thetags(info.tags, info.c, skin: info.skin, max-cols: 1)
}

// =====================================================================
// bouyachakka (skin de bfcours) — défaut des documents bfcours
// =====================================================================

/// En-tête « tcolorbox » : bandeau gris arrondi à droite, partie droite de 2,8 cm (score « ▢ / n »).
#let _bouyachakka-tcolorbox(info) = {
  let c = info.c
  let droite-l = if c.righthand-width == auto { 2.8cm } else { c.righthand-width }
  let police-corps = bf-lire(bf-police-p).at("texte", default: none)
  let police-corps = if police-corps == none { text.font } else { police-corps }
  let t12 = _taille-sans("normalsize")
  // partie gauche : \vphantom{\'Ep}■~Exercice n\theExotitle*[~--~] \hfill étoiles~\mbox{}
  let etiquette = _lien(info, _etiquette-num(info))
  let etoiles = if info.display-score and info.display-level { [#_etoiles(info, t12)~] }
  let titre-rendu = if _titre-visible(info) {
    let t = text(..info.police-titre, fill: info.couleur-titre, info.titre)
    // titre court (minipage[t]{0,5\textwidth}) tant que la place le permet : une boîte Typst s'aligne
    // déjà sur sa première ligne de base ; avec la grille d'EXOEVAL, le titre passe à la ligne dans la
    // colonne qui lui reste (jamais sous la grille)
    if info.grille != none { [~–~#t] } else {
      // Bandeau étroit (colonne, boîte basse) : la boîte de largeur fixe ne tenait plus après
      // « ■ Exercice n – » et passait seule à la ligne, laissant le tiret en bout de ligne. Elle est
      // ramenée à la place restante (2 cm au moins) ; à pleine largeur, rien ne change. La largeur
      // est celle que connaît `bf-largeur-courante` (un `layout` ici rendrait le document instable).
      let l = bf-largeur-entete(droite: droite-l)
      // mesure sans le lien : un lien vers la solution rend la mesure instable d'une passe à l'autre
      let avant = measure([#bf-ding110(t12, couleur: _carre(c))~#_etiquette-num(info)~–~]).width
      let apres = if etoiles == none { 0pt } else { measure(etoiles).width }
      // (si même ainsi la place manque, ce sont les étoiles qui passent à la ligne, pas le titre)
      let w = calc.min(0.5 * l, calc.max(2cm, l - avant - apres - 1em.to-absolute()))
      [~–~#box(width: w, t)]
    }
  }
  let gauche = {
    set par(justify: false)
    let debut = [#_strut(t12)#bf-ding110(t12, couleur: _carre(c))~#etiquette#titre-rendu]
    if info.grille == none {
      [#debut#h(1fr)#etoiles]
    } else {
      // EXOEVAL : titre | grille MI MF MS TBM | étoiles ; trois colonnes centrées sur le même axe
      // horizontal (le titre, la grille et le cartouche de points ont le même centre vertical), la
      // grille et les étoiles gardent leur largeur, le titre prend le reste et passe à la ligne si
      // besoin. La grille a sa propre marge verticale (elle ne touche ni le haut ni le bas du bandeau).
      // Si la place manque même pour un titre sur deux lignes, la grille et les étoiles passent sous le titre.
      let grille = box(inset: (y: ptl(2)), info.grille)
      let ecart = 0.8em.to-absolute()
      let droite-bloc = if etoiles == none { grille } else { grid(columns: 2, column-gutter: ecart, align: horizon, grille, etoiles) }
      layout(taille => {
        let l-droite = measure(droite-bloc).width
        if l-droite + ecart + 3cm <= taille.width {
          grid(
            columns: if etoiles == none { (1fr, auto) } else { (1fr, auto, auto) },
            column-gutter: ecart,
            align: left + horizon,
            debut, grille, ..if etoiles != none { (etoiles,) },
          )
        } else {
          stack(dir: ttb, spacing: ptl(2), debut, align(right, droite-bloc))
        }
      })
    }
  }
  // partie droite (centrée) : \scoreRD = \tccrep[seyes=false]{1.2cm}{}{\Large /} \large{\num{\points}}
  let droite = if info.display-score {
    // police de la partie basse : \sffamily\bfseries\scriptsize (d'où la petite espace avant le nombre)
    [#tccrep(seyes: false, 1.2cm)[]#text(size: _taille-sans("Large"))[/]#text(size: _taille-sans("scriptsize"))[ ]#text(font: police-corps, weight: "regular", size: taille-latex("large"), bf-nombre(info.score))]
  } else if info.display-level {
    // rdexo trace ces étoiles sans contour (line width=0pt) : les étoiles vides, blanches sur le gris
    // clair du bandeau, ne se voyaient presque pas. Elles gardent le contour (star-line-color, 0,6 pt)
    // des étoiles de la partie gauche (score et niveau affichés ensemble).
    _etoiles(info, t12)
  }
  let fond-droite = if c.score-bg-color == c.bg-color { none } else { c.score-bg-color }
  block(
    width: 100%,
    fill: c.bg-color,
    radius: (right: c.arc),
    above: 0pt,
    below: 0pt,
    breakable: false,
    clip: fond-droite != none,
    {
      set text(font: _sans, weight: "bold", size: t12, fill: c.fg-color)
      grid(
        columns: (ptl(3), 1fr, droite-l, ptl(3)),
        inset: (x: 0pt, y: ptl(3)),
        align: (left + horizon, left + horizon, center + horizon, left),
        fill: (x, y) => if x >= 2 { fond-droite } else { none },
        [], gauche, align(center, text(fill: c.score-fg-color, droite)), [],
      )
    },
  )
}

/// En-tête « tcbox » de bouyachakka : étiquette arrondie à droite de 7 cm (score et niveau) ou 6 cm,
/// puis « titre » en italique ; l'énoncé suit sur la même ligne.
#let _bouyachakka-tcbox(info) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let largeur = if info.display-score and info.display-level { 7cm } else { 6cm }
  let contenu = text(font: _sans, weight: "bold", size: t12, fill: c.fg-color, [#_strut(t12)#bf-ding110(t12, couleur: _carre(c))~#_lien(info, _etiquette-num(info))])
  let a-droite = info.display-score or info.display-level
  let deux = info.display-level and info.display-score
  let etoiles-l = if deux { measure(_etoiles(info, t12)).width } else { 0pt }
  let largeur = calc.max(largeur, measure(contenu).width + etoiles-l + (if deux { 2.8cm } else if a-droite { 1.8cm } else { 0pt }) + (0.6em).to-absolute())
  let boite = box(width: largeur, fill: c.bg-color, radius: (right: c.arc), inset: ptl(3), clip: true, {
    contenu
    // score and level : 1,8 cm à droite au fond score bg, étoiles ancrées 2,8 cm avant le bord droit.
    // Le nœud du score est vide en LaTeX (oubli) : on y écrit le score (\sffamily\bfseries\scriptsize).
    // Sans score ni niveau, pas de bloc (il n'aurait rien à porter).
    if a-droite {
      place(right + horizon, dx: ptl(3), box(width: 1.8cm, height: 100% + ptl(6), fill: c.score-bg-color, align(center + horizon,
        if info.display-score { text(font: _sans, weight: "bold", size: _taille-sans("scriptsize"), fill: c.score-fg-color, bf-the-score(info.score, info.score-label)) }
        else { _etoiles(info, t12, line-width: 0pt) })))
    }
    if info.display-level and info.display-score {
      place(right + horizon, dx: -2.8cm + ptl(6), _etoiles(info, t12))
    }
  })
  let titre = if _a-titre(info) [~#text(..info.police-titre, style: "italic", fill: info.couleur-titre)[« #_contenu-titre(info) »]]
  (ligne: [#boite#titre], marge: _marge-tags(info))
}

/// En-tête de correction de bouyachakka : « Solution de l'Exercice n » (étiquette grise, numéro sur
/// fond blanc, filet gris de 0,6 pt sous le titre) — couleurs du thème griba (lower bg color).
#let _bouyachakka-correction(corr) = {
  let gris = corr.c.lower-bg-color
  let tl = _taille-sans("large")
  set text(font: _sans, weight: "bold", size: tl)
  // police explicite : `measure` ignore le `set text` qui précède dans ce même bloc
  let chiffre = text(font: _sans, weight: "bold", size: tl, fill: gris, top-edge: "bounds", bottom-edge: "bounds", str(corr.n))
  let mc = measure(chiffre)
  // une boîte qui contient du texte s'aligne sur la ligne de base de ce texte (pas de `baseline`)
  let numero = box(
    width: mc.width + ptl(4),
    height: mc.height + ptl(4),
    fill: white,
    radius: (right: ptl(2)),
    align(center + horizon, chiffre),
  )
  let lib = [Solution de l'#corr.label~#numero]
  let lib = if corr.cible != none { link(corr.cible, lib) } else { lib }
  let etiquette = box(
    fill: gris,
    radius: (right: 1mm),
    inset: (x: ptl(4), y: ptl(2)),
    text(fill: white, top-edge: "bounds", bottom-edge: "baseline", lib),
  )
  // bottomtitle = 1 pt, puis le filet de titre (0,6 pt) ; l'étiquette est isolée dans un bloc
  // pour que l'espacement des paragraphes ne s'y ajoute pas
  block(width: 100%, above: 0pt, below: 0pt, {
    block(above: 0pt, below: 0pt, etiquette)
    v(ptl(1), weak: false)
    block(above: 0pt, below: 0pt, line(length: 100%, stroke: ptl(0.6) + gris))
  })
}

// =====================================================================
// default (rdexo)
// =====================================================================

/// Droite de l'en-tête default/rikid : étoiles puis pastille de score, ancrées au bord droit.
#let _droite-score-niveau(info, t, contour: false, radius: 1mm) = {
  let parts = ()
  if info.display-level { parts.push(_etoiles(info, t)) }
  if info.display-score { parts.push(_pastille-score(info, contour: contour, radius: radius)) }
  parts.join(h(ptl(4)))
}

#let _default-tcolorbox(info, carre: auto) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let carre = if carre == auto { bf-ding113(t12, couleur: _carre(c)) } else { carre }
  let titre = if _a-titre(info) [~–~#_titre(info)]
  let bloc = block(width: 100%, fill: c.bg-color, stroke: ptl(0.8) + c.frame-color, radius: c.arc, inset: ptl(3), above: 0pt, below: 0pt, breakable: false, {
    set text(font: _sans, weight: "bold", size: t12, fill: c.fg-color)
    set par(justify: false)
    grid(columns: (1fr, auto), align: horizon, column-gutter: ptl(4),
      [#_strut(t12)#carre~#_lien(info, _etiquette-num(info))#titre],
      _droite-score-niveau(info, t12),
    )
  })
  (bloc: bloc, tags: _bloc-tags(info))
}

/// Largeur d'une étiquette `tcbox` : la largeur LaTeX (tcbox width=forced left), élargie si le contenu
/// gauche et la partie droite ne tiennent pas côte à côte (police plus grande que celle de rdexo).
/// À appeler dans un `context`.
#let _largeur-tcbox(largeur, gauche, droite, inset, ecart: auto) = {
  let lg = measure(gauche).width
  let ld = if droite == none { 0pt } else { measure(droite).width }
  let ecart = if ecart == auto { (0.6em).to-absolute() } else { ecart }
  let besoin = lg + ld + 2 * inset + if droite == none { ptl(4) } else { ecart }
  calc.max(largeur, besoin)
}

#let _default-tcbox(info) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let largeur = if info.display-score and info.display-level { 5.2cm } else if info.display-score or info.display-level { 4cm } else { 2.8cm }
  let gauche = text(font: _sans, weight: "bold", size: t12, fill: c.fg-color, [#_strut(t12)#bf-ding113(t12, couleur: _carre(c))~#_lien(info, _etiquette-num(info))])
  let droite = _droite-score-niveau(info, t12)
  let largeur = _largeur-tcbox(largeur, gauche, droite, ptl(3) + ptl(0.8))
  let boite = box(width: largeur, fill: c.bg-color, stroke: ptl(0.8) + c.frame-color, radius: c.arc, inset: ptl(3), baseline: ptl(3), {
    gauche
    if droite != none { place(right + horizon, droite) }
  })
  let titre = if _a-titre(info) [~#text(..info.police-titre, style: "italic", fill: info.couleur-titre)[« #_contenu-titre(info) »]]
  (ligne: [#boite#titre], marge: _marge-tags(info))
}

/// `exo header=none` : le titre de la boîte (bande au fond bg color, sans cadre), score et niveau à droite.
#let _default-none(info, carre: auto) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let carre = if carre == auto { bf-ding113(t12, couleur: _carre(c)) } else { carre }
  let titre = if _a-titre(info) [~–~#_titre(info)]
  let bloc = block(width: 100%, fill: c.bg-color, inset: ptl(3), above: 0pt, below: 0pt, breakable: false, {
    set text(font: _sans, weight: "bold", size: t12, fill: c.fg-color)
    set par(justify: false)
    grid(columns: (1fr, auto), align: horizon, column-gutter: ptl(4),
      [#_strut(t12)#carre~#_lien(info, _etiquette-num(info))#titre],
      _droite-score-niveau(info, t12),
    )
  })
  (bloc: bloc, tags: _bloc-tags(info))
}

/// En-tête de correction default/pooja : « ❑ Exercice n : » en \sffamily\footnotesize, filet de 0,6 pt.
#let _default-correction(corr, carre: auto) = {
  let t = _taille-sans("footnotesize")
  let carre = if carre == auto { bf-ding113(t) } else { carre }
  let lib = text(font: _sans, size: t, fill: black, [#carre~#corr.label~#corr.n~:])
  let lib = if corr.cible != none { link(corr.cible, lib) } else { lib }
  block(width: 100%, above: 0pt, below: 0pt, {
    block(above: 0pt, below: 0pt, lib)
    v(ptl(1), weak: false)
    block(above: 0pt, below: 0pt, line(length: 100%, stroke: ptl(0.6) + black))
  })
}

// =====================================================================
// pooja (rdexo)
// =====================================================================

#let _pooja-tcolorbox(info) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let droite-l = if c.righthand-width == auto { 1.8cm } else { c.righthand-width }
  let titre = if _a-titre(info) [~–~#_titre(info)]
  let etoiles-gauche = if info.display-score and info.display-level { [#_etoiles(info, t12, raise: -ptl(1))~] }
  let droite = if info.display-score {
    text(font: _sans, weight: "bold", size: _taille-sans("scriptsize"), fill: c.score-fg-color, bf-the-score(info.score, info.score-label))
  } else if info.display-level { _etoiles(info, t12, line-width: 0pt) }
  let bloc = block(width: 100%, radius: (right: c.arc), clip: true, above: 0pt, below: 0pt, breakable: false, {
    set text(font: _sans, weight: "bold", size: t12, fill: c.fg-color)
    set par(justify: false)
    // ni score ni niveau : pas de partie droite (elle resterait un cartouche noir vide)
    let droite-l = if droite == none { 0pt } else { droite-l }
    grid(columns: (1fr, droite-l), inset: (x, y) => if x == 1 and droite == none { 0pt } else { ptl(3) }, align: (left + horizon, center + horizon),
      fill: (x, y) => if x == 0 { c.bg-color } else { c.score-bg-color },
      [#_strut(t12)#bf-ding110(t12, couleur: _carre(c))~#_lien(info, _etiquette-num(info))#titre#h(1fr)#etoiles-gauche],
      droite,
    )
  })
  (bloc: bloc, tags: _bloc-tags(info))
}

#let _pooja-tcbox(info) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let largeur = if info.display-score and info.display-level { 6cm } else { 5cm }
  let gauche = text(font: _sans, weight: "bold", size: t12, fill: c.fg-color, [#_strut(t12)#bf-ding110(t12, couleur: _carre(c))~#_lien(info, _etiquette-num(info))])
  // partie droite : 1,8 cm au fond score bg (score, ou étoiles seules), étoiles avant elle si les deux
  let a-droite = info.display-score or info.display-level
  let droite-l = if a-droite { 1.8cm } else { 0pt }
  let etoiles-l = if info.display-score and info.display-level { measure(_etoiles(info, t12)).width + ptl(6) } else { 0pt }
  let largeur = calc.max(largeur, measure(gauche).width + etoiles-l + droite-l + ptl(6) + (0.6em).to-absolute())
  let boite = box(width: largeur, fill: c.bg-color, radius: (right: c.arc), inset: ptl(3), clip: true, baseline: ptl(3), {
    gauche
    if a-droite { place(right + horizon, dx: ptl(3), box(width: 1.8cm, height: 100% + ptl(6), fill: c.score-bg-color, align(center + horizon,
      if info.display-score { text(font: _sans, weight: "bold", size: _taille-sans("scriptsize"), fill: c.score-fg-color, bf-the-score(info.score, info.score-label)) }
      else if info.display-level { _etoiles(info, t12, line-width: 0pt) }))) }
    if info.display-score and info.display-level {
      place(right + horizon, dx: -1.8cm + ptl(3) - ptl(3), _etoiles(info, t12))
    }
  })
  let titre = if _a-titre(info) [~#text(..info.police-titre, style: "italic", fill: info.couleur-titre)[« #_contenu-titre(info) »]]
  (ligne: [#boite#titre], marge: _marge-tags(info))
}

// =====================================================================
// rikid (rdexo)
// =====================================================================

/// Numéro dans un carré arrondi (header tcbox de rikid : fond bg color, 0,6 cm, ombre floue).
#let _rikid-numero(info, contenu, fond: auto) = {
  let c = info.c
  let fond = if fond == auto { c.bg-color } else { fond }
  let t12 = _taille-sans("normalsize")
  let boite = box(width: 0.6cm, fill: fond, radius: c.arc, inset: (y: ptl(2)),
    align(center, text(font: _sans, weight: "bold", size: t12, fill: c.fg-color, top-edge: "bounds", bottom-edge: "bounds", contenu)))
  let m = measure(boite)
  box(width: m.width, height: m.height, {
    // fuzzy shadow={0.5ex}{-0.5ex}{0mm}{0.075mm}{black}
    place(top + left, dx: 0.25em, dy: 0.25em, box(width: m.width, height: m.height, radius: c.arc, fill: black.transparentize(65%)))
    place(top + left, boite)
  })
}

/// Bande à dégradé (couleur!10 → blanc) qui commence à `debut` du bord gauche.
#let _rikid-bande(couleur, debut, corps, avant: 3.5em) = block(width: 100%, above: 0pt, below: 0pt, breakable: false,
  pad(left: debut, block(width: 100%, above: 0pt, below: 0pt, fill: gradient.linear(xmix(couleur, 10), white),
    inset: (left: avant - debut), corps)))

#let _rikid-tcolorbox(info) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let numero = _rikid-numero(info, if info.display-numexo { str(info.n) } else { hide[0] })
  let titre = if _a-titre(info) { _titre(info) }
  let bloc = block(width: 100%, above: 0pt, below: 0pt, breakable: false, {
    let interieur = {
      set text(font: _sans, weight: "bold", size: t12)
      set par(justify: false)
      grid(columns: (1fr, auto), align: horizon, column-gutter: ptl(4),
        [#_strut(t12)#titre],
        _droite-score-niveau(info, t12, contour: true, radius: 0pt),
      )
    }
    _rikid-bande(c.bg-color, 2.75em, interieur)
    place(left + horizon, _lien(info, numero))
  })
  (bloc: bloc, tags: _bloc-tags(info))
}

#let _rikid-tcbox(info) = {
  let t12 = _taille-sans("normalsize")
  let numero = _lien(info, _rikid-numero(info, if info.display-numexo { str(info.n) } else { hide[0] }))
  let etoiles = if info.display-level [#h(0.75em)#_etoiles(info, t12, raise: -ptl(1.5))]
  let score = if info.display-score [#h(0.75em)#_pastille-score(info, contour: true, radius: 0pt)]
  let titre = if _a-titre(info) [#h(0.75em)#text(..info.police-titre, style: "italic", fill: info.couleur-titre)[« #_contenu-titre(info) »]]
  (ligne: [#box(baseline: 30%, numero)#etoiles#score#titre], marge: _marge-tags(info))
}

#let _rikid-correction(corr) = {
  let c = corr.c
  let t = _taille-sans("footnotesize")
  let numero = _rikid-numero((c: c + (fg-color: white)), str(corr.n), fond: c.lower-bg-color)
  block(width: 100%, above: 0pt, below: ptl(5), breakable: false, {
    _rikid-bande(c.lower-bg-color, 3em, text(font: _sans, weight: "bold", size: t, [#_strut(t)]))
    place(left + horizon, if corr.cible != none { link(corr.cible, numero) } else { numero })
  })
}

// =====================================================================
// griba (rdexo)
// =====================================================================

/// « Exercice ⟦n⟧ » : étiquette (fond bg, texte fg) et numéro inversé (fond fg, texte bg, coins 2 pt).
#let _griba-label(info, fond: auto, chiffre: auto, boxsep: 0pt) = {
  let c = info.c
  let fond = if fond == auto { c.bg-color } else { fond }
  let chiffre = if chiffre == auto { c.bg-color } else { chiffre }
  let t = _taille-sans("normalsize")
  let num = if info.display-numexo [~#box(fill: c.fg-color, radius: (right: ptl(2)), inset: ptl(1), text(fill: chiffre, top-edge: "bounds", bottom-edge: "bounds", str(info.n)))]
  box(fill: fond, radius: (right: 1mm), inset: (x: ptl(2) + boxsep, y: boxsep), baseline: boxsep,
    text(font: _sans, weight: "bold", size: t, fill: c.fg-color, top-edge: "cap-height", bottom-edge: "baseline", [#info.label#num]))
}

#let _griba-tcolorbox(info) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let etoiles = if info.display-level [~#_etoiles(info, t12, raise: -ptl(1))]
  let titre = if _a-titre(info) { _titre(info) }
  let score = if info.display-score [#h(0.75em)#box(baseline: -ptl(3) + ptl(2), _pastille-score(info))]
  let bloc = block(width: 100%, stroke: (bottom: ptl(1) + c.frame-color), inset: (y: ptl(1.5)), above: 0pt, below: 0pt, breakable: false, {
    set text(font: _sans, weight: "bold", size: t12)
    set par(justify: false)
    [#_lien(info, _griba-label(info))#etoiles#h(1fr)#titre#score]
  })
  (bloc: bloc, tags: _bloc-tags(info))
}

#let _griba-tcbox(info) = {
  let t12 = _taille-sans("normalsize")
  let etoiles = if info.display-level [#h(0.5em)#_etoiles(info, t12, raise: -ptl(3.5), display-mode: "vertical", scale: 0.5)]
  let score = if info.display-score [#h(0.5em)#_pastille-score(info)]
  let titre = if _a-titre(info) [~#text(..info.police-titre, style: "italic", fill: info.couleur-titre)[« #_contenu-titre(info) »]]
  (ligne: [#_lien(info, _griba-label(info))#etoiles#score#titre], marge: _marge-tags(info))
}

#let _griba-correction(corr) = {
  let c = corr.c
  let info = (c: c + (fg-color: white, bg-color: c.lower-bg-color), display-numexo: true, n: corr.n, label: corr.label)
  let lib = text(size: _taille-sans("footnotesize"), _griba-label(info, chiffre: c.lower-bg-color, boxsep: ptl(1)))
  let lib = if corr.cible != none { link(corr.cible, lib) } else { lib }
  block(width: 100%, above: 0pt, below: 0pt, {
    block(above: 0pt, below: 0pt, lib)
    v(ptl(1), weak: false)
    block(above: 0pt, below: 0pt, line(length: 100%, stroke: ptl(0.6) + c.lower-bg-color))
  })
}

// =====================================================================
// objiva (rdexo.sty de septembre 2026, l. 1894-2085)
// =====================================================================

/// Bandeau gris pleine largeur ; à gauche, un parallélogramme sombre (penché de 60°, large de 20 pt de
/// plus que le texte) porte « Exercice n » en blanc, le titre suit à 1 cm ; à droite, un second
/// parallélogramme sombre de 1,5 cm porte le score (blanc, \tiny) et, à sa gauche, les étoiles.
/// Sans score, les étoiles sont centrées dans le parallélogramme et sans contour (line width = 0).
#let _objiva-tcolorbox(info) = {
  let c = info.c
  let t12 = _taille-sans("normalsize")
  let etiquette = text(font: _sans, weight: "bold", size: t12, fill: c.label-color, _lien(info, _etiquette-num(info), couleur: c.label-color))
  let l = measure(etiquette).width + ptl(20)
  let titre = if _a-titre(info) [#h(1cm)#_titre(info)]
  let ligne = {
    set par(justify: false)
    [#_strut(t12)#etiquette#titre]
  }
  // boxsep 3 pt en haut, bottom = 1 pt + boxsep 3 pt en bas
  let hh = measure(ligne).height + ptl(7)
  let delta = hh / calc.sqrt(3)
  let largeur-droite = 1.5cm
  let bloc = block(width: 100%, height: hh, above: 0pt, below: 0pt, breakable: false, fill: c.bg-color, layout(taille => {
    let centrer(x, contenu) = {
      let m = measure(contenu)
      place(top + left, dx: x - m.width / 2, dy: (hh - m.height) / 2, contenu)
    }
    place(top + left, dx: 0.4cm, polygon(fill: c.fg-color, stroke: none, (0pt, hh), (l, hh), (l + delta, 0pt), (delta, 0pt)))
    place(top + left, dx: 0.4cm + ptl(14.5), dy: ptl(3), ligne)
    if info.display-score or info.display-level {
      let x0 = taille.width - 0.4cm - largeur-droite - delta
      place(top + left, dx: x0, polygon(fill: c.fg-color, stroke: none, (delta, 0pt), (delta + largeur-droite, 0pt), (largeur-droite, hh), (0pt, hh)))
      let milieu = x0 + (largeur-droite + delta) / 2
      let gauche = x0 + delta / 2
      if info.display-score {
        centrer(milieu, text(font: _sans, weight: "bold", size: _taille-sans("tiny"), fill: c.label-color, bf-the-score(info.score, info.score-label)))
      }
      if info.display-level {
        let x-etoiles = if info.display-score { gauche - 0.75cm } else { milieu }
        centrer(x-etoiles, _etoiles(info, t12, line-width: if info.display-score { ptl(0.4) } else { 0pt }))
      }
    }
  }))
  (bloc: bloc, tags: _bloc-tags(info))
}

// =====================================================================
// exobac / exobrevet (bfcours-exobac.sty)
// =====================================================================

/// \bfexobacUline{texte} : souligne exactement la largeur du texte (filet de `width`, `depth` sous la ligne de base).
#let bf-bfexobacUline(corps, ..cles) = context {
  let p = reglages-resoudre(bf-divers-registre, pour: "bfexobacUline", local: cles.named(), commande: "bfexobacUline")
  let l = measure(corps).width
  box({
    corps
    place(bottom + left, dy: p.depth + p.width - measure(text(top-edge: "baseline", bottom-edge: "descender", [x])).height, line(length: l, stroke: p.width + black))
  })
}

/// « Exercice n » souligné, puis « (3 points) » en gras (sujets du baccalauréat).
#let _exobac-tete(info, ligne: false) = {
  let c = info.c
  let num = if info.display-numexo [~#(info.n - info.extra.decalage)]
  let label = _lien(info, bf-bfexobacUline(strong[#info.label#num]), couleur: c.fg-color)
  let score = if info.display-score [~*(#bf-the-score(info.score, info.score-label))*]
  let titre = if _a-titre(info) [~–~#_titre(info)]
  let niveau = if info.display-level and not ligne [#h(1fr)#_etoiles(info, taille-latex("normalsize"), raise: -ptl(1))]
  text(fill: c.fg-color, [#label#score#titre#niveau])
}

/// « Exercice n : titre (2,5 points) » tout en gras (sujets du DNB).
#let _exobrevet-tete(info, ligne: false) = {
  let c = info.c
  let num = if info.display-numexo [~#(info.n - info.extra.decalage)]
  let titre = if _a-titre(info) [~: #_titre(info)]
  let score = if info.display-score [~(#bf-the-score(info.score, info.score-label))]
  let niveau = if info.display-level and not ligne [#h(1fr)#_etoiles(info, taille-latex("normalsize"), raise: -ptl(1))]
  text(fill: c.fg-color, [#strong[#_lien(info, [#info.label#num], couleur: c.fg-color)#titre#score]#niveau])
}

#let _exobac-bloc(info, tete) = {
  // inset bas : en LaTeX, la profondeur du filet de \bfexobacUline entre dans le \baselineskip ;
  // en Typst le filet est posé sans hauteur, d'où l'énoncé collé au soulignement sans cette marge
  let bloc = block(width: 100%, above: 0pt, below: 0pt, inset: (bottom: 0.3em), {
    set par(justify: false)
    tete(info)
  })
  (bloc: bloc, tags: if info.montrer-tags {
    block(width: 100%, above: ptl(2), below: 0pt, align(right, bf-thetags(info.tags, info.c, skin: info.skin)))
  })
}

/// En-tête de correction : « Corrigé de l'exercice n » souligné (bac) ou en gras (brevet).
#let _exobac-correction(corr, brevet: false) = {
  let ex = corr.extra
  let mot = ex.at("corrword", default: if brevet { "Correction" } else { "Corrigé" })
  let de = ex.at("corrof", default: "de l’exercice")
  let num = ex.at("num", default: corr.n)
  let lib = [#mot #de~#num]
  let lib = if brevet { strong(lib) } else { bf-bfexobacUline(strong(lib)) }
  let lib = text(fill: corr.c.correction-fg-color, lib)
  block(above: 0pt, below: ptl(2) + ptl(4), inset: (bottom: if brevet { 0pt } else { 0.3em }), if corr.cible != none { link(corr.cible, lib) } else { lib })
}

// =====================================================================
// exolombards (bfcours-exolombards-skin.sty)
// =====================================================================

#let bf-exolombards-etiquette-defaut(t) = box(stroke: ptl(0.4) + black, inset: ptl(3), baseline: ptl(3), strong(t))
#let bf-exolombards-titre-defaut(t) = emph(t)
#let bf-exolombards-bareme-defaut(t) = [(#t)]

/// En-tête en ligne : [Exercice n] (5 points) titre, puis un cadratin ; l'étiquette déborde dans la marge.
#let _exolombards-tete(info) = {
  let o = info.extra
  let etiquette = if o.etiquette == auto { bf-exolombards-etiquette-defaut } else { o.etiquette }
  let titre-f = if o.titre == auto { bf-exolombards-titre-defaut } else { o.titre }
  let bareme = if o.bareme == auto { bf-exolombards-bareme-defaut } else { o.bareme }
  let num = if info.display-numexo [~#info.n]
  let score = if info.display-score [~#bareme(bf-the-score(info.score, info.score-label))]
  let titre = if _a-titre(info) [#h(0.5em)#titre-f(_contenu-titre(info))]
  (ligne: [#h(o.decalage)#_lien(info, etiquette([#info.label#num]), couleur: black)#score#titre#h(1em)], marge: none, sans-decalage: true)
}

/// En-tête de correction exolombards : « Correction : » (à la suite) ou « [Exercice n] titre » (partie séparée).
#let _exolombards-correction(corr) = {
  let o = corr.extra
  let etiquette = if o.etiquette == auto { bf-exolombards-etiquette-defaut } else { o.etiquette }
  let titre-f = if o.titre == auto { bf-exolombards-titre-defaut } else { o.titre }
  let lien(c) = if corr.cible != none { link(corr.cible, c) } else { c }
  if o.at("suite", default: true) {
    [#lien(strong(o.mot-correction))~]
  } else {
    let ref = o.at("reference", default: none)
    let titre = if ref != none [#h(0.5em)#[(Réf : #ref)]] else if corr.titre not in (none, [], "") [#h(0.5em)#titre-f(corr.titre)]
    [#h(o.decalage)#lien(etiquette([#corr.label~#corr.n]))#titre#h(1em)]
  }
}

// =====================================================================
// Aiguillage
// =====================================================================

/// Thèmes intégrés : nom → (tcolorbox, tcbox, none, correction).
#let bf-skins-integres = (
  bouyachakka: (
    tcolorbox: info => (bloc: _bouyachakka-tcolorbox(info), tags: none),
    tcbox: _bouyachakka-tcbox,
    "none": info => (bloc: _bouyachakka-tcolorbox(info), tags: none),
    correction: _bouyachakka-correction,
  ),
  default: (
    tcolorbox: _default-tcolorbox,
    tcbox: _default-tcbox,
    "none": _default-none,
    correction: _default-correction,
  ),
  pooja: (
    tcolorbox: _pooja-tcolorbox,
    tcbox: _pooja-tcbox,
    "none": _pooja-tcolorbox,
    correction: corr => _default-correction(corr, carre: bf-ding110(_taille-sans("footnotesize"))),
  ),
  rikid: (
    tcolorbox: _rikid-tcolorbox,
    tcbox: _rikid-tcbox,
    "none": _rikid-tcolorbox,
    correction: _rikid-correction,
  ),
  griba: (
    tcolorbox: _griba-tcolorbox,
    tcbox: _griba-tcbox,
    "none": _griba-tcolorbox,
    correction: _griba-correction,
  ),
  objiva: (
    tcolorbox: _objiva-tcolorbox,
    tcbox: _default-tcbox,
    "none": _default-none,
    correction: _default-correction,
  ),
  exobac: (
    tcolorbox: info => _exobac-bloc(info, _exobac-tete),
    tcbox: info => (ligne: _exobac-tete(info, ligne: true), marge: none),
    "none": info => _exobac-bloc(info, _exobac-tete),
    correction: _exobac-correction,
  ),
  exobrevet: (
    tcolorbox: info => _exobac-bloc(info, _exobrevet-tete),
    tcbox: info => (ligne: _exobrevet-tete(info, ligne: true), marge: none),
    "none": info => _exobac-bloc(info, _exobrevet-tete),
    correction: corr => _exobac-correction(corr, brevet: true),
  ),
  exolombards: (
    tcolorbox: _exolombards-tete,
    tcbox: _exolombards-tete,
    "none": _exolombards-tete,
    correction: _exolombards-correction,
  ),
)
