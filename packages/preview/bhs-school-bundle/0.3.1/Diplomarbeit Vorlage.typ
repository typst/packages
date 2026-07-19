#import "@preview/bhs-school-bundle:0.3.1": *

// Für Kolleg-Variante: "hak" durch "kolleg" ersetzen
// Für Bericht siehe README Beispiel
#show: hak.with(
  title: [Der Titel der Arbeit],
  subtitle: [Untertitel der Arbeit],
  projecttype: [Diplomarbeit],
  team: (
    (name: [Max Mustermann], responsibility: [Verantwortlich fur IT: HTML, CSS, BWL: Kaufvertrag]),
    (name: [Susanne Sorglos], responsibility: [Verantwortlich fur IT: HTML, CSS, BWL: Kaufvertrag]),
    (name: [Otto Normalverbraucher], responsibility: [Verantwortlich fur IT: HTML, CSS, BWL: Kaufvertrag]),
  ),
  responsible-default: "Susanne Sorglos",
  supervisors: (
    [Claudio Landerer],
    [Stefan Stolz],
  ),
  date: [Imst, 2026-06-08],
  font: "New Computer Modern",
  fontsize: 12.5pt,
  sectionnumbering: "1.1.1",
  // project-partner-logo: image("template/typst_media/logos/Logo_Projektpartner.png"),
  // school-logo: image("template/typst_media/logos/Logo_Schule.png"),
  // eidesstattliche-erklaerung-text: none,
  // abnahmeerklaerung-text: none,
  vorwort-text: [vorwort_text],
  kurzfassung-text: [kurzfassung_text],
  abstract-text: [abstract_text],
)

Hier startet das Dokument
