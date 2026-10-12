#import "@preview/fletcher:0.5.8": diagram, edge, node, shapes.ellipse,shapes.pill

// Fonction auxiliaire pour aplatir la séquence d'éléments mathématiques.
// Gère aussi le cas où `it` est une matrice construite avec mat(...) :
// on la remet à plat en réutilisant un vrai point d'alignement (extrait
// une fois depuis un fragment "&") comme séparateur de cellules, et
// linebreak() comme séparateur de lignes -- ce qui produit exactement
// le même format que celui d'une séquence écrite "a & b \ c & d",
// donc sans rien changer au code qui consomme flatten-seq ensuite. -> array
#let flatten-seq(
  // l'expression mathématiques ou la matrice à transformer pour math-grid -> math.mat | math.equation
  it
) = {
  if type(it) == content and it.func() == math.mat {
    let alignpoint = {
      let b = ($&$).body
      if repr(b.func()) == "align-point" {
        b
      } else {
        b.children.find(c => repr(c.func()) == "align-point")
      }
    }
    let out = ()
    for (i, row) in it.rows.enumerate() {
      if i > 0 { out.push(linebreak()) }
      for (j, cell) in row.enumerate() {
        if j > 0 { out.push(alignpoint) }
        out += flatten-seq(cell)
      }
    }
    out
  } else if type(it) == content and it.has("children") {
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
  // "hauteur" des traits du 1er mode -> length
  height:7.24pt,
  // arguments supplémentaires pour les edges -> dictionary
  ..args,
) = if mode == 1 {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node((0,n),box(height:height,width: 1pt),stroke:none),
  edge((c,n - 1),"dd",((a+b)/2,n + 1),"u",(b,n),(b,n - 1), marks:"<{-",mark-scale: .75,text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color},sign),label-pos: .3, label-sep: (-10pt), label-side: left, corner-radius: 0pt,stroke:color ,..args,),
  edge((a,n - 1), (a,n),((a+b)/2,n),corner-radius: 0pt,stroke:color,..args,),
)} else {(
  node((0,n),box(height:height,width: 1pt),stroke:none),
  edge((c,n - 1),(c,n),marks:"<{-",mark-scale: .75,text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color},sign), label-pos: 1, label-anchor: "north", label-sep: 0pt,  stroke:color,label-fill: white,layer:1.5,..args,),
  edge((c,n),(b,n),(b,n - 1), corner-radius: 0pt,stroke:color,..args,),
  edge((a,n - 1), (a,n),(c,n),corner-radius: 0pt,stroke:color,..args,),
)}
} else if mode == 2 {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node(((a+b)/2,n - 0.04),$#box(text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color}, sign,.8em), height:.8em, inset:1pt, fill:white, stroke:.4pt+if color != auto {color}, radius:0.5em)$, stroke:none, layer: 2),
  edge((c,n - 1),"dd",((a+b)/2,n + 1),"u",(b,n),(b,n - 1), marks:"<{-",mark-scale: .75, 
  $#box($ = $, fill:white, inset:2pt, stroke:.4pt+if color != auto {color}, radius:0.5em)$, label-pos: .3, label-sep: (-3.2pt), layer: .5,stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label,.8em),..args,),
  edge((c,n - 1),"dd",((a+b)/2,n + 1),"u",(a,n),(a,n - 1), stroke:color,..args,),
)} else {(
  node((c,n),$ #box(text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color}, sign,.8em), height:.8em, inset:1pt, fill:white, stroke:.4pt+if color != auto {color}, radius:0.5em) $, stroke:none, layer: 2,outset: -6pt,),
  edge((c,n - 1),(c,n),marks:"<{-",mark-scale: .75, layer: .5,stroke:color,..args,),
  edge((c,n),(b,n),(b,n - 1), layer: .5,stroke:color,..args,),
  edge((c,n), (a,n),(a,n - 1), stroke:color,..args,),
)}
} else {(
  node((c/2+a/4+b/4,n+.35),text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color},sign),stroke:none),
  edge((c,n - 1),"d," + if c > b {"l" * (c - b)} else {"r" * (b - c)} + ",u", marks:"<{-",mark-scale: .75,..args,stroke:color),
  edge((c,n - 1),"d," + if c > a {"l" * (c - a)} else {"r" * (a - c)} + ",u", ..args,stroke:color))
}

// Fonction pour faire des opérations sur les lignes d'une matrice -> content
#let row-op(
  // numéro de la première ligne de départ -> int
  a,
  // numéro de la seconde ligne de départ -> none | int
  b:0,
  // numéro de la ligne de d'arrivée -> int
  c,
  // label de l'opération -> content | str
  label,
  // couleur des flèches -> auto | color
  color:auto,
  // couleur du texte -> auto | color
  text-color:auto, 
  // nombre de colonnes -> int
  n:2,
  // "largeur" des traits -> length
  width:3em,
  // arguments supplémentaires pour les edges -> dictionary
  ..args,
) = {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node((n,0),box(width:width),stroke:none),
  edge((n - 1,c),(n,c),(n,a),(n -1,a),marks:"<{-",mark-scale: .75,text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color},label),label-pos: .5, label-side: if c> a {right} else {left}, corner-radius: 0pt,stroke:color,..args,),
  if b!=0 {edge((n - 1,b), (n,b),(n,a),corner-radius: 0pt,stroke:color,..args,)},
)} else {(
  node((n,0),box(width:width),stroke:none),
  edge((n - 1,c),(n,c),(n,a),(n - 1,a), marks:"<{-",corner-radius: 0pt,mark-scale: .75,text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color},label), label-pos: .35, label-anchor: "west", label-sep: 0pt,  stroke:color,layer:1.5,..args,),
  if b!=0 {edge((n,c),(n,b),(n - 1,b), corner-radius: 0pt,stroke:color,..args,)},
  // edge((n - 1,a), (n,a),(n,c),corner-radius: 0pt,stroke:color,..args,),
)}
}

// Résolution d'un tracé stroke selon le format fourni (valeur, dictionnaire ou fonction)
#let resolve-cell-stroke(x, y, stroke-val) = {
  if stroke-val == none { return (top: none, bottom: none, left: none, right: none) }

  let base = stroke-val
  if type(stroke-val) == function {
    base = stroke-val(x, y)
  } else if type(stroke-val) == dictionary {
    let key-dash = str(x) + "-" + str(y)
    let key-comma = str(x) + "," + str(y)
    if key-dash in stroke-val {
      base = stroke-val.at(key-dash)
    } else if key-comma in stroke-val {
      base = stroke-val.at(key-comma)
    }
  }

  if base == none {
    return (top: none, bottom: none, left: none, right: none)
  }

  if type(base) == dictionary and ("top" in base or "bottom" in base or "left" in base or "right" in base or "x" in base or "y" in base) {
    let default-s = base.at("rest", default: none)
    let t = if "top" in base { base.top } else if "y" in base { base.y } else { default-s }
    let b = if "bottom" in base { base.bottom } else if "y" in base { base.y } else { default-s }
    let l = if "left" in base { base.left } else if "x" in base { base.x } else { default-s }
    let r = if "right" in base { base.right } else if "x" in base { base.x } else { default-s }

    return (
      top: if t != none { stroke(t) } else { none },
      bottom: if b != none { stroke(b) } else { none },
      left: if l != none { stroke(l) } else { none },
      right: if r != none { stroke(r) } else { none },
    )
  } else {
    let s = stroke(base)
    return (top: s, bottom: s, left: s, right: s)
  }
}

// Définit une cellule fusionnée ou personnalisée au sein de `math-grid`.
//
// Reçoit les arguments positionnels et nommés :
//   - *Positionnels* :
//     - `body` (content) : Le contenu à afficher dans la cellule.
//     - `colspan` (int, optionnel) : Nombre de colonnes occupées (si un seul entier est fourni).
//     - `rowspan` (int, optionnel) : Nombre de lignes occupées (si un second entier est fourni).
//     - `align` (alignment, optionnel) : Alignement spécifique du contenu dans le bloc.
//     - `size` (taille du texte, optionnel)
//   - *Nommés réservés* :
//     - `colspan` (int, défaut: 1) : Extension horizontale de la cellule.
//     - `rowspan` (int, défaut: 1) : Extension verticale de la cellule.
//     - `align` (alignment, défaut: auto) : Alignement interne du contenu (`left`, `center`, `right`, etc.).
//     - `size` (taille du texte, optionnel)
//   - *Nommés supplémentaires* (`..node-args`) :
//     - Tout autre argument nommé (ex: `stroke`, `fill`, `corner-radius`, `extrude`, `def-draw`, etc.)
//       sera transmis directement au nœud Fletcher (`node(...)`) sous-jacent.
// -> content + metadata
#let mblock(
  // arguments positionnels (body, colspan, rowspan, align, size) et nommés (colspan, rowspan, align, size, ..node-args) -> arguments
  ..args
) = {
  let pos = args.pos()
  let named = args.named()

  let colspan = named.at("colspan", default: 1)
  let rowspan = named.at("rowspan", default: 1)
  let align-val = named.at("align", default: auto)
  let size = named.at("size", default: 1em)

  // Nettoyage des arguments nommés réservés à mblock
  let node-args = named
  let _ = node-args.remove("colspan", default: none)
  let _ = node-args.remove("rowspan", default: none)
  let _ = node-args.remove("align", default: none)
  let _ = node-args.remove("size", default: none)

  let body = []
  let ints = ()

  for item in pos {
    if type(item) == length {
      size = item
    } else if type(item) == int {
      ints.push(item)
    } else if type(item) == alignment {
      align-val = item
    } else {
      body = item
    }
  }

  if ints.len() == 1 {
    colspan = ints.at(0)
  } else if ints.len() >= 2 {
    colspan = ints.at(0)
    rowspan = ints.at(1)
  }

  [#metadata((
    type: "mblock",
    colspan: colspan,
    rowspan: rowspan,
    align: align-val,
    node-args: node-args,
  ))#text(size, body)]
}

// Fonction auxiliare pour placer un contenu dans une boite sans prendre de place (avec alignement positionnel ou nommé) -> content
#let zero-box(
  // Contenu et alignement -> arguments
  ..args
) = context {
  let pos = args.pos()
  let named = args.named()
  let align-val = named.at("align", default: center+horizon)
  let body = []
  
  for item in pos {
    if type(item) == alignment {
      align-val = item
    } else {
      body = item
    }
  }
  let (width, height) = measure(body)
  place(align-val, box(width: width, height: height, body))
  // box(width: 0%, height: 0pt)
}

// Dessine un *tableau* de proportionnalité en générant des nœuds Fletcher nommés à partir d'une equation (contenant des alignements ou une matrice), par défaut, tous les nœuds d'une même colonne ont la même largeur et ceux d'une même ligne ont la même hauteur, de plus, tous les nœuds sont collés, fonctionne comme diagram en mode mathématique. 
//
// -> content
#let math-grid(
  // équation mathématique qui sera traduite en tableau -> math.equation
  eq,
  // mode équation pour avoir l'alternance des alignements, pas de traits etc -> boolean
  equation: false,
  // mode matrix pour avoir les parenthèses ou crochets, pas de traits etc 
  // si true, des parenthèses par défaut, sinon le ou les (noms des) symbole(s) peuvent être donnés comme dans la fonction mat de typst.
  // -> boolean | str
  matrix-mode:false,
  // espacement des parenthèses ou crochets etc -> length
  matrix-sep:0pt,
  // Dessine des lignes d'augmentation dans une matrice, comme dans la fonction mat de typst. -> none | int | array | dictionary
  augment:none,
  // Pour ajouter une/des lignes au-dessus -> none | content
  first-line:0,
  // Pour ajouter une/des colonnes à gauche -> none | content
  first-column:0,
  // force le mode d'affichage mathématique grand format (display) -> boolean
  display: true,
  // booléen pour indiquer que toutes les colonnes doivent être de même largeur -> boolean
  equal-columns: false,
  // booléen pour indiquer que toutes les lignes doivent être de même hauteur -> boolean
  equal-rows: false,
  // caractéristiques des traits du tableau -> none | length | color | stroke
  node-stroke: 1pt,
  // booléen pour indiquer s'il faut tracer le cadre extérieur du tableau -> boolean
  cadre: true,
  // forme des nœuds -> function
  node-shape: rect,
  // alignement à l'intérieur des noeuds -> auto | alignment
  node-align:auto,
  // inset (h,v) des nœuds en nombre de points -> array
  inset: (4, 4),
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
  // arguments facultatifs à passer à la fonction `edge` pour le coefficient réciproque -> dictionary
  coef-recip-args: (),
  // booléen pour indiquer de dessiner les nœuds vides -> boolean
  no-empty-node: true,
  // Pour donner une couleur aux nœuds vides -> boolean | color
  fill-empty: false,
  // largeur minimale (utile pour les colonnes vides) -> length
  min-width: 0pt,
  // hauteur minimale (utile pour les lignes vides) -> length
  min-height: 0pt,
  // dictionnaire "x-y": color ou fonction (x, y) => color pour colorer des cellules -> dictionary | function
  fill-map: (:),
  // applique la couleur d'en-tête sur la première ligne (y = 0) -> boolean
  header-row: false,
  // pour appliquer un alignement différent aux titres (x = 0 ou y = 0) -> none | alignment
  header-align:none,
  // applique la couleur d'en-tête sur la première colonne (x = 0) -> boolean
  header-col: false,
  // couleur appliquée aux en-têtes -> color
  header-fill: rgb("d0d0d0"),
  // évite le doublement de l'épaisseur des bordures internes quand spacing = 0cm -> boolean
  clean-grid: true,
  // arguments facultatifs à passer à la fonction `diagram` de Fletcher -> arguments
  ..args,
) = context {
  let node-stroke = if (equation or matrix-mode != false) and node-stroke == 1pt { none } else { node-stroke }
  if matrix-mode != false {
  if type(augment) == int {node-stroke = (x,y) => if x == augment {(left:.05em)}}
  if type(augment) == array {node-stroke = (x,y) => if x in augment {(left:.05em)}}
  if type(augment) == dictionary {
    let stroke = if "stroke" in augment {augment.stroke} else {.05em}
    node-stroke = (x,y) => if "vline" in augment {if type(augment.vline) == array {if x in augment.vline {(left:stroke)}} else if type(augment.vline) == int {if x == augment.vline {(left:stroke)}}} + if "hline" in augment {if type(augment.hline) == array {if y in augment.hline {(top:stroke)}} else if type(augment.hline) == int {if y == augment.hline {(top:stroke)}}}
  }
  }
  let no-empty-node = if equation { false } else { no-empty-node }
  show math.equation: if display { math.display } else { eq => eq }
  assert(
    type(eq) == content and eq.func() == math.equation,
    message: "Le premier argument doit être une équation mathématique $...$",
  )

  let children = flatten-seq(eq.body)
  children.insert(0,[ ])

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

  let cell-matrix = matrix.map(row => {
    row.map(cell-items => {
      let content-items = ()
      let meta-items = ()
      let colspan = 1
      let rowspan = 1
      let cell-align = node-align
      let node-args = (:)

      for item in cell-items {
        if item.func() == metadata and type(item.value) == dictionary and item.value.at("type", default: none) == "mblock" {
          colspan = item.value.colspan
          rowspan = item.value.rowspan
          cell-align = item.value.align
          node-args = item.value.at("node-args", default: (:))
        } else if item.func() == metadata {
          meta-items.push(item)
        } else {
          content-items.push(item)
        }
      }
      (
        content: if content-items.len() > 0 { content-items.join() } else { none },
        meta: meta-items,
        colspan: colspan,
        rowspan: rowspan,
        align: cell-align,
        node-args: node-args,
      )
    })
  })

  let num-rows = cell-matrix.len()
  let num-cols = calc.max(..cell-matrix.map(r => r.len()))

  let num-vis-cols = if flip { num-rows } else { num-cols }
  let num-vis-rows = if flip { num-cols } else { num-rows }

  let covered = range(num-vis-rows).map(_ => range(num-vis-cols).map(_ => false))

  for (y, row) in cell-matrix.enumerate() {
    for (x, cellval) in row.enumerate() {
      let vis-x = if flip { y } else { x }
      let vis-y = if flip { x } else { y }
      let vis-cs = if flip { cellval.rowspan } else { cellval.colspan }
      let vis-rs = if flip { cellval.colspan } else { cellval.rowspan }

      if vis-cs > 1 or vis-rs > 1 {
        for dy in range(vis-rs) {
          for dx in range(vis-cs) {
            if dx != 0 or dy != 0 {
              let cy = vis-y + dy
              let cx = vis-x + dx
              if cy < num-vis-rows and cx < num-vis-cols {
                covered.at(cy).at(cx) = true
              }
            }
          }
        }
      }
    }
  }

  let vis-col-widths = (min-width,) * num-vis-cols
  let vis-row-heights = (min-height,) * num-vis-rows
  let vis-strokes = range(num-vis-rows).map(_ => range(num-vis-cols).map(_ => (top: none, bottom: none, left: none, right: none)))

  let strut-size = measure(box(inset: (x: inset.at(0) * 1pt, y: inset.at(1) * 1pt), $ 0 $,))

  for (y, row) in cell-matrix.enumerate() {
    for (x, contentval) in row.enumerate() {
      let vis-x = if flip { y } else { x }
      let vis-y = if flip { x } else { y }
      let vis-cs = if flip { contentval.rowspan } else { contentval.colspan }
      let vis-rs = if flip { contentval.colspan } else { contentval.rowspan }

      let cell-will-render = contentval.content != none or not no-empty-node
      let raw-cell-stroke = if contentval.content == [ ] {
        none // espace tapé explicitement : case volontairement vide, jamais de bordure
      } else if not cell-will-render {
        none // case vide qui ne sera pas dessinée (no-empty-node) : pas de bordure fantôme
      } else {
        node-stroke
      }
      vis-strokes.at(vis-y).at(vis-x) = resolve-cell-stroke(vis-x, vis-y, raw-cell-stroke)

      if contentval.content != none and contentval.content != [ ] {
        let size = measure(box(
          inset: (x: inset.at(0) * 1pt, y: inset.at(1) * 1pt),
          $ contentval.content $,
        ))

        if vis-cs == 1 {
          vis-col-widths.at(vis-x) = calc.max(vis-col-widths.at(vis-x), size.width)
        }
        if vis-rs == 1 {
          vis-row-heights.at(vis-y) = calc.max(vis-row-heights.at(vis-y), size.height)
        }
      } else {
        vis-col-widths.at(vis-x) = calc.max(vis-col-widths.at(vis-x), strut-size.width)
        vis-row-heights.at(vis-y) = calc.max(vis-row-heights.at(vis-y), strut-size.height)
      }
    }
  }

  // Synchronisation des bordures des cases couvertes par une fusion (mblock) :
  // une case fusionnée ne doit pas hériter du contenu (souvent vide) de la case
  // "absorbée" pour ses bords bas/droite, mais du trait de la case d'origine.
  for (y, row) in cell-matrix.enumerate() {
    for (x, contentval) in row.enumerate() {
      let vis-x = if flip { y } else { x }
      let vis-y = if flip { x } else { y }
      let vis-cs = if flip { contentval.rowspan } else { contentval.colspan }
      let vis-rs = if flip { contentval.colspan } else { contentval.rowspan }

      if vis-cs > 1 or vis-rs > 1 {
        let origin-stroke = vis-strokes.at(vis-y).at(vis-x)
        for dy in range(vis-rs) {
          for dx in range(vis-cs) {
            if dx != 0 or dy != 0 {
              let cy = vis-y + dy
              let cx = vis-x + dx
              if cy < num-vis-rows and cx < num-vis-cols {
                vis-strokes.at(cy).at(cx) = origin-stroke
              }
            }
          }
        }
      }
    }
  }

  for (y, row) in cell-matrix.enumerate() {
    for (x, contentval) in row.enumerate() {
      let vis-x = if flip { y } else { x }
      let vis-y = if flip { x } else { y }
      let vis-cs = if flip { contentval.rowspan } else { contentval.colspan }
      let vis-rs = if flip { contentval.colspan } else { contentval.rowspan }

      if contentval.content != none and (vis-cs > 1 or vis-rs > 1) {
        let size = measure(box(
          inset: (
            x: inset.at(0) * 1pt,
            y: inset.at(1) * 1pt,
          ),
          $ contentval.content $,
        ))

        let current-w = range(vis-cs).map(k => vis-col-widths.at(vis-x + k)).sum() + spacing * (vis-cs - 1)
        if size.width > current-w {
          let add-w = (size.width - current-w) / vis-cs
          for k in range(vis-cs) { vis-col-widths.at(vis-x + k) += add-w }
        }

        let current-h = range(vis-rs).map(k => vis-row-heights.at(vis-y + k)).sum() + spacing * (vis-rs - 1)
        if size.height > current-h {
          let add-h = (size.height - current-h) / vis-rs
          for k in range(vis-rs) { vis-row-heights.at(vis-y + k) += add-h }
        }
      }
    }
  }

  if equal-columns {
    let max-w = calc.max(..vis-col-widths)
    vis-col-widths = (max-w,) * num-vis-cols
  }
  if equal-rows {
    let max-h = calc.max(..vis-row-heights)
    vis-row-heights = (max-h,) * num-vis-rows
  }

  let generated-nodes = ()
  for (y, row) in cell-matrix.enumerate() {
  for (x, contentval) in row.enumerate() {
    let vis-x = if flip { y } else { x }
    let vis-y = if flip { x } else { y }
    let node-name = label(if contentval.colspan > 1 or contentval.rowspan > 1 {"e"} + str(x) + "-" + str(y))

    if covered.at(vis-y).at(vis-x) {
      generated-nodes.push(
        node(
          (vis-x, vis-y),
          box(
            width: vis-col-widths.at(vis-x),
            height: vis-row-heights.at(vis-y),
          ),
          name: node-name,
          inset: 0pt,
          stroke: none,
          fill: none,
        )
      )
      for meta in contentval.meta {
        generated-nodes.push(meta)
      }
      continue
    }

    if contentval.content != none or (contentval.content == none and (not no-empty-node or fill-empty != false)) {
      let vis-cs = if flip { contentval.rowspan } else { contentval.colspan }
      let vis-rs = if flip { contentval.colspan } else { contentval.rowspan }

      let w = range(vis-cs).map(k => vis-col-widths.at(vis-x + k)).sum() + spacing * (vis-cs - 1)
      let h = range(vis-rs).map(k => vis-row-heights.at(vis-y + k)).sum() + spacing * (vis-rs - 1)

      let cell-fill = if (contentval.content == none or contentval.content == [ ]) and fill-empty != false {fill-empty} else {none}
      if (header-row and y == 0) or (header-col and x == 0) { cell-fill = header-fill ; if header-align != none {contentval.align = header-align} }
      if type(fill-map) == function {
        let custom-fill = fill-map(x, y)
        if custom-fill != none { cell-fill = custom-fill }
      } else if type(fill-map) == dictionary {
        let key-dash = str(x) + "-" + str(y)
        let key-comma = str(x) + "," + str(y)
        if key-dash in fill-map { cell-fill = fill-map.at(key-dash) }
        else if key-comma in fill-map { cell-fill = fill-map.at(key-comma) }
      }

      let cell-strokes-origin = vis-strokes.at(vis-y).at(vis-x)
      let cell-strokes-end = vis-strokes.at(vis-y + vis-rs - 1).at(vis-x + vis-cs - 1)

      let is-top-outer = (vis-y == 0)
      let is-bottom-outer = (vis-y + vis-rs - 1 == num-vis-rows - 1)
      let is-left-outer = (vis-x == 0)
      let is-right-outer = (vis-x + vis-cs - 1 == num-vis-cols - 1)
      let has-fill = cell-fill != none

      let top-neighbor-has-bottom = if not is-top-outer {
        range(vis-cs).any(k => vis-strokes.at(vis-y - 1).at(vis-x + k).bottom != none)
      } else { false }

      let left-neighbor-has-right = if not is-left-outer {
        range(vis-rs).any(k => vis-strokes.at(vis-y + k).at(vis-x - 1).right != none)
      } else { false }

      let final-top = if is-top-outer {
        if cadre { cell-strokes-origin.top } else { none }
      } else if cell-strokes-origin.top != none and (not top-neighbor-has-bottom or has-fill or not clean-grid or spacing > 0cm) {
        cell-strokes-origin.top
      } else { none }

      let final-left = if is-left-outer {
        if cadre { cell-strokes-origin.left } else { none }
      } else if cell-strokes-origin.left != none and (not left-neighbor-has-right or has-fill or not clean-grid or spacing > 0cm) {
        cell-strokes-origin.left
      } else { none }

      let final-bottom = if is-bottom-outer and not cadre { none } else { cell-strokes-end.bottom }
      let final-right = if is-right-outer and not cadre { none } else { cell-strokes-end.right }

      let cell-stroke = (
        top: final-top,
        bottom: final-bottom,
        left: final-left,
        right: final-right,
      )

      let effective-align = if contentval.align != auto {
        contentval.align
      } else if not equation {
        center + horizon
      } else if vis-cs > 1 {
        center + horizon
      } else if calc.even(vis-x) {
        left  + horizon
      } else {
        right + horizon
      }

      let x1 = vis-x
      let y1 = vis-y
      let x2 = vis-x + vis-cs - 1
      let y2 = vis-y + vis-rs - 1

      let origin-coords = ()
      let node-coords = if vis-cs > 1 or vis-rs > 1 {
        (enclose:((x1, y1), (x2, y2)))
        origin-coords = (x1, y1)
      } else {
        ((x1, y1),)
      }

      let cell-body = if contentval.content in ([ \u{21D4} ],[ \u{21D2} ], [ \u{27F9} ], [ \u{27F8} ], [ \u{27FA} ], [ \u{21D0} ], [ \u{21CE} ], [ \u{2903} ], [ \u{21CF} ], [ \u{21CD} ], [ \u{2902} ], [ \u{21CE} ], [ \u{2904} ], [ \u{2235} ], [ \u{2234} ]) {$ contentval.content $} else {$contentval.content$}
      // if equation and type(contentval.content) == str {
      //   $contentval.content$
      // } else if equation {
      //   $contentval.content$
      // } else {
      //   $contentval.content$
      // }

      let is-merge = vis-cs > 1 or vis-rs > 1

      if origin-coords != () {
        generated-nodes.push(
        node(
          origin-coords,
          box(
            width: vis-col-widths.at(vis-x),
            height: vis-row-heights.at(vis-y),
          ),
          name: label(str(x) + "-" + str(y)),
          inset: 0pt,
          stroke: none,
          fill: none,
        )
      )
    }

      // Pour une case fusionnée (enclose), NE PAS laisser fletcher mesurer
      // une box explicitement dimensionnée à (w,h) comme label normal :
      // comme la position d'un noeud enclose est `auto`, fletcher pré-calcule
      // (avant même de résoudre l'enclose) un centre provisoire au milieu des
      // coordonnées englobées, et utilise la taille mesurée du label à cet
      // endroit pour son calcul de grille élastique -- ce qui gonfle
      // artificiellement les colonnes/lignes centrales dès que colspan ou
      // rowspan dépasse 2. On enveloppe donc la box dans `place()`, qui a
      // une empreinte de mesure nulle (comme zero-box ci-dessus) : fletcher
      // déduit alors la taille de la fusion des cases-ancres (origin-coords
      // / cases couvertes) déjà correctement positionnées, et la box ne
      // sert plus qu'à l'affichage final (fond + bordures par côté), une
      // fois la position/taille réelle résolue.
      let cell-content = if is-merge {zero-box(effective-align,cell-body)} else {align(effective-align, cell-body)} 
      
      let visual-box = box(
        width: w,
        height: h,
        fill: cell-fill,
        stroke: if not no-empty-node {node-stroke} else {cell-stroke},
        cell-content,
        inset:(x:inset.at(0)*1pt / if equation {2} else {1},y:inset.at(1)*1pt),
      )
      generated-nodes.push(
        if is-merge {
          node(
            ..node-coords,
            place(center+horizon, visual-box),
            name: node-name,
            inset: 0pt,
            ..contentval.node-args,
          )
        } else {
          node(
            ..node-coords,
            visual-box,
            name: node-name,
            inset: 0pt,
            ..contentval.node-args,
          )
        }
      )

      for meta in contentval.meta {
        generated-nodes.push(meta)
      }
    }
  }
}

  diagram(
    ..generated-nodes,
    ..args.pos(),
    node-stroke: none,
    node-shape: node-shape,
    spacing: spacing,
    mark-scale: mark-scale,
    ..args.named(),
    if coef != none {
      if flip {
        edge((0, num-cols), "r", marks:"-}>", bend: -40deg, shift: -3pt, label: coef, label-sep: (-1pt),..coef-args)
      } else {
        edge((num-cols, 0), "d", marks:"-}>", bend: 60deg, shift: -3pt, label: coef, label-sep: (-1pt),..coef-args)
      }
    },
    if matrix-mode == true or matrix-mode == "paren" or matrix-mode == "(" or matrix-mode == "()"  {
        import "@preview/fletcher:0.5.8":shapes.paren
        node(enclose: ((first-column,first-line),(first-column,num-rows - 1)),shape:paren.with(dir:left,sep:matrix-sep,),inset:0pt)
        node(enclose: ((num-cols - 1,first-line),(num-cols - 1,num-rows - 1)),shape:paren.with(dir:right,sep:matrix-sep,),inset:0pt)
      } else if matrix-mode == "bracket" or matrix-mode == "[" or matrix-mode == "[]" {
        import "@preview/fletcher:0.5.8":shapes.bracket
        node(enclose: ((first-column,first-line),(first-column,num-rows - 1)),shape:bracket.with(dir:left,sep:matrix-sep,),inset:0pt)
        node(enclose: ((num-cols -1,first-line),(num-cols - 1,num-rows - 1)),shape:bracket.with(dir:right,sep:matrix-sep,),inset:0pt)
      } else if matrix-mode == "{" or matrix-mode == "{}" {
        import "@preview/fletcher:0.5.8":shapes.brace
        node(enclose: ((first-column,first-line),(first-column,num-rows - 1)),shape:brace.with(dir:left,sep:matrix-sep,),inset:0pt)
        node(enclose: ((num-cols -1,first-line),(num-cols - 1,num-rows - 1)),shape:brace.with(dir:right,sep:matrix-sep,),inset:0pt)
      } else if matrix-mode == "det" or matrix-mode == "|" {
        import "@preview/fletcher:0.5.8":shapes.stretched-glyph
        node(enclose: ((first-column,first-line),(first-column,num-rows - 1)),shape:stretched-glyph.with(glyph:$|$,dir:left,sep:matrix-sep,),inset:0pt)
        node(enclose: ((num-cols -1,first-line),(num-cols - 1,num-rows - 1)),shape:stretched-glyph.with(glyph:$|$,dir:right,sep:matrix-sep,),inset:0pt)
      } else if matrix-mode == "||" {
        import "@preview/fletcher:0.5.8":shapes.stretched-glyph
        node(enclose: ((first-column,first-line),(first-column,num-rows - 1)),shape:stretched-glyph.with(glyph:$||$,dir:left,sep:matrix-sep,),inset:0pt)
        node(enclose: ((num-cols -1,first-line),(num-cols - 1,num-rows - 1)),shape:stretched-glyph.with(glyph:$||$,dir:right,sep:matrix-sep,),inset:0pt)
      } else if matrix-mode != false and matrix-mode != "" {
        import "@preview/fletcher:0.5.8":shapes.stretched-glyph
        node(enclose: ((first-column,first-line),(first-column,num-rows - 1)),shape:stretched-glyph.with(glyph:eval(matrix-mode + ".l",mode: "math"),dir:left,sep:matrix-sep,),inset:0pt)
        node(enclose: ((num-cols -1,first-line),(num-cols - 1,num-rows - 1)),shape:stretched-glyph.with(glyph:eval(matrix-mode + ".r",mode: "math"),dir:right,sep:matrix-sep,),inset:0pt)
      },
    if coef-recip != none {
      if flip {
        edge((1, -1), "l", marks:"-}>", bend: -40deg, shift: -3pt, label: coef-recip, label-sep: (-1pt),..coef-recip-args)
      } else {
        edge((-1, 1), "u", marks:"-}>", bend: 60deg, shift: -3pt, label: coef-recip, label-sep: (-1pt),..coef-recip-args)
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
  // "hauteur" des traits du 1er mode -> length
  height:7.24pt,
  // arguments supplémentaires pour les edges -> dictionary
  ..args,
) = if mode == 1 {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node((0,-1),box(height: height,width:1pt),stroke:none),
  edge((c,0),"uu",((a+b)/2,-2),"d",(b,-1),(b,0), marks:"<{-",mark-scale: .75,sign,label-pos: .3, label-sep: (-10pt),corner-radius: 0pt,stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label),..args,),
  edge((a,0), (a,-1),((a+b)/2,-1),corner-radius: 0pt,stroke:color,..args,),
)} else {(
  node((0,-1),box(height: height,width:1pt),stroke:none),
  edge((c,0),(c,-1),marks:"<{-",mark-scale: .75,sign,label-pos: 1, label-anchor: "south", label-sep: 0pt,  stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label),label-fill: white,layer:1.5,..args,),
  edge((c,-1),(b,-1),(b,0), corner-radius: 0pt,stroke:color,..args,),
  edge((a,0), (a,-1),(c,-1),corner-radius: 0pt,stroke:color,..args,),
)}
} else if mode == 2 {
  if not (a < c and c < b) and not (b < c and c < a) {(
  node(((a+b)/2,-1.1),$#box(text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color}, sign,.8em), height:.8em, inset:1pt, fill:white, stroke:.4pt+if color != auto {color}, radius:0.5em)$, stroke:none, layer: 2),
  edge((c,0),"uu",((a+b)/2,-2),"d",(b,-1),(b,0), marks:"<{-",mark-scale: .75, 
  $#box($ = $, fill:white, inset:2pt, stroke:.4pt+if color != auto {color}, radius:0.5em)$, label-pos: .3, label-sep: (-3.2pt), layer: .5,stroke:color,label-wrapper: it => text(if text-color == auto and color == auto {text.fill} else if text-color == auto {color} else {text-color},it.label,.8em),..args,),
  edge((c,0),"uu",((a+b)/2,-2),"d",(a,-1),(a,0), stroke:color, mark-scale: .75,..args,),
)} else {(
  node((c,-1),$ #box(text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color}, sign,.8em), height:.8em, inset:1pt, fill:white, stroke:.4pt+if color != auto {color}, radius:0.5em) $, stroke:none, layer: 2,outset: -6pt,),
  edge((c,0),(c,-1),marks:"<{-",mark-scale: .75, layer: .5,stroke:color,..args,),
  edge((c,-1),(b,-1),(b,0), layer: .5,stroke:color,..args,),
  edge((c,-1), (a,-1),(a,0), stroke:color,..args,),
)}
} else {
  (
  node((c/2+a/4+b/4,-1.35),text(if text-color == auto and color == auto {black} else if text-color == auto {color} else {text-color},sign),stroke:none),
  edge((c,0),"u," + if c > b {"l" * (c - b)} else {"r" * (b - c)} + ",d", marks:"<{-",mark-scale: .75,..args,stroke:color),
  edge((c,0),"u," + if c > a {"l" * (c - a)} else {"r" * (a - c)} + ",d", ..args,stroke:color)
)
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
    edge(p1, p2,marks:"<{-}>",mark-scale: .7, layer: .5,stroke:color,snap-to: (none,none),..c),
    edge(p3, p4,marks:"<{-}>",mark-scale: .7, layer: .5,stroke:color,snap-to: (none,none),..c)
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

  edge(eval("<" + str(f) + "-" + str(row) + dir + ">"), eval("<" + str(t) + "-" + str(row) + dir + ">"), marks:"-}>", bend: b * if flip {(-1)} else {1}, label: label, label-size: .8em, ..args)
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
    edge(eval("<" + str(col1) + "-" + str(row) + dir + ">"), eval("<" + str(to) + "-" + str(row) + dir + ">"), marks:"-}>", bend: b * if flip {(-1)} else {1}, label: label,label-side:center,label-size: .8em,..args),
    edge(eval("<" + str(col2) + "-" + str(row) + dir + ">"), eval("<" + str(to) + "-" + str(row) + dir + ">"), marks:"-}>", bend: b * if flip {(-1)} else {1},..args),
  )
}

// Flèche à droite allant vers le bas avec un label -> content
#let rdarrow(
  // étiquette de la flèche -> math.content
  label,
  // le nombre de ligne descendues -> int
  n:1,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("d"*n,marks:"-}>",label:$label$,bend:90deg,shift:-2pt,..a)

// Flèche à droite allant vers le haut avec un label -> content
#let ruarrow(
  // étiquette de la flèche -> math.content
  label,
  // le nombre de ligne montées -> int
  n:1,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("u"*n,marks:"-}>",label:$label$,bend:-90deg,shift:2pt,..a)

// Flèche à gauche allant vers le bas avec un label -> content
#let ldarrow(
  // étiquette de la flèche -> math.content
  label,
  // le nombre de ligne descendues -> int
  n:1,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("d"*n,marks:"-}>",label:$label$,bend:-90deg,shift:2pt,..a)

// Flèche à gauche allant vers le haut avec un label -> content
#let luarrow(
  // étiquette de la flèche -> math.content
  label,
  // le nombre de ligne montées -> int
  n:1,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("u"*n,marks:"-}>",label:$label$,bend:90deg,shift:-2pt,..a)

// Flèche en haut allant vers la droite avec un label -> content
#let urarrow(
  // étiquette de la flèche -> math.content
  label,
  // le nombre de ligne descendues -> int
  n:1,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("r"*n,marks:"-}>",label:$label$, bend:60deg,label-sep:0pt, shift:7.5pt,..a)

// Flèche en haut allant vers la gauche avec un label -> content
#let ularrow(
  // étiquette de la flèche -> math.content
  label,
  // le nombre de ligne descendues -> int
  n:1,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("l"*n,marks:"-}>",label:$label$, bend:-60deg,label-sep:0pt, shift:-7pt,..a)

// Flèche en bas allant vers la droite avec un label -> content
#let drarrow(
  // étiquette de la flèche -> math.content
  label,
  // le nombre de ligne descendues -> int
  n:1,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("r"*n,marks:"-}>",label:$label$, bend:-60deg,label-sep:0pt, shift:-7pt,..a)

// Flèche en bas allant vers la gauche avec un label -> content
#let dlarrow(
  // étiquette de la flèche -> math.content
  label,
  // le nombre de ligne descendues -> int
  n:1,
  // arguments transmis à la fonction edge de Fletcher -> arguments | dictionary
  ..a
) = edge("l"*n,marks:"-}>",label:$label$, bend:60deg,label-sep:0pt, shift:7pt,..a)