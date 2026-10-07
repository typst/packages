#set page(margin:(y:1cm))
#set text(lang:"fre")

= Additions
// `addition(nombres, show-carry: true, couleur:red, size:1em, hide-result:false, couleur-cadre:blue.mix(gray), couleur-solution:red, type-mask:"rect", liste:(), solution:false, space:1fr,)`

// Pose l'addition de 2 ou plusieurs nombres avec possibilité de cacher la ligne de résultat avec `hide-result`, une `liste` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc
// 
// *Exemples :* 
// ```example
// #addition(12.5, 3.75, .8, 14.2)
// ```
// ```example
// #addition(12.5, 3.75, .8, 14.2,liste:(2,10,19))
// ```
// 
// -> content
#let addition(
  // Montrer ou non les retenues -> boolean
  show-carry: true, 
  // couleur des retenues -> color
  couleur:red,
  // Taille des colonnes -> length
  size:1em,
  // Affichage des nombres à la française "," ou pas -> boolean
  fr: true,
  // Cache les retenues et le résultat -> boolean
  hide-result:false,
  // Couleur du cadre des chiffres cachés -> color
  couleur-cadre:blue.mix(gray),
  // Couleur des chiffres cachés si solution = true -> color
  couleur-solution:red,
  // Comment les chiffres sont cachés : soient "rect" pour un rectangle arrondi soit ... -> str
  type-mask:"rect",
  // liste des chiffres à cacher dans une addition à trous -> array
  liste:(),
  // Montrer les retenues et le résultat en mode hide-result (pour les corrections) -> boolean
  solution:false,
  // Signe d'égalité, false ou true [=] ou un symbole \$ = \$ -> boolean | content
  signe:false,
  // Espacement si plusieurs sur la même ligne -> length
  space:1fr,
  // taille du des chiffres : 1em -> length
  texte:1em,
  // -> array | arguments
  ..args
) = {
  let decimal-sep = if fr {[,]} else {[.]}
  // Récupération des nombres (arguments positionnels ou tableau unique)
  let nombres = args.pos()
  if nombres.len() == 1 and type(nombres.at(0)) == array {
    nombres = nombres.at(0)
  }
  if nombres.len() < 2 {
    panic("La fonction addition nécessite au moins deux nombres.")
  }

  set text(texte)

  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: couleur-cadre + .75pt, text(if solution == false { white } else { couleur-solution }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { couleur-solution }, x)))
  }

  // Traitement et nettoyage des chaînes de caractères
  let list-str = nombres.map(str)
  let list-parties = list-str.map(s => s.split("."))
  let list-entieres = list-parties.map(p => p.at(0))
  let list-decimales = list-parties.map(p => if p.len() > 1 { p.at(1) } else { "" })

  let max-decimales = calc.max(..list-decimales.map(d => d.len()))
  let max-entieres = calc.max(..list-entieres.map(e => e.len()))

  // Égalisation des longueurs (remplissage par des zéros)
  if max-decimales > 0 {
    list-decimales = list-decimales.map(d => d + "0" * (max-decimales - d.len()))
  }
  list-entieres = list-entieres.map(e => "0" * (max-entieres - e.len()) + e)

  let list-chiffres = range(nombres.len()).map(i => list-entieres.at(i) + list-decimales.at(i))

  // Calcul exact du résultat
  let total-sum = calc.round(nombres.sum(), digits: max-decimales)
  let str-resultat = str(total-sum)
  let parties-resultat = str-resultat.split(".")
  let entiere-resultat = parties-resultat.at(0)
  let decimale-resultat = if parties-resultat.len() > 1 { parties-resultat.at(1) } else { "" }

  // Calcul des retenues colonne par colonne (de droite à gauche)
  let nb-cols-chiffres = max-entieres + max-decimales
  let carries-generated = (0,) * nb-cols-chiffres
  let current-carry = 0

  for i in range(nb-cols-chiffres) {
    let k = nb-cols-chiffres - 1 - i
    let col-sum = current-carry
    for term-chiffres in list-chiffres {
      col-sum += int(term-chiffres.at(k))
    }
    current-carry = calc.trunc(col-sum / 10)
    carries-generated.at(k) = current-carry
  }

  // Décalage des retenues au-dessus de la colonne suivante à gauche
  let carries-above = ()
  for k in range(nb-cols-chiffres) {
    if k + 1 < nb-cols-chiffres {
      carries-above.push(carries-generated.at(k + 1))
    } else {
      carries-above.push(0)
    }
  }

  let pos-virgule = max-entieres
  let decalage = calc.max(0, entiere-resultat.len() - max-entieres)
  let largeur-totale = nb-cols-chiffres + (if max-decimales > 0 { 1 } else { 0 }) + decalage
  let colonnes = largeur-totale + 1

  let lignes = ()

  // Ligne des retenues
  let has-carry-row = show-carry and ((not hide-result and liste == ()) or solution)
  if has-carry-row {
    let retenue-row = ([],)
    for i in range(decalage) {
      retenue-row.push([])
    }
    for i in range(nb-cols-chiffres) {
      if i == pos-virgule and max-decimales > 0 {
        retenue-row.push(table.cell(inset: (x: -1pt))[])
      }
      let r-val = if i < carries-above.len() { carries-above.at(i) } else { 0 }
      if r-val > 0 {
        retenue-row.push(text(size: 0.8em, fill: couleur)[#r-val])
      } else {
        retenue-row.push([])
      }
    }
    lignes.push(retenue-row)
  }

  // Construction des lignes de nombres
  let creer-ligne-nombre = (signe, idx) => {
    let ligne = (signe,)
    let entiere = list-entieres.at(idx)
    let decimale = list-decimales.at(idx)
    let orig-parties = list-str.at(idx).split(".")
    let orig-ent = orig-parties.at(0)
    let orig-dec = if orig-parties.len() > 1 { orig-parties.at(1) } else { "" }

    for i in range(decalage) {
      ligne.push([])
    }

    for (c-idx, digit) in entiere.clusters().enumerate() {
      let is-padded = (c-idx < max-entieres - orig-ent.len())
      if is-padded {
        ligne.push([])
      } else {
        ligne.push(digit)
      }
    }

    if max-decimales > 0 {
      ligne.push(table.cell(inset: (x: -1pt))[#decimal-sep])
      for (c-idx, digit) in decimale.clusters().enumerate() {
        let is-padded = (c-idx >= orig-dec.len())
        if is-padded {
          ligne.push([0])
        } else {
          ligne.push(digit)
        }
      }
    }
    return ligne
  }

  for idx in range(nombres.len()) {
    let signe = if idx > 0 { text(.8em)[$ + $] } else { [] }
    lignes.push(creer-ligne-nombre(signe, idx))
  }

  // Ligne du résultat
  let ligne-resultat = (if signe == true [=] else if signe != false {signe} else [],)
  for digit in entiere-resultat.clusters() {
    ligne-resultat.push(digit)
  }
  if max-decimales > 0 {
    ligne-resultat.push(table.cell(inset: (x: -1pt))[#decimal-sep])
    if decimale-resultat.len() > 0 {
      for digit in decimale-resultat.clusters() {
        ligne-resultat.push(digit)
      }
    } else {
      for i in range(max-decimales) {
        ligne-resultat.push([0])
      }
    }
  }
  lignes.push(ligne-resultat)

  let ymax = lignes.len() - 1

  // Cache le résultat si demandé
  if hide-result {
    for i in range(1, lignes.at(ymax).len()) {
      lignes.at(ymax).at(i) = mask(lignes.at(ymax).at(i))
    }
  }

  // Application des masques pour les additions à trous
  let carry-line = if has-carry-row { lignes.remove(0) } else { none }
  let termes = lignes.flatten()

  for x in liste {
    if x < termes.len() {
      termes.at(x) = mask(termes.at(x))
    }
  }

  if carry-line != none {
    termes = carry-line + termes
  }

  // Rendu sous forme de tableau Typst
  box(table(
    columns: colonnes * (size,),
    stroke: none,
    inset: (x: 2pt, y: 3pt),
    align: center + horizon,
    ..termes,
    table.hline(stroke: 1pt, y: ymax)
  ))+h(space)
}

// Version avec étapes détaillées pour deux entiers
// 
// *Exemples :* 
// #example(`#_addition-detaillee(245, 167)`,ratio:.4)
// 
// 
// -> content
#let _addition-detaillee(
  // -> int
  nombre1, 
  // -> int
  nombre2, 
  // couleur des retenues -> color
  couleur:red
) = {
  let str1 = str(nombre1)
  let str2 = str(nombre2)
  let max-len = calc.max(str1.len(), str2.len())
  
  str1 = "0" * (max-len - str1.len()) + str1
  str2 = "0" * (max-len - str2.len()) + str2
  
  let etapes = ()
  let retenue = 0
  let resultat-partiel = ""
  
  [*Calcul étape par étape de $#str1 + #str2$ :*\ On calcule de la somme de chaque colonne de droite à gauche (unité puis centaine ...)]
  
  for i in range(max-len) {
    let pos = max-len - 1 - i
    let digit1 = int(str1.at(pos))
    let digit2 = int(str2.at(pos))
    let somme = digit1 + digit2 + retenue
    
    let unite = calc.rem(somme, 10)
    let nouvelle-retenue = calc.quo(somme, 10)
    
    resultat-partiel = str(unite) + resultat-partiel
    
    [\ Colonne $#{max-len - pos}$ : $quad #digit1 + #digit2 #{if retenue > 0 [$+ #retenue$ (retenue)]} = #somme$]
    if somme >= 10 [
      → j'écris $#unite$ et je retiens $#nouvelle-retenue$
    ] else [
      → j'écris $#unite$
    ]
    []
    
    retenue = nouvelle-retenue
  }
  
  if retenue > 0 {
    resultat-partiel = str(retenue) + resultat-partiel
    [Retenue finale: $#retenue$]
  }

  // v(-7em)
  [\ #addition(nombre1, nombre2, couleur:red)
   *Résultat final : $#resultat-partiel$* #h(1fr)]
}

= Soustraction avec retenues et/ou emprunts

// soustraction(nombre1, nombre2, show-borrow: true, barre:true, fr:true, couleur:red) avec nombre1 > nombre2 entiers ou flottants ex 3.7

// `soustraction(nombres, show-borrow: true, barre:false, fr:true, couleur:red, size:1em, zeros:true, hide-result:false, couleur-cadre:blue.mix(gray), couleur-solution:red, type-mask:"rect", liste:(), solution:false, space:1fr,)` 

// Pose la soustraction de 2 ou plusieurs nombres avec possibilité de cacher la ligne de résultat avec `hide-result`, une `liste` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc
// 
// *Exemples :* 
// ```example
// #soustraction(12.5, 3.75)
// ```
// ```example
// #soustraction(121.5, 3.75, .8, 14.2,liste:(2,10,19))
// ```
// 
// -> content
#let soustraction(
  // Montrer ou non les retenues -> boolean
  show-borrow: true, 
  // Si fr:false, montrer ou non le nombre initial barré -> boolean
  barre:false, 
  // Ecriture française ou avec emprunts à l'anglaise -> boolean
  fr:true, 
  // couleur des retenues -> color
  couleur:red,
  // Taille des colonnes -> length
  size:1em,
  // Ajoute ou non des zéros -> boolean
  zeros:true,
  // Cache les retenues et le résultat -> boolean
  hide-result:false,
  // Couleur du cadre des chiffres cachés -> color
  couleur-cadre:blue.mix(gray),
  // Couleur des chiffres cachés si solution = true -> color
  couleur-solution:red,
  // Comment les chiffres sont cachés : soient "rect" pour un rectangle arrondi soit ... -> str
  type-mask:"rect",
  // liste des chiffres à cacher dans une addition à trous -> array
  liste:(),
  // Montrer les retenues et le résultat en mode hide-result (pour les corrections) -> boolean
  solution:false,
  // Signe d'égalité, false ou true [=] ou un symbole \$ = \$ -> boolean | content
  signe:false,
  // taille du des chiffres : 1em -> length
  texte:1em,
  // Espacement si plusieurs sur la même ligne -> length
  space:1fr,
  // -> array | arguments
  ..args
) = {
  // Récupération des nombres (arguments positionnels ou tableau unique)
  let nombres = args.pos()
  if nombres.len() == 1 and type(nombres.at(0)) == array {
    nombres = nombres.at(0)
  }
  if nombres.len() < 2 {
    panic("La fonction soustraction nécessite au moins deux nombres.")
  }

  set text(texte)

  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: couleur-cadre + .75pt, text(if solution == false { white } else { couleur-solution }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { couleur-solution }, x)))
  }

  // Traitement des chaînes de caractères et séparation des parties
  let list-str = nombres.map(str)
  let list-parties = list-str.map(s => s.split("."))
  let list-entieres = list-parties.map(p => p.at(0))
  let list-decimales = list-parties.map(p => if p.len() > 1 { p.at(1) } else { "" })

  let max-decimales = calc.max(..list-decimales.map(d => d.len()))
  let max-entieres = calc.max(..list-entieres.map(e => e.len()))

  // Égalisation des longueurs (remplissage par des zéros)
  if max-decimales > 0 {
    list-decimales = list-decimales.map(d => d + "0" * (max-decimales - d.len()))
  }
  list-entieres = list-entieres.map(e => "0" * (max-entieres - e.len()) + e)

  let list-chiffres = range(nombres.len()).map(i => list-entieres.at(i) + list-decimales.at(i))
  let nb-cols-chiffres = max-entieres + max-decimales
  let pos-virgule = max-entieres

  // Vérification que le résultat n'est pas négatif
  let total-subtrahend = calc.round(nombres.slice(1).sum(), digits: max-decimales)
  let total-result = calc.round(nombres.at(0) - total-subtrahend, digits: max-decimales)
  if total-result < 0 {
    panic("La soustraction donnerait un résultat négatif.")
  }

  let str-resultat = str(total-result)
  let parties-resultat = str-resultat.split(".")
  let entiere-resultat = parties-resultat.at(0)
  let decimale-resultat = if parties-resultat.len() > 1 { parties-resultat.at(1) } else { "" }

  entiere-resultat = "0" * (max-entieres - entiere-resultat.len()) + entiere-resultat
  if max-decimales > 0 {
    decimale-resultat = decimale-resultat + "0" * (max-decimales - decimale-resultat.len())
  }

  // Calcul des emprunts et retenues
  let top-borrows = (0,) * nb-cols-chiffres
  let bottom-carries = (0,) * nb-cols-chiffres
  let M-mod = list-chiffres.at(0).clusters().map(c => int(c))
  let M-orig = list-chiffres.at(0).clusters().map(c => int(c))

  if fr {
    let carry-in = 0
    for i in range(nb-cols-chiffres) {
      let k = nb-cols-chiffres - 1 - i
      let sum-sub = carry-in
      for j in range(1, nombres.len()) {
        sum-sub += int(list-chiffres.at(j).at(k))
      }
      let digit-M = int(list-chiffres.at(0).at(k))
      if digit-M < sum-sub {
        let needed = calc.ceil((sum-sub - digit-M) / 10)
        top-borrows.at(k) = needed
        bottom-carries.at(k) = needed
        carry-in = needed
      } else {
        carry-in = 0
      }
    }
  } else {
    for i in range(nb-cols-chiffres) {
      let k = nb-cols-chiffres - 1 - i
      let sum-sub = 0
      for j in range(1, nombres.len()) {
        sum-sub += int(list-chiffres.at(j).at(k))
      }
      while M-mod.at(k) < sum-sub {
        M-mod.at(k) += 10
        let idx = k - 1
        while idx >= 0 and M-mod.at(idx) == 0 {
          M-mod.at(idx) = 9
          idx -= 1
        }
        if idx >= 0 {
          M-mod.at(idx) -= 1
        }
      }
    }
  }

  let colonnes = nb-cols-chiffres + (if max-decimales > 0 { 1 } else { 0 }) + 1
  let lignes = ()

  let show-carry-cond = show-borrow 

  // 1. Ligne supérieure des retenues (Méthode française)
  let has-top-borrow = fr and show-carry-cond
  if has-top-borrow {
    let top-row = ([],)
    for i in range(nb-cols-chiffres) {
      if i == pos-virgule and max-decimales > 0 {
        top-row.push(table.cell(inset: (x: -3pt))[])
      }
      let b-val = top-borrows.at(i)
      if b-val > 0 {
        top-row.push(pad(left: -.75em, bottom: -1.6em, text(size: 0.7em, fill: couleur)[#b-val]))
      } else {
        top-row.push([])
      }
    }
    if not ((not hide-result and liste == ()) or solution) {top-row = ([],) * top-row.len()}
    lignes.push(top-row)
  }

  // Helper pour la création d'une ligne de nombre
  let creer-ligne-nombre = (signe, idx) => {
    let ligne = (signe,)
    let entiere = list-entieres.at(idx)
    let decimale = list-decimales.at(idx)
    let orig-parties = list-str.at(idx).split(".")
    let orig-ent = orig-parties.at(0)
    let orig-dec = if orig-parties.len() > 1 { orig-parties.at(1) } else { "" }

    for (c-idx, digit) in entiere.clusters().enumerate() {
      let is-padded = (c-idx < max-entieres - orig-ent.len())
      if is-padded {
        ligne.push([])
      } else {
        ligne.push(digit)
      }
    }

    if max-decimales > 0 {
      ligne.push(table.cell(inset: (x: -3pt),if fr [,] else [.]))
      for (c-idx, digit) in decimale.clusters().enumerate() {
        let is-padded = (c-idx >= orig-dec.len())
        if is-padded {
          ligne.push(if zeros {[0]} else {[]})
        } else {
          ligne.push(digit)
        }
      }
    }
    return ligne
  }

  // 2. Lignes du Premier Nombre (Minuende)
  if fr {
    lignes.push(creer-ligne-nombre([], 0))
  } else {
    if barre {
      let line-mod = ([],)
      for i in range(nb-cols-chiffres) {
        if i == pos-virgule and max-decimales > 0 { line-mod.push(table.cell(inset: (x: -3pt))[]) }
        if M-mod.at(i) != M-orig.at(i) {
          line-mod.push(text(size: 0.8em, fill: blue)[#M-mod.at(i)])
        } else {
          line-mod.push([])
        }
      }
      lignes.push(line-mod)

      let line-orig = ([],)
      let orig-ent = list-str.at(0).split(".").at(0)
      for (i, digit) in list-entieres.at(0).clusters().enumerate() {
        if i < max-entieres - orig-ent.len() {
          line-orig.push([])
        } else if M-mod.at(i) != M-orig.at(i) {
          line-orig.push($cancel(#digit)$)
        } else {
          line-orig.push(digit)
        }
      }
      if max-decimales > 0 {
        line-orig.push(table.cell(inset: (x: -3pt),if fr [,] else [.]))
        for (i, digit) in list-decimales.at(0).clusters().enumerate() {
          let idx = max-entieres + i
          if M-mod.at(idx) != M-orig.at(idx) {
            line-orig.push($cancel(#digit)$)
          } else {
            line-orig.push(digit)
          }
        }
      }
      lignes.push(line-orig)
    } else {
      let line-min = ([],)
      let orig-ent = list-str.at(0).split(".").at(0)
      for (i, digit) in list-entieres.at(0).clusters().enumerate() {
        if i < max-entieres - orig-ent.len() {
          line-min.push([])
        } else if show-borrow and M-mod.at(i) != M-orig.at(i) {
          line-min.push(text(size: 0.8em, fill: blue)[#M-mod.at(i)])
        } else {
          line-min.push(digit)
        }
      }
      if max-decimales > 0 {
        line-min.push(table.cell(inset: (x: -3pt),if fr [,] else [.]))
        for (i, digit) in list-decimales.at(0).clusters().enumerate() {
          let idx = max-entieres + i
          if show-borrow and M-mod.at(idx) != M-orig.at(idx) {
            line-min.push(text(size: 0.8em, fill: blue)[#M-mod.at(idx)])
          } else {
            line-min.push(digit)
          }
        }
      }
      lignes.push(line-min)
    }
  }

  // 3. Lignes des termes à soustraire
  for idx in range(1, nombres.len()) {
    lignes.push(creer-ligne-nombre(text(.8em)[$ - $], idx))
  }

  // 4. Ligne inférieure des retenues (Méthode française)
  let has-bottom-carry = fr and show-carry-cond
  if has-bottom-carry {
    let bot-row = ([],)
    for i in range(nb-cols-chiffres) { {
      if i == pos-virgule and max-decimales > 0 {
        bot-row.push(table.cell(inset: (x: -3pt))[])
      }
      let c-val = if i + 1 < nb-cols-chiffres { bottom-carries.at(i + 1) } else { 0 }
      if c-val > 0 {
        bot-row.push(pad(top: -.6em, text(size: 0.7em, fill: couleur.negate())[+#c-val]))
      } else {
        bot-row.push([])
      }
    }}
    if not ((not hide-result and liste == ()) or solution) {bot-row = ([],) * bot-row.len()}
    lignes.push(bot-row)
  }

  // 5. Ligne du résultat
  let ligne-resultat = (if signe == true [=] else if signe != false {signe} else [],)
  let orig-res-ent = str(calc.abs(total-result)).split(".").at(0)
  for (c-idx, digit) in entiere-resultat.clusters().enumerate() {
    let is-padded = (c-idx < max-entieres - orig-res-ent.len())
    if is-padded {
      ligne-resultat.push([])
    } else {
      ligne-resultat.push(digit)
    }
  }
  if max-decimales > 0 {
    ligne-resultat.push(table.cell(inset: (x: -3pt),if fr [,] else [.]))
    for digit in decimale-resultat.clusters() {
      ligne-resultat.push(digit)
    }
  }
  lignes.push(ligne-resultat)

  let ymax = lignes.len() - 1

  // Application du masque de résultat caché
  if hide-result {
    for i in range(1, lignes.at(ymax).len()) {
      // if lignes.at(ymax).at(i) != [] {
        lignes.at(ymax).at(i) = mask(lignes.at(ymax).at(i))
      // }
    }
  }

  // Extraction des retenues pour l'exercice à trous
  let top-borrow-line = if has-top-borrow { lignes.remove(0) } else { none }
  let bot-carry-line = if has-bottom-carry { lignes.remove(lignes.len() - 2) } else { none }

  let termes = lignes.flatten()

  for x in liste {
    if x < termes.len() and termes.at(x) != [] {
      termes.at(x) = mask(termes.at(x))
    }
  }

  if top-borrow-line != none {
    termes = top-borrow-line + termes
  }
  if bot-carry-line != none {
    let idx-res = termes.len() - colonnes
    termes = termes.slice(0, idx-res) + bot-carry-line + termes.slice(idx-res)
  }

  // Hauteurs de lignes
  let table-rows = ()
  if has-top-borrow { table-rows.push(0pt) }
  table-rows += (auto,) * (nombres.len() + (if not fr and barre { 1 } else { 0 }))
  if has-bottom-carry { table-rows.push(5pt) }
  table-rows.push(auto)

  // Rendu du tableau final
  box(table(
    columns: colonnes * (size,),
    stroke: none,
    rows: table-rows,
    inset: (x: 3pt, y: 4pt),
    align: center + horizon,
    ..termes,
    table.hline(stroke: 1pt, y: ymax)
  ))+h(space)
}

// Version avec étapes détaillées pour la soustraction à l'anglaise (avec emprunts et non retenues)
// 
// *Exemples :* 
// #example(`#_soustraction-detaillee(121.5, 14.2)`,ratio:.8)
// 
// 
// -> content
#let _soustraction-detaillee(
  // -> int | float
  nombre1, 
  // -> int | float
  nombre2
) = {
  if nombre1 < nombre2 {
    [*Erreur* : Le premier nombre doit être plus grand que le second pour éviter un résultat négatif.]
    return
  }
  
  let str1 = str(nombre1)
  let str2 = str(nombre2)
  
  // Traitement similaire à la fonction principale pour l'alignement
  let parties1 = str1.split(".")
  let entiere1 = parties1.at(0)
  let decimale1 = if parties1.len() > 1 { parties1.at(1) } else { "" }
  
  let parties2 = str2.split(".")
  let entiere2 = parties2.at(0)
  let decimale2 = if parties2.len() > 1 { parties2.at(1) } else { "" }
  
  let max-decimales = calc.max(decimale1.len(), decimale2.len())
  if max-decimales > 0 {
    decimale1 = decimale1 + "0" * (max-decimales - decimale1.len())
    decimale2 = decimale2 + "0" * (max-decimales - decimale2.len())
  }
  
  let max-entieres = calc.max(entiere1.len(), entiere2.len())
  entiere1 = "0" * (max-entieres - entiere1.len()) + entiere1
  entiere2 = "0" * (max-entieres - entiere2.len()) + entiere2
  
  let chiffres1 = entiere1 + decimale1
  let chiffres2 = entiere2 + decimale2
  let chiffres1-modifies = chiffres1.clusters().map(c => int(c))
  
  [*Calcul étape par étape de $#nombre1 - #nombre2$ avec emprunts :*]

  v(-2em)
  grid(columns: (3fr,1fr),column-gutter: 1fr, {for i in range(chiffres1.len()) {
    let pos = chiffres1.len() - 1 - i
    let digit1-original = int(chiffres1.at(pos))
    let digit1 = chiffres1-modifies.at(pos)
    let digit2 = int(chiffres2.at(pos))
    let position-desc = if pos >= max-entieres { "décimale " + str(pos - max-entieres + 1) } else { "entière " + str(max-entieres - pos) }
    
    if digit1 < digit2 {
      [\ Chiffre de la partie #{position-desc} : $#digit1 < #digit2$, il faut emprunter]
      [\ → $#digit1-original$ devient $#(digit1 + 10)$, le chiffre précédent diminue de $1$]
      [\ → $#(digit1 + 10) - #digit2 = #(digit1+10 - digit2)$]
      
      // Emprunter au chiffre suivant
      if pos > 0 {
        chiffres1-modifies.at(pos - 1) -= 1
      }
    } else {
      [\ Chiffre de la partie  #{position-desc} : $#digit1 - #digit2 = #(digit1 - digit2)$]
    }
    []
  }
  
  [\  *Résultat final : $#calc.round(nombre1 - nombre2,digits: max-decimales)$*]}, 
  align(horizon)[#soustraction(nombre1, nombre2)])
  
}

= Multiplications

// `multiplication(a, b, mode:"g", sym:true, fr:true, spread:1em, size:auto, hide-result:false, couleur-cadre:blue.mix(gray), couleur-solution:red, type:"rect", liste:(), solution:false, space:1fr,)` 

// Pose la multiplication de 2 nombres entiers ou décimaux avec possibilité de cacher les lignes avec `hide-result`, une `liste` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc
// 
// *Exemples :* #v(6em)
// ```example
// #multiplication(12.5, 3.75)
// ```
// ```example
// #multiplication(1215, 142,liste:(3,12,19,36),type-mask: "line",)
// ```
// 
// -> content
#let multiplication(
  // -> int | float
  a, 
  // -> int | float
  b,
  // Présentation des décalages : "g" (défaut) pour 0 en gris, "0" pour des 0 normaux, "p" pour des petits points et "gp" pour des points plus gros, "" ou autre pour rien -> str
  mode: "g",
  // Afficher les + des additions et le égal du résultat si true, seulement les + si "+", seulement le = si "=", rien si false, sinon donner une liste du signe ($+$, $=$) par ex -> boolean | str | array
  sym: true,
  // Mode fr:true, le séparateur décimal est "," sinon "." -> boolean | str
  fr: true,
  // Largeur des colonnes -> length
  size: 1em,
  // Masquer les lignes intermédiaires et le résultat final pour les exercices -> boolean
  hide-result: false,
  // Liste des indices de cases à masquer (pour multiplication à trous) -> array
  liste: (),
  // Afficher ou non la solution dans les masques -> boolean
  solution: false,
  // Type de masque ("rect" ou "line") -> str
  type-mask: "rect",
  // Couleur de la bordure des cadres de masque -> color
  couleur-cadre: blue.mix(gray),
  // Couleur du texte de la solution -> color
  couleur-solution: red,
  // Espacement si plusieurs sur la même ligne -> length
  space: 1fr,
) = {
  let decimal-separator = if fr { "," } else { "." }

  // Organisation des deux facteurs (le plus long en haut)
  let (a, b) = if str(a).len() >= str(b).len() { (a, b) } else { (b, a) }

  let stra = str(a)
  let strb = str(b)

  let pad = if mode == "g" { text(gray)[$ 0 $] }
            else if mode == "0" { [$ 0 $] }
            else if mode == "p" { text(size: 0.8em)[$ thin circle.filled.tiny $] }
            else if mode == "gp" { text(size: 0.8em)[$ circle.filled.small $] }
            else { [] }

  // Fonction de masquage des cases
  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: couleur-cadre + .75pt, text(if solution == false { white } else { couleur-solution }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { couleur-solution }, x)))
  }

  // Séparation partie entière et décimale
  let partiesa = stra.split(".")
  let entierea = partiesa.at(0)
  let decimalea = if partiesa.len() > 1 { partiesa.at(1) } else { "" }

  let partiesb = strb.split(".")
  let entiereb = partiesb.at(0)
  let decimaleb = if partiesb.len() > 1 { partiesb.at(1) } else { "" }
  let decimales = decimalea.len() + decimaleb.len()

  let chiffres1 = entierea + decimalea
  let chiffres2 = entiereb + decimaleb

  let affichea = if partiesa.len() > 1 {
    let decompa = entierea.clusters()
    let derniera = decompa.last() + decimal-separator
    let _ = decompa.pop()
    decompa + (derniera,) + decimalea.clusters()
  } else { stra.clusters() }

  let afficheb = if partiesb.len() > 1 {
    let decompb = entiereb.clusters()
    let dernierb = decompb.last() + decimal-separator
    let _ = decompb.pop()
    decompb + (dernierb,) + decimaleb.clusters()
  } else { strb.clusters() }

  // Calcul du résultat exact en conservant les zéros décimaux
  let prod-int-str = str(int(chiffres1) * int(chiffres2))

  let (entierer, decimaler) = if decimales > 0 {
    let padded = if prod-int-str.len() <= decimales {
      "0" * (decimales - prod-int-str.len() + 1) + prod-int-str
    } else {
      prod-int-str
    }
    let split-pos = padded.len() - decimales
    (padded.slice(0, split-pos), padded.slice(split-pos))
  } else {
    (prod-int-str, "")
  }

  let afficher = if decimales > 0 {
    let decompr = entierer.clusters()
    let dernierr = decompr.last() + decimal-separator
    let _ = decompr.pop()
    decompr + (dernierr,) + decimaler.clusters()
  } else { entierer.clusters() }

  // Calcul des produits partiels (de droite à gauche)
  let d = chiffres2.clusters().map(x => int(x)).rev()
  let c = d.map(x => str(x * int(chiffres1)))

  // Calcul exact de la largeur requise pour chaque ligne intermédiaire
  let max-partial-width = calc.max(
    ..c.enumerate().map(((x, y)) => (if x == 0 { 0 } else { 1 }) + y.len() + x)
  )

  let col = calc.max(
    affichea.len(),
    afficheb.len() + 1,
    max-partial-width,
    if c.len() > 1 { afficher.len() + 1 } else { afficher.len() }
  )

  let (s1, s2) = if sym == true { (text(.7em)[$ + $], text(.7em)[$ = $]) }
                 else if sym == "+" { (text(.7em)[$ + $], [ ]) }
                 else if sym == "=" { ([ ], text(.7em)[$ = $]) }
                 else if sym == false{ ([ ], [ ]) }
                 else {sym}

  // Construction des deux premières lignes
  let row-a = (none,) * calc.max(0, col - affichea.len()) + affichea
  let row-b = (text(.7em)[$ times $],) + (none,) * calc.max(0, col - afficheb.len() - 1) + afficheb

  // Lignes intermédiaires (produits partiels)
  let partial-rows = ()
  if c.len() > 1 {
    for (x, y) in c.enumerate() {
      let line = ()
      if x == 0 {
        line = (none,) * calc.max(0, col - y.len()) + y.clusters() + (pad,) * x
      } else {
        line = (s1,) + (none,) * calc.max(0, col - x - y.len() - 1) + y.clusters() + (pad,) * x
      }
      partial-rows.push(line)
    }
  }

  // Ligne de résultat final (alignée à droite)
  let row-res = if c.len() > 1 {
    (s2,) + (none,) * calc.max(0, col - afficher.len() - 1) + afficher
  } else {
    (none,) * calc.max(0, col - afficher.len()) + afficher
  }

  // Application de hide-result (masque les lignes intermédiaires ET le résultat final)
  if hide-result {
    if partial-rows.len() > 0 {
      partial-rows = partial-rows.map(line => line.map(cell => {
        if cell == none or cell == [] or cell == pad {
          none
        } else if cell == s1 {
          cell
        } else {
          mask(cell)
        }
      }))
    }
    row-res = row-res.map(cell => {
      if cell == none or cell == [] {
        none
      } else if cell == s2 {
        cell
      } else {
        mask(cell)
      }
    })
  }

  // Assemblage de la grille
  let grid-cells = ()
  grid-cells += row-a
  grid-cells += row-b
  for p-row in partial-rows {
    grid-cells += p-row
  }
  if c.len() > 1 {
    grid-cells.push(grid.hline(stroke: black + .5pt))
  }
  grid-cells += row-res

  // Masquage ciblé (exercice à trous via liste)
  for idx in liste {
    if idx < grid-cells.len() and grid-cells.at(idx) != none and grid-cells.at(idx) != [] and grid-cells.at(idx) != pad {
      grid-cells.at(idx) = mask(grid-cells.at(idx))
    }
  }

  box(
    grid(
      columns: col * (size,),
      rows: auto,
      inset: (y: 3pt),
      align: center + horizon,
      stroke: (x, y) => if y == 1 { (bottom: black + .5pt) },
      ..grid-cells
    ),
    inset: (right: 1em)
  ) + h(space)
}

= Divisions

// Ecrit l'égalité d'une division euclidienne
// 
// ```example
// #egalite-euclidienne(126, 27)
// ```
// 
// -> content
#let egalite-euclidienne(
  // -> int | float
  a,
  // -> int | float
  b
) = $#a=#calc.quo(a,b) times #b+#calc.rem(a,b)$

// Ecrit l'égalité d'une division décimale
// 
// ```example
// #egalite-decimale(126, 25)
// ```
// 
// -> content
#let egalite-decimale(
  // -> int | float
  a,
  // -> int | float
  b,
  // -> str
  s:"e"
) = $#a div #b #{if s == "e" {$=$} else {$approx$}}#{a/b}$

// `division(a,b,mode:"g",extradigits:0,s:true, cycle: false, cycle-color:luma(50%),decimal-separator:",", size:1em,  hide-result: false, liste: (), solution: false, type-mask: "rect", couleur-cadre: blue.mix(gray), couleur-solution: red, space:1fr,..args)`

// Couleur d'accentuation
// couleur: red,

// Division du décimal a par le second b
// 
// avec : `extradigits` chiffres en plus après la virgule que dans a (si cycle:false), ils apparaissent en gris (`mode:`"g" par défaut) ou blanc (mode:"0") ou des points (mode:"p" ou "gp") ou rien (mode:""), `s:`true/false pour avoir ou non les soustractions, 
// Possibilité de sousligner en couleur (`cycle-color`) le cycle dans le quotient avec `cycle:true` ou de l'avoir entre parenthèses `cycle:""` ou en couleur `cycle:red`
// Possibilité de présenter des divisions à trous avec `hide-result`, `liste` et `solution` (de paramètres `type-mask`, `couleur-cadre` et `couleur-solution`)
// 
// *Exemples :* 
// ```example
// #division(12.6, 3.75)
// ```
// ```example
// #division(121.5, 7, cycle:true)
// ```
// ```example
// #division(121.5, 7, cycle:true,fr:false,dx:.5em,dy:-.9em)
// ```
// 
// 
// -> content
#let division(
  // -> int | float
  a, 
  // -> int | float
  b,
  // Mode pour les zéros ajoutés au dividende : "g" (gris), "0" (noir), "p" (petit point), "gp" (grand point), "" (vide) -> str
  mode: "g",
  // Nombre de décimales supplémentaires à calculer au quotient -> int
  extradigits: 0,
  // s: true/false pour afficher ou masquer les soustractions -> boolean
  s: true,
  // Détection et affichage automatique du cycle périodique -> boolean | str | color
  cycle: false, 
  // couleur du cycle ou du soulignage -> color
  cycle-color: luma(50%),
  // Mode fr:true, le séparateur décimal est "," sinon "." -> boolean
  fr:true,
  // Taille des colonnes du tableau -> length
  size: .7em,
  // dx for the ) in mode fr:false
  dx:.6em,
  // dy for the ) in mode fr:false
  dy:-.82em,
  // Masquer les étapes et le quotient pour le mode exercice -> boolean
  hide-result: false,
  // Liste des indices de cases à masquer (exercice à trous : a, b, étapes, quotient) -> array
  liste: (),
  // Afficher ou non la solution dans les masques -> boolean
  solution: false,
  // Type de masque ("rect" ou "line") -> str
  type-mask: "rect",
  // Couleur de la bordure des cadres de masque -> color
  couleur-cadre: blue.mix(gray),
  // Couleur du texte de la solution -> color
  couleur-solution: red,
  // Espacement si plusieurs sur la même ligne -> length
  space:1fr,
) = {
  let decimal-separator = if fr {","} else {"."}
  let size = if hide-result or liste != () and size < .85em {.85em} else {size}
  // let type-mask = type
  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: couleur-cadre + .75pt, text(if solution == false { white } else { couleur-solution }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { couleur-solution }, x)))
  }

  let (cycle-flag, entoure, cycle-couleur) = if cycle not in (true, false) {
    if type(cycle) == color { (true, false, cycle) } else { (true, true, false) }
  } else {
    (cycle, false, false)
  }

  let a-str = str(a)
  let b-str = str(b)

  // Normalisation du diviseur b si décimal
  let b-dec-len = if b-str.contains(".") { b-str.split(".").at(1).len() } else { 0 }
  let b-int = int(b-str.replace(".", ""))

  // Normalisation du dividende a
  let a-parts = a-str.split(".")
  let a-int-str = a-parts.at(0)
  let a-dec-str = if a-parts.len() > 1 { a-parts.at(1) } else { "" }

  if b-dec-len > 0 {
    if a-dec-str.len() <= b-dec-len {
      a-int-str += a-dec-str + "0" * (b-dec-len - a-dec-str.len())
      a-dec-str = ""
    } else {
      a-int-str += a-dec-str.slice(0, b-dec-len)
      a-dec-str = a-dec-str.slice(b-dec-len)
    }
  }

  // Construction du flux de chiffres du dividende
  let dividend-stream = ()
  for d in a-int-str.clusters() { dividend-stream.push((char: d, is_extra: false)) }
  for d in a-dec-str.clusters() { dividend-stream.push((char: d, is_extra: false)) }

  let int-digits-count = a-int-str.clusters().len()
  let total-orig-count = dividend-stream.len()

  // Algorithme de division pas à pas
  let q-int-digits = ()
  let q-dec-digits = ()
  let steps = ()

  let val = 0
  let col-idx = 0
  let seen-remainders = (:)
  let cycle-range = none

  let extra-added = 0
  let max-extra = if cycle-flag { 100 } else { extradigits }

  while col-idx < dividend-stream.len() or (val > 0 and extra-added < max-extra) {
    let item = none
    if col-idx < dividend-stream.len() {
      item = dividend-stream.at(col-idx)
    } else {
      item = (char: "0", is_extra: true)
      dividend-stream.push(item)
      extra-added += 1
    }

    let d = int(item.char)
    val = val * 10 + d
    let is-decimal-zone = col-idx >= int-digits-count

    if not is-decimal-zone {
      if val >= b-int or q-int-digits.len() > 0 {
        let q-digit = calc.trunc(val / b-int)
        let sub-val = q-digit * b-int
        let rem-val = val - sub-val

        steps.push((
          col-idx: col-idx,
          q-digit: q-digit,
          sub-val: sub-val,
          rem-val: rem-val,
          brought-char: item.char
        ))

        q-int-digits.push(str(q-digit))
        val = rem-val
      }
    } else {
      if q-int-digits.len() == 0 { q-int-digits.push("0") }

      let rem-key = str(val)
      if cycle-flag and item.is_extra and rem-key in seen-remainders {
        let start-idx = seen-remainders.at(rem-key)
        let end-idx = q-dec-digits.len() - 1
        cycle-range = (start-idx, end-idx)
        let _ = dividend-stream.pop()
        break
      }

      if cycle-flag and item.is_extra {
        seen-remainders.insert(rem-key, q-dec-digits.len())
      }

      let q-digit = calc.trunc(val / b-int)
      let sub-val = q-digit * b-int
      let rem-val = val - sub-val

      steps.push((
        col-idx: col-idx,
        q-digit: q-digit,
        sub-val: sub-val,
        rem-val: rem-val,
        brought-char: item.char
      ))

      q-dec-digits.push(str(q-digit))
      val = rem-val

      if val == 0 and col-idx >= total-orig-count - 1 and (not cycle-flag or extra-added >= extradigits) {
        break
      }
    }

    col-idx += 1
  }

  if q-int-digits.len() == 0 { q-int-digits.push("0") }

  // Compteur unique pour le masquage ciblé via `liste`
  let cell-counter = 0

  // 1. Cellules du dividende a (indices 0 à N_a - 1)
  let affichea = ()
  let total-cols = dividend-stream.len()
  for (i, item) in dividend-stream.enumerate() {
    let is-masked = (cell-counter in liste) or (hide-result and item.is_extra)
    let char-disp = if item.is_extra and not is-masked {
      if mode == "g" { text(luma(50%), item.char) }
      else if mode == "0" { item.char }
      else if mode == "p" { $thin circle.filled.tiny$ }
      else if mode == "gp" { $circle.filled.small$ }
      else { "" }
    } else if is-masked {
      mask(item.char)
    } else {
      item.char
    }

    if i == int-digits-count - 1 and total-cols > int-digits-count {
      affichea.push([#box(char-disp)#decimal-separator]) // grid.cell(align:left) provoque un léger décalage
    } else {
      affichea.push(char-disp)
    }
    cell-counter += 1
  }

  // 2. Cellules du diviseur b (indices N_a à N_a + N_b - 1)
  let afficheb = ()
  let b-clusters = str(b-int).clusters()
  for d in b-clusters {
    let is-masked = (cell-counter in liste)
    if is-masked {
      afficheb.push(mask(d))
    } else {
      afficheb.push(d)
    }
    cell-counter += 1
  }

  // 3. Construction géométrique des étapes (en bas à gauche)
  let left-step-cells = ()

  for (k, st) in steps.enumerate() {
    let is-last = (k == steps.len() - 1)
    let next-st = if not is-last { steps.at(k + 1) } else { none }

    // Ligne de soustraction
    if s and st.sub-val > 0 {
      let sub-str = str(st.sub-val)
      let l-sub = sub-str.len()
      let start-col = st.col-idx - l-sub + 1

      for c in range(total-cols) {
        if c >= start-col and c <= st.col-idx {
          let digit = sub-str.at(c - start-col)
          let is-masked = hide-result or (cell-counter in liste)
          let disp = if is-masked { mask(digit) } else { digit }

          if c == start-col and start-col == 0 {
            left-step-cells.push(
              grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#place(dx: -0.5em, [--]) #disp]
            )
          } else {
            left-step-cells.push(
              grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#disp]
            )
          }
          cell-counter += 1
        } else if c == start-col - 1 and start-col > 0 {
          let is-masked = hide-result or (cell-counter in liste)
          let minus-disp = if is-masked { mask([--]) } else { [--] }
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#minus-disp])
          cell-counter += 1
        } else {
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
        }
      }
    }

    // Ligne de reste
    if next-st != none {
      let full-rem-str = str(st.rem-val) + next-st.brought-char
      let l-rem = full-rem-str.len()
      let end-col = st.col-idx + 1
      let start-col = end-col - l-rem + 1

      for c in range(total-cols) {
        if c >= start-col and c <= end-col {
          let digit = full-rem-str.at(c - start-col)
          let is-masked = hide-result or (cell-counter in liste)
          let disp = if is-masked { mask(digit) } else { digit }
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#disp])
          cell-counter += 1
        } else {
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
        }
      }
    } else {
      let rem-str = str(st.rem-val)
      let l-rem = rem-str.len()
      let end-col = st.col-idx
      let start-col = end-col - l-rem + 1

      for c in range(total-cols) {
        if c >= start-col and c <= end-col {
          let digit = rem-str.at(c - start-col)
          let is-masked = hide-result or (cell-counter in liste)
          let disp = if is-masked { mask(digit) } else { digit }
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#disp])
          cell-counter += 1
        } else {
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
        }
      }
    }
  }

  // 4. Cellules du quotient (en bas à droite)
  let afficheq = ()
  for d in q-int-digits { afficheq.push(d) }
  if q-dec-digits.len() > 0 {
    let last-int = afficheq.pop()
    afficheq.push(last-int + decimal-separator)

    for (idx, d) in q-dec-digits.enumerate() {
      if cycle-range != none and idx >= cycle-range.at(0) and idx <= cycle-range.at(1) {
        if idx == cycle-range.at(0) and entoure == true {
          afficheq.push(text("(", cycle-color))
          afficheq.push(text(d, cycle-color))
        } else if idx == cycle-range.at(1) and entoure == true {
          afficheq.push(text(d, cycle-color))
          afficheq.push(text(")", cycle-color))
        } else if entoure {
          afficheq.push(text(d, cycle-color))
        } else if cycle-couleur == false {
          // afficheq.push(underline(d, extent: .1em, offset: .1em, stroke: cycle-color))
          if fr {afficheq.push(grid.cell(stroke:(bottom:.5pt + cycle-color),inset:(bottom:1pt),d))} else {afficheq.push(grid.cell(stroke: (top:.5pt + cycle-color),inset:(top:.5pt),d))}
        } else {
          afficheq.push(text(d, couleur))
        }
      } else {
        afficheq.push(d)
      }
    }
  }

  // Application du masque au quotient
  let new-afficheq = ()
  for item in afficheq {
    let is-masked = hide-result or (cell-counter in liste)
    if is-masked and item != [] and item != none {
      if decimal-separator not in item {new-afficheq.push(mask(item))} else {
        new-afficheq.push(box(mask(item.at(0))) + decimal-separator)}
      // new-afficheq.push(grid.cell(align:left,box(mask(item.at(0))) + decimal-separator))} // Provoque un léger décalage
    } else {
      new-afficheq.push(item)
    }
    cell-counter += 1
  }
  afficheq = new-afficheq

  // Rendu de la grille principale
  if fr {box(grid(
    columns: 2,
    align: (right + top, left + top),
    grid.vline(x: 1, stroke: 0.6pt),
    grid.hline(start: 1, y: 1, stroke: 0.6pt),

    // Dividende
    grid.cell(
      inset: (right: 3pt, bottom: 2pt),
      grid(columns: total-cols * (size,), align: center + horizon, ..affichea)
    ),

    // Diviseur
    grid.cell(
      inset: (left: 3pt, bottom: 2pt),
      grid(columns: afficheb.len() * (size,), align: center + horizon, ..afficheb)
    ),

    // Restes et Soustractions (parfaitement alignés par colonne)
    grid.cell(
      inset: (right: 3pt, top: 2pt),
      grid(columns: total-cols * (size,), align: center + horizon, row-gutter: 2pt, ..left-step-cells)
    ),

    // Quotient
    grid.cell(
      inset: (left: 3pt, top: 2pt),
      grid(columns: afficheq.len() * (size,), align: center + horizon, ..afficheq)
    )
  )
)+h(space)} else {box(grid(
    columns: 2,
    align: (right + top, left + top),
    // grid.vline(x: 1, stroke: 0.6pt),
    grid.hline(start: 1, y: 1, stroke: 0.6pt),

    [],
    // Quotient
    grid.cell(
      inset: (left: 3pt, bottom: 2pt),
      grid(columns: afficheq.len() * (size,), align: center + horizon, ..afficheq)
    ),
    
    // Diviseur
    grid.cell(
      inset: (right: 0pt, top: 2pt),
      grid(columns: str(b-int).len() * (size,), align: center + horizon, ..str(b-int).clusters() + (place(dx:dx,dy:dy,[)]),))
    ),
    
    // Dividende
    grid.cell(
      inset: (left: 3pt, top: 2pt),
      grid(columns: total-cols * (size,), align: center + horizon, ..affichea)
    ),
    
    
    [],
    // Restes et Soustractions (parfaitement alignés par colonne)
    grid.cell(
      inset: (left: 3pt, top: 2pt),
      grid(columns: total-cols * (size,), align: center + horizon, row-gutter: 2pt, ..left-step-cells)
    ),
  )
)+h(space)}
}

= Racine carrée posée

// `racine(a,  extradigits: 0,  groupes: false,  couleur-groupes: blue.darken(20%),  step: none,  couleur-step: blue.darken(20%), s: true, decimal-separator: ",", size: 0.65em, hide-result: false, liste: (), solution: false, type: "rect", couleur-cadre: blue.mix(gray), couleur-solution: red, space: 1fr,..args)` 

// Exemple :
//`#grid(columns: 3*(1fr,), row-gutter: 1em, 
// ..for i in range(1,11) {([
//   ==== Étape #i
//   #racine(24368, extradigits: 1,groupes: true, step: i)
// ],)+if i == 1 {([],[],)}}
// )`

// Calcul de la racine carrée de a, avec `extradigits` décimales en plus, en montrant les `groupes` de 2 en `couleur-groupes`, avec possibilité d'afficher les étapes avec `step`, de cacher les soustractions avec `s`, de cacher les résultats ou une `liste` de chiffres
// 
// *Exemples :* 
// ```example 
// #racine(24368,size: 1em,liste: (2,27))
// ```
// #example(`#grid(columns: 3*(1fr,), row-gutter: 1em, 
// ..for i in range(1,11) {([
//   ==== Étape #i
//   #racine(24368, extradigits: 1,groupes: true, step: i)
// ],)+if i == 1 {([],[],)}}
// )` , dir:ttb, scale-preview:100%)
// 
// -> content
#let racine(
  // -> int | float
  a,
  // Nombre de tranches de "00" supplémentaires à calculer après la virgule -> int
  extradigits: 0,
  // Afficher des crochets au-dessus des tranches de 2 chiffres -> boolean
  groupes: false,
  // Couleur des crochets -> color
  couleur-groupes: blue.darken(20%),
  // Étape de résolution pas à pas -> none | int
  step: none,
  // couleur de l'étape -> color
  couleur-step: blue.darken(20%),
  // Afficher ou masquer les soustractions sous le dividende -> boolean
  s: true,
  // Mode fr:true, le séparateur décimal est "," sinon "." -> boolean
  fr:true,
  // Largeur des colonnes -> length
  size: 0.65em,
  // Masquer les étapes, les opérations et le résultat (mode exercice) -> boolean
  hide-result: false,
  // Liste des indices de cases à masquer (exercice à trous) -> array
  liste: (),
  // Afficher ou non la solution dans les masques -> boolean
  solution: false,
  // Type de masque ("rect" ou "line") -> str
  type: "rect",
  // Couleur de la bordure des cadres de masque -> color
  couleur-cadre: blue.mix(gray),
  // Couleur du texte de la solution -> color
  couleur-solution: red,
  // espacement à droite -> length
  space: 1fr,
  ..args
) = {
  let decimal-separator = if fr {","} else {"."}
  let type-mask = type
  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: couleur-cadre + .75pt, text(if solution == false { white } else { couleur-solution }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { couleur-solution }, x)))
  }

  let crochet(body) = box(inset: (top: 3.5pt))[
    #place(top + right, dy: -.5em,dx:-size + .1em)[
      #rotate(-90deg,scale(180% * (size/1em))[#text(couleur-groupes)[\]]])
    ]
    #body
  ]

  // 1. Découpage en tranches de 2 chiffres
  let a-str = str(a)
  let parts = a-str.split(".")
  let int-str = parts.at(0)
  let dec-str = if parts.len() > 1 { parts.at(1) } else { "" }

  let int-tranches = ()
  let i = int-str.len()
  while i > 0 {
    let start = calc.max(0, i - 2)
    int-tranches.insert(0, int-str.slice(start, i))
    i -= 2
  }

  let dec-tranches = ()
  let j = 0
  while j < dec-str.len() {
    let end = calc.min(dec-str.len(), j + 2)
    let tr = dec-str.slice(j, end)
    if tr.len() == 1 { tr += "0" }
    dec-tranches.push(tr)
    j += 2
  }

  // Nombre de tranches "naturelles" du nombre initial
  let base-tranches-len = int-tranches.len() + dec-tranches.len()

  for _ in range(extradigits) {
    dec-tranches.push("00")
  }

  let total-int-tranches = int-tranches.len()
  let all-tranches = int-tranches + dec-tranches

  let total-cols = 0
  for tr in all-tranches { total-cols += tr.len() }

  let max-step = if step != none { step } else { 999 }

  // Teste si la tranche k doit être affichée dans le nombre initial du haut
  let tranche-visible(k) = {
    if k < base-tranches-len { true }
    else {
      let step-abaisser = 3 * k - 1
      max-step >= step-abaisser
    }
  }

  // La virgule s'affiche si a avait déjà une partie décimale OU si la 1re tranche décimale extra devient visible
  let show-comma = (dec-str.len() > 0) or (all-tranches.len() > total-int-tranches and tranche-visible(total-int-tranches))

  // 2. Calcul et enregistrement des 3 sous-étapes par tranche
  let root-digits = ()
  let right-ops = ()
  let steps-data = ()

  let current-rem = 0
  let current-col-idx = -1

  for (k, tr) in all-tranches.enumerate() {
    let step-abaisser  = if k == 0 { 1 } else { 3 * k - 1 }
    let step-trouve    = if k == 0 { 1 } else { 3 * k }
    let step-soustrait = if k == 0 { 1 } else { 3 * k + 1 }

    if max-step < step-abaisser { break }

    let val = current-rem * 100 + int(tr)
    current-col-idx += tr.len()

    if k == 0 {
      let d = 0
      while (d + 1) * (d + 1) <= val { d += 1 }
      let sub-val = d * d
      let rem-val = val - sub-val
      right-ops.push([$#d^2=#sub-val < val$])

      if max-step >= 1 {
        root-digits.push(str(d))
        steps-data.push((
          k: 0,
          col-idx: current-col-idx,
          sub-val: sub-val,
          rem-val: rem-val
        ))
        current-rem = rem-val
      }
    } else {
      let current-root-int = int(root-digits.join(""))
      let doubled = current-root-int * 2

      let u = 0
      while (doubled * 10 + (u + 1)) * (u + 1) <= val { u += 1 }

      let mult-lhs = doubled * 10 + u
      let sub-val = mult-lhs * u
      let rem-val = val - sub-val

      if max-step == step-abaisser {
        right-ops.push([$#doubled text(#couleur-step,c) times text(#couleur-step,c) lt.eq.slant #val$])
      } else if max-step >= step-trouve {
        right-ops.push([#mult-lhs $times$ #text(couleur-step,[#u]) = #sub-val])
      }

      if max-step >= step-soustrait {
        root-digits.push(str(u))
      }

      steps-data.push((
        k: k,
        col-idx: current-col-idx,
        tranche: tr,
        rem-prev: current-rem,
        sub-val: sub-val,
        rem-val: rem-val,
        show-abaisser: max-step >= step-abaisser,
        show-sub: max-step >= step-soustrait,
        show-rem: max-step >= step-soustrait
      ))

      if max-step >= step-soustrait {
        current-rem = rem-val
        if current-rem == 0 and k >= total-int-tranches - 1 and (k + 1 - total-int-tranches) >= dec-str.len() / 2 {
          break
        }
      }
    }
  }

  let cell-counter = 0

  // 3. Affichage du nombre initial (masquage dynamique des "00" pas encore abaissés)
  let affiche-a = ()
  let col-check = 0

  for (k, tr) in all-tranches.enumerate() {
    let tr-cells = ()
    let is-vis = tranche-visible(k)

    for d in tr.clusters() {
      if is-vis {
        let is-masked = (cell-counter in liste)
        let disp = if is-masked { mask(d) } else { d }
        
        if col-check == (int-str.len() - 1) and show-comma {
          tr-cells.push([#disp#decimal-separator])
        } else {
          tr-cells.push(disp)
        }
      } else {
        // Case vide pour conserver l'alignement de la grille sans afficher les "00"
        tr-cells.push([])
      }
      cell-counter += 1
      col-check += 1
    }

    let sub-grid = grid(columns: tr.len() * (size,), align: center + horizon, ..tr-cells)
    
    if groupes and is-vis {
      affiche-a.push(grid.cell(colspan: tr.len())[#crochet(sub-grid)])
    } else {
      affiche-a.push(grid.cell(colspan: tr.len())[#sub-grid])
    }
  }

  // 4. Étapes sous le nombre
  let left-step-cells = ()

  for (idx, st) in steps-data.enumerate() {
    let is-last-data = (idx == steps-data.len() - 1)

    if st.k == 0 {
      if s and st.sub-val > 0 {
        let sub-str = str(st.sub-val)
        let l-sub = sub-str.len()
        let start-col = st.col-idx - l-sub + 1

        for c in range(total-cols) {
          if c >= start-col and c <= st.col-idx {
            let digit = sub-str.at(c - start-col)
            let is-masked = hide-result or (cell-counter in liste)
            let disp = if is-masked { mask(digit) } else { digit }

            if c == start-col and start-col == 0 {
              left-step-cells.push(grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#place(dx: -0.5em, [--]) #disp])
            } else {
              left-step-cells.push(grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#disp])
            }
            cell-counter += 1
          } else if c == start-col - 1 and start-col > 0 {
            let is-masked = hide-result or (cell-counter in liste)
            let minus-disp = if is-masked { mask([--]) } else { [--] }
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#minus-disp])
            cell-counter += 1
          } else {
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
          }
        }
      }

      if max-step < 2 {
        let rem-str = str(st.rem-val)
        let l-rem = rem-str.len()
        let start-col = st.col-idx - l-rem + 1

        for c in range(total-cols) {
          if c >= start-col and c <= st.col-idx {
            let digit = rem-str.at(c - start-col)
            let is-masked = hide-result or (cell-counter in liste)
            let disp = if is-masked { mask(digit) } else { digit }
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#disp])
            cell-counter += 1
          } else {
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
          }
        }
      }
    } else {
      if st.show-abaisser {
        let full-str = str(st.rem-prev) + st.tranche
        let l-full = full-str.len()
        let start-col = st.col-idx - l-full + 1

        for c in range(total-cols) {
          if c >= start-col and c <= st.col-idx {
            let digit = full-str.at(c - start-col)
            let is-masked = hide-result or (cell-counter in liste)
            let disp = if is-masked { mask(digit) } else { digit }
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#disp])
            cell-counter += 1
          } else {
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
          }
        }
      }

      if s and st.show-sub and st.sub-val > 0 {
        let sub-str = str(st.sub-val)
        let l-sub = sub-str.len()
        let start-col = st.col-idx - l-sub + 1

        for c in range(total-cols) {
          if c >= start-col and c <= st.col-idx {
            let digit = sub-str.at(c - start-col)
            let is-masked = hide-result or (cell-counter in liste)
            let disp = if is-masked { mask(digit) } else { digit }

            if c == start-col and start-col == 0 {
              left-step-cells.push(grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#place(dx: -0.5em, [--]) #disp])
            } else {
              left-step-cells.push(grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#disp])
            }
            cell-counter += 1
          } else if c == start-col - 1 and start-col > 0 {
            let is-masked = hide-result or (cell-counter in liste)
            let minus-disp = if is-masked { mask([--]) } else { [--] }
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#minus-disp])
            cell-counter += 1
          } else {
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
          }
        }
      }

      let show-this-rem = st.show-rem and (is-last-data or max-step < 3 * (st.k + 1) - 1)
      if show-this-rem {
        let rem-str = str(st.rem-val)
        let l-rem = rem-str.len()
        let start-col = st.col-idx - l-rem + 1

        for c in range(total-cols) {
          if c >= start-col and c <= st.col-idx {
            let digit = rem-str.at(c - start-col)
            let is-masked = hide-result or (cell-counter in liste)
            let disp = if is-masked { mask(digit) } else { digit }
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#disp])
            cell-counter += 1
          } else {
            left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
          }
        }
      }
    }
  }

  // 5. Opérations à droite
  let afficher-right-ops = ()
  for op in right-ops {
    let is-masked = hide-result or (cell-counter in liste)
    if is-masked {
      afficher-right-ops.push(mask("..."))
    } else {
      afficher-right-ops.push(op)
    }
    cell-counter += 1
  }

  // 6. Racine (en haut à droite)
  let afficher-racine = ()
  for (idx, d) in root-digits.enumerate() {
    let is-masked = hide-result or (cell-counter in liste)
    let item = if idx == total-int-tranches - 1 and root-digits.len() > total-int-tranches {
      d + decimal-separator
    } else {
      d
    }

    if is-masked {
      afficher-racine.push(mask(item))
    } else {
      afficher-racine.push(item)
    }
    cell-counter += 1
  }

  // Grille finale
  box(grid(
    columns: 2,
    align: (right + top, left + top),
    grid.vline(x: 1, stroke: 0.6pt),
    grid.hline(start: 1, y: 1, stroke: 0.6pt),

    grid.cell(
      inset: (right: 4pt, bottom: 2pt), 
      grid(columns: total-cols * (size,), align: center + horizon, ..affiche-a)
    ),

    grid.cell(
      inset: (left: 4pt, bottom: if groupes {-1pt} else {2pt}),align:horizon,
      grid(columns: calc.max(1, afficher-racine.len()) * (size,), align: center + horizon, ..afficher-racine, ..args)
    ),

    grid.cell(
      inset: (right: 4pt, top: 2pt),
      grid(columns: total-cols * (size,), align: center + horizon, row-gutter: 2pt, ..left-step-cells)
    ),

    grid.cell(
      inset: (left: 6pt, top: 4pt),
      stack(spacing: 0.5em, ..afficher-right-ops)
    )
  ))+h(space)
}



= Calculs en ligne

// Pour avoir la somme en ligne de tous les nombres saisis
// 
// ```example
// $#add-en-ligne(198.7,120,35)$
// ```
// 
// -> content
#let add-en-ligne(
  ..ops
) = {
    let sum = ops.pos().first()
    [#ops.pos().first()]
    for op in ops.pos().slice(1) {
        [ \+ #if op> 0 {op} else {[(#op)]}]
        {sum = sum + op}
    }
    [ \= #calc.round(sum,digits:6) ]    
}

// Pour avoir la différence en ligne de tous les nombres saisis
// 
// ```example
// $#sous-en-ligne(198.7,107.3,-35)$
// ```
// 
// -> content
#let sous-en-ligne(
  ..ops,
  // -> auto | int
  digits:auto
) = {
    if digits == auto {digits = 6}
    let sum = ops.pos().first()
    [#ops.pos().first()]
    for op in ops.pos().slice(1) {
        [ $-$ #if op> 0 {op} else {[(#op)]}]
        {sum = sum - op}
    }
    [ \= #calc.round(sum,digits:6) ]    
}