#import "@preview/cetz:0.5.2": canvas, draw
#import "Colors.typ": *

= Cube

// Commande cetz pour un cube(`position` (x,y,z), `c:`color default auto = red right, green top, yellow left, `border-stroke:`false, `light:`20% -> how much to lighten), `thickness:`100% -> how much to scale the thickness from 1pt -> function
#let cube(
  // Position -> array
  a,
  // c:color default auto -> (rouge à droite, vert en haut, jaune à gauche), sinon une ou 3 couleurs -> auto | color | array
  c:auto,
  // Lignes en noir, défaut false -> boolean | color
  border-stroke:false,
  // coefficient multiplicateur des tracés (de 1pt), défaut 100% -> int | float | ratio
  thickness:100%,
  // light:20% -> de combien éclaircir quand une seule couleur -> float | ratio | array
  light:20%,
  // Internal pour petits cubes -> boolean
  side:false,
) = {
  import draw:*
  let t = if type(light) == ratio or type(light) == float {(light*1.25,light*0.25,light*2.5)} else {light}
  let colors = if type(c) == array and c.len() == 3 {c} else if type(c) == color {(c.lighten(t.at(0)),c.lighten(t.at(1)),c.lighten(t.at(2)))} else {(yellow,red,green)}
  // scale(z:-1)
  let colors = if side {(colors.at(1),colors.at(0),colors.at(2))} else {colors}
  let border-stroke = if type(border-stroke) == color {border-stroke} else if border-stroke == false and type(c) == color {c} else {black} //else if border-stroke == true {black} 
  set-style(line:(
    stroke:(paint:border-stroke,join:"round",thickness:1pt*thickness)
  ))
      line(a,(rel:(0,1,0),to:a),stroke:(dash:"dashed"))
      line(a,(rel:(1,0,0),to:a),stroke:(dash:"dashed"))
      line(a,(rel:(0,0,1),to:a),stroke:(dash:"dashed"))
      line((rel:(0,0,1),to:a), (rel:(1,0,0)), (rel:(0,1,0)), (rel:(-1,0,0)), (rel:(0,-1,0)),fill: colors.at(0))
      move-to((rel:(0,1,0)))
      line((), (rel:(0,0,-1)), (rel:(1,0,0)), (rel:(0,0,1)), (rel:(-1,0,0)),fill:colors.at(2))
      move-to((rel:(1,0,0)))
      line((), (rel:(0,0,-1)), (rel:(0,-1,0)), (rel:(0,0,1)),  (rel:(0,1,0)), fill:colors.at(1))
}

= pile

// Helper pour convertir un caractère (chiffre ou lettre a-z) en entier (a=10, b=11, ..., z=35)
#let _char-to-int(ch) = {
  let alpha-map = (
    "0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9,
    "a":10, "b":11, "c":12, "d":13, "e":14, "f":15, "g":16, "h":17, "i":18,
    "j":19, "k":20, "l":21, "m":22, "n":23, "o":24, "p":25, "q":26, "r":27,
    "s":28, "t":29, "u":30, "v":31, "w":32, "x":33, "y":34, "z":35
  )
  alpha-map.at(lower(str(ch)), default: 0)
}

// empilement de petits cubes sur une grille : les donner sous forme de liste en allant du fond vers l'avant `3251` puis de la gauche vers la droite (séparés par des virgules), une couleur peut être indiquée au début ou à la fin, couleurs de base avec none : avant -> jaune, dessus -> vert et droite -> rouge, sinon une liste de 3 couleurs peut-être donnée dans colors, exemple : #pile(54321, 3112, 2112, 11111,none)
// `z:0` pour vue de face `y:0, z:(0,-1)` pour vue du dessus `x:0, z:(-1,0)` pour vue de droite -> content
#let pile(
  // -> int | str | array | arguments
  ..a,
  // Active un mode aléatoire : génère automatiquement l'empilement (au lieu des arguments positionnels), avec des hauteurs égales ou décroissantes de rang en rang -> boolean
  random: false,
  // Largeur (nombre de tranches selon X) en mode aléatoire -> int
  width: 3,
  // Profondeur (nombre de chiffres par tranche selon Z) en mode aléatoire -> int
  depth: 4,
  // Hauteur maximale (selon Y) en mode aléatoire -> int
  height: 5,
  // Graine du générateur pseudo-aléatoire pour la reproductibilité du tirage : même graine -> même empilement, à changer pour en obtenir un autre -> int
  seed: 1,
  // Affiche le plan de niveau (vue de dessus chiffrée) -> boolean
  plan: false,
  // Affiche les intitulés des vues sur les grids -> boolean
  labels: false,
  // Direction de la première coordonnée, défaut (1,0) -> array
  x:(1,0),
  // Direction de la seconde coordonnée, défaut (0,1) -> array
  y:(0,1),
  // Direction de la troisième coordonnée, défaut (-0.5,-0.5) -> array
  z:(-.5,-.5),
  // coefficient multiplicateur des tracés (de 1pt), défaut 60% soit 0.6pt -> int | float | ratio
  thickness:60%,
  // Lignes en noir, défaut false -> boolean | color
  border-stroke:false,
  // Ajout d'une seconde vue de l'assemblage depuis la "droite" -> boolean
  side:false,
  // light:20% -> de combien éclaircir quand une seule couleur -> float | ratio | array
  light:20%,
  // modifie la taille des arêtes d'un cube de base -> float | ratio
  draw-scale:.5,
  // permet « d’éclater » l’empilement construit vers la droite afin de mieux permettre une visualisation par « tranches » -> float | int
  x-spread:0,
  // permet « d’éclater » l’empilement construit vers le haut afin de mieux permettre une visualisation par « couches » -> float | int
  y-spread:0,
  // permet « d’éclater » l’empilement construit vers l'avant afin de mieux permettre une visualisation par « tranches » -> float | int
  z-spread:0,
  // Pour donner une liste de 3 couleurs pour les trois faces (gauche, droite, haut) -> array
  colors:(),
  // Pour afficher trois grids permettant à l’élève de dessiner directement les vues de face, de dessus et de gauche -> boolean
  grids:false,
  // Affiche, lorsqu’elle est positionnée à true, les vues de face, de dessus et de gauche du solide associé sur les grids -> boolean
  solution:false,
  // Écart de la grille du dessous (auto = calculé automatiquement) -> auto | int | float
  below-separation: auto,
  // Écart de la grille de gauche (auto = calculé automatiquement) -> auto | int | float
  left-separation: auto,
  // Écart de la grille du fond (auto = calculé automatiquement) -> auto | int | float
  back-separation: auto,
  // Pour avoir différentes perspectives : si true, représentation isométrique, si 1 vue tikz3d-fr, si 2 "première vue" de ProfCollege, si 3 "seconde vue" de Profcollege, sinon vue par defaut de cetz -> boolean | int
  iso:false,
  // Espacement avec la seconde vue -> length | relative length | fraction
  space:2em,
  // Active un mode aléatoire : génère automatiquement l'empilement (au lieu des arguments positionnels), avec des hauteurs égales ou décroissantes de rang en rang -> boolean
  // aleatoire: false,
  // Graine du générateur pseudo-aléatoire : même graine -> même empilement, à changer pour en obtenir un autre -> int
  // graine:1,
  // Autorise des "trous" (hauteur nulle) dans l'empilement aléatoire à partir de la deuxième pile ; la première pile reste toujours "pleine" (hauteur >= 1 partout) -> boolean
  holes:false,
  // Mode aléatoire spécifique : 1 (LCG double min par gemini), 2 et 4 (LCG décroissant inspiré de ProfCollege par Claude), 3 (package suiji) -> auto | int
  random-mode: auto,
  // Liste des vues à afficher parmi ("dessus", "face", "droite") -> array
  views: ("dessus", "face", "droite"),
  // Noms des vues affichées parmi ("dessus", "face", "droite") -> array
  views-names: ("Vue de dessus", "Vue de face", "Vue de droite"),
  // Affiche les repères d'axes (coordonnées) au sol -> boolean
  axes: false,
  // Opacité des faces des cubes (100% = opaque, 50% = semi-transparent) -> ratio
  opacity: 100%,
  // Dessine l'empreinte au sol sous l'empilement -> boolean
  shadow: false,
  // Disposition des grids 2D : "3d" (projetées autour) ou "cote-a-cote" (à côté de la 3D) -> str
  disposition: "3d",
  // Arguments à passer à la (aux) boite(s) -> dictionary
  box-args:(),
) = {
  let t = if type(light) == ratio or type(light) == float {(light*1.25,light*0.25,light*2.5)} else {light}
  let (x,y,z) = if iso == true {((calc.cos(-30deg),calc.sin(-30deg)),(0,1),(calc.cos(-150deg),calc.sin(-150deg)))} else if iso == 1 {
  ((calc.cos(-25deg)*.9,calc.sin(-25deg)*.9), (0,1), (calc.cos(-160deg),calc.sin(-160deg)))} else if iso == 2 {
  ((-calc.cos(150deg)*.65,-calc.sin(150deg)*.65), (0,1), (-calc.cos(10deg),-calc.sin(10deg)))} else if iso == 3 {
  ((-calc.cos(140deg)*6.3/9,-calc.sin(140deg)*7/9), (0,1), (-calc.cos(17deg),-calc.sin(17deg)))} else {(x,y,z)}

  // Traitement de la couleur et extraction des arguments positionnels
  let c = auto
  let args_pos = if a.len() > 1 {a.pos()} else {(a.at(0,default: ()))}
  if args_pos.len() > 0 {
    if args_pos.last() == auto or args_pos.last() == none { c = args_pos.pop() } 
    else if type(args_pos.last()) == color { c = args_pos.pop() } 
    else if type(args_pos.first()) == color { c = args_pos.remove(0) } 
    else if args_pos.first() == auto or args_pos.first() == none { c = args_pos.remove(0) }
  }

  // Sélection du mode aléatoire effectif
  let active-mode = if random-mode != auto { random-mode }
                    // else if aleatoire { 2 }
                    else if random { 2 }
                    else { 0 }

  if active-mode == 0 and args_pos.len() == 0 {
    active-mode = 2 // Mode aléatoire par défaut si aucun argument positionnel n'est passé
  }

  // Normalisation des données : conversion systématique en tableau 2D d'entiers
  let grid_data = ()

  if active-mode == 1 {
    // Mode aléatoire 1 : LCG avec contrainte min croisée
    let state = if seed == none { 12345 } else { seed }
    for xi in range(width) {
      let row = ()
      for zi in range(depth) {
        state = calc.rem(state * 1103515245 + 12345, 2147483648)
        let max-h = height
        if xi > 0 { max-h = calc.min(max-h, grid_data.at(xi - 1).at(zi)) }
        if zi > 0 { max-h = calc.min(max-h, row.at(zi - 1)) }
        let val = if max-h > 0 { calc.rem(state, max-h + 1) } else { 0 }
        row.push(val)
      }
      grid_data.push(row)
    }
  } else if active-mode == 2 {
    // Mode aléatoire 2 : Générateur congruentiel linéaire (style ProfCollege / MetaPost)
    let h-max = calc.max(int(height), 1)
    let l-max = calc.max(int(width), 1)
    let p-max = calc.max(int(depth), 1)

    // Générateur congruentiel linéaire (déterministe, reproductible via `graine`)
    let lcg-suivant(etat) = calc.rem(etat * 1664525 + 1013904223, 4294967296)
    let etat = seed // if graine != none { graine } else { seed }

    // Une colonne par "rang" (position du chiffre selon la profondeur Z)
    let colonnes = ()
    for j in range(p-max) {
      let col = ()
      let precedent = h-max
      for i in range(l-max) {
        let mini = calc.min(if holes and i > 0 { 0 } else { 1 }, precedent)
        etat = lcg-suivant(etat)
        let val = mini + calc.rem(etat, precedent - mini + 1)
        col.push(val)
        precedent = val
      }
      colonnes.push(col)
    }

    // Alignment selon les tranches X
    for i in range(l-max) {
      let row = ()
      for j in range(p-max) {
        row.push(colonnes.at(j).at(i))
      }
      grid_data.push(row)
    }
  } else if active-mode == 4 {
    // Les chiffres sont codés sur un seul caractère : hauteur bornée à 9.
    let hauteur = calc.max(int(height),1)
    let largeur = calc.max(int(width),1)
    let profondeur = calc.max(int(depth),1)

    // Générateur congruentiel linéaire (déterministe, reproductible via `graine`) :
    // fait ici office de « uniformdeviate » de MetaPost.
    // NB : on ne réduit jamais l'état via `calc.rem` sur une petite plage —
    // les bits de poids faible d'un LCG ont une période bien plus courte que
    // l'état complet (calc.rem(etat,2) donnerait une simple alternance
    // 0,1,0,1,...). On passe donc par une division flottante (bits de poids
    // fort) pour obtenir un tirage borné correctement réparti.
    let m-lcg = 4294967296
    let lcg-suivant(etat) = calc.rem(etat * 1664525 + 1013904223, m-lcg)
    
    // Un LCG est une fonction affine de son état : deux graines voisines
    // (1, 2, 3...) restent décalées d'un pas fixe même après plusieurs
    // itérations, donc `graine:1` et `graine:2` donneraient des empilements
    // presque identiques. Le carré ci-dessous casse cette linéarité avant
    // d'entrer dans le LCG, pour que des graines voisines divergent bien.
    // On réduit d'abord la graine (valeur absolue, bornée) : sinon une
    // graine "naturelle" mais grande (une date comme 20260815, par ex.)
    // ferait déborder l'entier 64 bits au moment du carré.
    let graine-reduite = calc.rem(calc.abs(seed), 50000) // graine
    let etat = calc.rem(graine-reduite * graine-reduite * 2654435761 + graine-reduite * 1013904223 + 2246822519, m-lcg)
    etat = lcg-suivant(etat)

    // Une colonne par "rang" (position du chiffre dans le nombre = profondeur/z).
    // Comme dans VueCubes (clé holes), chaque tirage est un entier uniforme
    // entre 1 (ou 0 si `holes` autorise un "holes" à partir de la 2e pile) et
    // la valeur précédente de ce même rang : la suite est donc toujours égale
    // ou décroissante le long d'un même rang, et la première pile ne comporte
    // jamais de holes.
    let colonnes = ()
    for j in range(profondeur) {
      let col = ()
      let precedent = hauteur
      for i in range(largeur) {
        let mini = calc.min(if holes and i > 0 {0} else {1}, precedent)
        etat = lcg-suivant(etat)
        let etendue = precedent - mini + 1
        let val = mini + calc.min(calc.floor(etat / m-lcg * etendue), etendue - 1)
        col.push(val)
        precedent = val
      }
      colonnes.push(col)
    }

    // Reconstruction des piles sous forme de chaînes (et non d'entiers, pour
    // conserver les éventuels zéros de tête, ex. "034").
    let lignes = ()
    for i in range(largeur) {
      let ligne = ()
      for j in range(profondeur) {
        ligne.push(colonnes.at(j).at(i))
      }
      grid_data.push(ligne)
    }
  } else if active-mode == 3 {
    import "@preview/suiji:0.3.0" as suiji
    // Mode aléatoire 3 : Génération pseudo-aléatoire via le package `suiji`
    let h-max = calc.max(int(height), 1)
    let l-max = calc.max(int(width), 1)
    let p-max = calc.max(int(depth), 1)

    let rng = suiji.gen-rng(seed) //if graine != 1 { graine } else { seed }

    let colonnes = ()
    for j in range(p-max) {
      let col = ()
      let precedent = h-max
      for i in range(l-max) {
        let mini = calc.min(if holes and i > 0 { 0 } else { 1 }, precedent)
        let maxi = calc.max(precedent, mini)
        let val = 0
        (rng, val) = suiji.integers(rng, low: mini, high: maxi + 1)
        col.push(val)
        precedent = val
      }
      colonnes.push(col)
    }

    for i in range(l-max) {
      let row = ()
      for j in range(p-max) {
        row.push(colonnes.at(j).at(i))
      }
      grid_data.push(row)
    }
  } else {
    // Normalise les entrées (chaînes avec chiffres/lettres hexa/base36, entiers ou tableaux)
    for elem in args_pos {
      if type(elem) == array {
        grid_data.push(elem.map(v => if type(v) == str { _char-to-int(v) } else { int(v) }))
      } else {
        grid_data.push(str(elem).clusters().map(_char-to-int))
      }
    }
  }
  let main_color = if colors != () { colors } else { c }
    
    // Gestion de la transparence sur les couleurs
    let apply-opacity(col) = {
      if opacity < 100% and type(col) == color {
        col.transparentize(100% - opacity)
      } else {
        col
      }
    }
  
    let effective_color = if type(main_color) == array {
      main_color.map(apply-opacity)
    } else if type(main_color) == color {
      apply-opacity(main_color)
    } else {
      main_color
    }

    let Xmax = grid_data.len()
    let Zed = grid_data.map(row => row.len())
    let Zmax = calc.max(..Zed)
    let Ymax = calc.max(..grid_data.flatten())

    // 1. Calcul de l'encombrement réel du solide (avec éclatement)
    let Xspan = Xmax + (Xmax - 1) * x-spread
    let Yspan = Ymax + (Ymax - 1) * y-spread
    let Zspan = Zmax + (Zmax - 1) * z-spread
    
    // // 2. Projection verticale du vecteur Z (vaut 0.5 en isométrique standard)
    // let zy-abs = calc.abs(z.at(1))

    // // 3. Marge visuelle fixe souhaitée entre les cubes et les grids (en unités de cube)
    // let marge = 0.6

    // // 4. Calculs ajustés et compacts
    // // - Dessous : se place exactement 'marge' sous le cube le plus en avant
    // let below-separation = if below-separation != auto { below-separation } 
    //                     else { Zspan * zy-abs + marge }

    // // - Fond : collé juste derrière la face arrière (Z = 0)
    // let back-separation = if back-separation != auto { back-separation } 
    //                  else { marge + 0.15 * Yspan }

    // // - Gauche : collée juste à gauche de la face gauche (X = 0)
    // let left-separation = if left-separation != auto { left-separation } 
    //                    else { marge + 0.15 * Zspan }

    // 2. Marge visuelle de sécurité entre les grids et le solide
    let marge = 1.2

    // 3. Calcul dynamique des positions non chevauchantes
    let below-separation = if below-separation != auto { below-separation } else { 0.2 * (Xspan + Zspan) + marge }
    let back-separation    = if back-separation != auto { back-separation } else { 0.55 * (Yspan + Xmax) + marge }
    let left-separation  = if left-separation != auto { left-separation } else { 0.2 * (Yspan + Zmax) + marge }
    
  let figure-3d = box(..box-args, canvas(x:x, y:y, z:z, {
    import draw:*

    scale(draw-scale * if iso != false { .816 } else { 1 })

    // shadow au sol (empreinte des cubes)
    if shadow {
      on-xz(y: -below-separation, {
        for (i, row) in grid_data.enumerate() {
          for (j, h_val) in row.enumerate() {
            if h_val > 0 {
              rect(
                (i * (1 + x-spread), j * (1 + z-spread)),
                (i * (1 + x-spread) + 1, j * (1 + z-spread) + 1),
                fill: luma(88%),
                stroke: (gray + 0.3pt)
              )
            }
          }
        }
      })
    }

    // Tracé des cubes
    for (i, tranche) in grid_data.enumerate() {
      for (z_idx, h_val) in tranche.enumerate() {
        for h in range(h_val) {
          cube(
            (i * (1 + x-spread), h * (1 + y-spread), z_idx * (1 + z-spread)),
            c: effective_color,
            border-stroke: border-stroke,
            thickness: thickness,
            light: light
          )
        }
      }
    }

    // Affichage du plan de niveau sur la grille du dessous
    if plan and not grids {
      // Grille de dessous (Vue de dessus)
      on-xz(y: -below-separation, {
        grid((0, 0), (Xmax, Zmax), stroke: (gray + .5pt))
        if labels {
          content((Xmax / 2 + 1, Zmax + 0.6), text(size: .85em, fill: luma(20%))[Plan de construction])
        }
        // Affichage du plan de niveau sur la grille du dessous
        for (i, row) in grid_data.enumerate() {
          for (j, h_val) in row.enumerate() {
            content((i + 0.5, j + 0.5), text(size: .8em, weight: "semibold", fill: if solution { black } else { luma(20%) })[#h_val])
          }
        }
      })
    }

    // Tracé des grids et solutions
    if disposition == "3d" and grids {
      let cols = if type(main_color) == array and main_color.len() == 3 { main_color } 
                 else if type(main_color) == color { (main_color.lighten(t.at(0)), main_color.lighten(t.at(1)), main_color.lighten(t.at(2))) } 
                 else { (yellow, red, green) }
      let stroke_color = if type(border-stroke) == color { border-stroke } else if border-stroke == false and type(main_color) == color { main_color } else { black }
      set-style(rect: (stroke: (paint: stroke_color, join: "round", thickness: 1pt * thickness)))

      // 1. Grille de dessous : Vue de dessus
    if "dessus" in views {
      on-xz(y: -below-separation, {
        grid((0, 0), (Xmax, Zmax), stroke: (gray + .5pt))
        if labels { content((Xmax / 2, Zmax + 0.6), text(size: .85em, fill: luma(20%),views-names.at(0))) }
        if solution {
          for (i, row) in grid_data.enumerate() {
            for (j, h_val) in row.enumerate() {
              if h_val > 0 { rect((i, j), (i + 1, j + 1), fill: cols.at(2)) }
            }
          }
        }
        // Affichage du plan de niveau sur la grille du dessous
        if plan {
          for (i, row) in grid_data.enumerate() {
            for (j, h_val) in row.enumerate() {
              content((i + 0.5, j + 0.5), text(size: 9pt, weight: "bold", fill: if solution { black } else { luma(20%) })[#h_val])
            }
          }
        }
        // Affichage des repères d'axes (coordonnées)
        if axes {
          // Axe X (Numéros en bas)
          for i in range(Xmax) {
            content((i + 0.5, -0.4), text(size: 7pt, weight: "bold", fill: luma(30%))[#(i + 1)])
          }
          // Axe Z (Lettres à gauche)
          let lettres = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J")
          for j in range(Zmax) {
            let label-z = if j < lettres.len() { lettres.at(j) } else { str(j + 1) }
            content((-0.4, j + 0.5), text(size: 7pt, weight: "bold", fill: luma(30%))[#label-z])
          }
        }
      })
    }

    // 2. Grille du fond : Vue de face
    if "face" in views {
      on-xy(z: -back-separation, {
        grid((0, 0), (Xmax, Ymax), stroke: (gray + .5pt))
        if labels { content((Xmax / 2, Ymax + 0.6), text(size: .85em, fill: luma(20%),views-names.at(1))) }
        if solution {
          for (i, row) in grid_data.enumerate() {
            let max_h = calc.max(..row, 0)
            for j in range(max_h) { rect((i, j), (i + 1, j + 1), fill: cols.at(0)) }
          }
        }
      })
    }

    // 3. Grille de gauche : Vue de droite
    if "droite" in views {
      on-zy(x: -left-separation, {
        grid((0, 0), (Zmax, Ymax), stroke: (gray + .5pt))
        if labels { content((Zmax / 2, Ymax + 0.6), text(size: .85em, fill: luma(20%),views-names.at(2))) }
        if solution {
          for j in range(Zmax) {
            let column_heights = grid_data.map(row => if j < row.len() { row.at(j) } else { 0 })
            let max_h = calc.max(..column_heights, 0)
            for h in range(max_h) { rect((j, h), (j + 1, h + 1), fill: cols.at(1)) }
          }
        }
      })
    }
    }
  })) + if side {
    h(space) + box(..box-args, canvas(x:x, y:y, z:(z.at(0)*.6, z.at(1)*1.28), {
      import draw:*
      scale(draw-scale * if iso != false { .8 } else { 1 })
      for (i, tranche) in grid_data.enumerate() {
        for (z_idx, h_val) in tranche.enumerate().rev() {
          for h in range(h_val) {
            cube(
              (-z_idx * (1 + z-spread), h * (1 + y-spread), i * (1 + x-spread)),
              c: effective_color,
              border-stroke: border-stroke,
              thickness: thickness,
              light: light,
              side: true
            )
          }
        }
      }
    }))
  } 

  if disposition != "3d" and grids {
    // Génère les vues 2D sous forme de cartes indépendantes à plat
    let vue-2d-flat(titre, draw_fn) = box(stroke: luma(80%), inset: 5pt, radius: 3pt, {
      align(center)[
        #text(size: .9em, weight: "bold")[#titre]
        #v(-5pt)
        #canvas({
          import draw:*
          draw_fn()
        })
      ]
    })

    // Couleurs d'affichage des solutions
    let cols = if type(main_color) == array and main_color.len() == 3 { main_color } 
               else if type(main_color) == color { (main_color.lighten(t.at(0)), main_color.lighten(t.at(1)), main_color.lighten(t.at(2))) } 
               else { (yellow, red, green) }

    let stroke_color = if type(border-stroke) == color { border-stroke } else if border-stroke == false and type(main_color) == color { main_color } else { black }
      
    grid(
      columns: (auto, auto),
      gutter: 15pt,
      align: center,
      figure-3d,
      stack(
        dir: ltr,
        spacing: .85em,
        if "dessus" in views {
          vue-2d-flat(views-names.at(0), () => {
            // Tracé 2D à plat de la vue de dessus
            import draw:*
            scale(.65)
            // set-style(rect: (stroke: (paint: stroke_color, join: "round", thickness: 1pt * thickness)))
            grid((0, 0), (Xmax, -Zmax), stroke: gray + 0.5pt)
            if solution {
              for (i, row) in grid_data.enumerate() {
                for (j, h_val) in row.enumerate() {
                  if h_val > 0 { rect((i, -j), (i + 1, -j - 1), fill: cols.at(2)) }
                  if plan {
                    content((i + 0.5, - j - 0.5), text(size: .8em, weight: "bold", fill: if solution { black } else { luma(20%) })[#h_val])
                  }
                }
              }
            } else if plan {
              for (i, row) in grid_data.enumerate() {
                for (j, h_val) in row.enumerate() {
                  content((i + 0.5, - j - 0.5), text(size: 9pt, weight: "semibold", fill: if solution { black } else { luma(20%) })[#h_val])
                }
              }
            }
          })
        },
        if "face" in views {
          vue-2d-flat(views-names.at(1), () => {
            import draw:*
            scale(.65)
            // set-style(rect: (stroke: (paint: stroke_color, join: "round", thickness: 1pt * thickness)))
            grid((0, 0), (Xmax, Ymax), stroke: gray + 0.5pt)
            if solution {
              for (i, row) in grid_data.enumerate() {
                let max_h = calc.max(..row, 0)
                for j in range(max_h) { rect((i, j), (i + 1, j + 1), fill: cols.at(0)) }
              }
            }
          })
        },
        // 3. Vue de gauche
        if "droite" in views {
          vue-2d-flat(views-names.at(2), () => {
            import draw:*
            scale(.65)
            // set-style(rect: (stroke: (paint: stroke_color, join: "round", thickness: 1pt * thickness)))
            grid((0, 0), (-Zmax, Ymax), stroke: gray + 0.5pt)
            if solution {
              for j in range(Zmax) {
                let column_heights = grid_data.map(row => if j < row.len() { row.at(j) } else { 0 })
                let max_h = calc.max(..column_heights, 0)
                for h in range(max_h) { rect((-j, h), (-j - 1, h + 1), fill: cols.at(1)) }
              }
            }
          })
        }
      )
    )
  } else {
    figure-3d
  }
}

= building
// Assemblage de petits cubes avec mix de couleurs : chaque n° correspond à la position dans la liste de couleurs (16 max : 1 à 9 et a à g + t -> 3 couleurs), le "0" et le "o" représentent un holes, le "x" donne la première couleur, les cubes sont donnés dans une liste de listes : de l'avant vers l'arrière par un nombre "5432a" puis étage par étage, listes de gauches à droite
// `z:0` pour vue de face `y:0, z:(0,-1)` pour vue du dessus `x:0, z:(-1,0)` pour vue de droite -> content
#let building(
  // -> array | arguments
  ..a,
  // Liste de max 16 couleurs -> array
  color-list:typst16,
  // Direction de la première coordonnée, défaut (1,0) -> array
  x:(1,0),
  // Direction de la seconde coordonnée, défaut (0,1) -> array
  y:(0,1),
  // Direction de la troisième coordonnée, défaut (-0.5,-0.5) -> array
  z:(-.5,-.5),
  // coefficient multiplicateur des tracés (de 1pt), défaut 60% soit 0.6pt -> int | float | ratio
  thickness:60%,
  // Lignes en noir, défaut false -> boolean | color
  border-stroke:false,
  // parametre pour certaines vues _rev:false (si true haut vers bas) -> boolean
  _rev:false,
  // parametre pour la vue du dessous -> boolean
  _dessous:false,
  // paramètre pour la vue de l'arrière -> boolean
  _back:false,
  // light:20% -> de combien éclaircir quand une seule couleur -> float | ratio | array
  light:20%,
  // modifie la taille des arêtes d'un cube de base -> float | ratio
  draw-scale:.5,
  // Pour avoir différentes perspectives : si true, représentation isométrique, si 1 vue tikz3d-fr, si 2 première vue de ProfCollege, si 3 seconde vue de Profcollege, sinon vue par defaut de cetz -> boolean | int
  iso:false,
  // Texte à mettre en dessous de l'empilement (pour les vues) -> str | content
  text:none,
  // permet « d’éclater » l’empilement construit vers la droite afin de mieux permettre une visualisation par « tranches » -> float | int
  x-spread:0,
  // permet « d’éclater » l’empilement construit vers le haut afin de mieux permettre une visualisation par « couches » -> float | int
  y-spread:0,
  // permet « d’éclater » l’empilement construit vers l'avant afin de mieux permettre une visualisation par « tranches » -> float | int
  z-spread:0,
  // Arguments à passer à la boite -> dictionary
  box-args:(),
) = box(..box-args,align(center,{
  let (x,y,z) = if iso == true {((calc.cos(-30deg),calc.sin(-30deg)),(0,1),(calc.cos(-150deg),calc.sin(-150deg)))} else if iso == 1 {
  ((calc.cos(-25deg)*.9,calc.sin(-25deg)*.9), (0,1), (calc.cos(-160deg),calc.sin(-160deg)))} else if iso == 2 {
  ((-calc.cos(150deg)*.65,-calc.sin(150deg)*.65), (0,1), (-calc.cos(10deg),-calc.sin(10deg)))} else if iso == 3 {
  ((-calc.cos(140deg)*6.3/9,-calc.sin(140deg)*7/9), (0,1), (-calc.cos(17deg),-calc.sin(17deg)))} else {(x,y,z)}
  canvas(x:x,y:y,z:z,padding: 0pt,{//
  import draw:*
  let a = if a.len() > 1 {a.pos()} else {a.at(0)}//
  let s = if _rev {-1} else {1}
  scale(draw-scale * s * if iso != false {0.816} else {1})
  let a = if _rev {a.rev()} else {a}
  for (k,l) in a.enumerate() {
      // let l = l.map(it=>str(it))
      let l = if type(l) == array {l.map(it=>str(it))} else {(str(l),)}
      if _dessous {l = l.rev()}
      for i in range(l.len()){
      let tranche = if _back {str(l.at(i)).clusters().enumerate()} else {str(l.at(i)).rev().clusters().enumerate()}

  for (r,s) in tranche {
    if s != "0" and s != "o" {
      s = if s == "a" {"10"} else if s == "b" {"11"} else if s == "c" {"12"} else if s == "d" {"13"} else if s == "e" {"14"} else if s == "f" {"15"} else if s == "g" {"16"} else if s == "x" {"1"} else {s}
    cube((k * (1+x-spread),i * (1+y-spread),r * (1+z-spread)),c:if s == "t" or s == "n" {none} else {color-list.at(calc.rem(int(s)-1,color-list.len()))},border-stroke: border-stroke,thickness:thickness,light:light)
  }
  }}
  }
})}
)+align(center,text))

= Vues avec building

// Vue du dessus pour une building -> content
#let above-view(
  // les arguments pour building -> arguments
  ..it,
  // Nom de la vue
  text:"Vue du dessus"
) = building(           y:0,      z:(0,-1), ..it,light:10%,text:text)

// Vue de droite pour une building -> content
#let right-view(
  // les arguments pour building -> arguments
  ..it,
   // Nom de la vue
   text:"Vue de droite"
) = building(x:0,                 z:(-1,0), ..it,light:60%,text:text)

// Vue de face pour une building -> content
#let front-view(
  // les arguments pour building -> arguments
  ..it,
   // Nom de la vue
   text:"Vue de face"
) = building(                       z:0,      ..it,text:text)

// Vue du dessous pour une building -> content
#let below-view(
  // les arguments pour building -> arguments
  ..it,
   // Nom de la vue
   text:"Vue du dessous"
) = building(x:(-1,0), y:0,      z:(0,1),  _rev:true,_dessous:true,..it,light:10%,text:text)

// Vue de gauche pour une building -> content
#let left-view(
  // les arguments pour building -> arguments
  ..it,
   // Nom de la vue
   text:"Vue de gauche"
) = building(x:0,       y:(0,-1), z:(-1,0), _rev:true, ..it,light:60%,text:text)

// Vue de l'arrière pour une building -> content
#let back-view(
  // les arguments pour building -> arguments
  ..it,
   // Nom de la vue
   text:"Vue arrière"
) = building(x:(-1,0), y:(0,-1), z:0,      _rev:true, _back:true, ..it,text:text)