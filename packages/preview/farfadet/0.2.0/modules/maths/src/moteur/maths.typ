// maths.typ — équivalents Typst des macros de bfcours-mathsCommands.sty.
// (Les connecteurs logiques \Si, \Alors, \Donc… sont dans texte.typ.)
//
// Le convertisseur traduit les formules avec texmath (\R devient bb(R), \Vecteur{AB} devient
// arrow(A B)…), mais les macros qui dessinent quelque chose — \Coordonnees et ses pastilles
// grises, \CrochetG / \CrochetD et leurs crochets tracés à la main — sont rendues par les
// fonctions ci-dessous, appelées depuis la formule (voir bfcours-lua/maths.lua). Elles servent
// aussi à l'écriture directe en Typst, avec les mêmes noms qu'en LaTeX (en minuscules).
//
// Les cotes sont relevées sur le rendu LaTeX.
#import "../../../socle/lib.typ": interne as _socle
#import _socle: *

// ---------- Ensembles de nombres (\R, \N, \Z, \Q, \C, \D) ----------
#let R = $bb(R)$
#let N = $bb(N)$
#let Z = $bb(Z)$
#let Q = $bb(Q)$
#let C = $bb(C)$
#let D = $bb(D)$

/// \Vecteur{AB} → $vecteur(A B)$ (flèche extensible)
#let vecteur(x) = math.accent(x, math.arrow)
#let vect = vecteur

// ---------- Unités de LaTeX ----------
// 1 ex de la police du corps (Utopia à 11 pt : x-height 0,478 em, soit 5,26 pt sur le PDF
// d'origine) ramené au corps Typst (Erewhon, 11,715 pt) : les crochets gardent leurs
// proportions. Exprimées en em, les cotes suivent le style mathématique — en indice et en
// exposant, Typst réduit la police (0,7 puis 0,55) comme le \mathchoice de LaTeX le fait
// avec \scriptsize et \tiny.
#let _ex = 0.449em

/// Contenu composé en mode mathématique, sauf s'il en est déjà (le filtre passe des `[$x$]`).
#let _math(v) = if type(v) == content and v.func() == math.equation { v } else { $#v$ }

/// Contenu mesuré sur ses glyphes et non sur les métriques de la police : la boîte épouse le
/// contenu, comme une boîte TeX (dont la hauteur est celle de ce qu'elle contient).
#let _serre(v) = text(top-edge: "bounds", bottom-edge: "bounds", _math(v))

// ---------- \CrochetG, \CrochetD, \intervalle ----------
// (Épurage 07/10/2026 : `pastille`, `coordonnees` et `crochet-g`/`crochet-d` du moteur sont supprimés ;
// la façade règle les pastilles par `pastille-avec`.)
// Crochets ADAPTATIFS (variante retenue le 17/09/2026) : leur hauteur suit celle du contenu,
// mesurée sur les glyphes, au lieu des quatre tailles fixes du \mathchoice de LaTeX — un
// intervalle de fractions a des crochets à sa mesure. Ils sont aussi plus francs que le tracé
// TikZ d'origine, qu'on voyait peu. Cotes retenues (planche de comparaison, variante « V3 ») :
#let _cr = (
  trait: 0.8pt, // épaisseur du trait
  patte: 0.30em, // longueur des retours horizontaux
  marge: 0.10em, // dépassement au-delà du contenu, en haut et en bas
  ecart: 0.16em, // blanc entre le crochet et ce qu'il encadre
  approche: 0.06em, // blanc à l'extérieur : sans lui, le crochet colle au mot qui précède
)

// Boîte de largeur nulle qui descend de 200 pt sous la ligne de base : mesurée à côté du contenu,
// elle isole la hauteur AU-DESSUS de la ligne de base ; la profondeur s'en déduit.
#let _sonde = box(width: 0pt, height: 200pt, baseline: 200pt)

/// Un crochet de hauteur imposée ; `droit` : montant à droite (le « ] » de LaTeX).
/// `cr` : cotes (trait, patte, approche…), celles de `_cr` par défaut.
#let _crochet(droit, haut, bas, cr: _cr) = box(
  inset: if droit { (right: cr.approche) } else { (left: cr.approche) },
  box(
    width: cr.patte,
    height: haut + bas,
    baseline: bas,
    stroke: (
      top: cr.trait,
      bottom: cr.trait,
      left: if droit { none } else { cr.trait },
      right: if droit { cr.trait } else { none },
    ),
  ),
)

/// Paire de crochets à la hauteur de ce qu'elle encadre — `\CrochetG … \CrochetD` appariés par
/// le filtre, ou écriture directe : `#crochets(forme: "oo")[$0 #pvfr +oo$]`.
/// `forme` : « ff » [a ; b], « oo » ]a ; b[, « fo » [a ; b[, « of » ]a ; b].
/// `cr` : cotes à changer (dictionnaire partiel : `(trait: 1pt, ecart: 0.3em)`).
#let crochets(forme: "ff", cr: (:), corps) = context {
  let cr = _cr + cr
  let mesure = _serre(corps)
  let totale = measure(mesure).height
  let au-dessus = measure(mesure + _sonde).height - 200pt
  let marge = cr.marge.to-absolute()
  let (haut, bas) = (au-dessus + marge, totale - au-dessus + marge)
  let ouvre = _crochet(forme.at(0, default: "f") == "o", haut, bas, cr: cr)
  let ferme = _crochet(forme.at(1, default: "f") != "o", haut, bas, cr: cr)
  $#ouvre #h(cr.ecart) #_math(corps) #h(cr.ecart) #ferme$
}

/// Crochet seul aux cotes de LaTeX (`ex` : la longueur d'un « ex » ramenée au corps Typst) ; `droit` :
/// « ] » ; `cr` : cotes à changer. Sans contenu à mesurer : forme de LaTeX (1,84 ex au-dessus de la
/// ligne de base, 0,46 ex en dessous).
#let crochet-seul(droit, ex: _ex, cr: (:)) = _crochet(droit, 1.84 * ex, 0.46 * ex, cr: _cr + cr)

/// Crochet ADAPTATIF : sa hauteur suit celle de `corps` (mesuré sur ses glyphes, comme `crochets`), et
/// `corps` est écrit à côté, du côté où le crochet s'ouvre : « [ corps » (`droit: false`), « corps ] »
/// (`droit: true`). `cr` : cotes à changer.
#let crochet-adapte(droit, corps, cr: (:)) = context {
  let cr = _cr + cr
  let mesure = _serre(corps)
  let totale = measure(mesure).height
  let au-dessus = measure(mesure + _sonde).height - 200pt
  let marge = cr.marge.to-absolute()
  let (haut, bas) = (au-dessus + marge, totale - au-dessus + marge)
  let c = _crochet(droit, haut, bas, cr: cr)
  if droit { $#_math(corps) #h(cr.ecart) #c$ } else { $#c #h(cr.ecart) #_math(corps)$ }
}

/// Une coordonnée sur son fond, à longueurs et couleurs imposées (les clés tcolorbox de `\tcbox`) :
/// garde = `boxsep` + marge + `boxrule`, bord arrondi de `arc` + `boxrule`. Si `colframe` vaut `none` ou
/// `colback`, une seule boîte (pastille grise de `coordonnees`) ; sinon un filet de `boxrule` d'une autre couleur.
#let pastille-avec(corps, colback: xcolor("gray!15"), colframe: none, arc: ptl(2), boxsep: ptl(1),
    gauche: ptl(1), droite: ptl(1), haut: ptl(1), bas: ptl(1), boxrule: 0.5mm) = {
  if colframe == none or colframe == colback {
    box(
      fill: colback,
      inset: (left: boxsep + gauche + boxrule, right: boxsep + droite + boxrule,
        top: boxsep + haut + boxrule, bottom: boxsep + bas + boxrule),
      radius: arc + boxrule,
      _serre(corps),
    )
  } else {
    box(fill: colframe, radius: arc + boxrule, inset: boxrule, box(
      fill: colback,
      inset: (left: boxsep + gauche, right: boxsep + droite, top: boxsep + haut, bottom: boxsep + bas),
      radius: arc,
      _serre(corps),
    ))
  }
}

/// \intervalle[forme]{a}{b} ; formes « ff », « oo », « fo », « of ».
#let intervalle(forme: "ff", a, b) = crochets(forme: forme, $#a #pvfr #b$)

/// \Rep → (O ; I ; J)
#let rep = $lr(\(O #pvfr I #pvfr J\))$
