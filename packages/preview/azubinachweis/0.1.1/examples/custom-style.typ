// Gleiche Struktur, eigenes Aussehen: Serifenschrift, blaue Rahmen,
// farbige Kopfzellen, größere Schreibflächen, eigene Beschriftungen.
#import "@preview/azubinachweis:0.1.1": nachweis

#show: nachweis.with(
  name: "Max Mustermann",
  ausbildungsjahr: "2. Ausbildungsjahr",
  kalenderwoche: "38",
  jahr: "2026",
  betrieb: "Musterbetrieb GmbH",

  // Aussehen
  schrift: ("Libertinus Serif", "Georgia"),
  schriftgroesse: 11pt,
  titelgroesse: 16pt,
  linie: rgb("#2f4f7f"),
  kopfgrau: rgb("#dde6f2"),
  kopftext: rgb("#16233a"),
  fliess: rgb("#16233a"),
  rahmen: 0.7pt,
  luft: 1.15cm,
  mindesthoehe: 2.6cm,

  // Beschriftungen überschreiben
  bezeichnungen: (
    taetigkeiten: "Betriebliche Tätigkeiten",
    schule: "Themen des Berufsschulunterrichts",
    bemerkungen: "Sichtvermerk des Ausbilders",
  ),

  schulbericht: (
    "Erstes Musterthema des Berufsschulunterrichts wurde behandelt",
    "Zweites Musterthema mit praktischen Übungen am Musterbeispiel",
    "Drittes Musterthema als Wiederholung der Vorwoche",
  ),
)

- Einführung in den ersten Musterbereich des Ausbildungsbetriebs
- Kennenlernen der Musterwerkzeuge und der betrieblichen Musteranwendungen
- Bearbeitung einer Musteraufgabe zur Vertiefung des ersten Musterthemas
- Erstellung einer Musterdokumentation zu den Ergebnissen
- Teilnahme an einer Musterbesprechung des Musterteams
