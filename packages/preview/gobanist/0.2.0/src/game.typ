// Lo que queda del último tablero dibujado: los prisioneros, las notas «N en M», el puntaje y las regiones.

#import "options.typ": current
#import "coordinates.typ": column-letter
#import "texts.typ": word

// Lo guarda cada goban al dibujarse: (prisoners, score, notes, regions, use-i).
#let last = state("goban-last", none)

#let players-text = ("black", "white", "neutral")

#let get-last(name) = {
  let data = last.get()
  if data == none { panic(name + " necesita un goban antes") }
  data
}

#let check-player(name, player, allowed) = {
  if player not in allowed { panic(name + ": el jugador es " + allowed.join(", ", last: " o ") + ": " + repr(player)) }
}

// Cuántos prisioneros tiene el jugador en el último goban: las piedras del rival que capturaron sus jugadas.
#let goban-prisoners(player) = context {
  check-player("goban-prisoners", player, ("black", "white"))
  str(get-last("goban-prisoners").prisoners.at(player))
}

// El puntaje del jugador en el último goban, con las reglas japonesas: los puntos de su territorio, más las
// piedras muertas del rival que hay en él, más las que capturó, más el komi para las blancas. Con
// "neutral", los puntos neutrales.
#let goban-score(player, komi: auto) = context {
  check-player("goban-score", player, players-text)
  let komi = if komi == auto { current().score.komi } else { komi }
  let points = get-last("goban-score").score.at(player) + if player == "white" { komi } else { 0 }
  str(points)
}

// Las notas (n, m) de un tablero, «N en M» y, de los pases (m: none), «N: pasa», separadas por separator, con
// las opciones de text de notes.text. Los textos son at y pass del idioma. Necesita context.
#let notes-text(tree, notes, at: auto, separator: auto) = {
  let options = tree.notes
  let at = if at != auto { at } else if options.at != auto { options.at } else { word(tree, "at") }
  let separator = if separator == auto { options.separator } else { separator }
  let body = notes.map(((n, m)) => {
    if m == none { str(n) + ": " + word(tree, "pass") } else { str(n) + " " + at + " " + str(m) }
  }).join(separator)
  if body == none or options.text.len() == 0 { body } else { text(..options.text, body) }
}

// Las notas del último goban.
#let goban-notes(at: auto, separator: auto) = context {
  notes-text(current(), get-last("goban-notes").notes, at: at, separator: separator)
}

// Una propiedad de la región (draw: "region") del jugador en el último goban: "polygons", "outlines",
// "holes", "vertices", "area", "perimeter" o "polygon" (con n, desde 1: sus vértices como coordenadas).
#let goban-region(player, property, n: none) = context {
  check-player("goban-region", player, ("black", "white"))
  let data = get-last("goban-region")
  let region = data.regions.at(player)
  let properties = ("polygons", "outlines", "holes", "vertices", "area", "perimeter", "polygon")
  if property not in properties { panic("goban-region: la propiedad es " + properties.join(", ") + ": " + repr(property)) }
  if property == "polygon" {
    if type(n) != int { panic("goban-region: \"polygon\" necesita n") }
    if region == none or n < 1 or n > region.contours.len() { return "" }
    region.contours.at(n - 1).map(((x, y)) => column-letter(x, data.use-i) + str(y)).join(", ")
  } else {
    str(if region == none { 0 } else { region.at(property) })
  }
}
