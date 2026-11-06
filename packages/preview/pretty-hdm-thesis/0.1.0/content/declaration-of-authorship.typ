#let declaration-of-authorship(authors, title, location, date) = [
  = Ehrenwörtliche Erklärung

  #if authors.len() == 1 { "Hiermit versichere ich" } else { "Hiermit versichern wir" },
  #authors.join(", "), ehrenwörtlich, dass ich die vorliegende Bachelorarbeit mit dem Titel:

  #align(center, text("„" + title + "“", size: 1.1em, weight: "semibold"))

  selbstständig und ohne fremde Hilfe verfasst und keine anderen als die angegebenen Hilfsmittel benutzt habe. Die Stellen der Arbeit, die dem Wortlaut oder dem Sinn nach anderen Werken entnommen wurden, sind in jedem Fall unter Angabe der Quelle kenntlich gemacht. Ebenso sind alle Stellen, die mit Hilfe eines KI-basierten Schreibwerkzeugs erstellt oder überarbeitet wurden, kenntlich gemacht. Die Arbeit ist noch nicht veröffentlicht oder in anderer Form als Prüfungsleistung vorgelegt worden.

  Ich habe die Bedeutung der ehrenwörtlichen Versicherung und die prüfungsrechtlichen Folgen (§ 24 Abs. 2 Bachelor-SPO) einer unrichtigen oder unvollständigen ehrenwörtlichen Versicherung zur Kenntnis genommen.

  #v(0.5cm)
  #grid(
    columns: 2,
    gutter: 2cm,
    ..authors.map(author => {
      grid.cell()[
        #set par(spacing: 0.5em)
        #location, den #date.display("[day].[month].[year]")
        #v(2cm)
        #line(length: 6cm)
        #author
      ]
    })
    )

]
