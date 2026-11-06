// texte.typ — mise en valeur du texte (\acc, \voc, \encadrer, \surligner, connecteurs logiques…)
// et index du vocabulaire (\printvocindex).
//
// Sources : bfcours-commands.sty, bfcours-vocabulary.sty, babel-french (\frquote).
// Cotes relevées sur le rendu LaTeX de référence.

// \voc et \printvocindex sont partis dans farfadet-didactique (moteur/vocabulaire.typ).
#import "../../../socle/lib.typ": interne as _socle
#import _socle: *

#let _sequence = [a *b*].func()

/// Couleur : nom bfcours/xcolor ou valeur Typst (dans un `context`, connaît les \definecolor).
#let _couleur(x) = if type(x) == str { xcouleur(x) } else { x }

/// Texte brut d'un contenu (pour dédoublonner le vocabulaire).
#let bf-texte-brut(c) = {
  if c == none { return "" }
  if type(c) == str { return c }
  if type(c) != content { return str(c) }
  if c.has("text") { return c.text }
  if c.has("children") { return c.children.map(bf-texte-brut).join("") }
  if c.has("body") { return bf-texte-brut(c.body) }
  if c.has("child") { return bf-texte-brut(c.child) }
  if c.func() == [ ].func() { return " " }
  ""
}

/// Contenu à ré-afficher en mode mathématique si c'est une formule nue (appel depuis $…$).
#let _formule(c) = {
  if type(c) != content { return c }
  let maths = (math.frac, math.attach, math.root, math.lr, math.vec, math.mat, math.cases, math.binom, math.op)
  let est-maths(x) = x.func() in maths or (x.func() == _sequence and x.children.any(est-maths))
  if c.func() != math.equation and est-maths(c) { math.equation(block: false, math.display(c)) } else { c }
}

// =====================================================================
// \acc, \voc, \red, \blue, \frquote, \pascalc (puis \vspace, \hspace)
// =====================================================================

/// \acc[couleur]{x} : gras dans la couleur d'accent courante (\currentAccentColor).
/// Les formules gardent leur graisse (Fourier n'a pas de maths grasses sans \boldmath).
#let acc(couleur: auto, corps) = context {
  let c = if couleur == auto { bf-lire(bf-couleur-p) } else { _couleur(couleur) }
  show math.equation: set text(weight: "regular")
  text(fill: c, weight: "bold", corps)
}

/// \frquote{x} (babel-french) : « x » avec espaces insécables.
#let frquote(corps) = [«#sym.space.nobreak#corps#sym.space.nobreak»]

/// \pascalc
#let pascalc() = strong[Calculatrice interdite]

// =====================================================================
// \vspace, \hspace : alias des fonctions natives `v` et `h` de Typst
// =====================================================================
// Pour qui écrit comme en LaTeX. `#v(…)` et `#h(…)` restent la forme native
// (c'est celle que produit le convertisseur). Longueurs Typst : `1cm`, `0.5em`,
// `1fr` (équivalent de \fill / \stretch{1}), négatives admises.
// Comme en LaTeX, la forme simple disparaît en haut de page (vspace) ou en
// début de ligne (hspace) ; `etoile: true` la garde, comme \vspace* / \hspace*.

/// \vspace{l} → #vspace(l) ; \vspace*{l} → #vspace(l, etoile: true).
#let vspace(longueur, etoile: false) = v(longueur, weak: not etoile)

/// \hspace{l} → #hspace(l) ; \hspace*{l} → #hspace(l, etoile: true).
#let hspace(longueur, etoile: false) = h(longueur, weak: not etoile)

// Vrai s'il reste moins de `longueur` entre la position courante et le bas de
// la zone de texte (marge basse comprise : le pied de page est dans la marge).
// À appeler sous `context`.
#let _place-manque(longueur) = {
  let h = page.height
  if h == auto { return false }
  let m = page.margin
  let bas = if type(m) == dictionary { m.at("bottom", default: m.at("y", default: m.at("rest", default: auto))) } else { m }
  if bas == auto { bas = 0.119 * calc.min(page.width, h) }
  if type(bas) == relative { bas = bas.length + bas.ratio * h }
  if type(bas) == ratio { bas = bas * h }
  h - bas.to-absolute() - here().position().y < longueur.to-absolute()
}

/// \Needspace*{l} (paquet needspace) → #needspace(l) : si moins de `l` restent
/// sur la page, passe à la suivante ; sinon ne fait rien. `\baselineskip`
/// vaut 1.2em (interligne du modèle) : \Needspace*{5\baselineskip} → #needspace(6em).
/// Mécanique : un repère de hauteur nulle (`place`, hors flux, qui n'interrompt
/// pas la fusion des espacements faibles) fixe la position courante ; on la
/// compare au bas de la zone de texte. Sinon RIEN n'est inséré : l'écart avec
/// l'élément suivant est identique, au pixel, à celui d'un document sans
/// `needspace`. Si la place manque : un bloc insécable et invisible de hauteur `l`,
/// suivi de `v(-l, weak: true)`. Le bloc ne tient pas : il passe en haut de la page
/// suivante, et l'espacement faible qui le suit absorbe l'espacement de l'élément
/// suivant, exactement comme après un saut de page. (Un `pagebreak` posé dans ce
/// `context` scindait la suite des pages : la mise en page changeait de structure
/// d'un tour à l'autre et Typst refaisait un tour complet, même quand le saut ne
/// déplaçait rien.)
/// Dans un conteneur (`block`, `box`, colonnes), passer `conteneur: true`
/// (bloc insécable de hauteur `l` annulé par `v(-l)`, qui ajoute alors
/// l'espacement de l'élément suivant en haut de la page quand il y a saut).
/// Pas de variante sans étoile : Typst n'a qu'une seule forme.
// L'étiquette `<bf-needspace>` permet à la pagination rejouée (farfadet-modele, paginer.typ) de poser
// son saut AVANT le needspace : posé après, il laisserait une page blanche.
#let needspace(longueur, conteneur: false) = [#context {
  place(top + left, block(height: 0pt, width: 0pt))
  if _place-manque(longueur) {
    block(breakable: false, height: longueur, width: 100%, above: 0pt, below: 0pt)
    v(-longueur, weak: not conteneur)
  }
}<bf-needspace>]

/// \coloredsquare{c} et \dimcoloredsquare{c}{n} : carré plein de n ex (3 par défaut).
#let coloredsquare(couleur, taille: 3) = context box(
  width: taille * 1em * 0.46,
  height: taille * 1em * 0.46,
  fill: _couleur(couleur),
)
#let dimcoloredsquare(couleur, taille) = coloredsquare(couleur, taille: taille)

// =====================================================================
// \encadrer, \surligner (tcbox « on line », sensibles au mode mathématique)
// =====================================================================

/// Boîte en ligne façon tcbox : filet `regle`, marges internes, arc 5 pt, ligne de base conservée.
#let _boite-en-ligne(corps, cadre, fond, texte: auto, x: 3pt, y: 2pt, sep: 0pt, arc: 5pt, regle: 0.4pt, taille: auto) = {
  let interieur = {
    set text(top-edge: "bounds", bottom-edge: "bounds")
    set text(fill: texte) if texte != auto
    set text(size: taille) if taille != auto
    _formule(corps)
  }
  let ptt(v) = v * 72 / 72.27
  box(
    fill: cadre,
    radius: if arc == 0pt { 0pt } else { ptt(arc) },
    inset: ptt(regle),
    outset: (y: 0pt),
    box(
      fill: fond,
      radius: if arc == 0pt { 0pt } else { ptt(arc - regle) },
      inset: (x: ptt(x + sep), y: ptt(y + sep)),
      interieur,
    ),
  )
}

/// Boîte en ligne façon tcbox, à longueurs RÉELLES (Typst) et marges indépendantes : c'est la forme que
/// la façade règle (clés tcolorbox `left`, `right`, `top`, `bottom`, `boxsep`, `boxrule`, `arc`).
/// Aucune conversion « point TeX → point Typst » ici : la façade passe `ptl(3)` pour retrouver LaTeX.
#let boite-en-ligne(
  corps, cadre, fond, texte: auto, gauche: ptl(3), droite: ptl(3), haut: ptl(2), bas: ptl(2),
  sep: 0pt, arc: ptl(5), regle: ptl(0.4), taille: auto,
) = {
  let interieur = {
    set text(top-edge: "bounds", bottom-edge: "bounds")
    set text(fill: texte) if texte != auto
    set text(size: taille) if taille != auto
    _formule(corps)
  }
  box(
    fill: cadre,
    radius: if arc == 0pt { 0pt } else { arc },
    inset: regle,
    outset: (y: 0pt),
    box(
      fill: fond,
      radius: if arc == 0pt { 0pt } else { calc.max(0pt, arc - regle) },
      inset: (left: gauche + sep, right: droite + sep, top: haut + sep, bottom: bas + sep),
      interieur,
    ),
  )
}

/// \encadrer[couleur]{x} : fond couleur!5, filet couleur!75!black, texte noir.
/// En mode mathématique, passer la formule en contenu mathématique : $f(x) = #encadrer($1/x$)$.
#let encadrer(couleur: "blue", corps) = context {
  let c = _couleur(couleur)
  _boite-en-ligne(corps, xmix(c, 75, autre: black), xmix(c, 5), texte: black, sep: 1pt)
}

/// \surligner[couleur]{x} : fond et filet couleur!10, texte couleur!75!black.
#let surligner(couleur: "blue", corps) = context {
  let c = _couleur(couleur)
  _boite-en-ligne(corps, xmix(c, 10), xmix(c, 10), texte: xmix(c, 75, autre: black))
}

// =====================================================================
// Connecteurs logiques : \Si, \Alors, \Donc, \Et, \Mais, \Car, \Puisque, \SSI
// =====================================================================

#let _connecteur(mot, couleur, taille) = context {
  let c = _couleur(couleur)
  [#_boite-en-ligne(
      mot,
      xmix(c, 10),
      xmix(c, 10),
      texte: xmix(c, 75, autre: black),
      arc: 0pt,
      taille: taille-latex(taille),
    ) ]
}

#let si(couleur: "red") = _connecteur([Si], couleur, "large")
#let alors(couleur: "blue") = _connecteur([Alors], couleur, "large")
#let donc(couleur: "purple") = _connecteur([Donc], couleur, "large")
#let et(couleur: "green") = _connecteur([Et], couleur, "large")
#let mais(couleur: "red") = _connecteur([Mais], couleur, "large")
#let car(couleur: "green") = _connecteur([Car], couleur, "large")
#let puisque(couleur: "purple") = _connecteur([Puisque], couleur, "large")
#let ssi(couleur: "purple") = _connecteur([si et seulement si], couleur, "normalsize")
