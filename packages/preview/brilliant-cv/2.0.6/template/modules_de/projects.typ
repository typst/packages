// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Projekte und Verbände")

#cvEntry(
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
