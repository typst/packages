// Beispielprogramme für den NEPO-Renderer.
//
// Eine Sammlung von Calliope-mini-Programmen, die jeden Block und jede
// Verschachtelung zeigt, die Blockst derzeit rendern kann — von einer
// einzelnen Zeile bis zu vollständigen Unterrichtsprogrammen. Sie ist
// zugleich Materialsammlung und Sichtprüfung: was hier falsch aussieht, ist
// ein Fehler im Renderer.
//
//   typst compile examples/nepo/beispielprogramme.typ --root .
//
#import "@preview/blockst:0.4.0": nepo, set-blockst

#set page(
  paper: "a4",
  margin: (x: 16mm, y: 18mm),
  fill: white,
  numbering: "1",
)
#set text(font: "Helvetica Neue", size: 10pt, lang: "de", fallback: true)
#set par(justify: false)
#set-blockst(font: "Helvetica Neue")

#show heading.where(level: 1): it => block(
  above: 20pt, below: 10pt,
  text(size: 15pt, weight: "bold", it.body),
)
#show heading.where(level: 2): it => block(
  above: 16pt, below: 6pt,
  text(size: 11pt, weight: "bold", it.body),
)

// Ein Programm mit Erklärung darüber. `scale` ist da, weil manche Programme
// breiter sind als die Seite; der Text bleibt dabei gleich groß, nur die
// Blockgeometrie schrumpft.
#let programm(erklaerung, code, scale: auto) = block(
  breakable: false,
  below: 14pt,
  {
    text(size: 9pt, fill: rgb("#555"), erklaerung)
    v(4pt)
    nepo(code, scale: scale)
  },
)

#align(center)[
  #text(size: 20pt, weight: "bold")[NEPO-Beispielprogramme]
  #v(2pt)
  #text(size: 10pt, fill: rgb("#555"))[
    Open-Roberta-Blöcke für den Calliope mini, gerendert mit Blockst
  ]
]

#v(10pt)

Diese Sammlung zeigt alle Blöcke, die der NEPO-Renderer kennt, und vor allem
ihr Zusammenspiel: Variablen mit ihren Datentypen, verschachtelte Bedingungen,
zusammengesetzte Ausdrücke, Listen und mehrseitige Programme. Jedes Beispiel
ist ein Programm, das im Open Roberta Lab genauso gebaut werden kann.

= Der Programmrahmen

#programm[
  Jedes Programm beginnt mit dem Start-Block. Das Plus an seiner linken Seite
  legt Variablen an — ohne Variablen bleibt der Block einzeilig.
][```nepo
Start
  Zeige Text "Hallo Welt"
```]

#programm[
  Ein Kommentarblock steht für sich und erklärt den nächsten Schritt.
][```nepo
Start
  Kommentar "Begrüßung"
  Zeige Text "Hallo"
  Lösche Bildschirm
```]

= Variablen

#programm[
  Eine Variable wird im Start-Block angelegt: Name, Doppelpunkt, Datentyp,
  Startwert. Danach kann sie gelesen und beschrieben werden. Der Stecker der
  Variablen trägt die Farbe ihres Datentyps — hier das Blau der Zahlen.
][```nepo
Start
  Variable Punkte : Zahl ← 0
  Schreibe Punkte 10
  Zeige Text Punkte
```]

#programm[
  Alle Datentypen, die der Calliope mini kennt, mit passendem Startwert. Die
  Farbe des Anschlusses nennt jeweils den erwarteten Typ.
][```nepo
Start
  Variable Zaehler : Zahl ← 0
  Variable Name : Zeichenkette ← "Ida"
  Variable Fertig : logischer Wert ← falsch
  Variable Signal : Farbe ← (#00cc00)
  Variable Symbol : Bild ← Herz
  Variable Messwerte : Liste Zahl ← Liste : Zahl ← 3 5 8
```]

#programm[
  „erhöhe … um …“ addiert auf eine Zahlvariable, ohne sie neu zu schreiben.
  Der Variablenblock steckt dabei im Anschluss, ist also selbst ein Wert.
][```nepo
Start
  Variable Punkte : Zahl ← 0
  Wiederhole 5 mal
    erhöhe Punkte um 1
    Zeige Text Punkte
  Ende
```]

#programm[
  Ein Zähler, der auf den Tastendruck wartet und bei zehn wieder von vorn
  beginnt: Variable, Bedingung und Schleife zusammen.
][```nepo
Start
  Variable Punkte : Zahl ← 0
  Wiederhole unendlich oft
    Warte bis Taste A gedrückt?
    erhöhe Punkte um 1
    wenn Punkte = 10
      Schreibe Punkte 0
      Zeige Text "Reset"
    Ende
    Zeige Text Punkte
  Ende
```]

= Kontrollstrukturen

#programm[
  Zählschleife und Endlosschleife.
][```nepo
Start
  Wiederhole 3 mal
    Zeige Bild Herz
    Warte ms 200
    Lösche Bildschirm
    Warte ms 200
  Ende
```]

#programm[
  Kopfgesteuerte Schleifen: „solange“ läuft, während die Bedingung gilt,
  „bis“ läuft, bis sie gilt.
][```nepo
Start
  Variable Helligkeit : Zahl ← 0
  Wiederhole solange Helligkeit < 100
    erhöhe Helligkeit um 10
    Zeige Text Helligkeit
  Ende
  Wiederhole bis Taste B gedrückt?
    Spiele Achtelnote C4
  Ende
```]

#programm[
  Verzweigung mit zwei Ausgängen.
][```nepo
Start
  wenn Taste A gedrückt?
    Zeige Bild Lächeln
  sonst
    Lösche Bildschirm
  Ende
```]

#programm[
  Verschachtelte Bedingungen: eine Entscheidung innerhalb einer Entscheidung,
  innerhalb einer Endlosschleife.
][```nepo
Start
  Wiederhole unendlich oft
    wenn Taste A gedrückt?
      wenn Taste B gedrückt?
        Zeige Text "A und B"
      sonst
        Zeige Text "nur A"
      Ende
    sonst
      Lösche Bildschirm
    Ende
  Ende
```]

= Sensoren

#programm[
  Die Sensorblöcke des Calliope mini, einzeln.
][```nepo
Start
  Zeige Text gib Wert ° Temperatursensor
  Zeige Text gib Wert % Lichtsensor
  Zeige Text gib Wert % Mikrofon
  Zeige Text gib Winkel ° Kompasssensor
  Zeige Text gib Wert ms Zeitgeber 1
  Setze Zeitgeber 1 zurück
```]

#programm[
  Bedingungen aus Sensoren: Tasten, Pins und Lagesensor.
][```nepo
Start
  Wiederhole unendlich oft
    wenn Pin 0 gedrückt?
      Spiele Viertelnote C4
    Ende
    wenn gib geschüttelt Lage
      Zeige Bild Strichmännchen
    Ende
  Ende
```]

= Ausdrücke

#programm[
  Rechnen und Vergleichen. Zusammengesetzte Ausdrücke stecken ineinander:
  der Vergleich enthält eine Rechnung, die Rechnung enthält einen Sensorwert.
][```nepo
Start
  Variable Grenze : Zahl ← 25
  wenn gib Wert ° Temperatursensor > Grenze + 5
    Schalte RGB LED an Farbe (#ff0000)
  sonst
    Schalte RGB LED an Farbe (#0000ff)
  Ende
```]

#programm[
  Logische Verknüpfungen. „und“ darf Vergleiche aufnehmen, Klammern lösen
  jede verbleibende Mehrdeutigkeit.
][```nepo
Start
  Warte bis Taste A gedrückt? und gib Wert % Lichtsensor < 20
  Zeige Text "Dunkel und gedrückt"
  Warte bis (Taste A gedrückt? oder Taste B gedrückt?) und wahr
  Zeige Text "Los"
```]

#programm[
  Ein Zufallswert als Würfel.
][```nepo
Start
  Variable Augen : Zahl ← 0
  Wiederhole unendlich oft
    Warte bis gib geschüttelt Lage
    Schreibe Augen ganzzahliger Zufallswert zwischen 1 bis 6
    Zeige Text Augen
    Warte ms 1000
    Lösche Bildschirm
  Ende
```]

= Anzeige und Klang

#programm[
  Die 5×5-Matrix wird als Bild direkt im Quelltext geschrieben: `#` ist an,
  `.` ist aus, Ziffern sind Zwischenhelligkeiten.
][```nepo
Start
  Zeige Bild (.#.#./.#.#./...../#...#/.###.)
  Warte ms 500
  Zeige Bild (#...#/.#.#./..#../.#.#./#...#)
```]

#programm[
  Eine kleine Melodie aus den vier Notenlängen.
][```nepo
Start
  Spiele ganze Note C4
  Spiele halbe Note E4
  Spiele Viertelnote G4
  Spiele Achtelnote A4
```]

= Listen

#programm[
  Eine Liste wird mit ihren Elementen erzeugt; jedes weitere Element bekommt
  eine eigene, rechtsbündige Zeile.
][```nepo
Start
  Variable Messwerte : Liste Zahl ← Liste : Zahl ← 12 15 9 21
```]

#programm[
  Auf Listen zugreifen: Länge, Leerprüfung, Element holen, Element setzen und
  suchen. Der gelesene Wert trägt den Elementtyp der Liste.
][```nepo
Start
  Variable Messwerte : Liste Zahl ← Liste : Zahl ← 12 15 9
  Variable Aktuell : Zahl ← 0
  Schreibe Aktuell von der Liste Messwerte nimm #tes 2
  Zeige Text Länge von Messwerte
  von der Liste Messwerte setze #tes 1 ein 20
  wenn Messwerte ist leer?
    Zeige Text "leer"
  Ende
```]

= Vollständige Programme

#programm(scale: 85%)[
  *Reaktionsspiel.* Der Zeitgeber wird zurückgesetzt, sobald das Herz
  erscheint; gemessen wird, wie lange es bis zum Tastendruck dauert. Die
  Bestzeit steht in einer Variablen und wird nur überschrieben, wenn sie
  unterboten wird.
][```nepo
Start
  Variable Bestzeit : Zahl ← 9999
  Variable Zeit : Zahl ← 0
  Wiederhole unendlich oft
    Lösche Bildschirm
    Warte ms ganzzahliger Zufallswert zwischen 1000 bis 4000
    Zeige Bild Herz
    Setze Zeitgeber 1 zurück
    Warte bis Taste A gedrückt?
    Schreibe Zeit gib Wert ms Zeitgeber 1
    Zeige Text Zeit
    wenn Zeit < Bestzeit
      Schreibe Bestzeit Zeit
      Schalte RGB LED an Farbe (#00cc00)
    sonst
      Schalte RGB LED an Farbe (#ff0000)
    Ende
    Warte ms 2000
    Schalte RGB LED aus
  Ende
```]

#programm(scale: 85%)[
  *Temperatur-Ampel.* Eine Kette aus Bedingungen, die den Messwert in drei
  Bereiche einteilt und die RGB-LED entsprechend färbt.
][```nepo
Start
  Variable Temperatur : Zahl ← 0
  Wiederhole unendlich oft
    Schreibe Temperatur gib Wert ° Temperatursensor
    wenn Temperatur < 18
      Schalte RGB LED an Farbe (#0000ff)
      Zeige Text "kalt"
    sonst
      wenn Temperatur < 25
        Schalte RGB LED an Farbe (#00cc00)
        Zeige Text "gut"
      sonst
        Schalte RGB LED an Farbe (#ff0000)
        Zeige Text "warm"
      Ende
    Ende
    Warte ms 2000
  Ende
```]

#programm(scale: 85%)[
  *Schrittzähler.* Jede Erschütterung zählt einen Schritt; alle zehn Schritte
  gibt es eine Rückmeldung. Mit Taste B beginnt die Zählung von vorn.
][```nepo
Start
  Variable Schritte : Zahl ← 0
  Wiederhole unendlich oft
    wenn gib geschüttelt Lage
      erhöhe Schritte um 1
      wenn Schritte = 10
        Spiele Viertelnote G4
        Zeige Bild Lächeln
        Warte ms 500
        Lösche Bildschirm
      Ende
    Ende
    wenn Taste B gedrückt?
      Schreibe Schritte 0
      Zeige Text "0"
    Ende
  Ende
```]

#programm(scale: 85%)[
  *Zahlenraten.* Der Calliope denkt sich eine Zahl aus, der Spieler zählt mit
  Taste A hoch und bestätigt mit Taste B. Zwei Variablen, ein Vergleich mit
  drei Ausgängen und eine Schleife, die erst beim Treffer endet.
][```nepo
Start
  Variable Gesucht : Zahl ← 0
  Variable Tipp : Zahl ← 0
  Variable Fertig : logischer Wert ← falsch
  Schreibe Gesucht ganzzahliger Zufallswert zwischen 1 bis 20
  Wiederhole bis Fertig
    wenn Taste A gedrückt?
      erhöhe Tipp um 1
      Zeige Text Tipp
    Ende
    wenn Taste B gedrückt?
      wenn Tipp = Gesucht
        Zeige Bild Lächeln
        Schreibe Fertig wahr
      sonst
        wenn Tipp < Gesucht
          Zeige Text "zu klein"
        sonst
          Zeige Text "zu groß"
        Ende
        Schreibe Tipp 0
      Ende
    Ende
  Ende
```]

#programm(scale: 85%)[
  *Messreihe.* Drei Messwerte werden in einer Liste abgelegt und danach
  nacheinander angezeigt — Listenzugriff mit einem gezählten Index.
][```nepo
Start
  Variable Messwerte : Liste Zahl ← Liste : Zahl ← 0 0 0
  Variable Index : Zahl ← 1
  Wiederhole 3 mal
    Warte bis Taste A gedrückt?
    von der Liste Messwerte setze #tes Index ein gib Wert ° Temperatursensor
    erhöhe Index um 1
    Warte ms 500
  Ende
  Schreibe Index 1
  Wiederhole 3 mal
    Zeige Text von der Liste Messwerte nimm #tes Index
    erhöhe Index um 1
    Warte ms 1000
  Ende
```]

= Leere Anschlüsse

#programm[
  Ein leerer Anschluss nennt über seine Farbe den Datentyp, der hineingehört.
  Für Arbeitsblätter mit Lücken ist genau das der Zweck.
][```nepo
Start
  Variable Punkte : Zahl ←
  Zeige Text
  Schalte RGB LED an Farbe
  Zeige Bild
  Warte bis
  Schreibe Punkte
```]
