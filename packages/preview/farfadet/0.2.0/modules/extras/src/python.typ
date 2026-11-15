// python.typ (farfadet-extras) — façade publique du code Python mis en forme : `bf-code-python`.
//
// Une seule commande : `numeros:` pour les numéros de ligne, `style:` pour l'apparence (`"classique"` par
// défaut : fond vert pâle, onglet de titre ; `"sobre"` : cadre fin, bandeau de titre ; ou un style défini par
// `setbfextras(definir: …)`). Les lignes et leur numérotation sont composées par codly (vendor/codly).
// Les couleurs `CouleurVertForet`, `pythonkeyword`, `pythonstring`, `pythoncomment`, `pythonnumber` sont des
// couleurs nommées de bfcours : `setbfcolors(pythonkeyword: orange)` les change.
// Réglages : `setbfextras` (src/regler.typ), type `bf-code-python`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: xcouleur, taille-latex, bf-metriques, bf-espacement-tcb, environnements
#import "moteur/python.typ" as m
#import "reglages.typ": _resoudre, _couleurs

#let _sequence = [a#h(1pt)b].func()

/// Le code d'un `bf-code-python` : une chaîne, un bloc `raw`, ou un corps `[…]` / `#begin … #end` qui contient
/// ce bloc `raw` (les espaces et sauts de ligne autour sont ignorés). Passé par `environnements` d'abord.
#let _corps-code(code) = {
  if type(code) != content { return code }
  let c = environnements(code)
  if c.func() == _sequence {
    let utiles = c.children.filter(x => not (x.func() in (parbreak, [ ].func()) or (x.func() == text and x.text.trim() == "")))
    if utiles.len() == 1 { return utiles.first() }
  }
  c
}

/// Police du titre : valeurs de `fonttitle`, complétées par celles du style.
#let _fonte-titre(valeurs) = {
  let f = (size: "footnotesize", style: "italic", weight: "regular", family: "mono", fill: auto) + valeurs
  (
    taille: taille-latex(f.size),
    style: f.style,
    weight: f.weight,
    family: if f.family == "mono" { "DejaVu Sans Mono" } else { f.family },
    fill: f.fill,
  )
}

/// Code Python mis en forme dans une boîte : coloration, numéros de ligne facultatifs, titre.
///
/// Le style par défaut, `"classique"`, reprend le rendu de `bfcodepython` : fond vert très pâle, cadre vert
/// forêt, coins arrondis en diagonale, titre « Code Python » dans un onglet en haut à droite. Le style
/// `"sobre"` donne un cadre fin gris foncé, un fond blanc, un bandeau de titre sur toute la largeur et une
/// bande grisée derrière les numéros.
///
/// ````typ
/// #bf-code-python(```python
/// def carre(x):
///     # le carré de x
///     return x * x
/// ```)
/// #bf-code-python(numeros: 3, title: "Boucle", style: "sobre", ```python
/// for i in range(3):
///     print(i)
/// ```)
/// ````
///
/// La syntaxe environnement donne le même résultat : `#begin(bf-code-python, numeros: 3)`, le bloc `raw`, puis
/// `#end(bf-code-python)`.
///
/// - code (str, content): le code, en bloc `raw` (```` ```python … ``` ````) ou en chaîne.
/// - numeros (auto, bool, int): `false` : sans numéros ; `true` : numérotées à partir de 1 ; un entier : numéro de
///   la première ligne. Défaut : `auto` (selon les réglages ; `false` au départ).
/// - style (auto, str, array): nom d'un style : `"classique"` (défaut), `"sobre"`, ou défini par
///   `setbfextras(definir: …)`.
/// - ..options (any): clés locales : `title` (`"Code Python"`, `none` supprime le titre), `titre-position`
///   (`"onglet"` ou `"bandeau"`), `colframe`, `colback`, `colbacktitle`, `boxrule`, `arc`, `sharp-corners`, `left`,
///   `right`, `top` (`auto` : interligne de base), `bottom`, `before-skip` et `after-skip` (`auto`), `fonttitle`
///   (dictionnaire : `size`, `style`, `weight`, `family`, `fill`), `onglet` (dictionnaire : `colframe`, `boxrule`,
///   `arc`, `sharp-corners`, `left`, `hauteur`), `basicstyle`, `numberstyle`, `tabsize`, `police`,
///   `pythonkeyword`, `pythonstring`, `pythoncomment`, `pythonnumber`, `keywordstyle2`, `numeros-fond`,
///   `numeros-fond-largeur`, `surligner` (tableau de numéros de lignes), `couleur-surlignage`.
/// -> content
#let bf-code-python(code, numeros: auto, ..options) = context {
  let code = _corps-code(code)
  let local = options.named()
  if numeros != auto { local.insert("numeros", numeros) }
  let r = _couleurs(
    _resoudre("BFCodePython", arguments(..local), commande: "BFCodePython"),
    "colframe", "colback", "colbacktitle", "pythonkeyword", "pythonstring", "pythoncomment", "pythonnumber",
    "keywordstyle2", "numeros-fond", "couleur-surlignage",
  )
  let met = bf-metriques()
  let esp = bf-espacement-tcb(met)
  let theme = m.bf-python-theme(r.pythonkeyword, r.keywordstyle2, r.pythonstring, r.pythoncomment)
  let titre-fill = if r.fonttitle.at("fill", default: auto) == auto {
    if r.titre-position == "onglet" { r.colframe } else { white }
  } else { xcouleur(r.fonttitle.fill) }
  let fonte = _fonte-titre(r.fonttitle + (fill: titre-fill))
  let onglet = r.onglet
  let onglet = (
    colframe: if "colframe" in onglet { xcouleur(onglet.colframe) } else { r.colframe },
    boxrule: if "boxrule" in onglet { onglet.boxrule } else { r.boxrule },
    arc: if "arc" in onglet { onglet.arc } else { r.arc },
    sharp-corners: if "sharp-corners" in onglet { onglet.sharp-corners } else { r.sharp-corners },
    left: if "left" in onglet { onglet.left } else { 7.25pt },
    hauteur: if "hauteur" in onglet { onglet.hauteur } else { 14.75pt },
  )
  m.bf-python-boite(code, (
    title: r.title,
    titre-position: r.titre-position,
    numeros: if r.numeros == true { 1 } else { r.numeros },
    taille: taille-latex(r.basicstyle),
    taille-numeros: taille-latex(r.numberstyle),
    tabsize: r.tabsize,
    police: r.police,
    theme: theme,
    couleur-numeros: r.pythonnumber,
    surligner: r.surligner,
    couleur-surlignage: r.couleur-surlignage,
    colframe: r.colframe, colback: r.colback, colbacktitle: r.colbacktitle,
    boxrule: r.boxrule, arc: r.arc, sharp-corners: r.sharp-corners,
    left: r.left, right: r.right, top: if r.top == auto { met.bs } else { r.top }, bottom: r.bottom,
    above: if r.before-skip == auto { esp.above } else { r.before-skip },
    below: if r.after-skip == auto { esp.below } else { r.after-skip },
    fonttitle: fonte,
    onglet: onglet,
    numeros-fond: r.numeros-fond,
    numeros-fond-largeur: r.numeros-fond-largeur,
  ))
}
