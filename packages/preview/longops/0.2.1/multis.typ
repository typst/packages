#import "@preview/cetz:0.4.2"

// Helper interne : Convertit un chiffre/nombre en chaîne selon la base -> str
#let _format-digit(
  // Chiffre à convertir -> int
  d, 
  // Base selon laquelle convertir -> int
  base
) = {
  if d == "" or d == none { return "" }
  let digits-map = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
  if type(d) == int and d >= 0 and d < digits-map.len() {
    digits-map.at(d)
  } else {
    str(d)
  }
}

// Helper interne : Parse un caractère en valeur numérique selon sa position -> int
#let _parse-digit(
  // caractère à convertir -> str
  ch
) = {
  if type(ch) == int { return ch }
  let chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
  let u = upper(str(ch))
  let pos = chars.position(c => c == u)
  if pos != none { pos } else { int(ch) }
}

// Analyse d'un facteur : accepte int, float, decimal ou chaîne.
// Renvoie (digits: chiffres sans le séparateur, ndec: nb de décimales,
//          affichage: représentation avec le séparateur choisi). -> array
#let _parse-nombre(
  // nombre à analyser -> int | float | decimal | str
  x, 
  // nom du nombre -> str
  nom, 
  // Virgule décimale ou pas -> bool
  fr: true
) = {
  let s = if type(x) == str { x } else { str(x) }
  s = s.trim().replace(",", ".")
  let parties = s.split(".")
  if parties.len() > 2 {
    panic("nombre mal formé («" + s + "») pour " + nom)
  }
  let ip = parties.at(0, default: "")
  let dp = parties.at(1, default: "")
  if ip == "" { ip = "0" }
  if (ip + dp).matches(regex("^[0-9]+$")).len() != 1 {
    panic(nom + " ne doit contenir que des chiffres («" + s + "»)")
  }
  let sep = if fr { "," } else { "." }
  (
    digits: ip + dp,
    ndec: dp.len(),
    affichage: if dp == "" { ip } else { ip + sep + dp },
  )
}

// Écrit l'entier n divisé par 10^dec, avec le séparateur choisi.
// Les zéros inutiles en fin de partie décimale sont supprimés. -> str
#let _decalage-virgule(
  // Nombre entier à diviser -> int
  n, 
  // Position de la virgule -> int
  dec, 
  // Virgule décimale ou pas -> bool
  fr: true
) = {
  let sep = if fr { "," } else { "." }
  if n == 0 {
    "0"
  } else {
    let s = str(n)
    if dec <= 0 {
      if dec < 0 { for _ in range(-dec) { s = s + "0" } }
      s
    } else if dec >= s.len() {
      "0" + sep + ("0" * (dec - s.len())) + s
    } else {
      let c = s.len() - dec
      let t = s.slice(0, c) + sep + s.slice(c)
      while t.last() == "0" { t = t.slice(0, t.len() - 1) }
      if t.last() == sep { t = t.slice(0, t.len() - 1) }
      t
    }
  }
}

// 10^e sous forme d'entier (e ≥ 0) -> int
#let _puiss10(
  // exposant -> int
  e
) = range(e).fold(1, (acc, _) => acc * 10)

= Jalousie
== Multiplication par Jalousie (Grille de Napier)

// Cette fonction génère une grille où chaque case est séparée par une diagonale (dizaines en haut à gauche, unités en bas à droite). Les sommes sont effectuées le long des diagonales.

// Explication des options et de leur fonctionnement
// - base (défaut: 10) : 
//   - Tous les calculs de dizaines/unités dans les cases et les retenues se font désormais selon base.
//   - Prise en charge des bases jusqu'à 36 (affichage avec les lettres A, B, C... pour les bases $>10$).
// - hide-result :
//   - false (défaut) : affiche tout si solution: true.
//   - true ou "result" : masque le résultat final et cache les retenues (les calculs dans la grille restent visibles).
//   - "grid" ou "grid-only" : masque à la fois les calculs de la grille et le résultat final (dessin de la grille seule avec les deux facteurs).
//   - "calculations" : masque les calculs dans la grille tout en affichant le résultat final.
// - type-mask (défaut: "blank") :
//   - Permet de choisir l'apparence des valeurs masquées :
//     - "blank" : laisse un espace vide."box" : dessine un petit carré à compléter.
//     - "question" ou "?" : affiche ?.
//     - "dots" : affiche ....
//     - Une fonction ou du contenu personnalisé.
// - list (défaut: none) :
//   - Permet un masquage très fin :
//     - Soit par mots clés : list: ("result", "carries", "calculations").
//     - Soit par coordonnées de cases précises dans la grille (colonne, ligne) à masquer pour créer des exercices à trous, par exemple list: ((0, 1), (2, 0)).
// - solution (défaut: false) :
//   - Quand solution: true, les cases et retenues cachées par hide-result et/ou list sont affichées en solution-color.

// Affiche la multiplication par jalousie (grille avec diagonales).
// Cette fonction génère une grille où chaque case est séparée par une diagonale (dizaines en haut à gauche, unités en bas à droite). Les sommes sont effectuées le long des diagonales. 
// Exemples d'utilisation :
// ```example
// #grid-multiplication(4.51, 8.9,)
// ```
// Grille à trous
// ```example
// #grid-multiplication(384, 56, hide-result: "all", type-mask: "box",)
// ```
// Calcul en base 16 (hexadécimal)
// ```example
// #grid-multiplication("1A", "B2", base: 16)
// ```
// -> content
#let grid-multiplication(
  // Premier facteur (inscrit en haut) -> int | float | decimal | str
  a, 
  // Second facteur (inscrit à droite) -> int | float | decimal | str
  b,
  // Taille des cases de la grille. -> length
  cell-size: 1.1cm,
  // Couleur de la grille -> color
  grid-color: rgb("1f2937"),
  // Couleur des traits indiquant la position de la virgule -> color
  comma-lines-color: rgb("ef4444"),
  // Couleur des diagonales -> color
  diag-color: rgb("ef4444"),
  // Couleur du résultat -> color
  result-color: rgb("059669"),
  // Couleur de la partie décimal du résultat -> none | color
  decimal-part-color: none,
  // Couleur des facteurs -> color
  numbers-color: black,
  // Couleur des produits -> color
  prod-color: luma(80),
  // Couleur des produits -> none | color
  tens-color: none,
  // Couleur des produits -> none | color
  units-color: none,
  // Couleur d'affichage de la solution -> color
  solution-color: rgb("2563eb"),
  // Base de numération (défaut: 10) -> int
  base: 10,
  // Montrer la base des nombres -> bool
  show-base:false,
  // Masquage : false (tout afficher), true ou "result" (masquer le résultat), 
  // "grid" ou "grid-only" ou "all" (grille vide + facteurs uniquement), 
  // "calculations" (calculs masqués mais résultat affiché) -> bool | str
  hide-result: false,
  // Style du masque quand une valeur est cachée ("blank", "box", "question", "dots", content ou fonction) -> str | content | function
  type-mask: "blank",
  // Liste d'éléments cibles ou coordonnées (col, row) spécifiques à masquer -> array | none
  list: none,
  // Active le mode correction : affiche les valeurs masquées dans solution-color -> bool
  solution: false,
  // Virgule comme séparateur décimal ou pas -> bool
  fr: true
) = {
  let sep = if fr { "," } else { "." }
  let taille = cell-size
  let units-color = if units-color != none {units-color} else {prod-color}
  let tens-color = if tens-color != none {tens-color} else {prod-color}
  let decimal-part-color = if decimal-part-color != none {decimal-part-color} else {result-color}

  // Traitement de a
  let sa = str(a).replace(",", ".")
  let parts-a = sa.split(".")
  let int-part-a = parts-a.at(0)
  let dec-part-a = if parts-a.len() > 1 { parts-a.at(1) } else { "" }
  let digits-a = (int-part-a + dec-part-a).clusters().map(_parse-digit)
  let comma-pos-a = int-part-a.len()

  // Traitement de b
  let sb = str(b).replace(",", ".")
  let parts-b = sb.split(".")
  let int-part-b = parts-b.at(0)
  let dec-part-b = if parts-b.len() > 1 { parts-b.at(1) } else { "" }
  let digits-b = (int-part-b + dec-part-b).clusters().map(_parse-digit)
  let comma-pos-b = int-part-b.len()

  let m = digits-a.len()
  let n = digits-b.len()

  // Calcul des sommes diagonales selon la base
  let diag-sums = (0,) * (m + n)
  for c in range(m) {
    for r in range(n) {
      let p = digits-a.at(c) * digits-b.at(r)
      let tens = calc.trunc(p / base)
      let units = calc.rem(p, base)
      diag-sums.at(c + r + 1) += units
      diag-sums.at(c + r) += tens
    }
  }

  // Traitement des retenues de droite à gauche selon la base
  let final-digits = (0,) * (m + n)
  let carry = 0
  let carries = ()
  for i in range(m + n - 1, step: -1, -1) {
    let tot = diag-sums.at(i) + carry
    final-digits.at(i) = calc.rem(tot, base)
    carries.push(carry)
    carry = calc.trunc(tot / base)
  }

  // Identification des éléments devant être masqués
  let target-hide-result = (hide-result == true) or (hide-result in ("result", "final", "grid", "all", "grid-only")) or (type(list) == array and "result" in list)
  let target-hide-carries = (hide-result == true) or (hide-result in ("result", "final", "grid", "all", "grid-only", "carries")) or (type(list) == array and "carries" in list)
  let target-hide-calcs = (hide-result in ("grid", "all", "grid-only", "calculations", "grid-calculations")) or (type(list) == array and "calculations" in list)

  // Rendu unifié (Gère normal, masque et solution avec masque)
  let render-val(val, is-masked, carry:false, size: 1em, fill: auto, weight: "regular", prefix: "") = {
    if val == "" or val == none or (carry and ((hide-result != false or list != none) and not solution)) { return [] }
    let formatted-val = prefix + _format-digit(val, base)

    if not is-masked or carry {
      // Affichage standard
      text(size: size, fill: fill, weight: weight, formatted-val)
    } else if not solution {
      // Mode Exercice (solution: false) -> Masque uniquement
      if type-mask == "blank" or type-mask == none or type-mask == "none" {
        []
      } else if type-mask == "box" {
        box(width: size * 0.8, height: size * 0.8, outset:1pt, radius: .45em, stroke: luma(120) + .5pt, align(center + horizon, text(white.transparentize(100%), formatted-val)))
      } else if type-mask == "rect" {
        box(width: size * 0.8, height: size * 0.8, stroke: 0.5pt + luma(120))
      } else if type-mask == "question" or type-mask == "?" {
        text(size: size, fill: luma(120), weight: weight, "?")
      } else if type-mask == "dots" or type-mask == "." {
        box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(white.transparentize(100%), formatted-val)))
      } else if type(type-mask) == function {
        type-mask(val)
      } else {
        type-mask
      }
    } else {
      // Mode Solution (solution: true) -> Valeur corrigée + masque visible
      let sol-text = text(size: size, fill: solution-color, weight: "bold", formatted-val)
      
      if type-mask == "box" {
        box(width: size * 0.8, height: size * 0.8, outset:1pt, radius: .45em, stroke: luma(120) + .5pt, align(center + horizon, text(solution-color, formatted-val)))
      } else if type-mask == "rect" {
        box(
          width: size * 0.75, 
          height: size * 0.75, 
          outset:.5pt,
          stroke: 0.5pt + luma(120), 
          align(center + horizon, sol-text)
        )
      } else if type-mask == "dots" or type-mask == "." {
        box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(solution-color, sol-text)))
      } else {
        sol-text
      }
    }
  }

  cetz.canvas(length: taille, {
    import cetz.draw: *

    // Dessin des cases et diagonales
    for c in range(-1, m) {
      for r in range(n + 1) {
        let x0 = c
        let y0 = -r
        let x1 = (c + 1)
        let y1 = -(r + 1)

        if c != -1 and r != n {
          rect((x0, y0), (x1, y1), stroke: 1pt + grid-color)
          line((x1, y0), (x0, y1), stroke: (dash: "dashed", paint: diag-color, thickness: 0.75pt))

          let p = digits-a.at(c) * digits-b.at(r)
          let tens = calc.trunc(p / base)
          let units = calc.rem(p, base)

          let cell-masked = target-hide-calcs or (type(list) == array and (c, r) in list)

          content((x0 + 0.25, y0 - 0.25), render-val(tens, cell-masked, size: 0.95em, fill: tens-color))
          content((x0 + 0.75, y0 - 0.75), render-val(units, cell-masked, size: 0.95em, fill: units-color))
        } else {
          line((x1, y0), ((x1, y0), 40%, (x0, y1)), stroke: (dash: "dashed", paint: diag-color, thickness: 0.75pt), name: if (c == comma-pos-a and r == comma-pos-b) { "c" })
        }
      }
    }

    content((m + .25, 0.25), text(weight: "bold", size: 1.05em, numbers-color, "×"))

    if show-base {
      content((-.15,.15),text(.8em, prod-color, $bold(str(base))$), frame:"circle",stroke:prod-color)
    }

    // Facteurs en en-tête et bordure droite
    for c in range(m) {
      content((c + 0.5, 0.25), text(weight: "bold", size: 1.05em, numbers-color, _format-digit(digits-a.at(c), base)))
    }
    for r in range(n) {
      content((m + 0.25, -r - 0.5), text(weight: "bold", size: 1.05em, numbers-color, _format-digit(digits-b.at(r), base)))
    }

    // Virgule haut
    if comma-pos-a != m {
      let x-comma = comma-pos-a
      circle((x-comma, 0), radius: 0.05, fill: comma-lines-color, stroke: none, name: "a")
      content((x-comma, .25), text(weight: "bold", numbers-color, size: 1.05em, sep))
    }
    // Virgule de droite
    if comma-pos-b != n {
      let x-comma = -comma-pos-b
      circle((m, x-comma), radius: 0.05, fill: comma-lines-color, stroke: none, name: "b")
      content((m + .25, x-comma), text(weight: "bold", numbers-color, size: 1.05em, sep))
    }

    // Traits pour le placement de la virgule du résultat
    if comma-pos-a != m or comma-pos-b != n {
      let k = calc.min(comma-pos-a, n - comma-pos-b)
      line((comma-pos-a, 0), ((comma-pos-a, 0), "|-", (m, -comma-pos-b)), (m, -comma-pos-b), stroke: comma-lines-color + 1pt)
      line(((comma-pos-a, 0), "|-", (m, -comma-pos-b)), (rel: (-k - .35, -k - .35)), stroke: comma-lines-color + 1pt)
    }

    if final-digits.first() == 0 { final-digits.at(0) = "" }

    // Affichage du résultat le long des bordures gauche et inférieure
    for i in range(m + n) {
      let val = final-digits.at(i)
      let carry = carries.rev().at(i)
      let couleur = if i < comma-pos-a + comma-pos-b  {result-color} else {decimal-part-color}

      let res-digit-masked = target-hide-result or (type(list) == array and (i in list or "result" in list))
      let carry-masked = target-hide-carries or (type(list) == array and "carries" in list)

      if i < n {
        content((-0.25, -i - 0.7), render-val(val, res-digit-masked, size: 1.1em, fill: couleur, weight: "bold"))
        if carry != 0 {
          content((-0.135, -i - 0.4), render-val(carry, carry-masked, carry:true, size: .65em, fill: couleur.negate(space: cmyk), weight: "bold", prefix: "+"))
        }
      } else {
        let col = i - n + 1
        content((col - 0.75, -n - 0.22), render-val(val, res-digit-masked, size: 1.1em, fill: couleur, weight: "bold"))
        if carry != 0 {
          content((col - 0.45, -n - 0.12), render-val(carry, carry-masked, carry:true, size: .65em, fill: couleur.negate(space: cmyk), weight: "bold", prefix: "+"))
        }
      }
    }
  })
}

// ─────────────────────────────────────────────────────────────────────────────
== Exemples et tests
// ─────────────────────────────────────────────────────────────────────────────

#grid-multiplication(32.4, 5.67, result-color: red, )

// // 1. Grille seule (exercice) avec petits carrés à compléter
// #grid-multiplication(384, 56, hide-result: "grid", type-mask: "box",)

// // #grid-multiplication(384, 56, hide-result: true, type-mask: x => rect(width: .8em, height: .9em, radius: .35em, stroke: gray + .75pt, text(red)[#x]))

// // 2. Grille avec calculs internes mais sans le résultat final
// #grid-multiplication(384, 56, hide-result: "result")

// #import "/ocg.typ": *

// // 3. Masquer seulement quelques cases précises dans la grille
// #grid-multiplication(384, 56, list: ((0, 1), (2, 0)),)
// #grid-multiplication(384, 56, list: ((0, 1), (2, 0)), type-mask: gap.with(s:.95em, color:luma(80)))

// // 4. Calcul en base 16 (hexadécimal)
// #grid-multiplication("1A", "B2", base: 16)

// // 4. Calcul en base 8 (octal)
// #grid-multiplication(754, 216, base: 8)

// // --- 1. VERSION ÉLÈVE (solution: false) ---
// // Masque le résultat avec des cases carrées à compléter
// #grid-multiplication(384, 56, hide-result: true, type-mask: "box",)
// #grid-multiplication(384, 56, hide-result: "calculations", type-mask: "rect",)

// // --- 2. VERSION CORRIGÉE (solution: true) ---
// // Affiche la réponse dans les cases carrées en bleu
// #grid-multiplication(384, 56, hide-result: true, list:((0,1),(2,0)), type-mask: ".", solution: true)

// Alias de la multiplication en grille -> content
#let mul-jalousie = grid-multiplication

= Binaire

== Multiplication binaire (ou Éthiopienne ou Russe)



// Affiche la multiplication éthiopienne sous forme de tableau. 
// Cette méthode repose sur la décomposition binaire du premier facteur, donc sur des divisions successives par 2 (colonne de gauche) et des multiplications par 2 (colonne de droite). Les lignes où le nombre de gauche est pair (0 dans l'écriture binaire) sont biffées, et on additionne les nombres restants à droite.
// Exemples d'utilisation :
// ```example
// #binary-multiplication(23, 14, show-equality: false,sums: true, sum-symbol: "Result:")
// ```
// ```example
// #binary-multiplication("2.7", 1.3,numbers: true,rule: true,sums: true, )
// ``` -> content
#let binary-multiplication(
  // Premier facteur -> int | float | decimal | str
  a, 
  // Second facteur -> int | float | decimal | str
  b,
  // explique la décomposition en produits partiels -> bool
  numbers:false,
  // Affiche ÷ 2, × 2 pour expliquer les calculs -> bool
  rule:true,
  // Affiche une dernière ligne avec les sommes -> bool
  sums:false,
  // Symbole de sommation -> content
  sum-symbol:$sum$,
  // Barre les lignes des nombres pairs -> bool
  biffer-pairs: true,
  // Affiche une égalité sous le tableau -> bool
  show-equality: true,
  // Couleur des lignes avec nombres pairs -> color
  fill-even: rgb("ffebee"),
  // Couleur des lignes avec nombres impairs -> color
  fill-odd: rgb("e8f5e9"),
  // Traits du tableau -> stroke
  stroke: 0.5pt + luma(180),
  // Virgule comme séparateur décimal ou pas -> bool
  fr:true
) = {
  let sep = if fr { "," } else { "." }
  let left = int(str(a).replace(",","").replace(".",""))
  let right = int(str(b).replace(",","").replace(".",""))
  let inta = left
  let intb = right
  let floata = float(str(a).replace(",","."))
  let floatb = float(str(b).replace(",","."))
  let rows = ()
  let sum-terms = ()
  let decomp = ()
  let n = .5

  while left >= 1 {
    n = n * 2
    let is-even = calc.rem(left, 2) == 0
    rows.push((left, right, is-even)+if numbers {(n,)})
    if not is-even {
      sum-terms.push(right)
      decomp.push(n)
    }
    left = calc.trunc(left / 2)
    right = right * 2
  }

  let table-content = if rule {([*÷ 2*], [*× 2*]) + if numbers {([],)}} else {()}

  if numbers {for (l, r, is-even, n) in rows {
    if is-even and biffer-pairs {
      table-content.push(text(fill: luma(120), strike(str(l), stroke: black+1pt,extent: 14pt)))
      table-content.push(text(fill: luma(120), strike(str(r), stroke: black+1pt,extent: 14pt)))
      table-content.push(text(fill: luma(120), place(center+horizon, dy:.6pt,$cancel(#n times #intb,angle:#90deg, stroke:#(black+1pt),length:#(100%+23pt))$)))
    } else {
      table-content.push(text(weight: "medium", str(l)))
      table-content.push(text(weight: "bold", fill: rgb("2e7d32"), str(r)))
      table-content.push(text(weight: "medium", $#n times #intb$))
    }
  }  
  } else {for (l, r, is-even) in rows {
    if is-even and biffer-pairs {
      table-content.push(text(fill: luma(120), strike(str(l), stroke: black+1pt,extent: 15pt)))
      table-content.push(text(fill: luma(120), strike(str(r), stroke: black+1pt,extent: 15pt)))
    } else {
      table-content.push(text(weight: "medium", str(l)))
      table-content.push(text(weight: "bold", fill: rgb("2e7d32"), str(r)))
    }
  }
}
  let header = ($#a$,$#b$) + if numbers {($n$,)}
  let footer = if sums {if numbers {(sum-symbol,strong(str(inta*intb)),$inta times intb$)} else {{(sum-symbol,strong(str(inta*intb)))}}}

  show ".":sep
  align(center)[
    #block(
      radius: 4pt,
      clip: true,
      stroke: stroke,
      table(
        columns: 2 + if numbers {1},
        align: center + horizon,
        inset: (x:10pt,y:5pt),
        stroke: (x, y) => if y == 0 { (bottom: 1pt + black) } else { 0.4pt + luma(200) },//
        fill: (x, y) => {
          if y == 0 { return luma(240) }
          if y == 1 and rule { return none }
          let row-idx = y - 1 + if rule {-1}
          if row-idx < rows.len() and numbers {
            let (_, _, is-even,n) = rows.at(row-idx)
            return if is-even { fill-even } else { fill-odd }
          } else if row-idx < rows.len() {
            let (_, _, is-even) = rows.at(row-idx)
            return if is-even { fill-even } else { fill-odd }
          }
          return none
        },
        ..header,
        ..table-content,
        ..footer
      )
    )
    #if show-equality [
      // #v(2pt)
      $inta times intb #if numbers {$= (#decomp.map(str).join(" + ")) times intb$} = #sum-terms.map(str).join(" + ") = bold(#[#(inta * intb)])$

      #if type(a) != int or type(b) != int {$#a times #b = bold(#[#calc.round(floata * floatb,digits: 6)])$}
      
    ]
  ]
}

// Alias de la multiplication binaire
#let mul-ethiopienne = binary-multiplication

// ─────────────────────────────────────────────────────────────────────────────
// Exemples et tests
// ─────────────────────────────────────────────────────────────────────────────
// #binary-multiplication(23, 14, show-equality: false,sums: true, sum-symbol: "Result:")
// #binary-multiplication("2.7", 1.3,numbers: true,rule: true,sums: true, )
#binary-multiplication(13,27,numbers: true,rule: false,sums: true)


== Multiplication Japonaise (Visuelle par Lignes)

// Représente chaque chiffre par un faisceau de droites parallèles. Les intersections indiquent le nombre d'unités, dizaines et centaines.

// Multiplication japonaise (méthode des traits)
//
//   • deux couleurs distinctes (bleu / rouge par défaut) pour les traits
//     issus de chacun des deux nombres ;
//   • les traits représentant un chiffre 0 sont gris et pointillés ;
//   • l'épaisseur dépend du rang : unités 0.5pt, dizaines 1pt, centaines 1.5pt…
//   • option improved : pour un chiffre ≥ 5, cinq traits sont remplacés par un
//     seul trait de la couleur opposée, placé au centre du groupe (les traits
//     restants s'organisent autour) ; en mode points, les intersections de ce
//     trait sont matérialisées par un gros point (5×, voire 25×) ;
//   • les nombres décimaux sont acceptés (fr : séparateur « , » ou « . ») :
//     le dessin ignore le séparateur, mais l'explication du calcul en tient
//     compte (sommes des diagonales, virgule du résultat).

// Multiplication japonaise (méthode des traits).
// Représente chaque chiffre par un faisceau de droites parallèles. Les intersections indiquent le nombre d'unités, dizaines et centaines.
// Exemples d'utilisation :
// ```example
// Utilisation basique
// #lines-multiplication(23, 14)
// ```
// ```example
// Option « improved » (5 traits remplacés par un trait plus sombre et épais)
// #lines-multiplication(78, 67, improved: true,)
// ```
// ```example
// Avec les intersections visibles — le point noir compte pour 5 et le blanc pour 25 :
// #lines-multiplication(7.82, 67.9, improved: true, points: true, print: true, digits-spread-factor: .5, lines-spread-factor: .7, counts-y-spread-factor: .7,)
// ```
// -> content
#let lines-multiplication(
  // premier facteur -> int | float | decimal | str
  a, 
  // second facteur -> int | float | decimal | str
  b,
  // couleur des traits issus de a -> color
  color-a: rgb("2563eb"),
  // couleur des traits issus de b -> color
  color-b: rgb("dc2626"),
  // couleur des traits « zéro » pointillés -> color
  color-zero: gray,
  // facteur d'échelle du dessin -> int | float
  draw-scale: .8,
  // affichage de la virgule ou du point comme séparateur décimal -> bool
  fr:true,
  // couleurs des points d'intersection valant 1, de ceux des unités vers ceux des rangs élevés -> array | color
  points-color: (green, purple, orange, olive, black, red, blue,),
  // couleur des blocs autour des points d'intersection -> color | none
  color-blocs: none,
  // coefficient d'échelle des blocs -> float | int
  blocs-scale:0.7,
  // épaisseur des traits des unités -> length
  lines-thickness: 0.6pt,
  // épaisseur minimale (chiffres décimaux) -> length
  min-thickness: 0.4pt,
  // points aux intersections (ex-mode « Baguettes ») -> bool
  points: false,
  // facteur d'écartement des chiffres -> float
  digits-spread-factor: 1,
  // facteur d'écartement des lignes pour un chiffre -> float
  lines-spread-factor: 1,
  // facteur d'écartement horizontal des résultats par zone -> float
  counts-x-spread-factor:1,
  // facteur d'écartement vertical des résultats par zone -> float
  counts-y-spread-factor:1,
  // remplace 5 traits par un seul trait de la couleur opposée (chiffres ≥ 5) -> bool
  improved: false,
  // couleur des traits valant 5 pour le 1er facteur -> color | none
  color-5a:none,
  // couleur des traits valant 5 pour le 1er facteur -> color | none
  color-5b:none,
  // couleur des points d'intersection valant 5 -> color
  color-5: black,
  // couleur des points d'intersection valant 25 (deux traits condensés croisés) -> color
  color-25: white,
  // blocs indiquant les rangs, true/false or "rect"/"circ" -> bool | str
  blocs: false,
  // affiche sous le dessin les sommes, retenues et chiffres -> bool
  counts: true,
  // affichage du résultat après prise en compte des retenues -> bool
  result: true,
  // ne trace que le dessin -> bool
  only-drawing: false,
  // n'affiche que l'explication du calcul -> bool
  only-calculation: false,
  // affichage de l'égalité obtenue -> bool
  equal: true,
  // affichage des retenues -> bool
  carries:true,
  // affichage de la somme -> bool
  sum:true,
  // mode impression pour avoir les traits de même épaisseur et les traits valant 5 d'épaisseur doublée -> bool
  print: false,
) = {
  let color-5a = if color-5a == none {color-a.darken(40%)} else {color-5a}
  let color-5b = if color-5b == none {color-b.darken(40%)} else {color-5b}
  let sep = if fr {","} else {"."}
  
  let A = _parse-nombre(a, "le premier facteur", fr:fr)
  let B = _parse-nombre(b, "le second facteur", fr:fr)
  if only-calculation and only-drawing {
    panic("mul-japonaise: « only-drawing » et « only-calculation » sont incompatibles")
  }
  let lc = if type(points-color) == color { (points-color,) } else { points-color }

  let Da = A.digits.clusters().map(int)
  let Db = B.digits.clusters().map(int)
  let La = Da.len()
  let Lb = Db.len()
  let MD = La + Lb - 2
  let color-diag = m => lc.at(calc.rem(MD - m,lc.len()), default: black)
  let dec-tot = A.ndec + B.ndec
  let produit = int(A.digits) * int(B.digits)

  // Sommes par « diagonale » (m = 0 : chiffres de tête · m = MD : unités)
  let S = range(MD + 1).map(m => {
    let acc = 0
    for i in range(calc.max(0, m - Lb + 1), calc.min(m, La - 1) + 1) {
      acc += Da.at(i) * Db.at(m - i)
    }
    acc
  })

  // Retenues et chiffres du résultat (des unités vers les rangs élevés)
  let totaux = ()
  let chiffres = ()
  let retenues = ()
  let r = 0
  for m in range(MD, -1, step: -1) {
    let t = S.at(m) + r
    totaux.push(t)
    chiffres.push(calc.rem(t, 10))
    r = calc.quo(t, 10)
    retenues.push(r)
  }
  let total = m => totaux.at(MD - m)
  let chiffre = m => chiffres.at(MD - m)
  let r-sortante = m => retenues.at(MD - m)
  let r-entrante = m => if m == MD { 0 } else { retenues.at(MD - m - 1) }

  // ─── Explication du calcul ───────────────────────────────────────────────
  // Chaque diagonale r (r = 0 pour les unités) fournit un terme
  // S × 10^(r − ndéc(a) − ndéc(b)) : c'est ici que les décimales interviennent.
  let explication = align(center, grid(
    columns: (auto),
    column-gutter: 0.2em,
    row-gutter: 0.35em,
    align: center,
    if sum {range(MD, -1, step: -1).map(rr => {
      let m = MD - rr
      let s = S.at(m)
      let e = rr - dec-tot
      let col = lc.at(rr, default: black)
      let valeur = if e >= 0 { str(s * _puiss10(e)) } else { _decalage-virgule(s, -e, fr: fr) }
      (
        // $#text(fill: col, weight: "bold")[#s] times #calc.pow(10,e)= #valeur$
        $#text(fill: col, weight: "bold")[#valeur]$
      )
    }).join($thin + thin$)},
    if sum {grid.hline(stroke: 0.5pt)} else {v(-1em)},
    grid.cell(inset:(top:3pt))[$#text(weight: "bold")[$#A.affichage times #B.affichage= #_decalage-virgule(produit, dec-tot, fr:fr)$]$],
  ))

  // ─── Le dessin ───────────────────────────────────────────────────────────
  let dessin = cetz.canvas({
    import cetz.draw:*
    // scale(draw-scale)
    let U = draw-scale
    let ec = (2.5 * draw-scale) * digits-spread-factor
    let ta = (1 * U, 5 * U)
    // Point de croisement des groupes de traits (i, j) — repère « en losange »
    let P = (i, j) => (
      ta.at(0) + (i + j) * ec * U,
      ta.at(1) + (i - j) * ec * U,
    )
    let ext = 0.75
    // Épaisseur selon le rang : unités → lines-thickness, dizaines → 2×, etc.
    let epaisseur = place => if print {if place >= 0 {2*lines-thickness} else {2*min-thickness}} else {calc.max(lines-thickness * (place + 1), min-thickness)}
    // if print {calc.max(2*lines-thickness * (place + 1), 2*min-thickness)} else {calc.max(lines-thickness * (place + 1), min-thickness)}
    let espacement = place => (0.10 + 0.05 * calc.max(place + 1, 1))*lines-spread-factor
    let place-a = i => La - 1 - i - A.ndec
    let place-b = j => Lb - 1 - j - B.ndec
    // Traits d'un chiffre : liste de (décalage, poids).
    //   poids 1 = trait normal · poids 5 = trait « condensé » (option improved :
    //   un trait de la couleur opposée, centré dans le groupe, remplace 5 traits).
    let decalages = (d, place) => if d <= 0 {
      ((0, 1),)
    } else if improved and d >= 5 {
      let n = d - 4
      let i-cinq = calc.quo(n - 1, 2)
      range(n).map(l => (
        (l - (n - 1) / 2) * espacement(place),
        if l == i-cinq { 5 } else { 1 },
      ))
    } else {
      range(d).map(l => ((l - (d - 1) / 2) * espacement(place), 1))
    }

    // Losanges autour de chaque diagonale (option)
    if blocs != false or color-blocs != none {
      let cb = if color-blocs == none { black } else { color-blocs }
      let h = blocs-scale * U
      for m in range(MD + 1) {
        let it = calc.min(m, La - 1)
        let ib = calc.max(0, m - Lb + 1)
        let pt = P(it, m - it)
        let pb = P(ib, m - ib)
        if blocs == "rect" or blocs == true { draw.line(
          (pt.at(0) - h, pt.at(1) + h),
          (pt.at(0) + h, pt.at(1) + h),
          (pb.at(0) + h, pb.at(1) - h),
          (pb.at(0) - h, pb.at(1) - h),
          close: true,
          stroke: (paint: cb, thickness: 0.5pt),
        )}
        if blocs == "circ" { draw.circle((pt.at(0), (pt.at(1)+pb.at(1))/2), radius:(h, pt.at(1)-pb.at(1) -2*h),stroke: (paint: cb, thickness: 0.5pt),)}
      }
    }

    // Traits du premier facteur (direction ↘, étiquettes en haut à gauche)
    for i in range(La) {
      let d = Da.at(i)
      let place = place-a(i)
      let th = epaisseur(place)
      let centre = P(i, 0)
      let t-max = (Lb - 1) * ec + ext
      for (q, w) in decalages(d, place) {
        let cx = centre.at(0) + q * U
        let cy = centre.at(1) + q * U
        // trait condensé (poids 5) : couleur du facteur opposé
        let coul = if d == 0 { color-zero } else if w == 5 and not print { color-5a } else { color-a }
        line(
          (cx - ext * U, cy + ext * U),
          (cx + t-max * U, cy - t-max * U),
          stroke: if d == 0 {
            (paint: coul, thickness: calc.min(.5pt,th), dash: "dashed")
          } else {
            (paint: coul, thickness: if print and w == 5 {th*2} else if w == 5 {th*2} else {th})
          },
        )
      }
      content(
        (centre.at(0) - 1.05 * U, centre.at(1) + 1.05 * U),
        text(fill: if d == 0 { color-zero } else { color-a }, weight: "bold", size: 0.9em)[#d],
        anchor: "south-east",
      )
    }

    // Traits du second facteur (direction ↗, étiquettes à droite)
    for j in range(Lb) {
      let d = Db.at(j)
      let place = place-b(j)
      let th = epaisseur(place)
      let centre = P(0, j)
      let t-max = (La - 1) * ec + ext
      for (q, w) in decalages(d, place) {
        let cx = centre.at(0) + q * U
        let cy = centre.at(1) - q * U
        // trait condensé (poids 5) : couleur du facteur opposé
        let coul = if d == 0 { color-zero } else if w == 5 and not print { color-5b } else { color-b }
        line(
          (cx - ext * U, cy - ext * U),
          (cx + t-max * U, cy + t-max * U),
          stroke: if d == 0 {
            (paint: coul, thickness: calc.min(.5pt,th), dash: "dashed")
          } else {
            (paint: coul, thickness: if print and w == 5 {th*2} else if w == 5 {th*2} else {th})
          },
        )
      }
      content(
        (centre.at(0) + (t-max + 0.35) * U, centre.at(1) + (t-max + 0.35) * U),
        text(fill: if d == 0 { color-zero } else { color-b }, weight: "bold", size: 0.9em)[#d],
        anchor: "south-west",
      )
    }

    // Points aux intersections (option, couleur de la diagonale)
    if points {
      for i in range(La) {
        if Da.at(i) > 0 {
          for j in range(Lb) {
            let place = place-b(j)
            if Db.at(j) > 0 {
              let col = color-diag(i + j)
              for (q1, w1) in decalages(Da.at(i), place-a(i)) {
                for (q2, w2) in decalages(Db.at(j), place-b(j)) {
                  let t = q2 + j * ec
                  // poids de l'intersection : 1 (normal), 5 ou 25 (condensé)
                  let poids = w1 * w2
                  let coul-point = if poids == 25 {
                    color-25
                  } else if poids == 5 {
                    color-5
                  } else {
                    col
                  }
                  circle(
                    (P(i, 0).at(0) + (q1 + t) * U, P(i, 0).at(1) + (q1 - t) * U),
                    radius: 0.07*calc.max(U,.75),//epaisseur(place)
                    fill: coul-point,
                    // un fin liseré noir autour du point « 25 » pour le faire
                    // ressortir quelle que soit la couleur choisie
                    stroke: if poids !=1 { (paint: black, thickness: 0.5pt) } else { none },               
                  )
                }
              }
            }
          }
        }
      }
    }

    // if draw-scale < .8 {set-origin((- (La + Lb - 3)*draw-scale/1.41,0))}

    // Calcul détaillé sous le dessin : sommes, retenues, chiffres du produit
    if counts {
      let ec-calc = if draw-scale != 0.8 or digits-spread-factor != 1 {ec / (draw-scale*digits-spread-factor)} else {ec}
      
      // ancrage vertical : sur la géométrie du dessin (ec du dessin)
      let min-y = (5 - (Lb - 1) * ec) * U 
      let y-q = min-y - ec-calc * U * counts-y-spread-factor
      let y-c = y-q - 0.75 * U  * counts-y-spread-factor
      let y-r = y-q - ec-calc * U * counts-y-spread-factor
      // horizontal : espacement élargi (ec-calc), puis recentrage
      // du bloc de colonnes sur l'axe médian des diagonales
      // let x-m = m => (1 + m * ec) * U
      let dec-x = (ec-calc * counts-x-spread-factor  - ec) * MD / 2
      let x-m = m => (1 + m * ec-calc * counts-x-spread-factor  - dec-x) * U
      for m in range(MD + 1) {
        let col = color-diag(m)
        let entree = r-entrante(m)
        let sortie = r-sortante(m)
        let y0 = if entree > 0 and m > 0 { y-c } else { y-q }
        // somme de la diagonale
        content((x-m(m), y-q), text(fill: col, weight: "bold",)[#S.at(m)])
        // total (somme + retenue entrante), affiché seulement si utile
        if entree > 0 and m > 0 and carries {
          content((x-m(m), y-c), text(fill: col)[#total(m)])
        }
        if result {// flèche verticale
        line(
          (x-m(m), y0 - 0.25 * U),
          (x-m(m), y-r + 0.35 * U),
          stroke: 0.5pt,
          fill:black,
          mark: (end: "stealth",anchor:"center",scale:.8),
        )}
        // flèche de retenue vers la colonne suivante (plus significative)
        if m > 0 and sortie > 0 and carries {
          let from = (x-m(m), y0)
          let to = (x-m(m - 1), y-q)
          let dx = to.at(0) - from.at(0)
          let dy = to.at(1) - from.at(1)
          let norm = calc.sqrt(dx * dx + dy * dy)
          let ux = dx / norm
          let uy = dy / norm
          let c = 0.6 * U
          line(
            (from.at(0) + ux * c, from.at(1) + uy * c),
            (to.at(0) - ux * c, to.at(1) - uy * c),
            stroke: 0.5pt,
            fill:black,
            mark: (end: "stealth",anchor:"center",scale:.8),
          )
          let milieu = ((from.at(0) + to.at(0)) / 2, (from.at(1) + to.at(1)) / 2)
          content(milieu, text(size: 0.7em, "+" + str(sortie)), frame:"circle", fill:white, padding:0, stroke: none)
        }
        // chiffre du résultat (la 1re colonne affiche le nombre complet),
        // suivi de la virgule si des décimales sont en jeu
        let val = if m == 0 { total(m) } else { chiffre(m) }
        let txt = if dec-tot > 0 and m == MD - dec-tot { str(val) + sep } else { str(val) }
        if result {content((x-m(m), y-r), text(weight: "bold")[#txt])}
      }
    }
  })

  if only-calculation {
    explication
  } else if only-drawing {
    align(center, dessin)
  } else {
    align(center, [#dessin #if equal [#explication]])
  }
}

// Alias
#let mul-japonaise = lines-multiplication

// ─────────────────────────────────────────────────────────────────────────────
// Exemples et tests
// ─────────────────────────────────────────────────────────────────────────────

// == Multiplication de deux entiers

// #lines-multiplication(23, 14)

// == Option « improved » (5 traits remplacés par un trait plus sombre et épais)

// #lines-multiplication(78, 67, improved: true, points: true)

// // Avec les intersections visibles — le point noir compte pour 5 et le blanc pour 25 :

// #lines-multiplication(7.82, 67.9, improved: true, points: true, print: true, digits-spread-factor: .5, lines-spread-factor: .7, counts-y-spread-factor: .7,)

// == Avec des zéros (traits gris pointillés)

// #lines-multiplication("102", "40")

== Avec les intersections visibles et des nombres décimaux  :
#lines-multiplication(7.82, 67.9, improved: true, points: true, print: true, digits-spread-factor: .5, lines-spread-factor: .7, counts-y-spread-factor: .7,)

// == Nombres décimaux

// #lines-multiplication("1.2", "3.4", print: true,)

// == Dessin seul / calcul seul

// #lines-multiplication("52", "13", only-drawing: true,)

// #lines-multiplication("52", "13", only-calculation: true)

= Visuelle

// ─────────────────────────────────────────────────────────────────────────────
// Visualisation d'une multiplication de décimaux : rectangle de dimensions
// a × b, case « 1 × 1 » colorée, traits fins tous les dixièmes (si le facteur
// correspondant est décimal), traits épais toutes les unités, cotations.
// Adapté de PfCVisualisationMulDeci.tex (v0.1).
// ─────────────────────────────────────────────────────────────────────────────

// Visualisation d'une multiplication de décimaux : rectangle de dimensions
// a × b, case « 1 × 1 » colorée, traits fins tous les dixièmes (si le facteur
// correspondant est décimal), traits épais toutes les unités, cotations.
// Exemples d'utilisation :
// ```example
// #area-multiplication("1.5", "1.4")
// ```
// ```example
// #area-multiplication(2, "2.7", unit: 1cm)
// ```
// -> content
#let area-multiplication(
  // premier facteur -> int | float | str
  a,
  // second facteur -> int | float | str
  b,
  // côté d'une unité -> length
  unit: 2cm,
  // couleur des traits des dixièmes -> color
  tenths-color: orange,
  // couleur des traits des unités -> color
  ones-color: rgb("006400"),
  // remplissage de la case « 1×1 » (auto : version claire de ones-color) -> color | auto
  unit-color: auto,
  // traits des dixièmes suivant a : auto (tracés si a est décimal) | true | false -> bool | auto
  tenths-a: auto,
  // traits des dixièmes suivant b : auto (tracés si b est décimal) | true | false -> bool | auto
  tenths-b: auto,
  // affichage de la virgule ou du point comme séparateur décimal -> bool
  fr: true,
  // épaisseur des traits des dixièmes -> length
  tenths-thickness: 0.5pt,
  // épaisseur des traits des unités -> length
  units-thickness: 1.2pt,
  show-result:true,
) = {
  let sep = if fr {","} else {"."}
  show ".":sep
  let B = _parse-nombre(a, "le premier facteur", fr: fr)
  let A = _parse-nombre(b, "le second facteur", fr: fr)
  let va = int(A.digits) / _puiss10(A.ndec)
  let vb = int(B.digits) / _puiss10(B.ndec)
  let u = unit / 1cm
  let largeur = va * u
  let hauteur = vb * u
  let dix-a = if tenths-a == auto { A.ndec > 0 } else { tenths-a }
  let dix-b = if tenths-b == auto { B.ndec > 0 } else { tenths-b }
  let fond = if unit-color == auto { ones-color.lighten(70%) } else { unit-color }

  align(center, cetz.canvas({
    import cetz.draw:*
    // case « 1 × 1 »
    rect((0, 0), (u, u), fill: fond, stroke: none)
    // traits fins : un tous les dixièmes
    if dix-a {
      let n = int(calc.floor(va * 10 + 0.000001))
      for k in range(n + 1) {
        let x = k * u / 10
        line((x, 0), (x, hauteur), stroke: (paint: tenths-color, thickness: tenths-thickness))
      }
    }
    if dix-b {
      let n = int(calc.floor(vb * 10 + 0.000001))
      for k in range(n + 1) {
        let y = k * u / 10
        line((0, y), (largeur, y), stroke: (paint: tenths-color, thickness: tenths-thickness))
      }
    }
    // traits épais : un par unité
    for k in range(int(calc.floor(va + 0.000001)) + 1) {
      let x = k * u
      line((x, 0), (x, hauteur), stroke: (paint: ones-color, thickness: units-thickness))
    }
    for k in range(int(calc.floor(vb + 0.000001)) + 1) {
      let y = k * u
      line((0, y), (largeur, y), stroke: (paint: ones-color, thickness: units-thickness))
    }
    // cotation du bas (facteur a)
    let d = 0.5
    line((0, -d), (largeur, -d), stroke: 0.6pt, mark: (symbol: "stealth"), fill:black)
    line((0, 0), (0, -d - 0.15), stroke: 0.4pt)
    line((largeur, 0), (largeur, -d - 0.15), stroke: 0.4pt)
    content((largeur / 2, -d - 0.1), text(weight: "bold")[#A.affichage], anchor: "north")
    // cotation à gauche (facteur b)
    line((-d, 0), (-d, hauteur), stroke: 0.6pt, mark: (symbol: "stealth"), fill:black)
    line((0, 0), (-d - 0.15, 0), stroke: 0.4pt)
    line((0, hauteur), (-d - 0.15, hauteur), stroke: 0.4pt)
    content((-d - 0.25, hauteur / 2), std.rotate(-90deg)[#text(weight: "bold")[#B.affichage]])

    if show-result {
      content((if A.ndec != 0 or B.ndec !=0 {-d}+largeur/2,-d -.8), $ #a times #b #if A.ndec != 0 or B.ndec !=0 {$= #if B.ndec != 0 {$#B.digits times calc.pow(#10, #(-1*B.ndec))$} else {B.digits} times #if A.ndec != 0 {$#A.digits times calc.pow(#10,#(-1*A.ndec))$} else {A.digits} =#(int(A.digits) * int(B.digits)) times calc.pow(#10, #(-1*(A.ndec+B.ndec)))$} = #calc.round(float(a)*float(b),digits:A.ndec+B.ndec)$)
    }
  })
)
}

// ─────────────────────────────────────────────────────────────────────────────
// Exemples et tests
// ─────────────────────────────────────────────────────────────────────────────

== Visualisation d'une multiplication de décimaux

#area-multiplication("1.5", "3.42")

// #area-multiplication(2, "2.7", unit: 1cm)

// == Visualisation avec dixièmes forcés sur les deux axes

// #area-multiplication(2, 2, tenths-a: true, tenths-b: true)
// // #area-multiplication(2, 2, )