#import "@preview/cetz:0.5.2"
#set text(lang:"fre")

#let repere = {
  cetz.draw.line((0,0),(1,0),stroke:red,mark:(end:")>",fill:red,scale:.7))
  cetz.draw.content((1.1,0),text(red,$x$))
  cetz.draw.line((0,0),(0,1),stroke:green,mark:(end:")>",fill:green,scale:.7))
  cetz.draw.content((0,1.2,0),text(green,$y$))
  cetz.draw.line((0,0,0),(0,0,1),stroke:blue,mark:(end:")>",fill:blue,scale:.7))
  cetz.draw.content((0,0,1.2),text(blue,$z$))
}

// Fonction qui détermine les définitions pour cetz.canvas de `x`, `y` et `z` pour un angle de vue défini par l'élévation (θ) et l'azimut (φ). -> dictionary
#let thetaphi(
  // polar angle θ -> int | angle
  theta:70,
  // azimuthal angle φ -> int | angle
  phi:110
) = {
  let th = if type(theta) == int {theta*1deg} else {theta}
  let ph = if type(phi) == int {phi*1deg} else {phi}
  let vx = (
    calc.cos(ph), 
    -calc.cos(th) * calc.sin(ph) 
  )
  let vy = (
    calc.sin(ph), 
    calc.cos(th) * calc.cos(ph) 
  )
  let vz = (
    0.0, 
    calc.sin(th)
  )
  (x:vx,y:vy,z:vz)
}

// ---------------------------------------------------------
// 1. LOGIQUE DE SÉLECTION DES FACES (CHIRALITÉ DU DÉ)
// ---------------------------------------------------------

#let get-right-face(front, top, vue) = {
  let rules = (
    "1/2": 3, "1/3": 5, "1/5": 4, "1/4": 2,
    "2/1": 4, "2/4": 6, "2/6": 3, "2/3": 1,
    "3/1": 2, "3/2": 6, "3/6": 5, "3/5": 1,
    "4/1": 5, "4/5": 6, "4/6": 2, "4/2": 1,
    "5/1": 3, "5/3": 6, "5/6": 4, "5/4": 1,
    "6/2": 4, "6/4": 5, "6/5": 3, "6/3": 2,
  )
  let r = rules.at(str(front) + "/" + str(top), default: 3)
  if vue == "D" { r } else { 7 - r } 
}

// ---------------------------------------------------------
// 2. DESSIN DES POINTS D'UNE FACE (PLAN 2D)
// ---------------------------------------------------------

#let draw-dots(val, dot-color) = {
  import cetz.draw: circle
  let r = 1/6
  let dot(x, y) = circle((x, y), radius: r, fill: dot-color, stroke: none)
  
  if val in (2, 4, 5, 6) {
    dot(0.5, 0.5)
    dot(-0.5, -0.5)
  }
  if val in (3, 4, 5, 6) {
    dot(-0.5, 0.5)
    dot(0.5, -0.5)
  }
  if val in (1, 3, 5) {
    dot(0, 0)
  }
  if val == 6 {
    dot(0,0.5)
    dot(0,-0.5)
  }
}

// ---------------------------------------------------------
// 3. DESSIN DU DÉ EN 3D NATIVE
// ---------------------------------------------------------

// Fonction utilisée pour dessiner le dé en 3D. -> function
#let draw-de-3d(
  // nombre de points sur la face de devant -> int 
  front: 1,
  // nombre de points sur la face du dessus -> int 
  top: 2,
  // Echelle du dessin -> int | float | ratio
  s: 1.0,
  // Couleur du dé, par défaut légèrement gris -> color
  color: rgb("d3d3d3"),
  // Couleur des points  -> color
  dot-color: black,
  // Vue "D" pour doite ou "G" pour gauche  -> str 
  vue: "D",
  // Position de l'origine du dé  -> array
  origin: (0, 0, 0), // Coordonnées 3D natives
  /// Opacité du dé -> ratio
  opacity:100%,
) = {
  import cetz.draw: * // group, translate, scale as cetz-scale, rect, on-xy, on-xz, on-yz
  top = if top == front {if top + 1 == 7 {1} else {top+1}} else {top}

  let right = get-right-face(front, top, vue)
  let x-scale = if vue == "D" { 1 } else { -1 }

  group({
    // On se positionne dans l'espace 3D
    translate(origin)
    
    // Le dé d'origine est défini de -1 à 1, d'où le facteur 0.5
    scale(x: x-scale * s * 0.5, y: s * 0.5, z: s * 0.5)

    // Style commun des faces (le rayon gère les coins arrondis "rounded corners")
    let poly-opts = (fill: color.transparentize(100% - opacity), stroke: .3pt + black, radius: 0.33)
    let poly-opts2 = (fill: color.transparentize(100% - opacity), stroke: .3pt + black.transparentize(100% - opacity*1.5), radius: 0.33)

    // ortho(sorted:false,{rotate(y:15deg,x:-7deg,z:5deg)
    // -- FACES ARRIÈRES (pour éviter de voir à travers les interstices des arrondis) --
    on-xy(z:-1, rect((-1, -1), (1, 1), ..poly-opts2)+if opacity < 100% {draw-dots(7-top,dot-color.transparentize(100% - opacity/1.5))})
    on-xz(y:-1, rect((-1, -1), (1, 1), ..poly-opts2)+if opacity < 100% {draw-dots(7-right,dot-color.transparentize(100% - opacity/1.5))})
    on-zy(x:-x-scale, rect((-1, -1), (1, 1), ..poly-opts2)+if opacity < 100% {draw-dots(7-front,dot-color.transparentize(100% - opacity/1.5))})

    // -- FACE DU DESSUS (plan XY décalé à z = 1) --
    on-xy(z:1, {
      rect((-1, -1), (1, 1), ..poly-opts)
      draw-dots(top, dot-color)
    })

    // -- FACE DE DROITE (plan XZ décalé à y = 1) --
    on-xz(y:1, {
      rect((-1, -1), (1, 1), ..poly-opts)
      draw-dots(right, dot-color)
    })

    // -- FACE DE DEVANT (plan YZ décalé à x = 1) --
    on-zy(x:x-scale, {
      rect((-1, -1), (1, 1), ..poly-opts)
      draw-dots(front, dot-color)
    })
  // })
  })
}

// #import "@preview/cetz:0.5.2"

// Contournement du bug amont (cetz-package/cetz) : transform-rotate-aer()
// appelle mul-mat()/mul4x4-vec3() definies plus bas dans matrix.typ, ce que
// Typst ne resout pas. Reimplementation identique, verifiee numeriquement.
// #let transform-rotate-aer(azimuth, elevation, roll: 0deg) = {
//   let rotate-z-up = cetz.matrix.transform-rotate-x(-90deg)
//   let rotate-azimuth = cetz.matrix.transform-rotate-z(-90deg - azimuth)
//   let (ax, ay, az) = (-calc.sin(azimuth), calc.cos(azimuth), 0)

//   let c = calc.cos(elevation)
//   let s = calc.sin(elevation)
//   let rotate-elevation = (
//     (ax*ax*(1-c)+c, ax*ay*(1-c)-az*s, ax*az*(1-c)+ay*s, 0),
//     (ay*ax*(1-c)+az*s, ay*ay*(1-c)+c, ay*az*(1-c)-ax*s, 0),
//     (az*ax*(1-c)-ay*s, az*ay*(1-c)+ax*s, az*az*(1-c)+c, 0),
//     (0, 0, 0, 1),
//   )
//   let base = cetz.matrix.mul-mat(rotate-z-up, rotate-azimuth, rotate-elevation)

//   if roll == 0deg {
//     base
//   } else {
//     let v = cetz.matrix.mul4x4-vec3(base, (1, 0, 0), w: 0)
//     let n = calc.sqrt(v.at(0)*v.at(0) + v.at(1)*v.at(1) + v.at(2)*v.at(2))
//     let (vx, vy, vz) = (v.at(0)/n, v.at(1)/n, v.at(2)/n)
//     let cr = calc.cos(roll)
//     let sr = calc.sin(roll)
//     let rotate-roll = (
//       (vx*vx*(1-cr)+cr, vx*vy*(1-cr)-vz*sr, vx*vz*(1-cr)+vy*sr, 0),
//       (vy*vx*(1-cr)+vz*sr, vy*vy*(1-cr)+cr, vy*vz*(1-cr)-vx*sr, 0),
//       (vz*vx*(1-cr)-vy*sr, vz*vy*(1-cr)+vx*sr, vz*vz*(1-cr)+cr, 0),
//       (0, 0, 0, 1),
//     )
//     cetz.matrix.mul-mat(rotate-roll, base)
//   }
// }

// Composant d'appel (gère la caméra et la projection orthographique)

// Fonction utilisée pour dessiner le dé en 3D. -> content | function
#let dice(
  // standalone:true si seul, false si déjà dans un canvas -> boolean 
  standalone: true,
  // nombre de points sur la face de devant -> int 
  front: 1,
  // nombre de points sur la face du dessus -> int 
  top: 2,
  // Echelle du dessin -> int | float | ratio
  s: 1.0,
  // Angle theta des coordonnées sphériques -> int | float 
  theta: 70,
  // Angle phi des coordonnées sphériques-> int | float
  phi: 110,
  // Vue "D" pour doite ou "G" pour gauche -> str
  vue: "D",
  // Couleur du dé, par défaut légèrement gris -> color
  color: rgb("d3d3d3"),
  // Couleur des points -> color
  dot-color: black,
  // Position de l'origine du dé -> array
  origin:(0,0,0),
  // Arguments supplémentaires pour la boîte
  box-args:(),
  /// Opacité du dé -> ratio
  opacity:100%,
) = {
// Calcul mathématique des projections des axes 3D sur l'écran 2D (comme TikZ tdplot)
  // let scale-factor = 0.5 * s
  let x-scale = if vue == "D" { 1 } else { -1 }

  let th = theta * 1deg
  let ph = phi * 1deg

  // Calcul des vecteurs unitaires projetés de l'espace 3D
  let vx = (
    calc.cos(ph)  * x-scale, 
    -calc.cos(th) * calc.sin(ph) 
  )
  let vy = (
    calc.sin(ph) * x-scale, 
    calc.cos(th) * calc.cos(ph) 
  )
  let vz = (
    0.0, 
    calc.sin(th)
  )

  let mat = (
    (      calc.cos(ph)  * x-scale,      calc.sin(ph) * x-scale,  0,           0),
    (-calc.cos(th) * calc.sin(ph) , calc.cos(th) * calc.cos(ph),  calc.sin(th),0),
    (0,0,1,0),
    (0,0,0,1)
  )

  if standalone {
    box(..box-args,cetz.canvas(
      // z:(-.5,-.5),
      x: vx,
      y: vy,
      z: vz,
      { 
    //   import cetz.matrix:mul-mat,transform-rotate-aer
    //       cetz.draw.set-ctx(ctx => {
    // let mat = transform-rotate-aer(th,ph)
    // ctx.transform = mat
    // return ctx
    // })
      // cetz.draw.transform(transform-rotate-aer(th,ph))
      draw-de-3d(front: front, top: top, s:s, vue: vue, color: color, dot-color: dot-color, opacity: opacity) }
    ))
  } else {
    // cetz.draw.group({
    cetz.draw.set-transform(mat)
    draw-de-3d(front: front, top: top, s:s, vue: vue, color: color, dot-color: dot-color, origin:origin, opacity: opacity)
  // })
  }
}

// ---------------------------------------------------------
// 4. TIRAGES ET LOBBY SÉCURISÉ (ALÉATOIRE)
// ---------------------------------------------------------

// Fonction pour faire du pseudo-aléatoire. -> array
#let pseudo-random(seed) = {
  let a = 1664525
  let c = 1013904223
  let m = 4294967296
  let next = calc.rem(a * seed + c, m)
  (next, next / m)
}

// Tirage aléatoire ou non de `n` dés. -> content
#let throws(
  // nombre de dés -> int 
  n,
  // liste des jets none par défaut sinon liste des couples (face avant, face du dessus),  -> none | array
  list: none,
  // graine du pseudo aléatoire  -> int
  seed: 42,
  // Dés présentés "collés"  -> boolean
  yams: false,
  // Avancement des dés dans la ligne si yams  -> int | float
  yams-h:.1,
  // Espacement horizontal des dés  -> length
  espace-h: 5mm,
  // facteur d'espacement  -> int | float | ratio
  s: 1.0,
  // Liste des couleurs des dés  -> array
  colors: (rgb("d3d3d3"),),
  // couleur des points -> color
  dot-color: black,
  // Angle theta des coordonnées sphériques -> int | float
  theta: 70,
  // Angle phi des coordonnées sphériques -> int | float
  phi: 110,
  // Vue "D" droite ou "G" gauche -> str
  vue: "D",
  // Arguments supplémentaires pour la boîte
  box-args:(),
  /// Opacité des dés -> ratio
  opacity:100%,
) = {
  let color-list = if type(colors) == array { colors } else { (colors,) }

  // Initialisation de l'accumulateur (la graine actuelle + la liste des résultats)
  let init-state = (seed: seed, list: ())
  
  // Utilisation de .fold() pour propager proprement l'état aléatoire d'un dé à l'autre
  let result = range(n).fold(init-state, (acc, i) => {
    let current-seed = acc.seed
    let front = 1
    let top = 2
    let next-seed = current-seed

    if list != none and list.len() > i {
      let thr = list.at(i)
      front = thr.at(0)
      top = thr.at(1)
    } else {
      let (s1, r1) = pseudo-random(current-seed)
      let (s2, r2) = pseudo-random(s1)
      next-seed = s2

      front = calc.floor(r1 * 6) + 1
      let top-faces = (
        (2,3,4,5), (1,3,4,6), (1,2,6,5), (1,5,6,2), (1,3,6,4), (2,4,5,3)
      ).at(front - 1)
      top = top-faces.at(calc.floor(r2 * 4))
    }
    
    let c = color-list.at(calc.rem(i, color-list.len()))
    let item = (front, top, c)
    
    // On renvoie le nouvel état (nouvelle graine calculée et liste mise à jour)
    (seed: next-seed, list: acc.list + (item,))
  })

  // On extrait la liste finale de dés générés
  let dices-data = if vue == "D" { result.list } else { result.list.rev() }

  // Préparation de la projection (inchangée)
  // let scale-factor = 0.5 * s
  let x-scale = if vue == "D" { 1 } else { -1 }
  let th = theta * 1deg
  let ph = phi * 1deg
  
  let vx = (
    calc.cos(ph) * x-scale, 
    -calc.cos(th) * calc.sin(ph) 
  )
  let vy = (
    calc.sin(ph) * x-scale, 
    calc.cos(th) * calc.cos(ph) 
  )
  let vz = (
    0.0, 
    calc.sin(th)
  )

  if yams {
    box(..box-args,cetz.canvas(
      x: vx,
      y: vy,
      z: vz,
      {
        import cetz.draw: group, translate
        for (i, data) in dices-data.enumerate() {
          let (f, t, c) = data
          // let dir = if vue == "D" { 1 } else { -1 }
          
          let ox = (i + 1)  * 1cm * s
          let oy = (i + 1)  * yams-h * 1cm * s
          
          group({
            translate((oy, ox))
            draw-de-3d(
              front: f,
              top: t,
              s: s,
              vue: vue,
              color: c,
              dot-color: dot-color,
              opacity: opacity
            )
          })
        }
      }
    ))
  } else {
    box(..box-args,stack(
      dir: if vue == "D" {ltr} else {rtl},
      spacing: espace-h,
      ..dices-data.map(data => dice(
        standalone: true,
        theta: theta,
        phi: phi,
        s: s,
        vue: vue,
        front: data.at(0),
        top: data.at(1),
        color: data.at(2),
        dot-color: dot-color,
        opacity: opacity
      ))
    ))
  }
}

// Dessine la face d'un dé de numero donné. -> content
#let dice-face(
  // int from 1 to 6 -> int
  num,
  // -> none | color 
  fill: none,
  // black for a light color fill or white for a dark color or a chosen color -> auto | color
  spot-fill: auto,
  // auto | stroke
  stroke: auto
) = context {
  // Resolve stroke and spot-fill.
  let stroke = if stroke != auto { stroke }
               else if fill == none { text.fill }
               else { none }

  let spot-fill = if spot-fill != auto { spot-fill }
                  else if fill == none { text.fill }
                  else if color.hsl(fill).components().at(2) >= 50% { black }
                  else { white }

  // Positions of the spots for each number.
  let positions = (
    /* 1 */ (( 0, 0),),
    /* 2 */ ((-1, 1), (1, -1)),
    /* 3 */ ((-1, 1), (0, 0), (1, -1)),
    /* 4 */ ((-1, -1), (-1, 1), (1, -1), (1, 1)),
    /* 5 */ ((-1, -1), (-1, 1), (1, -1), (1, 1), (0, 0)),
    /* 6 */ ((-1, 1), (-1, 0), (-1, -1), (1, 1), (1, 0), (1, -1))
  ).at(num - 1)

  // If in math mode, center on axis.
  show: it => if "math" in text.font { block(it) } else { it }
  
  show: box.with(
    baseline: 2.2pt,
    width: 0.9em,
    height: 0.9em,
    fill: fill,
    stroke: stroke,
    radius: 20%
  )

  // Place the spots relative to center of die.
  for (x, y) in positions {
    place(
      center + horizon,
      dx: x * 0.22em,
      dy: y * 0.22em,
      circle(fill: spot-fill, radius: 0.08em)
    )
  }
}