// items.typ (farfadet-enum) — lecture du corps unique des fonctions à items : tcbenumerate, enumerate, itemize,
// MultiColonnes, tcbraster.
//
// Depuis la double syntaxe, ces fonctions reçoivent UN SEUL corps, où chaque item s'écrit `+` (tcbenumerate,
// enumerate) ou `-` (itemize, MultiColonnes, tcbraster), ou `#tcbitem(…)[…]` quand l'item a des options :
//
//   #tcbenumerate(columns: 2)[
//     + Première question
//     + Seconde question
//   ]
//
// Ce module passe le corps par `environnements` (pour accepter `#begin … #end` à l'intérieur), le découpe en
// items (`decouper-items`) et le met sous la forme que le moteur attend.

#import "../../socle/lib.typ": interne as _socle
#import _socle: environnements, decouper-items
#import "moteur/listes.typ" as m

/// Message d'erreur de l'ancienne écriture (un bloc `[…]` par item, ou `tcbitem` entre parenthèses).
#let _ancienne-ecriture(nom, puce) = {
  panic(
    nom + " : l'écriture à plusieurs blocs `[…][…]` (ou avec `tcbitem(…)` entre parenthèses) n'existe plus.\n"
      + "Écrire UN SEUL corps, avec un item par ligne (« " + puce + " ») :\n"
      + "    #" + nom + "[\n"
      + "      " + puce + " Première question\n"
      + "      " + puce + " Seconde question\n"
      + "    ]\n"
      + "Un item qui a des options s'écrit `#tcbitem(raster-multicolumn: 2)[…]` dans le corps, à la place du « "
      + puce + " ».",
  )
}

/// Le corps unique de `pos` (les arguments positionnels de l'appel), après contrôle.
#let corps-unique(nom, pos, puce) = {
  if pos.len() == 0 {
    panic(nom + " : le corps est manquant. Écrire `#" + nom + "[` puis un item par ligne (« " + puce + " »), puis `]`.")
  }
  if pos.len() > 1 { _ancienne-ecriture(nom, puce) }
  let c = pos.first()
  if type(c) != content {
    if type(c) == dictionary { _ancienne-ecriture(nom, puce) }
    panic(nom + " : le corps doit être un bloc de contenu `[…]` ; reçu : " + repr(c) + ".")
  }
  c
}

/// Items d'une fonction à cases ou à pastilles : tableau de contenus et de `tcbitem` du moteur.
/// `titre` : titre par défaut des items qui n'ont pas le leur (clé `title` de `tcbenumerate`).
/// Renvoie `(items: …, depart: …)` : `depart` est le numéro explicite du premier item (`5. …`), sinon `none`.
#let items-boites(nom, pos, puce, titre: none) = {
  let corps = corps-unique(nom, pos, puce)
  let lus = decouper-items(environnements(corps), puce: puce)
  let depart = none
  let items = ()
  for (i, it) in lus.enumerate() {
    if type(it) != dictionary {
      items.push(if titre == none { it } else { m.tcbitem(title: titre, it) })
      continue
    }
    let opts = it.options
    if "number" in opts {
      if i == 0 { depart = opts.number }
      let _ = opts.remove("number") // `remove` renvoie la valeur : ne pas la joindre au résultat
    }
    if titre != none and "title" not in opts { opts.insert("title", titre) }
    items.push(if opts.len() == 0 { it.corps } else { m.tcbitem(..opts, it.corps) })
  }
  (items: items, depart: depart)
}

/// Items d'une liste standard (`enumerate`, `itemize`) : tableau de contenus, plus le numéro du premier item
/// s'il est explicite. Un `tcbitem` n'a pas de sens ici.
#let items-liste(nom, pos, puce) = {
  let corps = corps-unique(nom, pos, puce)
  let lus = decouper-items(environnements(corps), puce: puce)
  let depart = none
  let items = ()
  for (i, it) in lus.enumerate() {
    if type(it) == dictionary {
      let autres = it.options.keys().filter(k => k != "number")
      if autres.len() > 0 {
        panic(nom + " : `tcbitem` n'existe que dans tcbenumerate, multi-colonnes et tcbraster ; écrire simplement « " + puce + " » devant l'item.")
      }
      if i == 0 and "number" in it.options { depart = it.options.number }
      items.push(it.corps)
    } else { items.push(it) }
  }
  (items: items, depart: depart)
}
