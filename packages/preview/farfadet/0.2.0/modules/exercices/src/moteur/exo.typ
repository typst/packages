// exo.typ (farfadet-exo) — moteur des exercices (EXO, EXOEVAL), corrections différées (rdexocorrection),
// filtre d'étiquettes (rdexofilter), accesseurs de l'exercice en cours, index des compétences.
//
// Un exercice bfcours n'a par défaut ni cadre ni fond : c'est un en-tête (thème `skin`) suivi de l'énoncé ;
// un cadre facultatif (clé `cadre`, thème ou réglage) peut entourer l'ensemble. La correction (écrite dans le
// corps après le marqueur `#exocorrection`) n'est pas affichée : \rdexocorrection la rejoue plus loin sous un
// en-tête de solution (liens cliquables dans les deux sens), avec son propre cadre facultatif (`cadre-correction`).
//
// Réglages : registres de reglages.typ, tous adressés par l'unique setter `setrdexo` (bf-setrdexo ci-dessous).
// Épurage : le code de compatibilité des anciennes versions (exo, exoeval, corrections, pts,
// total-points, setrdexo à options LaTeX, bf-etoiles) est supprimé du moteur.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "../../../zones-reponse/lib.typ": interne as _crep
#import _crep: crep, tccrep
#import "../../../tableaux/lib.typ": interne as _tableaux
#import _tableaux: tcbtabcomp, cellule, hline
#import "evaluation.typ": mi, mf, ms, tbm, competence, tableaucompetenceeval, bf-couleurs-grille
#import "reglages.typ": *
#import "etoiles.typ": bf-rdexostars
#import "listes.typ": bf-exo-liste, bf-rdexotikzlist, bf-rdexohlist
#import "points.typ": bf-points-info
#import "skins.typ": (
  bf-skins-integres, bf-largeur-entete, bf-thetags, bf-exo-etiquette, bf-the-score, bf-ding110,
)

// =====================================================================
// États
// =====================================================================

/// Numéro d'exercice affiché (rdexo@numexo).
#let bf-exo = counter("bf-exo")

/// Compteur unique (rdexo@real@numexo) : la clé `numexo` ne le touche pas ; il nomme les ancres.
#let bf-exo-reel = counter("bf-exo-reel")

/// \def\rdifficulty{n} : niveau (0 à 3, demi-étoiles permises) des exercices suivants.
#let bf-rdifficulty-p = bf-etat("bf-rdifficulty", 1)
#let bf-rdifficulty = bf-rdifficulty-p.etat
#let rdifficulty(n) = bf-maj(bf-rdifficulty-p, n)

/// Exercice en cours, lu par \thenumexo, \thescore, \theexotitle, \thetags… (`none` hors exercice).
#let bf-exo-courant = state("bf-exo-courant", none)

/// \rdexofilter : expression booléenne d'étiquettes (none = pas de filtre) et sensibilité à la casse.
#let bf-rdexo-filtre-p = bf-etat("bf-rdexo-filtre", (expr: none, match-case: false))
#let bf-rdexo-filtre = bf-rdexo-filtre-p.etat

/// \setcorrectionstyle : styles de boîte de correction par numéro d'exercice (consommés à l'usage).
#let bf-correction-styles-p = bf-etat("bf-rdexo-correction-styles", (:))
#let bf-correction-styles = bf-correction-styles-p.etat

/// bfcours-exobac : décalage de numérotation par partie et intitulés des corrigés.
#let bf-exobac-etat-p = bf-etat("bf-exobac", (decalage: 0, corrword: "Corrigé", corrof: "de l’exercice", actif: false))
#let bf-exobac-etat = bf-exobac-etat-p.etat

/// \rdexoinclude* : options appliquées aux exercices du fichier inclus (file@options).
#let bf-exo-options-fichier-p = bf-etat("bf-exo-options-fichier", (:))
#let bf-exo-options-fichier = bf-exo-options-fichier-p.etat

// =====================================================================
// Outils
// =====================================================================

#import "enroulement.typ": _fonctions-texte, bf-enrouler-ligne

/// Nature du début d'un contenu : "texte" (paragraphe), "multicolonnes" (boîte sans espace
/// avant), "boite" (tcbenumerate, crep, tcbtab… : espace tcolorbox) ou "autre".
#let _debut(c) = {
  let f = c
  while type(f) == content and f.func() == [*a* *b*].func() {
    let enfants = f.children.filter(x => x != [ ] and x.func() != parbreak)
    if enfants.len() == 0 { return "texte" }
    f = enfants.at(0)
  }
  if type(f) != content { return "texte" }
  if f.func() == metadata {
    // points posés en tête d'item : le début est celui du texte de l'item
    if type(f.value) == dictionary and "bf-debut-point" in f.value { return _debut(f.value.at("bf-debut-point")) }
    return if f.value == "bf-multicolonnes" { "multicolonnes" } else { "boite" }
  }
  if f.func() == math.equation { return if f.block { "autre" } else { "texte" } }
  if f.func() in _fonctions-texte or f.func() == [*a*].func() { "texte" } else { "boite" }
}

/// Le corps commence-t-il par un paragraphe (et non par une boîte ou une liste) ?
#let _commence-par-texte(c) = {
  let f = c
  while type(f) == content and f.func() == [*a* *b*].func() {
    let enfants = f.children.filter(x => x != [ ] and x.func() != parbreak)
    if enfants.len() == 0 { return true }
    f = enfants.at(0)
  }
  if type(f) != content { return true }
  if f.func() == math.equation { return not f.block }
  f.func() in _fonctions-texte or f.func() == [*a*].func()
}

/// Contenu vide (none, [], "", espaces) ?
#let _vide(c) = c == none or c == [] or c == "" or c == [ ] or (type(c) == content and c.func() == [*a* *b*].func() and c.children.all(x => x == [ ] or x.func() == parbreak))

/// Texte brut d'une étiquette (pour le filtre).
#let _texte(t) = {
  if type(t) == str { return t }
  if type(t) != content { return str(t) }
  if t.has("text") { return t.text }
  if t.has("children") { return t.children.map(_texte).join("") }
  if t.has("body") { return _texte(t.body) }
  ""
}

// =====================================================================
// \rdexofilter : expression booléenne d'étiquettes (! & | et parenthèses)
// =====================================================================

/// Découpe l'expression en jetons : opérateurs « | & ( ) ! » et noms d'étiquettes (espaces de bord retirés).
#let _jetons(expr) = {
  let res = ()
  let courant = ""
  for ch in expr.clusters() {
    if ch in ("|", "&", "(", ")", "!") {
      if courant.trim() != "" { res.push(("id", courant.trim())) }
      courant = ""
      res.push(("op", ch))
    } else { courant += ch }
  }
  if courant.trim() != "" { res.push(("id", courant.trim())) }
  res
}

/// Analyse descendante : niveau 0 = « | », 1 = « & », 2 = « ! », parenthèses, étiquette.
/// Renvoie (valeur, position suivante).
#let _analyser(jetons, i, niveau, tags) = {
  if niveau == 0 or niveau == 1 {
    let op = if niveau == 0 { "|" } else { "&" }
    let (v, i) = _analyser(jetons, i, niveau + 1, tags)
    while i < jetons.len() and jetons.at(i) == ("op", op) {
      let (w, j) = _analyser(jetons, i + 1, niveau + 1, tags)
      v = if niveau == 0 { v or w } else { v and w }
      i = j
    }
    return (v, i)
  }
  if i >= jetons.len() { panic("rdexofilter : expression incomplète (opérande manquant).") }
  let (genre, val) = jetons.at(i)
  if genre == "op" and val == "!" {
    let (v, j) = _analyser(jetons, i + 1, 2, tags)
    return (not v, j)
  }
  if genre == "op" and val == "(" {
    let (v, j) = _analyser(jetons, i + 1, 0, tags)
    if j >= jetons.len() or jetons.at(j) != ("op", ")") { panic("rdexofilter : parenthèse fermante manquante.") }
    return (v, j + 1)
  }
  if genre == "id" { return (val in tags, i + 1) }
  panic("rdexofilter : jeton inattendu « " + val + " ».")
}

/// L'exercice d'étiquettes `tags` passe-t-il le filtre ?
#let bf-filtre-accepte(expr, tags, match-case: false) = {
  let norm(s) = if match-case { s } else { lower(s) }
  let tags = tags.map(t => norm(_texte(t).trim()))
  let jetons = _jetons(norm(expr))
  if jetons.len() == 0 { return true }
  let (v, i) = _analyser(jetons, 0, 0, tags)
  if i < jetons.len() { panic("rdexofilter : expression mal formée près de « " + jetons.at(i).at(1) + " ».") }
  v
}

/// \rdexofilter[match case]{expression} ; \rdexoresetfilter.
#let bf-rdexofilter(expr, match-case: false) = bf-maj(bf-rdexo-filtre-p, (expr: expr, match-case: match-case))
#let bf-rdexoresetfilter() = bf-maj(bf-rdexo-filtre-p, f => f + (expr: none))

// =====================================================================
// Thèmes
// =====================================================================

/// Habillage du texte des corrections selon le thème (correction style).
#let _texte-correction = (
  bouyachakka: (sans: true, taille: "normalsize", haut: ptl(5)),
  default: (sans: false, taille: "footnotesize", haut: ptl(5)),
  pooja: (sans: false, taille: "footnotesize", haut: ptl(5)),
  rikid: (sans: false, taille: "footnotesize", haut: 0pt),
  griba: (sans: false, taille: "footnotesize", haut: ptl(5)),
  objiva: (sans: false, taille: "footnotesize", haut: ptl(5)),
  exobac: (sans: false, taille: "normalsize", haut: 0pt),
  exobrevet: (sans: false, taille: "normalsize", haut: 0pt),
  exolombards: (sans: false, taille: "normalsize", haut: 0pt, en-ligne: true),
)

/// Fonctions d'un thème (intégré ou déclaré par \rdexoSkin). À appeler dans un `context`.
#let bf-skin(nom, commande: "setrdexo") = {
  if nom in bf-skins-integres { return bf-skins-integres.at(nom) }
  let perso = bf-lire(bf-skins-perso-p)
  if nom in perso {
    let s = perso.at(nom)
    let defaut = bf-skins-integres.default
    let tcolorbox = if s.tcolorbox == none { defaut.tcolorbox } else { info => (bloc: (s.tcolorbox)(info), tags: none) }
    let tcbox = if s.tcbox == none { defaut.tcbox } else { info => (ligne: (s.tcbox)(info), marge: none) }
    return (
      tcolorbox: tcolorbox,
      tcbox: tcbox,
      "none": tcolorbox,
      correction: if s.correction == none { defaut.correction } else { s.correction },
      cadre: s.at("cadre", default: none),
      cadre-correction: s.at("cadre-correction", default: none),
    )
  }
  panic(
    commande + " : thème inconnu « " + nom + " ». Thèmes possibles : "
      + reglages-liste(bf-skins-integres.keys() + perso.keys()) + ".",
  )
}

/// \rdexoSkin{nom}{en-tête tcbox}{en-tête tcolorbox} : déclare un thème. Les en-têtes sont des
/// fonctions `info => contenu` (voir skins.typ pour les champs de `info`). `cadre` et `cadre-correction`
/// (facultatifs, `(info, contenu) => contenu`) habillent l'exercice entier et le bloc de correction.
#let bf-rdexoSkin(nom, tcbox: none, tcolorbox: none, correction: none, cadre: none, cadre-correction: none, couleurs: (:)) = {
  for (cle, f) in (cadre: cadre, cadre-correction: cadre-correction) {
    if f != none and type(f) != function {
      panic("rdexo-skin : valeur invalide pour « " + cle + " » : " + repr(f) + ". Valeurs possibles : none ou une fonction (info, contenu) => contenu.")
    }
  }
  bf-maj(bf-skins-perso-p, d => {
    d.insert(nom, (tcbox: tcbox, tcolorbox: tcolorbox, correction: correction, cadre: cadre, cadre-correction: cadre-correction, couleurs: couleurs))
    d
  })
}

/// Champs de `info` utiles à un cadre, dérivés des couleurs du thème : `couleur` (cadre du thème), `fond`.
#let _info-cadre(c) = (couleur: c.at("frame-color", default: black), fond: c.at("bg-color", default: none))

// =====================================================================
// Boîte basse (lower box)
// =====================================================================

/// Clés de la boîte basse transmises à `crep` comme options nommées (les autres vont dans `tcb`).
#let _cles-crep = ("extra-lines", "seyes", "dotfill", "normal-crep", "show-crep-num", "crep-mode", "forced-height", "seyes-colors", "crep-opaq", "crep-align", "auto-factor")

/// Paramètres de la boîte basse : raccourcis left/right/seyes left/seyes right développés.
#let bf-lower-parametres(lp) = {
  let p = bf-lower-defauts + lp
  for (cle, pos) in (("left", "left"), ("right", "right"), ("seyes-left", "left"), ("seyes-right", "right")) {
    if cle in lp {
      let v = lp.at(cle)
      p.position = pos
      if v != true { p.width = v }
      if cle.starts-with("seyes") { p.box = "crep"; p.style = p.style + (seyes: true) }
    }
  }
  p
}

/// Dessin de la boîte basse. À appeler dans un `context`.
#let _boite-basse(contenu, p, hauteur: auto) = {
  let boite = if p.box == "crep" {
    let nommees = (:)
    let tcb = (:)
    for (k, v) in p.style { if k in _cles-crep { nommees.insert(k, v) } else { tcb.insert(k, v) } }
    if hauteur != auto { tcb.insert("height", hauteur); nommees.insert("forced-height", true) }
    crep(..nommees, tcb: tcb, contenu)
  } else {
    // lower default style : fond transparent à 50 %, \small, boxsep 3 pt (lower style des thèmes)
    let s = p.style
    let fond = bf-exo-couleur(s.at("colback", default: "gray!10!white"))
    let op = s.at("opacityback", default: 0.5)
    block(
      width: 100%,
      height: hauteur,
      fill: if op == 0 { none } else { fond.transparentize((1 - op) * 100%) },
      inset: s.at("boxsep", default: ptl(3)),
      above: 0pt,
      below: 0pt,
      { set text(size: taille-latex("small")); set par(justify: true); contenu },
    )
  }
  if p.mirror { rotate(180deg, reflow: true, boite) } else { boite }
}

// =====================================================================
// Exercice : environnement `exo` (et EXO, EXOEVAL)
// =====================================================================

/// Moteur UNIQUE des exercices : `exo`, `exo-eval` et `rdexoinclude` passent tous par lui (un seul chemin de
/// code, l'environnement `exo` de rdexo et `exo` de bfcours étant la même chose). `nature` : "EXO" ou
/// "EXOEVAL", types du registre « exo » (réglages `setrdexo(pour: "EXOEVAL", …)`).
///   enonce        : contenu de la boîte haute ;
///   tcblower      : contenu de la boîte basse (\tcblower) ;
///   exocorrection : correction (\exocorrection), rejouée par \rdexocorrection ;
///   competence    : entrée de l'index des compétences (\ncomp), none = aucune ;
///   grille        : contenu rangé à côté du titre dans l'en-tête (EXOEVAL : grille MI / MF / MS / TBM), none = rien ;
///   cles          : clés locales (validées par le registre).
#let bf-exercice(
  nature: "EXO",
  enonce,
  tcblower: none,
  exocorrection: none,
  competence: none,
  grille: none,
  cles: (:),
) = context {
  // \rdexoinclude* : options du fichier (file@options), appliquées après les clés locales
  let cles = cles + bf-lire(bf-exo-options-fichier-p)
  // clés de couleur du thème, propres à CET exercice (`exo(skin: "pooja", score-bg-color: red)`)
  let cles-skin = cles.pairs().filter(((k, v)) => k in bf-cles-skin).to-dict()
  let cles = cles.pairs().filter(((k, v)) => k not in bf-cles-skin).to-dict()
  let r = reglages-resoudre(bf-exo-registre, pour: nature, local: cles, commande: nature)
  let tags = bf-exo-liste(r.tags)
  // \rdexofilter : un exercice écarté n'est ni numéroté ni compté
  let filtre = bf-lire(bf-rdexo-filtre-p)
  if filtre.expr != none and not bf-filtre-accepte(filtre.expr, tags, match-case: filtre.match-case) { return }
  // numéro : la clé locale numexo fixe celui de CET exercice (\setcounter après \stepcounter)
  let n = if cles.at("numexo", default: auto) != auto { cles.numexo } else { bf-exo.get().first() + 1 }
  let id = bf-exo-reel.get().first() + 1
  // styles par numéro (exo <n>/.try) : appliqués après les clés locales, comme en LaTeX
  let par-numero = bf-exo-fusion("exo", pour: nature, local: cles)
  if str(n) in par-numero {
    let d = reglages-verifier(nature, par-numero.at(str(n)), bf-exo-controles)
    r = r + d
    tags = bf-exo-liste(r.tags)
  }
  let lp = bf-lower-parametres(bf-exo-fusion("lower", pour: nature, local: cles))
  let niveau = if r.level == auto { bf-lire(bf-rdifficulty-p) } else { r.level }
  let fin = query(selector(<bf-exo-fin>).after(here())).at(0, default: none)
  let score = if r.score != auto { r.score } else if fin != none { bf-points.at(fin.location()).exo } else { 0 }
  // score ABSENT (score: none, ou calculé nul sans display-zero-score) et niveau absent (level: none,
  // ou rdifficulty(none)) : l'en-tête se comporte comme avec display-score / display-level à false
  let score-visible = r.display-score and score != none and not (r.score == auto and score == 0 and not r.display-zero-score)
  let score = if score == none { 0 } else { score }
  // correction comme boîte basse ?
  let (tcblower, exocorrection) = if r.correction-as-lower { (exocorrection, none) } else { (tcblower, exocorrection) }
  let afficher-bas = if r.display-lower == auto { not _vide(tcblower) } else { r.display-lower }
  // lien vers la solution si \rdexocorrection l'affiche
  let lab-sol = label("rdexo-sol-" + str(id))
  let solution = exocorrection != none and query(lab-sol).len() > 0
  let cible = if solution { lab-sol } else { none }
  let m = bf-metriques()
  let e = bf-espacement-tcb(m)
  let prof = est-correction()
  let montrer-tags = tags.len() > 0 and (r.display-tags == true or (r.display-tags == "correction" and prof))
  let c = bf-skin-couleurs(r.skin, local: cles-skin)
  let fonctions = bf-skin(r.skin, commande: nature)
  let exobac = bf-lire(bf-exobac-etat-p)
  let lombards = reglages-courants(bf-exolombards-registre)
  let extra = if r.skin in ("exobac", "exobrevet") { exobac } else if r.skin == "exolombards" { lombards } else { (:) }
  let info = (
    n: n,
    id: id,
    label: r.label,
    display-numexo: r.display-numexo,
    display-score: score-visible,
    display-level: r.display-level and niveau != none,
    display-exotitle: r.display-exotitle,
    titre: r.exotitle,
    grille: grille,
    score: score,
    niveau: niveau,
    score-label: r.score-label,
    tags: tags,
    montrer-tags: montrer-tags,
    cible: cible,
    police-titre: bf-exo-police(r.exotitle-font),
    couleur-titre: if c.title-color != auto { bf-exo-couleur(c.title-color) } else { bf-exo-couleur(r.exotitle-color) },
    header-skip: r.header-skip,
    c: c,
    skin: r.skin,
    exo-header: r.exo-header,
    extra: extra,
  )
  // \kern\rdexoheaderskip sous l'en-tête, puis l'espace propre au premier élément de l'énoncé
  // (relevés LaTeX : paragraphe → ligne de base à 6 pt + hauteur TeX ; MultiColonnes → 6 pt ;
  // tcbenumerate et autres tcolorbox → 6 pt + 0,5 \baselineskip)
  let debut = _debut(enonce)
  let saut = if debut == "texte" { r.header-skip + m.asc - m.haut } else if debut == "multicolonnes" {
    r.header-skip
  } else { r.header-skip + 0.5 * m.bs }
  let entete = (fonctions.at(r.exo-header))(info)
  let corps-enonce = {
    set par(justify: true)
    bf-sans-espace-initial(enonce)
  }
  let haut = {
    // L'ancre de l'énoncé est posée dès qu'il y a une correction, sans attendre que la solution soit
    // affichée : posée seulement « si la solution existe », elle formait une boucle (ancre ← solution ←
    // test de l'ancre dans rdexocorrection) qui coûtait deux passes de plus et faisait dépasser les cinq
    // passes de Typst aux longs documents (« number of elements labelled <rdexo-enonce-n> did not stabilize »).
    if exocorrection != none [#metadata(n)#label("rdexo-enonce-" + str(id))]
    if "bloc" in entete {
      let bloc-tags = entete.at("tags", default: none)
      // étiquettes sous le bandeau : l'énoncé peut commencer sur leur ligne, à leur gauche (clé `tags-wrap`)
      if bloc-tags != none and r.tags-wrap != none and debut != "multicolonnes" and type(enonce) == content {
        // repli : exactement la disposition d'origine (étiquettes sous le bandeau, puis énoncé)
        let repli = {
          block(width: 100%, above: 0pt, below: saut, breakable: false, sticky: true, {
            entete.bloc
            bloc-tags
          })
          corps-enonce
        }
        // un énoncé qui commence par du texte (même stylé) a l'espace d'un paragraphe sous le bandeau
        let saut-texte = r.header-skip + m.asc - m.haut
        bf-enrouler-ligne(
          bf-thetags(tags, c, skin: r.skin), enonce, repli, seuil: r.tags-wrap, pose: x => box(baseline: 50% - 0.35em, x),
          habiller: x => {
            block(width: 100%, above: 0pt, below: 0pt, breakable: false, sticky: true, entete.bloc)
            block(width: 100%, above: saut-texte, below: 0pt, { set par(justify: true); x })
          },
        )
      } else {
        block(width: 100%, above: 0pt, below: saut, breakable: false, sticky: true, {
          entete.bloc
          if bloc-tags != none { bloc-tags }
        })
        corps-enonce
      }
    } else {
      // en-tête en ligne (exo header=tcbox) : l'énoncé suit sur la même ligne
      let marge = entete.at("marge", default: none)
      if marge != none {
        let lm = measure(marge)
        // jamais rognée par le bord de la page
        place(top + left, dx: calc.max(-1em.to-absolute() - lm.width, -here().position().x + 1mm), marge)
      }
      set par(justify: true)
      [#entete.ligne#if not entete.at("sans-decalage", default: false) [ ]#bf-sans-espace-initial(enonce)]
    }
    // étiquettes verticales dans la marge gauche (overlay de bfcours, thème bouyachakka)
    if montrer-tags and r.skin == "bouyachakka" and "bloc" in entete {
      let bande = stack(dir: ltr, spacing: 2pt, ..tags.map(t => bf-exo-etiquette(t, c)))
      let lb = measure(bande)
      // jamais coupée par le bord de la page : si la marge est plus étroite que la bande, elle se rapproche
      // du bord de la page (au pire elle recouvre le début du bandeau, jamais la page n'en rogne une partie)
      let x0 = here().position().x
      let dx = calc.max(-0.3cm - lb.height / 2, -x0 + 1mm)
      place(bottom + left, dx: dx, rotate(-90deg, reflow: true, bande))
    }
  }
  let bas = if afficher-bas { _boite-basse(if tcblower == none { [] } else { tcblower }, lp) }
  let avant = if r.skin == "exolombards" { ptl(8) } else { e.above }
  let apres = if r.skin == "exolombards" { ptl(2) } else if r.skin in ("exobac", "exobrevet") { ptl(13) } else { r.after-skip }
  // compteurs, points, exercice en cours
  if cles.at("numexo", default: auto) != auto { bf-exo.update(n) } else { bf-exo.step() }
  bf-exo-reel.step()
  bf-points.update(p => p + (exo: 0))
  bf-points-info.update(p => p + (exo: 0))
  bf-exo-courant.update((
    n: n, label: r.label, score: score, niveau: niveau, titre: r.exotitle, tags: tags,
    display-numexo: r.display-numexo, display-score: score-visible, display-exotitle: r.display-exotitle,
    display-level: r.display-level and niveau != none,
    display-tags: r.display-tags, score-label: r.score-label, police-titre: info.police-titre,
    couleur-titre: info.couleur-titre, skin: r.skin, c: c,
  ))
  // \ncomp : entrée de l'index des compétences (\printcompindex)
  if competence != none and competence != "" [#metadata(competence) <bf-exo-comp>]
  // EXO : entrée de sommaire « Exercice n - titre » (\addcontentsline{toc}{subsection})
  // `libelle` et `compteur` : le sommaire relit le numéro au compteur, à l'emplacement de l'entrée. Juste
  // dès le tour 2 (les pas du compteur sont posés au tour 1), alors que `n`, lu par `get()`, ne l'est qu'au
  // tour 3 : le sommaire n'est plus recomposé au tour 3. `nom` reste pour les anciens lecteurs.
  if nature == "EXO" and r.sommaire [#metadata((
    nom: [#r.label #n], libelle: r.label, compteur: bf-exo, titre: r.exotitle, simple: false,
  ))<bf-toc>]
  // cadre autour de l'exercice entier : clé (locale, style, type, global) > thème > aucun. Le cadre reçoit
  // en-tête + énoncé (+ boîte basse) ; les espaces avant et après restent ceux du bloc extérieur.
  let cadre = if r.cadre != auto { r.cadre } else { fonctions.at("cadre", default: none) }
  let lateral = not (lp.position == "bottom" or not afficher-bas)
  let habiller-cadre(contenu) = if cadre == none { contenu } else {
    cadre(info + _info-cadre(c) + (breakable: r.breakable and not lateral, correction: false), contenu)
  }
  if not lateral {
    block(width: 100%, above: avant, below: apres, breakable: r.breakable, habiller-cadre({
      haut
      if afficher-bas {
        v(lp.skip, weak: true)
        bas
      }
    }))
  } else {
    block(width: 100%, above: avant, below: apres, breakable: false, habiller-cadre(layout(taille => {
      let wl = if type(lp.width) == ratio { lp.width * taille.width } else if type(lp.width) == relative { lp.width.ratio * taille.width + lp.width.length } else { lp.width }
      let we = taille.width - lp.skip - wl
      let partie-exo = block(width: we, above: 0pt, below: 0pt, bf-avec-largeur(haut))
      let h = measure(partie-exo, width: we).height
      let partie-bas = block(width: wl, above: 0pt, below: 0pt, _boite-basse(if tcblower == none { [] } else { tcblower }, lp, hauteur: h))
      let cellules = if lp.position == "left" { (partie-bas, partie-exo) } else { (partie-exo, partie-bas) }
      let colonnes = if lp.position == "left" { (wl, we) } else { (we, wl) }
      grid(columns: colonnes, column-gutter: lp.skip, align: top, ..cellules)
    })))
  }
  [#metadata(none) <bf-exo-fin>]
  if exocorrection != none {
    let ex = if r.skin in ("exobac", "exobrevet") {
      (corrword: exobac.corrword, corrof: exobac.corrof, num: n - exobac.decalage)
    } else { (:) }
    [#metadata((correction: exocorrection, n: n, id: id, label: r.label, titre: r.exotitle, extra: ex, cadre-correction: r.cadre-correction)) <bf-rdexo-correction>]
  }
}

// =====================================================================
// \setrdexo
// =====================================================================

/// Les cinq registres de réglages du paquet, tous adressés par l'unique setter `setrdexo`.
#let _registres = (bf-exo-registre, bf-skins-registre, bf-etoiles-registre, bf-divers-registre, bf-exolombards-registre)

/// Types acceptés par `setrdexo(pour: …)` : exercices, thèmes, étoiles, options d'exolombards, objets divers.
#let bf-types-setrdexo = (
  bf-types-exercice
    + bf-skins-defauts.keys().filter(k => k != "exolombards")
    + ("rdexostars", "exolombards")
    + bf-divers-types.keys()
)

/// Registre qui porte le type `p` de `setrdexo(pour: p, …)`.
#let _registre-de(p) = {
  if type(p) != str {
    panic("setrdexo : `pour` attend un nom de type ou un tableau de noms ; reçu : " + repr(p) + ".")
  }
  if p in bf-types-exercice { bf-exo-registre }
  else if p == "rdexostars" { bf-etoiles-registre }
  else if p == "exolombards" { bf-exolombards-registre }
  else if p in bf-skins-defauts { bf-skins-registre }
  else if p in bf-divers-types { bf-divers-registre }
  else { panic("setrdexo : type inconnu « " + p + " ». Types possibles : " + reglages-liste(bf-types-setrdexo) + ".") }
}

/// Styles de boîte de correction par numéro (`correction-style: ("1,3": (colback: …))`) : consommés à l'usage.
#let _correction-styles(dico) = {
  if type(dico) != dictionary or dico.values().any(s => type(s) != dictionary) {
    panic("setrdexo : valeur invalide pour la clé « correction-style » : " + repr(dico) + ". Valeurs possibles : un dictionnaire numéros → style, par exemple (\"1,3\": (colback: \"yellow!10\")).")
  }
  for (numeros, style) in dico {
    for (k, v) in style {
      if k not in bf-cles-boite {
        panic("setrdexo : clé « correction-style » : clé inconnue « " + k + " ». Clés possibles : " + reglages-liste(bf-cles-boite) + ".")
      }
    }
  }
  bf-maj(bf-correction-styles-p, d => {
    for (numeros, style) in dico {
      for n in numeros.split(",") { d.insert(str(int(n.trim())), style) }
    }
    d
  })
}

/// L'unique setter du paquet. Sans `pour` : réglage global des exercices ; avec `pour: "<type>"` : réglage
/// du type (un exercice, un thème, les étoiles, une boîte de points, un tableau…), `pour:` accepte
/// aussi un tableau de types. `definir: "nom"` définit un style nommé. `reinitialiser` : voir la convention
/// des setters (socle, REGLAGES.md) ; avec `pour:`, seuls les réglages de ces types sont oubliés.
/// Actions immédiates : `numexo: n` met le compteur à n (le prochain exercice porte le numéro n + 1,
/// comme en LaTeX) ; `correction-style` range des styles de boîte pour le prochain `rdexocorrection`.
#let bf-setrdexo(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if cles.pos().len() > 0 {
    panic("setrdexo : seuls des arguments nommés sont acceptés, par exemple setrdexo(display-level: false) ; reçu : " + repr(cles.pos().first()) + ".")
  }
  if reinitialiser not in (true, false, "tout") {
    panic("setrdexo : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  let c = cles.named()
  // registres visés, avec leurs types (none = réglage global du registre des exercices)
  let types-par-registre = (:)
  if pour == none { types-par-registre.insert(bf-exo-registre.nom, none) } else {
    for p in (if type(pour) == array { pour } else { (pour,) }) {
      let nom = _registre-de(p).nom
      // les étoiles et exolombards n'ont pas de types : leurs clés sont les réglages globaux du registre
      if p in ("rdexostars", "exolombards") { types-par-registre.insert(nom, none) } else {
        types-par-registre.insert(nom, types-par-registre.at(nom, default: ()) + (p,))
      }
    }
  }
  // actions immédiates du registre des exercices
  let exo-vise = bf-exo-registre.nom in types-par-registre
  if exo-vise and "numexo" in c {
    let v = c.remove("numexo")
    if type(v) != int { panic("setrdexo : valeur invalide pour la clé « numexo » : " + repr(v) + ". Valeurs possibles : un entier.") }
    bf-exo.update(v)
  }
  if exo-vise and "correction-style" in c { _correction-styles(c.remove("correction-style")) }
  if definir != none {
    for r in _registres {
      if r.nom in types-par-registre { reglages-definir-style(r, definir, pour: types-par-registre.at(r.nom), ..c) }
    }
    return
  }
  if reinitialiser != false and pour == none {
    for r in _registres { reglages-reinitialiser(r, styles: reinitialiser == "tout") }
  }
  for r in _registres {
    if r.nom not in types-par-registre { continue }
    let types = types-par-registre.at(r.nom)
    if reinitialiser != false and types != none {
      // remise à zéro de ces seuls types
      bf-maj(r, e => {
        for t in types { let _ = e.types.remove(t, default: none) }
        if reinitialiser == "tout" { e.styles = r.at("styles-initiaux", default: (:)) }
        e
      })
    } else if reinitialiser != false and pour != none {
      // registre sans types (étoiles, exolombards) visé par `pour`
      reglages-reinitialiser(r, styles: reinitialiser == "tout")
    }
    if c.len() > 0 { reglages-regler(r, pour: types, ..c) }
  }
}

// =====================================================================
// \the… : l'exercice en cours
// =====================================================================

#let _courant() = {
  let c = bf-exo-courant.get()
  if c == none { panic("Les commandes \\thenumexo, \\thescore… ne s'emploient que dans un exercice.") }
  c
}
#let _encadre(etoile, visible, avant, apres, x) = if etoile { if visible [#avant#x#apres] } else { x }

/// \thenumexo[*][avant][après]
#let bf-thenumexo(etoile: false, avant: [], apres: []) = context {
  let c = _courant()
  _encadre(etoile, c.display-numexo, avant, apres, [#c.n])
}
/// \thescore[*][avant][après] : score à la française (« 2,5 »).
#let bf-thescore(etoile: false, avant: [], apres: []) = context {
  let c = _courant()
  _encadre(etoile, c.display-score, avant, apres, bf-nombre(c.score))
}
/// \theScore[*][avant][après] : « 2,5 points ».
#let bf-theScore(etoile: false, avant: [], apres: []) = context {
  let c = _courant()
  _encadre(etoile, c.display-score, avant, apres, bf-the-score(c.score, c.score-label))
}
/// \rdexoscore : valeur brute du score.
#let bf-rdexoscore() = context _courant().score
/// \theexotitle[*][avant][après]
#let bf-theexotitle(etoile: false, avant: [], apres: []) = context {
  let c = _courant()
  _encadre(etoile, c.display-exotitle and c.titre != none, avant, apres, c.titre)
}
/// \theExotitle[*][avant][après] : titre dans la police et la couleur de titre.
#let bf-theExotitle(etoile: false, avant: [], apres: []) = context {
  let c = _courant()
  _encadre(etoile, c.display-exotitle and c.titre != none, avant, apres, text(..c.police-titre, fill: c.couleur-titre, c.titre))
}
/// \thetags[*][max cols] : étiquettes en matrice, au style du thème courant.
#let bf-thetags-courant(etoile: false, max-cols: 0) = context {
  let c = _courant()
  let visible = c.display-tags == true or (c.display-tags == "correction" and est-correction())
  if etoile and not visible { return }
  // Dans une boîte : la matrice (un `layout`) cassait le paragraphe quand la macro est écrite dans
  // une phrase, et la ponctuation qui la suit tombait seule sur la ligne suivante.
  box(baseline: 30%, bf-thetags(c.tags, c.c, skin: c.skin, max-cols: max-cols))
}
/// \thelabel : libellé (« Exercice »).
#let bf-thelabel() = context {
  let c = bf-exo-courant.get()
  if c == none { reglages-courants(bf-exo-registre).label } else { c.label }
}
/// \rdexotags : étiquettes de l'exercice en cours, séparées par des virgules.
#let bf-rdexotags() = context _courant().tags.join(", ")
/// \thelevel : niveau de l'exercice en cours (0 s'il n'y en a pas).
#let bf-thelevel() = context {
  let c = _courant()
  [#bf-nombre(if c.niveau == none { 0 } else { c.niveau })]
}
/// \rdexonumexo : valeur du compteur d'exercices ; `f` (ajout) reçoit l'entier, pour calculer avec.
#let bf-rdexonumexo(f: none) = context {
  let n = bf-exo.get().first()
  if f == none { [#n] } else { f(n) }
}
/// \rdexoMod{a}{b} : modulo (le résultat a le signe de b, comme dans rdexo).
#let bf-rdexoMod(a, b) = a - b * calc.floor(a / b)
/// \rdexotitlefont : police du titre de l'exercice en cours (sinon celle du réglage `exotitle-font`).
#let bf-rdexotitlefont(corps) = context {
  let c = bf-exo-courant.get()
  let police = if c == none { bf-exo-police(reglages-courants(bf-exo-registre).exotitle-font) } else { c.police-titre }
  text(..police, corps)
}
/// \TFNumexo, \TFScore, \TFLevel, \TFTitle, \TFTags : `oui` si l'élément est affiché, `non` sinon
/// (conditionnelles d'écriture des thèmes, dans l'exercice en cours).
#let bf-TFNumexo(oui, non) = context { if _courant().display-numexo { oui } else { non } }
#let bf-TFScore(oui, non) = context { if _courant().display-score { oui } else { non } }
#let bf-TFLevel(oui, non) = context { if _courant().display-level { oui } else { non } }
#let bf-TFTitle(oui, non) = context {
  let c = _courant()
  if c.display-exotitle and c.titre != none { oui } else { non }
}
#let bf-TFTags(oui, non) = context {
  let c = _courant()
  if c.display-tags == true or (c.display-tags == "correction" and est-correction()) { oui } else { non }
}

// =====================================================================
// Corrections différées : \rdexocorrection (le style d'une boîte de correction se règle par
// `setrdexo(correction-style: ("1,3": (…)))`, ancien \setcorrectionstyle)
// =====================================================================

/// Habillage d'une boîte (clé `correction-style`, mirror style) : fond, cadre, marges, police.
/// À appeler dans un `context`.
#let bf-habiller-boite(s, corps) = {
  if s.len() == 0 { return corps }
  let fond = bf-exo-couleur(s.at("colback", default: none))
  let fond = if s.at("opacityback", default: 1) == 0 { none } else { fond }
  let cadre = bf-exo-couleur(s.at("colframe", default: none))
  let trait = s.at("boxrule", default: if cadre != none { ptl(0.5) } else { 0pt })
  let sep = s.at("boxsep", default: if fond != none or cadre != none { 1mm } else { 0pt })
  let police = bf-exo-police(s.at("fontupper", default: none))
  let couleur = bf-exo-couleur(s.at("coltext", default: none))
  let c = text(..police, ..if couleur != none { (fill: couleur) } else { (:) }, corps)
  let al = s.at("halign", default: none)
  let c = if al in ("left", "flush left") { align(left, c) } else if al in ("center", "flush center") { align(center, c) } else if al in ("right", "flush right") { align(right, c) } else { c }
  block(
    width: s.at("width", default: 100%),
    fill: fond,
    stroke: if cadre != none and trait > 0pt { trait + cadre } else { none },
    radius: s.at("arc", default: 0pt),
    inset: (
      left: sep + s.at("left", default: 0pt),
      right: sep + s.at("right", default: 0pt),
      top: sep + s.at("top", default: 0pt),
      bottom: sep + s.at("bottom", default: 0pt),
    ),
    c,
  )
}

/// Liste demandée : 0 (depuis le dernier appel), "tous", tableau, ou chaîne « 1,3 » / « 2,...,5 ».
#let _numeros(liste) = {
  if type(liste) == array { return liste }
  let s = str(liste).replace(" ", "")
  let m = s.match(regex("^(\d+),\.\.\.,(\d+)$"))
  if m != none { return range(int(m.captures.at(0)), int(m.captures.at(1)) + 1) }
  s.split(",").filter(x => x != "").map(int)
}

/// \rdexocorrection[options]{liste} : rejoue les corrections.
///   0 (ou "0", "nouveaux") : exercices posés depuis le dernier appel (reset num start) ;
///   "1,3", "2,...,5", (2, 4) : exercices choisis, dans l'ordre de la liste ; "tous" : tout le document.
/// Options (/tcb/rdexo/correction/) : columns, raster, mirror, mirror-style, reset-num-start ;
/// `lombards` : mode du thème exolombards (auto | suite | separee), `reference` (\corrigeLombards).
#let bf-rdexocorrection(liste, reference: none, mode-lombards: auto, ..cles) = {
  let locales = cles.named()
  for (k, v) in locales {
    if k not in bf-correction-defauts {
      panic("rdexocorrection : clé inconnue « " + k + " ». Clés possibles : " + reglages-liste(bf-correction-defauts.keys()) + ".")
    }
  }
  context {
    let r = reglages-courants(bf-exo-registre)
    let cp = bf-correction-defauts + bf-exo-fusion("correction") + locales
    let ici = here()
    // appels précédents seulement (qui remettent le départ à zéro)
    let appels = query(selector(<bf-rdexo-appel>).before(ici)).filter(a => a.value.reset)
    let depuis = if appels.len() > 0 { appels.last().location() } else { none }
    let toutes = query(selector(<bf-rdexo-correction>).before(ici))
    let nouvelles = liste == 0 or liste == "0" or liste == "nouveaux"
    let corrections = if nouvelles {
      if depuis == none { toutes } else { query(selector(<bf-rdexo-correction>).before(ici).after(depuis)) }
    } else if liste == "tous" { toutes } else {
      // \rdexocorrection{1,3} : la DERNIÈRE correction rangée sous chaque numéro, dans l'ordre demandé
      _numeros(liste).map(k => toutes.filter(c => c.value.n == k).at(-1, default: none)).filter(c => c != none)
    }
    // exolombards : un numéro seul = la correction suit l'énoncé ; 0 ou une liste = partie séparée
    let lombards = reglages-courants(bf-exolombards-registre)
    let mode = if mode-lombards == auto { lombards.correction } else { mode-lombards }
    let suite = if reference != none { false } else if mode == "suite" { true } else if mode == "separee" { false } else {
      not nouvelles and liste != "tous" and type(liste) != array and not str(liste).contains(",")
    }
    let skin = r.skin
    let fonctions = bf-skin(skin, commande: "rdexocorrection")
    let couleurs = bf-skin-couleurs(skin)
    let texte = _texte-correction.at(skin, default: _texte-correction.default)
    let styles = bf-lire(bf-correction-styles-p)
    let m = bf-metriques()
    let rendu = ()
    for c in corrections {
      let val = c.value
      let cible = label("rdexo-enonce-" + str(val.id))
      let cible = if query(cible).len() > 0 { cible } else { none }
      // une solution rejouée une seconde fois ne repose pas d'ancre (étiquette unique)
      let premiere = query(selector(label("rdexo-sol-" + str(val.id))).before(ici)).len() == 0
      let extra = if skin == "exolombards" { lombards + (suite: suite, reference: reference) } else { val.extra }
      let corr = (n: val.n, id: val.id, label: val.label, titre: val.titre, cible: cible, c: couleurs, extra: extra, skin: skin)
      let entete = (fonctions.correction)(corr)
      let e = val.correction
      let style = styles.at(str(val.n), default: (:))
      let corps = if texte.at("en-ligne", default: false) {
        block(width: 100%, above: 0pt, below: 0pt, {
          if premiere [#metadata(val.n)#label("rdexo-sol-" + str(val.id))]
          set par(justify: true)
          [#entete#bf-sans-espace-initial(e)]
        })
      } else {
        block(width: 100%, breakable: true, above: 0pt, below: 0pt, {
          if premiere [#metadata(val.n)#label("rdexo-sol-" + str(val.id))]
          // collé au début de la solution : jamais seul au pied d'une page
          block(width: 100%, above: 0pt, below: 0pt, sticky: true, entete)
          v(texte.haut, weak: false)
          let police = (size: if texte.sans { bf-exo-taille-sans(texte.taille) } else { taille-latex(texte.taille) })
          if texte.sans { police.insert("font", bf-exo-sans) }
          set text(..police)
          // les formules gardent la taille du texte SERIF du même corps (le texte sans-serif est plus gros) :
          // un rapport relatif, jamais une taille absolue, pour que `text(7pt)[$-2$]` ou une figure cetz
          // gardent la taille qu'on leur donne
          let rapport = if texte.sans { taille-latex(texte.taille) / bf-exo-taille-sans(texte.taille) } else { 1 }
          show math.equation: set text(size: 1em * rapport) if rapport != 1

          set par(justify: true)
          let saut = if _commence-par-texte(e) { m.asc - m.haut } else { 0pt }
          v(saut, weak: true)
          bf-sans-espace-initial(e)
        })
      }
      // cadre de la correction : clé de l'exercice (posée avec lui) > réglage courant > thème > aucun
      let cadre-corr = val.at("cadre-correction", default: auto)
      let cadre-corr = if cadre-corr == auto { r.cadre-correction } else { cadre-corr }
      let cadre-corr = if cadre-corr == auto { fonctions.at("cadre-correction", default: none) } else { cadre-corr }
      let corps = if cadre-corr == none { corps } else {
        cadre-corr(corr + _info-cadre(couleurs) + (breakable: true, correction: true), corps)
      }
      rendu.push(bf-habiller-boite(style, corps))
    }
    if rendu.len() > 0 {
      let (avant, entre, apres) = if skin == "exolombards" {
        if suite { (ptl(8), ptl(4), ptl(2)) } else { (0pt, ptl(4), ptl(4)) }
      } else if skin in ("exobac", "exobrevet") { (ptl(6), ptl(8), ptl(6)) } else {
        // tcbraster : 2 mm avant, qui s'AJOUTENT à l'espace laissé par le titre qui précède
        // (relevé LaTeX : 7,87 pt de plus que l'espace sous un \section*)
        (2mm + 2.2pt, 2mm + ptl(1), 2mm)
      }
      let rs = cp.raster
      let entre = rs.at("raster-row-skip", default: entre)
      let colonnes = cp.columns
      let raster = if colonnes <= 1 {
        block(width: 100%, above: 0pt, below: apres, rendu.map(b => block(width: 100%, above: entre, below: 0pt, b)).join())
      } else {
        block(width: 100%, above: 0pt, below: apres, grid(
          columns: (1fr,) * colonnes,
          column-gutter: rs.at("raster-column-skip", default: ptl(10)),
          row-gutter: entre,
          align: top,
          ..rendu,
        ))
      }
      v(rs.at("raster-before-skip", default: avant), weak: false)
      if cp.mirror {
        block(width: 100%, above: 0pt, below: 0pt, rotate(180deg, reflow: true, bf-habiller-boite(cp.mirror-style, raster)))
      } else { raster }
      // `correction-style` : un style par numéro ne sert qu'une fois (\rdexogtcbset de rdexo)
      let utilises = corrections.map(c => str(c.value.n)).filter(k => k in styles)
      if utilises.len() > 0 { bf-maj(bf-correction-styles-p, d => { for k in utilises { let _ = d.remove(k, default: none) }; d }) }
    }
    [#metadata((reset: cp.reset-num-start)) <bf-rdexo-appel>]
  }
}

// =====================================================================
// Liens énoncé ↔ solution (bfcours-use_rdexo_rdcrep.sty l. 17-36)
// =====================================================================

/// \rdexoEnonceLabel{n}{texte} : texte cliquable vers la solution de l'exercice n (si elle est affichée).
#let bf-rdexoEnonceLabel(n, corps) = context {
  let c = query(<bf-rdexo-correction>).filter(c => c.value.n == n)
  if c.len() == 0 { return corps }
  let cible = label("rdexo-sol-" + str(c.last().value.id))
  if query(cible).len() > 0 { link(cible, corps) } else { corps }
}

/// \rdexoSolutionLabel{n}{texte} : texte cliquable vers l'énoncé de l'exercice n.
#let bf-rdexoSolutionLabel(n, corps) = context {
  let c = query(<bf-rdexo-correction>).filter(c => c.value.n == n)
  if c.len() == 0 { return corps }
  let cible = label("rdexo-enonce-" + str(c.last().value.id))
  if query(cible).len() > 0 { link(cible, corps) } else { corps }
}

// =====================================================================
// EXO, EXOEVAL (new-bfcours-environments.sty l. 386-430)
// =====================================================================

/// Grille MI / MF / MS / TBM de l'en-tête d'EXOEVAL (\tcbtabcomp, \arraystretch 0,75).
#let bf-grille-exoeval() = context {
  let g = bf-couleurs-grille()
  tcbtabcomp(
    "|>{\\centering\\arraybackslash}p{0.55cm}|>{\\centering\\arraybackslash}p{0.55cm}|>{\\centering\\arraybackslash}p{0.55cm}|>{\\centering\\arraybackslash}p{0.9cm}",
    etirement: 0.75,
    hline(),
    cellule(fill: g.mi, mi()), cellule(fill: g.mf, mf()),
    cellule(fill: g.ms, ms()), cellule(fill: g.tbm, tbm()),
    hline(),
    [], [], [], [],
  )
}

// =====================================================================
// Marqueurs #tcblower et #exocorrection : découpent le corps d'un exercice
// =====================================================================

/// Les marqueurs `tcblower` et `exocorrection` (\tcblower, \exocorrection de bfcours) : des repères
/// invisibles déposés dans le corps d'`exo` / `exo-eval`, qui le coupent en énoncé, partie basse (affichée
/// dans la boîte) et correction (rejouée par `rdexocorrection`). Hors d'un exercice, ils n'affichent rien.
/// S'écrivent sans parenthèses : `#tcblower`, `#exocorrection`.
#let bf-tcblower = metadata((bf-marqueur: "tcblower"))
#let bf-exocorrection = metadata((bf-marqueur: "exocorrection"))

#let _marqueur-de(c) = if type(c) == content and c.func() == metadata and type(c.value) == dictionary and "bf-marqueur" in c.value { c.value.bf-marqueur } else { none }

/// Nombre de marqueurs de ce nom dans un contenu, à n'importe quelle profondeur (listes, colonnes, blocs…).
#let _compte-marqueurs(c, nom) = {
  if type(c) == array { return c.map(x => _compte-marqueurs(x, nom)).sum(default: 0) }
  if type(c) != content { return 0 }
  if _marqueur-de(c) != none { return if _marqueur-de(c) == nom { 1 } else { 0 } }
  c.fields().values().map(x => _compte-marqueurs(x, nom)).sum(default: 0)
}

/// Retire les espaces et sauts de paragraphe de bout d'une suite de contenus (`debut` / `fin`).
#let _rogner(enfants, debut: false, fin: false) = {
  let blanc(x) = x.func() in (parbreak, [ ].func())
  let e = enfants
  if debut { while e.len() > 0 and blanc(e.first()) { e = e.slice(1) } }
  if fin { while e.len() > 0 and blanc(e.last()) { e = e.slice(0, -1) } }
  e
}

/// Coupe le corps d'un exercice aux marqueurs `tcblower` et `exocorrection` : renvoie (énoncé, partie
/// basse, correction) : `none` pour une partie dont le marqueur est absent, `[]` quand le marqueur n'est
/// suivi de rien. Ordre : énoncé, `#tcblower`, partie basse,
/// `#exocorrection`, correction (celui de LaTeX) ; l'ordre inverse est une erreur. Chaque marqueur doit
/// être au premier niveau du corps, une seule fois : imbriqué dans une liste, des colonnes ou un bloc,
/// ou répété, il provoque une erreur explicite. `nom` : nom de l'exercice (EXO, EXOEVAL) pour les messages.
#let bf-couper-exo(nom, corps) = {
  if type(corps) != content { return (corps, none, none) }
  let positions = (:)
  let enfants = if corps.func() == [*a* *b*].func() { corps.children } else { (corps,) }
  for m in ("tcblower", "exocorrection") {
    let total = _compte-marqueurs(corps, m)
    if total > 1 {
      panic(nom + " : le marqueur #" + m + " apparaît " + str(total) + " fois dans le même corps ; il n'en faut qu'un.")
    }
    if total == 1 {
      let i = enfants.position(c => _marqueur-de(c) == m)
      if i == none {
        panic(nom + " : le marqueur #" + m + " est imbriqué dans une liste, des colonnes ou un bloc. Il doit être au premier niveau du corps de l'exercice : #" + nom + "[Titre][Énoncé #tcblower Partie basse #exocorrection Correction].")
      }
      positions.insert(m, i)
    }
  }
  if positions.len() == 0 { return (corps, none, none) }
  if "tcblower" in positions and "exocorrection" in positions and positions.exocorrection < positions.tcblower {
    panic(nom + " : #tcblower doit précéder #exocorrection (énoncé, #tcblower, partie basse, #exocorrection, correction), comme dans LaTeX.")
  }
  let tranche(a, b) = {
    // marqueur sans rien après lui : partie vide (une solution sans texte, comme `exocorrection: []` jadis)
    _rogner(enfants.slice(a, b), debut: a > 0, fin: true).join(default: [])
  }
  let fin-enonce = positions.values().fold(enfants.len(), calc.min)
  let enonce = _rogner(enfants.slice(0, fin-enonce), fin: true).join(default: [])
  let basse = if "tcblower" in positions {
    tranche(positions.tcblower + 1, positions.at("exocorrection", default: enfants.len()))
  } else { none }
  let correction = if "exocorrection" in positions { tranche(positions.exocorrection + 1, enfants.len()) } else { none }
  (enonce, basse, correction)
}

/// \begin{EXO}{titre}{tags} : `titre` dans une minipage (thème bouyachakka), \ncomp{titre}, sommaire.
#let bf-EXO(titre, enonce, tcblower: none, exocorrection: none, competence: auto, cles: (:)) = {
  let comp = if competence == auto { titre } else { competence }
  bf-exercice(
    nature: "EXO",
    enonce,
    tcblower: tcblower,
    exocorrection: exocorrection,
    competence: comp,
    cles: cles + if titre != none { (exotitle: titre) } else { (:) },
  )
}

/// \begin{EXOEVAL}{titre}{compétence} : le même exercice, dont l'en-tête porte en plus la grille
/// MI / MF / MS / TBM (`grille`) ; \ncomp{tags} (ce sont les étiquettes qui entrent dans l'index des compétences).
#let bf-EXOEVAL(titre, enonce, tcblower: none, exocorrection: none, competence: auto, cles: (:)) = {
  let tags = cles.at("tags", default: auto)
  let comp = if competence != auto { competence } else if type(tags) == array { tags.join(", ") } else if tags == auto { none } else { tags }
  bf-exercice(
    nature: "EXOEVAL",
    enonce,
    tcblower: tcblower,
    exocorrection: exocorrection,
    competence: comp,
    grille: bf-grille-exoeval(),
    cles: cles + if titre != none { (exotitle: titre) } else { (:) },
  )
}

// =====================================================================
// Index des compétences (bfcours-competencies.sty)
// =====================================================================

/// Compétences du document (\ncomp), sans doublon, dans l'ordre d'apparition, avec les numéros
/// d'ordre des exercices qui les citent (\makecomptexts : « Ex.1, Ex.3 »). À appeler dans un `context`.
#let bf-competences-document() = {
  let vus = ()
  let res = ()
  for (i, m) in query(<bf-exo-comp>).enumerate() {
    let cle = repr(m.value)
    let k = vus.position(x => x == cle)
    if k == none {
      vus.push(cle)
      res.push((valeur: m.value, exercices: (i + 1,), location: m.location()))
    } else {
      res.at(k).exercices.push(i + 1)
    }
  }
  res
}

/// \printcompindex : tableau « Compétences évaluées » dont les lignes sont les compétences des
/// exercices du document (titres des EXO, étiquettes des EXOEVAL, \ncomp), sans doublon.
/// `taille` : taille LaTeX des intitulés (\printlittlecompindex : "scriptsize").
#let printcompindex(taille: none) = context {
  let lignes = bf-competences-document().map(d => {
    let v = if type(d.valeur) == str { [#d.valeur] } else { d.valeur }
    competence(if taille == none { v } else { text(size: taille-latex(taille), v) })
  })
  tableaucompetenceeval(..lignes)
}

/// \rdexoinclude[options]{fichier} (rdexo.sty l. 1147-1160) : en Typst, le fichier est lu par
/// l'appelant (`include "f.typ"`), car un paquet ne peut pas lire les fichiers du document. Sans
/// étoile : un exercice (le même moteur qu'`exo`) qui contient le fichier ; avec `etoile: true` : le fichier
/// contient déjà ses exercices, qui reçoivent les options (file@options).
#let bf-rdexoinclude(contenu, etoile: false, ..cles) = {
  if etoile {
    bf-maj(bf-exo-options-fichier-p, cles.named())
    contenu
    bf-maj(bf-exo-options-fichier-p, (:))
  } else {
    for k in ("exocorrection", "tcblower") {
      if k in cles.named() {
        panic("rdexoinclude : la clé « " + k + " » n'existe plus. Écrire la partie à la suite de l'énoncé, après le marqueur #" + k + ".")
      }
    }
    let (enonce, basse, correction) = bf-couper-exo("rdexoinclude", contenu)
    bf-exercice(nature: "EXO", enonce, tcblower: basse, exocorrection: correction, cles: cles.named())
  }
}
