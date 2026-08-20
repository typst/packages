#set page(margin: (y: 1cm))
#set text(lang: "fre")
#import "Hachures.typ": *

#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4": chart,plot

#import "@preview/tiptoe:0.4.0"
#show math.equation: it => {
  show regex("\d+(\.\d+)?"): it => it.text.replace(".", ",")
  it
}
#show math.lt.eq: math.lt.eq.slant
// #show regex("\d+(\.\d+)?"): it => it.text.replace(".", ",")

#let fr(a) = {str(a)}

// Ecrit le quotient a / b avec a et b flottants (ou a si b = 1)
#let ff(a, b) = if b == 1 or a == 0 { fr(float(a)) } else {
  math.frac(fr(float(a)), fr(float(b)))
}

// Donne l'écriture sous forme de fraction irréductible (max 6 chiffres après la virgule) -> content
#let valf(
  // int | float
  a, 
  // int |float
  b
) = if (
  (type(a) == float and calc.round(a, digits: 5) == int(a) or type(a) == int)
    and type(b) == int
    and calc.gcd(int(a), int(b)) == calc.abs(b)
) { $#(a / b)$ } else {
  if a * b < 0 {
    $-$
    a = calc.abs(a)
    b = calc.abs(b)
  }
  math.frac(
    fr(float(int(a * 1000000) / calc.gcd(int(a * 1000000), int(b * 1000000)))),
    fr(float(b * 1000000 / calc.gcd(int(a * 1000000), int(b * 1000000)))),
  )
}

// $display(#ff(3.6,6.9))=display(#valf(3.6,6.9))$

// Ecrit le quotient a / b  avec a et b flottants (ou a si b = 1) et son écriture sous forme de fraction irréductible (max 6 chiffres après la virgule) 
//```example
// #simpli(3.6,6.9)
//```
// -> content
#let simpli(
  // int | float
  a, 
  // int |float
  b
) = if type(a) == int and type(b) == int and calc.gcd(a, b) == 1 or a == 0 { $display(#ff(a, b))$ } else {
  $display(#ff(a, b))=display(#valf(a, b))$
}

// Calcule le PGCD d'une liste de nombres 
//```example
// #PGCD(1000, 1200, 1400, 1600, 1800, 2000)
//``` 
//-> int
#let PGCD(
  // Liste de nombres -> array
  ..a
) = {
  let gcd=calc.gcd(a.at(0),a.at(1))
  for i in range(2,a.len()) {gcd=calc.gcd(gcd,a.at(i))}
  gcd
}

=== Fonctions diagrammes
==== Bandes

// `bandes(valeurs:(), effectifs:(), width:1fr, tourne:(), couleurs:auto, print:false, explication:(), hauteur:40pt)`

// Dessine un diagramme en bandes 
//```example
//>>> #set text(.7em)
// #bandes(valeurs:("Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"),effectifs:(25, 18, 17, 10, 5, 20),width:9cm,tourne:(4,),explication: (0,))
//``` 
// -> content
#let bandes(
  // Modalités du caractères -> array
  valeurs:(),
  // Effectifs de chaque valeur -> array
  effectifs:(),
  // Longueur totale de la bande -> length
  width:1fr,
  // Pour tourner les labels des rectangles de 90deg -> array
  tourne:(),
  // Liste des couleurs des rectangles -> auto | array
  couleurs:auto,
  // Si true, remplace les couleurs par des tilings -> boolean
  print:false,
  // Explication de la construction : la ou les étapes à expliquer (0,) ou (0,3) -> array
  explication:(),
  // Hauteur de la bande -> length
  hauteur:40pt,
) = box(width:width,{
  let cols = effectifs.len()
  let couleurs = if print {hachures} else if couleurs != auto {couleurs} else {petroff10}
  for i in tourne {valeurs.at(i) = rotate(90deg,reflow:true,text(.9em,valeurs.at(i)))}
  let valeurs = if print {valeurs.map(x => box(fill:white, outset:1.5pt, radius:.25em, x))} else {valeurs}
  if explication != () {v(-.5em)
  valeurs.insert(0,table.cell(colspan :cols,stroke:none,fill:none,align: bottom)[$width.cm() "cm"$ #tiptoe.line(length: 100%,tip: tiptoe.stealth, toe: tiptoe.stealth) ] )
  for i in range(cols) {
    if i in explication {
      valeurs.push(table.cell(fill:none,stroke: none,align: top)[#set text(1em)
        #tiptoe.line(length: 100%,tip: tiptoe.stealth, toe: tiptoe.stealth)
        $width.cm() times effectifs.at(#i)/effectifs.sum() approx #calc.round(width.cm() * effectifs.at(i)/effectifs.sum(),digits:1) "cm" $])
    } else {valeurs.push(table.cell(fill:none,stroke: none)[])} 
  } 
  }
  table(align:center+horizon,
  columns: effectifs.map(it => it*1fr),
  rows:if explication != () {(20pt,hauteur,30pt)} else {hauteur},
  fill:(col, _) => for i in range(effectifs.len()) {if col==i { couleurs.at(i) }},
  ..valeurs
)})

==== Camemberts

// camembert(valeurs:(),  effectifs:(),  data:(),  semi:false,  legende:"d",  espace:.1,  print:false,  couleurs:auto,  dedans:true,  dehors:true,  ..args)

// Dessine un diagramme (semi-)circulaire
//```example
// #camembert(valeurs:("foot","basket","tennis","ping-pong","hand","natation","danse"),effectifs: (1, 3, 5, 4, 7, 2, 5),radius:1.5,legende: "d",espace: 0,semi: true)
//``` 
// -> content
#let camembert(
  // Modalités du caractères -> array
  valeurs:(),
  // Effectifs de chaque valeur -> array
  effectifs:(),
  // Pour garder la possibilité de ne saisir qu'une liste de valeurs -> array
  data:(),
  // Si true, dessine un diagramme semi-circulaire -> boolean
  semi:false,
  // Position de la légende : "d", "g", "h", "b" sinon "" rien -> str
  legende:"d",
  // Espacement des items dans la légende si à gauche ou droite -> int | float
  espace:.1,
  // Si true, remplace les couleurs par des tilings -> boolean
  print:false,
  // Liste des couleurs des secteurs -> auto | array
  couleurs:auto,
  // True, none, false ou passe à inner-label -> boolean | none | dictionnary
  dedans:true,
  // True, none, false ou passe à outer-label -> boolean | none | dictionnary
  dehors:true,
  ..args
) = box(cetz.canvas({
  let data = if data == () { valeurs.zip(effectifs) } else {data}
  chart.piechart(
    data,
    value-key: if effectifs != () {1},
    label-key: if effectifs != () {0},
    radius: 2,
    gap: 0deg,
    start:if semi {0deg} else {90deg},
    stop:if semi {180deg} else {450deg},
    slice-style: if print {print-hachures} else if couleurs != auto {couleurs} else {petroff10}, 
    legend: if legende == "d" {(
            position: "east",
            anchor: "west",
            orientation: ttb,
            item: (spacing: espace),
            offset: (.5em, -.5em ),
          )} else if legende == "t" {(
            offset: (0em, .5em ),
          )} else if legende == "b" {(
            position: "north",
            anchor: "south",
            offset: (0em, -.5em ),
          )} else if legende == "g" {(
            position: "west",
            anchor: "east",
            orientation: ttb,
            item: (spacing: espace),
            offset: (-.5em, -.5em ),
          )} else {(label:none)},
          inner-label: if dedans == true {(
            content: (value, label) => box(text(.8em, if print {black} else {white}, $value$) ,fill: if print {white} else {none},inset:.5pt,radius: .5em),
            radius: 130%,
          )} else if dedans == none or dedans == false {(content:none)} else {(dedans)},
          outer-label: if dehors == true {(
            content: "%",
            radius: 120%,
          )} else if dehors == none or dehors == false {(content:none)} else {(dehors)},
          ..args
  )
}))

==== Vrais histogrammes

// `histogramme(classes: (),  effectifs:(),  px: 1,  uaire: 1,  s: 1,   grille: true,  PasGrille:1,  Donnee: [Valeurs],  Effectifs: [effectifs],  add: (-1, 1, 1),  lecture: true,  DonneesSup: true,  ListeCouleurs: auto,  pos-rect: (0, 2),  print:false,  transparence:30%,  ECC:false,  Mediane:false,  quartiles:false,  décimales:2,  posq1:(0,-1.5),  posMediane:(0,-1.5),  posq3:(1,-1.5),  stroke-mediane:2pt,  stroke-quartiles:1.5pt,  textsize:1em,)`

// Dessine un VRAI histogramme : les classes n'ont pas forcément la même amplitude et ce sont les aires qui sont proportionnelles 
///
// #example(`#histogramme(
//   classes: (1000, 1200, 1400, 1600, 1800, 2000),
//   effectifs: (120, 150, 220, 360, 200),
//   px: 50,
//   uaire: 10,
//   s: .5,
//   // textsize: .5em,
//   Donnee: [Salaire (en €)],
//   Effectifs: [Salariés],
//   Mediane: true,
//   quartiles: true,
//   pos-rect: (0,5),
// )`,dir:ttb)
///
// -> content
#let histogramme(
  // Liste des bornes des classes : longueur = longueur de `effectifs` + 1 -> array
  classes: (),
  // Effectifs de chaque classe : longueur = longueur de `classes` - 1 -> array
  effectifs:(),
  // Pas sur l'axe des abscisses -> int
  px: 1,
  // Quantité représentée par un carreau -> int
  uaire: 1,
  // Echelle cetz du graphique -> int | float | dictionnary
  s: 1,
  // Affichage ou non d'un quadrillage -> boolean
  grille: true,
  // Pas du quadrillage -> int | float
  PasGrille:1,
  // Nom pour la légende ou l'axe des ordonnées le cas échéant -> content
  Donnee: [Valeurs],
  // Nom pour l'axe des abscisses -> content
  Effectifs: [effectifs],
  // Combien "ajouter" à gauche, droite et au dessous, soit un triplet, soit un entier unique -> int | array
  add: (-1, 1, 1),
  // Pour avoir ou non un axe des ordonnées lorsque les classes ont la même amplitude -> boolean
  lecture: true,
  // Affichage ou non des effectifs au dessus des rectangles -> boolean
  DonneesSup: true,
  // Liste des couleurs des rectangles ou une unique couleur white pour l'impression par ex -> auto | color | array
  ListeCouleurs: auto,
  // Position du rectangle de légende par rapport au coin hg du plus petit rectangle -> array
  pos-rect: (0, 2),
  // Si true, remplace les couleurs par des tilings -> boolean
  print:false,
  // Transparence des rectangles : mettre à 100% si ListeCouleurs: white -> ratio
  transparence:30%,
  // Affichage des effectifs cumulés croissants -> boolean
  ECC:false,
  // Affichage ou non de la médiane -> boolean
  Mediane:false,
  // Afficha ou non des quartiles -> boolean
  quartiles:false,
  // Nombre de décimales des arrondis -> int
  décimales:2,
  // Position de la valeur de q1 par rapport à l'axe des abscisses (0,-1.5) par défaut -> array
  posq1:(0,-1.5),
  // Position de la valeur de la médiane par rapport à l'axe des abscisses (0,-1.5) par défaut -> array
  posMediane:(0,-1.5),
  // Position de la valeur de q3 par rapport à l'axe des abscisses (1,-1.5) par défaut -> array
  posq3:(1,-1.5),
  // Trait pour représenter la médiane 2pt par défaut -> length | stroke
  stroke-mediane:2pt,
  // Trait pour représenter les quartiles 2pt par défaut -> length | stroke
  stroke-quartiles:1.5pt,
  // Taille des textes -> length
  textsize:1em,
) = box(cetz.canvas({
  import cetz.draw: *
  let ListeCouleurs = if print {hachures} else if type(ListeCouleurs) == color {(ListeCouleurs,)*effectifs.len()} else if ListeCouleurs != auto {ListeCouleurs} else {petroff10}
  let add = if type(add) == int { (-add, add, add) } else { add }
  let ecarts = for i in range(classes.len() - 1) {
    (classes.at(i + 1) - classes.at(i),)
  }

  let ecc = {
    for i in range(effectifs.len()) { (effectifs.slice(0, i + 1).sum(),) }
  }

  let effectif-total = effectifs.sum()

  let mediane = if ecc != none {
    let milieu = ecc.position(x => x > calc.quo(effectif-total, 2))
     (milieu, calc.round(classes.at(milieu)
          + (effectif-total / 2 - ecc.at(milieu - 1))
            / effectifs.at(milieu)
            * (classes.at(milieu + 1) - classes.at(milieu)),digits:décimales)
          )
  }

  let q1 = if ecc != none {
    let pos = ecc.position(x => x >= effectif-total / 4)
    
      (pos,
        calc.round(classes.at(pos)
          + (effectif-total / 4 - if pos != 0 { ecc.at(pos - 1) } else { 0 })
            / effectifs.at(pos)
            * (classes.at(pos + 1) - classes.at(pos)),digits:décimales)
      )
  }

  let q3 = if ecc != none {
    let pos = ecc.position(x => x >= 3 * effectif-total / 4)
      (pos,
        calc.round(classes.at(pos)
          + (
            3 * effectif-total / 4 - if pos != 0 { ecc.at(pos - 1) } else { 0 }
          )
            / effectifs.at(pos)
            * (classes.at(pos + 1) - classes.at(pos)),digits:décimales)
      )
  }

  let effectifs = if ECC {ecc} else {effectifs}

  let test = for i in ecarts { (i == ecarts.at(0),) }

  let rectx = for i in classes { ((i - classes.at(0)) / px,) }
  let recty = for i in range(effectifs.len()) {
    (effectifs.at(i) / (uaire * (rectx.at(i + 1) - rectx.at(i))),)
  }

  let m = calc.min(..recty)
  let n = recty.position(x => x == m)
  let k = calc.max(..recty)

  let py = if false not in test { effectifs.at(0) / recty.at(0) }

  scale(s)

  if grille != false {
    grid(
      (add.at(0), 0),
      (rectx.last() + add.at(1), k + add.at(2)),
      stroke: gray + .6pt,step:PasGrille,
    )
  }

  line((add.at(0), 0), (0, 0))
  line((rectx.last(), 0), (rectx.last() + add.at(1), 0), mark: (
    end: ">>",
    fill: black,
  ))
  content((), Donnee, anchor: "north-west", padding: .1,wrap:text.with(textsize))

  if py != none and lecture {
    line((add.at(0), 0), (add.at(0), k + add.at(2)), mark: (
      end: ">>",
      fill: black,
    ))
    content((), Effectifs, anchor: "south", padding: .1,wrap:text.with(textsize))

    for i in range(int(k) + add.at(2)) {
      line((-.1 + add.at(0), i), (+add.at(0), i))
      content((add.at(0), i), $#(py * i)$, anchor: "east", padding: .1,wrap:text.with(textsize))
    }
  } else {
    rect(
      (rectx.at(n) + pos-rect.at(0), calc.ceil(m + pos-rect.at(1))),
      (rel: (1, 1)),
      fill: gray.transparentize(transparence),
    )
    content((), [$uaire$ #Effectifs], anchor: "north-west", padding: .1*s,wrap:text.with(textsize))
  }

  for i in range(effectifs.len()) {
    rect(
      (rectx.at(i), 0),
      (rectx.at(i + 1), recty.at(i)),
      fill: if type(ListeCouleurs.at(i)) == color {ListeCouleurs.at(i).transparentize(transparence)} else {ListeCouleurs.at(i)},
    )
    if DonneesSup {
      content(
        ((rectx.at(i) + rectx.at(i + 1)) / 2, recty.at(i) ),
        $effectifs.at(#i)$, anchor:"south", padding: .1,wrap:text.with(textsize),
      )
    }
  }

  for i in range(rectx.len()) {
    content((rectx.at(i), 0), $classes.at(#i)$, anchor: "north", padding: .1,wrap:text.with(textsize))
  }

  if Mediane {
    line(((mediane.at(1)- classes.at(0)) / px,recty.at(mediane.at(0))),((mediane.at(1) - classes.at(0)) / px,0),stroke:stroke-mediane)
    content((rel:posMediane),$ "Me" approx mediane.at(#1) $,wrap:text.with(textsize))
    if py != none and lecture and ECC {
      line((add.at(0),effectif-total/2/py),((mediane.at(1) - classes.at(0)) / px,effectif-total/2/py),stroke:(dash:"dashed"))
      line((rectx.at(mediane.at(0)),recty.at(mediane.at(0)-1)),         (rectx.at(mediane.at(0)+1),recty.at(mediane.at(0))), stroke:(dash:"dashed"))
    }
  }

  if quartiles {
    line(((q1.at(1)- classes.at(0)) / px,recty.at(q1.at(0))),((q1.at(1) - classes.at(0)) / px,0),stroke:stroke-quartiles)
    content((rel:posq1),$ q1.at(#1) $,wrap:text.with(textsize))
    line(((q3.at(1)- classes.at(0)) / px,recty.at(q3.at(0))),((q3.at(1) - classes.at(0)) / px,0),stroke:stroke-quartiles)
    content((rel:posq3),$ q3.at(#1) $,wrap:text.with(textsize))
  }
  
}))

== Fonction caractéristiques

// `caracteristiques(valeurs: (),  effectifs: (),  classes: (), bins:0, sondage: (),  crochets:false,  deciles:true,)`

// Produit un dictionnaire des caractéristiques : effectif-total, mediane, classe-mediane, q1, q3, d1, d9, ecart-interquartiles, max, min, etendue, modes, effectif-modes, sommex,  sommex2, moyenne, variance, ecart-type, variance-echantillon, ecart-type-echantillon, lqboxplot, cetzboxplot 
///```example
// #caracteristiques(sondage: (1, 5, 7, 9, 4, 5, 9, 8, 7, 3, 8),)
///``` 
// -> array
#let caracteristiques(
  // Modalités du caractère `numérique` -> array
  valeurs:(),
  // Effectifs de chaque valeur -> array
  effectifs: (),
  // Bornes des classes le cas échéant : longueur = longueur effectifs + 1 -> array
  classes: (),
  // Pour un sondage, création automatique des classes de même amplitude si bins > 0 -> int
  bins:0,
  // Liste de toutes les valeurs dans le cas d'un sondage -> array
  sondage: (),
  // Pour les des classes et donc de la classe médiane, soit avec des crochets soit des inégalités a <= ... < b -> boolean
  crochets:false,
  // Prise en compte ou non des déciles pour les moustaches renvoyées dans lqboxplot et cetzboxplot, sinon +- 1.5 IQR -> boolean
  deciles:true,
) = {
  let valeurs = if sondage != () { sondage.dedup().sorted() } else { valeurs }

  let classes = if sondage != () and bins != 0 {
    let min = calc.min(..sondage)
    let max = calc.max(..sondage)
    range(bins + 1).map(x=>min+x*(max - min)/bins)
    
  } else {classes}
  
  let classes = classes.sorted()

  let effectifs = if sondage != () {
    for i in valeurs { (sondage.filter(x => x == i).len(),) }
  } else { effectifs }

  let centres = if classes != () and classes.len() == effectifs.len() + 1 {
    for i in range(classes.len() - 1) {
      ((classes.at(i) + classes.at((i + 1))) / 2,)
    }
  }

  let names = if classes != () and classes.len() == effectifs.len() + 1 {
    for i in range(classes.len() - 1) {
      if crochets {($ lr(\[classes.at(#i) thin \; classes.at(#(i + 1))\[) $,)} else {($ classes.at(#i) <= ... < classes.at(#(i + 1)) $,)}
    }
  }

  let effectif-total = if effectifs != () { effectifs.sum() } else if (
    valeurs != ()
  ) { valeurs.len() }

  let ecc = for i in range(effectifs.len()) {
    (effectifs.slice(0, i + 1).sum(),)
  }

  let mediane = {
    let milieu = ecc.position(x => x > calc.quo(effectif-total, 2))
    let m1 = ecc.position(x => x >= calc.floor(effectif-total / 2))
    let m2 = ecc.position(x => x > calc.ceil(effectif-total / 2))
    if classes == () {
      if calc.rem(effectif-total, 2) == 0 {
        (valeurs.at(m1) + valeurs.at(m2)) / 2
      } else { valeurs.at(milieu) }
    } else {
      (approx:(
        classes.at(milieu)
          + (effectif-total / 2 - ecc.at(milieu - 1))
            / effectifs.at(milieu)
            * (classes.at(milieu + 1) - classes.at(milieu))
          ),classe:names.at(milieu))
    }
  }

  let (mediane,classe-mediane) = if type(mediane) == dictionary {(mediane.approx, mediane.classe)} else {(mediane, none)}

  let q1 = {
    let pos = ecc.position(x => x >= effectif-total / 4)
    if classes == () { valeurs.at(pos) } else {
      (
        classes.at(pos)
          + (effectif-total / 4 - if pos != 0 { ecc.at(pos - 1) } else { 0 })
            / effectifs.at(pos)
            * (classes.at(pos + 1) - classes.at(pos))
      )
    }
  }

  let q3 = {
    let pos = ecc.position(x => x >= 3 * effectif-total / 4)
    if classes == () { valeurs.at(pos) } else {
      (
        classes.at(pos)
          + (
            3 * effectif-total / 4 - if pos != 0 { ecc.at(pos - 1) } else { 0 }
          )
            / effectifs.at(pos)
            * (classes.at(pos + 1) - classes.at(pos))
      )
    }
  }

  let ecart = q3 - q1

  let d1 = {
    let pos = ecc.position(x => x >= effectif-total / 10)
    if classes == () { valeurs.at(pos) } else {
      (
        classes.at(pos)
          + (effectif-total / 10 - if pos != 0 { ecc.at(pos - 1) } else { 0 })
            / effectifs.at(pos)
            * (classes.at(pos + 1) - classes.at(pos))
      )
    }
  }

  let d9 = {
    let pos = ecc.position(x => x >= 9 * effectif-total / 10)
    if classes == () { valeurs.at(pos) } else {
      (
        classes.at(pos)
          + (
            9 * effectif-total / 10 - if pos != 0 { ecc.at(pos - 1) } else { 0 }
          )
            / effectifs.at(pos)
            * (classes.at(pos + 1) - classes.at(pos))
      )
    }
  }

  let max = if classes != () { classes.last() } else if valeurs != () {
    valeurs.last()
  }
  let effectif-max = if effectifs != () { calc.max(..effectifs) }
  let (eff, names) = (effectifs, if valeurs != () { valeurs } else { names })
  let (modes, effectif-modes) = if effectifs != () {
    let modes = ()
    let effectif-modes = ()
    while effectif-max in eff {
      modes = modes + (names.remove(eff.position(x => x == effectif-max)),)
      effectif-modes = (
        effectif-modes + (eff.remove(eff.position(x => x == effectif-max)),)
      )
    }
    (modes, effectif-modes.at(0))
  }
  let min = if classes != () { classes.first() } else if valeurs != () {
    valeurs.first()
  }
  let étendue = if classes != () or valeurs != () { max - min }

  let whisker-low = if deciles {d1} else {calc.max(q1 - 1.5*ecart,min)}
  let whisker-high = if deciles {d9} else {calc.min(q3 + 1.5*ecart,max)}

  let outliers = if classes == () {()
    for i in range(valeurs.len()) {if valeurs.at(i) < whisker-low or valeurs.at(i)> whisker-high {(valeurs.at(i),)}}
  } else {()}


  let sommeprod = if centres != none {
    for i in range(effectifs.len()) { (centres.at(i) * effectifs.at(i),) }
  } else if effectifs != () {
    for i in range(effectifs.len()) { (valeurs.at(i) * effectifs.at(i),) }
  } else { valeurs }

  let sommeprod2 = if centres != none {
    for i in range(effectifs.len()) {
      (centres.at(i) * centres.at(i) * effectifs.at(i),)
    }
  } else if effectifs != () {
    for i in range(effectifs.len()) {
      (valeurs.at(i) * valeurs.at(i) * effectifs.at(i),)
    }
  } else { valeurs.map(x => x * x) }

  let sommex = if sommeprod != none { sommeprod.sum() }
  let sommex2 = if sommeprod2 != none { sommeprod2.sum() }

  let moyenne = if sommeprod != none { sommex / effectif-total }
  let variance = if sommeprod2 != none {
    sommex2 / effectif-total - moyenne * moyenne
  }
  let ecart-type = if variance != none { calc.sqrt(variance) }
  let variance-corr = if sommeprod2 != none {
    variance * effectif-total / (effectif-total - 1)
  }
  let ecart-type-corr = if variance != none { calc.sqrt(variance-corr) }

  (
    effectif-total:effectif-total,
    mediane:mediane,
    classe-médiane:classe-mediane,
    q1:q1,
    q3:q3,
    d1:d1,
    d9:d9,
    ecart-interquartiles:ecart,
    max:max,
    min:min,
    etendue:étendue,
    modes:modes,
    effectif-modes:effectif-modes, 
    sommex:sommex,
    sommex2:sommex2,
    moyenne:moyenne,
    variance:variance,
    ecart-type:ecart-type, 
    variance-echantillon:variance-corr,
    ecart-type-echantillon:ecart-type-corr,
    lqboxplot:(median:mediane, q1:q1, q3:q3, whisker-low:whisker-low, whisker-high:whisker-high, outliers:outliers,mean:moyenne),
    cetzboxplot:(q1:q1, q2:mediane, q3:q3, min:whisker-low, max:whisker-high, outliers:outliers + (moyenne,)),
  )
}

// #pagebreak()
=== Fonction stat : tableaux + diagrammes

// `stat(valeurs: (), effectifs: (),  qualitatif: true,  totaux: false,   tableau: true,  couleur-tableau: luma(85%),  inset: 5pt,  Nom-donnee: [],  Nom-effectifs: [Effectifs],  décimales: 0,  frequences: true,  sondage: (),  vide: false,  angle: false,  ECC: false,  classes: (),  bins:0,  crochets:false,  centre: true,  colonnes-vide: (),  cases-vide: (),  diagramme: "",  bar: (),  lqbar:(),  moustaches:(),  lqbox:(),  circ:(:), bande:(),  histo:(),  FCC:false,  multi:(),  labels:(),  print:false,  ListeCouleurs:auto,)`

// Fait l'étude statistique et présente les résultats, soit sous forme de tableau avec possibilité d'afficher les `effectifs`, `fréquences` ("f" pour fractions, "d" pour décimales, "t" pour les trois, true ou autre pour %), `angles` pour les diagrammes (semi)-circulaires, `ECC`, `FCC`, `classes` (automatiques si `bins` > 0) et leurs `centres`, et les `diagrammes` : si "hbar" ou "bar" ou "circ" ou "semicirc" ou "box" ou "bande" ou "histo" ou une combinaison dans `diagramme` avec des paramétrages : `ListeCouleurs` (petroff10 par défaut) ... Si `multi` != (), possibilité d'afficher un diagramme en barres (h ou v) ou des boites à moustaches avec une option `print` pour avoir des tilings 
///```example
// #stat(
//   classes: (150, 160, 170, 200),
//   effectifs: (3, 4, 5),
//   frequences: "f",
// )
///``` 
///```example
// #stat(sondage: ("Handball","Basket","Football","Handball","Ping-pong","Basket","Ping-pong","Ping-pong"),diagramme: "bar",cbar:(size:(8.2,4)))
///``` 
///```example
// #stat(valeurs:("Grippe","Angine","Allergies"),multi:((25,12,10),(10,10,17),(2,8,28),),diagramme: "bar",labels:("Mars","Avril","Mai",),tableau: false)
///``` 
// -> content
#let stat(
  // Modalités du caractère `numérique` -> array
  valeurs:(),
  // Effectifs de chaque valeur -> array
  effectifs: (),
  // Type de caractère -> boolean
  qualitatif: true,
  // Affichage des totaux dans les tableaux -> boolean
  totaux: false,
  // Affichage d'un tableau -> boolean
  tableau: true,
  // Couleur de la première ligne et colonne du tableau -> color
  couleur-tableau: luma(85%),
  // Inset du tableau -> length
  inset: 5pt,
  // Nom des données pour la case hg du tableau (et certains graphiques) -> content
  Nom-donnee: [],
  // Nom des effectifs pour la ligne concernée (et certains graphiques) -> content
  Nom-effectifs: [Effectifs],
  // Nombre de décimales des arrondis -> int
  décimales: 0,
  // false/true pour %, "f" pour fraction, "d" pour décimaux, "t" pour tout ou "v" pour une ligne vide -> boolean | str
  frequences: true,
  // Toutes les valeurs une à une pour un sondage -> array
  sondage: (),
  // Si true, toutes les lignes sauf la première sont vides -> boolean
  vide: false,
  // false/true ou "v" pour une ligne vide -> boolean | str
  angle: false,
  // false/true ou "v" pour une ligne vide -> boolean | str
  ECC: false,
  // Bornes des classes dans le cas d'un caractère continu, longueur = longueur (+1) -> array
  classes: (),
  // Dans le cas d'un sondage, si bins > 0, alors bins classes sont formées automatiquement -> int
  bins:0,
  // Dans le cas des classes, affichage par défaut a <= ... < b, si crochets:true, [a ; b[ -> boolean
  crochets:false,
  // false/true ou "v" pour une ligne vide -> boolean | str
  centre: true,
  // Pour vider les colonnes correspondantes de toutes leurs valeurs -> array
  colonnes-vide: (),
  // Pour vider une liste de cases, numérotation dans la partie blanche, ligne par ligne -> array
  cases-vide: (),
  // "hbar" ou "bar" ou "circ" ou "semicirc" ou "box" ou "bande" ou "histo" ou une combinaison -> str
  diagramme: "",
  // paramètres à passer au canvas de bar ou hbar -> array
  bar: (),
  // paramètres à passer à barchart ou columnchart de cetz -> array
  cbar:(),
  // paramètres à passer au canvas des boites à moustaches -> array
  moustaches:(),
  // paramètres à passer à boxwhiskers de cetz -> array
  cmoustaches:(),
  // paramètres à passer à la fonction camembert -> dictionnary
  circ:(:),
  // paramètres à passer à la fonction bandes -> array
  bande:(),
  // paramètres à passer à la fonction histogramme -> array
  histo:(),
  // false/true ou "v" pour une ligne vide -> boolean | str
  FCC:false,
  // si multi != (), possibilité d'afficher un diagramme en barres (h ou v) ou des boites à moustaches -> array
  multi:(),
  // Labels des différentes séries dans le cas de `multi` -> array
  labels:(),
  // false/true pour l'affichage de tilings à la place des couleurs dans les graphiques -> boolean
  print:false,
  // Liste des couleurs pour les graphiques -> auto | color | array
  ListeCouleurs:auto,
) = {
  let tableau = if multi != () {false} else {tableau}

  let classes = if sondage != () and bins != 0 {
    let min = calc.min(..sondage)
    let max = calc.max(..sondage) + 1
    range(bins + 1).map(x=>min+x*(max - min)/bins)
    
  } else {classes}
  
  let effectifs = if sondage != () and classes != () {
    let effectifs = ()
    for i in range(classes.len() - 1) {
      let k = 0
      for j in sondage {if classes.at(i) <= j and j < classes.at(i +1) {k +=1}}
      effectifs.push(k)
  }
  effectifs
} else {effectifs}

  let (valeurs, effectifs) = if sondage != () and classes == () {
    (sondage.dedup().sorted().map(str), for i in sondage.dedup().sorted() { (sondage.filter(x => x == i).len(),) },)
  } else {(valeurs,effectifs)}

  let ListeCouleurs = if print {hachures} else if type(ListeCouleurs) == color {(ListeCouleurs,)*effectifs.len()} else if ListeCouleurs != auto {ListeCouleurs} else {petroff10}

  show math.lt.eq: math.lt.eq.slant
  show regex("\d+(\.\d+)?"): it => it.text.replace(".", ",")

  let valeurs = if classes != () and classes.len() == effectifs.len() {
    for i in range(classes.len()) {
      if i < classes.len() - 1 {if crochets {($ lr(\[classes.at(#i) thin \; classes.at(#(i + 1))\[) $,)} else {($ classes.at(#i) <= ... < classes.at(#(i + 1)) $,)}
      } else {if crochets {($ lr(\[classes.at(#i) thin \; +oo\[) $,)} else {($ classes.at(#i) <= ... $,)} }
    }
  } else if classes != () and classes.len() == effectifs.len() + 1 {
    for i in range(classes.len() - 1) {
      if crochets {($ lr(\[classes.at(#i) thin \; classes.at(#(i + 1))\[) $,)} else {($ classes.at(#i) <= ... < classes.at(#(i + 1)) $,)}
    }
  } else if classes != () {
    panic(
      "La liste des extrémités des classes doit être de longueur égale à celle des effectifs (ou + 1)",
    )
  } else { valeurs }

  let centres = if classes != () and classes.len() == effectifs.len() + 1 {
    for i in range(classes.len() - 1) {
      ((classes.at(i) + classes.at((i + 1))) / 2,)
    }
  }

  let data = if multi == () {valeurs.zip(effectifs)} else {valeurs.zip(..multi)}

  let sommeprod = if not qualitatif {
    for i in range(effectifs.len()) { (valeurs.at(i) * effectifs.at(i),) }
  } else if centres != none {
    for i in range(effectifs.len()) { (centres.at(i) * effectifs.at(i),) }
  }

  let moyenne = if sommeprod != none { sommeprod.sum() / effectifs.sum() }

  let classes-centres = if centre == "v" or vide {
    ([Centres des classes],) + ([],) * valeurs.len() + if totaux { ([],) }
  } else if centre and centres != none {
    ([Centres des classes],) + centres.map(x => $ #x $) + if totaux { (table.cell(fill:gray)[],) }
  }

  let first = (
    (Nom-donnee,)
      + if qualitatif { valeurs } else { valeurs.map(x => $ #x $) }
      + if totaux { ([Total],) }
  )
  let Effectifs = if vide {
    ([#Nom-effectifs],) + ([],) * valeurs.len() + if totaux { ([],) }
  } else {
    (
      ([#Nom-effectifs],)
        + effectifs.map(x => $ #x $)
        + if totaux { ($ effectifs.sum() $,) }
    )
  }

  let freq = (
    ([Fréquences (en %)],)
      + effectifs.map(x => {
        $ #calc.round(x / effectifs.sum() * 100, digits: décimales) $
      })
      + if totaux { ($ 100 $,) }
  )
  let freqfrac = (
    ([Fréquences],)
      + effectifs.map(x => $ simpli(#x, effectifs.sum()) $)
      + if totaux { ($ 1 $,) }
  )
  let freqdeci = (
    ([Fréquences],)
      + effectifs.map(x => {
        $ #calc.round(x / effectifs.sum(), digits: décimales + 2) $
      })
      + if totaux { ($ 1 $,) }
  )
  let freqtout = (
    ([Fréquences],)
      + effectifs.map(x => {
        $
          #x / effectifs.sum() #if calc.round(x / effectifs.sum(), digits: 6) == calc.round(x / effectifs.sum(), digits: 2) { $=$ } else { $approx$ } #calc.round(x / effectifs.sum(), digits: décimales + 2) #if calc.round(x / effectifs.sum(), digits: 6) == calc.round(x / effectifs.sum(), digits: 2) { $=$ } else { $approx$ } #calc.round(x / effectifs.sum() * 100, digits: décimales) thin %
        $
      })
      + if totaux { ($ 1 $,) }
  )
  let fréq = if frequences == "v" or vide {
    ([Fréquences],) + ([],) * valeurs.len() + if totaux { ([],) }
  } else if frequences == false {} else if frequences == "f" {
    freqfrac
  } else if frequences == "d" { freqdeci } else if frequences == "t" {
    freqtout
  } else { freq }

  let angles = if angle == "v" or vide {
    ([Angles (en °)],) + ([],) * valeurs.len() + if totaux { ([],) }
  } else if angle == "s" {
    (
      ([Angles (en °)],)
        + effectifs.map(x => {
          $ #calc.round(x / effectifs.sum() * 180, digits: décimales) $
        })
        + if totaux { ($ 180 $,) }
    )
  } else if angle == false {} else {
    (
      ([Angles (en °)],)
        + effectifs.map(x => {
          $ #calc.round(x / effectifs.sum() * 360, digits: décimales) $
        })
        + if totaux { ($ 360 $,) }
    )
  }

  let effcc = if ECC == "v" or vide or ECC == false {} else {
    for i in range(effectifs.len()) { (effectifs.slice(0, i + 1).sum(),) }
  }
  
  let ecc = if ECC == "v" or vide {
    ([E.C.C.],) + ([],) * valeurs.len() + if totaux { ([],) }
  } else if ECC == false or ECC == () or ECC == none {} else {
    (
      ([E.C.C.],)
        + effcc.map(x => $ #x $)
        + if totaux { ($ effectifs.sum() $,) }
    )
  }

  let freqcc = if FCC == "v" or vide or FCC == false {} else {
    for i in range(effectifs.len()) { (calc.round(effectifs.slice(0, i + 1).sum()/effectifs.sum(),digits: décimales +2),) }
  }

  let fcc = if FCC == "v" or vide {
    ([F.C.C.],) + ([],) * valeurs.len() + if totaux { ([],) }
  } else if FCC == false or FCC == () or FCC == none {} else {
    (
      ([F.C.C.],)
        + freqcc.map(x => $ #x $)
        + if totaux { ($ 1 $,) }
    )
  }

  let affiche = {
    (
      if classes-centres != none { (classes-centres,) }
        + if Effectifs != none { (Effectifs,) }
        + if fréq != none { (fréq,) }
        + if angles != none { (angles,) }
        + if ecc != none { (ecc,) }
        + if fcc != none { (fcc,) }
    )
  }
  if colonnes-vide != () {
    for i in colonnes-vide {
      for j in range(affiche.len()) { affiche.at(j).at(i) = ([#h(2em)],) }
    }
  }

  affiche = affiche.flatten()

  if cases-vide != () { for i in cases-vide { affiche.at(i) = [#h(2em)] } }

  let liste-complete = if not qualitatif {
    for i in range(effectifs.len()) {
      (valeurs.at(i),) * effectifs.at(i)
    }
  } else if centres != none {
    for i in range(effectifs.len()) {
      (centres.at(i),) * effectifs.at(i)
    }
  }

  if tableau {
    table(
      columns: valeurs.len() + 1 + if totaux { 1 },
      fill: (x, y) => if x == 0 or y == 0 { couleur-tableau },
      inset: inset,
      align: (x, y) => if x == 0 { left + horizon } else { center + horizon },
      ..first,
      ..affiche
    )
  }
  // [\ ]
  if "hbar" in diagramme {
    h(1fr)
    box(cetz.canvas({
        cetz.draw.set-style(
          barchart: (
            bar-width: if multi != () {auto} else if not qualitatif {.2} else {.7},
            stroke:if not qualitatif {.1pt},
            grid:(stroke:black+.8pt),
          ),
          axes:(stroke:1pt,mark:(end:">>",fill:black),tick-limit:12,auto-tick-count:if not qualitatif {valeurs.len()} else {6}), 
          
        // grid:(dash:"loosely-dotted"), 
        // tick-step:none
        
      )
        bar
        chart.barchart(
          data,
          value-key:if multi == () {1} else {range(multi.len()).map(x=>x+1)},
          size: (6,4),
          mode:if multi == () {"basic"} else {"clustered"},
          labels:if multi != () {labels},
          bar-style: cetz.palette.new(colors: ListeCouleurs),
          // bar-width:if multi == () {.25} else {auto},
          ..cbar
        )
      })
    )
  } else if "bar" in diagramme {
    h(1fr)
        box(cetz.canvas({
        cetz.draw.set-style(
          columnchart: (
            bar-width: if multi != () {auto} else if not qualitatif {.2} else {.7},
            stroke:if not qualitatif {.1pt},
            grid:(stroke:black+.7pt),
          ),
          axes:(stroke:1pt,mark:(end:">>",fill:black),tick-limit:12,auto-tick-count:if not qualitatif {valeurs.len()} else {6}), 
      )
      bar
        chart.columnchart(
          data,
          // x-key:0,
          value-key:if multi == () {1} else {range(multi.len()).map(x=>x+1)},
          size: (7,4),
          mode:if multi == () {"basic"} else {"clustered"},
          labels:if multi != () {labels},
          bar-style: cetz.palette.new(colors: ListeCouleurs),
          ..cbar
        )
      })
    )
  }

  if "box" in diagramme {
    h(1fr)
    let boxi = if multi != () {for i in range(multi.len()) {((..caracteristiques(valeurs: multi.at(i).sorted(),effectifs:(1,)*multi.at(i).len(),).cetzboxplot,x:i),)}} else if not qualitatif {(..caracteristiques(valeurs: valeurs,effectifs: effectifs,).cetzboxplot,x:1)} else if centres != none {(..caracteristiques(valeurs: centres,effectifs: effectifs,).cetzboxplot,x:1)}

    box(cetz.canvas({
    import cetz.draw:*
    // import cetz-plot:*
    set-style(line:(stroke:black,fill:white))
    moustaches
    plot.plot(
      y-tick-step: 2,size:(if multi != () {multi.len()} else {1},3),axis-style: "scientific-auto",x-tick-step: none, y-grid: true, x-label: none,y-label:none, plot.add-boxwhisker(boxi, style:(stroke:black,fill:none), ..cmoustaches)
    )
  }))
  }

    if "circ" in diagramme {if not qualitatif {valeurs= valeurs.map(str); circ = (..circ, legende:"",)}
    h(1fr)
    camembert(
      valeurs:valeurs,   
      effectifs: effectifs,
      semi: if "semi" in diagramme {true} else {false},
      couleurs:ListeCouleurs,
      ..circ
  )   
  }

  if "bande" in diagramme {if not qualitatif {valeurs= valeurs.map(str); circ = (..circ, legende:"",)}
    h(1fr)
    bandes(valeurs:valeurs, effectifs:effectifs, couleurs:ListeCouleurs, ..bande)
    h(1fr)
  }

  if "histo" in diagramme and classes != () {
    h(1fr)
    histogramme(classes:classes, effectifs:effectifs,px: PGCD(..classes)/2,uaire: PGCD(..effectifs),s:.5,ListeCouleurs:ListeCouleurs,..histo,)
  }

  if diagramme != "" { h(1fr) }
}

#let help(..args) = {
  import "@preview/tidy:0.4.3"
  let namespace = (".": (read.with("/Exemples/premanuel-fr.typ")))
  tidy.generate-help(namespace: namespace, package-name: "stats-fr")(..args)
}