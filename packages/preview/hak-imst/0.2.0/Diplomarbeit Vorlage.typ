// Für Kolleg-Variante: "hak" durch "kolleg" ersetzen
#import "lib.typ": *


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
  // school_logo_path: image("template/typst_media/logos/Logo_HAK_Imst.png"),
)

Hier startet das Dokument
