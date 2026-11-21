// precoce.typ (farfadet-socle) — réglages effectifs DÈS LE PREMIER TOUR de mise en page.
//
// Le problème. Les setters (`setbfenvironments`, `setrdcrep`, `setbfcolors`…) rangent leurs réglages
// dans des `state` : c'est ce qui leur donne leur portée « toute la suite du document, même écrit dans
// un bloc ». Mais Typst ne connaît la valeur d'un état qu'après un tour de mise en page : au tour 1,
// tout état vaut sa valeur initiale. Le document était donc composé une première fois avec les réglages
// par défaut, puis recomposé en entier : un tour gâché, et des positions fausses qui trompaient ce qui
// en dépend, d'où un ou deux tours de plus.
//
// La solution, sans changer l'API des setters :
//   1. Un setter pose, à côté de sa mise à jour d'état, un marqueur `metadata` étiqueté `<bfr-maj-CLE>`
//      qui porte la fonction de mise à jour (`bf-maj`).
//   2. La passe `bf-precoce` (posée par le modèle, ou `#show: bf-precoce`) parcourt le document AVANT la
//      mise en page, dans l'ordre du texte. À chaque marqueur, elle calcule la nouvelle valeur, consomme
//      le marqueur et enveloppe la suite du document d'une règle `set` qui porte la valeur (chaîne de
//      styles : connue dès le tour 1, sans introspection). Elle descend dans les séquences et les contenus
//      stylés (`#[…]`, `#include`, corps d'un `#show: f`) : un réglage écrit dans un bloc vaut bien pour
//      la suite du document, comme avec l'état.
//   3. La lecture (`bf-lire`) prend la valeur portée par la chaîne. Repli : si un marqueur de cet état a
//      échappé à la passe (setter écrit dans un élément opaque : corps d'une boîte, d'un exercice, d'une
//      cellule…), il reste dans le document ; `bf-lire` le voit (requête `<bfr-maj-CLE>`) et lit alors l'état,
//      exactement comme avant. La mise à jour d'état est toujours posée : l'état reste la référence.
//      Dans le cas courant (aucun marqueur échappé), la requête est vide à tous les tours : la lecture ne
//      dépend d'aucune introspection, et le tour 2 retrouve tout en cache.
//
// Valeurs à portée lexicale (`bf-porter`, `bf-porte`) : remplacent les états mis à jour avant un contenu
// puis rétablis après lui (largeur d'un conteneur, couleurs d'un environnement, niveau d'une liste…), qui
// avaient un tour de retard par niveau d'emboîtement. `bf-lire` les consulte en premier.
//
// Un état « précoce » se décrit par un dictionnaire `(etat: state(cle, init), cle: cle, init: init)` (les
// registres de `reglages-paquet` ont déjà cette forme) : `bf-etat(cle, init)` le fabrique.
//
// Porteur : le champ `title` de `bibliography`, réglé par `set` (un champ de contenu que rien d'autre
// n'emploie dans les documents bfcours). Une bibliographie éventuelle retrouve son titre par défaut
// (règle `show bibliography` posée par la passe).
//
// Noms exportés par interne.typ : bf-etat, bf-maj, bf-lire, bf-porter, bf-porte, bf-precoce,
// bf-precoce-chaine.

#let _sequence = [a#h(1pt)b].func()
#let _styled = [#set text(red)
  x].func()

/// Descripteur d'un état précoce : `(etat: state(cle, init), cle: cle, init: init)`.
#let bf-etat(cle, init) = (etat: state(cle, init), cle: cle, init: init)

/// Chaîne portée à cet endroit (dictionnaire clé d'état → valeur), ou `none` hors passe. Dans un `context`.
#let bf-precoce-chaine() = {
  let t = bibliography.title
  if type(t) == content and t.func() == metadata {
    let v = t.value
    if type(v) == dictionary and "bfr-precoce" in v { return v.at("bfr-precoce") }
  }
  none
}

/// Mise à jour d'un état précoce : `bf-maj(d, f)` remplace `d.etat.update(f)` (`d` : descripteur).
/// `f` : fonction (ancienne valeur → nouvelle) ou valeur.
#let bf-maj(d, f) = {
  let g = if type(f) == function { f } else { _ => f }
  [#metadata((bfr-maj: d.cle, init: d.init, f: g))#label("bfr-maj-" + d.cle)#d.etat.update(g)]
}

/// Un marqueur de cet état a-t-il échappé à la passe ? (dans un `context`). Une étiquette par état : la
/// requête ne change (et ne fait recomposer) que pour les lecteurs de cet état.
#let _echappe(cle) = query(label("bfr-maj-" + cle)).len() > 0

/// Valeur d'un état précoce à cet endroit (`d` : descripteur), dans un `context` ; remplace
/// `d.etat.get()`. Dans l'ordre : la valeur posée par le `bf-porter` englobant ; sous la passe, la valeur
/// portée par la chaîne (la valeur initiale si l'état n'a reçu aucune mise à jour), sauf si un marqueur
/// de cet état a échappé à la passe ; sinon (hors passe, ou marqueur échappé), l'état.
/// Toutes les mises à jour d'un état lu ainsi passent par `bf-maj` (une mise à jour directe
/// `etat.update(…)` serait ignorée sous la passe dès qu'un `bf-maj` vise le même état).
#let bf-lire(d) = {
  let ch = bf-precoce-chaine()
  if ch == none { return d.etat.get() }
  let p = ch.at("_portee", default: (:))
  if d.cle in p { return p.at(d.cle) }
  if _echappe(d.cle) { return d.etat.get() }
  // sous la passe, un état absent de la chaîne n'a reçu aucune mise à jour (ni vue, ni échappée)
  ch.at(d.cle, default: d.init)
}

// ---------------------------------------------------------------------
//  Valeurs à portée lexicale (remplacent les états posés puis rétablis)
// ---------------------------------------------------------------------

/// `corps` composé avec les valeurs `valeurs` (dictionnaire clé → valeur), pour `corps` seulement.
/// À la différence d'un état mis à jour avant `corps` et rétabli après, la valeur est connue dès le
/// tour 1 et ne dépend pas de la mise en page précédente. À appeler dans un `context` (ou un `layout`).
#let bf-porter(valeurs, corps) = {
  let ch = bf-precoce-chaine()
  let ch = if ch == none { (:) } else { ch }
  ch.insert("_portee", ch.at("_portee", default: (:)) + valeurs)
  set bibliography(title: metadata((bfr-precoce: ch)))
  corps
}

/// Valeur posée sous le nom `cle` par le `bf-porter` englobant le plus proche, sinon `defaut`.
/// Dans un `context`.
#let bf-porte(cle, defaut: none) = {
  let ch = bf-precoce-chaine()
  if ch == none { defaut } else { ch.at("_portee", default: (:)).at(cle, default: defaut) }
}

// ---------------------------------------------------------------------
//  La passe
// ---------------------------------------------------------------------

#let _est-maj(x) = (
  x.func() == metadata and type(x.value) == dictionary and "bfr-maj" in x.value
)

#let _porter(ch, corps) = {
  set bibliography(title: metadata((bfr-precoce: ch)))
  corps
}

// Parcourt `c` ; `etat` = (ch: chaîne en vigueur, n: numéro de version de la chaîne).
// Renvoie (contenu, etat à la fin). Le contenu rendu n'est pas enveloppé à son début : il hérite de la
// chaîne de son parent ; dès que la chaîne change, la suite de la séquence est enveloppée d'un `set`
// qui porte la nouvelle valeur (valeur COMPLÈTE : les enveloppes ne s'empilent pas). Seules les
// séquences sans étiquette et les contenus stylés sont traversés : le reste est opaque (et rendu tel
// quel, sans copie : un contenu inchangé garde son identité).
// `join` (comme `+`) aplatit une séquence : si elle porte une étiquette (`#[…] <x>`), l'étiquette est perdue et les
// `#lien("x")` / `@x` échouent. Dès qu'un élément est une séquence étiquetée, on construit la séquence directement.
#let _joindre(items) = {
  if items.len() < 2 or not items.any(x => x.func() == _sequence and x.has("label")) { items.join() } else { _sequence(items) }
}

#let _passe(c, etat) = {
  let f = c.func()
  if f == _styled {
    let (x, e2) = _passe(c.child, etat)
    if e2.n == etat.n { return (c, etat) }
    return (_styled(x, c.styles), e2)
  }
  if f != _sequence or c.has("label") { return (c, etat) }
  let n0 = etat.n
  let ch = etat.ch
  let n = n0
  let morceaux = ()
  let seg = ()
  let ch-seg = ch
  let n-seg = n0
  for x in c.children {
    if _est-maj(x) {
      let v = x.value
      ch.insert(v.bfr-maj, (v.f)(ch.at(v.bfr-maj, default: v.init)))
      n += 1
    } else {
      let fx = x.func()
      if fx == _sequence or fx == _styled {
        let (y, e2) = _passe(x, (ch: ch, n: n))
        seg.push(y)
        ch = e2.ch
        n = e2.n
      } else {
        seg.push(x)
      }
    }
    if n != n-seg {
      if seg.len() > 0 {
        morceaux.push(if n-seg == n0 { _joindre(seg) } else { _porter(ch-seg, _joindre(seg)) })
      }
      seg = ()
      ch-seg = ch
      n-seg = n
    }
  }
  if n == n0 { return (c, etat) }
  if seg.len() > 0 { morceaux.push(_porter(ch-seg, _joindre(seg))) }
  (_joindre(morceaux), (ch: ch, n: n))
}

/// La passe : à poser une fois, en tête du document (`#show: bf-precoce`) ; le modèle de bfcours le fait.
/// Le document entier est enveloppé d'une chaîne qui contient déjà la valeur initiale de chaque état mis
/// à jour par un marqueur : avant sa première mise à jour, un tel état se lit donc sans introspection.
#let bf-precoce(doc) = {
  if type(doc) != content { return doc }
  // 1. valeurs initiales des états visés par les marqueurs visibles (parcours itératif)
  let inits = (:)
  let pile = (doc,)
  while pile.len() > 0 {
    let x = pile.pop()
    let f = x.func()
    if f == _sequence { if not x.has("label") { pile += x.children } }
    else if f == _styled { pile.push(x.child) }
    else if _est-maj(x) and x.value.bfr-maj not in inits { inits.insert(x.value.bfr-maj, x.value.init) }
  }
  if inits.len() == 0 { return doc }
  // 2. la passe elle-même
  let (x, e) = _passe(doc, (ch: inits, n: 0))
  show bibliography: set bibliography(title: auto)
  _porter(inits, x)
}
