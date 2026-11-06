// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-entry
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-entry = cv-entry.with(metadata: metadata)


#cv-section("Projekte und Verbände")

#cv-entry(
  title: [Ehrenamtlicher Datenanalyst],
  society: [ABC Gemeinnützige Organisation],
  date: [2019 - Heute],
  location: [New York, NY],
  description: list(
    [Analyse von Spender- und Fundraising-Daten zur Ermittlung von Trends und Wachstumsmöglichkeiten],
    [Erstellung von Datenvisualisierungen und Dashboards zur Vermittlung von Erkenntnissen an den Vorstand],
    [Zusammenarbeit mit anderen Freiwilligen bei der Entwicklung und Umsetzung datengestützter Strategien],
  ),
)
