// kapitel/04_ergebnisse.typ
#import "@preview/easy-wi-hwr:0.1.2": abk, quelle
// Für lokale Entwicklung:
// #import "../../lib.typ": abk, quelle

= Ergebnisse

#lorem(120)

== Auswertung

#lorem(80)

#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    table.header([*System*], [*Einführungsdauer*], [*Kosten*]),
    [SAP S/4HANA], [18 Monate], [120.000 €],
    [Microsoft Dynamics], [12 Monate], [85.000 €],
    [Odoo], [6 Monate],  [30.000 €],
  ),
  caption: [Vergleich ausgewählter ERP-Systeme. #quelle(<mustermann2024>)],
)

#lorem(60)
