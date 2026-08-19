#import "/prepa-prio.typ":* 

// ---------------------------------------------------------
// FONCTION PRINCIPALE : ETAPES-CALCUL
// ---------------------------------------------------------

// etapes-calcul(expr-str, mode: "fr", concomitant: false, vertical: false, digits: 2, n: 0,  name: "", todo: false, space: 1fr, fraction: false, highlight: rgb("#1e88e5"), skip: ()) 

// Fait le calcul détaillé de expr-str (sauf si todo:true) avec possibilité d'avoir les calculs indépendants de même priorité fait simultanément avec concomitant, en mode vertical ou horizontal, et mise en avant de l'étape en cours (highlight) avec un mode fraction forcant la poursuite des calculs avec des fractions 
// 
// ```example
// #etapes-calcul("[ 6 + 5 * (23 + 8 / 2) ] * 8", fraction: false, vertical: true,n:0)
// ```
// ```example
// #etapes-calcul("(200 - 45 * 2) / ((4 * 7 - 3 : 6) * 2)",concomitant: true)
// ```
// ```example
// #etapes-calcul("2 * pi * 3", fraction: false, name: "B",n:3)
// ```
// ```example
// #etapes-calcul("ln(exp(1)) + 3", fraction: true, name: "E")
// ``` #v(2em)
// ```example 
// #etapes-calcul("sqrt(8)*sqrt(27)", fraction: true)
// ```
// -> content
#let etapes-calcul(
  // -> str
  expr-str, 
  // mode "fr" ou "en" pour le séparateur décimal -> str
  mode: "fr", 
  // Passer à true pour avoir les calculs indépendants de même priorité fait simultanément -> boolean
  concomitant: false,
  // Pour avoir une présentation "en colonne" du calcul -> boolean
  vertical: false,
  // Nombre de décimales dans les calculs avec pi ... -> int
  digits: 2,
  // Nombre d'étapes (comptées depuis la fin) auquel remplacer le = par un approx si besoin -> int
  n: 0,
  // Nom à ajouter au début de l'expression -> str | content
  name: "",
  // Mode énoncé, seul l'expression proposé + un = apparaît -> boolean
  todo: false,
  // Espacement horizontal entre deux etapes-calcul -> length
  space: 1fr,
  // En mode fraction, le calcul reste exact : soit en mode fraction soit en s'arrêtant à 5pi par ex. -> boolean
  fraction: false,
  // Soit une couleur qui met en avant les calculs en cours soit false pour du gras ou none pour rien du tout -> color | boolean | none
  highlight: rgb("#1e88e5"),
  // liste des étapes à sauter si nécessaire -> array
  skip: ()
) = {
  let tokens = tokenize(expr-str, fraction: fraction)
  let steps = ()
  
  if todo {
    steps.push(format-tokens(tokens, mode, fraction: fraction, highlight: none, digits: digits))
    steps.push("#hide[a]")
  } else {
    let max-steps = 30 
    let count = 0
    let current-tokens = tokens
    
    while current-tokens.len() > 1 and count < max-steps {
      let step-info = process-step(current-tokens, concomitant)
      let active-ops = step-info.active-ops
      let paren-to-remove = step-info.paren-to-remove
      let active-simplifications = step-info.active-simplifications
      let active-funcs = step-info.active-funcs
      
      if active-ops.len() == 0 and paren-to-remove.len() == 0 and active-simplifications.len() == 0 and active-funcs.len() == 0 { break }
      
      let next-tokens = compute-next-tokens(current-tokens, active-ops, paren-to-remove, active-simplifications, active-funcs, fraction)
      
      let current-unhighlighted = format-node-list(group-fractions-in-list(nest-parentheses(current-tokens)), mode, fraction, none, digits, ignore-highlight: true)
      let next-unhighlighted = format-node-list(group-fractions-in-list(nest-parentheses(next-tokens)), mode, fraction, none, digits, ignore-highlight: true)
      
      if current-unhighlighted == next-unhighlighted {
        current-tokens = next-tokens
        continue
      }
      
      let highlighted = apply-highlights(current-tokens, active-ops, paren-to-remove, active-simplifications, active-funcs)
      steps.push(format-tokens(highlighted, mode, fraction: fraction, highlight: highlight, digits: digits))
      current-tokens = next-tokens
      count += 1
    }
    steps.push(format-tokens(current-tokens, mode, fraction: fraction, highlight: none, digits: digits))
    
    if not fraction and current-tokens.len() == 1 {
      let last-t = current-tokens.at(0)
      if last-t.type == "num" and (last-t.symbol != none or last-t.at("radicand", default: 1) > 1) {
        let approx-token = last-t
        approx-token.insert("is-final-approx", true)
        steps.push(format-tokens((approx-token,), mode, fraction: false, highlight: none, digits: digits))
      }
    }
  }
  
  let unique-steps = ()
  for step in steps {
    if unique-steps.len() == 0 or unique-steps.at(-1) != step { unique-steps.push(step) }
  }
  
  let filtered-steps = ()
  let len = unique-steps.len()
  let normalized-skip = skip.map(idx => if idx < 0 { len + idx + 1 } else { idx })
  let idx = 0
  while idx < len {
    let step-num = idx + 1
    if step-num not in normalized-skip { filtered-steps.push(unique-steps.at(idx)) }
    idx += 1
  }
  
  let equal = if vertical { " \ = & " } else { " = " }
  let appro = if vertical { "\ approx & "} else {" approx "}
  show math.equation: math.display
  
  let effective-n = n //if n == 0 and not fraction and unique-steps.len() > 1 { unique-steps.len() - 1 } else { n }
  
  let part2 = filtered-steps.slice(effective-n).join(appro)
  let part1 = filtered-steps.slice(0, effective-n).join(equal)
  let result = if effective-n == 0 or fraction { filtered-steps.join(equal) } else { part1 + appro + part2 }
  
  set-round(precision:digits, mode:"places", pad: false)
  show regex("\d+(\.\d+)?"): x => math.class("normal", num(x))
  show math.equation: it => {
    show regex("\d+(\.\d+)?"): x => math.class("normal", num(x))
    show regex("[A-Z]"): math.upright
    it
  }
  
  if mode == "fr" {
    box({
      show math.frac: math.display
      set-num(decimal-separator: "," + h(0pt))
      eval("$ " + if name != "" { name + " = " } + "& " + result + " $")
    }, outset: 0pt)
  } else {
    box({
      set-num(decimal-separator: "." + h(0pt))
      eval("$ " + if name != "" { name + " = " } + "& " + result + " $")
    }, outset: 0pt)
  } + h(space)
}

= Fonction détail pour détailler les calculs manuellement
// `
// #detail(
//   expr-str,
//   vertical: false,
//   arrondi: false,
//   digits: 2,
//   appro: 0,
//   todo: false,
//   space: 1fr,
//   a: aqua,
//   b: blue,
//   f: fuchsia,
//   g: olive,
//   r: red,
//   l: gray,
//   m: maroon,
//   n: navy,
//   o: orange,
//   t: teal,
//   p: purple,
//   y: yellow,
//   c: "cancel", // or c:"circle"
// )
// `

// `detail`(expr-str, `vertical:`false, `arrondi:`false, `digits:`2, `appro:`0, `todo:`false, `space:`1fr, `a:` aqua, ..., `c:` "color",) avec s18 -> sqrt(18) automatiquement
// Les paramètres `a, b, f, g, r, l, m, n, o, p, t, y` permettent de changer les couleurs typst par défaut si besoin

// Fonction pour détailler les calculs manuellement 
// #v(2em)
// ```example
// #detail("A=15/21=(5*r3)/(7*r3)=5/7",arrondi:true,c:"circle")
// ```
// ```example
// #detail("B=(15s2)/(21s18)=(5*r3 s2)/(7*r3 s(9*2))=(5 ps2)/(21 bs2) =5/21",c:"color",vertical:true, arrondi: true)
// ```
// ```example
// #detail("cal(A)=pi * r^2 = pi*5^2=25 pi",arrondi: true,digits: 4)
// ```
// -> content
#let detail(
  // Le calcul comme avant -> str
  expr-str,
  // mode vertical ou non -> boolean
  vertical:false,
  // Si ajout d'un arrondi à la fin ou non -> boolean
  arrondi:false,
  // le nombre de chiffres de l'arrondi -> int
  digits:2,
  // rang à partir duquel remplacer les = par des approx si besoin -> int
  appro:0,
  // si todo:true, seul l'expression initiale est affichée -> boolean
  todo:false,
  // l'espace de séparation avant le calcul suivant -> length
  space:1fr,
  // a:aqua peut être changée de la couleur typst par défaut si besoin -> color
  a: aqua,
  // b: blue peut être changée de la couleur typst par défaut si besoin -> color
  b: blue,
  // f: fuchsia peut être changée de la couleur typst par défaut si besoin -> color
  f: fuchsia,
  // g: green peut être changée de la couleur typst par défaut si besoin -> color
  g: green,
  // r: red peut être changée de la couleur typst par défaut si besoin -> color
  r: red,
  // l: gray peut être changée de la couleur typst par défaut si besoin -> color
  l: gray,
  // m: maroon peut être changée de la couleur typst par défaut si besoin -> color
  m: maroon,
  // n:rgb(8, 111, 189) -> navy peut être changée si besoin -> color
  n: rgb("#086fbd"),
  // o: orange peut être changée de la couleur typst par défaut si besoin -> color
  o: orange,
  // t: rgb(0,128,128) -> teal peut être changée si besoin -> color
  t: rgb(0,128,128),
  // p: purple peut être changée de la couleur typst par défaut si besoin -> color
  p: purple,
  // y: yellow peut être changée de la couleur typst par défaut si besoin -> color
  y: yellow,
  // choix du mode "cancel" ou "circle" ou "color" -> str
  c: "color",
) = {
  // Cartographie des identifiants de couleur vers leurs variables respectives
  let color-map = (
    a: a, b: b, f: f, g: g, r: r, l: l, m: m, n: n, o: o, t: t, p: p, y: y
  )
  
  // Fonction interne de stylisation appelée lors de l'évaluation
  let deco(color-key, body) = {
    let color-val = color-map.at(color-key, default: red)
    if c == "circle" {
      circle(inset: 0pt, stroke: color-val, body)
    } else if c == "color" {
      text(fill: color-val, body)
    } else {
      math.cancel(stroke: color-val, body)
    }
  }

  // Découpage des différentes étapes du calcul
  let steps = expr-str.split("=")
  // if vertical and steps.at(0).match(regex("^\s*[a-zA-Z]+\s*$")) == none { steps = ("&" + steps.at(0) + " \\ ",) + steps.slice(1) }
  if vertical and steps.at(0).match(regex("^\\s*[a-zA-Z]+(\\([a-zA-Z]+\\))?\\s*$")) == none { steps = ("&" + steps.at(0) + " \\ ",) + steps.slice(1) }
  if todo {
    steps = steps.slice(0, calc.min(1, steps.len()))
    steps.push("")
  }

  // Transformation sécurisée via des fonctions de remplacement anonymes
  let processed-steps = ()
  for step in steps {
    let s = step
    
    // 1. Motifs colorés complexes (lettre + racine avec parenthèses) : rs(9*2)
    s = s.replace(regex("([abfgrlmnotpy])s\((.*?)\)"), m => "#deco(\"" + m.captures.at(0) + "\", [$sqrt(" + m.captures.at(1) + ")$])")
    
    // 2. Motifs colorés simples (lettre + racine directe) : bs2
    s = s.replace(regex("([abfgrlmnotpy])s(\d+)"), m => "#deco(\"" + m.captures.at(0) + "\", [$sqrt(" + m.captures.at(1) + ")$])")
    
    // 3. Chiffres colorés directs : r3
    s = s.replace(regex("([abfgrlmnotpy])(\d+)"), m => "#deco(\"" + m.captures.at(0) + "\", [$" + m.captures.at(1) + "$])")
    
    // 4. Racines standards avec parenthèses : s(18)
    s = s.replace(regex("s\((.*?)\)"), m => " sqrt(" + m.captures.at(0) + ") ")
    
    // 5. Racines standards directes : s2
    s = s.replace(regex("s(\d+)"), m => " sqrt(" + m.captures.at(0) + ") ")
    
    // 6. Remplacement du signe multiplicateur
    s = s.replace("*", " times ")
    
    processed-steps.push(s)
  }

  // Assemblage des lignes selon le mode horizontal ou vertical
  let final-math-str = ""
  if vertical {
    let lines = ()
    if processed-steps.len() > 1 {
      let op1 = if appro > 0 and 1 >= appro { " approx & " } else { " = & " }
      lines.push(processed-steps.at(0) + op1 + processed-steps.at(1))
      
      for i in range(2, processed-steps.len()) {
        let op = if appro > 0 and i >= appro { " approx & " } else { " = & " }
        lines.push(op + processed-steps.at(i))
      }
      final-math-str = lines.join(" \\ \n")
    } else {
      final-math-str = processed-steps.at(0)
    }
  } else {
    final-math-str = processed-steps.at(0)
    for i in range(1, processed-steps.len()) {
      let op = if appro > 0 and i >= appro { " approx " } else { " = " }
      final-math-str += op + processed-steps.at(i)
    }
  }
  let signe = "≈"
  
  if arrondi not in (true,false) {arrondi = true;signe = "="}
  
  // Calcul automatique et injection de la valeur arrondie si demandée
  if arrondi and not todo and steps.len() > 0 {
    let last-raw = steps.last()

    if "pi" in last-raw {
      let clean-raw = last-raw.replace(regex("(\d+) pi"), m=> m.captures.at(0)+ " times " +str(calc.round(3.141592653589793, digits: digits)))

      
      let rounded = clean-raw + "≈" + str(calc.round(eval(clean-raw.replace("times","*")), digits: digits)) + "≈" + str(calc.round(eval(clean-raw.replace("times","*")), digits: digits - 1))
      if vertical {
      final-math-str += " \\ "+signe+"& " + str(rounded)
    } else {
      final-math-str += signe + str(rounded)
    }
    } else {
    let clean-raw = last-raw
      .replace(regex("s\((.*?)\)"), m => "calc.sqrt(" + m.captures.at(0) + ")")
      .replace(regex("s(\d+)"), m => "calc.sqrt(" + m.captures.at(0) + ")")
      // .replace(regex("(\d+) pi"), m=> (m.captures.at(0)+ "*" +str(calc.round(3.141592653589793, digits: digits)),"3.141592653589793 *"+m.captures.at(0)))
      .replace(regex("(\d+) pi"), m=> "3.141592653589793 *"+m.captures.at(0))
      .replace(regex("(.*?)\^(\d+)"), m=> str(calc.pow(float(m.captures.at(0)), float(m.captures.at(1)))))
      .replace(regex("[abfgrlmnotpy]"), "")
      
    
    let num-value = eval(clean-raw)
    let rounded = calc.round(num-value, digits: digits)
    if vertical {
      final-math-str += " \\ "+signe+"& " + str(rounded)
    } else {
      final-math-str += signe + str(rounded)
    }
  }
    
  }

  // Génération du bloc d'équation final sans conflit de délimiteurs
  box(
    math.equation(block: true, eval(final-math-str, mode: "math", scope: (deco: deco))),
    // after: space
  )+h(space)
}

