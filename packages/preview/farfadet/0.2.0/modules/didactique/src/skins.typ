// skins.typ (farfadet-didactique) — registre des skins des environnements didactiques.
//
// Un skin est une fonction `d => contenu` qui dessine la boîte d'un environnement à partir d'un
// dictionnaire `d` entièrement résolu (contrat : skins/CONTRAT.md). Le moteur (`_rendre`, construction.typ)
// garde la numérotation, l'étiquette, le sommaire, la carte Anki et la version prof/élève : le skin ne
// fait que dessiner.
//
// Un skin s'emploie par la clé `rendu` (sur l'appel, par `setbfenvironments`, par un style nommé), soit
// directement (`rendu: mon-skin`), soit par un nom enregistré ici (`setbfskins(bristol: mon-skin)`, puis
// `rendu: "bristol"`).

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-liste, bf-etat, bf-maj, bf-lire

#import "galerie/icones.typ": icone as _icone
#import "galerie/cahier.typ" as _cahier
#import "galerie/outil.typ" as _outil
#import "galerie/pastille.typ" as _pastille
#import "galerie/manchette.typ" as _manchette
#import "galerie/filet.typ" as _filet
#import "galerie/suspendu.typ" as _suspendu
#import "galerie/minimal.typ" as _minimal

/// Rendus intégrés au moteur (`bf` : rendu de bfcours ; `rd` : boîtes de rdboites), réservés.
#let _rendus-integres = ("bf", "rd")

/// Skins intégrés au paquet (src/galerie/), disponibles par leur nom sans rien enregistrer, génériques
/// (utilisables par n'importe quel environnement) et réglables par la clé `skin:`. Noms réservés.
#let _skins-integres = (
  cahier: _cahier.skin,
  outil: _outil.skin,
  pastille: _pastille.skin,
  manchette: _manchette.skin,
  filet: _filet.skin,
  suspendu: _suspendu.skin,
  minimal: _minimal.skin,
)

/// Skins enregistrés : (nom: fonction).
#let _skins-p = bf-etat("bfd-skins", (:))
#let _skins = _skins-p.etat

/// Enregistre des skins sous un nom, pour la suite du document : `rendu: "<nom>"` les appelle ensuite
/// partout où la clé `rendu` est acceptée (sur l'environnement, `setbfenvironments(pour: …, rendu: …)`,
/// `setbfenvironments(rendu: …)`, style nommé). Un nom déjà enregistré est remplacé.
///
/// Un skin est une fonction `d => contenu` : elle reçoit un dictionnaire résolu (`type`, `nom`, `numero`,
/// `titre`, `corps`, `couleur`, `fond`, `cadre`, `couleur-titre`, `icone`, `breakable`, `avant`, `apres`,
/// `options`, `auteur`, `explicites`, `r`) et dessine la boîte. Elle ne gère ni la numérotation, ni
/// l'étiquette, ni le sommaire, ni Anki, ni la version prof/élève. Contrat complet : `skins/CONTRAT.md`.
///
/// ```example
/// #let filet(d) = block(stroke: (left: 2pt + d.couleur), inset: (left: 8pt, y: 4pt), breakable: d.breakable)[
///   #smallcaps(d.nom)#if d.numero != none [ #d.numero]#if d.titre != none [ — #d.titre] \ #d.corps
/// ]
/// #setbfskins(filet: filet)
/// #definition(rendu: "filet")[Vecteur][Direction, sens et norme.]
/// ```
///
/// - reinitialiser (bool): `true` oublie d'abord tous les skins enregistrés.
/// - skins (function): `nom: fonction`, autant que voulu. Les noms `"bf"`, `"rd"` et ceux des skins intégrés (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`, `"suspendu"`, `"minimal"`) sont réservés. Une variante d'un skin (`bfskin("suspendu", icone: "cle")`) est une fonction : elle s'enregistre comme un autre skin.
/// -> content
#let setbfskins(reinitialiser: false, ..skins) = {
  if type(reinitialiser) != bool {
    panic("setbfskins : la clé « reinitialiser » attend true ou false ; reçu : " + repr(reinitialiser) + ".")
  }
  if skins.pos().len() > 0 {
    panic("setbfskins : les skins s'écrivent en arguments nommés (nom: fonction) ; reçu : " + repr(skins.pos().first()) + ".")
  }
  for (nom, f) in skins.named() {
    if nom in _rendus-integres or nom in _skins-integres {
      panic("setbfskins : le nom « " + nom + " » est réservé à un rendu intégré (" + reglages-liste(_rendus-integres + _skins-integres.keys()) + ") ; choisir un autre nom, ou en faire une variante : bfskin(\"" + nom + "\", …).")
    }
    if type(f) != function {
      panic("setbfskins : le skin « " + nom + " » doit être une fonction d => contenu ; reçu : " + repr(f) + ".")
    }
  }
  bf-maj(_skins-p, s => (if reinitialiser { (:) } else { s }) + skins.named())
}

// =====================================================================
// Outils à la craie offerts aux skins (champ `d.outils` du contrat)
// =====================================================================
//
// Un skin est compilé seul : il ne peut pas importer la copie de chalks du paquet (`vendor/chalks/`). Le moteur
// lui en passe donc quelques outils, des fonctions simples à paramètres nommés. Le trait est le même que celui
// de la Démonstration (`bf-craie`) ; la couleur par défaut est celle de l'environnement. Le tracé est
// dérivé de la géométrie : deux compilations donnent la même image.

#import "../vendor/chalks/lib.typ" as chalks

/// Trait de craie de base (celui du cadre de la Démonstration).
#let _craie-trait = (roughness: 1.3, taper: 0.5, passes: 2)

/// Teinte d'un outil : `auto` prend la couleur de l'environnement.
#let _teinte-craie(couleur, defaut) = if couleur == auto { defaut } else { couleur }

/// Outils à la craie, à la teinte `defaut` (couleur de l'environnement) quand `couleur: auto`.
/// Retourne le dictionnaire `d.outils` : `icone`, `cadre-craie`, `trait-craie`, `souligner-craie`, `cercle-craie`.
/// Contrat et exemples : skins/CONTRAT.md.
#let _outils(defaut) = (
  /// Icône dessinée du jeu commun (`coche`, `etoile`, `etoile5`, `cle`, `roue`, `implique`, `fanion`,
  /// `equerre`, `attention`, `loupe`, `fleche`), une fonction `couleur => contenu`, un contenu ou `none`.
  /// `couleur: auto` prend la teinte de l'environnement ; un nom inconnu arrête la compilation.
  icone: (nom, taille: 1em, couleur: auto, pastille: auto) => _icone(
    nom, taille: taille, couleur: _teinte-craie(couleur, defaut), pastille: pastille,
  ),
  /// Cadre à la craie autour d'un contenu, à la largeur courante. Insécable : un contenu plus haut que la
  /// page n'est pas coupé (pour un skin `breakable`, n'en entourer qu'un titre ou un résumé).
  cadre-craie: (contenu, couleur: auto, epaisseur: 1.6, fond: none, marge: 6pt) => layout(taille => {
    let L = taille.width
    let interieur = L - 2 * marge
    let H = measure(block(width: interieur, contenu)).height + 2 * marge
    // le lissage borne le dépassement du tracé hors du rectangle (comme le cadre de la Démonstration)
    let lissage = calc.min(0.2, 6.0 / calc.max(L.pt(), H.pt(), 1.0))
    block(width: L, height: H, breakable: false, fill: fond, {
      place(top + left, chalks.sketch(
        L, H,
        chalks.rect((0, 0), (L.pt(), H.pt()), .._craie-trait, width: epaisseur, color: _teinte-craie(couleur, defaut), smoothness: lissage),
      ))
      place(top + left, dx: marge, dy: marge, block(width: interieur, contenu))
    })
  }),
  /// Trait horizontal à la craie, sur la largeur courante (`longueur: auto`) ou une longueur donnée.
  trait-craie: (couleur: auto, epaisseur: 1.6, longueur: auto) => layout(taille => {
    let l = if longueur == auto { taille.width } else { longueur }
    block(width: l, height: 5pt, above: 0pt, below: 0pt, chalks.sketch(
      l, 5pt,
      chalks.line((0, 2.5), (l.pt(), 2.5), .._craie-trait, width: epaisseur, color: _teinte-craie(couleur, defaut)),
    ))
  }),
  /// Souligne à la craie un contenu court, tenant sur une seule ligne (inline).
  souligner-craie: (contenu, couleur: auto, epaisseur: 1.4) => context {
    let g = measure(contenu)
    box({
      contenu
      place(bottom + left, dy: 6pt, chalks.sketch(
        g.width, 5pt,
        chalks.line((0, 2.5), (g.width.pt(), 2.5), .._craie-trait, width: epaisseur, color: _teinte-craie(couleur, defaut)),
      ))
    })
  },
  /// Entoure à la craie un contenu court, tenant sur une seule ligne (inline) : ovale tracé autour du mot.
  cercle-craie: (contenu, couleur: auto, epaisseur: 1.4) => context {
    let g = measure(contenu)
    // l'ovale déborde un peu du contenu (rayons 0,6 × la largeur, 0,75 × la hauteur, plus une marge) pour ne
    // pas mordre sur les lettres
    let (rx, ry) = (0.6 * g.width + 4pt, 0.75 * g.height + 2pt)
    let (W, H) = (2 * rx, 2 * ry)
    box(width: W, height: H, baseline: (H - g.height) / 2, {
      place(top + left, chalks.sketch(
        W, H,
        chalks.ellipse((rx.pt(), ry.pt()), (rx.pt(), ry.pt()), .._craie-trait, width: epaisseur, color: _teinte-craie(couleur, defaut)),
      ))
      place(top + left, dx: (W - g.width) / 2, dy: (H - g.height) / 2, contenu)
    })
  },
)

/// Fonction de rendu désignée par la valeur `rendu` : `none` pour les rendus intégrés (`"bf"`, `"rd"`),
/// sinon la fonction du skin. Un nom inconnu arrête la compilation avec la liste des rendus possibles.
/// À appeler dans un `context`.
#let _skin(id, rendu) = {
  if type(rendu) == function { return rendu }
  if rendu in _rendus-integres { return none }
  if rendu in _skins-integres { return _skins-integres.at(rendu) }
  let connus = bf-lire(_skins-p)
  if rendu not in connus {
    panic(
      id + " : rendu inconnu « " + rendu + " ». Rendus possibles : "
        + reglages-liste(_rendus-integres + _skins-integres.keys() + connus.keys())
        + " (un skin s'enregistre par setbfskins(nom: fonction), ou se passe directement : rendu: ma-fonction).",
    )
  }
  connus.at(rendu)
}

/// Variante d'un skin : un skin (fonction `d => contenu`) dont certaines options sont figées.
///
/// `base` est le nom d'un skin intégré (`"cahier"`, `"outil"`, `"pastille"`, `"manchette"`, `"filet"`,
/// `"suspendu"`, `"minimal"`) ou enregistré par `setbfskins`, ou une fonction skin. Les options données ici sont les
/// valeurs par défaut de la variante ; celles de la clé `skin:` de l'appel (ou d'un réglage) l'emportent.
/// La variante s'emploie directement (`rendu: bfskin(…)`) ou s'enregistre sous un nom (`setbfskins`).
///
/// ```example
/// #setbfskins(cle-rouge: bfskin("suspendu", icone: "cle", epaisseur: 1.6pt))
/// #setbfenvironments(pour: "Theoreme", rendu: "cle-rouge")
/// #definition(rendu: bfskin("manchette", icone: "fanion"))[Vecteur][Direction, sens et norme.]
/// ```
///
/// - base (str, function): skin de départ, par son nom ou sa fonction.
/// - options (any): options figées, en arguments nommés (`icone: "cle"`, `epaisseur: 2pt`…) ; ce sont celles du skin de base (clé `skin:`).
/// -> function
#let bfskin(base, ..options) = {
  if type(base) not in (str, function) {
    panic("bfskin : le skin de base est un nom (« manchette »…) ou une fonction d => contenu ; reçu : " + repr(base) + ".")
  }
  if type(base) == str and base in _rendus-integres {
    panic("bfskin : « " + base + " » est un rendu du moteur, pas un skin : une variante part d'un skin (" + reglages-liste(_skins-integres.keys()) + ", un skin enregistré ou une fonction).")
  }
  if options.pos().len() > 0 {
    panic("bfskin : les options s'écrivent en arguments nommés (icone: \"cle\") ; reçu : " + repr(options.pos().first()) + ".")
  }
  let figees = options.named()
  d => {
    let profondeur = d.at("variante", default: 0)
    if profondeur >= 8 {
      panic("bfskin : variantes imbriquées sur plus de huit niveaux (une variante enregistrée sous un nom s'appelle-t-elle elle-même ?).")
    }
    let f = if type(base) == function { base } else { _skin("bfskin", base) }
    f(d + (options: figees + d.options, variante: profondeur + 1))
  }
}
