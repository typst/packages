// environnements.typ (farfadet-socle) — la double syntaxe « commande / environnement ».
//
//   Syntaxe commande       : #tcbenumerate(columns: 2)[ … ]
//   Syntaxe environnement  : #begin(tcbenumerate, columns: 2) … #end(tcbenumerate)
//
// Typst ne permet pas à une fonction de capturer ce qui la suit. `begin` et `end` posent donc des
// marqueurs (`metadata`), et la passe `environnements` regroupe le contenu compris entre deux marqueurs,
// puis appelle `f(..options, corps)`. La passe s'applique de deux façons :
//   - `#show: environnements` (le modèle de bfcours le fait pour tout le document) ;
//   - `environnements(corps)` au début d'une fonction commande qui veut accepter begin/end dans son corps.
//
// Le découpage d'un corps en items (`decouper-items`) sert aux fonctions à items : tcbenumerate, enumerate,
// itemize, MultiColonnes, tcbraster.
//
// Noms exportés : begin, end, environnements, garde-marqueur, decouper-items, item-corps, item-options.
// Les noms qui commencent par « _ » sont privés.
//
// Contraintes de Typst prises en compte :
//   - les marqueurs portent la fonction elle-même ; la comparaison `==` entre fonctions est fiable ;
//   - les parcours sont ITÉRATIFS (pile explicite) : la récursion plante vers 25 `#set` imbriqués ;
//   - un contenu à un seul élément n'a pas de `.children` : on teste toujours `func()` d'abord.

// ---------------------------------------------------------------------
//  Types d'éléments internes, non nommables dans le langage : on les
//  récupère à partir de contenus d'exemple.
// ---------------------------------------------------------------------
#let _sequence = [a#h(1pt)b].func()
#let _styled = [#set text(red)
  x].func()
#let _space = [#h(1pt) #h(1pt)].children.at(1).func()

// Éléments « transparents » : on descend dans leur `body` quand un marqueur s'y trouve
// (par exemple un `#begin` écrit dans le corps indenté d'un item `+`).
#let _transparents = (enum.item, list.item, strong, emph)

// ---------------------------------------------------------------------
//  Marqueurs
// ---------------------------------------------------------------------

/// Garde : contenu étiqueté `<bf-garde>` qui plante À LA MISE EN PAGE. La passe supprime la garde de chaque
/// marqueur qu'elle consomme ; une garde qui survit signale un marqueur non traité.
#let garde-marqueur(msg) = [#context panic(msg)<bf-garde>]

#let _msg-garde = (
  "begin/end non traité : la passe n'a pas vu ce marqueur. "
    + "Vérifier `#show: environnements` en tête de document (ou `#show: modele(…)`), et que begin/end "
    + "ne sont pas enfermés dans un élément opaque (cellule de tableau, figure, "
    + "formule, bloc, box…) ; sinon appeler environnements(corps) dans cet élément."
)

/// Ouvre un environnement : `#begin(f, ..options)` ; ferme-le par `#end(f)`.
/// `f` est la fonction elle-même (`tcbenumerate`, `exo`…), pas son nom.
///
/// - f (function): la fonction de l'environnement.
/// - options (arguments): options et blocs fixes (un titre, par exemple) passés à `f` avant le corps.
/// -> content
#let begin(f, ..args) = {
  garde-marqueur(_msg-garde)
  metadata((bf-env: "begin", f: f, args: args))
}

/// Ferme l'environnement ouvert par `#begin(f, …)`. Une étiquette peut suivre : `#end(f) <ex1>`.
///
/// - f (function): la même fonction que celle de `begin`.
/// -> content
#let end(f) = {
  garde-marqueur(_msg-garde)
  metadata((bf-env: "end", f: f))
}

// ---------------------------------------------------------------------
//  Outils de lecture du contenu
// ---------------------------------------------------------------------

#let _est-garde(c) = c.at("label", default: none) == <bf-garde>

// Texte brut d'un contenu (pour les messages d'erreur).
#let _texte(c) = {
  let f = c.func()
  if f == text { c.text }
  else if f == _space { " " }
  else if f == _sequence { c.children.map(_texte).join() }
  else { "" }
}

// Contenu « blanc » : espaces, sauts de paragraphe, gardes, vide.
#let _blanc(c) = {
  let f = c.func()
  if f == _sequence { c.children.all(_blanc) }
  else if f == parbreak or f == _space { true }
  else if f == text { c.text.trim() == "" }
  else { _est-garde(c) }
}

#let _rogner(toks) = {
  // Indices, puis une seule copie (l'ancienne version recopiait le tableau à chaque jeton retiré).
  let n = toks.len()
  let a = 0
  while a < n and _blanc(toks.at(a)) { a += 1 }
  let b = n
  while b > a and _blanc(toks.at(b - 1)) { b -= 1 }
  if a == 0 and b == n { toks } else { toks.slice(a, b) }
}

// Seuls ces éléments peuvent être des marqueurs (`_est-env`, `_est-item`) : on n'appelle `est` que pour eux.
#let _marquables = (metadata, enum.item, list.item)

// `join` aplatit une séquence étiquetée (`#[…] <x>`) et perd son étiquette : on construit alors la séquence directement.
#let _assembler(toks) = if toks.len() == 0 { [] } else if toks.len() > 1 and toks.any(x => x.func() == _sequence and x.has("label")) {
  _sequence(toks)
} else { toks.join() }

// Marqueur d'environnement : renvoie "begin" / "end" / none.
#let _est-env(c) = {
  if c.func() == metadata {
    let v = c.value
    if type(v) == dictionary { return v.at("bf-env", default: none) }
  }
  none
}

// Item de liste : "+" (enum.item), "-" (list.item), "tcb" (marqueur tcbitem) ou none.
#let _est-item(c) = {
  let f = c.func()
  if f == enum.item { "+" }
  else if f == list.item { "-" }
  else if f == metadata {
    let v = c.value
    if type(v) == dictionary and "bf-tcbitem" in v { "tcb" } else { none }
  } else { none }
}

// Le contenu contient-il un marqueur (selon `est`) ? On ne traverse que les séquences, les `styled` et
// (si `desc`) les éléments transparents. ITÉRATIF.
#let _contient(c, est, desc) = {
  let pile = (c,)
  while pile.len() > 0 {
    let x = pile.pop()
    let f = x.func()
    if f == _sequence { for y in x.children { pile.push(y) } }
    else if f == _styled { pile.push(x.child) }
    else if f in _marquables and est(x) != none { return true }
    else if desc and f in _transparents and x.has("body") { pile.push(x.body) }
  }
  false
}

// Reconstruit un élément transparent avec un nouveau corps (et son étiquette éventuelle).
#let _reconstruire(c, corps) = {
  let f = c.func()
  let neuf = if f == enum.item {
    enum.item(c.at("number", default: auto), corps)
  } else { f(corps) }
  let e = c.at("label", default: none)
  if e == none { neuf } else { [#neuf#label(str(e))] }
}

// Aplatit un contenu en « événements » :
//   (t: "tok",   c: contenu)           feuille
//   (t: "open",  s: styles)            début d'un styled contenant un marqueur
//   (t: "close",)                      fin de ce styled
//   (t: "begin"/"end"/"+"/"-"/"tcb", c: …)  marqueur
// Les `styled` SANS marqueur restent des feuilles (rapide et sûr). `rec` : la passe elle-même, pour
// descendre dans les éléments transparents. ITÉRATIF. Les dictionnaires empilés sont des sentinelles :
// (close: true) ferme un styled ; (etiq: lab) reporte l'étiquette d'une séquence sur le dernier événement
// (`#end(f) <x>` : le résultat de l'appel est une séquence étiquetée).
#let _flux(c, est, desc, rec) = {
  let evs = ()
  let pile = (c,)
  while pile.len() > 0 {
    let x = pile.pop()
    if type(x) == dictionary {
      if "close" in x { evs.push((t: "close")) }
      else if evs.len() > 0 { evs.at(-1).etiq = x.etiq }
      continue
    }
    let f = x.func()
    if f == _sequence {
      let lab = x.at("label", default: none)
      if lab != none and not _contient(x, est, desc) {
        evs.push((t: "tok", c: x))
      } else {
        if lab != none { pile.push((etiq: lab)) }
        for y in x.children.rev() { pile.push(y) }
      }
    } else if f == _styled and _contient(x.child, est, desc) {
      evs.push((t: "open", s: x.styles))
      pile.push((close: true))
      pile.push(x.child)
    } else if _est-garde(x) {
      continue
    } else if f in _marquables and est(x) != none {
      evs.push((t: est(x), c: x))
    } else if (desc and f in _transparents and x.has("body")
        and _contient(x.body, est, desc)) {
      evs.push((t: "tok", c: _reconstruire(x, rec(x.body))))
    } else {
      evs.push((t: "tok", c: x))
    }
  }
  evs
}

// ---------------------------------------------------------------------
//  La passe
//
//  Pile de cadres : (k: "racine"|"env"|"style", c: contenus accumulés, …)
//  - un `#set` placé AVANT begin et fermé après end : le cadre « style » englobe tout ;
//  - un `#set` placé ENTRE begin et end : le styled enveloppe aussi le #end (et le reste du document) ;
//    au `end` on referme le style dans le corps de l'environnement et on ne le rouvre pas : le `set`
//    ne s'applique qu'à l'environnement. Le `close` ultérieur est ignoré ;
//  - un `#[ #set … #begin(f) ]` : le styled se ferme avant le end ; on applique alors le style à ce qui a
//    déjà été accumulé dans l'environnement.
// ---------------------------------------------------------------------

/// Passe de regroupement des environnements `begin … end`. À utiliser en tête de document
/// (`#show: environnements`, déjà fait par `#show: modele(…)`) ou sur un corps : `environnements(corps)`.
/// Un `begin` sans `end` (ou l'inverse), ou mal imbriqué, arrête la compilation avec un message qui indique
/// où chercher.
///
/// - doc (content): le contenu à traiter ; une autre valeur (chaîne, nombre, none…) est rendue telle quelle.
/// -> content
#let environnements(doc) = {
  if type(doc) != content { return doc }
  if not _contient(doc, _est-env, true) { return doc }
  let ev = _flux(doc, _est-env, true, environnements)
  let pile = ((k: "racine", c: ()),)
  let nb = 0 // nombre de begin rencontrés (pour les messages)
  let nstyle = 0 // identifiant des styled ouverts
  let ouverts = () // pile des identifiants de styled dont le close est attendu
  let dernier = "" // dernier texte vu (repère dans les messages)
  let repere(s) = {
    let cl = s.trim().clusters()
    if cl.len() == 0 { "(début de zone)" } else {
      ("« " + (if cl.len() > 40 { "…" } else { "" })
        + cl.slice(calc.max(0, cl.len() - 40)).join() + " »")
    }
  }
  for e in ev {
    if e.t == "tok" {
      pile.at(-1).c.push(e.c)
      if e.c.func() == text { dernier = e.c.text }
    } else if e.t == "open" {
      nstyle += 1
      ouverts.push(nstyle)
      pile.push((k: "style", id: nstyle, s: e.s, c: ()))
    } else if e.t == "close" {
      // Ferme le style correspondant. Si un `end` l'a déjà refermé (set placé dans l'environnement), il
      // n'est plus dans la pile : rien à faire. Les cadres au-dessus sont des environnements ouverts à
      // l'intérieur du styled (begin dans `#[ #set … ]`) : on leur applique le style.
      let id = ouverts.pop()
      let i = pile.position(x => x.k == "style" and x.id == id)
      if i != none {
        for j in range(i + 1, pile.len()) {
          pile.at(j).c = (_styled(_assembler(pile.at(j).c), pile.at(i).s),)
        }
        let st = pile.remove(i)
        pile.at(i - 1).c.push(_styled(_assembler(st.c), st.s))
      }
    } else if e.t == "begin" {
      nb += 1
      let v = e.c.value
      pile.push((
        k: "env", f: v.f, args: v.args, c: (), n: nb,
        etiq: e.at("etiq", default: e.c.at("label", default: none)),
        apres: repere(dernier),
      ))
    } else if e.t == "end" {
      let v = e.c.value
      let i = pile.len() - 1
      while i > 0 and pile.at(i).k != "env" { i -= 1 }
      if i == 0 {
        panic("end(" + repr(v.f) + ") sans begin correspondant (après "
          + repere(dernier) + ").")
      }
      if pile.at(i).f != v.f {
        panic("end(" + repr(v.f) + ") ne correspond pas à l'environnement "
          + "ouvert begin(" + repr(pile.at(i).f) + ") n°" + str(pile.at(i).n)
          + " (ouvert après " + pile.at(i).apres + ") : begin/end mal "
          + "imbriqués ou end oublié.")
      }
      // Styles ouverts DANS l'environnement : on les ferme dans le corps et on NE les rouvre PAS.
      while pile.len() - 1 > i {
        let st = pile.pop()
        pile.at(-1).c.push(_styled(_assembler(st.c), st.s))
      }
      let env = pile.pop()
      let corps = _assembler(_rogner(env.c))
      let res = (env.f)(..env.args, corps)
      let etiq = e.at("etiq", default: e.c.at("label", default: env.etiq))
      if etiq != none { res = [#res#label(str(etiq))] }
      pile.at(-1).c.push(res)
    }
  }
  if pile.len() > 1 {
    let env = pile.filter(x => x.k == "env").last()
    panic("begin(" + repr(env.f) + ") n°" + str(env.n) + " (ouvert après "
      + env.apres + ") n'est jamais fermé : end(" + repr(env.f) + ") manquant.")
  }
  _assembler(pile.at(0).c)
}

// ---------------------------------------------------------------------
//  Découpage d'un corps en items
// ---------------------------------------------------------------------

/// Contenu d'un item rendu par `decouper-items` (un item ordinaire est déjà un contenu).
#let item-corps(i) = if type(i) == dictionary { i.corps } else { i }

/// Options d'un item rendu par `decouper-items` : celles d'un `tcbitem`, ou `(number: n)` pour un item
/// `+` à numéro explicite ; `(:)` pour un item ordinaire.
#let item-options(i) = if type(i) == dictionary { i.options } else { (:) }

/// Découpe un corps en items et renvoie un tableau dont chaque élément est :
///   - un CONTENU, pour un item `+` ou `-` ordinaire ;
///   - un dictionnaire `(corps: contenu, options: (…))`, pour un `tcbitem` ou un item `+` à numéro
///     explicite (`options: (number: 5)`).
/// Tout ce qui suit un item (texte, autres éléments, environnements déjà résolus) est rattaché à cet item.
/// Du blanc avant le premier item est ignoré ; tout autre contenu est une erreur. Un `#set` écrit entre
/// deux items s'applique aux items qui suivent. Mélanger `+` et `-` est une erreur.
///
/// Les marqueurs de `tcbitem` sont reconnus par leur valeur `(bf-tcbitem: true, options, corps)`.
///
/// - corps (content): le corps, déjà passé par `environnements`.
/// - puce (str, auto): `"+"` ou `"-"` pour imposer le genre d'items ; `auto` : celui du premier item.
/// -> array
#let decouper-items(corps, puce: auto) = {
  let ev = _flux(corps, _est-item, false, none)
  let items = () // chacun : (corps: (morceaux), options: (..))
  let genre = puce
  let styles = () // pile des styles actifs (un `#set` au milieu des items)
  // Une fonction de Typst capture ses variables À SA CRÉATION : `styles` doit donc être passé en argument,
  // sinon `habiller` ne verrait jamais les styles empilés ensuite.
  let habiller(c, styles) = styles.rev().fold(c, (acc, s) => _styled(acc, s))
  for e in ev {
    if e.t == "open" { styles.push(e.s) }
    else if e.t == "close" { let _ = styles.pop() } // `pop` renvoie une valeur : ne pas la laisser dans le résultat
    else if e.t == "tok" {
      if items.len() == 0 {
        if not _blanc(e.c) {
          panic("contenu avant le premier item : « " + _texte(e.c).trim()
            + " » (élément " + repr(e.c.func()) + "). Un corps à items doit "
            + "commencer par un item (+, - ou #tcbitem).")
        }
      } else { items.at(-1).corps.push(habiller(e.c, styles)) }
    } else {
      // item : e.t vaut "+", "-" ou "tcb"
      if e.t != "tcb" {
        if genre == auto { genre = e.t }
        else if genre != e.t {
          panic("mélange d'items « + » et « - » dans un même corps (attendu « "
            + genre + " », trouvé « " + e.t + " » avant « "
            + _texte(e.c.body).trim() + " »). Indenter la sous-liste ou "
            + "utiliser #tcbitem.")
        }
      }
      if e.t == "tcb" {
        items.push((
          corps: (habiller(e.c.value.corps, styles),),
          options: e.c.value.options,
        ))
      } else {
        let opts = (:)
        if e.t == "+" and e.c.at("number", default: auto) != auto {
          opts.number = e.c.number
        }
        items.push((corps: (habiller(e.c.body, styles),), options: opts))
      }
    }
  }
  items.map(i => {
    let c = _assembler(_rogner(i.corps))
    if i.options.len() == 0 { c } else { (corps: c, options: i.options) }
  })
}
