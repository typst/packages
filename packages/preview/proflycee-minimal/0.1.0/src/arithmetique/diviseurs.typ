// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Diviseurs et facteurs premiers, d'après \ListeDiviseurs, \ArbreDiviseurs,
// \DecompFactPremiers, \PresFactPremiers et \SimplFracDecomp du paquet LaTeX
// ProfLycee (Cédric Pierquet, §60 de sa documentation).
//
// Commandes (noms abrégés, plus courts que ceux de ProfLycee) :
//
//   #liste-div(n, clés)          -> D_n = { 1 ; … ; n } ;
//   #arbre-div(n, clés)          -> arbre des diviseurs, un niveau par facteur
//                                   premier (canvas autonome) ;
//   arbre-div-dessin(n, clés)    -> ses éléments seuls, dans son propre
//                                   #canvas({ ... }) (pas dans ProfLycee) ;
//   #dpfp(n, clés)               -> décomposition en produit de facteurs
//                                   premiers : 2^3 × 3 × 5 × 7^2 × 11 × 43 ;
//   #prespfp(n, clés)            -> divisions successives présentées en
//                                   colonnes, séparées d'un trait ;
//   #simpfrac(num, den, clés)    -> fraction simplifiée grâce aux
//                                   décompositions, facteurs communs en couleur.
//
// n, num, den : entiers strictement positifs (pour un produit, écrire le
// calcul Typst : calc.pow(2, 2) * 3 * 5 * 7 * 11). Décomposition prévue pour
// des entiers de taille scolaire : garantie jusqu'à 10^8 (au-delà, Typst peut
// arrêter la recherche des facteurs, limitée à 10 000 tours de boucle).
//
// Clés (entre parenthèses : équivalent ProfLycee, puis défaut) :
//
// liste-div
//   aff-nom          (AffNom)          afficher « D_n = » ............... true
//   scr              (version étoilée) nom en écriture ronde (scr), au
//                                      lieu de calligraphique (cal) ..... true
// arbre-div
//   espace-niveau    (EspaceNiveau)    écart horizontal entre niveaux ... 2.25
//   espace-feuille   (EspaceFeuille)   écart vertical entre feuilles .... 0.66
//   details          (Details)         calcul de chaque diviseur à droite true
//   couleur-details  (CouleurDetails)  couleur de ces calculs ........... red
//   echelle          (Echelle)         échelle de toute la figure, texte
//                                      compris (version autonome seule) . 1
//   fleches          (Fleches)         flèche au bout des branches ...... true
// dpfp
//   longue           (Longue)          facteurs répétés, sans puissances  false
//   puissance-un     (PuissanceUn)     écrire aussi les exposants 1 ..... false
// prespfp
//   epaisseur-trait  (EpaisseurTrait)  épaisseur du trait vertical ...... 0.4pt
//   encadre-fin      (EncadreFin)      encadrer le 1 final .............. false
// simpfrac
//   aff-couleur      (pas dans ProfLycee) facteurs communs en couleur ;
//                                      sinon tout en noir ............... false
//   couleur-commun   (CouleurCommun)   couleur des facteurs communs ..... red.darken(10%)
//   barrer           (Barrer)          barrer les facteurs communs ...... false
//   couleurs-barres  (pas dans ProfLycee) avec barrer et aff-couleur, une
//                                      couleur par premier commun, du plus
//                                      petit au plus grand (on reprend au
//                                      début si la liste est trop courte) (red, blue, green.darken(20%), orange, purple)
//   d                (d)               fractions en grand (display) ..... false
//   t                (t)               fractions en petit (inline) ...... false
//
// Exemples :
//   #liste-div(150)
//   #arbre-div(60)
//   #dpfp(2781240, puissance-un: true)
//   #simpfrac(1320, 1248, d: true, barrer: true, aff-couleur: true)
#import "../deps.typ": cetz
#import "../outils.typ": _nombre
#import "../arbre.typ": _arbre-dessin

#let _entier-positif(n, nom) = assert(
  type(n) == int and n >= 1,
  message: nom + " : entier strictement positif attendu",
)

// Décomposition de n : tableau de (p, a), p premier croissant, par divisions
// successives.
#let _facteurs(n) = {
  let facteurs = ()
  let p = 2
  while p * p <= n {
    let a = 0
    while calc.rem(n, p) == 0 {
      n = calc.quo(n, p)
      a += 1
    }
    if a > 0 { facteurs.push((p, a)) }
    p += if p == 2 { 1 } else { 2 }
  }
  if n > 1 { facteurs.push((n, 1)) }
  facteurs
}

// Facteurs répétés, dans l'ordre croissant : 12 → (2, 2, 3).
#let _facteurs-longs(n) = _facteurs(n).map(((p, a)) => (p,) * a).flatten()

#let liste-div(n, aff-nom: true, scr: true) = {
  _entier-positif(n, "liste-div")
  let petits = range(1, calc.floor(calc.sqrt(n)) + 1).filter(d => calc.rem(n, d) == 0)
  let grands = petits.rev().map(d => calc.quo(n, d)).filter(d => d * d != n)
  let liste = $lr(\{ #(petits + grands).map(_nombre).join($med";"med$) \})$
  if aff-nom {
    // `scr` (la clé) masque math.scr
    let D = if scr { $#math.scr("D")$ } else { $cal(D)$ }
    $#D _#_nombre(n) = #liste$
  } else { liste }
}

#let dpfp(n, longue: false, puissance-un: false) = {
  _entier-positif(n, "dpfp")
  if n == 1 { return $1$ }
  let termes = if longue {
    _facteurs-longs(n).map(_nombre)
  } else {
    _facteurs(n).map(((p, a)) => if a == 1 and not puissance-un { _nombre(p) } else { $#_nombre(p)^#a$ })
  }
  // une seule formule, pour l'espacement autour des ×
  $#termes.join($times$)$
}

#let prespfp(n, epaisseur-trait: 0.4pt, encadre-fin: false) = {
  _entier-positif(n, "prespfp")
  let lignes = ()
  for p in _facteurs-longs(n) {
    lignes.push((_nombre(n), _nombre(p)))
    n = calc.quo(n, p)
  }
  let fin = if encadre-fin { box(stroke: epaisseur-trait, inset: (x: 2pt), outset: (y: 2pt), $1$) } else { $1$ }
  lignes.push((fin, []))
  grid(
    columns: 2,
    align: (right, left),
    inset: (x: 0.4em, y: 0.25em),
    stroke: (x, y) => if x == 1 { (left: epaisseur-trait) },
    ..lignes.flatten(),
  )
}

#let simpfrac(
  num,
  den,
  aff-couleur: false,
  couleur-commun: red.darken(10%),
  barrer: false,
  couleurs-barres: (red, blue, green.darken(20%), orange, purple),
  d: false,
  t: false,
) = {
  _entier-positif(num, "simpfrac")
  _entier-positif(den, "simpfrac")
  let g = calc.gcd(num, den)
  let communs = _facteurs-longs(g)
  // couleur d'un facteur commun : noir sans aff-couleur ; sinon
  // couleur-commun, ou, s'il est barré, celle de son rang parmi les premiers
  // communs (2 en rouge, 3 en bleu…)
  let premiers = _facteurs(g).map(f => f.first())
  let couleur(p) = if not aff-couleur { black } else if barrer {
    couleurs-barres.at(calc.rem(premiers.position(x => x == p), couleurs-barres.len()))
  } else { couleur-commun }
  // produit des facteurs de n, les facteurs communs (avec multiplicité)
  // éventuellement en couleur et barrés
  let produit(n) = {
    let reste = communs
    let termes = ()
    for p in _facteurs-longs(n) {
      let i = reste.position(x => x == p)
      if i != none {
        let _ = reste.remove(i)
        let c = if aff-couleur { text(fill: couleur(p), _nombre(p)) } else { _nombre(p) }
        termes.push(if barrer { math.cancel(c, stroke: couleur(p) + 0.5pt) } else { c })
      } else { termes.push(_nombre(p)) }
    }
    if termes.len() == 0 { $1$ } else { termes.join($times$) }
  }
  let style = if d { math.display } else if t { math.inline } else { x => x }
  let fraction(a, b) = style(math.frac(a, b))
  let resultat = if den == g { _nombre(calc.quo(num, g)) } else {
    fraction(_nombre(calc.quo(num, g)), _nombre(calc.quo(den, g)))
  }
  $#fraction(_nombre(num), _nombre(den)) = #fraction(produit(num), produit(den)) = #resultat$
}

#let arbre-div-dessin(
  n,
  espace-niveau: 2.25,
  espace-feuille: 0.66,
  details: true,
  couleur-details: red,
  fleches: true,
) = {
  import cetz.draw: *
  _entier-positif(n, "arbre-div")
  assert(n >= 2, message: "arbre-div : entier au moins égal à 2 attendu")
  let facteurs = _facteurs(n)
  let K = facteurs.len()
  // niveau k : les puissances p_k^0, …, p_k^a_k du k-ième facteur premier
  let puissance(k, e) = $#_nombre(facteurs.at(k - 1).first())^#e$
  _arbre-dessin(
    facteurs.map(((p, a)) => a + 1),
    (k, i, chemin) => puissance(k, chemin.last()),
    espace-niveau: espace-niveau,
    espace-feuille: espace-feuille,
    fleche: fleches,
    trait: (paint: black, thickness: 0.4pt),
  )
  if details {
    let nb-feuilles = facteurs.fold(1, (s, (p, a)) => s * (a + 1))
    let x = K * espace-niveau + 0.6
    for j in range(nb-feuilles) {
      // exposants de la feuille j, du premier facteur au dernier
      let (exposants, reste) = ((), j)
      for (p, a) in facteurs.rev() {
        exposants.insert(0, calc.rem(reste, a + 1))
        reste = calc.quo(reste, a + 1)
      }
      let valeur = facteurs.zip(exposants).fold(1, (s, ((p, a), e)) => s * calc.pow(p, e))
      let calcul = range(K).map(k => puissance(k + 1, exposants.at(k))).join($times$)
      content(
        ((x, 0), "|-", "A" + str(K) + str(j + 1)),
        text(fill: couleur-details, $#calcul = #_nombre(valeur)$),
        anchor: "west",
      )
    }
  }
}

#let arbre-div(n, echelle: 1, ..cles) = scale(
  echelle * 100%,
  reflow: true,
  cetz.canvas(length: 1cm, arbre-div-dessin(n, ..cles)),
)
