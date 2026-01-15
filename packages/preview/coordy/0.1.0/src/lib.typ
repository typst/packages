// Position Helper - Package Typst pour faciliter le positionnement d'éléments
// Auteur: E-Paroxysme
// Licence: MIT

/// Parse les caractères de commande depuis une chaîne
#let parse-commands(input) = {
  let text-content = if type(input) == str {
    input
  } else if type(input) == content {
    let result = ""
    if input.has("text") {
      result = input.text
    } else if input.has("children") {
      for child in input.children {
        if child.has("text") {
          result += child.text
        }
      }
    }
    result
  } else {
    ""
  }
  text-content.clusters().map(c => lower(c))
}

/// Calcule la position à partir des commandes
#let compute-position(
  commands: "",
  start-x: 297.5pt,
  start-y: 421pt,
  step: 10,
) = {
  let cmds = parse-commands(commands)

  let pos-x = start-x
  let pos-y = start-y
  let current-step = step

  for cmd in cmds {
    if cmd == "z" {
      pos-y = pos-y - current-step * 1pt
    } else if cmd == "s" {
      pos-y = pos-y + current-step * 1pt
    } else if cmd == "q" {
      pos-x = pos-x - current-step * 1pt
    } else if cmd == "d" {
      pos-x = pos-x + current-step * 1pt
    } else if cmd == "a" {
      current-step = calc.max(1, current-step - 1)
    } else if cmd == "e" {
      current-step = current-step + 1
    } else if cmd == "r" {
      pos-x = start-x
      pos-y = start-y
      current-step = step
    }
  }

  pos-x = calc.max(0pt, pos-x)
  pos-y = calc.max(0pt, pos-y)

  (x: pos-x, y: pos-y, step: current-step)
}

/// Crée l'overlay du position helper (à utiliser avec set page)
#let position-helper-overlay(
  commands: "",
  start-x: 297.5pt,
  start-y: 421pt,
  step: 10,
  marker-size: 8pt,
  marker-color: red,
  show-grid: false,
  grid-step: 50pt,
  margin: 2.5cm,
) = {
  let pos = compute-position(
    commands: commands,
    start-x: start-x,
    start-y: start-y,
    step: step,
  )

  let pos-x = pos.x
  let pos-y = pos.y
  let current-step = pos.step

  // Coordonnées relatives à la zone de contenu (après marges)
  let display-x = pos-x - margin
  let display-y = pos-y - margin

  // Grille optionnelle
  if show-grid {
    let grid-color = luma(200)
    for x in range(0, 13) {
      let xpos = x * grid-step
      place(
        top + left,
        dx: xpos,
        dy: 0pt,
        line(start: (0pt, 0pt), end: (0pt, 842pt), stroke: 0.5pt + grid-color)
      )
      place(
        top + left,
        dx: xpos + 2pt,
        dy: 2pt,
        text(size: 6pt, fill: grid-color)[#xpos]
      )
    }
    for y in range(0, 18) {
      let ypos = y * grid-step
      place(
        top + left,
        dx: 0pt,
        dy: ypos,
        line(start: (0pt, 0pt), end: (595pt, 0pt), stroke: 0.5pt + grid-color)
      )
      place(
        top + left,
        dx: 2pt,
        dy: ypos + 2pt,
        text(size: 6pt, fill: grid-color)[#ypos]
      )
    }
  }

  // Marqueur (point rouge)
  place(
    top + left,
    dx: pos-x - marker-size / 2,
    dy: pos-y - marker-size / 2,
    circle(
      radius: marker-size / 2,
      fill: marker-color,
      stroke: 1pt + marker-color.darken(30%)
    )
  )

  // Croix de visée
  place(
    top + left,
    dx: pos-x,
    dy: pos-y - marker-size,
    line(start: (0pt, 0pt), end: (0pt, marker-size * 2), stroke: 0.5pt + marker-color)
  )
  place(
    top + left,
    dx: pos-x - marker-size,
    dy: pos-y,
    line(start: (0pt, 0pt), end: (marker-size * 2, 0pt), stroke: 0.5pt + marker-color)
  )

  // Panneau d'information (compact)
  place(
    top + right,
    dx: -10pt,
    dy: 10pt,
    block(
      fill: white.transparentize(10%),
      stroke: 0.5pt + luma(150),
      inset: 5pt,
      radius: 3pt,
      [
        #set text(size: 8pt)
        #grid(
          columns: (auto, auto),
          gutter: 4pt,
          [X:], [#calc.round(display-x.pt(), digits: 1)],
          [Y:], [#calc.round(display-y.pt(), digits: 1)],
          [Pas:], [#current-step],
        )
      ]
    )
  )
}

/// Variable pour stocker les commandes (à modifier par l'utilisateur)
#let ph-commands = state("ph-commands", "")

/// Fonction courte pour usage rapide
///
/// Usage:
/// ```typst
/// #import "@local/position-helper:0.1.0": ph
///
/// #show: ph("ddddzzzz")
///
/// // Ton contenu normal ici
/// ```
#let ph(
  commands,
  start-x: 297.5pt,
  start-y: 421pt,
  step: 10,
  marker-size: 8pt,
  marker-color: red,
  show-grid: false,
  grid-step: 50pt,
  margin: 2.5cm,
) = {
  (body) => {
    set page(foreground: position-helper-overlay(
      commands: commands,
      start-x: start-x,
      start-y: start-y,
      step: step,
      marker-size: marker-size,
      marker-color: marker-color,
      show-grid: show-grid,
      grid-step: grid-step,
      margin: margin,
    ))
    body
  }
}

/// Alias long pour compatibilité
#let position-helper = ph
