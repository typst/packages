#import "@preview/azubinachweis:0.1.1": nachweis

#show: nachweis.with(
  name: "Max Mustermann",
  ausbildungsjahr: "1. Ausbildungsjahr",
  kalenderwoche: "37",
  jahr: "2026",
  // Optionale Kopfzeilen — leere Felder erscheinen nicht:
  // beruf: "Musterberuf",
  // betrieb: "Musterbetrieb GmbH",
  // ausbilder: "Erika Musterfrau",
  // abteilung: "Musterabteilung",
  // zeitraum: "07.09.2026 – 11.09.2026",
  // heft-nr: "1",

  // Optionale Stundenangaben je Abschnitt:
  // stunden: (betrieb: 32, schule: 8),

  schulbericht: (
    "Erstes Musterthema des Berufsschulunterrichts wurde behandelt",
    "Zweites Musterthema mit praktischen Übungen am Musterbeispiel",
    "Drittes Musterthema als Wiederholung der Vorwoche",
    "Ein Mustertest im Lernmanagementsystem wurde bearbeitet",
  ),
)

// Der Text dieses Dokuments bildet den Tätigkeitsbericht.
- Einführung in den ersten Musterbereich des Ausbildungsbetriebs
- Kennenlernen der Musterwerkzeuge und der betrieblichen Musteranwendungen
- Bearbeitung einer ersten Musteraufgabe zur Einschätzung der Vorkenntnisse
- Erstellung einer Musterdokumentation zu den Ergebnissen der Musteraufgabe
- Teilnahme an einer Musterbesprechung des Musterteams
- Einarbeitung in das Musterthema anhand der betrieblichen Musterunterlagen
- Selbststudium des Musterhandbuchs zum zweiten Musterthema
