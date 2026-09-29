#import "@preview/numbly:0.1.0": numbly


//// Global variables that can be accessed via --input

#let year-global= if "year" in sys.inputs { int(sys.inputs.year) } else { none }
#let round-global = if "round" in sys.inputs { int(sys.inputs.round) } else { none }
#let publish-global = if "publish" in sys.inputs { sys.inputs.publish == "true" } else { none }
#let metadata-global = if "metadata" in sys.inputs { sys.inputs.metadata == "true" } else { none }


//// Exporting functions

// Counters

#let task-counter = counter("task")
#let task = {
  task-counter.step()
  box(width: 2em, context strong(task-counter.display("(a)")))
}

#let numstep(counter) = {
  counter.step()
  context counter.display("1.")
}

#let letstep(counter) = {
  counter.step()
  context counter.display("A.")
}

// Table styles

#let matching-table(body) = {
  show table.cell.where(x: 1): set text(weight: "bold")
  show table.cell.where(x: 3): set text(style: "italic")
  set table(
    stroke: none,
    columns: 4,
    align: (right, left, right, left),
    column-gutter: (0em, 6em, 0em),
  )
  body
}

#let translation-table(body) = {
  show table.cell.where(x: 1): set text(weight: "bold")
  show table.cell.where(x: 2): set text(style: "italic")
  set table(
    stroke: none,
    columns: 3,
    align: (right, left, left),
    column-gutter: (0em, 2em),
  )
  body
}

#let number-table(body) = {
  show table.cell.where(x: 0): set text(weight: "bold")
  show table.cell.where(x: 1): set text(weight: "regular")
  set table(
    stroke: none,
    columns: 2,
    align: (left, right),
    column-gutter: 2em,
  )
  body
}

#let booktabs-table(body) = {
  show table.cell: set text(weight: "regular")
  show table.cell: set text(style: "normal")
  show table: set table(
    stroke: (x, y) => (
      top: if y == 0 { 1pt } else if y == 1 { 0.7pt } else { 0pt },
      bottom: 1pt,
    ),
  )
  set table(
    stroke: 1pt + black,
    columns: (),
    align: auto,
    column-gutter: (),
  )
  body
}

#let standard-table(body) = {
  show table.cell: set text(weight: "regular")
  show table.cell: set text(style: "normal")
  set table(
    stroke: 1pt + black,
    columns: (),
    align: auto,
    column-gutter: (),
  )
  body
}

// #show: dol-theme.with(...)
#let dol-theme(
  title: none,
  longtitle: none,
  author: none,
  points: none,
  composition: none,
  background: none,
  solution: false,
  solution-file: none,
  year: none,
  round: none,
  publish: false,
  metadata: true,
  body,
) = {
  if year-global != none { year = year-global }
  if round-global != none { round = round-global }
  if publish-global != none { publish = publish-global }
  if metadata-global != none { metadata = metadata-global }
  let embed = solution and publish

  if metadata {
    if author != none { set document(author: author.text) }
    if title != none { set document(title: title.text + if solution { "-Solution" } else { "" }) }
  }

  // Local functions

  let longtitle = if longtitle == none { title } else { longtitle }

  let titleheader(title, author, year, round) = if publish and not solution {
    align(center)[
      #v(4em)

      #text(20pt, title)

      #text(14pt, author)

      #{
        if year != none [DOL #year]
        if year != none and round != none [, ]
        if round != none [Runde #round]
      }

      #v(2em)
    ]
  }

  let hintergrund(it) = if publish and not solution and background != none [
    #set par(
      spacing: 1.2em,
      first-line-indent: (amount: 1em, all: false),
    )
    = Hintergrund
    #it
  ]

  let punkte(points, composition: none) = {
    if composition != none { text(10pt)[(#composition)] }
    h(1em)
    if points == 1 [_1 Punkt_] else if points == none [] else [_#points Punkte_]
  }

  let problem(points, compo: none, title) = [
    #set heading(numbering: numbly(
      if publish {
        if solution { "Lösungen" } else { "Aufgaben" }
      } else if metadata { "Aufgabe {1}:" }
      else { "Aufgabe {1}" }))

    = #if embed [] else [
      #if metadata and not publish { title }
      #if solution [ --- Lösung ]
      #h(1fr)
      #text(13pt, weight: "regular", punkte(points, composition: compo))
    ]
  ]

  // Style

  task-counter.update(0)

  show heading: it => stack(it, v(6pt))

  show: matching-table

  set text(
    lang: "de",
    size: 11pt,
  )

  set par(
    justify: true,
    spacing: 1.5em,
  )

  let content-body = {
    titleheader(longtitle, author, year, round)
    hintergrund(background)
    problem(points, compo: composition, title)
    body
    if author != none and metadata and not publish and not solution [#h(1fr) -- _#author _]
    if publish and not solution and solution-file != none { solution-file }
  }
  
  if embed {
    content-body
  } else {
    set page(
      header: [
        #box(baseline: 1.5em, image("assets/logosColors.pdf", height: 1.5cm))
        #h(1fr)
        #box(align(right, emph({
          if publish [#longtitle\ ]

          if year != none [DOL #year]
          if year != none and round != none [, ]
          if round != none [Runde #round]
        })))
      ],

      margin: (
        top: 4cm,
        bottom: if publish { 4.5cm } else { auto },
        x: 2cm,
      ),

      footer: if publish {
        context [
          #box(stroke: 1pt, inset: 5pt)[
            #show link: set text(fill: navy)

            #box(image("assets/by.svg", height: 0.5cm), baseline: bottom) _#longtitle _ von #author ist lizensiert unter einer #link("http://creativecommons.org/licenses/by/4.0/")[Creative Commons Namensnennung 4.0 International Lizenz]. Besonders im Unterricht an Schulen und Hochschulen darf das Rätsel gerne unter Nennung der Autorschaft und der DOL verwendet werden.
          ]
          #align(center, counter(page).display())
        ]
      } else { auto },
      footer-descent: if publish { 1.8em } else { 30% + 0pt },
    )

    content-body
  }
}

#let compile-problems(
  time: none,
  editors: none,
  year: none,
  round: none,
  body
) = {
  if year-global != none { year = year-global }
  if round-global != none { round = round-global }

  if editors != none { set document(author: editors.text) }
  if year != none {
    set document(title: "dol" + str(year).slice(-2) + if round != none { "-" + str(round) } else { "" })
  }

  // Style

  set par(justify: true)
  
  set page(
    numbering: "1",

    header: [
      #box(baseline: 1.5em, image("assets/logosColors.pdf", height: 1.5cm))
      #h(1fr)
      #box(align(right, emph({
        if year != none [DOL #year]
        if year != none and round != none [, ]
        if round != none [Runde #round]
      })))
    ],
    
    margin: (
      top: 4cm,
      bottom: if publish { 4.5cm } else { auto },
      x: 2cm,
    ),
  )

  [
    #align(center)[
      #v(4em)

      #text(20pt)[DOL #year]

      #text(14pt)[Runde #round]

      #v(3em)
    ]

    Willkommen zur #if round == 1 [ersten] else if round == 2 [zweiten] else if round == 3 [dritten] else [X.] Runde der Deutschen Linguistik-Olympiade #year!

    \

    Du hast für die Bearbeitung der Aufgaben #time Zeit. #if round != none and round <= 2 [Innerhalb dieser Zeit sind alle Lösungen in Moodle einzutragen.

    Die Aufgaben sind selbstständig und ohne fremde Hilfsmittel (inkl. Recherchen im Internet) zu lösen. Sollte festgestellt werden, dass du die Aufgaben mit fremder Hilfe gelöst hast, werden deine Ergebnisse nicht berücksichtigt und du wirst von der weiteren Teilnahme an der Olympiade ausgeschlossen.
    
    Das Teilen der Aufgaben ist strengstens verboten.] else [

    Schreibe die Aufgaben nicht ab. Jede Aufgabe soll auf einem eigenen Blatt oder Blättern gelöst werden. Notiere auf jedem Blatt die Nummer der Aufgabe und deinen Namen.

    Sofern nicht anders angegeben, solltest du alle Muster oder Regeln beschreiben, die du in den Daten identifiziert hast. Andernfalls ist die volle Punktzahl nicht erreichbar.
    ]
    
    \ \
    
    Viel Erfolg!

    #v(1fr)
    #line(length: 100%)
    #align(center)[*Redaktion:* #editors]
    #v(2em)
  ]

  body
}