// mcq.typ (farfadet-qcm, moteur) — portage de rdmcq.sty (Régis Deleuze) : environnement Mcq, questions
// McqQuest, réglage global \setrdmcq.
//
// Architecture (rdmcq.sty, « Les différentes zones d'un questionnaire ») :
// - une boîte englobante (clé boxstyle) contient des RANGÉES séparées de `row sep` ;
// - une rangée de question = zone externe de la question (largeur `question width`) + zone externe des
//   réponses (le reste), côte à côte et de même hauteur ; avec `same width`, la zone des réponses glisse
//   sous celle de la question (écart `question answer sep`) ;
// - les réponses forment une grille (raster) : une ligne en orientation horizontale, une colonne (ou
//   `answer columns` colonnes) en orientation verticale ;
// - `column sep = 0pt` (défaut) fait chevaucher les cadres voisins d'une épaisseur `boxrule`, et
//   `row sep = 0pt` aussi : les cadres se collent sans doubler le trait (comme en LaTeX).
//
// Les styles s'empilent dans l'ordre documenté par rdmcq (p. 24-27 de la doc) : style initial, format,
// clés question/answer colback|colframe|opacityback, every …, every odd/even …, clés locales.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-afficher-points-p,
  bf-lire,
  est-correction, reglages-paquet, reglages-regler, reglages-resoudre, reglages-controles, reglages-choix,
  reglages-ou, reglages-verifier, reglages-liste, ptl, bf-points, bf-afficher-points, bf-boite-points-en-ligne,
)
#import "boite.typ": mcq-boite, mcq-fusionner, mcq-evaluer, mcq-marges, mcq-regles, mcq-verifier-style, mcq-tcb-controles
#import "cases.typ": bf-mcq-br
#import "formats.typ": rdmcqCounterFormat, bf-mcq-formats, mcq-formats-globaux

// ---------------------------------------------------------------------
// Compteurs et états
// ---------------------------------------------------------------------

/// Numéro de la question courante (\rdmcqQuestioncount).
#let bf-mcq-question = counter("bf-mcq-question")
/// Numéro de la réponse courante (\rdmcqAnswercount).
#let bf-mcq-reponse = state("bf-mcq-reponse", 0)
/// Réglages effectifs du Mcq en cours (none hors d'un Mcq).
#let bf-mcq-courant = state("bf-mcq-courant", none)

// ---------------------------------------------------------------------
// Registre de \setrdmcq (clés /rdmcq/)
// ---------------------------------------------------------------------

#let _c = reglages-controles
#let _style = (v => type(v) == dictionary, "un style tcb : dictionnaire de clés tcolorbox, par exemple (colback: yellow)")
#let _coul-none = reglages-ou(_c.couleur, _c.texte, (v => v == none, "none"))
#let _opac-none = (v => v == none or (type(v) in (int, float) and v >= 0 and v <= 1), "none ou un nombre entre 0 et 1")
#let _long-auto = reglages-ou(_c.longueur, (v => v == auto, "auto"))
#let _nom-format = (v => type(v) == str, "un nom de format (\"default\", \"Boston\"…)")

/// Défauts des clés /rdmcq/ : style `reset` de rdmcq.sty, l. 223-259.
#let mcq-defauts = (
  orientation: "horizontal",
  resume: false,
  num-start: 1,
  width: auto,
  question-width: 8.5cm,
  same-width: false,
  boxrule: 0.6pt,
  column-sep: 0pt,
  row-sep: 0pt,
  question-answer-sep: auto,
  answer-column-sep: auto,
  answer-row-sep: 0pt,
  answer-columns: 0,
  question-format: "default",
  answer-format: "default",
  boxstyle: (:),
  correction: auto,
  question-colback: none,
  question-colframe: none,
  question-opacityback: none,
  answer-colback: none,
  answer-colframe: none,
  answer-opacityback: none,
  every-question-zone: (:),
  every-question: (:),
  every-answer-zone: (:),
  every-answer: (:),
  every-odd-question-zone: (:),
  every-even-question-zone: (:),
  every-odd-answer-zone: (:),
  every-even-answer-zone: (:),
  every-odd-answer: (:),
  every-even-answer: (:),
  answer: (:),
  counter-format: rdmcqCounterFormat,
  // raccourcis (styles pgf de rdmcq) : développés avant d'être enregistrés, jamais stockés
  format: none,
  colback: none,
  colframe: none,
  opacityback: none,
  every-odd-row: none,
  every-even-row: none,
)

#let _controles-mcq = (
  orientation: reglages-choix("horizontal", "vertical"),
  resume: _c.booleen,
  num-start: _c.entier,
  width: _long-auto,
  question-width: _c.longueur,
  same-width: _c.booleen,
  boxrule: _c.longueur,
  column-sep: _c.longueur,
  row-sep: _c.longueur,
  question-answer-sep: reglages-ou(_long-auto, (v => type(v) == function, "une fonction m => longueur (m.boxrule, m.rowsep)")),
  answer-column-sep: _long-auto,
  answer-row-sep: _c.longueur,
  answer-columns: (v => type(v) == int and v >= 0, "un entier positif ou nul (0 : automatique)"),
  question-format: _nom-format,
  answer-format: _nom-format,
  boxstyle: _style,
  correction: reglages-ou(_c.booleen, (v => v == auto, "auto (selon la version prof/élève)")),
  question-colback: _coul-none,
  question-colframe: _coul-none,
  question-opacityback: _opac-none,
  answer-colback: _coul-none,
  answer-colframe: _coul-none,
  answer-opacityback: _opac-none,
  every-question-zone: _style,
  every-question: _style,
  every-answer-zone: _style,
  every-answer: _style,
  every-odd-question-zone: _style,
  every-even-question-zone: _style,
  every-odd-answer-zone: _style,
  every-even-answer-zone: _style,
  every-odd-answer: _style,
  every-even-answer: _style,
  answer: (v => type(v) == dictionary and v.values().all(x => type(x) == dictionary), "un dictionnaire (\"n\": style tcb), par exemple (\"3\": (colback: gray))"),
  counter-format: (v => type(v) == function, "une fonction n => contenu"),
  format: (v => v == none or type(v) == str, "none ou un nom de format"),
  colback: _coul-none,
  colframe: _coul-none,
  opacityback: _opac-none,
  every-odd-row: reglages-ou(_style, (v => v == none, "none")),
  every-even-row: reglages-ou(_style, (v => v == none, "none")),
)

/// Registre de \setrdmcq. Les formats globaux (Boston, Paris…) sont des styles nommés prédéfinis :
/// `mcq(style: "Boston")` est l'équivalent de `\begin{Mcq}[Boston]`.
#let registre-mcq = {
  reglages-paquet("mcq", mcq-defauts, controles: _controles-mcq, commande: "setrdmcq", styles: mcq-formats-globaux)
}

/// Développe les raccourcis (styles pgf de rdmcq) : `format`, `colback`, `colframe`, `opacityback`,
/// `every-odd-row`, `every-even-row`. Une clé explicite du même appel l'emporte.
#let mcq-raccourcis(d) = {
  let r = d
  let f = r.remove("format", default: none)
  if f != none {
    for p in ("question", "answer") {
      if p + "-format" not in d { r.insert(p + "-format", f) }
    }
  }
  for cle in ("colback", "colframe", "opacityback") {
    let v = r.remove(cle, default: none)
    if v != none {
      for p in ("question", "answer") {
        if p + "-" + cle not in d { r.insert(p + "-" + cle, v) }
      }
    }
  }
  for parite in ("odd", "even") {
    let v = r.remove("every-" + parite + "-row", default: none)
    if v != none {
      for z in ("question-zone", "answer-zone", "answer") {
        let k = "every-" + parite + "-" + z
        if k not in d { r.insert(k, v) }
      }
    }
  }
  r
}

/// Vérifie les styles tcb contenus dans des clés /rdmcq/ (every…, boxstyle, answer).
#let _verifier-styles(commande, d) = {
  for (cle, v) in d {
    if type(v) == dictionary and (cle.starts-with("every-") or cle == "boxstyle") {
      mcq-verifier-style(commande + " (" + cle + ")", v)
    }
    if cle == "answer" and type(v) == dictionary {
      for (n, s) in v { mcq-verifier-style(commande + " (answer \"" + n + "\")", s) }
    }
  }
}

// ---------------------------------------------------------------------
// Géométrie d'une rangée
// ---------------------------------------------------------------------

/// Dimensions calculées à l'entrée de Mcq (rdmcq.sty, l. 1337-1380) pour une largeur disponible W.
#let mcq-geometrie(g, W) = {
  let qw = if g.same-width { W } else { calc.min(g.question-width.to-absolute(), W) }
  let multi = qw < W
  let B = g.boxrule.to-absolute()
  let cs = g.column-sep.to-absolute()
  let grow = if cs == 0pt and multi { B } else { 0pt }
  let x2 = if multi { qw + cs - grow } else { 0pt }
  let rw = if multi { W - x2 } else { W }
  let rs = if g.row-sep.to-absolute() == 0pt { -B } else { g.row-sep.to-absolute() }
  let acs = if g.answer-column-sep == auto { cs } else { g.answer-column-sep.to-absolute() }
  let acs = if acs > 0pt { acs } else { -B }
  (W: W, qw: qw, multi: multi, x2: x2, rw: rw, rowsep: rs, acs: acs, boxrule: B)
}

/// Écart effectif entre rangées : `row sep`, ou −boxrule si `row sep = 0pt` (cadres chevauchés).
#let _rs(g) = if g.row-sep.to-absolute() == 0pt { -g.boxrule.to-absolute() } else { g.row-sep.to-absolute() }

/// Informations transmises aux valeurs-fonctions des styles.
#let _infos(g, geo) = (
  question: none,
  answer: none,
  br: false,
  correction: g.correction,
  boxrule: geo.boxrule,
  rowsep: geo.rowsep,
  orientation: g.orientation,
  counter-format: g.counter-format,
)

/// Style des clés utilisateur `<prefixe>-colback`, `-colframe`, `-opacityback`.
#let _style-utilisateur(g, prefixe) = {
  let d = (:)
  for k in ("colback", "colframe", "opacityback") {
    let v = g.at(prefixe + "-" + k)
    if v != none { d.insert(k, v) }
  }
  d
}

/// Style initial de la zone externe des questions (zonequestion@defaultstyle).
#let _zone-base(geo) = (
  colback: "black!5!white",
  colframe: "black!75!white",
  boxrule: geo.boxrule,
  arc: 0pt,
)

/// Grille de boîtes de même largeur (raster) : `cellules` = tableau de (style, contenu, m).
/// `colonnes`, écart horizontal `ecart-x` (négatif = chevauchement), écart vertical `ecart-y`.
/// `egal` : "rows" (hauteur égale par ligne) ou "all" ; `hauteur-min` : hauteur minimale des cellules.
#let mcq-grille(cellules, largeur, colonnes, ecart-x, ecart-y, egal: "rows", hauteur-min: 0pt) = {
  let n = cellules.len()
  if n == 0 { return none }
  let cw = (largeur - (colonnes - 1) * ecart-x) / colonnes
  let hauteurs = cellules.map(((s, c, m)) => measure(mcq-boite(s, c, largeur: cw, m: m), width: cw).height)
  let lignes = calc.ceil(n / colonnes)
  let hl = range(lignes).map(i => calc.max(hauteur-min, ..hauteurs.slice(i * colonnes, calc.min(n, (i + 1) * colonnes))))
  if egal == "all" { hl = hl.map(_ => calc.max(..hl)) }
  // écart vertical nul : les cadres se collent (chevauchement d'une épaisseur de filet haut)
  let total = hl.sum() + (lignes - 1) * ecart-y
  block(width: largeur, height: total, above: 0pt, below: 0pt, breakable: false, {
    let y = 0pt
    for i in range(lignes) {
      for j in range(colonnes) {
        let k = i * colonnes + j
        if k < n {
          let (s, c, m) = cellules.at(k)
          place(top + left, dx: j * (cw + ecart-x), dy: y, mcq-boite(s, c, largeur: cw, hauteur: hl.at(i), m: m))
        }
      }
      y += hl.at(i) + ecart-y
    }
  })
}

/// Rangée à deux zones côte à côte (mode multi) ou empilées (mode simple).
/// `gauche`, `droite` : none ou fonction (hauteur) => contenu de la largeur voulue.
/// `ecart-vertical` : écart entre les deux zones empilées (mode simple).
#let mcq-rangee(geo, gauche, droite, ecart-vertical: auto, egaliser: true) = {
  let rs = geo.rowsep
  if geo.multi {
    let hg = if gauche != none { measure(gauche(auto), width: geo.qw).height } else { 0pt }
    let hd = if droite != none { measure(droite(auto), width: geo.rw).height } else { 0pt }
    let H = calc.max(hg, hd)
    block(width: geo.W, height: H, above: rs, below: rs, breakable: false, {
      if gauche != none { place(top + left, gauche(if egaliser and hg < H { H } else { auto })) }
      if droite != none { place(top + left, dx: geo.x2, droite(if egaliser and hd < H { H } else { auto })) }
    })
  } else {
    let ev = if ecart-vertical == auto { rs } else { ecart-vertical }
    block(width: geo.W, above: rs, below: rs, breakable: false, {
      if gauche != none { gauche(auto) }
      if gauche != none and droite != none { v(ev) }
      if droite != none { droite(auto) }
    })
  }
}

/// Réglages courants du Mcq ; erreur explicite hors d'un environnement Mcq.
#let _courant(commande) = {
  let g = bf-mcq-courant.get()
  if g == none {
    panic(commande + " : à placer dans un environnement mcq, par exemple #mcq[#" + commande + "(…)].")
  }
  g
}

// ---------------------------------------------------------------------
// Mcq
// ---------------------------------------------------------------------

#let _parties = ("question", "answer")

/// Environnement Mcq (rdmcq.sty, l. 1314) : `options` = clés /rdmcq/ (dictionnaire déjà développé).
#let mcq-environnement(options, corps) = context {
  _verifier-styles("Mcq", options)
  let r = reglages-resoudre(registre-mcq, local: options, commande: "Mcq")
  let f = bf-mcq-formats.get()
  for p in _parties {
    let nom = r.at(p + "-format")
    if nom not in f.at(p) {
      panic(
        "Mcq : format de " + p + " inconnu « " + nom + " ». Formats définis : " + reglages-liste(f.at(p).keys()) + ".",
      )
    }
    if p == "answer" and r.orientation not in f.answer.at(nom) {
      panic("mcq : le format de réponses « " + nom + " » n'existe pas en orientation " + r.orientation + ".")
    }
  }
  let g = r + (correction: if r.correction == auto { est-correction() } else { r.correction })
  let bs = mcq-evaluer((before-skip: ptl(4.1), after-skip: ptl(4.1), breakable: true) + r.boxstyle, (:))
  let fond = bs.colback
  let largeur = if r.width == auto { 100% } else { r.width }
  {
    if not r.resume {
      bf-mcq-question.update(r.num-start - 1)
    }
    bf-mcq-courant.update(g)
    block(
      width: largeur,
      above: bs.before-skip,
      below: bs.after-skip,
      breakable: bs.breakable,
      fill: if fond == none { none } else { _socle.bf-resoudre-couleur(fond) },
      stroke: if bs.boxrule > 0pt and bs.colframe != none and not bs.frame-hidden { bs.boxrule + _socle.bf-resoudre-couleur(bs.colframe) },
      radius: bs.arc,
      inset: mcq-marges(bs),
      corps,
    )
    bf-mcq-courant.update(none)
  }
}

// ---------------------------------------------------------------------
// McqQuest
// ---------------------------------------------------------------------

/// Ajoute des points au barème (clé `points`, ajout).
#let _ajouter-points(n) = bf-points.update(p => p + (total: p.total + n, exo: p.exo + n))

/// Une question et ses réponses (rdmcq.sty, l. 1102). `justes` : numéros (à partir de 1) des bonnes réponses ;
/// `local` : clés tcb de la zone externe de la question ; `zone` : clé answer-zone ; `styles` : clé answer.
#let mcq-question(question, reponses, justes: (), local: (:), zone: (:), styles: none, points: none, boite: auto) = {
  if points != none { _ajouter-points(points) }
  bf-mcq-question.step()
  context {
    let g = _courant("McqQuest")
    let n = bf-mcq-question.get().first()
    let fq = bf-mcq-formats.get().question.at(g.question-format)
    let fa = bf-mcq-formats.get().answer.at(g.answer-format).at(g.orientation)
    let impair = calc.odd(n)
    let styles = if styles == none { g.answer } else { g.answer + styles }
    block(width: 100%, above: _rs(g), below: _rs(g), breakable: false, layout(t => {
      let geo = mcq-geometrie(g, t.width)
      let m = _infos(g, geo) + (question: n)
      // ----- zone de la question
      let s-zone-q = mcq-fusionner(
        _zone-base(geo),
        (opacityback: 0, colframe: black, colback: white),
        fq.zone,
        _style-utilisateur(g, "question"),
        g.every-question-zone,
        if impair { g.every-odd-question-zone } else { g.every-even-question-zone },
        local,
      )
      let s-q = mcq-fusionner(fq.box, g.every-question)
      let texte-q = {
        question
        if points != none {
          context if (if boite == auto { bf-lire(bf-afficher-points-p) } else { boite }) {
            h(1fr)
            bf-boite-points-en-ligne(points)
          }
        }
      }
      let zone-q(h) = {
        let mq = mcq-marges(mcq-evaluer(s-zone-q, m))
        mcq-boite(s-zone-q, mcq-boite(s-q, texte-q, largeur: geo.qw - mq.left - mq.right, m: m), largeur: geo.qw, hauteur: h, m: m)
      }
      // ----- zone des réponses
      let s-zone-r = mcq-fusionner(
        (valign: "top"),
        fa.zone,
        _style-utilisateur(g, "answer"),
        g.every-answer-zone,
        if impair { g.every-odd-answer-zone } else { g.every-even-answer-zone },
        zone,
      )
      let mz = mcq-marges(mcq-evaluer(s-zone-r, m))
      let largeur-interieure = geo.rw - mz.left - mz.right
      let horizontal = g.orientation == "horizontal"
      let colonnes = if horizontal { calc.max(1, reponses.len()) } else if g.answer-columns > 0 { g.answer-columns } else { 1 }
      let cellules(hmin) = reponses
        .enumerate()
        .map(((i, rep)) => {
          let k = i + 1
          let juste = g.correction and k in justes
          let mk = m + (answer: k, br: juste)
          let s = mcq-fusionner(
            fa.box,
            _style-utilisateur(g, "answer"),
            g.every-answer,
            if impair { g.every-odd-answer } else { g.every-even-answer },
            styles.at(str(k), default: (:)),
            if juste { fa.correction } else { (:) },
          )
          (s, [#bf-mcq-reponse.update(k)#bf-mcq-br.update(juste)#rep#bf-mcq-br.update(false)], mk)
        })
      let ars = if g.answer-row-sep.to-absolute() == 0pt and reponses.len() > 0 {
        // contexte d'une réponse (la 1re) : les formats qui lisent `m.answer` (lettre de Miami, Melun, Paris)
        // ne doivent pas recevoir `none`
        let s0 = mcq-evaluer(mcq-fusionner(fa.box, g.every-answer), m + (answer: 1, br: false))
        -mcq-regles(s0).top
      } else { g.answer-row-sep.to-absolute() }
      let egal = if not horizontal and g.answer-columns > 0 { "all" } else { "rows" }
      let grille(hmin) = mcq-grille(cellules(hmin), largeur-interieure, colonnes, geo.acs, ars, egal: egal, hauteur-min: hmin)
      let zone-r(h) = {
        // en horizontal, si la zone de la question est plus haute, les réponses prennent toute la hauteur
        let hmin = if horizontal and h != auto { h - mz.top - mz.bottom } else { 0pt }
        mcq-boite(s-zone-r, grille(hmin), largeur: geo.rw, hauteur: h, m: m)
      }
      let qas = if g.question-answer-sep == auto { geo.rowsep } else if type(g.question-answer-sep) == function {
        (g.question-answer-sep)(m)
      } else { g.question-answer-sep }
      mcq-rangee(geo, zone-q, zone-r, ecart-vertical: qas)
    }))
  }
}
