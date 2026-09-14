#import "../design-system.typ"
#import "../makros.typ": *
// #import "@preview/gantty:0.5.1": gantt

// Konvertiert Wochen-Index (int) in datetime-Objekt.
// BASISDATUM: 01. Mai 2026.
// Grund: Das Systemdatum ist Juli 2026. Damit die "Today"-Linie 
// mittig im Projekt (Woche 1-14) erscheint, muss das Projekt 
// im Mai/Juni 2026 starten.
#let zu-datum(wert) = {
  if type(wert) == int {
    let basis = datetime(year: 2026, month: 5, day: 1)
    return basis + duration(days: (wert - 1) * 7)
  }
  return wert
}

#let diagramm-gantt(
  tasks: (),
  meilensteine: (),
  zeit-einheit: "Woche",      // Abwärtskompatibilität
  heutiger-tag: none,
  caption-text: "",
  source-text: "",
  caption-position: auto,
  breite: auto,
  hoehe: auto,
) = {
  let max-ende = if tasks.len() > 0 {
    calc.max(..tasks.map(t => t.ende))
  } else { 1 }
  
  let max-ms = if meilensteine.len() > 0 {
    calc.max(..meilensteine.map(m => m.zeit))
  } else { 1 }
  
  let gesamt-max = calc.max(max-ende, max-ms)

  let gantt-tasks = tasks.map(task => (
    name: task.name,
    start: zu-datum(task.start),
    end: zu-datum(task.ende),
    ..if "id" in task.keys() { (id: task.id) } else { (:) },
    ..if "fortschritt" in task.keys() and task.fortschritt >= 100 {
      (done: zu-datum(task.ende))
    } else { (:) },
    ..if "dependencies" in task.keys() and task.dependencies.len() > 0 {
      (dependencies: task.dependencies.map(dep => (id: dep)))
    } else { (:) },
  ))

  let gantt-milestones = meilensteine.map(ms => (
    name: ms.name,
    date: zu-datum(ms.zeit),
    show-date: true,
  ))

  // Dictionary für gantty
  let gantt-dict = (
    show-today: true, // Zeigt die echte Systemdatum-Linie (21. Juli 2026)
    headers: ("month", "week"),
    start: zu-datum(1), // Start: 01. Mai 2026
    end: zu-datum(gesamt-max), // Ende: ca. August 2026
    tasks: gantt-tasks,
    milestones: gantt-milestones,
  )

  let braucht-a3 = auto-a3 and (tasks.len() > 5 or meilensteine.len() > 2)

  let inhalt = {
    diagramm-figur(
      caption-text: caption-text,
      source-text: source-text,
      caption-pos: caption-position,
      breite: if breite == auto { 16cm } else { breite },
      {
        set text(lang: "de")
        set text(size: diagramm-schrift, font: "Noto Sans")
        gantt(gantt-dict)
      }
    )
  }

  if braucht-a3 {
    a3-seite(inhalt)
  } else {
    inhalt
  }
}