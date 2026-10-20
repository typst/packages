// Für Kolleg-Variante: "hak" durch "kolleg" ersetzen
#import "@preview/bhs-school-bundle:0.3.1": *


// Für Kolleg-Variante: "hak" durch "kolleg" ersetzen
#show: hak.with(
  title: [Der Titel der Arbeit],
  subtitle: [Untertitel der Arbeit],
  projecttype: [Diplomarbeit],
  team: (
    (name: [Max Mustermann], responsibility: [Verantwortlich fur IT: HTML, CSS, BWL: Kaufvertrag]),
    (name: [Susanne Sorglos], responsibility: [Verantwortlich fur IT: HTML, CSS, BWL: Kaufvertrag]),
    (name: [Otto Normalverbraucher], responsibility: [Verantwortlich fur IT: HTML, CSS, BWL: Kaufvertrag]),
  ),
  supervisors: (
    [Claudio Landerer],
    [Stefan Stolz],
  ),
  date: [Imst, 2026-06-08],
  font: "New Computer Modern",
  fontsize: 12.5pt,
  sectionnumbering: "1.1.1",
  responsible-default: [Gabi Sorglos],  
  vorwort-text: [Hinweise, wie das bearbeitete Thema gefunden wurde, sowie Danksagungen fur Betreuung und Unterstutzung.],
  kurzfassung-text: [Kurzbeschreibung von Aufgabenstellung und Problemlosung.],
  abstract-text: [Englische Version der Kurzfassung.],
  project-partner-logo: image("typst_media/logos/Logo_Projektpartner.png"),
  school-logo: image("typst_media/logos/Logo_Schule.png"),
)

#include "thesis_content.typ"
