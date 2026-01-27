#import "@preview/ipsy-thesis:0.1.0": appendix, begin-appendix, annotation-table

#begin-appendix

#appendix("Erster Anhang", lbl: <app>)[
  #figure(caption: lorem(10), image("../diagram.svg", width: 63%))<app:image>
  #figure(
    caption: lorem(10), 
    annotation-table(
      annotation-term: "Annotations",
      annotation: [Allgemeine Anmerkungen, die sich auf die gesamte Tabelle beziehen, werden zu Beginn genannt. Adaptiert nach @leitfaden[S. 32].],
      columns: 5 * (1fr,), stroke: none, inset: 0.65em, align: (x, ..) => {
        if x == 0 { left + bottom }
        else { center }
      },
      /* --- Tabelleninhalt --- */
      table.header(
        table.hline(),
        table.cell(rowspan: 2)[Schwierigkeit], table.cell(colspan: 2)[Mittlere Reaktionszeit in ms], table.cell(colspan: 2)[Fehlerrate in %], 
        table.hline(),
        [Medikament], [Placebo], [Medikament], [Placebo],
        table.hline(),
      ),
      table.cell(colspan: 5, align(center)[Männliche Probanden ($N = 100$)]),
      [leicht], [400], [300], [4], [6],
      [mittel], [450], [350], [5], [7],
      [schwer], [500], [400], [6], [8],
      table.hline(),
      table.cell(colspan: 5, align(center)[Weibliche Probanden ($N = 100$)]),
      [leicht], [350], [300], [5], [5],
      [mittel], [400], [350], [6], [6],
      [schwer], [450], [400], [7], [7],
      table.hline()
    )
  )<app:tbl>
]

#appendix("Zweiter Anhang")[
  #figure(caption: lorem(10), scale(x: -100%, image("../diagram.svg", width: 80%)))<app:image2>\
  #figure(caption: "A funny circle that is very circle-like.", circle(radius: 2.25cm), gap: 1.5em)<app:image3>
]
