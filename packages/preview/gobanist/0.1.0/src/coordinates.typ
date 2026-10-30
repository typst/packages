// La sintaxis de coordenadas de pgf-go. L es una letra mayúscula y N un número de una o dos cifras. Los
// rangos incluyen los dos extremos y se recorren del primero al segundo.
//
// Tramos (se encadenan: tienen un primer y un último punto):
//   LN               una intersección (C3).
//   L:L N o L N:N    un tramo de fila o de columna (A:C 3, C 1:3).
//   LN:LN            un rectángulo, de la primera esquina a la segunda. Sin orden, salvo que sea una línea.
// Operadores entre tramos (del último punto de uno al primero del siguiente):
//   -|  primero horizontal y después vertical.     |-  primero vertical y después horizontal.
//   --  línea en cualquier dirección.              -|- y |-|  esa línea, con la esquina de -| o de |-.
//   r   el contorno del rectángulo. Sin orden.
// Solos (ni se encadenan ni tienen orden): *, L, N, L:L, N:N y L:L N:N.
// Corchetes: L[...], [...]N y [...][...] se reparten en su lugar. Las comas separan elementos que se
// suman; los ; separan grupos que se suman y se restan alternadamente.

// La columna de la letra. Sin use-i, I y J son la 9.
#let column(letter, use-i) = {
  let n = letter.to-unicode() - "A".to-unicode() + 1
  if not use-i and letter.to-unicode() > "I".to-unicode() { n - 1 } else { n }
}

// La letra de la columna n.
#let column-letter(n, use-i) = {
  let letters = if use-i { "ABCDEFGHIJKLMNOPQRSTUVWXYZ" } else { "ABCDEFGHJKLMNOPQRSTUVWXYZ" }
  letters.at(n - 1)
}

// De a hasta b, con los dos extremos.
#let span(a, b) = if a <= b { range(a, b + 1) } else { range(a, b - 1, step: -1) }

#let sign(n) = if n > 0 { 1 } else if n < 0 { -1 } else { 0 }

// El rectángulo de esquinas (x1, y1) y (x2, y2), columna por columna desde x1 y cada columna desde y1.
#let rectangle(x1, y1, x2, y2) = {
  let points = ()
  for x in span(x1, x2) {
    for y in span(y1, y2) { points.push((x, y)) }
  }
  points
}

// A1 -| C3.
#let jota(x1, y1, x2, y2) = span(x1, x2).map(x => (x, y1)) + span(y1, y2).slice(1).map(y => (x2, y))

// A1 |- C3.
#let gamma(x1, y1, x2, y2) = span(y1, y2).map(y => (x1, y)) + span(x1, x2).slice(1).map(x => (x, y2))

// B1 r D3: una vuelta desde la primera esquina, primero horizontal.
#let frame(x1, y1, x2, y2) = {
  if x1 == x2 or y1 == y2 { return rectangle(x1, y1, x2, y2) }
  let a = if x1 > x2 { -1 } else { 1 }
  let b = if y1 > y2 { -1 } else { 1 }
  // De from a to con paso s (vacío si to queda antes de from).
  let walk(from, to, s) = if s > 0 { range(from, to + 1) } else { range(from, to - 1, step: -1) }
  (
    walk(x1, x2, a).map(x => (x, y1))
      + walk(y1 + b, y2, b).map(y => (x2, y))
      + walk(x2 - a, x1, -a).map(x => (x, y2))
      + walk(y2 - b, y1 + b, -b).map(y => (x1, y))
  )
}

// Cuánto se corrió el eje corto (que avanza d en total) en el paso i de steps: |d| * i / steps, redondeado.
// Si la recta pasa justo entre dos, gana la del lado del extremo más cercano, y en el medio exacto, la menor:
// así la línea no depende del orden de los extremos y es simétrica.
#let offset(d, i, steps) = {
  let base = calc.quo(calc.abs(d) * i, steps)
  let rest = 2 * (calc.abs(d) * i - base * steps)
  if rest == steps {
    if 2 * i == steps {
      if d < 0 { base += 1 }
    } else if 2 * i > steps { base += 1 }
  } else if rest > steps { base += 1 }
  base
}

// A1 -- E6, A1 -|- E6 y A1 |-| E6 (corner: none, "-|" o "|-"). Las piedras van en el orden del camino. El
// eje largo avanza de a una; en el corto, la posición más cercana a la recta.
#let stairs(corner, x1, y1, x2, y2) = {
  let dx = x2 - x1
  let dy = y2 - y1
  let steps = calc.max(calc.abs(dx), calc.abs(dy))
  if steps == 0 { return ((x1, y1),) }
  let points = ()
  let (px, py) = (x1, y1)
  for i in range(steps + 1) {
    let (x, y) = if calc.abs(dy) < calc.abs(dx) {
      (x1 + sign(dx) * i, y1 + sign(dy) * offset(dy, i, steps))
    } else {
      (x1 + sign(dx) * offset(dx, i, steps), y1 + sign(dy) * i)
    }
    // En un escalón (cambian las dos), la esquina de -| o de |- va antes.
    if i > 0 and x != px and y != py {
      if corner == "-|" { points.push((x, py)) }
      if corner == "|-" { points.push((px, y)) }
    }
    points.push((x, y))
    (px, py) = (x, y)
  }
  points
}

// El operador op de (x1, y1) a (x2, y2), con los dos extremos.
#let link(op, x1, y1, x2, y2) = {
  if op == "--" { stairs(none, x1, y1, x2, y2) }
  else if op == "-|-" { stairs("-|", x1, y1, x2, y2) }
  else if op == "|-|" { stairs("|-", x1, y1, x2, y2) }
  else if op == "-|" { jota(x1, y1, x2, y2) }
  else if op == "|-" { gamma(x1, y1, x2, y2) }
  else { frame(x1, y1, x2, y2) }
}

// Los tramos: la expresión y en qué grupos están las esquinas (letra, número, letra, número).
#let pieces = (
  (regex("^([A-Z])(\d{1,2})$"), (0, 1, 0, 1)),
  (regex("^([A-Z]):([A-Z])\s*(\d{1,2})$"), (0, 2, 1, 2)),
  (regex("^([A-Z])\s*(\d{1,2}):(\d{1,2})$"), (0, 1, 0, 2)),
  (regex("^([A-Z])(\d{1,2}):([A-Z])(\d{1,2})$"), (0, 1, 2, 3)),
)

// Las esquinas (x1, y1, x2, y2) del tramo, o none si no es un tramo.
#let corners(text, use-i) = {
  for (pattern, (a, b, c, d)) in pieces {
    let m = text.match(pattern)
    if m != none {
      let g = m.captures
      return (column(g.at(a), use-i), int(g.at(b)), column(g.at(c), use-i), int(g.at(d)))
    }
  }
  none
}

// Una sola intersección (C3), o none.
#let point(text, use-i) = {
  let m = text.trim().match(regex("^([A-Z])(\d{1,2})$"))
  if m == none { none } else { (column(m.captures.at(0), use-i), int(m.captures.at(1))) }
}

// Lo que va solo. window: la parte visible, (x1, y1, x2, y2).
#let alone(text, use-i, window) = {
  let (fx, fy, tx, ty) = window
  let m = text.match(regex("^([A-Z]):([A-Z])\s*(\d{1,2}):(\d{1,2})$"))
  if m != none {
    let g = m.captures
    let (x1, y1, x2, y2) = (column(g.at(0), use-i), int(g.at(2)), column(g.at(1), use-i), int(g.at(3)))
    return (points: rectangle(x1, y1, x2, y2), ordered: x1 == x2 or y1 == y2)
  }
  let m = text.match(regex("^([A-Z])(?::([A-Z]))?$"))
  if m != none {
    let a = column(m.captures.at(0), use-i)
    let b = if m.captures.at(1) == none { a } else { column(m.captures.at(1), use-i) }
    return (points: rectangle(a, fy, b, ty), ordered: false)
  }
  let m = text.match(regex("^(\d{1,2})(?::(\d{1,2}))?$"))
  if m != none {
    let a = int(m.captures.at(0))
    let b = if m.captures.at(1) == none { a } else { int(m.captures.at(1)) }
    return (points: rectangle(fx, a, tx, b), ordered: false)
  }
  if text == "*" { return (points: rectangle(fx, fy, tx, ty), ordered: false) }
  panic("coordenada desconocida: «" + text + "»")
}

#let link-pattern = regex("\s*(-\|-|\|-\||--|-\||\|-|r)\s*")

// Un elemento (lo que está entre dos comas): una cadena de tramos y operadores, o algo que va solo. Cada
// operador va del último punto de un tramo al primero del siguiente, y el punto que comparten va una vez.
#let item(text, use-i, window) = {
  let parts = text.split(link-pattern)
  let links = text.matches(link-pattern).map(m => m.captures.at(0))
  let found = parts.map(p => corners(p, use-i))
  if found.contains(none) {
    if links.len() == 0 { return alone(text, use-i, window) }
    panic("coordenada desconocida: «" + text + "»")
  }
  let piece(c) = rectangle(..c)
  let unordered(c) = c.at(0) != c.at(2) and c.at(1) != c.at(3)
  let points = piece(found.at(0))
  let ordered = not unordered(found.at(0))
  for (i, op) in links.enumerate() {
    let (from, to) = (found.at(i), found.at(i + 1))
    points += link(op, from.at(2), from.at(3), to.at(0), to.at(1)).slice(1)
    points += piece(to).slice(1)
    if op == "r" or unordered(to) { ordered = false }
  }
  (points: points, ordered: ordered)
}

// Reparte los corchetes en su lugar: A[1:3, 5] es A1:3, A5.
#let brackets(text) = {
  let split(s) = s.split(",").map(str.trim).filter(s => s != "")
  let rules = (
    (regex("\[([^\]]*)\]\[([^\]]*)\]"), (a, b) => split(a).map(l => split(b).map(n => l + n)).flatten()),
    (regex("([A-Z])\[([^\]]*)\]"), (a, b) => split(b).map(n => a + n)),
    (regex("\[([^\]]*)\](\d{1,2})"), (a, b) => split(a).map(l => l + b)),
  )
  for (pattern, expand) in rules {
    let m = text.match(pattern)
    while m != none {
      let (a, b) = m.captures
      text = text.slice(0, m.start) + expand(a, b).join(", ") + text.slice(m.end)
      m = text.match(pattern)
    }
  }
  text
}

// Las intersecciones de las coordenadas, en orden. Sin moves, no se repiten y los ; alternan entre sumar
// y restar; con moves, se repiten y no hay grupos. Devuelve (points: ((x, y), ...), ordered: bool):
// ordered dice si todo lo que suma tiene un orden fijo.
#let parse(text, use-i: false, window: (1, 1, 19, 19), moves: false) = {
  let groups = text.split(";")
  if moves and groups.len() > 1 { panic("las jugadas no tienen grupos que restan: «" + text + "»") }
  let slots = ()
  let seen = (:)
  let ordered = true
  let subtract = false
  for group in groups {
    for element in brackets(group).split(",").map(str.trim).filter(s => s != "") {
      let result = item(element, use-i, window)
      if not subtract and not result.ordered { ordered = false }
      for p in result.points {
        let key = str(p.at(0)) + "," + str(p.at(1))
        if subtract {
          if key in seen {
            slots.at(seen.at(key)) = none
            let _ = seen.remove(key)
          }
        } else if moves or key not in seen {
          seen.insert(key, slots.len())
          slots.push(p)
        }
      }
    }
    subtract = not subtract
  }
  (points: slots.filter(p => p != none), ordered: ordered)
}
