// Minimaler Wochenbericht — das Grundlayout ohne jede Zusatzangabe.
// Nur Name, Ausbildungsjahr, Woche und Jahr; alles andere bleibt weg:
// keine Stunden, keine Unterweisungen, zwei Unterschriftenfelder.
//
// Beide Hälften des Berichts sind hier gleich geschrieben, als Markup mit
// Bindestrichen. Als Arrays von Strings sähe es genauso aus.
#import "@preview/azubinachweis:0.1.1": nachweis

#nachweis(
  name: "Max Mustermann",
  ausbildungsjahr: "1. Ausbildungsjahr",
  kalenderwoche: "36",
  jahr: "2026",

  taetigkeiten: [
    - Einführung in den ersten Musterbereich des Ausbildungsbetriebs
    - Kennenlernen der Musterkollegen und der betrieblichen Musterabläufe
    - Einführung in die Musterwerkzeuge und die betrieblichen Musteranwendungen
    - Bearbeitung einer ersten Musteraufgabe zur Einschätzung der Vorkenntnisse
    - Erstellung einer Musterdokumentation zu den Ergebnissen der Musteraufgabe
    - Einarbeitung in das zweite Musterthema anhand der Musterunterlagen
    - Selbststudium des Musterhandbuchs zum zweiten Musterthema
  ],

  schulbericht: [
    - Erstes Musterthema des Berufsschulunterrichts wurde behandelt
    - Zweites Musterthema mit praktischen Übungen am Musterbeispiel
    - Drittes Musterthema als Wiederholung der Vorwoche
    - Ein Mustertest im Lernmanagementsystem wurde bearbeitet
  ],
)
