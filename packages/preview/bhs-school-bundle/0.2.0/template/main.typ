// Für Kolleg-Variante: "hak" durch "kolleg" ersetzen
#import "@preview/hak-imst:0.2.0": *


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
  responsible_default: [Gabi Sorglos],
  eidesstattliche_erklaerung_text: [Ich erklare an Eides statt, dass ich die vorliegende Diplomarbeit selbst verfasst und keine anderen als die angefuhrten Behelfe verwendet habe. Alle Stellen, die wortlich oder inhaltlich den angegebenen Quellen entnommen wurden, sind als solche kenntlich gemacht. Diese Versicherung umfasst auch verwendete bildliche Darstellungen, Tabellen, Skizzen und Zeichnungen. Etwaig verwendete Behelfe generativer KI-Tools wurden vollstandig und wahrheitsgetreu inkl. Produktversion und Prompt ausgewiesen. Ich bin damit einverstanden, dass meine Arbeit offentlich zuganglich gemacht wird.],
  abnahmeerklaerung_text: [Hiermit bestatigt der Auftraggeber, dass das ubergebene Produkt dieser Diplomarbeit den dokumentierten Vorgaben entspricht. Des Weiteren verzichtet der Auftraggeber auf unentgeltliche Wartung und Weiterentwicklung des Produktes durch die Projektmitglieder bzw. die Schule.],
  vorwort_text: [Hinweise, wie das bearbeitete Thema gefunden wurde, sowie Danksagungen fur Betreuung und Unterstutzung.],
  kurzfassung_text: [Kurzbeschreibung von Aufgabenstellung und Problemlosung.],
  abstract_text: [Englische Version der Kurzfassung.],
  project_partner_logo_path: image("typst_media/logos/Logo_Projektpartner.png"),
  school_logo_path: image("typst_media/logos/Logo_Schule.png"),
)

#include "content.typ"
