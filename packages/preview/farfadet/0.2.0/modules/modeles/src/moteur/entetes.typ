// entetes.typ — \chapitre, \chapEval (bfcours-exoplus.sty), le pied de page qu'ils installent et
// \SequenceItem (bfcours-commands.sty).
//
// \chapitre[niveau]{thème}{cycle}{établissement}{zone droite}{type}
//   → bandeau de 1,5 cm (dégradé gris), pied de page « type thème | cycle établissement | n° ».
// Cotes relevées sur le rendu LaTeX de référence.
//
// Toutes les cotes sont des clés du registre `modele-reglages` (moteur/reglages.typ) : réglage global,
// réglage par type, styles nommés et clés locales (`..options`) par le mécanisme du socle.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "../../../maths/lib.typ": interne as _maths
#import _maths: acc
#import "../../../zones-reponse/lib.typ": interne as _crep
#import _crep: tccrep
// rendu "rd" de l'en-tête : le bandeau `rd.entete` de rdboites, réutilisé tel quel (ajout 11/10/2026)
// rdboites est importé dans _entete-rd (chargé au premier appel)
#import "reglages.typ": modele-reglages as _registre, champs-identite, noms-champs as _noms-champs

/// Registre des réglages du paquet (clés, types, styles) : pour régler le modèle depuis un autre paquet
/// avec les fonctions `reglages-*` du socle, par exemple le skin exolombards :
/// `reglages-regler(modele-reglages, pour: "pied-de-page", disposition: "simple")`.
#let modele-reglages = _registre

/// Valeurs effectives des réglages d'un type (à appeler dans un `context`).
#let _resoudre(pour, locaux) = reglages-resoudre(modele-reglages, pour: pour, local: locaux, commande: pour)

/// Niveaux connus : écriture courte → étiquette du bandeau (exposant typographique). Toute autre
/// valeur (chaîne ou contenu) est affichée telle quelle.
#let _niveaux = (
  "6e": [6#super[e]],
  "5e": [5#super[e]],
  "4e": [4#super[e]],
  "3e": [3#super[e]],
  "2nde": [2#super[nde]],
  "1re": [1#super[ère]],
  "1ère": [1#super[ère]],
  "Tle": [T#super[le]],
)

/// Types de document connus : écriture courte → (libellé du bandeau, bandeau d'évaluation ?).
#let _types-document = (
  cours: ([Cours], false),
  exercices: ([Exercices], false),
  activite: ([Activité], false),
  fiche: ([Fiche], false),
  evaluation: ([Évaluation], true),
)

#let _etiquette-niveau(n) = if type(n) == str { _niveaux.at(n, default: n) } else { n }

/// Types de document effectifs : les défauts (`_types-document`) dont les libellés sont remplacés par la clé
/// `libelles-types`, complétés par ses nouveaux types. Un type connu garde son indicateur d'évaluation,
/// un type nouveau n'a pas de bandeau d'évaluation.
#let _types-effectifs(libelles) = {
  let res = _types-document
  for (k, v) in libelles {
    res.insert(k, (v, _types-document.at(k, default: (none, false)).at(1)))
  }
  res
}

/// Libellé du bandeau : `"cours"`, `"evaluation"`… donnent « Cours », « Évaluation » (ou le libellé réglé par
/// `libelles-types`) ; toute autre valeur est affichée telle quelle.
#let _libelle-type(t, types: _types-document) = if type(t) == str and t in types { types.at(t).first() } else { t }

/// Valeurs résolues d'un bandeau, niveau et type remplacés par leur étiquette et leur libellé.
#let _bandeau-resolu(pour, locaux) = {
  let r = _resoudre(pour, locaux)
  r + (niveau: _etiquette-niveau(r.niveau), type: _libelle-type(r.type, types: _types-effectifs(r.libelles-types)))
}

/// Texte brut d'un contenu (pour savoir par quoi finit un libellé).
#let _texte-brut(c) = if type(c) == str { c } else if type(c) == content {
  if c.has("text") { c.text } else if c.has("children") { (c.children.map(_texte-brut) + ("",)).join() } else if c.has("body") {
    _texte-brut(c.body)
  } else { "" }
} else { "" }

/// « type » et « thème » mis bout à bout. `sep` (clé `separateur-type`) se place entre les deux ;
/// sans type ou sans thème, il est omis. `auto` (défaut) : « : » (« Cours : Thème »), sauf si le
/// libellé finit déjà par deux-points (libellé libre « Cours : » d'un document converti) : on garde
/// alors `defaut`, la composition d'origine (espace réglée par `espace-type-theme`).
#let _type-theme(type-, theme, sep, defaut) = if sep == auto and _texte-brut(type-).trim().ends-with(":") {
  defaut
} else if bf-vide(type-) or bf-vide(theme) {
  [#type-#theme]
} else if sep == auto {
  [#type-#sym.space.nobreak:#sym.space#theme]
} else {
  [#type-#sep#theme]
}

/// `style: auto` ne doit pas atteindre la résolution (la clé `style` attend un nom) : dictionnaire à étaler.
#let _style(s) = if s == auto { (:) } else { (style: s) }

// Dictionnaire des clés locales non `auto` d'une liste d'arguments.
#let _locaux(base, options) = base + options.named()

// =====================================================================
// Champs de l'en-tête (ajout 11/10/2026)
// =====================================================================
//
// Un rendu d'en-tête reçoit un dictionnaire `d` (contrat dans la docstring de `chapitre`, façade) :
// les champs (niveau, type, theme, titre, zone, et les champs d'identité), `champs` (les zones à
// remplir : gauche, centre, droite), `pile` (fonction qui empile les champs d'une zone), `options`
// (clé `skin`), `r` (toutes les clés résolues). Une zone est une liste d'éléments : un nom de champ, un
// contenu libre ou une fonction `d => contenu`.

/// Liste des éléments d'une zone : none → (), un élément seul → (élément,).
#let _liste(v) = if v == none { () } else if type(v) == array { v } else { (v,) }

/// Logo ramené à la hauteur `h` (image ou dessin). À appeler dans un `context`.
#let _logo(logo, h) = {
  if logo == none { return none }
  let m = measure(logo)
  if m.height == 0pt { return logo }
  box(scale(h / m.height * 100%, reflow: true, logo))
}

/// Valeur d'un élément de zone. `noms` : champs que l'on peut citer par leur nom.
#let _valeur(d, x, commande, noms) = {
  if type(x) == function { return x(d) }
  if type(x) != str { return x }
  if x not in noms {
    panic(
      commande + " : champ inconnu « " + x + " ». Champs possibles : " + reglages-liste(noms)
        + " ; un texte libre s'écrit entre crochets ([Mathématiques]), un calcul par une fonction d => contenu.",
    )
  }
  let v = d.at(x)
  if x == "logo" { return _logo(v, d.hauteur-logo) }
  let style = d.at("style-champ", default: none)
  if x in champs-identite and style != none and not bf-vide(v) { style(v) } else { v }
}

/// Champs d'une zone empilés (un par ligne) ; un élément seul est rendu tel quel, sans filtre ; plusieurs :
/// les vides sont écartés, et le logo, s'il est cité en premier, se place à gauche des autres champs.
/// `none` si rien à montrer.
#let _pile(d, items, commande, noms: _noms-champs) = {
  let xs = _liste(items)
  if xs.len() == 0 { return none }
  if xs.len() == 1 { return _valeur(d, xs.first(), commande, noms) }
  let logo = if xs.first() == "logo" { _valeur(d, "logo", commande, noms) } else { none }
  let xs = if xs.first() == "logo" { xs.slice(1) } else { xs }
  let vals = xs.map(x => _valeur(d, x, commande, noms)).filter(v => not bf-vide(v))
  let texte = if vals.len() == 0 { none } else if vals.len() == 1 { vals.first() } else {
    set par(justify: false, leading: 0.3em)
    vals.join(linebreak())
  }
  if logo == none { return texte }
  if texte == none { return logo }
  box(grid(columns: 2, column-gutter: 0.4em, align: horizon + left, logo, texte))
}

/// Champs d'une zone sur une ligne, séparés par `sep` (pied de page).
#let _ligne(d, items, sep, commande, noms) = {
  let vals = _liste(items).map(x => _valeur(d, x, commande, noms)).filter(v => not bf-vide(v))
  if vals.len() == 0 { [] } else { vals.join(sep) }
}

/// Champs affichés par défaut, selon le rendu.
#let _champs-defaut(rendu, evaluation) = if rendu == "encadre" {
  (
    gauche: ("logo", "etablissement", "professeur"),
    centre: ("type", "theme"),
    droite: if evaluation { ("niveau", "zone") } else { ("niveau", "classe", "annee") },
  )
} else if rendu == "sobre" {
  (gauche: ("niveau",), centre: ("titre",), droite: if evaluation { ("zone",) } else { ("etablissement", "annee") })
} else {
  (gauche: ("niveau",), centre: ("titre",), droite: ("zone",))
}

/// Contenu d'une zone, `[]` si elle est vide.
#let _zone(d, nom) = {
  let c = _pile(d, d.champs.at(nom, default: none), d.commande)
  if c == none { [] } else { c }
}

/// Règles de police et de graisse du titre (clés `police-titre`, `graisse-titre`), sans effet à `auto`.
#let _style-titre(r, graisse, c) = {
  set text(font: r.police-titre) if r.police-titre != auto
  let g = if r.graisse-titre != auto { r.graisse-titre } else { graisse }
  set text(weight: g) if g != auto
  c
}

/// Bandeau commun à \chapitre et \chapEval (rendu "bf"). `r` : valeurs effectives (clés du bandeau) ;
/// `d` : champs (voir plus haut).
#let _bandeau(r, d) = {
  let gris(c) = bf-resoudre-couleur(c)
  let taille-niveau = taille-latex(r.taille-niveau)
  let taille-titre = taille-latex(r.taille-titre)
  let r = r + (epaisseur-filet: if r.epaisseur-filet == auto { ptl(1) } else { r.epaisseur-filet })
  // Bandeau plus bas que le carré de niveau (`hauteur: 1.2cm`) : le carré dépassait au-dessus et
  // au-dessous des filets. Il est ramené entre les filets, avec le même jeu qu'à la hauteur d'origine
  // (1,5 cm pour 1,4 cm) ; un bandeau aussi haut ou plus haut ne change pas.
  let r = r + (hauteur-etiquette: calc.min(r.hauteur-etiquette, r.hauteur - 2 * r.epaisseur-filet - 0.8pt))
  let niveau = _zone(d, "gauche")
  let zone = _zone(d, "droite")
  let fond = if r.couleur-fond == auto {
    gradient.linear(gris(r.couleur-debut), gris(r.couleur-fin))
  } else if r.couleur-fond == none { none } else { gris(r.couleur-fond) }
  block(
    width: 100%,
    height: r.hauteur,
    above: 0pt,
    below: 0pt,
    breakable: false,
    fill: fond,
    layout(s => {
      let L = s.width
      let n = r.colonnes
      let col = (L - 2 * r.boxsep - (n - 1) * r.gouttiere) / n
      let x(k) = r.boxsep + k * (col + r.gouttiere)
      let larg(k) = k * col + (k - 1) * r.gouttiere
      let dy = (r.hauteur - r.hauteur-etiquette) / 2
      // filets haut et bas : bfcours demande un dégradé (borderline … shading), que tcolorbox
      // n'applique pas au trait : le rendu LaTeX est un filet de 1 pt (noir par défaut).
      for y in (0pt, r.hauteur - r.epaisseur-filet) {
        place(dy: y, rect(width: L, height: r.epaisseur-filet, fill: gris(r.couleur-filet)))
      }
      // étiquette de niveau : \contour{white}{\Large #1} sur gray!60
      let etiquette-a(t) = {
        set text(size: t, top-edge: "bounds", bottom-edge: "bounds")
        let contour = {
          set text(fill: gris(r.couleur-contour), stroke: r.epaisseur-contour + gris(r.couleur-contour))
          niveau
        }
        box(place(center + horizon, contour) + text(fill: gris(r.couleur-niveau), niveau))
      }
      // un niveau trop large pour le carré (« Tle spé ») est réduit jusqu'à y tenir
      let t-niveau = taille-niveau
      while t-niveau > 0.5 * taille-niveau and measure(etiquette-a(t-niveau)).width > col - 2 * r.boxsep {
        t-niveau = t-niveau * 0.94
      }
      place(dx: x(0), dy: dy, box(
        width: col,
        height: r.hauteur-etiquette,
        fill: gris(r.couleur-etiquette),
        align(center + horizon, etiquette-a(t-niveau)),
      ))
      // titre : \acc{\large{#6#2}} ; #6#2 : espaces des retours à la ligne du source LaTeX
      // l'espace entre type et thème est une vraie espace du source LaTeX : elle s'étire à la justification
      // champs du centre : « titre » (défaut) garde exactement la composition d'origine
      let contenu-titre = if _liste(d.champs.centre) == ("titre",) {
        [#h(r.espace-avant-type)#d.titre]
      } else {
        [#h(r.espace-avant-type)#_zone(d, "centre")]
      }
      let titre = if r.couleur-titre == auto { acc(contenu-titre) } else { text(fill: gris(r.couleur-titre), contenu-titre) }
      let largeur-titre = larg(r.colonnes-titre)
      let titre-a(t) = {
        // la tcolorbox du titre justifie son texte : sur plusieurs lignes, la première est étirée
        set par(justify: true)
        _style-titre(r, auto, text(size: t, top-edge: "bounds", bottom-edge: "bounds", titre))
      }
      // un titre trop long passe à la ligne, puis rapetisse jusqu'à tenir dans la hauteur du carré
      let t-titre = taille-titre
      while t-titre > 0.5 * taille-titre and measure(block(width: largeur-titre, titre-a(t-titre))).height > r.hauteur-etiquette {
        t-titre = t-titre * 0.95
      }
      place(dx: x(1), dy: dy, box(width: largeur-titre, height: r.hauteur-etiquette, align(horizon, titre-a(t-titre))))
      // zone de droite
      let reste = n - 1 - r.colonnes-titre
      place(dx: x(1 + r.colonnes-titre), dy: dy, box(width: larg(reste), height: r.hauteur-etiquette, align(horizon, zone)))
    }),
  )
}

// =====================================================================
// Rendus "rd", "sobre", "encadre" (ajout 11/10/2026)
// =====================================================================

/// Rendu "rd" : le bandeau `rd.entete` de rdboites (filets dégradés, fond dégradé gris), réutilisé tel
/// quel. Les clés de `rd.entete` (`colframe`, `colback`, `rule-width`…) passent par la clé `skin`, et les
/// réglages `setrdboites(pour: "entete", …)` s'appliquent aussi.
#let _entete-rd(r, d) = {
  import "../../../rd-boites/lib.typ": rd as _rd
  let gris(c) = bf-resoudre-couleur(c)
  let largeurs = if r.largeurs == auto { (auto, 1fr, auto) } else { r.largeurs }
  let titre = _zone(d, "centre")
  let titre = if r.couleur-titre == auto { titre } else { text(fill: gris(r.couleur-titre), titre) }
  let corps = grid(
    columns: largeurs,
    column-gutter: 1em,
    align: (left + horizon, left + horizon, right + horizon),
    _zone(d, "gauche"),
    _style-titre(r, auto, titre),
    // `rd.entete` compose en gras et à 1,31 em : la zone de droite revient au texte courant
    text(weight: "regular", size: 1em / 1.31, _zone(d, "droite")),
  )
  let cles = (colframe: gris(r.couleur-filet), before-skip: 0pt, after-skip: 0pt)
  if r.couleur-fond == none { cles.insert("colback", white) } else if r.couleur-fond != auto {
    cles.insert("colback", gris(r.couleur-fond))
  }
  if r.epaisseur-filet != auto { cles.insert("rule-width", r.epaisseur-filet) }
  _rd.entete(corps, ..(cles + r.skin))
}

/// Rendu "sobre" : une ligne sur fond blanc (niveau, titre, champs à droite) et un seul filet fin dessous.
#let _entete-sobre(r, d) = {
  let gris(c) = bf-resoudre-couleur(c)
  let ep = if r.epaisseur-filet == auto { 0.6pt } else { r.epaisseur-filet }
  let fond = if r.couleur-fond in (auto, none) { none } else { gris(r.couleur-fond) }
  let largeurs = if r.largeurs == auto { (auto, 1fr, auto) } else { r.largeurs }
  let titre = {
    set par(justify: false)
    set text(size: taille-latex(r.taille-titre))
    set text(fill: gris(r.couleur-titre)) if r.couleur-titre != auto
    _style-titre(r, "bold", _zone(d, "centre"))
  }
  let niveau = text(size: taille-latex(r.taille-niveau), weight: "bold", fill: gris(r.couleur-niveau), _zone(d, "gauche"))
  block(
    width: 100%,
    above: 0pt,
    below: 0pt,
    breakable: false,
    fill: fond,
    inset: (bottom: 0.35em, x: if fond == none { 0pt } else { 0.4em }, top: if fond == none { 0pt } else { 0.35em }),
    stroke: (bottom: ep + gris(r.couleur-filet)),
    grid(
      columns: largeurs,
      column-gutter: 0.8em,
      align: (left + horizon, left + horizon, right + horizon),
      niveau, titre, { set par(justify: false); _zone(d, "droite") },
    ),
  )
}

/// Rendu "encadre" : un cadre fin à trois cases (identité à gauche, titre au centre, niveau et année à
/// droite), séparées par des filets fins ; fond blanc.
#let _entete-encadre(r, d) = {
  let gris(c) = bf-resoudre-couleur(c)
  let ep = if r.epaisseur-filet == auto { 0.6pt } else { r.epaisseur-filet }
  let trait = ep + gris(r.couleur-filet)
  let fond = if r.couleur-fond in (auto, none) { none } else { gris(r.couleur-fond) }
  let largeurs = if r.largeurs == auto { (1fr, 2fr, 1fr) } else { r.largeurs }
  let petit(c) = { set par(justify: false); text(size: taille-latex(r.taille-champs), c) }
  let titre = {
    set par(justify: false)
    set text(size: taille-latex(r.taille-titre))
    set text(fill: gris(r.couleur-titre)) if r.couleur-titre != auto
    _style-titre(r, "bold", _zone(d, "centre"))
  }
  block(
    width: 100%,
    above: 0pt,
    below: 0pt,
    breakable: false,
    fill: fond,
    stroke: trait,
    grid(
      columns: largeurs,
      inset: 0.5em,
      stroke: (x, y) => (left: if x > 0 { trait } else { none }),
      align: (left + horizon, center + horizon, right + horizon),
      petit(_zone(d, "gauche")), titre, petit(_zone(d, "droite")),
    ),
  )
}

/// En-tête d'un bandeau selon la clé `rendu` : prépare les champs `d`, puis appelle le rendu.
/// `zone` : contenu de la zone de droite (`zone-droite`, ou les cases Classe et Date de chapEval).
#let _entete(r, commande, zone) = {
  let gris(c) = bf-resoudre-couleur(c)
  let rendu = r.rendu
  let nom = if type(rendu) == function { "fonction" } else { rendu }
  let champs = _champs-defaut(nom, commande == "chapEval")
  if r.champs != auto { champs = champs + r.champs }
  let hauteur-logo = if r.hauteur-logo != auto { r.hauteur-logo } else if nom == "bf" {
    0.9 * calc.min(r.hauteur-etiquette, r.hauteur - 2 * (if r.epaisseur-filet == auto { ptl(1) } else { r.epaisseur-filet }) - 0.8pt)
  } else { 1.2cm }
  let style-champ(v) = {
    set text(size: taille-latex(r.taille-champs))
    set text(fill: gris(r.couleur-champs)) if r.couleur-champs != auto
    set text(font: r.police-champs) if r.police-champs != auto
    v
  }
  let d = (
    commande: commande,
    evaluation: commande == "chapEval",
    niveau: r.niveau,
    type: r.type,
    theme: r.theme,
    titre: _type-theme(r.type, r.theme, r.separateur-type, [#r.type#text(spacing: r.espace-type-theme)[ ]#r.theme]),
    zone: zone,
  )
  for k in champs-identite { d.insert(k, r.at(k)) }
  d += (champs: champs, hauteur-logo: hauteur-logo, style-champ: style-champ, options: r.skin, r: r)
  d.insert("pile", items => _pile(d, items, commande))
  if type(rendu) == function {
    rendu(d)
  } else if rendu == "rd" {
    _entete-rd(r, d)
  } else if rendu == "sobre" {
    _entete-sobre(r, d)
  } else if rendu == "encadre" {
    _entete-encadre(r, d)
  } else {
    _bandeau(r, d)
  }
}

/// Enregistre les textes du pied de page à partir de cet endroit : type, thème, niveau et champs d'identité.
#let _pied(r) = [#metadata(
    (type: r.type, theme: r.theme, niveau: r.niveau, separateur-type: r.separateur-type) + champs-identite.map(k => (k, r.at(k))).to-dict(),
  )<bf-chapitre>]

/// \chapitre[niveau]{thème}{cycle}{établissement}{zone droite}{type}
///   #chapitre(niveau: [$bold(6^"ème")$], [La proportionnalité], [Collège], [Marie Curie], [], [Cours])
/// `options` : clés nommées du type « chapitre » (hauteur, couleur-debut, taille-titre, pied, style…) ;
/// `auto` pour un argument : « selon les réglages ».
#let chapitre(niveau: [], theme, cycle, etablissement, zone, type, ..options) = context {
  let r = _bandeau-resolu("chapitre", _locaux((
    niveau: niveau,
    theme: theme,
    cycle: cycle,
    etablissement: etablissement,
    zone-droite: zone,
    type: type,
  ), options))
  if r.pied { _pied(r) }
  block(above: 0pt, below: 0pt, _entete(r, "chapitre", r.zone-droite))
  v(r.espace-apres)
}

/// \chapEval[niveau]{thème}{cycle}{établissement}{contenu placé sous le bandeau}{type}
/// La zone de droite porte « Classe : » et « Date : » avec leurs cases (\tccrep sans Seyès).
#let chapeval(niveau: [], theme, cycle, etablissement, apres, type, ..options) = context {
  let r = _bandeau-resolu("chapEval", _locaux((
    niveau: niveau,
    theme: theme,
    cycle: cycle,
    etablissement: etablissement,
    apres: apres,
    type: type,
  ), options))
  if r.pied { _pied(r) }
  // Les cases tiennent sur une seule ligne, sans justification ; si la zone est plus étroite que
  // son contenu (page étroite, aperçu), l'ensemble est réduit pour y tenir.
  // Hors du rendu "bf", les cases blanches ne se verraient pas sur un fond clair : deux lignes à remplir.
  let trou(l) = box(width: l, height: 0.8em, stroke: (bottom: 0.5pt))
  let cases = if r.rendu == "bf" {
    par(justify: false, [#acc[Classe :] #tccrep(seyes: false, tcb: "colback=white", 1.5cm, [])#hide[A]#acc[Date :] #tccrep(seyes: false, tcb: "colback=white", 3.5cm, [])])
  } else {
    par(justify: false, leading: 0.6em, [Classe : #trou(2cm) \ Date : #trou(2.6cm)])
  }
  let zone = align(horizon, layout(dim => {
    let m = measure(box(cases))
    if m.width > dim.width and m.width > 0pt {
      scale(dim.width / m.width * 100%, origin: left + horizon, reflow: true, box(cases))
    } else {
      box(cases)
    }
  }))
  block(above: 0pt, below: 0pt, _entete(r, "chapEval", zone))
  v(r.espace-apres, weak: true)
  r.apres
}

/// Pied de page de \chapitre (fancyhdr, style monStyle) : à passer à `page(footer: …)`
/// avec `footer-descent: 0pt`. Rien n'est affiché avant le premier \chapitre ou \chapEval
/// (sauf si `gauche`, `centre` ou `droite` sont donnés).
#let pied-de-page(..options) = context {
  let r = _resoudre("pied-de-page", options.named())
  let ici = here().page()
  let q = query(<bf-chapitre>).filter(m => m.location().page() <= ici)
  let fonction = type(r.disposition) == function
  let libre = (r.gauche, r.centre, r.droite).any(v => v != auto) or fonction
  if q.len() == 0 and not libre { return }
  // champs : identité réglée pour le pied, remplacée par celle du dernier bandeau quand elle y est renseignée
  let d = (type: [], theme: [], niveau: [])
  for k in champs-identite { d.insert(k, r.at(k)) }
  if q.len() > 0 {
    for (k, v) in q.last().value {
      if k == "separateur-type" { continue }
      if not bf-vide(v) or k not in d { d.insert(k, v) }
    }
  }
  // séparateur entre type et thème : le réglage du pied, à défaut celui du dernier bandeau
  let sep-type = if r.separateur-type != auto { r.separateur-type } else if q.len() > 0 {
    q.last().value.at("separateur-type", default: auto)
  } else { auto }
  let base = r.hauteur // \footskip
  let petit = taille-latex(r.taille)
  let c-texte = bf-resoudre-couleur(r.couleur-texte)
  set text(size: petit, weight: r.graisse, fill: c-texte, top-edge: "baseline", bottom-edge: "baseline")
  set par(justify: false)
  let n = counter(page).display()
  // zones données par une liste de champs (ajout 11/10/2026)
  d += (
    numero: n,
    titre: _type-theme(d.type, d.theme, sep-type, [#d.type#h(r.espace-type-theme)#d.theme]),
    hauteur-logo: if r.hauteur-logo == auto { 1em } else { r.hauteur-logo },
    r: r,
  )
  let noms = ("type", "theme", "titre", "niveau", "numero") + champs-identite
  let sep = if r.separateur == auto { [ #sym.dot.c ] } else { r.separateur }
  d.insert("ligne", items => _ligne(d, items, sep, "pied-de-page", noms))
  let zone(v) = if type(v) == array { _ligne(d, v, sep, "pied-de-page", noms) } else if type(v) == function { v(d) } else { v }
  if fonction { return block(width: 100%, height: base, (r.disposition)(d)) }
  let gauche = if r.gauche == auto { [#h(r.espace-avant-type)#d.titre] } else { zone(r.gauche) }
  let droite = if r.droite == auto { [#d.cycle#h(r.espace-type-theme)#d.etablissement] } else { zone(r.droite) }
  let centre = if r.centre == auto { auto } else { zone(r.centre) }
  block(width: 100%, height: base, {
    // filet (\footrulewidth)
    place(dy: base - r.position-filet, line(length: 100%, stroke: r.epaisseur-filet + bf-resoudre-couleur(r.couleur-filet)))
    if r.disposition == "bfcours" {
      place(dy: base, gauche)
      place(dy: base, dx: r.decalage-droite, box(width: r.largeur-droite, align(right, droite)))
      if centre != auto { place(dy: base, box(width: 100%, align(center, centre))) }
      // numéro de page dans un disque gray!80!black (nœud TikZ circle, scale=0.8)
      if r.numero {
        let style-num = (size: r.echelle-numero * bf-lire(bf-taille-base-p), fill: bf-resoudre-couleur(r.couleur-numero), top-edge: "cap-height")
        let chiffres = text(..style-num, n)
        // comme le nœud TikZ, le disque s'agrandit autour d'un numéro large (10, 13…) au lieu que les
        // chiffres en touchent le bord ; son centre ne bouge pas, un seul chiffre garde le rayon réglé.
        // (mesure sur la valeur du compteur : `measure` ne voit pas la page où le pied est posé)
        // le disque doit contenir les coins du rectangle des chiffres (demi-diagonale), plus une marge
        let m = measure(text(..style-num, str(counter(page).get().first())))
        let demi-diagonale = calc.sqrt(calc.pow(m.width.pt() / 2, 2) + calc.pow(m.height.pt() / 2, 2)) * 1pt
        let rayon = calc.max(r.rayon, demi-diagonale + 0.12 * r.rayon)
        let d = rayon - r.rayon
        place(top + right, dx: d, dy: base - r.decalage-numero - d, circle(
          radius: rayon,
          fill: bf-resoudre-couleur(r.couleur-disque),
          stroke: none,
          align(center + horizon, chiffres),
        ))
      }
    } else {
      // disposition « simple » : texte à gauche, numéro au centre, texte à droite (pied du skin exolombards)
      place(dy: base, gauche)
      place(dy: base, box(width: 100%, align(center, if centre == auto { if r.numero { n } else { [] } } else { centre })))
      place(dy: base, box(width: 100%, align(right, droite)))
    }
  })
}

// =====================================================================
// \SequenceItem[options]{forme}{description}{commentaire} (bfcours-commands.sty)
// =====================================================================

/// Une ligne de progression : forme en chevron (texte blanc) suivie d'une boîte à deux volets
/// (description à gauche, commentaire à droite, dont le fond est plus clair).
#let sequence-item(forme, description, commentaire, ..options) = context {
  let r = _resoudre("SequenceItem", options.named())
  let c = bf-resoudre-couleur(r.couleur)
  let w = r.largeur-forme
  let h = r.hauteur
  let p = r.pointe
  let boite = block(width: r.largeur-boite, height: h, breakable: false, {
    // ombre portée « lifted » : une ombre douce sous le bord bas
    if r.ombre {
      place(dy: h - 1pt, dx: 4%, ellipse(
        width: 92%,
        height: 5pt,
        fill: gradient.radial(luma(60).transparentize(55%), luma(60).transparentize(100%)),
        stroke: none,
      ))
    }
    // deux volets
    place(box(
      width: 100%,
      height: h,
      clip: true,
      radius: (top-left: 0pt, top-right: r.rayon, bottom-left: r.rayon, bottom-right: r.rayon),
      grid(
        columns: (1fr, 1fr),
        rect(width: 100%, height: h, fill: xmix(c, r.fond-description / 1%), stroke: none, inset: (x: 0.5cm, y: 0.25cm), description),
        rect(width: 100%, height: h, fill: xmix(c, r.fond-commentaire / 1%), stroke: none, inset: (x: 0.5cm, y: 0.25cm), commentaire),
      ),
    ))
    place(rect(
      width: 100%,
      height: h,
      radius: (top-left: 0pt, top-right: r.rayon, bottom-left: r.rayon, bottom-right: r.rayon),
      fill: none,
      stroke: r.epaisseur + c,
    ))
  })
  let chevron = box(width: w, height: h, {
    place(polygon(
      fill: c,
      stroke: c,
      (0pt, 0pt),
      (w / 2, p),
      (w, 0pt),
      (w, h - p),
      (w / 2, h),
      (0pt, h - p),
    ))
    place(center + horizon, box(width: r.largeur-texte, align(center, text(fill: bf-resoudre-couleur(r.couleur-texte), forme))))
  })
  pad(left: r.retrait, grid(columns: (w, auto), chevron, boite))
}
