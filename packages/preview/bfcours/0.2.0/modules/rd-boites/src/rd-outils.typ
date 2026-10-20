// rd-outils.typ — outils communs des boîtes (module `rd`) : ombre floue, icône d'avertissement,
// compteurs, « calque » (boîte dessinée sur mesure), polygones arrondis, bord déchiré.
//
// Ce fichier n'est PAS public : `rd.typ` en ré-exporte seulement les noms à documenter
// (`ombre-floue`, `icone-alerte`, `reinitialiser-compteur`…). Les autres fichiers rd-*.typ l'importent
// sous un nom court (`#import "rd-outils.typ" as o`).

#import "../../socle/lib.typ": interne as _socle
#import _socle: xmix, est-correction, environnements, decouper-items, item-corps, item-options

/// Cellules d'une boîte à items (`regulartcbitemize`, `mytcbitemize`) : UN SEUL corps, un item par `-` (ou
/// `+`), éventuellement écrit en `#begin … #end`. Renvoie le tableau des contenus. L'ancienne écriture, une
/// cellule par bloc `[…][…]`, arrête la compilation avec la nouvelle écriture en exemple.
#let items-corps(nom, pos) = {
  let exemple = "    #rd." + nom + "[\n      - Première cellule\n      - Seconde cellule\n    ]"
  if pos.len() == 0 {
    panic(nom + " : le corps est manquant. Écrire un item par ligne (« - »)." + "\n" + exemple)
  }
  if pos.len() > 1 or type(pos.first()) != content {
    panic(
      nom + " : l'écriture à plusieurs blocs `[…][…]` n'existe plus. Écrire UN SEUL corps, avec un item par ligne (« - ») :\n"
        + exemple,
    )
  }
  decouper-items(environnements(pos.first())).map(i => {
    if item-options(i).keys().any(k => k != "number") {
      panic(nom + " : `tcbitem` n'existe pas dans cette boîte ; écrire simplement « - » devant la cellule.")
    }
    item-corps(i)
  })
}

/// Passe le corps d'une boîte par la passe `begin … end` du socle : `#begin(rd.zone)[Titre] … #end(rd.zone)`
/// marche aussi à l'intérieur du corps d'une boîte écrite en syntaxe commande. Un corps qui n'est pas du
/// contenu (chaîne, `none`) passe tel quel.
#let env-corps(corps) = if type(corps) == content { environnements(corps) } else { corps }

// =====================================================================
// Constantes : polices de remplacement, palette, espacements
// =====================================================================

/// Police sans empattement des titres et étiquettes.
#let sans = "Latin Modern Sans"

/// Police de titre condensée de `entete` (Erewhon gras).
#let police-titre = "Erewhon"

/// Police « manuscrite » de `coinpli` (Erewhon italique).
#let police-manuscrite = "Erewhon"

#let gris = rgb(128, 128, 128)

/// Palette des boîtes.
#let palette = (
  alerte: rgb("#C0392B"),
  fiche: rgb("#2E86C1"),
  fiche-texte: rgb("#1B4F72"),
  lien-fond: rgb("#F5B041"),
  lien-cadre: rgb("#D68910"),
  lien-texte: rgb("#784212"),
  casio: rgb("#2E7D5B"),
  seyes: rgb("#6FA8DC"),
  scratch: rgb("#c837ab"),
  zone: rgb("#42609C"),
  ggb: rgb(72, 122, 170),
  papier: rgb(239, 227, 157),
  aide: rgb("#0088aa"),
  scratch-figure: rgb("#E6CDA4"),
  scratch-figure-fond: rgb("#FEFDF8"),
  scratch-capture: rgb("#ff6600"),
  tache-fond: rgb("#E1F1EB"),
  tache-etiquette: rgb("#E56600"),
  tache-cadre: rgb("#92CDDC"),
  prog-cadre: rgb("#92CDDC"),
  prog-interieur: rgb("#B6DDE8"),
  thermo: rgb("#558DCC"),
  thermo-clair: rgb("#CBEBFA"),
  thermo-moyen: rgb("#B8E5F8"),
)

/// c!p de xcolor : `p` pour cent de la couleur, le reste de blanc (ou de `autre`).
#let pale(c, p, autre: white) = xmix(c, p, autre: autre)

/// Espace vertical autour des boîtes de bloc.
#let espace = 0.8em

/// Hauteur des jambages : une ligne de texte de Typst s'arrête à la ligne de base, celle de LaTeX descend
/// jusqu'au bas des lettres (p, g, parenthèses). Ajoutée sous le contenu d'une boîte, elle redonne la
/// marge basse de la boîte LaTeX.
#let jambage = 0.22em

/// Supplément de hauteur d'un bandeau de titre : LaTeX y pose un étai (strut) plus haut que les capitales
/// et plus bas que la ligne de base. Ajouté en haut ET en bas du titre.
#let etai-titre = 0.2em

/// Taille « footnotesize » de LaTeX, relative au corps courant.
#let t-notes = 0.8em
#let t-script = 0.7em
#let t-minuscule = 0.55em
#let t-grand = 1.3em

// =====================================================================
// Petits utilitaires
// =====================================================================

/// Résout une largeur (longueur, pourcentage, relatif) par rapport à une base.
#let resoudre(l, base) = {
  if l == auto { base } else if type(l) == ratio { base * l } else if type(l) == relative {
    base * l.ratio + l.length
  } else { l }
}

/// Entier sur `k` chiffres (« 007 »).
#let chiffres(n, k) = {
  let s = str(n)
  "0" * calc.max(0, k - s.len()) + s
}

/// Sépare titre et corps pour une boîte à titre FACULTATIF : `[Titre][Corps]` ou `[Corps]`.
#let titre-corps(args, nom) = {
  // Les arguments nommés (clés de réglage) sont traités par l'appelant : seuls les positionnels comptent ici.
  let p = args.pos()
  if p.len() == 2 { (p.at(0), env-corps(p.at(1))) } else if p.len() == 1 { (none, env-corps(p.at(0))) } else {
    panic(nom + " : le titre (facultatif) puis le corps, soit [Titre][Corps] ou [Corps] ; reçu " + str(p.len()) + " argument(s) positionnel(s).")
  }
}

/// Même chose pour une boîte à DEUX parties (`[Partie gauche][Partie droite]` ou `[Corps]` seul).
#let deux-parties(args, nom) = titre-corps(args, nom)

/// Applique la couleur de texte si elle est donnée.
#let colorer(c, corps) = if c == none or c == auto { corps } else { text(fill: c, corps) }

// =====================================================================
// Ombre floue
// =====================================================================

/// Ombre floue, à poser DERRIÈRE une boîte de dimensions `largeur` × `hauteur` : dix rectangles de plus
/// en plus opaques vers le centre, décalés de `decalage`. C'est l'équivalent de `drop fuzzy shadow` et
/// `fuzzy shadow` de tcolorbox. Le résultat n'occupe aucune place (tout est en `place`).
///
/// ```typ
/// #box(width: 4cm, height: 1.2cm, {
///   rd.ombre-floue(4cm, 1.2cm)
///   rect(width: 4cm, height: 1.2cm, fill: white, stroke: 0.5pt)
/// })
/// ```
///
/// - largeur (length): largeur de la boîte ombrée.
/// - hauteur (length): hauteur de la boîte ombrée.
/// - decalage (length): décalage de l'ombre vers la droite et vers le bas.
/// - flou (length): demi-épaisseur de la zone floue.
/// - couleur (color): couleur de l'ombre.
/// - opacite (ratio): opacité au centre de la zone floue.
/// - rayon (length): arrondi des coins de la boîte ombrée.
/// -> content
#let ombre-floue(
  largeur,
  hauteur,
  decalage: 2.5pt,
  flou: 1.4pt,
  couleur: gris,
  opacite: 50%,
  rayon: 1mm,
) = {
  let alphas = (1, 2, 4, 7, 11, 11, 7, 4, 2, 1)
  let n = alphas.len()
  let k = opacite / 50%
  for (i, a) in alphas.enumerate() {
    let e = flou * (1 - 2 * i / (n - 1))
    place(
      top + left,
      dx: decalage - e,
      dy: decalage - e,
      rect(
        width: largeur + 2 * e,
        height: hauteur + 2 * e,
        radius: calc.max(0pt, rayon + e),
        fill: couleur.transparentize(100% - a * 1% * k),
      ),
    )
  }
}

// =====================================================================
// Icône d'avertissement
// =====================================================================

/// Triangle d'avertissement (point d'exclamation dans un triangle orange), dessiné en Typst : aucune
/// image externe. Remplace `misc/warning` de la boîte `attention`.
///
/// ```typ
/// #rd.icone-alerte(taille: 10mm)
/// ```
///
/// - taille (length): largeur de l'icône.
/// - couleur (color): couleur de remplissage.
/// - contour (color): couleur du contour et du point d'exclamation.
/// -> content
#let icone-alerte(taille: 8mm, couleur: rgb("#FF8000"), contour: rgb("#5A2600")) = {
  let h = taille * 0.88
  box(width: taille, height: h, {
    place(top + left, polygon(
      fill: couleur,
      stroke: (paint: contour, thickness: 0.06 * taille, join: "round"),
      (taille / 2, 0.06 * h),
      (taille - 0.04 * taille, h - 0.04 * h),
      (0.04 * taille, h - 0.04 * h),
    ))
    place(center + horizon, dy: 0.12 * h, text(font: sans, weight: "bold", size: 0.5 * taille, fill: contour, top-edge: "bounds", bottom-edge: "bounds")[!])
  })
}

// =====================================================================
// Compteurs
// =====================================================================

/// Compteur d'une boîte numérotée (`exemplerealisation`, `scratchblock`, `vf`…), nommé comme la boîte.
#let compteur(nom) = counter("rd-" + nom)

/// Remet à zéro le ou les compteurs des boîtes nommées.
/// Noms utiles : `"exemplerealisation"`, `"vf"`, `"scratchblock"`, `"scratchfig"`, `"scratchcapture"`,
/// `"ficheno"`, `"gauche"`, `"droite"` (points à relier).
///
/// ```typ
/// #rd.reinitialiser-compteur("vf")
/// ```
///
/// - noms (str): noms des boîtes dont on remet le compteur à zéro.
/// -> content
#let reinitialiser-compteur(..noms) = {
  for n in noms.pos() { compteur(n).update(0) }
}

/// Remet à zéro les trois compteurs Scratch (`scratchblock`, `scratchfig`, `scratchcapture`) :
/// l'équivalent de `\resetScratchCounters`.
///
/// ```typ
/// #rd.reinitialiser-scratch()
/// ```
///
/// -> content
#let reinitialiser-scratch() = reinitialiser-compteur("scratchblock", "scratchfig", "scratchcapture")

// =====================================================================
// Polygones arrondis
// =====================================================================

/// Courbe fermée passant par `pts` (liste de (x, y) en longueurs) avec des coins arrondis de rayon `r`
/// (nombre en pt, ou liste d'un rayon par sommet).
#let courbe-ronde(pts, r, ..style) = {
  let n = pts.len()
  let v = pts.map(p => (p.at(0).pt(), p.at(1).pt()))
  let rs = if type(r) == array { r } else { (r,) * n }
  let segs = ()
  let premier = none
  for i in range(n) {
    let p = v.at(calc.rem(i + n - 1, n))
    let c = v.at(i)
    let s = v.at(calc.rem(i + 1, n))
    let d1 = calc.sqrt(calc.pow(p.at(0) - c.at(0), 2) + calc.pow(p.at(1) - c.at(1), 2))
    let d2 = calc.sqrt(calc.pow(s.at(0) - c.at(0), 2) + calc.pow(s.at(1) - c.at(1), 2))
    let ri = calc.min(rs.at(i), d1 / 2, d2 / 2)
    let a = if ri == 0 { c } else { (c.at(0) + (p.at(0) - c.at(0)) / d1 * ri, c.at(1) + (p.at(1) - c.at(1)) / d1 * ri) }
    let b = if ri == 0 { c } else { (c.at(0) + (s.at(0) - c.at(0)) / d2 * ri, c.at(1) + (s.at(1) - c.at(1)) / d2 * ri) }
    let pa = (a.at(0) * 1pt, a.at(1) * 1pt)
    let pb = (b.at(0) * 1pt, b.at(1) * 1pt)
    if i == 0 { segs.push(curve.move(pa)) } else { segs.push(curve.line(pa)) }
    if ri > 0 { segs.push(curve.quad((c.at(0) * 1pt, c.at(1) * 1pt), pb)) }
  }
  segs.push(curve.close(mode: "straight"))
  curve(..style, ..segs)
}

// =====================================================================
// Générateur pseudo-aléatoire déterministe (bord déchiré)
// =====================================================================

/// Générateur congruentiel linéaire : renvoie un tableau de `n` nombres dans [0 ; 1[ qui ne dépend que
/// de la graine. Interne : sert au tracé décoratif des bords déchirés, pas aux utilisateurs.
#let _alea(graine, n) = {
  let etat = calc.rem(graine * 2654435761 + 12345, 2147483647)
  let sortie = ()
  for _ in range(n) {
    etat = calc.rem(etat * 48271, 2147483647)
    sortie.push(etat / 2147483647)
  }
  sortie
}

/// Points d'un rectangle `l` × `h` au bord irrégulier (« random steps » de TikZ) : des segments de
/// longueur `pas` dont chaque sommet est décalé au hasard d'au plus `amplitude`.
#let rectangle-dechire(l, h, pas, amplitude, graine) = {
  let L = l.pt()
  let H = h.pt()
  let p = pas.pt()
  let a = amplitude.pt()
  let nx = int(calc.max(2, calc.round(L / p)))
  let ny = int(calc.max(2, calc.round(H / p)))
  let total = 2 * (nx + ny)
  let r = _alea(graine, 2 * total)
  let pts = ()
  let k = 0
  // dessus, de gauche à droite
  for i in range(nx) { pts.push((L * i / nx, 0)) }
  for j in range(ny) { pts.push((L, H * j / ny)) }
  for i in range(nx) { pts.push((L - L * i / nx, H)) }
  for j in range(ny) { pts.push((0, H - H * j / ny)) }
  pts.enumerate().map(((i, q)) => (
    (q.at(0) + (r.at(2 * i) * 2 - 1) * a) * 1pt,
    (q.at(1) + (r.at(2 * i + 1) * 2 - 1) * a) * 1pt,
  ))
}

// =====================================================================
// Calque : boîte dessinée sur mesure
// =====================================================================

/// Boîte de bloc dont le fond et le premier plan sont dessinés à partir des dimensions réelles.
///
/// Le contenu est d'abord mesuré (à la largeur `largeur`, retraits `inset` compris), puis `dessous(l, h)`
/// et `dessus(l, h)` sont appelés avec les dimensions finales : ils renvoient du contenu qui sera posé
/// en `place(top + left, …)` derrière et devant le texte.
#let calque(
  corps,
  largeur: 100%,
  hauteur: auto,
  inset: 0pt,
  dessous: none,
  dessus: none,
  alignement: none,
  avant: espace,
  apres: espace,
  secable: false,
) = block(width: 100%, above: avant, below: apres, breakable: false, layout(s => {
  let L = resoudre(largeur, s.width)
  let contenu(h) = block(
    width: L,
    height: h,
    inset: inset,
    breakable: false,
    if alignement == none { corps } else { align(alignement, corps) },
  )
  let m = measure(contenu(auto))
  let H = if type(hauteur) == length { calc.max(m.height, hauteur) } else { m.height }
  block(width: L, height: H, breakable: false, {
    if dessous != none { place(top + left, block(width: L, height: H, breakable: false, dessous(L, H))) }
    contenu(H)
    if dessus != none { place(top + left, block(width: L, height: H, breakable: false, dessus(L, H))) }
  })
}))

/// Rend une boîte qui peut être PLUS HAUTE QU'UNE PAGE.
///
/// `f` est une fonction sans argument qui renvoie la boîte. Une boîte qui tient sur une page est renvoyée
/// telle quelle (aucun changement, la boîte monte à la page suivante si la place manque). Une boîte plus
/// haute que la zone utile d'une page est dessinée en entier (fond, cadre, ruban) puis découpée en
/// tranches de la hauteur disponible : la première part de la position courante, les suivantes remplissent
/// chacune une page. Le fond et le cadre latéral sont continus ; le décor (ruban, titre, icône) reste sur
/// la première tranche. Une tranche peut couper une ligne de texte ; rien n'est perdu.
///
/// Limite : la hauteur est mesurée à la largeur de la zone utile de la page (boîte dans le flux principal) ;
/// une boîte trop haute DANS une colonne ou une autre boîte n'est pas découpée.
#let tranchable(f) = context {
  let c = f()
  let ab(v) = if type(v) == relative { v.length } else if type(v) == length { v } else { 0pt }
  let ph = page.height
  let pw = page.width
  let mg = page.margin
  if type(ph) != length or type(pw) != length { return c }
  // marge : une seule valeur (longueur), `auto` (2,5/21 du petit côté) ou un dictionnaire par côté
  let cote(k) = if type(mg) == dictionary {
    ab(mg.at(k, default: ab(mg.at("rest", default: 0pt))))
  } else if mg == auto {
    calc.min(ph, pw) * 2.5 / 21
  } else {
    ab(mg)
  }
  let (mh, mb, mgau, mdr) = (cote("top"), cote("bottom"), cote("left"), cote("right"))
  let utile = ph - mh - mb
  let wmax = pw - mgau - mdr
  let H = measure(width: wmax, c).height
  if H <= utile { return c }
  // `here()` donne le haut de la ligne courante : on retire la hauteur de cette ligne et l'espacement entre
  // blocs qui s'ajoutent avant la première tranche
  let ecart = calc.max(ab(par.spacing.to-absolute()), (1.2em).to-absolute()) + (1.4em).to-absolute() + 2pt
  let reste = ph - mb - here().position().y - ecart
  let tranches = ()
  let decalage = 0pt
  if reste >= 40pt {
    let h = calc.min(reste - 1pt, H)
    tranches.push((decalage, h))
    decalage += h
  }
  while decalage < H - 0.01pt {
    let h = calc.min(utile - 8pt, H - decalage)
    tranches.push((decalage, h))
    decalage += h
  }
  // un élément flottant vide devant la première tranche : sans lui, Typst repousse la première tranche à la page suivante
  place(top + left, [])
  for (i, (d, h)) in tranches.enumerate() {
    block(width: wmax, height: h, above: if i == 0 { 0.6em } else { 0pt }, below: 0pt, breakable: false, clip: true, {
      place(top + left, dy: -d, block(width: wmax, height: H, breakable: false, c))
    })
  }
}

/// Boîte EN LIGNE (équivalent des `\newtcbox`) : dimensions du contenu, mêmes `dessous` et `dessus`.
#let calque-ligne(corps, inset: 0pt, dessous: none, dessus: none, baseline: 0pt) = context {
  let c = box(inset: inset, corps)
  let m = measure(c)
  box(width: m.width, height: m.height, baseline: baseline, {
    if dessous != none { place(top + left, dessous(m.width, m.height)) }
    c
    if dessus != none { place(top + left, dessus(m.width, m.height)) }
  })
}

/// Texte tourné de 90° (lu de bas en haut), prenant sa vraie place dans la mise en page.
#let vertical(corps) = rotate(-90deg, reflow: true, box(corps))

/// Vrai si le document est compilé en version professeur. À appeler dans un `context`.
#let prof() = est-correction()

/// Coche seule (sans case), dans un carré de côté `taille` : le ✔ de `\ding{52}`.
#let coche(taille: 3.2mm, couleur: red) = box(width: taille, height: taille, baseline: 0.15 * taille, place(top + left, curve(
  stroke: (paint: couleur, thickness: 0.16 * taille, cap: "round", join: "round"),
  curve.move((0.08 * taille, 0.55 * taille)),
  curve.line((0.38 * taille, 0.9 * taille)),
  curve.line((0.95 * taille, 0.05 * taille)),
)))

/// Case ombrée (le ❑ de `\ding{113}`) : carré au trait fin, ombre pleine décalée en bas à droite ;
/// `cochee` ajoute une coche rouge.
#let case-ombree(cochee: false, taille: 3.4mm, couleur: black, couleur-coche: red) = {
  let o = 0.16 * taille
  box(width: taille + o, height: taille + o, baseline: 0.15 * taille, {
    place(top + left, dx: o, dy: o, rect(width: taille, height: taille, fill: couleur))
    place(top + left, rect(width: taille, height: taille, stroke: 0.5pt + couleur, fill: white))
    if cochee { place(top + left, dx: 0.1 * taille, dy: -0.15 * taille, coche(taille: taille, couleur: couleur-coche)) }
  })
}

/// Case à cocher carrée ; `cochee` ajoute une coche rouge.
#let case(cochee: false, taille: 3.2mm, couleur: black, couleur-coche: red) = box(width: taille, height: taille, baseline: 0.15 * taille, {
  place(top + left, rect(width: taille, height: taille, stroke: 0.6pt + couleur, fill: white, radius: 0.5pt))
  if cochee {
    place(top + left, curve(
      stroke: (paint: couleur-coche, thickness: 1.1pt, cap: "round", join: "round"),
      curve.move((0.18 * taille, 0.55 * taille)),
      curve.line((0.42 * taille, 0.85 * taille)),
      curve.line((1.1 * taille, -0.2 * taille)),
    ))
  }
})
