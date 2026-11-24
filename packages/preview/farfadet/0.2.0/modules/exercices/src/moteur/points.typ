// points.typ (farfadet-exo) — boîtes de points et barème de new-bfcours-environments.sty (l. 96-360) :
// \tcbitempoint et \itempoint (une seule fonction `itempoint` : clé `dys` = ancien \dystcbitempoint, clé
// `variante: "gris"` = ancien \itempoint), \infotcbitempoint, \baremepoint,
// \displaybaremepoints, \getinfoexopoint, \getsavedinfototalpoints.
//
// La machinerie partagée (état `bf-points`, \displayitempoints) vit dans farfadet-socle (lue aussi par le QCM) ;
// ce fichier en tire des boîtes RÉGLABLES (registre « exo-divers », types `itempoint`, `infotcbitempoint`…,
// réglés par `setrdexo(pour: …)`) dont les défauts reproduisent bfcours au pixel près.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "reglages.typ": bf-divers-registre, bf-divers-types, bf-points-gris, bf-exo-couleur
#import "enroulement.typ": bf-enrouler-ligne, bf-flottant-en-ligne

/// Points « informatique » (\infotcbitempoint) : total du document et de l'exercice en cours.
#let bf-points-info = state("bf-points-info", (total: 0, exo: 0))

/// \displaybaremepointstrue / \displaybaremepointsfalse (faux par défaut, comme bfcours).
#let bf-afficher-bareme-p = bf-etat("bf-afficher-bareme", false)
#let bf-afficher-bareme = bf-afficher-bareme-p.etat

/// Icône \faLaptop (Font Awesome) dessinée : écran et clavier, à la hauteur des capitales.
#let bf-icone-portable() = box(baseline: 0pt, {
  let h = 0.62em
  box(width: 0.95em, height: h, {
    place(top + center, dy: 0pt, rect(width: 0.72em, height: 0.46em, radius: 0.06em, stroke: 0.09em, fill: none))
    place(bottom + center, rect(width: 0.95em, height: 0.09em, radius: 0.04em, fill: black, stroke: none))
  })
})

/// Libellé « 1 pt », « 0,5 pt », « 2,5 pts » (singulier jusqu'à 1 inclus, comme bfcours).
#let bf-libelle-point(n, p) = {
  // `[2]` ou `[2,5]` (argument LaTeX en crochets) : converti en nombre
  if type(n) == content and n.has("text") { n = float(n.text.trim().replace(",", ".")) }
  if type(n) == str { n = float(n.trim().replace(",", ".")) }
  let unite = if n > 1 { p.plural } else { p.singular }
  [#bf-nombre(n)#h(0.36em)#unite]
}

/// Boîte de points résolue `p` (nœud TikZ draw, fill, rounded corners, inner sep, minimum width).
/// Renvoie (boite:, largeur:, haut:). À appeler dans un `context`.
#let bf-boite-point(n, p) = {
  let icone = if p.at("icone", default: none) == auto { bf-icone-portable() } else { p.at("icone", default: none) }
  let lib = [#if icone != none [#icone#h(0.33em)]#bf-libelle-point(n, p)]
  let haut = measure(text(top-edge: "bounds", bottom-edge: "baseline", lib)).height
  let t = text(top-edge: "bounds", bottom-edge: "bounds", fill: bf-exo-couleur(p.at("coltext", default: black)), lib)
  let m = measure(t)
  let l = calc.max(m.width + 2 * p.boxsep, p.at("min-width", default: 0pt))
  let boite = box(
    width: l,
    height: m.height + 2 * p.boxsep,
    fill: bf-exo-couleur(p.colback),
    stroke: p.boxrule + bf-exo-couleur(p.colframe),
    radius: p.arc,
    align(center + horizon, t),
  )
  (boite: boite, largeur: l, haut: haut + p.boxsep)
}

/// Réglages résolus d'une boîte de points. La variante « gris » (ancien \itempoint de bfcours) ne remplace que
/// les clés laissées à leur valeur par défaut : un réglage explicite (`colback: red`) l'emporte.
#let _regler-point(type, cles) = {
  let p = reglages-resoudre(bf-divers-registre, pour: type, local: cles, commande: type)
  if p.at("variante", default: "standard") == "gris" {
    let defauts = bf-divers-types.at(type)
    for (k, v) in bf-points-gris { if p.at(k) == defauts.at(k) { p.insert(k, v) } }
  }
  p
}

/// Pose (ou non) la boîte de points d'un item et cumule les points. `type` : type du registre « exo-divers » ;
/// `etat` : état cumulé (`bf-points` ou `bf-points-info`).
///
/// Deux écritures, dans les deux cas le texte ne passe jamais sous la boîte :
///   - EN TÊTE, avec le texte de l'item en second argument (`itempoint(2)[Résoudre…]`, forme normale) :
///     `position: "droite"` (défaut) range la boîte à droite, en haut de l'item, et le texte de la première ligne
///     coule à sa gauche puis reprend toute la largeur dessous (`bf-enrouler-ligne`) ; sur un texte qui ne s'y prête
///     pas (liste, figure, formule en affichage), la boîte prend sa propre ligne, à droite, au-dessus du texte ;
///     `position: "gauche"` pose la boîte en ligne, juste avant le premier mot ;
///   - EN FIN d'item, sans texte (`Texte. #itempoint(2)`, ancien usage, conservé) : une zone de la largeur de la
///     boîte est réservée au bout de la dernière ligne (`reserver`) ; une expression longue qui irait jusque sous
///     la boîte passe à la ligne suivante, avec la boîte.
#let _point(type, n, cles, afficher, etat, corps: none, reserver: true) = {
  let pose = context {
    let p = _regler-point(type, cles)
    let montrer = if afficher == auto { bf-lire(bf-afficher-points-p) } else { afficher }
    if not montrer { return corps }
    let b = bf-boite-point(n, p)
    // `dx: auto` : 0 cm, ou 2 cm pour la variante DYS
    let dx = if p.dx == auto { if p.dys { 2cm } else { 0cm } } else { p.dx }
    // `position: "gauche"` : boîte en ligne, juste avant le premier mot
    if p.position == "gauche" { return [#bf-flottant-en-ligne(b.boite)#h(0.5em)#corps] }
    // distance du bord droit du conteneur au bord droit de la boîte
    let droite = calc.max(0pt, p.xshift + dx - b.largeur / 2)
    let (x0, largeur) = bf-conteneur-ici()
    // boîte posée au bord droit du conteneur, à la hauteur de la ligne où se trouve cet appel, et zone réservée
    // (du bord gauche de la boîte au bord droit du conteneur, plus 0,5 em) ; le joint de mots empêche tout saut
    // de ligne entre le dernier mot, la boîte et la zone
    let fin() = context {
      let ici = here().position().x
      let boite = box(width: 0pt, height: 0pt, place(
        top + left,
        dx: x0 + largeur - p.xshift - dx - b.largeur / 2 - ici,
        dy: -b.haut - p.dy,
        b.boite,
      ))
      let zone = p.xshift + dx + b.largeur / 2 + 0.5em.to-absolute()
      if reserver { [#sym.wj#boite#sym.wj#box(width: zone)] } else { boite }
    }
    if corps == none { return fin() }
    // en tête : boîte flottante à droite, texte enroulé ; repli (texte qui ne s'y prête pas) : réservation en fin
    let flottant = box(inset: (right: droite), b.boite)
    // question qui commence par un bloc : badge en haut à droite, sur la ligne du numéro, le bloc dans une colonne
    // plus étroite (jamais sous le badge) ; l'item suivant ne touche pas le badge (la ligne prend sa hauteur)
    // La boîte en ligne a pour ligne de base la première ligne du bloc (le numéro de l'item s'aligne sur le haut).
    let l-item = x0 + largeur - here().position().x
    let grille = grid(columns: (1fr, auto), column-gutter: 1em, align: top, corps, flottant)
    let h-grille = measure(box(width: l-item, grille)).height
    let montee = measure(text(top-edge: "ascender", bottom-edge: "baseline", [x])).height
    let repli-bloc = box(width: l-item, baseline: h-grille - montee, grille)
    bf-enrouler-ligne(flottant, corps, [#corps#fin()], largeur: l-item, repli-bloc: repli-bloc)
  }
  // en fin d'item : deux espaces de 0,3 em (7 pt pour 11,7 pt) ; hors `context` et avant la mise à jour de l'état,
  // sinon l'espacement faible ne disparaît plus en début de paragraphe
  if corps == none { h(0.6em, weak: true) }
  // repère invisible : en tête d'un énoncé, `exo` classe son début d'après le texte de l'item
  // (en LaTeX, \tcbitempoint est un nœud flottant : le premier paragraphe reste un paragraphe)
  if corps != none [#metadata((bf-debut-point: corps))]
  pose
  etat.update(e => e + (total: e.total + n, exo: e.exo + n))
}

/// Points d'un item (\tcbitempoint{points}[décalage vertical][décalage horizontal], \itempoint, \dystcbitempoint :
/// une seule fonction). `variante: "gris"` : l'ancien \itempoint (boîte grise, plus près du bord).
#let bf-itempoint(n, corps: none, boite: auto, reserver: true, ..cles) = _point("itempoint", n, cles.named(), boite, bf-points, corps: corps, reserver: reserver)

/// \infotcbitempoint{points}[v][h] : points « informatique » (icône d'ordinateur, totaux séparés).
#let bf-infotcbitempoint(n, corps: none, boite: auto, reserver: true, ..cles) = _point("infotcbitempoint", n, cles.named(), boite, bf-points-info, corps: corps, reserver: reserver)

/// \displaybaremepointstrue / false.
#let bf-displaybaremepoints(v) = bf-maj(bf-afficher-bareme-p, v)

/// \baremepoint{contenu}{points} : boîte rouge « n pts » au-dessus du contenu, si \displaybaremepointstrue.
/// Ne s'ajoute à aucun total (comme en LaTeX).
#let bf-baremepoint(contenu, n, ..cles) = context {
  let p = reglages-resoudre(bf-divers-registre, pour: "baremepoint", local: cles.named(), commande: "baremepoint")
  if not bf-lire(bf-afficher-bareme-p) { return box(contenu) }
  let b = bf-boite-point(n, p + (min-width: 0pt))
  let mc = measure(box(contenu))
  // nœud anchor=south posé 0,2 cm au-dessus du haut du contenu
  box({
    contenu
    place(top + left, dx: (mc.width - b.largeur) / 2, dy: -p.raise - measure(b.boite).height, b.boite)
  })
}

/// Points de l'exercice n du document (\getexopoint{n}), 0 s'il n'existe pas. À appeler dans un `context`.
#let bf-points-exercice(n, etat: bf-points) = {
  let fins = query(<bf-exo-fin>)
  if n < 1 or n > fins.len() { return 0 }
  etat.at(fins.at(n - 1).location()).exo
}

/// \getinfoexopoint{n} : points « informatique » de l'exercice n.
#let bf-getinfoexopoint(n) = context bf-nombre(bf-points-exercice(n, etat: bf-points-info))

/// \getsavedinfototalpoints : total des points « informatique » du document (suivi d'un \phantom{A}).
#let bf-getsavedinfototalpoints() = context [ #bf-nombre(bf-points-info.final().total)#hide[A]]
