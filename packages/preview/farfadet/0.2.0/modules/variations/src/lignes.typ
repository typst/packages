// lignes.typ (farfadet-tabvar) — les lignes d'un tableau : `tkz-tab-line` (signes) et `tkz-tab-var` (variations).
//
// Ces fonctions ne dessinent rien : elles valident leurs arguments et rendent une description de ligne
// (un dictionnaire marqué `bf-tabvar-ligne`) que `tabvar` met en page.

/// Une chaîne est une formule : « -oo » donne −∞. Un contenu passe tel quel. `none` et « » donnent `none`.
#let _contenu(v) = if type(v) == str {
  if v.trim() == "" { none } else { eval(v, mode: "math") }
} else { v }

#let _verifier-h(commande, h) = {
  if type(h) not in (int, float) or h <= 0 {
    panic(commande + " : la clé « h » (hauteur relative) attend un nombre strictement positif ; reçu : " + repr(h) + ".")
  }
}

/// `a-completer` d'une ligne : auto, un booléen, "valeurs", "fleches", une liste de numéros, ou
/// un dictionnaire (valeurs: …, fleches: …).
#let _verifier-ac(commande, ac) = {
  let ok = (
    ac == auto
      or type(ac) == bool
      or ac in ("valeurs", "fleches")
      or (type(ac) == array and ac.all(i => type(i) == int))
      or (type(ac) == dictionary and ac.keys().all(k => k in ("valeurs", "fleches")))
  )
  if not ok {
    panic(
      commande
        + " : la clé « a-completer » attend auto, true, false, \"valeurs\", \"fleches\", une liste de numéros"
        + " ou un dictionnaire (valeurs: …, fleches: …) ; reçu : " + repr(ac) + ".",
    )
  }
}

/// Ce qui est vidé pour l'élève : `(val: …, fl: …)`, chacun true, false ou une liste de numéros.
/// `ac-tab` : réglage du tableau (true, false ou liste de numéros de lignes) ; `num` : numéro de la ligne.
#let _ac-resolu(ac, ac-tab, num) = {
  let du-tableau = ac-tab == true or (type(ac-tab) == array and num in ac-tab)
  if ac == auto { (val: du-tableau, fl: du-tableau) }
  else if type(ac) == bool { (val: ac, fl: ac) }
  else if ac == "valeurs" { (val: true, fl: false) }
  else if ac == "fleches" { (val: false, fl: true) }
  else if type(ac) == array { (val: ac, fl: false) }
  else { (val: ac.at("valeurs", default: false), fl: ac.at("fleches", default: false)) }
}

/// L'élément n° `i` est-il vidé pour l'élève ?
#let _cache(spec, i) = spec == true or (type(spec) == array and i in spec)

// ---------------------------------------------------------------------------------------------
// Lignes de signes
// ---------------------------------------------------------------------------------------------

#let _jetons-signes(spec) = {
  if type(spec) == str {
    let morceaux = if spec.contains(",") { spec.split(",") } else { spec.split(" ").filter(s => s != "") }
    morceaux.map(s => s.trim())
  } else if type(spec) == array {
    spec
  } else {
    panic("tkz-tab-line : la description des signes attend une chaîne (\",-,z,+,\") ou un tableau ; reçu : " + repr(spec) + ".")
  }
}

#let _item-signe(j) = {
  if type(j) == str {
    let s = j.trim().replace("−", "-")
    if s == "" { (genre: "vide") }
    else if s == "+" { (genre: "signe", c: $+$) }
    else if s == "-" { (genre: "signe", c: $-$) }
    else if s == "z" { (genre: "z") }
    else if s == "t" { (genre: "t") }
    else if s == "d" { (genre: "d") }
    else if s == "|" { (genre: "barre") }
    else if s == "h" { (genre: "h") }
    else { (genre: "texte", c: _contenu(s)) }
  } else if j == none {
    (genre: "vide")
  } else {
    (genre: "texte", c: j)
  }
}

/// Ligne de signes (`\tkzTabLine`). `spec` : 2·N − 1 éléments pour N valeurs de x, séparés par des
/// virgules : les valeurs de x aux rangs impairs, les intervalles aux rangs pairs.
/// Éléments : « » (vide), `+`, `-`, `z` (zéro), `t` (trait pointillé), `d` (double barre),
/// `|` (trait plein), `h` (hachures, intervalle seulement), ou une formule.
#let tkz-tab-line(nom, spec, h: 1, a-completer: auto) = {
  _verifier-h("tkzTabLine", h)
  _verifier-ac("tkzTabLine", a-completer)
  (
    bf-tabvar-ligne: true,
    genre: "signes",
    nom: _contenu(nom),
    h: h,
    items: _jetons-signes(spec).map(_item-signe),
    a-completer: a-completer,
  )
}

// ---------------------------------------------------------------------------------------------
// Lignes de variations
// ---------------------------------------------------------------------------------------------

#let _reperes-var = ("R", "im", "D", "+", "-", "+D", "-D", "D+", "D-", "+D+", "+D-", "-D+", "-D-")

#let _item-var(it, i) = {
  let brut = if type(it) == array and it.len() > 0 { it } else if type(it) == str { (it,) } else {
    panic(
      "tkzTabVar : l'élément n° " + str(i) + " attend un repère (\"+\", \"-\", \"R\"…) ou un tableau (repère, valeur…) ; reçu : "
        + repr(it) + ".",
    )
  }
  let (repere, ..vals) = brut
  if type(repere) != str {
    panic("tkz-tab-var : le repère de l'élément n° " + str(i) + " doit être une chaîne ; reçu : " + repr(repere) + ".")
  }
  let repere = repere.trim().replace("−", "-")
  if repere not in _reperes-var {
    panic(
      "tkzTabVar : repère « " + repere + " » inconnu à l'élément n° " + str(i) + ". Repères possibles : "
        + _reperes-var.map(k => "« " + k + " »").join(", ") + ".",
    )
  }
  let vals = vals.map(_contenu)
  let niveau(s) = if s == "+" { "h" } else { "b" }
  let erreur-nb(attendu) = panic(
    "tkzTabVar : le repère « " + repere + " » (élément n° " + str(i) + ") accepte " + attendu + " ; reçu : "
      + str(vals.len()) + ".",
  )

  if repere == "R" {
    if vals.len() > 0 { erreur-nb("aucune valeur") }
    (repere: repere, pts: (), ent: none, sor: none, barre: false, im: none, passe: true)
  } else if repere == "im" {
    if vals.len() != 1 { erreur-nb("exactement une valeur (l'image)") }
    (repere: repere, pts: (), ent: none, sor: none, barre: false, im: vals.at(0), passe: true)
  } else if repere == "D" {
    if vals.len() > 0 { erreur-nb("aucune valeur") }
    (repere: repere, pts: (), ent: none, sor: none, barre: true, im: none, passe: false)
  } else if not repere.contains("D") {
    if vals.len() > 1 { erreur-nb("au plus une valeur") }
    let p = (niveau: niveau(repere), val: vals.at(0, default: none), cote: "c")
    (repere: repere, pts: (p,), ent: 0, sor: 0, barre: false, im: none, passe: false)
  } else {
    let (gauche, droite) = repere.split("D")
    let pts = ()
    let k = 0
    let ent = none
    let sor = none
    if gauche != "" {
      pts.push((niveau: niveau(gauche), val: vals.at(k, default: none), cote: "g"))
      ent = pts.len() - 1
      k += 1
    }
    if droite != "" {
      pts.push((niveau: niveau(droite), val: vals.at(k, default: none), cote: "d"))
      sor = pts.len() - 1
      k += 1
    }
    if vals.len() > pts.len() { erreur-nb(str(pts.len()) + " valeur(s) au plus") }
    (repere: repere, pts: pts, ent: ent, sor: sor, barre: true, im: none, passe: false)
  }
}

/// Ligne de variations (`\tkzTabVar`). Un élément par valeur de x :
/// - `"R"` : rien (la flèche passe) ; `"+"`, `"-"` : un point haut ou bas sans valeur ;
/// - `("+", val)`, `("-", val)` : une valeur en haut ou en bas ;
/// - `("+D-", gauche, droite)`, `("-D+", …)`, `("D-", droite)`, `("+D", gauche)`… : valeur interdite,
///   double barre, limites de part et d'autre ;
/// - `("im", val)` : image intermédiaire posée sur la flèche, à l'abscisse de cette colonne.
#let tkz-tab-var(nom, ..items, h: 2, a-completer: auto) = {
  _verifier-h("tkzTabVar", h)
  _verifier-ac("tkzTabVar", a-completer)
  if items.named().len() > 0 {
    panic(
      "tkzTabVar : clé inconnue « " + items.named().keys().first() + " ». Clés possibles : « h », « a-completer ».",
    )
  }
  (
    bf-tabvar-ligne: true,
    genre: "variations",
    nom: _contenu(nom),
    h: h,
    items: items.pos().enumerate().map(((i, it)) => _item-var(it, i + 1)),
    a-completer: a-completer,
  )
}
