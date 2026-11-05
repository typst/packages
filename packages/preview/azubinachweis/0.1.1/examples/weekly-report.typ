// Wochenbericht mit allen optionalen Kopfzeilen, Stundenangaben,
// dem zusätzlichen Abschnitt „Unterweisungen" und vier Unterschriftenfeldern.
// Der zweispaltige Kopf (kopfspalten: 2) und die knapperen Schreibflächen
// halten das alles auf einer Seite.
#import "@preview/azubinachweis:0.1.1": nachweis

#show: nachweis.with(
  name: "Max Mustermann",
  ausbildungsjahr: "1. Ausbildungsjahr",
  kalenderwoche: "37",
  jahr: "2026",
  heft-nr: "1",
  beruf: "Musterberuf",
  betrieb: "Musterbetrieb GmbH",
  ausbilder: "Erika Musterfrau",
  abteilung: "Musterabteilung",
  zeitraum: "07.09. – 11.09.2026",

  kopfspalten: 2,
  luft: 1cm,
  mindesthoehe: 1.5cm,
  unterschrifthoehe: 1.5cm,
  bezeichnungen: (ausbilder: "Ausbilder"),

  stunden: (betrieb: 28, unterweisung: 4, schule: 8),

  unterweisungen: (
    "Musterunterweisung zur Arbeitssicherheit im Musterbereich",
    "Betrieblicher Musterunterricht zum ersten Musterthema",
  ),

  schulbericht: (
    "Erstes Musterthema des Berufsschulunterrichts wurde behandelt",
    "Zweites Musterthema mit praktischen Übungen am Musterbeispiel",
    "Drittes Musterthema als Wiederholung der Vorwoche",
  ),

  unterschriften: (
    "Auszubildender",
    "Ausbilder",
    "Gesetzlicher Vertreter",
    "Berufsschule",
  ),
)

- Einführung in den ersten Musterbereich des Ausbildungsbetriebs
- Kennenlernen der Musterwerkzeuge und der betrieblichen Musteranwendungen
- Bearbeitung einer ersten Musteraufgabe zur Einschätzung der Vorkenntnisse
- Erstellung einer Musterdokumentation zu den Ergebnissen der Musteraufgabe
- Teilnahme an einer Musterbesprechung des Musterteams
