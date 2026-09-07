// anhang/c_abbildung.typ
//
// Beispiel: Bild als Anhang-Inhalt.
// Ersetze den Platzhalter durch dein eigenes Bild:
//
//   #figure(
//     image("../images/mein-bild.png", width: 90%),
//     caption: [Beschreibung des Bildes.],
//   )
//
// Unterstützte Formate: PNG, JPEG, SVG, GIF
// Empfehlung: Bilder in images/ ablegen

#figure(
  rect(width: 90%, height: 5cm, stroke: 0.5pt + gray)[
    #align(center + horizon)[
      #text(fill: gray)[Hier dein Bild einfügen — siehe Kommentar oben.]
    ]
  ],
  caption: [Beispiel: Screenshot des ERP-Dashboards nach erfolgreicher Implementierung.],
)
