#import "@preview/bhs-school-bundle:0.2.0": *

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
  // project_partner_logo_path: image("template/typst_media/logos/Logo_Projektpartner.png"),
  // school_logo_path: image("template/typst_media/logos/Logo_Schule.png"),
  // eidesstattliche_erklaerung_text: none,
  // abnahmeerklaerung_text: none,
  vorwort_text: [vorwort_text],
  kurzfassung_text: [kurzfassung_text],
  abstract_text: [abstract_text],
)

Hier startet das Dokument
