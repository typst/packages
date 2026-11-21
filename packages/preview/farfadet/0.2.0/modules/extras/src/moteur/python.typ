// python.typ (moteur de farfadet-extras) — boîte de code Python.
//
// MOTEUR : noms exportés par ../../interne.typ (STABLES). Paramètres DÉJÀ RÉSOLUS (couleurs Typst, longueurs
// absolues) : la résolution des réglages est faite par la façade (../python.typ).
//
// Les lignes, leur numérotation, les surlignages et l'indentation intelligente viennent du paquet Universe
// `codly` (embarqué dans ../../vendor/codly) ; la coloration vient de Typst (`raw`), avec un thème fabriqué à
// partir des couleurs du .sty (`pythonkeyword`, `pythonstring`, `pythoncomment`, `pythonnumber`, magenta pour la
// classe de mots 2). Le cadre (coins arrondis en diagonale, onglet de titre) est dessiné ici : codly n'accepte
// qu'un seul rayon pour tous les coins.

#import "@preview/codly:2.0.0" as codly

/// Thème de coloration (format TextMate, octets) pour `raw(theme: …)`.
///
/// - mots (color): mots-clés (`keywordstyle`).
/// - mots2 (color): fonctions et types prédéfinis (`keywordstyle=[2]`).
/// - chaines (color): chaînes de caractères (`stringstyle`).
/// - commentaires (color): commentaires, en italique (`commentstyle`).
/// -> bytes
#let bf-python-theme(mots, mots2, chaines, commentaires, texte: black) = {
  let regle(portee, couleur, style: none) = (
    "<dict><key>scope</key><string>" + portee + "</string><key>settings</key><dict><key>foreground</key><string>"
      + rgb(couleur).to-hex() + "</string>" + (if style != none { "<key>fontStyle</key><string>" + style + "</string>" } else { "" })
      + "</dict></dict>"
  )
  bytes(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><plist version=\"1.0\"><dict><key>name</key><string>bfcours-python</string>"
      + "<key>settings</key><array><dict><key>settings</key><dict><key>foreground</key><string>"
      + rgb(texte).to-hex() + "</string></dict></dict>"
      + regle("comment", commentaires, style: "italic")
      + regle("string", chaines)
      + regle("keyword.control, keyword.operator.logical, keyword.operator.word, storage.type, storage.modifier, constant.language", mots)
      + regle("support.function, support.type, support.class", mots2)
      + "</array></dict></plist>",
  )
}

/// Rayons des quatre coins pour la clé `sharp-corners` de tcolorbox : `"downhill"` rend carrés le coin
/// haut gauche et le coin bas droit, `"uphill"` les deux autres, etc.
///
/// - arc (length): rayon des coins arrondis.
/// - mode (str): `"none"`, `"all"`, `"downhill"`, `"uphill"`, `"north"`, `"south"`, `"east"`, `"west"`.
/// -> dictionary
#let bf-python-coins(arc, mode) = {
  let carres = (
    "none": (), all: ("tl", "tr", "br", "bl"), downhill: ("tl", "br"), uphill: ("tr", "bl"),
    north: ("tl", "tr"), south: ("bl", "br"), east: ("tr", "br"), west: ("tl", "bl"),
  ).at(mode)
  (
    top-left: if "tl" in carres { 0pt } else { arc },
    top-right: if "tr" in carres { 0pt } else { arc },
    bottom-right: if "br" in carres { 0pt } else { arc },
    bottom-left: if "bl" in carres { 0pt } else { arc },
  )
}

/// Le code lui-même, composé par codly : lignes numérotées ou non, surlignage, coloration.
///
/// - texte (str): le code, sans saut de ligne final.
/// - r (dictionary): valeurs résolues : `taille`, `taille-numeros` (longueurs), `numeros` (`false` ou numéro de
///   la première ligne), `tabsize`, `police`, `theme` (octets), `couleur-numeros`, `surligner` (tableau de numéros
///   de lignes), `couleur-surlignage`.
/// -> content
#let _code-codly(texte, r) = {
  let numero = n => text(size: r.taille-numeros, fill: r.couleur-numeros, str(n))
  let decalage = if r.numeros == false { 0 } else { r.numeros - 1 }
  let surlignees = r.surligner.map(n => (n, r.couleur-surlignage))
  {
    set text(size: r.taille)
    set text(font: r.police) if r.police != auto
    set par(justify: false)
    show: codly.line-set_(fill: none, stroke: none, radius: 0pt, inset: (x: 0.4em, y: 0.22em))
    show: codly.number-set_(numbering: (..n) => numero(n.pos().first()), align: right + top)
    codly.new(
      raw(texte, lang: "python", block: true, theme: r.theme, tab-size: r.tabsize),
      file: none,
      lang-position: none,
      number-enabled: r.numeros != false,
      offset: decalage,
      radius: 0pt,
      padding: 0pt,
      smart-indent: false,
      highlighted: surlignees,
    )
  }
}

/// Boîte de code Python : cadre, titre (onglet en haut à droite ou bandeau pleine largeur), numéros de ligne.
///
/// - code (str, content): le code (une chaîne ou un bloc `raw`).
/// - r (dictionary): valeurs résolues (voir la façade) : en plus de celles de `_code-codly` : `title`,
///   `titre-position` (`"onglet"` ou `"bandeau"`), `colframe`, `colback`, `colbacktitle`, `boxrule`, `arc`,
///   `sharp-corners`, `left`, `right`, `top`, `bottom`, `above`, `below`, `fonttitle` (`taille`, `style`,
///   `weight`, `family`, `fill`), `onglet` (`arc`, `sharp-corners`, `left`, `hauteur`, `boxrule`, `colframe`),
///   `numeros-fond` (`none` ou couleur), `numeros-fond-largeur`.
/// -> content
#let bf-python-boite(code, r) = {
  let texte = if type(code) == str { code } else if type(code) == content and code.func() == raw { code.text } else {
    panic("bf-code-python : une chaîne ou un bloc ```python … ``` est attendu, reçu : " + repr(code) + ".")
  }
  let texte = texte.trim("\n", at: end)
  let corps = _code-codly(texte, r)
  let titre-texte(t) = {
    set text(size: r.fonttitle.taille, fill: r.fonttitle.fill, style: r.fonttitle.style, weight: r.fonttitle.weight)
    set text(font: r.fonttitle.family) if r.fonttitle.family != auto
    t
  }
  let rayons = bf-python-coins(r.arc, r.sharp-corners)
  if r.titre-position == "onglet" {
    let onglet = r.onglet
    let titre = if r.title == none { none } else {
      place(
        top + right, dx: r.right + 0pt, dy: -r.top,
        box(
          fill: r.colbacktitle,
          stroke: onglet.boxrule + onglet.colframe,
          radius: bf-python-coins(onglet.arc, onglet.sharp-corners),
          height: onglet.hauteur,
          inset: (x: onglet.left, y: 0pt),
          align(horizon, titre-texte(r.title)),
        ),
      )
    }
    block(
      width: 100%, above: r.above, below: r.below, breakable: false,
      fill: r.colback, stroke: r.boxrule + r.colframe, radius: rayons,
      inset: (left: r.left, right: r.right, top: r.top, bottom: r.bottom),
      { titre; corps },
    )
  } else {
    block(
      width: 100%, above: r.above, below: r.below, breakable: false, clip: true,
      fill: r.colback, stroke: r.boxrule + r.colframe, radius: rayons, inset: 0pt,
      layout(size => {
        let part = calc.min(r.numeros-fond-largeur.to-absolute() / size.width, 1)
        let fond = if r.numeros-fond != none and r.numeros != false {
          gradient.linear((r.numeros-fond, 0%), (r.numeros-fond, part * 100%), (r.colback, part * 100%), (r.colback, 100%))
        } else { r.colback }
        if r.title != none {
          block(width: 100%, fill: r.colbacktitle, inset: (x: r.left, y: 2.2pt), above: 0pt, below: 0pt, align(center, titre-texte(r.title)))
        }
        block(
          width: 100%, above: 0pt, below: 0pt, fill: fond,
          inset: (left: r.left, right: r.right, top: r.top, bottom: r.bottom),
          corps,
        )
      }),
    )
  }
}
