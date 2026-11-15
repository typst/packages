// paginer.typ (farfadet-modele) — pagination relevée puis rejouée.
//
// Typst ne compose en parallèle que les suites de pages séparées par un saut de page explicite
// (typst-layout, pages/mod.rs et pages/collect.rs). Un saut posé exactement là où la page se termine
// déjà ne change rien au rendu. La chaîne de compilation (bfwatch, compiler.py) relève donc les débuts
// de page d'une compilation ordinaire, puis les rejoue en sauts explicites lors des compilations
// suivantes du MÊME source. Le document ne porte rien.
//
// Entrées (sys.inputs), posées par la chaîne, jamais par le document :
//   bf-releve=1         : pose un repère `metadata(k) <bf-coupure>` devant chaque frontière candidate n° k ;
//   bf-releve=2         : idem, plus l'inventaire des feuilles (`<bf-inventaire>`, mise au point) ;
//   bf-coupures=3,17,42 : pose un saut FAIBLE devant les frontières candidates 3, 17 et 42 (faible : jamais
//                         de page blanche s'il tombe en haut d'une page déjà commencée par un saut).
// Sans ces entrées, le corps est rendu tel quel (aucun parcours, coût nul).
//
// Frontière candidate : feuille du flux de premier niveau (on ne descend que dans les séquences et les
// styles, jamais dans un conteneur) qui commence un bloc : après un saut de paragraphe, après un élément
// de bloc, ou au début du document. Un saut ne coupe donc jamais un paragraphe.
// Cas du `needspace` (étiquette `<bf-needspace>`) : quand il précède une frontière à couper, le saut se
// pose devant lui (posé après, son bloc invisible déjà passé en haut de page laisserait une page blanche).

#let _seq = [a *b*].func()
#let _styled = [#set text(red)
  x].func()

// Feuilles invisibles : elles ne changent pas l'état « frontière ».
#let _neutres = ("metadata", "state-update", "counter-update", "tag")
// Éléments de bloc : après eux, on est sur une frontière.
#let _blocs = ("heading", "block", "figure", "grid", "table", "place", "v", "pagebreak", "colbreak",
  "list.item", "enum.item", "terms.item", "align", "pad", "columns", "stack", "rect", "outline")

// `join` aplatit une séquence étiquetée (`#[…] <x>`) et perd son étiquette : on construit alors la séquence directement.
#let _joindre(items) = {
  if items.len() < 2 or not items.any(x => x.func() == _seq and x.has("label")) { items.join() } else { _seq(items) }
}

// s : (k: n° de la prochaine candidate, fr: frontière, inv: inventaire, saut: candidate dont le saut est déjà posé)
#let _rec(c, s, coupures, mode) = {
  let f = c.func()
  // Une séquence étiquetée (needspace, environnement étiqueté) est une feuille : la reconstruire perdrait son étiquette.
  if f == _seq and c.at("label", default: none) == none {
    let sortie = ()
    for x in c.children {
      let (r, s2) = _rec(x, s, coupures, mode)
      sortie.push(r)
      s = s2
    }
    (_joindre(sortie), s)
  } else if f == _styled {
    let (r, s2) = _rec(c.child, s, coupures, mode)
    (f(r, c.styles), s2)
  } else {
    let nom = repr(f)
    if nom == "space" { return (c, s) }
    if nom == "parbreak" { s.fr = true; return (c, s) }
    let ns = c.at("label", default: none) == <bf-needspace>
    let bloc = ns or nom in _blocs or (nom == "equation" and c.block)
    let fr2 = bloc or (nom in _neutres and s.fr)
    if mode == 2 { s.inv.push((nom, s.fr, repr(c.at("label", default: none)))) }
    let avant = ()
    if s.fr {
      let k = s.k
      if ns and (k + 1) in coupures {
        avant.push(pagebreak(weak: true))
        s.saut = k + 1
      } else if k in coupures and s.saut != k {
        avant.push(pagebreak(weak: true))
      }
      if mode >= 1 { avant.push([#metadata(k)<bf-coupure>]) }
      s.k = k + 1
    } else if ns and s.k in coupures {
      // needspace hors frontière : la prochaine candidate (n° s.k) reçoit son saut ici, devant lui.
      avant.push(pagebreak(weak: true))
      s.saut = s.k
    }
    s.fr = fr2
    (if avant.len() == 0 { c } else { _joindre((..avant, c)) }, s)
  }
}
#let paginer(corps, coupures: (), mode: 0) = {
  if coupures.len() == 0 and mode == 0 { return corps }
  let (r, s) = _rec(corps, (k: 0, fr: true, inv: (), saut: none), coupures, mode)
  if mode == 2 { [#metadata(s.inv)<bf-inventaire>] }
  r
}

#let paginer-auto(corps) = {
  let brut = sys.inputs.at("bf-coupures", default: "")
  let coupures = if brut == "" { () } else { brut.split(",").map(int) }
  let mode = int(sys.inputs.at("bf-releve", default: "0"))
  paginer(corps, coupures: coupures, mode: mode)
}
