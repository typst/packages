#set page(  margin: (top: 0cm, bottom: 0cm, left: 0cm, right: 0cm ))


#align(center)[
  #v(1cm)  // Vertikal zentrieren (oben)

  // ---------- Logo ----------
  #image("/dat/HOSTLogo.png", width: 8cm)
  #v(0.5cm)

  // ---------- Hauptblock (zentriert, schmale Spalte) ----------
  #block(width: 75%)[
    #align(center)[
      #text(size: 16pt, weight: "bold")[Abschlussarbeit]
      #v(0.5cm)
      #text(size: 12pt, weight: "bold")[Studiengang Elektrotechnik Bachelor]
      #v(0.5cm)

      // Linie
      //#hline()
      #v(0.2cm)

      // ---------- Titel ----------
      #line(length: 100%)
      #text(size: 24pt, weight: "bold")[
        Titel der Abschlussarbeit, der viel zu lang ist, sowie sich das für eine Ordentliche Abschlussarbeit, die was aufsich hält, gehört
      ]
      #line(length: 100%)
      #v(0.2cm)

      // Linie
      //#hline()
      #v(0.5cm)

      #text(size: 11pt)[von]
      #text(size: 12pt, weight: "bold")[Vorname Nachname]
    ]
  ]
]
  #v(2cm)

  #block(width: 100%)[
  #set align(center)
  

  #table(
    columns: (auto, auto),
    stroke: none,
    align: (left),
      [Erstprüfer:], [Prof. Dr. Beispielname],
      [Zweitprüfer:], [Prof. Dr. Zweitname],
      [durchgeführt in der:], [Fakultät Elektrotechnik und Informatik],
      [durchgeführt für:], [Beispiel GmbH],
      [Verfasser:], [Vorname Nachname],
      [], [Straße 1],
      [], [12345 Stadt],

      [Arbeit vorgelegt am:], [#datetime.today().display("[year]-[month]-[day]")],
    
  )

  #v(1fr)  // Vertikal zentrieren (unten)
]

// ---------- Danach normale Seitenränder wiederherstellen ----------



