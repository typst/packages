// construction.typ — pont entre la façade (clés nommées) et le moteur de farfadet-didactique.
//
// - `_rendre` : cœur commun (lecture des positionnels, résolution des réglages par le socle,
//   version prof/élève, numérotation et étiquette, carte Anki) ;
// - `_construire` : un constructeur par type (nom LaTeX exact), qui traduit les réglages résolus en
//   appel du moteur ;
// - couleurs : une couleur `auto` prend la teinte de la palette COURANTE (nom LaTeX `thm`, `defi`…,
//   lu dans les couleurs définies par `definecolor` / `bfd-activate-palette`).
// Rien ici n'est public : lib.typ n'exporte que les noms de didactique.typ et des autres façades.

#import "moteur/didactique.typ" as m
#import "moteur/sectionnement.typ": bf-numero-section
#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-couleur-nommee, bf-resoudre-couleur, bfdsetcolors, est-correction, reglages-courants, reglages-liste,
  reglages-resoudre, taille-latex, tf-correction, xc, xcouleur, xmix, environnements,
)
// ankify est importé dans le corps de la note (chargé au premier appel)
#import "catalogue.typ": _communs, _modes, _noms, _numerotables, _types-defauts
#import "reglages.typ": _R, _R-explicite, _RA
#import "style-rd.typ": _construire-rd
#import "skins.typ": _outils, _skin
#import "galerie/commun.typ": choisir-icone

// =====================================================================
// Arguments positionnels
// =====================================================================

/// Lit les positionnels d'un type selon son mode : (titre, corps).
#let _titre-corps(id, args) = {
  let pos = args.pos()
  let mode = _modes.at(id)
  if args.named().len() > 0 {
    // une clé inconnue n'est pas déclarée dans la signature : elle arrive ici
    let cle = args.named().keys().first()
    let possibles = _communs.keys() + _types-defauts.at(id).keys() + ("style",)
    if id in _numerotables { possibles.push("label") }
    if id in ("bfEnv", "cracked") { possibles.push("sous-titre") }
    if id == "Histoire" { possibles.push("auteur") }
    panic(id + " : clé inconnue « " + cle + " ». Clés possibles : " + reglages-liste(possibles) + ".")
  }
  // Le corps passe par `environnements` : `#begin(f) … #end(f)` marche dans le corps, quelle que soit la syntaxe d'appel.
  if mode == "corps" and pos.len() == 1 { return (none, environnements(pos.at(0))) }
  if mode == "obligatoire" and pos.len() == 2 { return (pos.at(0), environnements(pos.at(1))) }
  if mode == "facultatif" and pos.len() in (1, 2) {
    return if pos.len() == 2 { (pos.at(0), environnements(pos.at(1))) } else { (none, environnements(pos.at(0))) }
  }
  let attendu = if mode == "corps" { "un contenu (le corps)" } else if mode == "obligatoire" {
    "deux contenus (titre, corps)"
  } else { "un ou deux contenus (titre facultatif, corps)" }
  let syntaxe = if mode == "corps" { "#" + id + "[Corps]" } else if mode == "obligatoire" {
    "#" + id + "[Titre][Corps]"
  } else { "#" + id + "[Titre][Corps] ou #" + id + "[Corps]" }
  panic(id + " : " + attendu + " attendu(s), reçu " + str(pos.len()) + ". Syntaxe : " + syntaxe + ".")
}

// =====================================================================
// Version prof / élève
// =====================================================================

/// À appeler dans un `context`.
#let _visible(version) = version == "toutes" or (version == "prof") == est-correction()

// =====================================================================
// Numérotation et étiquette (contrat avec farfadet-modele : figures de kind « bfn-… »)
// =====================================================================

/// Numéro d'un environnement : « 3 » (globale) ou « 2.3 » ; le numéro de section suit le style de
/// numérotation des titres (« II.3 » en chiffres romains). À appeler dans un `context`.
#let _formater(n, mode) = if mode == "globale" { str(n) } else {
  let s = calc.div-euclid(n, 1000)
  let k = calc.rem(n, 1000)
  if s == 0 { str(k) } else { bf-numero-section(s) + "." + str(k) }
}

/// `rendu` : fonction numero → contenu (numero : none ou « 2.3 »). À appeler dans un `context`.
#let _habiller(id, nom, r, etiquette, titre, rendu) = {
  if not r.numero and etiquette == none {
    rendu(none)
  } else if not r.numero {
    // Référençable sans numéro : `@etiquette` affiche le titre (ou `nameref`), cliquable.
    let kind = "bfn-" + id + "-texte"
    let texte = if r.nameref != auto { r.nameref } else if not m.bf-vide(titre) { titre } else { nom }
    show figure.where(kind: kind): it => {
      set align(start)
      set block(breakable: true)
      it.body
    }
    [#figure(kind: kind, supplement: texte, numbering: none, outlined: false, gap: 0pt, caption: none, rendu(none))#etiquette]
  } else {
    let mode = r.numerotation
    let kind = if r.compteur == "commun" { "bfn-commun-" + mode } else { "bfn-" + id + "-" + mode }
    let compteur = counter(figure.where(kind: kind))
    let s = counter(heading).get().first()
    let remise = if mode == "globale" { none } else {
      compteur.update(c => if calc.div-euclid(c, 1000) != s { s * 1000 } else { c })
    }
    show figure.where(kind: kind): it => {
      set align(start)
      set block(breakable: true)
      it.body
    }
    let fig = figure(
      kind: kind,
      supplement: nom,
      numbering: n => context _formater(n, mode),
      outlined: false,
      gap: 0pt,
      caption: none,
      context {
        let n = compteur.get().first()
        rendu(_formater(n, mode))
      },
    )
    [#remise#fig#etiquette]
  }
}

// =====================================================================
// Anki
// =====================================================================

/// Expression compilée une fois pour toutes : `regex(…)` dans une fonction recompile l'expression à chaque
/// appel (de l'ordre de 0,5 ms), ici à chaque carte Anki, donc à chaque environnement.
#let _non-alphanumerique = regex("[^a-z0-9]+")

/// Texte brut d'un titre, réduit à un identifiant : lettres et chiffres séparés par des tirets.
#let _identifiant(titre) = {
  let brut = if type(titre) == str { titre } else { m._brut(titre) }
  let s = lower(brut)
  for (accentue, simple) in (
    ("àâä", "a"), ("ç", "c"), ("éèêë", "e"), ("îï", "i"), ("ôö", "o"), ("ùûü", "u"), ("ÿ", "y"), ("œ", "oe"), ("æ", "ae"),
  ) {
    for c in accentue.clusters() { s = s.replace(c, simple) }
  }
  s = s.replace(_non-alphanumerique, "-").trim("-")
  s.clusters().slice(0, calc.min(40, s.clusters().len())).join()
}

/// Carte Anki. À appeler dans un `context`.
#let _carte(id, nom, titre, numero, corps, etiquette) = {
  let a = reglages-courants(_RA)
  let sans-titre = m.bf-vide(titre)
  let recto = [*#nom*#if numero != none [ #numero]#if not sans-titre [ : #titre]]
  let slug = if sans-titre { "" } else { _identifiant(titre) }
  let base = if etiquette != none { str(etiquette) } else { lower(id) + if slug == "" { "" } else { "-" + slug } }
  let cle = "bfn-anki-" + base
  let options = (tags: (lower(id),) + a.etiquettes)
  if a.paquet != none { options.insert("deck", a.paquet) }
  if a.format != none { options.insert("format", a.format) }
  [#counter(cle).step()#context {
    let n = counter(cle).get().first()
    import "@preview/ankify:0.1.0": note as _note-anki
    _note-anki(base + if n > 1 { "-" + str(n) } else { "" }, data: (Front: recto, Back: corps), ..options)
  }]
}

// =====================================================================
// Outils de traduction
// =====================================================================

/// Couleur résolue (nom xcolor, nom de palette ou couleur Typst). Dans un `context`.
#let _rc(v) = bf-resoudre-couleur(v)
/// Couleur de la palette courante pour un nom LaTeX (`thm`, `defi`…). Dans un `context`.
#let _palette(nom) = xcouleur(nom)
/// Couleur de l'environnement : clé `couleur` (par défaut, la couleur nommée du type, déjà résolue au
/// rendu), sinon couleur de palette `defaut` (nom ou couleur) quand la clé vaut `auto`.
#let _teinte(r, defaut) = if r.couleur == auto { _rc(defaut) } else { _rc(r.couleur) }
/// La couleur de l'environnement est-elle celle par défaut du type, c'est-à-dire la couleur nommée
/// `nom` telle qu'elle est maintenant (clé `couleur` non réglée, ou réglée à cette même couleur) ?
#let _est-defaut(r, nom) = r.couleur == auto or _rc(r.couleur) == bf-couleur-nommee(nom, commande: "setbfenvironments")
/// `auto` ou couleur résolue.
#let _ra(v) = if v == auto { auto } else { _rc(v) }
#let _taille(f) = if type(f) == str { taille-latex(f) } else { f }

/// Style de craie. Démonstration (craie par défaut) garde le gris-noir de chalks retenu le 18/09/2026,
/// sauf couleur explicite ; tout autre type tracé à la craie garde sa teinte (`craie: true` sur une
/// Définition ne la rend plus grise, indiscernable d'une Démonstration).
#let _craie(r, nom) = if not r.craie { none } else if nom == "demo" and _est-defaut(r, nom) { m.bf-craie } else {
  m.bf-craie + (couleur: auto)
}
#let _icone(r) = if r.icone == auto { none } else { r.icone }
/// `sommaire` du moteur : true (entrée du type), false, ou une entrée simple au libellé donné.
#let _som(r) = if type(r.sommaire) == bool { r.sommaire } else { m.bf-entree-sommaire(r.sommaire, none, simple: true) }
/// Entrée de sommaire pour les moteurs qui attendent le contenu (cracked).
#let _entree(r, nom, titre) = if r.sommaire == false { none } else if r.sommaire == true {
  m.bf-entree-sommaire(nom, titre)
} else { m.bf-entree-sommaire(r.sommaire, none, simple: true) }
#let _espaces(r) = {
  let a = (:)
  if r.before-skip != auto { a.insert("avant", r.before-skip) }
  if r.after-skip != auto { a.insert("apres", r.after-skip) }
  a
}

/// Arguments du moteur pour la famille « banderole » (bfd didactic skin). `defaut` : nom de la couleur
/// nommée du type (pour reconnaître la couleur par défaut).
#let _banderole(r, numero, defaut) = (
  sommaire: _som(r),
  numero: numero,
  icone: _icone(r),
  breakable: r.breakable,
  craie: _craie(r, defaut),
  fond: _rc(r.colback),
  bordure: _ra(r.colframe),
  arcs: _ra(r.banner-arc),
  ruban: _ra(r.colbacktitle),
  coltitle: _rc(r.coltitle),
  taille-titre: r.fonttitle,
  variant: r.variant,
  ombre: r.drop-shadow,
  k: (
    arc: r.arc,
    trait: r.edge-width,
    gauche: r.left + r.boxsep,
    droite: r.right + r.boxsep,
    pad: r.top + r.boxsep,
    bas: r.bottom + r.boxsep,
    titre-x: r.title-xshift,
  ),
) + _espaces(r)

/// Environnement à banderole d'une couleur de palette (`hook` : accroche de couleurs propre au type).
#let _semantique(nom, defaut, hook: none) = (r, numero, titre, corps, extra) => {
  let c = _teinte(r, defaut)
  let reglage = if hook != none and _est-defaut(r, defaut) { hook(c) } else { auto }
  m.bf-environnement(c, nom, titre: titre, reglage: reglage, .._banderole(r, numero, defaut), corps)
}

/// Exemple / ContreExemple : (fond, cadre, accent) par défaut.
#let _exemple(nom, nom-numerote, fond, cadre, accent) = (r, numero, titre, corps, extra) => {
  let c = if r.couleur == auto { none } else { _rc(r.couleur) }
  m.bf-exemple(
    if numero == none { nom } else { nom-numerote },
    titre,
    if r.colback != auto { _rc(r.colback) } else if c == none { fond() } else { xmix(c, 2) },
    if r.colframe != auto { _rc(r.colframe) } else if c == none { cadre() } else { c },
    if r.couleur-accent != auto { _rc(r.couleur-accent) } else if c == none { accent() } else { xmix(c, 80, autre: black) },
    corps,
    sommaire: _som(r),
    numero: numero,
    icone: _icone(r),
    breakable: r.breakable,
    k: (trait: r.line-width, coin: r.corner-size),
    taille: r.fonttitle,
    .._espaces(r),
  )
}

/// Famille cracked : largeur d'étiquette par défaut (sans numéro, avec numéro).
#let _cracked(defaut, largeurs) = (r, numero, titre, corps, extra) => {
  let nom = extra.nom
  m.cracked(
    titre: nom,
    sous-titre: extra.sous-titre,
    couleur: _teinte(r, defaut),
    couleur-titre: _ra(r.couleur-titre),
    largeur: if r.largeur-titre != auto { r.largeur-titre } else if numero == none { largeurs.at(0) } else { largeurs.at(1) },
    sommaire: _entree(r, nom, extra.sous-titre),
    numero: numero,
    k: (
      trait: r.line-width,
      ampl: r.amplitude,
      pas: r.segment-length,
      titre-taille: _taille(r.fonttitle),
      angle: r.title-angle,
      haut: r.top + 1mm + 0.5mm,
      bas: r.bottom + 1mm + 0.5mm,
      gauche: r.left + 1mm + 0.5mm,
      droite: r.right + 1mm + 0.5mm,
      ombre: r.drop-shadow,
    ),
    .._espaces(r),
    corps,
  )
}

/// Boîte simple à bandeau (boite, bfbox) : couleur d'accent courante par défaut.
#let _boite(r, titre, corps) = {
  let bc = m.bf-boitecouleur()
  let cadre = if r.colframe == auto { bc } else { _rc(r.colframe) }
  m._boite-titree(
    titre: titre,
    cadre: cadre,
    fond: _rc(r.colback),
    fond-titre: if r.colbacktitle == auto { cadre } else { _rc(r.colbacktitle) },
    couleur-titre: _rc(r.coltitle),
    regle: r.boxrule,
    arc: r.arc,
    marges: (left: r.left, right: r.right, top: r.top, bottom: r.bottom),
    sep: r.boxsep,
    largeur: r.width,
    above: if r.before-skip == auto { 0.99pt } else { r.before-skip },
    breakable: r.breakable,
    corps,
  )
  v(if r.after-skip == auto { 14.45pt } else { r.after-skip })
}

#let _alignements = (left: left, center: center, right: right, justify: left)

/// Un constructeur par type : (r, numero, titre, corps, extra) → contenu. À appeler dans un `context`.
#let _construire = (
  Theoreme: _semantique([Théorème], "thm", hook: m.bfd-hook-theoreme),
  Definition: _semantique([Définition], "defi", hook: m.bfd-hook-definition),
  Propriete: _semantique([Propriété], "prop"),
  Demonstration: _semantique([Démonstration], "demo"),
  Methode: _semantique([Méthode], "meth"),
  Activite: _semantique([Activité], "act"),
  Vocabulaire: _semantique([Vocabulaire], "nota"),
  Solution: (r, numero, titre, corps, extra) => {
    let vert = _teinte(r, "green")
    let fonce = xmix(vert, 80, autre: black)
    m.bf-environnement(
      vert,
      [Solution],
      titre: titre,
      reglage: bfdsetcolors(xmix(vert, 50, autre: black)),
      .._banderole(r, numero, "green") + (
        arcs: if r.banner-arc == auto { fonce } else { _rc(r.banner-arc) },
        ruban: if r.colbacktitle == auto { fonce } else { _rc(r.colbacktitle) },
      ),
      corps,
    )
  },
  Exemple: (r, numero, titre, corps, extra) => _exemple(
    [Exemple(s)],
    [Exemple],
    () => xmix(xc.gray, 2),
    () => xmix(xc.gray, 80, autre: black),
    () => xmix(_palette("nota"), 80, autre: black),
  )(r, numero, titre, corps, extra),
  ContreExemple: (r, numero, titre, corps, extra) => _exemple(
    [Contre-Exemple(s)],
    [Contre-Exemple],
    () => xmix(xc.red, 2),
    () => xmix(xc.red, 80, autre: black),
    () => xmix(xc.blue, 80, autre: black),
  )(r, numero, titre, corps, extra),
  Remarque: (r, numero, titre, corps, extra) => m.remarque(
    titre: titre,
    corps,
    sommaire: _som(r),
    numero: numero,
    icone: r.icone,
    couleur: if r.couleur == auto { none } else { _rc(r.couleur) },
    accent: if r.couleur-accent != auto { _rc(r.couleur-accent) } else if r.couleur == auto {
      xmix(_palette("thm"), 80, autre: black)
    } else { auto },
    breakable: r.breakable,
    barre: r.barre,
    taille-titre: r.fonttitle,
    taille-logo: r.logo-size,
    .._espaces(r),
  ),
  Notation: (r, numero, titre, corps, extra) => _cracked("defi", (3.5cm, 4.6cm))(
    r, numero, titre, corps, (nom: [Notation], sous-titre: titre),
  ),
  Aide: (r, numero, titre, corps, extra) => _cracked("nota", (2.5cm, 3.6cm))(
    r, numero, titre, corps, (nom: [Aide], sous-titre: titre),
  ),
  cracked: (r, numero, titre, corps, extra) => _cracked(xc.orange, (2.5cm, 2.5cm))(
    r, numero, titre, corps, (nom: if titre == none [Propriété] else { titre }, sous-titre: extra.sous-titre),
  ),
  Histoire: (r, numero, titre, corps, extra) => m.histoire(
    titre,
    auteur: extra.auteur,
    onglet: r.onglet,
    couleur: _teinte(r, "histoire"),
    corps,
    sommaire: _som(r),
    numero: numero,
    fond: _ra(r.colback),
    regle: r.boxrule,
    arc: r.arc,
    .._espaces(r),
  ),
  bfEnv: (r, numero, titre, corps, extra) => m.bfenv(
    titre,
    titre: extra.sous-titre,
    couleur: _teinte(r, "prop"),
    corps,
    .._banderole(r, numero, "prop"),
  ),
  None: (r, numero, titre, corps, extra) => m.neutre(corps, breakable: r.breakable, .._espaces(r)),
  boite: (r, numero, titre, corps, extra) => _boite(r, titre, corps),
  bfbox: (r, numero, titre, corps, extra) => _boite(r, titre, corps),
  boiteFigure: (r, numero, titre, corps, extra) => m.boitefigure(
    titre,
    corps,
    cadre: _rc(r.colframe),
    fond: _rc(r.colback),
    arc: r.arc,
    regle: r.boxrule,
    haut: r.top,
    aligne: _alignements.at(r.halign),
    .._espaces(r),
  ),
)

// =====================================================================
// Skins (rendu fourni par une fonction d => contenu : skins/CONTRAT.md)
// =====================================================================

/// Teinte d'un type dont la clé `couleur` vaut `auto` (ou qui n'a pas de clé `couleur`) : celle que son
/// rendu bf emploie. À appeler dans un `context`.
#let _teintes-auto = (
  Exemple: () => xmix(xc.gray, 80, autre: black),
  ContreExemple: () => xmix(xc.red, 80, autre: black),
  Remarque: () => xmix(_palette("thm"), 80, autre: black),
  boite: () => m.bf-boitecouleur(),
  bfbox: () => m.bf-boitecouleur(),
  boiteFigure: () => _rc("black!50"),
)

/// Constructeur d'un skin : traduit les réglages résolus en dictionnaire `d` et appelle `skin(d)`.
/// `t` : titre au sens du contrat (le sous-titre pour bfEnv et cracked) ; `x` : clés réglées.
#let _construire-skin(skin, id, nom, t, x) = (r, numero, titre, corps, extra) => {
  let couleur = {
    let c = r.at("couleur", default: auto)
    if c != auto { _rc(c) } else if id in _teintes-auto { (_teintes-auto.at(id))() } else { _rc("black") }
  }
  let icone = r.at("icone", default: none)
  let t = if m.bf-vide(t) { none } else { t }
  // boîtes sans nom de type (boite, bfbox, boiteFigure) : leur titre tient lieu de nom
  let (nom, t) = if id in ("boite", "bfbox", "boiteFigure") { (t, none) } else { (nom, t) }
  let d = (
    type: id,
    nom: nom,
    numero: numero,
    titre: t,
    // couleurs d'accent du corps (`acc`, `voc`, puces) à la teinte de l'environnement, comme en rendu bf
    corps: m.bf-avec-couleurs(reglage: bfdsetcolors(couleur), corps),
    couleur: couleur,
    fond: _ra(x.at("colback", default: auto)),
    cadre: _ra(x.at("colframe", default: auto)),
    couleur-titre: _ra(x.at("coltitle", default: auto)),
    icone: if icone == auto { none } else { icone },
    // emblème du type (clé `embleme`) : `auto` quand il n'y en a pas (le défaut « "auto" » du catalogue et `none`
    // y sont ramenés : `auto` seul vaut « non précisé » sur un appel) ; les skins le lisent par `icone-choisie`,
    // qui applique la priorité icone > option icone > embleme > icône propre au skin
    embleme: { let e = r.at("embleme", default: auto); if e == none or e == "auto" { auto } else { e } },
    breakable: r.at("breakable", default: false),
    avant: r.before-skip,
    apres: r.after-skip,
    options: r.skin,
    auteur: extra.at("auteur", default: none),
    explicites: x.pairs().filter(((k, v)) => v != auto).to-dict(),
    r: r,
    // outils à la craie (cadre, trait, soulignement, cercle), à la teinte de l'environnement par défaut
    outils: _outils(couleur),
  )
  // `d.outils.icone-choisie(defaut, taille:, couleur:, pastille:)` : l'icône du skin selon la priorité commune
  // (la même fonction que les six skins intégrés), à la disposition des skins personnels
  let outils = d.outils + (icone-choisie: (defaut, taille: 1em, couleur: auto, pastille: auto) => choisir-icone(
    d, defaut, taille: taille, couleur: couleur, pastille: pastille,
  ))
  skin(d + (outils: outils))
}

/// Entrée de sommaire déposée par `_rendre` pour les rendus autres que bf (skin, style « rd ») : le
/// moteur bf la dépose lui-même. `r.sommaire` : true (« **Nom** - titre »), false, ou un libellé.
#let _entree-rendu(id, r, nom, t) = {
  let s = r.at("sommaire", default: false)
  if s == false { none } else if s == true {
    m.bf-entree-sommaire(if id == "Histoire" { r.onglet } else { nom }, t)
  } else { m.bf-entree-sommaire(s, none, simple: true) }
}

// =====================================================================
// Cœur commun
// =====================================================================

/// Rend un environnement.
///   id      nom LaTeX du type (clé `pour:` de setbfenvironments)
///   local   clés écrites sur l'appel (`auto` = non précisé)
///   etiq    clé `label` (none, ou une étiquette)
///   args    positionnels (titre, corps)
///   extra   clés propres à l'objet (sous-titre, auteur)
///
/// Trois rendus : bf (`_construire`, défaut), style « rd » (`_construire-rd`), skin (fonction). Quel que
/// soit le rendu, `_rendre` assure la version prof/élève, la numérotation et l'étiquette (`_habiller`),
/// la carte Anki ; pour les rendus autres que bf, il dépose aussi l'entrée de sommaire.
/// None garde toujours le rendu bf.
#let _rendre(id, local, etiq, args, extra) = {
  let (titre, corps) = _titre-corps(id, args)
  if etiq != none and type(etiq) != std.label {
    panic(id + " : `label` doit être une étiquette, par exemple <chasles> ; reçu : " + repr(etiq) + ".")
  }
  let local = local.pairs().filter(((k, v)) => v != auto).to-dict()
  let nom = if id in ("bfEnv", "cracked") and titre != none { titre } else { _noms.at(id) }
  // bfEnv et cracked : le titre est le nom du type, le sous-titre tient lieu de titre
  let t = if id in ("bfEnv", "cracked") { extra.sous-titre } else { titre }
  context {
    let r = reglages-resoudre(_R, pour: id, local: local, commande: id)
    if _visible(r.version) {
      let skin = _skin(id, r.rendu)
      let autre = id != "None"
      let rd = autre and skin == none and r.rendu == "rd"
      let skin = if autre { skin } else { none }
      // clés réglées par l'utilisateur seulement (les défauts du catalogue valent `auto`)
      let x = if rd or skin != none { reglages-resoudre(_R-explicite, pour: id, local: local, commande: id) } else { none }
      let construire = if skin != none { _construire-skin(skin, id, nom, t, x) } else if rd { _construire-rd.at(id) } else {
        _construire.at(id)
      }
      let extra = if rd { extra + (nom: nom, explicites: x) } else { extra }
      let entree = if rd or skin != none { _entree-rendu(id, r, nom, t) } else { none }
      if id in _numerotables {
        _habiller(id, nom, r, etiq, t, numero => {
          if r.anki { _carte(id, nom, t, numero, corps, etiq) }
          entree
          construire(r, numero, titre, corps, extra)
        })
      } else {
        entree
        construire(r, none, titre, corps, extra)
      }
    }
  }
}
