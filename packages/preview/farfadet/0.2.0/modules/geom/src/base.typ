// base.typ (farfadet-geom) — briques communes : accès au style, couleurs, traits, unités, étiquettes.
// Chaque macro de dessin est un `group` cetz dont le corps reçoit le style (posé par `geo`) et le contexte.

#import "@preview/cetz:0.5.3": draw as d
#import "rapide.typ" as _r
#import "reglages.typ": noms-couleurs
#import "outils.typ": *

/// Élément cetz qui lit le style de la figure : `f(g, ctx)` renvoie des éléments de dessin.
///
/// Équivalent exact d'un `d.group` anonyme (même contexte rendu, mêmes tracés), sans ce que le groupe
/// anonyme calcule pour rien : la résolution complète du style « group » (`styles.resolve`) et la pile
/// des groupes. En mode `debug` de cetz (cadres englobants dessinés), on repasse par `d.group`.
#let elem(cmd, f) = (ctx => {
  let g = ctx.at("bfgeom", default: none)
  if g == none {
    panic(cmd + " : à employer dans geo(…) ou figure-geo(…), qui posent le style de farfadet-geom.")
  }
  if ctx.debug { return (d.group(c => f(g, c)).first())(ctx) }
  let corps = f(g, ctx)
  if corps == none { return (ctx: ctx) }
  let c = ctx
  c.groups.push(())
  let traces = ()
  for el in corps {
    let r = el(c)
    if r != none {
      c = r.ctx
      let t = r.at("drawables", default: ())
      if type(t) == dictionary { traces.push(t) } else { traces += t }
      let nom = r.at("name", default: none)
      if nom != none and "anchors" in r {
        // un élément nommé dans une macro : même enregistrement que process.element (portée du groupe)
        c.nodes.insert(nom, r)
        c.groups.last().push(nom)
      }
    }
  }
  ctx.shared-state = c.shared-state
  (ctx: ctx, drawables: traces)
},)

/// Fenêtre courante `((x0, y0), (x1, y1))` (posée par `geo(fenetre: …)` ou par `repere`), ou `none`.
#let fenetre-de(ctx) = ctx.at("bfgeom-fenetre", default: none)

/// Longueur absolue ou nombre → unités du canevas.
#let u(ctx, v) = if type(v) == length { v / ctx.length } else { v }

// ---------- Couleurs et traits ----------

#let couleur-de(g, c, cmd) = {
  if c == auto { g.couleur } else if type(c) == str {
    if c in noms-couleurs { g.at("couleur-" + c) } else {
      panic(cmd + " : couleur inconnue « " + c + " ». Noms possibles : " + noms-couleurs.map(n => "« " + n + " »").join(", ") + ", ou une couleur Typst.")
    }
  } else if type(c) == color { c } else {
    panic(cmd + " : la clé « couleur » attend auto, un nom de couleur ou une couleur Typst ; reçu : " + repr(c) + ".")
  }
}

/// Fond d'une surface : `none`, une couleur Typst, ou un nom de couleur (version claire).
#let fond-de(g, f, cmd) = {
  if f == none { none } else if type(f) == str { couleur-de(g, f, cmd).lighten(80%) } else if type(f) == color { f } else {
    panic(cmd + " : la clé « remplissage » attend none, un nom de couleur ou une couleur Typst ; reçu : " + repr(f) + ".")
  }
}

#let styles-trait = (plein: none, tirets: "dashed", pointilles: "dotted", mixte: "dash-dotted")

/// Trait cetz pour une couleur, une épaisseur et un style (`"plein"`, `"tirets"`, `"pointilles"`, `"mixte"`).
#let trait(g, cmd, couleur: auto, epaisseur: auto, style: "plein") = {
  if style not in styles-trait {
    panic(cmd + " : style de trait inconnu « " + repr(style) + " ». Styles possibles : « plein », « tirets », « pointilles », « mixte ».")
  }
  let e = if epaisseur == auto { g.epaisseur } else { epaisseur }
  let s = (paint: couleur-de(g, couleur, cmd), thickness: e)
  if styles-trait.at(style) != none { s.insert("dash", styles-trait.at(style)) }
  s
}

// ---------- Étiquettes ----------

#let _boussole = ("e", "ne", "n", "no", "o", "so", "s", "se")
#let _ancres = (
  e: "west", ne: "south-west", n: "south", no: "south-east", o: "east", so: "north-east", s: "north", se: "north-west",
)

/// Secteur de boussole (`"e"`, `"ne"`, …) d'une direction donnée par un angle.
#let secteur(a) = _boussole.at(int(calc.rem-euclid(calc.round((a / 1deg) / 45), 8)))

/// Ancre cetz du texte pour une position `pos` du texte autour du point : « ne » = texte au nord-est.
#let ancre-de(pos, cmd) = {
  let cle = if type(pos) == angle { secteur(pos) } else { pos }
  if type(cle) != str or cle not in _ancres {
    panic(cmd + " : position d'étiquette inconnue " + repr(pos) + ". Positions possibles : « n », « s », « e », « o », « ne », « no », « se », « so », ou un angle.")
  }
  _ancres.at(cle)
}

/// Nom de point ou de variable en maths : une chaîne `"A"` devient `$A$`.
#let nom-math(nom, cmd) = {
  if type(nom) == str {
    if nom.match(regex("[A-Z]{2,}")) != none {
      panic(cmd + " : le nom « " + nom + " » contient plusieurs lettres majuscules collées ; en maths, écrire les lettres séparées (« A B ») ou passer un contenu ($A B$).")
    }
    eval("$" + nom + "$")
  } else if type(nom) == content { nom } else {
    panic(cmd + " : le nom doit être une chaîne ou un contenu ; reçu : " + repr(nom) + ".")
  }
}

/// Texte d'étiquette (couleur, taille du document sauf réglage).
#let texte-geom(g, c, contenu) = {
  if g.taille-texte == auto { text(fill: c, contenu) } else { text(fill: c, size: g.taille-texte, contenu) }
}

/// Étiquette `nom` placée autour de `p` (texte au `pos` du point).
#let etiquette(g, p, nom, pos, couleur, cmd) = {
  _r.contenu(
    p,
    texte-geom(g, couleur, nom-math(nom, cmd)),
    anchor: ancre-de(pos, cmd),
    padding: g.espace-etiquette,
  )
}

/// Nom de vecteur surmonté d'une flèche : `"u"` ou `"A B"` devient `$arrow(u)$`.
#let nom-vecteur(nom, cmd) = {
  if type(nom) == str {
    if nom.match(regex("[A-Z]{2,}")) != none {
      panic(cmd + " : le nom « " + nom + " » contient plusieurs lettres majuscules collées ; écrire « A B » ou passer un contenu ($A B$).")
    }
    eval("$arrow(" + nom + ")$")
  } else if type(nom) == content { $arrow(#nom)$ } else {
    panic(cmd + " : le nom du vecteur doit être une chaîne ou un contenu ; reçu : " + repr(nom) + ".")
  }
}

/// Entier de codage (1, 2 ou 3 traits).
#let verifier-codage(n, cmd) = {
  if type(n) != int or n < 1 or n > 3 {
    panic(cmd + " : le nombre de traits de codage est 1, 2 ou 3 ; reçu : " + repr(n) + ".")
  }
}

/// Comme `verifier-codage`, mais renvoie `n`.
#let codage-valide(n, cmd) = {
  verifier-codage(n, cmd)
  n
}
