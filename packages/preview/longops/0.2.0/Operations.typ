#set page(margin:(y:1cm))
#set text(lang:"fre")

= Conversions entre bases

// conversion en décimal depuis une autre base (défaut : 2) .
// ```example
// #from-base("1AF",base:16,)
// ``` -> str | int | float
#let from-base(
  // nombre à convertir -> int | float | str
  val, 
  // base depuis laquelle convertir -> int
  base: 2,
  // mode fr pour avoir des virgules à la place des points -> boolean
  fr:false,
  // indique en indice que le résultat est en base 10 -> boolean
  show-base: false,
) = {
  let digits-str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let char-to-val(c) = {
    let c-up = upper(c)
    let pos = digits-str.clusters().position(x => x == c-up)
    if pos != none { pos } else { 0 }
  }

  let s = str(val).replace(",", ".")
  let parts = s.split(".")
  let ent-str = parts.at(0)
  let dec-str = if parts.len() > 1 { parts.at(1) } else { "" }

  // Partie entière
  let ent-val = 0
  let pow = 1
  for c in ent-str.clusters().rev() {
    ent-val += char-to-val(c) * pow
    pow *= base
  }

  // Partie décimale
  let dec-val = 0.0
  let frac-pow = 1.0 / base
  for c in dec-str.clusters() {
    dec-val += char-to-val(c) * frac-pow
    frac-pow /= base
  }

  let res = ent-val + dec-val
  if show-base {if dec-str.len() == 0 { str(int(res)) } else if fr { str(res).replace(".",",") } else { str(res) } + $""_10$} else {if dec-str.len() == 0 { int(res) } else if fr { str(res).replace(".",",") } else { res }}
}

// conversion d'un nombre en écriture décimale vers une autre base (défaut : 2).
// ```example
// #to-base(base:16,"7,8",fr:false)
// ``` 
// ```example
// #to-base(100, base: 8)
// ``` -> str | int | float
#let to-base(
  // nombre à convertir -> int | float | str
  val, 
  // base depuis laquelle convertir -> int
  base: 2,
  // mode fr pour avoir des virgules à la place des points -> boolean
  fr:false,
  // indique en indice que le résultat est en base 10 -> boolean
  show-base: false,
  // permet de limiter le nombre de chiffres après la virgule si le développement est infini -> int
  precision: 6,
) = {
  let digits-str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let val-to-char(v) = digits-str.at(v)

  let num = if type(val) == str { float(val.replace(",", ".")) } else { float(val) }

  let ent-val = calc.trunc(num)
  let dec-val = calc.abs(num - ent-val)

  // Partie entière : divisions successives
  let ent-str = ""
  if ent-val == 0 {
    ent-str = "0"
  } else {
    let temp = ent-val
    while temp > 0 {
      let rem-val = calc.rem(temp, base)
      ent-str = val-to-char(rem-val) + ent-str
      temp = calc.trunc(temp / base)
    }
  }

  // Partie décimale : multiplications successives
  let dec-str = ""
  if dec-val > 0 and precision > 0 {
    let temp = dec-val
    let count = 0
    while temp > 0 and count < precision {
      temp *= base
      let p-int = calc.trunc(temp)
      dec-str += val-to-char(p-int)
      temp -= p-int
      count += 1
    }
  }

  if dec-str.len() > 0 {
    ent-str + if fr {","} else {"."} + dec-str + if show-base { $""_#base$ }
  } else {
    ent-str + if show-base { $""_#base$ }
  }
}

// conversion d'un nombre d'une base (défaut : 2) vers une autre base (défaut : 10).
// ```example
// // Conversion entre deux bases non décimales (Hexadécimal vers Binaire)
// #base-to-base("1A", base-from: 16, base-to: 2, equal: true)
// ```
// ```example
// // Conversion entre deux bases non décimales (Octal vers Binaire)
// #base-to-base("77", base-from: 8, base-to: 2, equal: true, mode:"line")
// ```
// ```example
// // Explication complète pas à pas (Base 16 vers Base 8)
// #base-to-base("1A.F", base-from: 16, base-to: 8, explain: true,mode: "line")
// ``` -> str | int | float
#let base-to-base(
  // nombre à convertir -> int | float | str
  val,
  // base depuis laquelle convertir -> int
  base-from: 2,
  // base vers laquelle convertir -> int
  base-to: 10,
  // pour avoir le détail de la convertion -> boolean
  explain: false,
  // pour avoir l'égalité de la convertion -> boolean
  equal: false,
  // permet de limiter le nombre de chiffres après la virgule si le développement est infini -> int
  precision: 6,
  // mode fr pour avoir des virgules à la place des points -> boolean
  fr: false,
  // différents modes de présentation "paren", "line", "simple" -> str
  mode:"paren",
) = {
  let digits-str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let val-to-char(v) = digits-str.at(v)
  let char-to-val(c) = {
    let c-up = upper(c)
    let pos = digits-str.clusters().position(x => x == c-up)
    if pos != none { pos } else { 0 }
  }

  let dec-sep-str = if fr { "," } else { "." }
  let raw-str = str(val).replace(",", ".")
  let parts = raw-str.split(".")
  let ent-str = parts.at(0)
  let dec-str = if parts.len() > 1 { parts.at(1) } else { "" }

  // --- 1. Conversion de base-from vers la base 10 ---
  let ent-val = 0
  let ent-terms = ()
  let ent-clusters = ent-str.clusters()
  let n-ent = ent-clusters.len()

  for (i, c) in ent-clusters.enumerate() {
    let v = char-to-val(c)
    let p = n-ent - 1 - i
    ent-val += v * calc.pow(base-from, p)
    ent-terms.push((digit: c, val: v, pow: p))
  }

  let dec-val = 0.0
  let dec-terms = ()
  for (i, c) in dec-str.clusters().enumerate() {
    let v = char-to-val(c)
    let p = -(i + 1)
    dec-val += v * calc.pow(float(base-from), p)
    dec-terms.push((digit: c, val: v, pow: p))
  }

  let val-base10 = ent-val + dec-val

  // --- 2. Conversion de la base 10 vers base-to ---
  let target-ent = calc.trunc(val-base10)
  let target-dec = calc.abs(val-base10 - target-ent)

  // Divisions successives pour la partie entière
  let div-steps = ()
  let res-ent-str = ""
  if target-ent == 0 {
    res-ent-str = "0"
  } else {
    let temp = target-ent
    while temp > 0 {
      let q = calc.trunc(temp / base-to)
      let r = calc.rem(temp, base-to)
      div-steps.push((num: temp, q: q, r: r, char: val-to-char(r)))
      res-ent-str = val-to-char(r) + res-ent-str
      temp = q
    }
  }

  // Multiplications successives pour la partie décimale
  let mult-steps = ()
  let res-dec-str = ""
  if target-dec > 0 and precision > 0 {
    let temp = target-dec
    let count = 0
    while temp > 0 and count < precision {
      let p = temp * base-to
      let p-int = calc.trunc(p)
      let p-rem = p - p-int
      mult-steps.push((val: temp, prod: p, int-part: p-int, char: val-to-char(p-int)))
      res-dec-str += val-to-char(p-int)
      temp = p-rem
      count += 1
    }
  }

  let final-str = if res-dec-str.len() > 0 {
    res-ent-str + dec-sep-str + res-dec-str
  } else {
    res-ent-str
  }

  // Helper pour l'affichage avec indice de base : (val)_(base)
  let fmt-base(s, b) = if mode == "paren" {$ (#s)_(#b) $} else if mode == "line" {$ overline(#s)^""^(script(#[#b])) $} else {$ #s _(#b) $}
  let val-disp = str(val).replace(".", dec-sep-str)
  let eq-display = if explain {$#fmt-base(val-disp, base-from) = #fmt-base(final-str, base-to) $} else {$ #fmt-base(val-disp, base-from) = #fmt-base(final-str, base-to) $}

  // Cas simples sans explication
  if not explain {
    if equal {
      return eq-display
    } else {
      return final-str
    }
  }

  // --- 3. Construction du bloc d'explications (explain: true) ---
  let steps-content = ()

  // Étape A : Décomposition vers la base 10
  if base-from != 10 {
    let exp-parts = ()
    for t in ent-terms {
      exp-parts.push($ #char-to-val(t.digit) times #base-from^#t.pow $)
    }
    for t in dec-terms {
      exp-parts.push($ #char-to-val(t.digit) times #base-from^(#t.pow) $)
    }
    let b10-str = str(val-base10).replace(".", dec-sep-str)

    steps-content.push([
      #if fr [*1. Conversion de la base #base-from vers la base 10 (décomposition polynomiale) :*] else [*1. Conversion from base #base-from to base 10:*]
      $ #fmt-base(val-disp, base-from) = #exp-parts.join($ + $) = #fmt-base(b10-str, 10) $
    ])
  }

  // Étape B : Conversion de la base 10 vers base-to
  if base-to != 10 {
    let sub-steps = ()

    if div-steps.len() > 0 {
      sub-steps.push([

        #if fr [_Partie entière (divisions successives par #base-to) :_] else [_Integer part (successive divisions by #base-to) :_]
        #list(
          ..div-steps.map(s => [
            $#s.num = #base-to times #s.q + bold(#str(s.r)) $
            #if s.r >= 10 [ $-> $ *#s.char* ] else []
          ])
        )
      ])
    }

    if mult-steps.len() > 0 {
      sub-steps.push([
        #if fr [_Partie décimale (multiplications successives par #base-to) :_] else [_Fractional part (successive multiplications by #base-to) :_]
        #list(
          ..mult-steps.map(s => [
            $#s.val times #base-to = bold(#str(s.prod)) $ (#if fr [partie entière :] else [integer part:] *#s.int-part* #if s.int-part >= 10 [ $->$ *#s.char* ])
          ])
        )
      ])
    }

    let title = if base-from != 10 { if fr [*2. Conversion de la base 10 vers la base #base-to :*] else [*2. Conversion from base 10 to base #base-to:*] } else { if fr [*Conversion vers la base #base-to :*] else [*Conversion to base #base-to:*] }
    steps-content.push([
      #title
      #sub-steps.join()
    ])
  }

  // Rendu dans un encadré explicatif
  block(
    stroke: 0.5pt + luma(120),
    inset: 10pt,
    radius: 4pt,
    fill: luma(248),
    width: 100%,
    [
      #steps-content.join([\ \ ])

      #v(4pt)
      #line(length: 100%, stroke: 0.5pt + luma(200))
      #align(center)[#if fr [*Résultat :*] else [*Result:*] #eq-display]
    ]
  )
}

= Additions
// `addition(nombres, show-carry: true, carries-color:red, size:1em, hide-result:false, border-color:blue.mix(gray), solution-color:red, type-mask:"rect", list:(), solution:false, space:1fr,)`

// Pose l'addition de 2 ou plusieurs nombres avec possibilité de cacher la ligne de résultat avec `hide-result`, une `list` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc
// 
// *Exemples :* 
// ```example
// #addition(12.5, 3.75, .8, 14.2)
// ```
// ```example
// #addition(12.5, 3.75, .8, 14.2,list:(2,10,19))
// ```
// ```example
// #addition(base: 16, "1A.F", "2B.8",show-base: true,)
// ```
// -> content
#let addition(
  // Base numérique (ex: 2, 8, 10, 16) -> int
  base: 10,
  // Montrer ou non dans quelle base l'addition est posée -> boolean
  show-base:false,
  // Montrer ou non les retenues -> boolean
  show-carry: true, 
  // couleur des retenues -> color
  carries-color: red,
  // Taille des colonnes -> length
  size: 1em,
  // Affichage des sép. décimaux à la française "," ou pas -> boolean
  fr: true,
  // Cache les retenues et le résultat -> boolean
  hide-result: false,
  // Couleur du cadre des chiffres cachés -> color
  border-color: blue.mix(gray),
  // Couleur des chiffres cachés si solution = true -> color
  solution-color: red,
  // Comment les chiffres sont cachés : "rect" ou autre -> str
  type-mask: "rect",
  // Liste des chiffres à cacher -> array
  list: (),
  // Montrer les retenues et le résultat en mode hide-result -> boolean
  solution: false,
  // Signe d'égalité -> boolean | content
  sign: false,
  // Espacement si plusieurs sur la même ligne -> length
  space: 1fr,
  // Taille des chiffres -> length
  text-size: 1em,
  // Nombres (acceptent nombres ou chaînes de caractères ex: "1A.F") -> array | arguments
  ..args
) = {
  let decimal-sep = if fr {[,]} else {[.]}
  
  // Helpers pour la conversion des chiffres selon la base (0-9, A-Z)
  let digits-str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let val-to-char(v) = digits-str.at(v)
  let char-to-val(c) = {
    let pos = digits-str.clusters().position(x => x == upper(c))
    if pos != none { pos } else { 0 }
  }

  // Récupération des nombres
  let nombres = args.pos()
  if nombres.len() == 1 and type(nombres.at(0)) == array {
    nombres = nombres.at(0)
  }
  if nombres.len() < 2 {
    panic("La fonction addition nécessite au moins deux nombres.")
  }

  set text(text-size)

  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: border-color + .75pt, text(if solution == false { white } else { solution-color }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { solution-color }, x)))
  }

  // Nettoyage et séparation des chaînes
  let list-str = nombres.map(s => str(s).replace(",", "."))
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

  // Calcul du résultat et des retenues colonne par colonne (de droite à gauche)
  let nb-cols-chiffres = max-entieres + max-decimales
  let carries-generated = (0,) * nb-cols-chiffres
  let res-digits-rev = ()
  let current-carry = 0

  for i in range(nb-cols-chiffres) {
    let k = nb-cols-chiffres - 1 - i
    let col-sum = current-carry
    for term-chiffres in list-chiffres {
      col-sum += char-to-val(term-chiffres.at(k))
    }
    current-carry = calc.trunc(col-sum / base)
    carries-generated.at(k) = current-carry
    res-digits-rev.push(val-to-char(calc.rem(col-sum, base)))
  }
  let res-digits = res-digits-rev.rev()

  // Traitement des retenues restantes tout à gauche (débordement)
  let overflow-digits-rev = ()
  while current-carry > 0 {
    let rem-val = calc.rem(current-carry, base)
    current-carry = calc.trunc(current-carry / base)
    overflow-digits-rev.push(val-to-char(rem-val))
  }
  let overflow-digits = overflow-digits-rev.rev()

  let entiere-resultat = overflow-digits.join() + res-digits.slice(0, max-entieres).join()
  let decimale-resultat = if max-decimales > 0 { res-digits.slice(max-entieres).join() } else { "" }

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
  let decalage = overflow-digits.len()
  let largeur-totale = nb-cols-chiffres + (if max-decimales > 0 { 1 } else { 0 }) + decalage
  let colonnes = largeur-totale + 1

  let lignes = ()

  // Ligne des retenues
  let has-carry-row = show-carry and ((not hide-result and list == ()) or solution)
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
        retenue-row.push(text(size: 0.8em, fill: carries-color)[#val-to-char(r-val)])
      } else {
        retenue-row.push([])
      }
    }
    lignes.push(retenue-row)
  }

  // Construction des lignes de nombres
  let creer-ligne-nombre = (sign, idx) => {
    let ligne = (sign,)
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
    let sign = if idx > 0 { text(.8em)[$ + $] } else { [] }
    lignes.push(creer-ligne-nombre(sign, idx))
  }

  // Ligne du résultat
  let ligne-resultat = (if sign == true [=] else if sign != false {sign} else [],)
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

  for x in list {
    if x < termes.len() {
      termes.at(x) = mask(termes.at(x))
    }
  }

  if carry-line != none {
    termes = carry-line + termes
  }

  if show-base {termes.insert(0,table.cell(x: colonnes,rowspan: lignes.len()+1)[#place(bottom,dy:-.4em,$""^#base$)])} //super[#base]+

  // Rendu sous forme de tableau Typst
  box(table(
    columns: (colonnes + if show-base {1} else {0}) * (size,),
    stroke: none,
    inset: (x: 2pt, y: 3pt),
    align: center + horizon,
    // ,
    ..termes, 
    table.hline(stroke: 1pt, y: ymax)
  )) + h(space)
}

// Version avec étapes détaillées pour deux entiers
// 
// *Exemples :* 
// #example(`#_addition-detaillee(245, 167)`,ratio:.4)
// 
// 
// -> content
#let _addition-detaillee(
  // premier nombre -> int
  nombre1, 
  // second nombre -> int
  nombre2, 
  // couleur des retenues -> color
  carries-color:red
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
  [\ #addition(nombre1, nombre2, carries-color:red)
   *Résultat final : $#resultat-partiel$* #h(1fr)]
}

= Soustraction avec retenues et/ou emprunts

// soustraction(nombre1, nombre2, show-borrow: true, canceled:true, fr:true, carries-color:red) avec nombre1 > nombre2 entiers ou flottants ex 3.7

// `soustraction(nombres, show-borrow: true, canceled:false, fr:true, carries-color:red, size:1em, zeros:true, hide-result:false, border-color:blue.mix(gray), solution-color:red, type-mask:"rect", list:(), solution:false, space:1fr,)` 

// Pose la soustraction de 2 ou plusieurs nombres avec possibilité de cacher la ligne de résultat avec `hide-result`, une `list` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc
// 
// *Exemples :* 
// ```example
// #soustraction(12.5, 3.75)
// ```
// ```example
// #soustraction(121.5, 3.75, .8, 14.2,list:(2,10,19))
// ```
// ```example
// // En hexadécimal (Base 16) :
// #soustraction(base: 16, "1A4.F", "B2.C",show-base: true)
// ```
// 
// -> content
#let soustraction(
  // Base de calcul (de 2 à 36) -> int
  base: 10,
  // Montrer ou non dans quelle base l'addition est posée -> boolean
  show-base:false,
  // Montrer ou non les retenues -> boolean
  show-borrow: true, 
  // Si fr:false, montrer ou non le nombre initial barré -> boolean
  canceled: false, 
  // Ecriture française ou avec emprunts à l'anglaise -> boolean
  fr: true, 
  // couleur des retenues -> color
  carries-color: red,
  // Taille des colonnes -> length
  size: 1em,
  // Ajoute ou non des zéros -> boolean
  zeros: true,
  // Cache les retenues et le résultat -> boolean
  hide-result: false,
  // Couleur du cadre des chiffres cachés -> color
  border-color: blue.mix(gray),
  // Couleur des chiffres cachés si solution = true -> color
  solution-color: red,
  // Comment les chiffres sont cachés : soient "rect" pour un rectangle arrondi soit ... -> str
  type-mask: "rect",
  // list des chiffres à cacher dans une addition à trous -> array
  list: (),
  // Montrer les retenues et le résultat en mode hide-result (pour les corrections) -> boolean
  solution: false,
  // sign d'égalité, false ou true [=] ou un symbole $ = $ -> boolean | content
  sign: false,
  // taille des chiffres : 1em -> length
  text-size: 1em,
  // Espacement si plusieurs sur la même ligne -> length
  space: 1fr,
  // Nombres -> array | arguments
  ..args
) = {
  // Récupération des nombres
  let nombres = args.pos()
  if nombres.len() == 1 and type(nombres.at(0)) == array {
    nombres = nombres.at(0)
  }
  if nombres.len() < 2 {
    panic("La fonction soustraction nécessite au moins deux nombres.")
  }

  set text(text-size)

  // Tables de conversion pour les chiffres selon la base (0-9, A-Z)
  let digits-str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let val-to-char(v) = digits-str.at(v)
  let char-to-val(c) = {
    let c-up = upper(c)
    let pos = digits-str.clusters().position(x => x == c-up)
    if pos != none { pos } else { 0 }
  }

  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: border-color + .75pt, text(if solution == false { white } else { solution-color }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { solution-color }, x)))
  }

  // Traitement des chaînes de caractères et séparation des parties
  let list-str = nombres.map(str)
  let list-parties = list-str.map(s => s.replace(",", ".").split("."))
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

  // Conversion vers la valeur numérique pour vérifier si le résultat est négatif
  let from-base-val(s) = {
    let parts = str(s).replace(",", ".").split(".")
    let ent = parts.at(0)
    let dec = if parts.len() > 1 { parts.at(1) } else { "" }
    let v = 0.0
    let p = 1.0
    for c in ent.clusters().rev() {
      v += char-to-val(c) * p
      p *= base
    }
    p = 1.0 / base
    for c in dec.clusters() {
      v += char-to-val(c) * p
      p /= base
    }
    return v
  }

  let minuend-val = from-base-val(list-str.at(0))
  let subtrahends-val = nombres.slice(1).map(from-base-val).sum()
  if minuend-val < subtrahends-val {
    panic("La soustraction donnerait un résultat négatif.")
  }

  // Calcul des retenues, emprunts et des chiffres du résultat
  let top-borrows = (0,) * nb-cols-chiffres
  let bottom-carries = (0,) * nb-cols-chiffres
  let M-mod = list-chiffres.at(0).clusters().map(char-to-val)
  let M-orig = list-chiffres.at(0).clusters().map(char-to-val)
  let res-digits = ("0",) * nb-cols-chiffres

  if fr {
    let carry-in = 0
    for i in range(nb-cols-chiffres) {
      let k = nb-cols-chiffres - 1 - i
      let sum-sub = carry-in
      for j in range(1, nombres.len()) {
        sum-sub += char-to-val(list-chiffres.at(j).at(k))
      }
      let digit-M = char-to-val(list-chiffres.at(0).at(k))
      if digit-M < sum-sub {
        let needed = calc.ceil((sum-sub - digit-M) / base)
        top-borrows.at(k) = needed
        bottom-carries.at(k) = needed
        res-digits.at(k) = val-to-char(digit-M + needed * base - sum-sub)
        carry-in = needed
      } else {
        res-digits.at(k) = val-to-char(digit-M - sum-sub)
        carry-in = 0
      }
    }
  } else {
    for i in range(nb-cols-chiffres) {
      let k = nb-cols-chiffres - 1 - i
      let sum-sub = 0
      for j in range(1, nombres.len()) {
        sum-sub += char-to-val(list-chiffres.at(j).at(k))
      }
      while M-mod.at(k) < sum-sub {
        M-mod.at(k) += base
        let idx = k - 1
        while idx >= 0 and M-mod.at(idx) == 0 {
          M-mod.at(idx) = base - 1
          idx -= 1
        }
        if idx >= 0 {
          M-mod.at(idx) -= 1
        }
      }
      res-digits.at(k) = val-to-char(M-mod.at(k) - sum-sub)
    }
  }

  let entiere-resultat = res-digits.slice(0, max-entieres).join("")
  let decimale-resultat = if max-decimales > 0 { res-digits.slice(max-entieres).join("") } else { "" }

  let colonnes = nb-cols-chiffres + (if max-decimales > 0 { 1 } else { 0 }) + 1
  let lignes = ()
  let show-carry-cond = show-borrow 

  let fmt-mod(v) = {
    if v >= base {
      "1" + val-to-char(v - base)
    } else {
      val-to-char(v)
    }
  }

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
        top-row.push(pad(left: -.75em, bottom: -1.6em, text(size: 0.7em, fill: carries-color)[#val-to-char(b-val)]))
      } else {
        top-row.push([])
      }
    }
    if not ((not hide-result and list == ()) or solution) {top-row = ([],) * top-row.len()}
    lignes.push(top-row)
  }

  // Helper pour la création d'une ligne de nombre
  let creer-ligne-nombre = (sign, idx) => {
    let ligne = (sign,)
    let entiere = list-entieres.at(idx)
    let decimale = list-decimales.at(idx)
    let orig-parties = list-str.at(idx).replace(",", ".").split(".")
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
      ligne.push(table.cell(inset: (x: -3pt), if fr [,] else [.]))
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
    if canceled {
      let line-mod = ([],)
      for i in range(nb-cols-chiffres) {
        if i == pos-virgule and max-decimales > 0 { line-mod.push(table.cell(inset: (x: -3pt))[]) }
        if M-mod.at(i) != M-orig.at(i) {
          line-mod.push(text(size: 0.8em, fill: blue)[#fmt-mod(M-mod.at(i))])
        } else {
          line-mod.push([])
        }
      }
      lignes.push(line-mod)

      let line-orig = ([],)
      let orig-ent = list-str.at(0).replace(",", ".").split(".").at(0)
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
        line-orig.push(table.cell(inset: (x: -3pt), if fr [,] else [.]))
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
      let orig-ent = list-str.at(0).replace(",", ".").split(".").at(0)
      for (i, digit) in list-entieres.at(0).clusters().enumerate() {
        if i < max-entieres - orig-ent.len() {
          line-min.push([])
        } else if show-borrow and M-mod.at(i) != M-orig.at(i) {
          line-min.push(text(size: 0.8em, fill: blue)[#fmt-mod(M-mod.at(i))])
        } else {
          line-min.push(digit)
        }
      }
      if max-decimales > 0 {
        line-min.push(table.cell(inset: (x: -3pt), if fr [,] else [.]))
        for (i, digit) in list-decimales.at(0).clusters().enumerate() {
          let idx = max-entieres + i
          if show-borrow and M-mod.at(idx) != M-orig.at(idx) {
            line-min.push(text(size: 0.8em, fill: blue)[#fmt-mod(M-mod.at(idx))])
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
    for i in range(nb-cols-chiffres) {
      if i == pos-virgule and max-decimales > 0 {
        bot-row.push(table.cell(inset: (x: -3pt))[])
      }
      let c-val = if i + 1 < nb-cols-chiffres { bottom-carries.at(i + 1) } else { 0 }
      if c-val > 0 {
        bot-row.push(pad(top: -.6em, text(size: 0.7em, fill: carries-color.negate())[+#val-to-char(c-val)]))
      } else {
        bot-row.push([])
      }
    }
    if not ((not hide-result and list == ()) or solution) {bot-row = ([],) * bot-row.len()}
    lignes.push(bot-row)
  }

  // 5. Ligne du résultat
  let ligne-resultat = (if sign == true [=] else if sign != false {sign} else [],)
  let res-ent-trimmed = entiere-resultat
  let first-non-zero = res-ent-trimmed.clusters().position(c => c != "0")
  let leading-zeros-count = if first-non-zero != none { first-non-zero } else { max-entieres - 1 }

  for (c-idx, digit) in entiere-resultat.clusters().enumerate() {
    let is-padded = (c-idx < leading-zeros-count)
    if is-padded {
      ligne-resultat.push([])
    } else {
      ligne-resultat.push(digit)
    }
  }
  if max-decimales > 0 {
    ligne-resultat.push(table.cell(inset: (x: -3pt), if fr [,] else [.]))
    for digit in decimale-resultat.clusters() {
      ligne-resultat.push(digit)
    }
  }
  lignes.push(ligne-resultat)

  let ymax = lignes.len() - 1

  // Application du masque de résultat caché
  if hide-result {
    for i in range(1, lignes.at(ymax).len()) {
      lignes.at(ymax).at(i) = mask(lignes.at(ymax).at(i))
    }
  }

  // Extraction des retenues pour l'exercice à trous
  let top-borrow-line = if has-top-borrow { lignes.remove(0) } else { none }
  let bot-carry-line = if has-bottom-carry { lignes.remove(lignes.len() - 2) } else { none }

  let termes = lignes.flatten()

  for x in list {
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
  table-rows += (auto,) * (nombres.len() + (if not fr and canceled { 1 } else { 0 }))
  if has-bottom-carry { table-rows.push(5pt) }
  table-rows.push(auto)

  if show-base {termes.insert(0,table.cell(x: colonnes,rowspan: table-rows.len())[#place(bottom,dy:-.4em,$""^#base$)])} //super[#base]+

  // Rendu du tableau final
  box(table(
    columns: (colonnes + if show-base {1} else {0}) * (size,),
    stroke: none,
    rows: table-rows,
    inset: (x: 3pt, y: 4pt),
    align: center + horizon,
    ..termes,
    table.hline(stroke: 1pt, y: ymax)
  )) + h(space)
}

// Version avec étapes détaillées pour la soustraction à l'anglaise (avec emprunts et non retenues)
// 
// *Exemples :* 
// #example(`#_soustraction-detaillee(121.5, 14.2)`,ratio:.8)
// 
// 
// -> content
#let _soustraction-detaillee(
  // premier nombre -> int | float
  nombre1, 
  // second nombre -> int | float
  nombre2,
  // couleur des retenues -> color
  carries-color:red,
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
  align(horizon)[#soustraction(nombre1, nombre2, carries-color:carries-color,)])
  
}

= Multiplications

// `multiplication(a, b, mode:"g", sym:true, fr:true, spread:1em, size:auto, hide-result:false, border-color:blue.mix(gray), solution-color:red, type:"rect", list:(), solution:false, space:1fr,)` 

// Pose la multiplication de 2 nombres entiers ou décimaux avec possibilité de cacher les lignes avec `hide-result`, une `list` de certains chiffres puis d'afficher la `solution`, diverses couleurs paramétrables etc
// 
// *Exemples :* #v(6em)
// ```example
// #multiplication(12.5, 3.75)
// ```
// ```example
// #multiplication(1215, 142,list:(3,12,19,36),type-mask: "line",)
// ```
// 
// -> content
#let multiplication(
  // Base de numération (2 à 36) -> int
  base: 10,
  // Montrer ou non dans quelle base l'addition est posée -> boolean
  show-base:false,
  // premier facteur -> int | float | str
  a, 
  // second facteur -> int | float | str
  b,
  // Afficher les retenues : false, true ("all"), "mult", "add" -> boolean | str
  carries: false,
  // Couleur des retenues -> color | array
  carries-color: red,
  // Présentation des décalages : "g" (défaut) pour 0 en gris, "0" pour des 0 normaux, "p" pour des petits points et "gp" pour des points plus gros, "" ou autre pour rien -> str
  mode: "g",
  // Afficher les + des additions et le égal du résultat si true, seulement les + si "+", seulement le = si "=", rien si false, sinon donner une list du sign ($+$, $=$) par ex -> boolean | str | array
  sym: true,
  // Mode fr:true, le séparateur décimal est "," sinon "." -> boolean | str
  fr: true,
  // Largeur des colonnes -> length
  size: 1em,
  // Masquer les lignes intermédiaires et le résultat final pour les exercices -> boolean
  hide-result: false,
  // list des indices de cases à masquer (pour multiplication à trous) -> array
  list: (),
  // Afficher ou non la solution dans les masques -> boolean
  solution: false,
  // Type de masque ("rect" ou "line") -> str
  type-mask: "rect",
  // Couleur de la bordure des cadres de masque -> color
  border-color: blue.mix(gray),
  // Couleur du texte de la solution -> color
  solution-color: red,
  // Espacement si plusieurs sur la même ligne -> length
  space: 1fr,
) = {
  let decimal-separator = if fr { "," } else { "." }
  let carries-color = if type(carries-color) == color {(carries-color,carries-color)} else {carries-color}

  // Helpers pour la conversion de base
  let digits-str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let char-to-val(c) = {
    let c-up = upper(c)
    let pos = digits-str.clusters().position(x => x == c-up)
    if pos != none { pos } else { 0 }
  }
  let val-to-char(v) = digits-str.at(v)

  let parse-base(s) = {
    let val = 0
    for c in s.clusters() {
      val = val * base + char-to-val(c)
    }
    val
  }

  let int-to-base(v) = {
    if v == 0 { return "0" }
    let s = ""
    let temp = v
    while temp > 0 {
      let rem = calc.rem(temp, base)
      s = val-to-char(rem) + s
      temp = calc.trunc(temp / base)
    }
    s
  }

  // Organisation des deux facteurs (le plus long en haut)
  let stra = upper(str(a).replace(",", "."))
  let strb = upper(str(b).replace(",", "."))
  if stra.len() < strb.len() {
    let temp = stra
    stra = strb
    strb = temp
  }

  let pad = if mode == "g" { text(gray)[0] }
            else if mode == "0" { [0] }
            else if mode == "p" { text(size: 0.8em)[$ thin circle.filled.tiny $] }
            else if mode == "gp" { text(size: 0.8em)[$ circle.filled.small $] }
            else { [] }

  // Fonction de masquage des cases
  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: border-color + .75pt, text(if solution == false { white } else { solution-color }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { solution-color }, x)))
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

  // Calcul du résultat exact en base N
  let val1 = parse-base(chiffres1)
  let val2 = parse-base(chiffres2)
  let prod-int-str = int-to-base(val1 * val2)

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
  let d = chiffres2.clusters().map(char-to-val).rev()
  let c = d.map(x => int-to-base(x * val1))

  // Calcul des retenues de multiplication (pour chaque ligne intermédiaire)
  let mult-carries-list = ()
  for (k, bk) in d.enumerate() {
    let carries-k = (0,) * chiffres1.len()
    let carry = 0
    let a-digits = chiffres1.clusters().map(char-to-val).rev()
    for (j, aj) in a-digits.enumerate() {
      let prod = aj * bk + carry
      let next-carry = calc.trunc(prod / base)
      if j + 1 < chiffres1.len() {
        carries-k.at(j + 1) = next-carry
      }
      carry = next-carry
    }
    mult-carries-list.push(carries-k)
  }

  // Calcul des retenues d'addition (entre produits partiels)
  let add-carries = (0,) * afficher.len()
  if c.len() > 1 {
    let carry-in = 0
    for m in range(afficher.len()) {
      let sum-col = carry-in
      for (k, p-str) in c.enumerate() {
        let idx-in-p = m - k
        if idx-in-p >= 0 and idx-in-p < p-str.len() {
          let p-digits = p-str.clusters().map(char-to-val).rev()
          sum-col += p-digits.at(idx-in-p)
        }
      }
      let next-carry = calc.trunc(sum-col / base)
      if m + 1 < afficher.len() {
        add-carries.at(m + 1) = next-carry
      }
      carry-in = next-carry
    }
  }

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
                 else if sym == false { ([ ], [ ]) }
                 else { sym }

  // Gestion de l'affichage des retenues
  let show-mult = (carries == true or carries == "all" or carries == "mult")
  let show-add = (carries == true or carries == "all" or carries == "add")
  let hide-carries-cond = hide-result and not solution

  // Lignes de retenues supérieures (Multiplication)
  let top-carry-rows = ()
  if show-mult and not hide-carries-cond {
    for carries-k in mult-carries-list {
      if carries-k.any(v => v > 0) {
        let carry-row = (none,) * calc.max(0, col - affichea.len())
        for i in range(affichea.len()) {
          let j = affichea.len() - 1 - i
          let val = carries-k.at(j)
          if val > 0 {
            carry-row.push(std.pad(bottom: -0.5em, text(size: 0.7em, fill: carries-color.at(0))[#val-to-char(val)]))
          } else {
            carry-row.push([])
          }
        }
        top-carry-rows.push(carry-row)
      }
    }
  }

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

  // Ligne de retenues d'addition
  let add-carry-row = ()
  let has-add-carries = show-add and not hide-carries-cond and c.len() > 1 and add-carries.any(v => v > 0)
  if has-add-carries {
    add-carry-row = (none,) * calc.max(0, col - afficher.len())
    for i in range(afficher.len()) {
      let m = afficher.len() - 1 - i
      let val = add-carries.at(m)
      if val > 0 {
        add-carry-row.push(grid.cell(inset:0pt,text(size: 0.7em, fill: carries-color.at(1))[+#val-to-char(val)]))
      } else {
        add-carry-row.push([])
      }
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
  for top-row in top-carry-rows {
    grid-cells += top-row
  }
  grid-cells += row-a
  grid-cells += row-b
  for p-row in partial-rows {
    grid-cells += p-row
  }
  if has-add-carries {
    grid-cells += add-carry-row
  }
  if c.len() > 1 {
    grid-cells.push(grid.hline(stroke: black + .5pt))
  }
  grid-cells += row-res

  // Masquage ciblé (exercice à trous via list)
  for idx in list {
    if idx < grid-cells.len() and grid-cells.at(idx) != none and grid-cells.at(idx) != [] and grid-cells.at(idx) != pad {
      grid-cells.at(idx) = mask(grid-cells.at(idx))
    }
  }

  let stroke-y = top-carry-rows.len() + 1

  box(
    grid(
      columns: col * (size,),
      rows: auto,
      inset: (y: 3pt),
      align: center + horizon,
      stroke: (x, y) => if y == stroke-y { (bottom: black + .5pt) },
      ..grid-cells
    )+if show-base { place(bottom+right,dx:.55em,dy:-.55em,box(width:.5em,align(left,$""^#base$))) },
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
  // dividende -> int | float
  a,
  // diviseur -> int | float
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
  // dividende -> int | float
  a,
  // diviseur -> int | float
  b,
  // signe =, sinon approx -> str
  s:"e"
) = $#a div #b #{if s == "e" {$=$} else {$approx$}}#{a/b}$

// Function to show a vertical line inside each cell showing that a number is being pulled down -> content
#let pull-down(n,coef:89%) = if n > 0 {grid.cell(
  rowspan: n,
  align: horizon,
  {
    set text(luma(50%))
    if n == 1 {place(center,dy:-1em * coef/10,scale(y: coef*.95, $arrow.b$))} else {$stretch(arrow.b, size: #{ n * coef })$}
  },
)}

// `division(a,b,mode:"g",extradigits:0,s:true, cycle: false, cycle-color:luma(50%),decimal-separator:",", size:1em,  hide-result: false, list: (), solution: false, type-mask: "rect", border-color: blue.mix(gray), solution-color: red, space:1fr,..args)`

// Couleur d'accentuation
// couleur: red,

// Division du décimal a par le second b
// 
// avec : `extradigits` chiffres en plus après la virgule que dans a (si cycle:false), ils apparaissent en gris (`mode:`"g" par défaut) ou blanc (mode:"0") ou des points (mode:"p" ou "gp") ou rien (mode:""), `s:`true/false pour avoir ou non les soustractions, 
// Possibilité de sousligner en couleur (`cycle-color`) le cycle dans le quotient avec `cycle:true` ou de l'avoir entre parenthèses `cycle:""` ou en couleur `cycle:red`
// Possibilité de présenter des divisions à trous avec `hide-result`, `list` et `solution` (de paramètres `type-mask`, `border-color` et `solution-color`)
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
// ```example
// // En héxadécimal avec décimales au quotient
// #division(base: 16, extradigits: 2, "1A8", "B", arrows: true)
// ```
// 
// -> content
#let division(
  // Base de numération (2 à 36) -> int
  base: 10,
  // Montrer ou non dans quelle base l'addition est posée -> boolean
  show-base:false,
  // dividende -> int | float | str
  a, 
  // diviseur -> int | float | str
  b,
  // Mode pour les zéros ajoutés au dividende : "g" (gris), "0" (noir), "p" (petit point), "gp" (grand point), "" (vide) -> str
  mode: "g",
  // Nombre de décimales supplémentaires à calculer au quotient -> int
  extradigits: 0,
  // pour afficher ou masquer les soustractions -> boolean
  s: true,
  // Détection et affichage automatique du cycle périodique -> boolean | str | color
  cycle: false, 
  // couleur du cycle ou du soulignage -> color
  cycle-color: luma(50%),
  // Mode fr:true, le séparateur décimal est "," sinon "." -> boolean
  fr: true,
  // Taille des colonnes du tableau -> length
  size: .7em,
  // dx for the ) in mode fr:false
  dx: 1.35em,
  // dy for the ) in mode fr:false
  dy: -.82em,
  // Masquer les étapes et le quotient pour le mode exercice -> boolean
  hide-result: false,
  // list des indices de cases à masquer (exercice à trous : a, b, étapes, quotient) -> array
  list: (),
  // Afficher ou non la solution dans les masques -> boolean
  solution: false,
  // Type de masque ("rect" ou "line") -> str
  type-mask: "rect",
  // Couleur de la bordure des cadres de masque -> color
  border-color: blue.mix(gray),
  // Couleur du texte de la solution -> color
  solution-color: red,
  // Espacement si plusieurs sur la même ligne -> length
  space: 1fr,
  // Affiche une flèche verticale entre chaque chiffre "descendu" du
  // dividende et la ligne où il est effectivement utilisé -> boolean
  arrows: false,
  // coefficient pour la taille des flèches, à ajuster entre 80% et 90% en fonction de la taille du texte, plus elle est grande, plus il doit diminuer -> ratio
  arrows-coef: 89%
) = {
  let decimal-separator = if fr { "," } else { "." }
  let size = if hide-result or list != () and size < .85em { .85em } else { size }

  // Helpers pour la conversion de base (2 à 36)
  let digits-str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let char-to-val(c) = {
    let c-up = upper(c)
    let pos = digits-str.clusters().position(x => x == c-up)
    if pos != none { pos } else { 0 }
  }
  let val-to-char(v) = digits-str.at(v)

  let parse-base(s) = {
    let val = 0
    for c in s.clusters() {
      val = val * base + char-to-val(c)
    }
    val
  }

  let int-to-base(v) = {
    if v == 0 { return "0" }
    let s = ""
    let temp = v
    while temp > 0 {
      let rem = calc.rem(temp, base)
      s = val-to-char(rem) + s
      temp = calc.trunc(temp / base)
    }
    s
  }

  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: border-color + .75pt, text(if solution == false { white } else { solution-color }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { solution-color }, x)))
  }

  let (cycle-flag, entoure, cycle-couleur) = if cycle not in (true, false) {
    if type(cycle) == color { (true, false, cycle) } else { (true, true, false) }
  } else {
    (cycle, false, false)
  }

  let a-str = upper(str(a).replace(",", "."))
  let b-str = upper(str(b).replace(",", "."))

  let b-dec-len = if b-str.contains(".") { b-str.split(".").at(1).len() } else { 0 }
  let b-int-str = b-str.replace(".", "")
  let b-int = parse-base(b-int-str)

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

  let dividend-stream = ()
  for d in a-int-str.clusters() { dividend-stream.push((char: d, is_extra: false)) }
  for d in a-dec-str.clusters() { dividend-stream.push((char: d, is_extra: false)) }

  let int-digits-count = a-int-str.clusters().len()
  let total-orig-count = dividend-stream.len()

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

    let d = char-to-val(item.char)
    val = val * base + d
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

        q-int-digits.push(val-to-char(q-digit))
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

      q-dec-digits.push(val-to-char(q-digit))
      val = rem-val

      if val == 0 and col-idx >= total-orig-count - 1 and (not cycle-flag or extra-added >= extradigits) {
        break
      }
    }

    col-idx += 1
  }

  if q-int-digits.len() == 0 { q-int-digits.push("0") }

  let remainder-row-of-step = ()
  let step-row-cursor = 0
  for st in steps {
    if s and st.sub-val > 0 { step-row-cursor += 1 }
    remainder-row-of-step.push(step-row-cursor)
    step-row-cursor += 1
  }
  let arrow-end-row = (:)
  for k in range(1, steps.len()) {
    arrow-end-row.insert(str(steps.at(k).col-idx), remainder-row-of-step.at(k - 1))
  }

  let covered-until = (-1,) * dividend-stream.len()
  let step-row = 0

  let cell-counter = 0

  let affichea = ()
  let total-cols = dividend-stream.len()
  for (i, item) in dividend-stream.enumerate() {
    let is-masked = (cell-counter in list) or (hide-result and item.is_extra)
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
      affichea.push([#box(char-disp)#decimal-separator])
    } else {
      affichea.push(char-disp)
    }
    cell-counter += 1
  }

  let afficheb = ()
  let b-clusters = b-int-str.clusters()
  for d in b-clusters {
    let is-masked = (cell-counter in list)
    if is-masked {
      afficheb.push(mask(d))
    } else {
      afficheb.push(d)
    }
    cell-counter += 1
  }

  let left-step-cells = ()

  for (k, st) in steps.enumerate() {
    let is-last = (k == steps.len() - 1)
    let next-st = if not is-last { steps.at(k + 1) } else { none }

    if s and st.sub-val > 0 {
      let sub-str = int-to-base(st.sub-val)
      let l-sub = sub-str.len()
      let start-col = st.col-idx - l-sub + 1

      for c in range(total-cols) {
        if arrows and step-row == 0 and str(c) in arrow-end-row and arrow-end-row.at(str(c)) >= 1 {
          left-step-cells.push(pull-down(arrow-end-row.at(str(c)), coef: arrows-coef))
          covered-until.at(c) = arrow-end-row.at(str(c)) - 1
        } else if arrows and covered-until.at(c) >= step-row {
          // colonne couverte par une flèche
        } else if c >= start-col and c <= st.col-idx {
          let digit = sub-str.at(c - start-col)
          let is-masked = hide-result or (cell-counter in list)
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
          let is-masked = hide-result or (cell-counter in list)
          let minus-disp = if is-masked { mask([--]) } else { [--] }
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#minus-disp])
          cell-counter += 1
        } else {
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
        }
      }
      step-row += 1
    }

    if next-st != none {
      let full-rem-str = int-to-base(st.rem-val) + next-st.brought-char
      let l-rem = full-rem-str.len()
      let end-col = st.col-idx + 1
      let start-col = end-col - l-rem + 1

      for c in range(total-cols) {
        if arrows and step-row == 0 and str(c) in arrow-end-row and arrow-end-row.at(str(c)) >= 1 {
          left-step-cells.push(pull-down(arrow-end-row.at(str(c)), coef: arrows-coef))
          covered-until.at(c) = arrow-end-row.at(str(c)) - 1
        } else if arrows and covered-until.at(c) >= step-row {
          // colonne couverte
        } else if c >= start-col and c <= end-col {
          let digit = full-rem-str.at(c - start-col)
          let is-masked = hide-result or (cell-counter in list)
          let disp = if is-masked { mask(digit) } else { digit }
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#disp])
          cell-counter += 1
        } else {
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
        }
      }
      step-row += 1
    } else {
      let rem-str = int-to-base(st.rem-val)
      let l-rem = rem-str.len()
      let end-col = st.col-idx
      let start-col = end-col - l-rem + 1

      for c in range(total-cols) {
        if arrows and step-row == 0 and str(c) in arrow-end-row and arrow-end-row.at(str(c)) >= 1 {
          left-step-cells.push(pull-down(arrow-end-row.at(str(c)), coef: arrows-coef))
          covered-until.at(c) = arrow-end-row.at(str(c)) - 1
        } else if arrows and covered-until.at(c) >= step-row {
          // colonne couverte
        } else if c >= start-col and c <= end-col {
          let digit = rem-str.at(c - start-col)
          let is-masked = hide-result or (cell-counter in list)
          let disp = if is-masked { mask(digit) } else { digit }
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[#disp])
          cell-counter += 1
        } else {
          left-step-cells.push(grid.cell(stroke: none, inset: (top: -.1em))[])
        }
      }
      step-row += 1
    }
  }

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
          if fr { afficheq.push(grid.cell(stroke: (bottom: .5pt + cycle-color), inset: (bottom: 1pt), d)) }
          else { afficheq.push(grid.cell(stroke: (top: .5pt + cycle-color), inset: (top: .5pt), d)) }
        } else {
          afficheq.push(text(d, cycle-couleur))
        }
      } else {
        afficheq.push(d)
      }
    }
  }

  let new-afficheq = ()
  for item in afficheq {
    let is-masked = hide-result or (cell-counter in list)
    if is-masked and item != [] and item != none {
      if decimal-separator not in item { new-afficheq.push(mask(item)) }
      else { new-afficheq.push(box(mask(item.at(0))) + decimal-separator) }
    } else {
      new-afficheq.push(item)
    }
    cell-counter += 1
  }
  afficheq = new-afficheq

  if fr {
    box(grid(
      columns: 2,
      align: (right + top, left + top),
      grid.vline(x: 1, stroke: 0.6pt),
      grid.hline(start: 1, y: 1, stroke: 0.6pt),

      grid.cell(
        inset: (right: 3pt, bottom: 2pt),
        grid(columns: total-cols * (size,), align: center + horizon, ..affichea)
      ),

      grid.cell(
        inset: (left: 3pt, bottom: 2pt),
        grid(columns: afficheb.len() * (size,), align: center + horizon, ..afficheb)
      ),

      grid.cell(
        inset: (right: 3pt, top: 2pt),
        grid(columns: total-cols * (size,), align: center + horizon, row-gutter: 2pt, ..left-step-cells)
      ),

      grid.cell(
        inset: (left: 3pt, top: 2pt),
        grid(columns: afficheq.len() * (size,), align: center + horizon, ..afficheq)
      )
    )+if show-base { place(top+right,dx:.55em,dy:.7em,box(width:.5em,align(left,$""^#base$))) }) + h(space)
  } else {
    box(grid(
      columns: 2,
      align: (right + top, left + top),
      grid.hline(start: 1, y: 1, stroke: 0.5pt),

      [],
      grid.cell(
        inset: (left: 3pt, bottom: 2pt),
        grid(columns: afficheq.len() * (size,), align: center + horizon, ..afficheq)
      ),

      grid.cell(
        inset: (right: 0pt, top: 2pt),
        grid(columns: b-int-str.len() * (size,), align: center + horizon, ..b-int-str.clusters() + (place(dx: dx, dy: dy, [)]),))
      ),

      grid.cell(
        inset: (left: 3pt, top: 2pt),
        grid(columns: total-cols * (size,), align: center + horizon, ..affichea)
      ),

      [],
      grid.cell(
        inset: (left: 3pt, top: 2pt),
        grid(columns: total-cols * (size,), align: center + horizon, row-gutter: 2pt, ..left-step-cells)
      ),
    )+if show-base { place(top+right,dx:.55em,dy:.7em,box(width:.5em,align(left,$""^#base$))) }) + h(space)
  }
}

= Racine carrée posée

// `racine(a,  extradigits: 0,  groups: false,  groups-color: blue.darken(20%),  step: none,  step-color: blue.darken(20%), s: true, decimal-separator: ",", size: 0.65em, hide-result: false, list: (), solution: false, type: "rect", border-color: blue.mix(gray), solution-color: red, space: 1fr,..args)` 

// Exemple :
//`#grid(columns: 3*(1fr,), row-gutter: 1em, 
// ..for i in range(1,11) {([
//   ==== Étape #i
//   #racine(24368, extradigits: 1,groups: true, step: i)
// ],)+if i == 1 {([],[],)}}
// )`

// Calcul de la racine carrée de a, avec `extradigits` décimales en plus, en montrant les `groups` de 2 en `groups-color`, avec possibilité d'afficher les étapes avec `step`, de cacher les soustractions avec `s`, de cacher les résultats ou une `list` de chiffres
// 
// *Exemples :* 
// ```example 
// #racine(24368,size: 1em,list: (2,27))
// ```
// #example(`#grid(columns: 3*(1fr,), row-gutter: 1em, 
// ..for i in range(1,11) {([
//   ==== Étape #i
//   #racine(24368, extradigits: 1,groups: true, step: i)
// ],)+if i == 1 {([],[],)}}
// )` , dir:ttb, scale-preview:100%)
// 
// -> content
#let racine(
  // nombre -> int | float
  a,
  // Nombre de tranches de "00" supplémentaires à calculer après la virgule -> int
  extradigits: 0,
  // Afficher des crochets au-dessus des tranches de 2 chiffres -> boolean
  groups: false,
  // Couleur des crochets -> color
  groups-color: blue.darken(20%),
  // Étape de résolution pas à pas -> none | int
  step: none,
  // couleur de l'étape -> color
  step-color: blue.darken(20%),
  // Afficher ou masquer les soustractions sous le dividende -> boolean
  s: true,
  // Mode fr:true, le séparateur décimal est "," sinon "." -> boolean
  fr:true,
  // Largeur des colonnes -> length
  size: 0.65em,
  // Masquer les étapes, les opérations et le résultat (mode exercice) -> boolean
  hide-result: false,
  // list des indices de cases à masquer (exercice à trous) -> array
  list: (),
  // Afficher ou non la solution dans les masques -> boolean
  solution: false,
  // Type de masque ("rect" ou "line") -> str
  type: "rect",
  // Couleur de la bordure des cadres de masque -> color
  border-color: blue.mix(gray),
  // Couleur du texte de la solution -> color
  solution-color: red,
  // espacement à droite -> length
  space: 1fr,
  ..args
) = {
  let decimal-separator = if fr {","} else {"."}
  let type-mask = type
  let mask(x) = if type-mask == "rect" {
    rect(width: .8em, height: .9em, radius: .35em, stroke: border-color + .75pt, text(if solution == false { white } else { solution-color }, x))
  } else {
    box(inset: 2pt, underline(stroke: (paint: black, dash: "dotted", thickness: .75pt), extent: .45pt, offset: 1.65pt, text(if solution == false { white } else { solution-color }, x)))
  }

  let crochet(body) = box(inset: (top: 3.5pt))[
    #place(top + right, dy: -.5em,dx:-size + .1em)[
      #rotate(-90deg,scale(180% * (size/1em))[#text(groups-color)[\]]])
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
        right-ops.push([$#doubled text(#step-color,c) times text(#step-color,c) lt.eq.slant #val$])
      } else if max-step >= step-trouve {
        right-ops.push([#mult-lhs $times$ #text(step-color,[#u]) = #sub-val])
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
        let is-masked = (cell-counter in list)
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
    
    if groups and is-vis {
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
            let is-masked = hide-result or (cell-counter in list)
            let disp = if is-masked { mask(digit) } else { digit }

            if c == start-col and start-col == 0 {
              left-step-cells.push(grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#place(dx: -0.5em, [--]) #disp])
            } else {
              left-step-cells.push(grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#disp])
            }
            cell-counter += 1
          } else if c == start-col - 1 and start-col > 0 {
            let is-masked = hide-result or (cell-counter in list)
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
            let is-masked = hide-result or (cell-counter in list)
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
            let is-masked = hide-result or (cell-counter in list)
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
            let is-masked = hide-result or (cell-counter in list)
            let disp = if is-masked { mask(digit) } else { digit }

            if c == start-col and start-col == 0 {
              left-step-cells.push(grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#place(dx: -0.5em, [--]) #disp])
            } else {
              left-step-cells.push(grid.cell(stroke: (bottom: 0.75pt), inset: (bottom: .1em, top: -.1em))[#disp])
            }
            cell-counter += 1
          } else if c == start-col - 1 and start-col > 0 {
            let is-masked = hide-result or (cell-counter in list)
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
            let is-masked = hide-result or (cell-counter in list)
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
    let is-masked = hide-result or (cell-counter in list)
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
    let is-masked = hide-result or (cell-counter in list)
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
      inset: (left: 4pt, bottom: if groups {-1pt} else {2pt}),align:horizon,
      grid(columns: calc.max(1, afficher-racine.len() + if args.len()>0 {1}) * (size,), align: center + horizon, ..afficher-racine, ..args)
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
  // termes -> arguments
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
  // termes -> arguments
  ..ops,
  // Nombre de chiffres -> auto | int
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