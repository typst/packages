// Zweite Schreibweise: Abschnitte als Inhaltsblöcke hinter dem Aufruf.
// Statt Strings in Arrays schreibt man gewöhnliches Typst-Markup — mit
// Auszeichnungen, Nummerierung, Links, Fußnoten, allem.
//
//   #nachweis(..)[Tätigkeitsbericht][Schulbericht][Bemerkungen]
//
// Ein leerer Block [] überspringt einen Abschnitt; gemischt mit benannten
// Argumenten funktioniert es ebenso.
#import "@preview/azubinachweis:0.1.1": nachweis

#nachweis(
  name: "Max Mustermann",
  ausbildungsjahr: "1. Ausbildungsjahr",
  kalenderwoche: "38",
  jahr: "2026",
)[
  + Einführung in den ersten Musterbereich des Ausbildungsbetriebs
  + Bearbeitung einer Musteraufgabe zum Thema *Musterverfahren*
  + Erstellung einer Musterdokumentation mit den Feldern
    #box[`muster_id`], #box[`muster_wert`] und #box[`muster_status`]
  + Einarbeitung in das zweite Musterthema anhand der Musterunterlagen
  + Teilnahme an einer Musterbesprechung des Musterteams
][
  - Erstes Musterthema des Berufsschulunterrichts wurde behandelt
  - Zweites Musterthema mit praktischen Übungen am Musterbeispiel
  - Drittes Musterthema als Wiederholung der Vorwoche
]
