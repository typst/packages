// Für Kolleg-Variante: "hak" durch "kolleg" ersetzen
#import "lib.typ": *


// Für Kolleg-Variante: "hak" durch "kolleg" ersetzen
#show: report.with(
  title: [Der Titel der Arbeit],
  subtitle: [Untertitel der Arbeit],
  // projecttype: [Diplomarbeit],
  author: "Max Mustermann, Susanne Sorglos",
  responsible_default: "Susanne Sorglos",
  location: "Imst",
  date: [2026-06-08],
  font: "New Computer Modern",
  fontsize: 12.5pt,
  sectionnumbering: "1.1.1",
  project_partner_logo_path: image("template/typst_media/logos/Logo_Projektpartner.png"),
  school_logo_path: image("template/typst_media/logos/Logo_HAK_Imst.png"),
)

test
