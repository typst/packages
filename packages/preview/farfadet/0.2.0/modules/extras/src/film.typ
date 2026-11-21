// film.typ (farfadet-extras) — façade publique de la pellicule de film.
//
// Noms publics : `filmbox` (une seule commande, `n:` vignettes par rangée, `mode:` image / rogne / texte),
// `filmt` (vignette bicolore), `clip-image`, `whitebox`, `colored-small-box` (pièces pour composer une bande à la
// main). Les images se passent en CONTENU (`image("a.png")`) : un chemin écrit en chaîne serait lu depuis le
// dossier du paquet, pas depuis celui du document.
// Réglages : `setbfextras` (src/regler.typ), types `filmbox`, `filmbox-rogne`, `filmbox-texte`, `filmt`
// (groupe `film`).

#import "../../socle/lib.typ": interne as _socle
#import _socle: xcouleur, environnements, decouper-items, item-corps, item-options
#import "moteur/film.typ" as m
#import "reglages.typ": _resoudre, _couleurs

/// Dimensions et couleurs communes, résolues pour le type `type` (dans un `context`).
#let _cadre(r, milieu, haut-alterne: true) = {
  let r = _couleurs(r, "fond", "perforation-couleur", "ColoredSmallBox", "couleur-texte")
  let n = r.perforations
  let haut = m.bf-film-perforations(
    m.bf-film-couleurs-haut(n, r.ColoredSmallBox, r.perforation-couleur, alterner: haut-alterne),
    r.perforation-largeur,
    r.perforation-hauteur,
  )
  let bas = m.bf-film-perforations((r.perforation-couleur,) * n, r.perforation-largeur, r.perforation-hauteur)
  m.bf-film-cadre(
    haut, milieu, bas, r.largeur, r.fond, r.marge, r.ecart-haut, r.ecart-bas,
    texte: r.couleur-texte,
  )
}

/// Une perforation, centrée entre deux ressorts `h(1fr)`, à placer dans une `box` de largeur fixée pour composer
/// une bande à la main.
///
/// ```typ
/// #box(width: 4cm, fill: black, height: 6mm)[#whitebox()#whitebox()#whitebox()]
/// ```
///
/// - ..options (any): clés du type `filmbox` : `perforation-largeur`, `perforation-hauteur`, `perforation-couleur`, `style`.
/// -> content
#let whitebox(..options) = context {
  let r = _couleurs(_resoudre("filmbox", options, commande: "whitebox"), "perforation-couleur")
  h(1fr)
  box(width: r.perforation-largeur, height: r.perforation-hauteur, fill: r.perforation-couleur, baseline: -1mm)
  h(1fr)
}

/// Une perforation de la couleur de la clé `colored-small-box` (blanche par défaut ; se règle par
/// `setbfextras(pour: "film", ColoredSmallBox: …)`), entre deux ressorts `h(1fr)`.
///
/// ```typ
/// #setbfextras(pour: "film", ColoredSmallBox: "orange")
/// #box(width: 4cm, fill: black, height: 6mm)[#colored-small-box()#whitebox()#colored-small-box()]
/// #setbfextras(reinitialiser: true)
/// ```
///
/// - ..options (any): clés du type `filmbox` : `colored-small-box`, `perforation-largeur`, `perforation-hauteur`, `style`.
/// -> content
#let colored-small-box(..options) = context {
  let r = _couleurs(_resoudre("filmbox", options, commande: "ColoredSmallBox"), "ColoredSmallBox")
  h(1fr)
  box(width: r.perforation-largeur, height: r.perforation-hauteur, fill: r.ColoredSmallBox, baseline: -1mm)
  h(1fr)
}

/// L'image est mise à l'échelle pour couvrir la zone `largeur × hauteur`, puis rognée à droite ou en bas
/// (le coin haut gauche est conservé).
///
/// ```typ
/// #clip-image(2cm, 3cm, rect(width: 4cm, height: 3cm, fill: gradient.linear(red, blue))[A])
/// ```
///
/// La syntaxe environnement donne le même résultat : `#begin(clip-image, 2cm, 3cm)`, l'image, puis
/// `#end(clip-image)`.
///
/// - largeur (length): largeur de la zone.
/// - hauteur (length): hauteur de la zone.
/// - image (content): l'image, en contenu (`image("a.png")`).
/// -> content
#let clip-image(largeur, hauteur, image) = {
  let image = if type(image) == content { environnements(image) } else { image }
  m.bf-film-clip(largeur, hauteur, image)
}

/// Les vignettes de `filmbox` : UN SEUL corps, une vignette par `-` (ou le même corps entre `#begin`/`#end`).
/// L'ancienne écriture, une vignette par argument `filmbox(a, b, c)`, arrête la compilation.
#let _vignettes(pos) = {
  let exemple = "    #filmbox(mode: \"rogne\")[\n      - #image(\"a.png\")\n      - #image(\"b.png\")\n    ]"
  if pos.len() == 0 {
    panic("filmbox : le corps est manquant. Écrire une vignette par ligne (« - ») :\n" + exemple)
  }
  if pos.len() > 1 or type(pos.first()) != content {
    panic(
      "filmbox : l'écriture `filmbox(a, b, c)`, une vignette par argument, n'existe plus. Écrire UN SEUL corps, "
        + "avec une vignette par ligne (« - ») :\n" + exemple,
    )
  }
  decouper-items(environnements(pos.first()), puce: "-").map(i => {
    if item-options(i).len() > 0 {
      panic("filmbox : `tcbitem` n'existe pas dans filmbox ; écrire simplement « - » devant la vignette.")
    }
    item-corps(i)
  })
}

/// Types du registre selon le mode.
#let _types-modes = (image: "filmbox", rogne: "filmbox-rogne", texte: "filmbox-texte")

/// Une vignette (un cadre de film) selon le mode.
#let _vignette(mode, contenu, options) = {
  let type = _types-modes.at(mode)
  let r = _resoudre(type, options, commande: "filmbox")
  if mode == "image" {
    _cadre(r, m.bf-film-image-largeur(contenu, r.image-largeur), haut-alterne: false)
  } else if mode == "rogne" {
    _cadre(r, m.bf-film-clip(r.image-largeur, r.image-hauteur, contenu))
  } else {
    _cadre(r, block(width: 100%, align(center, contenu)))
  }
}

/// Pellicule de film : un cadre noir percé de perforations en haut et en bas autour de chaque contenu. Une seule
/// commande pour une vignette isolée comme pour une rangée : `n` vignettes par ligne, les suivantes passent à la
/// ligne.
///
/// Trois modes :
/// - `"image"` (défaut) : cadre de 3,2 cm, image à 3 cm de large (proportions conservées) ;
/// - `"rogne"` : l'image est rognée à 3 × 3 cm (`clip-image`) et la bande haute alterne perforations colorées
///   (`colored-small-box`) et blanches ;
/// - `"texte"` : cadre de 4,5 cm autour d'un contenu quelconque, centré. Le texte noir sur le fond noir est
///   invisible : posez-le sur un fond clair (`box(fill: white)[…]`) ou réglez `couleur-texte: white`.
///
/// ```typ
/// #let im(t) = rect(width: 4cm, height: 3cm, fill: luma(200))[#t]
/// #filmbox[- #im[A]]
/// #filmbox(mode: "rogne")[
///   - #im[A]
///   - #im[B]
///   - #im[C]
/// ]
/// #filmbox(mode: "rogne", n: 3, largeur: 2.8cm, image-largeur: 2.6cm, image-hauteur: 2.6cm)[
///   - #im[1]
///   - #im[2]
///   - #im[3]
///   - #im[4]
///   - #im[5]
/// ]
/// ```
///
/// Le corps est UN SEUL bloc `[…]` : une vignette par `-`. La syntaxe environnement donne le même résultat :
/// `#begin(filmbox, mode: "rogne")`, les `-`, puis `#end(filmbox)`. L'ancienne écriture `filmbox(a, b, c)`
/// (une vignette par argument) arrête la compilation avec cet exemple.
///
/// - ..contenus (content): le corps : une vignette par `-` (images en contenu, `image("a.png")`).
/// - n (auto, int): nombre de vignettes par rangée ; `auto` : toutes sur une seule rangée.
/// - mode (str): `"image"`, `"rogne"` ou `"texte"`.
/// - ..options (any): clés locales : `largeur` (3,2 cm ; 4,5 cm en mode texte), `image-largeur` (3 cm),
///   `image-hauteur` (3 cm, mode rogne), `fond` (noir), `perforations` (9), `perforation-largeur` (1,8 mm),
///   `perforation-hauteur` (2,8 mm), `perforation-couleur` (blanc), `colored-small-box` (blanc, modes rogne et
///   texte), `marge` (1 mm), `ecart-haut` (3,83 pt), `ecart-bas` (4,02 pt), `couleur-texte`, `style`.
/// -> content
#let filmbox(..contenus, n: auto, mode: "image") = {
  let liste = _vignettes(contenus.pos())
  context {
    assert(mode in _types-modes, message: "filmbox : `mode` doit valoir \"image\", \"rogne\" ou \"texte\" ; reçu : " + repr(mode) + ".")
    assert(n == auto or (type(n) == int and n >= 1), message: "filmbox : `n` doit valoir auto ou un entier d'au moins 1 ; reçu : " + repr(n) + ".")
    assert(liste.len() >= 1, message: "filmbox : au moins une vignette est attendue.")
    let options = arguments(..contenus.named())
    if liste.len() == 1 {
      _vignette(mode, liste.first(), options)
    } else {
      let par-rangee = if n == auto { liste.len() } else { n }
      for debut in range(0, liste.len(), step: par-rangee) {
        block(width: 100%, breakable: false, {
          for c in liste.slice(debut, calc.min(debut + par-rangee, liste.len())) { _vignette(mode, c, options) }
        })
      }
    }
  }
}

/// Vignette bicolore dans un cadre de film : partie haute blanche (`haut`), partie basse grise (`bas`), cadre
/// noir, hauteur totale `hauteur`.
///
/// ```typ
/// #filmt[Question][Réponse]
/// #filmt(largeur: 3.5cm, hauteur: 4cm, colbacklower: "yellow!40")[Énoncé][Solution]
/// ```
///
/// - haut (content): contenu de la partie haute.
/// - bas (content): contenu de la partie basse.
/// - ..options (any): clés locales : `largeur` (4,7 cm), `hauteur` (6 cm), `colback` (blanc), `colbacklower` (`gray!50`),
///   `colframe` (noir), `boxrule` (0,5 mm), `arc` (1 mm), `boxsep` (1 mm), `left`, `right`, `top`, `bottom` (4 pt) ;
///   et celles du cadre de film : `fond`, `perforations`, `perforation-largeur`, `perforation-hauteur`,
///   `perforation-couleur`, `colored-small-box`, `marge`, `ecart-haut`, `ecart-bas`, `couleur-texte`, `style`.
/// -> content
#let filmt(haut, bas, ..options) = context {
  let r = _resoudre("filmt", options)
  let b = _couleurs(r, "colback", "colbacklower", "colframe")
  let milieu = m.bf-film-boite-bicolore(haut, bas, (
    hauteur: b.hauteur, colback: b.colback, colbacklower: b.colbacklower, colframe: b.colframe,
    boxrule: b.boxrule, arc: b.arc,
    gauche: b.left + b.boxsep, droite: b.right + b.boxsep, dessus: b.top + b.boxsep, dessous: b.bottom + b.boxsep,
  ))
  _cadre(r, milieu)
}
