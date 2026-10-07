// Tagesbericht: eine Tabellenzeile pro Datum, mit Stundenspalte und Summe.
#import "@preview/azubinachweis:0.1.1": tagesbericht

#show: tagesbericht.with(
  name: "Max Mustermann",
  ausbildungsjahr: "1. Ausbildungsjahr",
  kalenderwoche: "37",
  jahr: "2026",
  abteilung: "Musterabteilung",
  zeitraum: "07.09.2026 – 11.09.2026",
  kopfspalten: 2,

  tage: (
    (
      datum: "07.09.2026",
      tag: "Montag",
      inhalt: (
        "Einführung in den ersten Musterbereich",
        "Kennenlernen der Musterwerkzeuge",
      ),
      stunden: 8,
    ),
    (
      datum: "08.09.2026",
      tag: "Dienstag",
      inhalt: "Bearbeitung der ersten Musteraufgabe im Musterteam",
      stunden: 8,
    ),
    (
      datum: "09.09.2026",
      tag: "Mittwoch",
      inhalt: "Berufsschule — erstes und zweites Musterthema",
      stunden: 8,
    ),
    (
      datum: "10.09.2026",
      tag: "Donnerstag",
      inhalt: (
        "Musterunterweisung zur Arbeitssicherheit",
        "Erstellung der Musterdokumentation",
      ),
      stunden: 8,
    ),
    (
      datum: "11.09.2026",
      tag: "Freitag",
      inhalt: "Musterbesprechung und Einarbeitung in das zweite Musterthema",
      stunden: 8,
    ),
  ),

  schulbericht: (
    "Erstes Musterthema des Berufsschulunterrichts wurde behandelt",
    "Zweites Musterthema mit praktischen Übungen am Musterbeispiel",
  ),
  stunden: (schule: 8),
)
