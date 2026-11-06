#import "@preview/fletcher:0.5.8": diagram, edge, node, shapes.ellipse,shapes.pill

// Fonction auxiliaire pour aplatir la séquence d'éléments mathématiques
#let flatten-seq(it) = {
  if type(it) == content and it.has("children") {
    it.children.map(flatten-seq).flatten()
  } else {
    (it,)
  }
}

// // Pas mis en fonction
// node((1.5,-1.6),$#box($ + $,fill:white, radius: .5em)$,stroke:none,layer: 0.5,),
// edge((3,0),"uu",(1.5,-2),"d",(2,-1),(2,0), "<|-",mark-scale: .75,$#box($=$,fill:white,inset:1pt)$,label-pos: .3, label-sep: (-6pt),layer: .5),
// edge((3,0),"uu",(1.5,-2),"d",(1,-1),(1,0), mark-scale: .75),

// // Croix en gamma
// edge((2.2,0.2),(rel:(.6,.7)),(rel:(-.7,0)),(rel:(.7,-.7)),"-}>",corner-radius: (10pt),snap-to: (none,none),stroke:luma(40%),),

// Dessine un *tableau* de proportionnalité en générant des nœuds Fletcher nommés à partir d'une equation, par défaut, tous les nœuds d'une même colonne ont la même largeur et ceux d'une même ligne ont la même hauteur, de plus, tous les nœuds sont collés, fonctionne comme diagram en mode mathématique. 
//
// -> content
#let math-grid(
  // équation mathématiques qui sera traduite en tableau -> math.equation
  eq,
  // mode équation pour avoir l'alternance des alignements -> boolean
  equation:false,
  // booléen pour indiquer que les cases d'une colonne doivent être de même largeur -> boolean
  equal-columns: true,
  // booléen pour indiquer que les cases d'une ligne doivent être de même largeur -> boolean
  equal-rows: true,
  // caractéristiques des traits du tableau -> none | length | color | stroke
  node-stroke: 1pt,
  // forme des nœuds -> function
  node-shape: rect,
  // inset (h,v) des nœuds en nombre de points -> array
  inset: (0, -2),
  // espacement des cases du tableau -> length
  spacing: 0cm,
  // échelle des marques des flèches -> int | float
  mark-scale: 1.2,
  // booléen pour mettre le tableau vertical -> boolean
  flip: false,
  // coefficient de proportionnalité (de la 1ère ligne vers la 2nde) -> none | content
  coef: none,
  // coefficient réciproque (de la 2ème ligne vers la 1ère) -> none | content
  coef-recip: none,
  // arguments facultatifs à passer à la fonction `edge` pour le coefficient -> dictionary
  coef-args: (),
  // arguments facultatifs à passer à la fonction `edge` pour le coefficient -> dictionary
  coef-recip-args: (),
  // booléen pour indiquer de dessiner les nœuds vides -> boolean
  no-empty-node:true,
  // largeur minimale (utile pour les colonnes vides) -> length
  min-width:0pt,
  // hauteur minimale (utile pour les lignes vides) -> length
  min-height:0pt,
  // arguments facultatifs à passer à la fonction `diagram` de Fletcher -> arguments
  ..args,
) = context {
  let node-stroke = if equation {none} else {node-stroke}
  let no-empty-node = if equation {false} else {no-empty-node}
  show math.equation:math.display
  assert(
    type(eq) == content and eq.func() == math.equation,
    message: "Le premier argument doit être une équation mathématique $...$",
  )

  let children = flatten-seq(eq.body)

  // 1. Découpage de l'équation en grille (lignes / colonnes)
  let matrix = ()
  let current-row = ()
  let current-cell = ()

  for child in children {
    let f-name = repr(child.func())
    if f-name in ("linebreak", "std.linebreak") {
      current-row.push(current-cell)
      current-cell = ()
      matrix.push(current-row)
      current-row = ()
    } else if f-name in ("align-point", "alignment") {
      current-row.push(current-cell)
      current-cell = ()
    } else {
      current-cell.push(child)
    }
  }
  current-row.push(current-cell)
  matrix.push(current-row)

  // 2. Séparation du contenu visuel et des métadonnées (node, edge...)
  let cell-matrix = matrix.map(row => {
    row.map(cell-items => {
      let content-items = ()
      let meta-items = ()
      for item in cell-items {
        if item.func() == metadata {
          meta-items.push(item)
        } else {
          content-items.push(item)
        }
      }
      (
        content: if content-items.len() > 0 { content-items.join() } else { none },
        meta: meta-items,
      )
    })
  })

  let num-rows = cell-matrix.len()
  let num-cols = calc.max(..cell-matrix.map(r => r.len()))

  // 3. Mesure des dimensions maximales par colonne visuelle et par ligne visuelle
  let num-vis-cols = if flip { num-rows } else { num-cols }
  let num-vis-rows = if flip { num-cols } else { num-rows }

  let vis-col-widths = (min-width,) * num-vis-cols
  let vis-row-heights = (min-height,) * num-vis-rows

  for (y, row) in cell-matrix.enumerate() {
    for (x, contentval) in row.enumerate() {
      if contentval.content != none {
        let size = measure(box(
          inset: (
            x: if contentval.content != [ ] { inset.at(0) * 1pt } else { 0pt },
            y: if contentval.content != [ ] { inset.at(1) * 1pt } else { 0pt },
          ),
          $ contentval.content $,
        ))

        let vis-x = if flip { y } else { x }
        let vis-y = if flip { x } else { y }

        vis-col-widths.at(vis-x) = calc.max(vis-col-widths.at(vis-x), size.width)
        vis-row-heights.at(vis-y) = calc.max(vis-row-heights.at(vis-y), size.height)
      }
    }
  }

  // 4. Génération des nœuds Fletcher natifs avec noms d'ancres
  let generated-nodes = ()
  for (y, row) in cell-matrix.enumerate() {
    for (x, contentval) in row.enumerate() {
      if contentval.content != none or (contentval.content == none and not no-empty-node) {
        let vis-x = if flip { y } else { x }
        let vis-y = if flip { x } else { y }

        let w = if equal-columns { vis-col-widths.at(vis-x) } else { auto }
        let h = if equal-rows { vis-row-heights.at(vis-y) } else { auto }

        // Le nom conserve les coordonnées d'origine (x = colonne math, y = ligne math)
        let node-name = str(x) + "-" + str(y)

        generated-nodes.push(
          node(
            (vis-x, vis-y),
            box(
              width: w,
              height: h,
              align(if not equation {center + horizon} else if calc.even(vis-x) == true {left} else {right} , $contentval.content$),
            ),
            name: node-name,
            stroke: if contentval.content == [ ] {none} else {node-stroke}
          )
        )

        for meta in contentval.meta {
          generated-nodes.push(meta)
        }
      }
    }
  }

  // 5. Transmet tous les nœuds générés + les edges fournies en argument à diagram()
  diagram(
    ..generated-nodes,
    ..args.pos(),
    node-stroke: node-stroke,
    node-shape: node-shape,
    spacing: spacing,
    mark-scale: mark-scale,
    ..args.named(),
    if coef != none {
      if flip {
        edge((0, num-cols), "r", "-}>", bend: -40deg, shift: -3pt, label: coef, label-sep: (-1pt),..coef-args)
      } else {
        edge((num-cols, 0), "d", "-}>", bend: 60deg, shift: -3pt, label: coef, label-sep: (-1pt),..coef-args)
      }
    },
    if coef-recip != none {
      if flip {
        edge((1, -1), "l", "-}>", bend: -40deg, shift: -3pt, label: coef-recip, label-sep: (-1pt),..coef-recip-args)
      } else {
        edge((-1, 1), "u", "-}>", bend: 60deg, shift: -3pt, label: coef-recip, label-sep: (-1pt),..coef-recip-args)
      }
    },
  )
}

// Fonction pour montrer qu'une colonne est la somme (défaut) ou la différence de 2 autres, au-dessus de la première ligne, 3 modes sont proposés
// -> content
#let lin-up(
  // numéro de la première colonne de départ -> int
  a,
  // numéro de la seconde colonne de départ -> int
  b,
  // numéro de la colonne d'arrivée -> int
  c,
  // signe de l'opération -> content | str
  sign:$ + $,
  // couleur des flèches -> auto | color
  color:auto,
  // couleur du texte -> auto | color
  text-color:auto, 
  // 3 modes sont proposés -> int
  mode:1,
  // arguments supplémentaires pour les edges -> dictionary
  ..args,
) = if mode == 1 {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node((0,-1),hide([a]),stroke:none),
  edge((c,0),"uu",((a+b)/2,-2),"d",(b,-1),(b,0), "<{-",mark-scale: .75,sign,label-pos: .3, label-sep: (-10pt),corner-radius: 0pt,stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label),..args,),
  edge((a,0), (a,-1),((a+b)/2,-1),corner-radius: 0pt,stroke:color,..args,),
)} else {(
  node((0,-1),hide([a]),stroke:none),
  edge((c,0),(c,-1),"<{-",mark-scale: .75,sign,label-pos: 1, label-anchor: "south", label-sep: 0pt,  stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label),label-fill: white,layer:1.5,..args,),
  edge((c,-1),(b,-1),(b,0), corner-radius: 0pt,stroke:color,..args,),
  edge((a,0), (a,-1),(c,-1),corner-radius: 0pt,stroke:color,..args,),
)}
} else if mode == 2 {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node(((a+b)/2,-1.1),$#box(text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color}, sign,.8em), height:.8em, inset:1pt, fill:white, stroke:.4pt+if color != auto {color}, radius:0.5em)$, stroke:none, layer: 2),
  edge((c,0),"uu",((a+b)/2,-2),"d",(b,-1),(b,0), "<{-",mark-scale: .75, 
  $#box($ = $, fill:white, inset:2pt, stroke:.4pt+if color != auto {color}, radius:0.5em)$, label-pos: .3, label-sep: (-3.2pt), layer: .5,stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label,.8em),..args,),
  edge((c,0),"uu",((a+b)/2,-2),"d",(a,-1),(a,0), stroke:color, mark-scale: .75,..args,),
)} else {(
  node((c,-1),$ #box(text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color}, sign,.8em), height:.8em, inset:1pt, fill:white, stroke:.4pt+if color != auto {color}, radius:0.5em) $, stroke:none, layer: 2,outset: -6pt,),
  edge((c,0),(c,-1),"<{-",mark-scale: .75, layer: .5,stroke:color,..args,),
  edge((c,-1),(b,-1),(b,0), layer: .5,stroke:color,..args,),
  edge((c,-1), (a,-1),(a,0), stroke:color,..args,),
)}
} else {
  (
  node((c/2+a/4+b/4,-1.35),text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color},sign),stroke:none),
  edge((c,0),"u," + if c > b {"l" * (c - b)} else {"r" * (b - c)} + ",d", "<{-",mark-scale: .75,..args,stroke:color),
  edge((c,0),"u," + if c > a {"l" * (c - a)} else {"r" * (a - c)} + ",d", ..args,stroke:color)
)
}

// Fonction pour montrer qu'une colonne est la somme (défaut) ou la différence de 2 autres, en-dessous de la seconde ligne, 3 modes sont proposés -> content
#let lin-down(
  // numéro de la première colonne de départ -> int
  a,
  // numéro de la seconde colonne de départ -> int
  b,
  // numéro de la colonne d'arrivée -> int
  c,
  // signe de l'opération -> content | str
  sign:$ + $,
  // couleur des flèches -> auto | color
  color:auto,
  // couleur du texte -> auto | color
  text-color:auto, 
  // 3 modes sont proposés -> int
  mode:1,
  // nombre de lignes -> int
  n:2,
  // arguments supplémentaires pour les edges -> dictionary
  ..args,
) = if mode == 1 {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node((0,n),hide([a]),stroke:none),
  edge((c,n - 1),"dd",((a+b)/2,n + 1),"u",(b,n),(b,n - 1), "<{-",mark-scale: .75,sign,label-pos: .3, label-sep: (-10pt), label-side: left, corner-radius: 0pt,stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label),..args,),
  edge((a,n - 1), (a,n),((a+b)/2,n),corner-radius: 0pt,stroke:color,..args,),
)} else {(
  node((0,n),hide([a]),stroke:none),
  edge((c,n - 1),(c,n),"<{-",mark-scale: .75,sign, label-pos: 1, label-anchor: "north", label-sep: 0pt,  stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label),label-fill: white,layer:1.5),
  edge((c,n),(b,n),(b,n - 1), corner-radius: 0pt,stroke:color,..args,),
  edge((a,n - 1), (a,n),(c,n),corner-radius: 0pt,stroke:color,..args,),
)}
} else if mode == 2 {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node(((a+b)/2,n - 0.04),$#box(text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color}, sign,.8em), height:.8em, inset:1pt, fill:white, stroke:.4pt+if color != auto {color}, radius:0.5em)$, stroke:none, layer: 2),
  edge((c,n - 1),"dd",((a+b)/2,n + 1),"u",(b,n),(b,n - 1), "<{-",mark-scale: .75, 
  $#box($ = $, fill:white, inset:2pt, stroke:.4pt+if color != auto {color}, radius:0.5em)$, label-pos: .3, label-sep: (-3.2pt), layer: .5,stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label,.8em),..args,),
  edge((c,n - 1),"dd",((a+b)/2,n + 1),"u",(a,n),(a,n - 1), stroke:color,..args,),
)} else {(
  node((c,n),$ #box(text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color}, sign,.8em), height:.8em, inset:1pt, fill:white, stroke:.4pt+if color != auto {color}, radius:0.5em) $, stroke:none, layer: 2,outset: -6pt,),
  edge((c,n - 1),(c,n),"<{-",mark-scale: .75, layer: .5,stroke:color,..args,),
  edge((c,n),(b,n),(b,n - 1), layer: .5,stroke:color,..args,),
  edge((c,n), (a,n),(a,n - 1), stroke:color,..args,),
)}
} else {(
  node((c/2+a/4+b/4,n+.35),text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color},sign),stroke:none),
  edge((c,n - 1),"d," + if c > b {"l" * (c - b)} else {"r" * (b - c)} + ",u", "<{-",mark-scale: .75,..args,stroke:color),
  edge((c,n - 1),"d," + if c > a {"l" * (c - a)} else {"r" * (a - c)} + ",u", ..args,stroke:color))
}

// Fonction pour afficher les croix d'un produit en croix entre deux colonnes 
// -> content
#let x-product(
  // couleur des flèches -> color
  color:luma(40%),
  // écart avec les centres des nœuds -> float
  sep:.2,
  // décalage des extrémités gauches des flèches si besoin -> float
  left-shift:0,
  // décalage des extrémités droites des flèches si besoin -> float
  right-shift:0,
  // pour l'utilisation dans les tableaux verticaux -> boolean
  flip:false,
  // arguments contenant nécessairement le numéro de la première colonne et accessoirement celui d'une seconde colonne (sinon +1), ainsi que des arguments transmis à la fonction edge de Fletcher -> int | arguments
  ..a,
) = {
  let (a,b,c) = if a.pos().len() == 1 {(a.at(0),a.at(0)+1,a.named())} else {(a.at(0),a.at(1),a.named())}
  let sign = if b > a {1} else {-1}
  let p1 = if flip {(to:(sep,a+sep*sign),rel:(0,left-shift))} else {(to:(a+sep*sign,sep),rel:(left-shift,0))}
  let p2 = if flip {(to:(1-sep,b - sep*sign),rel:(0,right-shift))} else {(to:(b - sep*sign, 1-sep),rel:(right-shift,0))}
  let p3 = if flip {(to:(1-sep,a+sep*sign),rel:(0,left-shift))} else {(to:(a+sep*sign,1-sep),rel:(left-shift,0))}
  let p4 = if flip {(to:(sep,b - sep*sign),rel:(0,right-shift))} else {(to:(b - sep*sign, sep),rel:(right-shift,0))}
  (
    edge(p1, p2,"<{-}>",mark-scale: .7, layer: .5,stroke:color,snap-to: (none,none),..c),
    edge(p3, p4,"<{-}>",mark-scale: .7, layer: .5,stroke:color,snap-to: (none,none),..c)
  )
}

// Trace une flèche d'opération directe d'une colonne vers une autre au-dessus ou en dessous du tableau.
// - `row` : indice de la ligne (0 ou 1)
// - `f` : indice de la colonne de départ (ex: 1)
// - `t` : indice de la colonne d'arrivée (ex: 3)
// - `label` : libellé de l'opération (ex: $+ 7$ ou $+ "Col 2"$)
// et accessoirement :
// - `pos` : "top" (au-dessus) ou "bottom" (en dessous)
// - `bend` : courbure de l'arc
// - `flip` : pour indiquer que le tableau est vertical
// + d'autres arguments pour la commande edge de Fletcher
// -> content
#let col-op(
  // indice de la ligne (ou colonne si flip:true) de départ -> int
  row,
  // indice de la colonne (ou ligne si flip:true) de départ -> int
  f,
  // indice de la colonne (ou ligne si flip:true) d'arrivée -> int
  t,
  // texte/opération (ex: $+ 12$ ou $+ "col 2"$) -> content | str
  label,
  // position : "top" (au-dessus) ou "bottom" (en dessous), défaut : auto -> auto | str
  pos: auto,     
  // courbure de l'arc -> auto | angle
  bend: auto,
  // pour l'utilisation dans les tableaux verticaux -> boolean 
  flip:false,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..args,
) = {
  let r = if row != auto { row } else if pos == "bottom" { 1 } else { 0 }
  let pos = if pos != auto { pos } else if row == 0 { "top" } else { "bottom" }
  let default-bend = if pos == "top" { 60deg  } else { -60deg  }
  let b = if bend == auto { default-bend * (t - f) / calc.abs(t - f) } else { bend * (t - f) / calc.abs(t - f) }
  let dir = if flip {if row == 0 {".west"} else {".east"}} else {if row == 0 {".north"} else {".south"}}

  edge(eval("<" + str(f) + "-" + str(row) + dir + ">"), eval("<" + str(t) + "-" + str(row) + dir + ">"), "-}>", bend: b * if flip {(-1)} else {1}, label: label, label-size: .8em, ..args)
}

// Double flèche montrant la combinaison (addition/soustraction) de deux colonnes vers une 3e. 
// -> content
#let col-combine(
  // indice de la ligne (ou colonne si flip:true) de départ -> int
  row,
  // indice de la 1ère colonne de départ -> int
  col1,
  // Indice de la 2ème colonne de départ -> int
  col2,
  // uindice de la colonne d'arrivée -> int
  to,
  // texte/opération (ex: $+ 12$ ou $+ "col 2"$) -> content | str
  label: $+$,
  // position : "top" (au-dessus) ou "bottom" (en dessous), défaut : auto -> auto | str
  pos: auto,
  // courbure de l'arc -> auto | angle
  bend: auto,
  // pour l'utilisation dans les tableaux verticaux -> boolean 
  flip:false,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..args,
) = {
  let pos = if pos != auto { pos } else if row == 0 { "top" } else { "bottom" }
  let default-bend = if pos == "top" { 60deg } else { -60deg }
  let b = if bend == auto { default-bend * (to - col1) / calc.abs(to - col1) } else { bend * (to - col1) / calc.abs(to - col1) }
  let dir = if flip {if row == 0 {".west"} else {".east"}} else {if row == 0 {".north"} else {".south"}}

  (
    edge(eval("<" + str(col1) + "-" + str(row) + dir + ">"), eval("<" + str(to) + "-" + str(row) + dir + ">"), "-}>", bend: b * if flip {(-1)} else {1}, label: label,label-side:center,label-size: .8em,..args),
    edge(eval("<" + str(col2) + "-" + str(row) + dir + ">"), eval("<" + str(to) + "-" + str(row) + dir + ">"), "-}>", bend: b * if flip {(-1)} else {1},..args),
  )
}

/// Flèche à droite allant vers le bas avec un label -> content
#let rdarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("d"*n,"-}>",label:$label$,bend:90deg,shift:-2pt,..a)

/// Flèche à droite allant vers le haut avec un label -> content
#let ruarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne montées -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("u"*n,"-}>",label:$label$,bend:-90deg,shift:2pt,..a)

/// Flèche à gauche allant vers le bas avec un label -> content
#let ldarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("d"*n,"-}>",label:$label$,bend:-90deg,shift:2pt,..a)

/// Flèche à gauche allant vers le haut avec un label -> content
#let luarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne montées -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("u"*n,"-}>",label:$label$,bend:90deg,shift:-2pt,..a)

/// Flèche en haut allant vers la droite avec un label -> content
#let urarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("r"*n,"-}>",label:$label$, bend:60deg,label-sep:0pt, shift:7.5pt,..a)

/// Flèche en haut allant vers la gauche avec un label -> content
#let ularrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("l"*n,"-}>",label:$label$, bend:-60deg,label-sep:0pt, shift:-7pt,..a)

/// Flèche en bas allant vers la droite avec un label -> content
#let drarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("r"*n,"-}>",label:$label$, bend:-60deg,label-sep:0pt, shift:-7pt,..a)

/// Flèche en bas allant vers la gauche avec un label -> content
#let dlarrow(
  /// étiquette de la flèche -> math.content
  label,
  /// le nombre de ligne descendues -> int
  n:1,
  /// arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("l"*n,"-}>",label:$label$, bend:60deg,label-sep:0pt, shift:7pt,..a)