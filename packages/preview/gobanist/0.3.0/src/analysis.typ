// El análisis de las partidas: cómo se escriben sus números y de qué color va lo que pierde una jugada. Los
// datos vienen del kernel (kernel/src/sgf/analysis.rs), todos desde Negro: winrate de 0 a 1, lead (cuántos
// puntos gana Negro), prior de 0 a 1.

#let minus = "\u{2212}"

// x con digits decimales, sin signo.
#let fixed(x, digits) = {
  let scale = calc.pow(10, digits)
  let n = calc.round(calc.abs(x) * scale)
  let whole = str(int(calc.quo(n, scale)))
  if digits == 0 { return whole }
  let frac = str(int(calc.rem(n, scale)))
  whole + "." + "0" * (digits - frac.len()) + frac
}

// x con su signo: + si es positivo, − si es negativo (redondeado, el cero va sin signo).
#let signed(x, digits) = {
  let r = calc.round(x, digits: digits)
  (if r < 0 { minus } else if r > 0 { "+" } else { "" }) + fixed(x, digits)
}

// x con − solo si es negativo.
#let negative(x, digits) = (if calc.round(x, digits: digits) < 0 { minus } else { "" }) + fixed(x, digits)

// Si los números se escriben desde Negro: perspective "black", o "player" y el jugador no es Blanco.
#let from-black(a, player) = a.perspective == "black" or (a.perspective == "player" and player != "white")

// Los datos de una jugada o de una posición, como texto ("" lo que falta): winrate (en %, sin el signo), lead
// (con signo), visits, prior (en %) y loss (lo que pierde, en puntos; con − si gana), desde el jugador player
// según perspective. letter, si la tiene (una jugada propuesta).
#let values(a, data, player, letter: none) = {
  let d = a.digits
  let black = from-black(a, player)
  let get(key) = data.at(key, default: none)
  (
    letter: letter,
    winrate: if get("winrate") == none { "" } else {
      fixed(if black { get("winrate") * 100 } else { 100 - get("winrate") * 100 }, d)
    },
    lead: if get("lead") == none { "" } else { signed(if black { get("lead") } else { -get("lead") }, d) },
    visits: if get("visits") == none { "" } else { str(int(calc.round(get("visits")))) },
    prior: if get("prior") == none { "" } else { fixed(get("prior") * 100, d) },
    loss: if get("loss") == none { "" } else { negative(get("loss"), d) },
  )
}

// El color de lo que pierde loss (en puntos): el del mayor de colors que alcanza; none si no alcanza ninguno.
#let loss-color(a, loss) = {
  if loss == none { return none }
  let found = a.colors.sorted(key: ((p, _)) => -p).find(((p, _)) => loss >= p)
  if found == none { none } else { found.at(1) }
}

// Comprueba las opciones de analysis que se usan.
#let check-analysis(a) = {
  if a.perspective not in ("black", "white", "player") {
    panic("analysis.perspective es \"black\", \"white\" o \"player\": " + repr(a.perspective))
  }
  if type(a.digits) != int or a.digits < 0 { panic("analysis.digits es un número desde 0: " + repr(a.digits)) }
  for (key, branch) in (candidates: a.candidates, line: a.line) {
    if branch.count != auto and (type(branch.count) != int or branch.count < 0) {
      panic("analysis." + key + ".count es auto o un número: " + repr(branch.count))
    }
  }
  if a.line.from != auto and type(a.line.from) != int { panic("analysis.line.from es auto o un número") }
  if type(a.mistakes.count) != int or a.mistakes.count < 0 {
    panic("analysis.mistakes es un número desde 0: " + repr(a.mistakes.count))
  }
  if a.mistakes.player not in ("both", "black", "white") {
    panic("analysis.mistakes.player es \"both\", \"black\" o \"white\": " + repr(a.mistakes.player))
  }
  if type(a.colors) != array or a.colors.any(c => type(c) != array or c.len() != 2) {
    panic("analysis.colors es un arreglo de pares (puntos, color): " + repr(a.colors))
  }
  for key in ("text", "note") {
    let f = a.candidates.at(key)
    if f != auto and type(f) != function { panic("analysis.candidates." + key + " es auto o una función") }
  }
  a
}

// Lo que se escribe en la marca de una jugada propuesta: su letra o, con candidates.text, lo que devuelve.
#let candidate-text(a, v) = if a.candidates.text == auto { v.letter } else { (a.candidates.text)(v) }

// La nota de una jugada propuesta: «A: 52.3 %», o lo que devuelve candidates.note.
#let candidate-note(a, v) = if a.candidates.note == auto {
  [#v.letter: #v.winrate#sym.space.thin%]
} else { (a.candidates.note)(v) }

// Las notas de las jugadas propuestas (los datos que guarda el tablero: (letter, data, player)), separadas por
// candidates.separator; none si no hay.
#let candidates-text(a, list) = {
  if list.len() == 0 { return none }
  list.map(c => candidate-note(a, values(a, c.data, c.player, letter: c.letter))).join(a.candidates.separator)
}

// Las jugadas que más pierden según mistakes, en orden de jugada: de la serie del kernel (la evaluación de cada
// posición), en puntos si alguna tiene puntaje y si no en winrate. Solo las que pierden algo.
#let mistakes(a, series) = {
  let points = series.any(e => e.loss != none)
  let key = if points { "loss" } else { "loss-winrate" }
  let list = series.enumerate().filter(((k, e)) => (e.at(key) != none and e.at(key) > 0
    and (a.mistakes.player == "both" or e.player == a.mistakes.player)))
  list.sorted(key: ((k, e)) => (-e.at(key), k)).slice(0, calc.min(a.mistakes.count, list.len()))
    .map(((k, _)) => k).sorted()
}
