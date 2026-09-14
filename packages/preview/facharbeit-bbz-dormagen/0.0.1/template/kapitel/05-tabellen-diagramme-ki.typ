#import "../_system/design-system.typ": diagramm-figur, tabellen-figur
#import "../_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "../_system/utils.typ": a3-seite
#import "@preview/cetz:0.5.2"
#import "../_system/einstellungen.typ"

= Tabellen, Diagramme und Künstliche Intelligenz

Besonders für die Beschreibung Ihres Betriebs oder die Auswertung von Zahlenmaterial benötigen Sie komplexe Elemente. Typst bietet Ihnen fantastische Möglichkeiten, Diagramme *nativ* (also ohne Excel-Bildschirmfotos) direkt aus dem Text heraus zu erzeugen. 

Da der Programmcode dafür für Anfänger einschüchternd wirken kann, dürfen Sie die in diesem Kapitel gezeigten Beispiele *einfach kopieren und an Ihre Zwecke anpassen*!

== Wie Ihnen Künstliche Intelligenz (KI) dabei hilft
Sie müssen die komplexen Diagramme nicht komplett selbst programmieren. Nutzen Sie dafür moderne Sprachmodelle wie ChatGPT, Claude oder Microsoft Copilot. 

*WICHTIG:* Das blinde Kopieren von KI-generierten Textpassagen als Ihre eigene gedankliche Leistung ist ein Täuschungsversuch. Die Nutzung der KI als *Programmier-Assistent* für Tabellen und Diagramme ist hingegen völlig legitim! 

*Der wasserdichte Prompt für die KI:*
Wenn Sie z. B. das unten stehende Balkendiagramm für Ihre eigenen Umsatzahlen umbauen wollen, kopieren Sie den gesamten Code des Diagramms (aus der Datei `05-tabellen-diagramme-ki.typ`) in die KI und nutzen Sie exakt diesen Prompt:

> *"Ich schreibe eine wissenschaftliche Arbeit im Satzsystem 'Typst' (mit dem Paket 'cetz'). Hier ist der lauffähige Code für ein Balkendiagramm: [Code einfügen]. Bitte behalte die exakte Struktur, Farben und das Layout bei, aber ändere die Daten auf folgende Werte für mein Unternehmen: [Ihre neuen Werte, z. B. Filiale A 50~000 €, Filiale B 80~000 €]. Gib mir nur den reinen Typst-Code zurück, den ich direkt wieder einfügen kann."*

Die KI wird Ihnen fehlerfreien Code liefern, den Sie nur noch per Copy & Paste in Ihre Arbeit einfügen müssen!

== Komplexe Tabellen (der Excel-Workaround)
Sollte Ihnen die Programmierung in Typst dennoch zu aufwändig sein (z. B. bei einer riesigen Nutzwertanalyse mit 15 Spalten oder der Abbildung eines komplexen JIT-Lieferprozesses), nutzen Sie einen einfachen Workaround: Bauen Sie die Tabelle wunderschön in Excel @mscharts[S. 42], machen Sie mit dem Windows Snipping Tool einen scharfen Screenshot @mssnipping[S. 10] und binden Sie diesen als Bild ein (siehe Kapitel "Grafiken einbinden"). Das ist völlig legitim und oft zeitsparender! Für weitere Informationen zu verfügbaren Diagrammtypen in Office-Anwendungen siehe auch @mscharttypes[S. 115].

== Beispiel: Säulen- und Balkendiagramme
Kopieren Sie diesen Code-Block für ein klassisches Balkendiagramm, welches in der Literatur häufig für Umsatzvergleiche empfohlen wird @werner2020[S. 230]. (Die Pakete `cetz` und `cetz-plot` werden im Web-Editor automatisch im Hintergrund geladen). Um aktuelle Branchendaten grafisch aufzubereiten, können Sie z. B. auf Marktforschungsstudien zurückgreifen @branchenreport2024[S. 12ff].

So geben Sie es ein:
```typst
#diagramm-figur(
  caption-text: [Quartalsumsatz im Geschäftsjahr 2024],
  source-text: [Eigene Erhebung],
  cetz.canvas({
    import cetz.draw: *
    import "@preview/cetz-plot:0.1.4": plot
    plot.plot(
      size: (8, 4),
      axis-style: "left",
      y-tick-step: 50,
      x-tick-step: none,
      y-max: 250,
      y-grid: true,
      x-min: -0.5,
      x-max: 3.5,
      x-label: none,
      y-label: [Umsatz (Tsd. €)],
      legend: none,
      x-ticks: ((0, [Q1/24]), (1, [Q2/24]), (2, [Q3/24]), (3, [Q4/24])),
      {
        plot.add-bar(
          ((0, 120), (1, 155), (2, 180), (3, 215)),
          bar-width: 0.6,
          style: idx => (fill: einstellungen.balken-farben.at(calc.rem(idx, 6)), stroke: none),
        )
        plot.add-hline(0, style: (stroke: black))
        plot.annotate({
          content((0, 135.8), text(size: 9pt)[120])
          content((1, 170.8), text(size: 9pt)[155])
          content((2, 195.8), text(size: 9pt)[180])
          content((3, 230.8), text(size: 9pt)[215])
        })
      },
    )
    content((9.2, 3.5), box(stroke: 0.5pt + gray, inset: 0.5em, radius: 2pt)[#text(fill: einstellungen.primärfarbe.lighten(40%))[■] #text(fill: black)[Umsatz]])
  }),
)
```

Und so sieht das Ergebnis aus:
#diagramm-figur(
  caption-text: [Quartalsumsatz im Geschäftsjahr 2024],
  source-text: [Eigene Erhebung],
  cetz.canvas({
    import cetz.draw: *
    import "@preview/cetz-plot:0.1.4": plot
    plot.plot(
      size: (8, 4),
      axis-style: "left",
      y-tick-step: 50,
      x-tick-step: none,
      y-max: 250,
      y-grid: true,
      x-min: -0.5,
      x-max: 3.5,
      x-label: none,
      y-label: [Umsatz (Tsd. €)],
      legend: none,
      x-ticks: ((0, [Q1/24]), (1, [Q2/24]), (2, [Q3/24]), (3, [Q4/24])),
      {
        plot.add-bar(
          ((0, 120), (1, 155), (2, 180), (3, 215)),
          bar-width: 0.6,
          style: idx => (fill: einstellungen.balken-farben.at(calc.rem(idx, 6)), stroke: none),
        )
        plot.add-hline(0, style: (stroke: black))
        plot.annotate({
          content((0, 135.8), text(size: 9pt)[120])
          content((1, 170.8), text(size: 9pt)[155])
          content((2, 195.8), text(size: 9pt)[180])
          content((3, 230.8), text(size: 9pt)[215])
        })
      },
    )
    content((9.2, 3.5), box(stroke: 0.5pt + gray, inset: 0.5em, radius: 2pt)[#text(fill: einstellungen.primärfarbe.lighten(40%))[■] #text(fill: black)[Umsatz]])
  }),
)

== Beispiel: Trendanalyse (Liniendiagramm)
Ein professionelles Liniendiagramm eignet sich hervorragend zur Darstellung wirtschaftlicher Entwicklungen (z. B. Umsatz vs. Gewinn) im Zeitverlauf. Kopieren Sie das Folgende für Ihre eigenen Trendanalysen:

So geben Sie es ein:
```typst
#diagramm-figur(
  caption-text: [Geschäftsentwicklung Umsatz vs. Gewinn],
  source-text: [Eigene Darstellung],
  cetz.canvas({
    import cetz.draw: *
    import "@preview/cetz-plot:0.1.4": plot
    let data-umsatz = ((1, 120), (2, 150), (3, 130), (4, 180))
    let data-gewinn = ((1, 20), (2, 35), (3, 25), (4, 45))
    plot.plot(
      size: (8, 4),
      axis-style: "school-book",
      x-tick-step: 1,
      y-tick-step: 50,
      x-min: 0,
      x-max: 4.5,
      y-min: 0,
      y-max: 200,
      y-grid: true,
      x-label: none,
      y-label: [Mio. €],
      legend: none,
      {
        plot.add(
          data-umsatz,
          style: (stroke: (paint: rgb("cc5500"), thickness: 2pt)),
          mark: "o",
          label: [Umsatz],
        )
        plot.add(
          data-gewinn,
          style: (stroke: (paint: rgb("006600"), thickness: 2pt)),
          mark: "*",
          label: [Gewinn],
        )
        plot.annotate({
          content((1, 133), text(size: 8pt, fill: rgb("cc5500"))[120])
          content((2, 163), text(size: 8pt, fill: rgb("cc5500"))[150])
          content((3, 143), text(size: 8pt, fill: rgb("cc5500"))[130])
          content((4, 193), text(size: 8pt, fill: rgb("cc5500"))[180])
          content((1, 33), text(size: 8pt, fill: rgb("006600"))[20])
          content((2, 48), text(size: 8pt, fill: rgb("006600"))[35])
          content((3, 38), text(size: 8pt, fill: rgb("006600"))[25])
          content((4, 58), text(size: 8pt, fill: rgb("006600"))[45])
        })
      },
    )
    content((9.2, 0), [Quartal], anchor: "west")
    content((9.5, 2), box(stroke: 0.5pt + gray, inset: 0.5em, radius: 2pt)[
      #text(fill: rgb("cc5500"))[●] #text(fill: black)[Umsatz] \
      #v(0.2em)
      #text(fill: rgb("006600"))[★] #text(fill: black)[Gewinn]
    ])
  }),
)
```

Und so sieht das Ergebnis aus:
#diagramm-figur(
  caption-text: [Geschäftsentwicklung Umsatz vs. Gewinn],
  source-text: [Internes Controlling @controlling2024],
  cetz.canvas({
    import cetz.draw: *
    import "@preview/cetz-plot:0.1.4": plot
    let data-umsatz = ((1, 120), (2, 150), (3, 130), (4, 180))
    let data-gewinn = ((1, 20), (2, 35), (3, 25), (4, 45))
    plot.plot(
      size: (8, 4),
      axis-style: "school-book",
      x-tick-step: 1,
      y-tick-step: 50,
      x-min: 0,
      x-max: 4.5,
      y-min: 0,
      y-max: 200,
      y-grid: true,
      x-label: none,
      y-label: [Mio. €],
      legend: none,
      {
        plot.add(
          data-umsatz,
          style: (stroke: (paint: rgb("cc5500"), thickness: 2pt)),
          mark: "o",
          label: [Umsatz],
        )
        plot.add(
          data-gewinn,
          style: (stroke: (paint: rgb("006600"), thickness: 2pt)),
          mark: "*",
          label: [Gewinn],
        )
        plot.annotate({
          content((1, 133), text(size: 8pt, fill: rgb("cc5500"))[120])
          content((2, 163), text(size: 8pt, fill: rgb("cc5500"))[150])
          content((3, 143), text(size: 8pt, fill: rgb("cc5500"))[130])
          content((4, 193), text(size: 8pt, fill: rgb("cc5500"))[180])
          content((1, 33), text(size: 8pt, fill: rgb("006600"))[20])
          content((2, 48), text(size: 8pt, fill: rgb("006600"))[35])
          content((3, 38), text(size: 8pt, fill: rgb("006600"))[25])
          content((4, 58), text(size: 8pt, fill: rgb("006600"))[45])
        })
      },
    )
    content((9.2, 0), [Quartal], anchor: "west")
    content((9.5, 2), box(stroke: 0.5pt + gray, inset: 0.5em, radius: 2pt)[
      #text(fill: rgb("cc5500"))[●] #text(fill: black)[Umsatz] \
      #v(0.2em)
      #text(fill: rgb("006600"))[★] #text(fill: black)[Gewinn]
    ])
  }),
)

== Beispiel: Nutzwertanalyse (Spinnwebdiagramm)
Besonders bei Standortentscheidungen oder Nutzwertanalysen ist das Spinnwebdiagramm (Radar Chart) in der Logistik unverzichtbar @crm2024[S. 88--92] <chart_spider>. Auch dieses können Sie per KI an Ihre fünf eigenen Kriterien anpassen lassen:

So geben Sie es ein:
```typst
#diagramm-figur(
  caption-text: [Nutzwertanalyse: Lieferant A vs. Lieferant B],
  source-text: [Eigene Erhebung],
  cetz.canvas({
    import cetz.draw: *
    for i in range(5) {
      let angle = i * 72deg + 90deg
      line((0, 0), (angle, 3), stroke: 0.8pt + gray)
      let labels = ("Kosten", "Qualität", "Flexibilität", "Service", "Ökologie")
      let my-anchor = "south"
      if i == 1 { my-anchor = "south-east" }
      if i == 2 { my-anchor = "north-east" }
      if i == 3 { my-anchor = "north-west" }
      if i == 4 { my-anchor = "south-west" }
      content((angle, 3.4), text(size: 8pt, fill: einstellungen.primärfarbe)[#labels.at(i)], anchor: my-anchor)
      for r in (1, 2, 3) {
        line((angle, r), (angle + 72deg, r), stroke: 0.5pt + gray)
      }
    }
    let data-a = (2, 3, 2, 2.5, 1)
    let pts-a = ()
    for i in range(5) {
      pts-a.push((i * 72deg + 90deg, data-a.at(i)))
    }
    pts-a.push(pts-a.at(0))
    line(..pts-a, close: true, stroke: 1.5pt + rgb("cc5500"), fill: rgb(204, 85, 0, 40))
    let data-b = (1, 2, 3, 2, 2)
    let pts-b = ()
    for i in range(5) {
      pts-b.push((i * 72deg + 90deg, data-b.at(i)))
    }
    pts-b.push(pts-b.at(0))
    line(..pts-b, close: true, stroke: 1.5pt + rgb("006600"), fill: rgb(0, 102, 0, 40))
    for r in (1, 2, 3) {
      content((90deg, r), box(fill: white, inset: 1pt)[#text(size: 6pt, fill: gray)[#r]], anchor: "east")
    }
    content((3.5, 2.5), box(stroke: 0.5pt + gray, inset: 0.5em, radius: 2pt)[
      #text(fill: rgb("cc5500"))[■] #text(fill: black)[Lieferant A] \
      #v(0.2em)
      #text(fill: rgb("006600"))[■] #text(fill: black)[Lieferant B]
    ])
  }),
) <chart_spider>
```

Und so sieht das Ergebnis aus:
#diagramm-figur(
  caption-text: [Nutzwertanalyse: Lieferant A vs. Lieferant B],
  source-text: [Eigene Erhebung],
  cetz.canvas({
    import cetz.draw: *
    for i in range(5) {
      let angle = i * 72deg + 90deg
      line((0, 0), (angle, 3), stroke: 0.8pt + gray)
      let labels = ("Kosten", "Qualität", "Flexibilität", "Service", "Ökologie")
      let my-anchor = "south"
      if i == 1 { my-anchor = "south-east" }
      if i == 2 { my-anchor = "north-east" }
      if i == 3 { my-anchor = "north-west" }
      if i == 4 { my-anchor = "south-west" }
      content((angle, 3.4), text(size: 8pt, fill: einstellungen.primärfarbe)[#labels.at(i)], anchor: my-anchor)
      for r in (1, 2, 3) {
        line((angle, r), (angle + 72deg, r), stroke: 0.5pt + gray)
      }
    }
    let data-a = (2, 3, 2, 2.5, 1)
    let pts-a = ()
    for i in range(5) {
      pts-a.push((i * 72deg + 90deg, data-a.at(i)))
    }
    pts-a.push(pts-a.at(0))
    line(..pts-a, close: true, stroke: 1.5pt + rgb("cc5500"), fill: rgb(204, 85, 0, 40))
    let data-b = (1, 2, 3, 2, 2)
    let pts-b = ()
    for i in range(5) {
      pts-b.push((i * 72deg + 90deg, data-b.at(i)))
    }
    pts-b.push(pts-b.at(0))
    line(..pts-b, close: true, stroke: 1.5pt + rgb("006600"), fill: rgb(0, 102, 0, 40))
    for r in (1, 2, 3) {
      content((90deg, r), box(fill: white, inset: 1pt)[#text(size: 6pt, fill: gray)[#r]], anchor: "east")
    }
    content((3.5, 2.5), box(stroke: 0.5pt + gray, inset: 0.5em, radius: 2pt)[
      #text(fill: rgb("cc5500"))[■] #text(fill: black)[Lieferant A] \
      #v(0.2em)
      #text(fill: rgb("006600"))[■] #text(fill: black)[Lieferant B]
    ])
  }),
) <chart_spider>
