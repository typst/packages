// Frontespizio Tesi - Università di Pisa

#let frontespizio(
  title: "Un fantastico titolo per la mia tesi di laurea!",
  author: "Nome Cognome",
  department: "Dipartimento di Ingegneria dell'Informazione",
  degree: "Laurea Triennale in Ingegneria Informatica",
  supervisors: (
    "Prof. Nome Cognome",
    "Prof. Nome Cognome",
  ),
  academic-year: "202X/202Y",
  // Logo in cima alla pagina: `auto` per il Cherubino dell'Università di Pisa (incluso nel
  // pacchetto), un contenuto (es. `image("logo.svg")`) per un altro logo, `none` per ometterlo
  logo: auto,
  // Alias opzionali
  titolo: none,
  autore: none,
  candidato: none,
  dipartimento: none,
  tipo-laurea: none,
  corso-di-laurea: none,
  relatori: none,
  anno-accademico: none,
) = {
  let title = if titolo != none { titolo } else { title }
  let author = if candidato != none { candidato } else if autore != none { autore } else { author }
  let department = if dipartimento != none { dipartimento } else { department }
  let degree = if tipo-laurea != none { tipo-laurea } else if corso-di-laurea != none { corso-di-laurea } else { degree }
  let supervisors = if relatori != none { relatori } else { supervisors }
  let academic-year = if anno-accademico != none { anno-accademico } else { academic-year }

  let sup-list = if type(supervisors) == array { supervisors } else { (supervisors,) }
  let sup-label = if sup-list.len() > 1 { "Relatori:" } else { "Relatore:" }

  let auth-list = if type(author) == array { author } else { (author,) }
  let auth-label = if auth-list.len() > 1 { "Candidati:" } else { "Candidato:" }

  let dept-text = if type(department) == str { upper(department) } else { department }
  let year-text = if type(academic-year) == str and (academic-year.starts-with("ANNO ACCADEMICO") or academic-year.starts-with("Anno Accademico") or academic-year.starts-with("anno accademico")) {
    upper(academic-year)
  } else [ANNO ACCADEMICO #academic-year]

  align(center)[
    #if logo != none [
      // Larghezza predefinita del logo; un `width` esplicito passato a image() ha la precedenza
      #set image(width: 35%)
      #if logo == auto { image("cherubino.svg") } else { logo }

      #v(8mm)
    ]
    #text(size: 20pt, weight: "regular")[UNIVERSITÀ DI PISA] \
    #v(3mm)
    #text(size: 14.5pt, weight: "regular")[#dept-text] \
    #v(3mm)
    #text(size: 20pt, weight: "regular")[#degree]

    #v(15mm)

    #text(size: 20pt, weight: "bold")[#title]
  ]

  

  v(30mm)
  let s = 5mm
  grid(
    columns: (1fr, 1fr),
    align: (left, right),
    stack(
      spacing: s,
      text(size: 13pt)[#sup-label],
      ..sup-list.map(sup => text(size: 13pt, weight: "bold")[#sup]),
    ),
    stack(
      spacing: s,
      text(size: 13pt)[#auth-label],
      ..auth-list.map(auth => text(size: 13pt, weight: "bold")[#auth]),
    ),
  )

  align(bottom, stack(
    spacing: 5.75pt,
    line(length: 100%, stroke: 0.4pt),
    align(center, text(size: 14.5pt)[#year-text]),
  ))
}
