#import "@preview/hannes-thesis:0.1.0": thesis

// === Colors ===
#let color-THAred = rgb(255, 3, 80)

#show link: set text(fill: color-THAred)
#show ref: set text(fill: color-THAred)

#show: thesis.with(
  title: "My Typst Thesis",
  subtitle: "A personal template from Hannes",
  lang: "de",
  authors: (
    (
      name: "Johannes Knoll",
      email: "johannes.knoll@tha.de",
      studiengang: "Informatik Bachelor",
      matrikelnr: "Mat.-Nr. 1234567",
    ),
  ),

  // logo: image("assets/THA_Logo_S_Red_RGB.svg", width: 80%),
  // footer-logo: image("assets/THA_Wordmark_S_Red_RGB.svg", width: 25%),
  // Please install Latin Modern Sans and Roman
  // font-heading: "Latin Modern Sans",
  // font-normal: "Latin Modern Roman",


  outlines: (
    outline(title: [Abkürzungsverzeichnis], target: figure.where(kind: image)),
    outline(title: [Abbildungsverzeichnis], target: figure.where(kind: image)),
    outline(title: [Tabellenverzeichnis], target: figure.where(kind: table)),
    outline(title: [Quellcode], target: figure.where(kind: raw)),
  ),

  bibliography: bibliography("refs.bib"),
  toc: outline(title: [Custom Outline Title]),
)



= Einleitung

1. Hinführung zum Thema und Relevanz
2. Stand der Forschung und Forschungslücke
3. Forschungsfrage und Zielsetzung der Arbeit
4. Aufbau und Gang der Untersuchung

= Theoretische Grundlagen

1. Definition zentraler Begriffe
2. Darstellung relevanter Theorien und Modelle
3. Herleitung von Hypothesen (vor allem bei quantitativen Arbeiten)

= Methodik

1. Begründung des Forschungsdesigns (z.B. Literaturarbeit, qualitative/quantitative Studie)
2. Beschreibung der Datenerhebung (z.B. Literaturauswahl, Stichprobenziehung, Interviewleitfaden)
3. Beschreibung der Datenauswertungsmethode (z.B. qualitative Inhaltsanalyse, statistische Verfahren)

= Ergebnisse

1. Darstellung der Ergebnisse (gegliedert nach Forschungsfragen oder Hypothesen)
2. Deskriptive Auswertung (neutrale Präsentation der Daten in Text, Tabellen, Abbildungen)
3. Analytische Auswertung (Ergebnisse der angewandten Analysemethoden)

= Diskussion

1. Interpretation und Einordnung der Ergebnisse
2. Abgleich mit dem Forschungsstand und den Theorien (aus Kapitel 1 und 2)
3. Kritische Reflexion und Limitationen der eigenen Arbeit

= Fazit und Ausblick

1. Prägnante Zusammenfassung der wichtigsten Erkenntnisse
2. Finale Beantwortung der Forschungsfrage
3. Ausblick auf weiterführenden Forschungsbedarf und praktische Implikationen

#pagebreak()

= Template Tutorial

Dies ist ein #strong([typst])-Template.

#link("https://typst.app")[typst]
#link("https://typst.app/docs")[Dokumentation]

Die Dokumentation für Typst ist hier @typst-doku zu finden.

== Quellen

Das Zitieren von Quellen ist ein zentraler Bestandteil.

1. Legen Sie eine references.bib-Datei an: Speichern Sie Ihre Quellen im *BibTeX-Format* in dieser Datei. Ein Eintrag könnte so aussehen:

```bib
@book{typst-doku,
  author  = {Typst contributors},
  title   = {Typst Documentation},
  year    = {2024},
  url     = {[https://typst.app/docs/](https://typst.app/docs/)},
}
```

2. Zitieren Sie im Text: Verwenden Sie das *\@-Zeichen* gefolgt von dem BibTeX-Schlüssel.
3. Literaturverzeichnis: Das Template fügt das Literaturverzeichnis automatisch am Ende Ihrer Arbeit ein. Sie müssen nichts weiter tun!

== Terms

/ Ligature: A merged glyph.
/ Kerning: A spacing adjustment between two adjacent letters.
/ GOG: Google

== Tabellen

Tabellen, wie in @tab:planets, werden mit der table()-Funktion erstellt. Die figure sorgt auch hier
für die Beschriftung.

#figure(
  caption: [Planeten im Sonnensystem und deren Entfernung zur Sonne],
  placement: top,
  table(
    columns: (6em, auto),
    align: (left, right),
    inset: (x: 8pt, y: 4pt),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },

    table.header()[Planet][Entfernung (Millionen km)],
    [Mercury], [57.9],
    [Venus], [108.2],
    [Earth], [149.6],
    [Mars], [227.9],
    [Jupiter], [778.6],
    [Saturn], [1,433.5],
    [Uranus], [2,872.5],
    [Neptune], [4,495.1],
  ),
) <tab:planets>

#figure(
  table(
    columns: (1fr, auto),
    inset: 10pt,
    align: horizon,
    table.header([*Volumen*], [*Parameter*]),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: Höhe \
      $D$: Äußerer Durchmesser \
      $d$: Innerer Durchmesser
    ],

    $ sqrt(2) / 12 a^3 $, [$a$: Kantenlänge],
  ),
  caption: "Volumenformeln für geometrische Körper.",
)

== Code-Blöcke

Stellen Sie Code übersichtlich dar, indem Sie ihn in drei Backticks \`\`\`
einschließen. Geben Sie die Sprache an, um Syntax-Highlighting zu aktivieren.

#figure(
  ```python
  def main():
    print("Some code!")
  ```,
  caption: "Python Beispielcode",
)

== Text

*Fett*

_Kursiv_

#underline[Unterstrichen]

#highlight[Wichtig]

"Anführungszeichen"

#strike[Durchgestrichen]

#figure(
  ```typst
  // Aufzählung
  - Erster Punkt
  - Zweiter Punkt

  // Nummerierte Liste
  + Erster Punkt
  + Zweiter Punkt
  ```,
  caption: "Überschriften in typst",
)

== Formeln

// Inline-Formel
Die berühmte Formel von Einstein lautet $E = m c^2$.

// Abgesetzte Formel
$
  sum_(i=1)^n i = (n(n+1)) / 2
$


== Variablen und Schleifen

#for i in range(3) {
  [=== Dies ist Absatz Nummer #(i + 1).]
}

== Funktionen

#let my_box(content) = {
  rect(content, fill: red, inset: 8pt, radius: 4pt)
}

#my_box[
  Dieser Inhalt wird in einer
  stilisierten Box dargestellt.
]

