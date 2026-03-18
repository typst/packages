#let eidesstattliche(datum: none, persons: ()) = [
  
  = Selbständigkeitserklärung

  #set text(11pt)
  
  Wir erklären, dass wir die vorliegende Diplomarbeit selbstständig und ohne fremde Hilfe verfasst, andere als die angegebenen Quellen und Hilfsmittel nicht benutzt und die den benutzten Quellen wörtlich und inhaltlich entnommenen Stellen als solche kenntlich gemacht haben.

  #v(1cm)

  #let signature(person) = {
      set align(center)
      stack(
        spacing: 2mm,
        line(length: 80%, stroke: 0.5pt),
        person
      )
  }
  
  Wien, am #datum

  #v(4cm)
  #grid(
    columns: (1fr, 1fr, 1fr),
    ..persons.map(signature)
  )
  
  
]
