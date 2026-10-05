// Die zuletzt hinzugekommenen NEPO-Blöcke, einzeln und in allen Varianten —
// zum Abgleich mit dem Open Roberta Lab (Calliope mini, Expertenmodus).
//
//   typst compile examples/nepo/neue-bloecke.typ --root .
// Relativ importiert: diese Blöcke sind neuer als das letzte Release.
#import "@preview/blockst:0.4.1": nepo, set-blockst

#set page(paper: "a4", margin: (x: 16mm, y: 16mm), fill: white, numbering: "1")
#set text(font: "Helvetica Neue", size: 10pt, lang: "de", fallback: true)
#set-blockst(font: "Helvetica Neue")

#show heading.where(level: 1): it => block(above: 18pt, below: 8pt, text(size: 14pt, weight: "bold", it.body))

// Der Quelltext über dem Ergebnis, damit jeder Block in Originalgröße
// erscheint und sich mit dem Lab vergleichen lässt.
#let fall(code) = block(breakable: false, below: 12pt, {
  text(size: 8pt, fill: rgb("#555"), raw(code.text, lang: none))
  v(3pt)
  nepo(code)
})

#align(center, text(size: 18pt, weight: "bold")[Neue NEPO-Blöcke zum Gegenchecken])
#v(4pt)
Über jedem Block steht sein Quelltext. Im Lab findet man die
Blöcke unter _Logik_, _Kontrolle → Schleifen_, _Sensoren_ und
_Kommunikation_. Die Grove-Sensoren erscheinen dort erst, wenn sie in der
Roboterkonfiguration hinzugefügt wurden.

= Logik: nicht

#fall(```nepo
nicht wahr
```)
#fall(```nepo
nicht
```)
#fall(```nepo
nicht Taste A gedrückt? und wahr
```)
#fall(```nepo
nicht (Taste A gedrückt? und wahr)
```)

= Kontrolle: Zählschleife

#fall(```nepo
Zähle i von 0 solange Zähler < 5 mit Schrittweite 1
  Zeige Text i
```)
#fall(```nepo
Zähle Runde von 1 bis 10 mit Schrittweite 2
  Warte ms 500
```)
#fall(```nepo
Zähle i von 0 bis 10
  Lösche Bildschirm
```)

= Sensoren: Beschleunigung

#fall(```nepo
gib Wert milli-g Beschleunigungssensor x
```)
#fall(```nepo
gib Wert milli-g Beschleunigungssensor y
```)
#fall(```nepo
gib Wert milli-g Beschleunigungssensor z
```)
#fall(```nepo
gib Wert milli-g Beschleunigungssensor Stärke
```)

= Sensoren: Grove

#fall(```nepo
gib Abstand cm Ultraschallsensor U
```)
#fall(```nepo
gib Luftfeuchtigkeit % Luftfeuchtigkeitsensor L
```)
#fall(```nepo
gib Temperatur ° Luftfeuchtigkeitsensor L
```)
#fall(```nepo
gib Wert % Feuchtigkeitsensor F
```)
#fall(```nepo
gib Farbe Farbsensor TCS3472 F
```)
#fall(```nepo
gib Licht % Farbsensor TCS3472 F
```)
#fall(```nepo
gib RGB Farbsensor TCS3472 F
```)
#fall(```nepo
gib Abstand cm Ultraschallsensor Vorne
```)

= Kommunikation: Funk

#fall(```nepo
Sende Nachricht Zahl 1 mit Stärke 7
```)
#fall(```nepo
Sende Nachricht "Hallo"
```)
#fall(```nepo
Sende Nachricht logischer Wert
```)
#fall(```nepo
Empfange Nachricht Zahl
```)
#fall(```nepo
Empfange Nachricht Zeichenkette
```)
#fall(```nepo
setze Kanal auf 0
```)
