#import "elemente/deckblatt.typ": render-deckblatt
#import "elemente/declaration.typ": eig-ung
#import "helpers/validators.typ": _validate-algemein-inputs

#let ausarbeitung(
  abstand-oben: 25mm, // zwischen 20mm und 25mm
  abstand-unten: 25mm, // zwischen 20mm und 25mm
  abstand-links: 25mm, // zwischen 20mm und 30mm
  abstand-rechts: 25mm, // zwischen 20mm und 30mm
  schriftart: "Times New Roman", // "Arial" | "Times New Roman" | "Verdana"
  leitfrage: "Eine sehr interessante Leitfrage über Heidelbeeren und deren Funktion in der Gesellschaft!", // deine Leitfrage
  name: "Max Mustermann", // dein Name
  referenzfach: "[Referenzfach]", // dein Referenzfach
  bezugsfach: "[Bezugsfach]", // dein Bezugsfach
  pruefer: ((name: "Frau Muster"), (name: "Herr Mann")), // deine Prüfenden
  vorgelegt-am: datetime.today(), // Tag der Abgabe
  abgabetermin-am: datetime.today(), // Datum der Frist 
  body, // Hauptteil
  bibliography-style: "handout-5pk-lmo.csl", // "handout-5pk-lmo" or any other style available in typst
  gruppenarbeit: false, // true = Gruppenarbeit
  stadt: "Berlin", // Stadt in der die Arbeit geschrieben wird (voraussichtlich Berlin)
  schule: "OSZ-Lise-Meitner" // deine Schule
  ) = {

  // Allgemein
  _validate-algemein-inputs(abstand-oben, abstand-unten, abstand-links, abstand-rechts, schriftart)
  //Randabstände
  set page(
    paper: "a4",
    margin: (top: abstand-oben, bottom: abstand-unten, left: abstand-links, right: abstand-rechts),
  )

  //Schriftgröße, Zeilenabstand und Schriftart
  let groesse = if schriftart == "Times New Roman" {12pt} else {11pt}
  set text(size: groesse, lang: "de", font: schriftart)
  set par(justify: true, leading: 0.65em)

  // Einrückung Listelementen
  set list(indent: 1em)

  // Farbe der Links
  show link: set text(fill: blue)

  // Überschriftenstyle
  set heading(numbering: "1.1")
  show heading.where(level: 1): set text(size: 20pt, weight: "bold")
  show heading.where(level: 2): set text(size: 16pt, weight: "bold")
  // Ebene 3: Überschrift — fetter inline-Text gefolgt von Geviertstrich
  show heading.where(level: 3): it => {
    text(weight: "bold", it.body)
    h(1em)
  }
  // Notes für Quellen
  show cite: (it) => footnote(it)

  //Deckblatt
  render-deckblatt(
    leitfrage: leitfrage,
    name: name,
    referenzfach: referenzfach,
    bezugsfach: bezugsfach,
    pruefer: pruefer, 
    vorgelegt-am: vorgelegt-am,
    abgabetermin-am: abgabetermin-am,
    stadt: stadt,
    schule: schule
  )

  //Inhaltsverzeichnis
  outline()
  pagebreak()


  //Hauptteil
  set page(numbering: "1")
  counter(page).update(1)
  body

  //Literaturverzeichnis
  pagebreak()
  heading(level: 1, numbering: none)[Literatur- und Medienverzeichnis]
  linebreak()
  bibliography("template/references.bib", style: bibliography-style, title: none)


  //Eigenständigkeitserklärung
  eig-ung(
    gruppenarbeit: gruppenarbeit,
    stadt: stadt,
    name: name
    )

}