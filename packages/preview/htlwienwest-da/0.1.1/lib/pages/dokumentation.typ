#import "@preview/tablex:0.0.8": tablex, colspanx, rowspanx, cellx
#import table: cell

#let dokumentation(persons: ()) = [
  
  = Dokumentation der Diplomarbeit

  #set text(11pt)
  #set par(leading: 7pt)


  #let std_space = 7mm
  #let left_col = 6cm
  #table(
    columns: (left_col, 1fr),
    [Verfasser], v(std_space),
    [Jahrgang], v(std_space),
    [Thema], v(std_space),
    [Kooperationspartner], v(std_space),
  )
  
  #let nested_table(right) = {
    cell(
      inset: 0pt,
      table(
        columns: (3cm, 1fr),
        [Datum: #v(std_space+5mm)], right
      ),
    )
  }

  #table(
    columns: (left_col, 1fr),
    [Aufgabenstellung], v(std_space),
    [Realisierung], v(std_space),
    [Ergebnisse], v(std_space+5cm),
    [Teilname an Wettbewerben], v(std_space),
    [Möglichkeiten der Einsichtnahme\ der Arbeit], v(std_space+6mm),
    [Abgabevermerk], nested_table[Übernommen von:],
    [Approbation], nested_table[Prüfer:],
    [], nested_table[Abteiluntsvorstand:]
  )
]



