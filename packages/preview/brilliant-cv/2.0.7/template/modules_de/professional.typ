// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Berufliche Erfahrung")

#cvEntry(
  title: [Direktor für Datenwissenschaft],
  society: [XYZ Gesellschaft],
  logo: image("../src/logos/xyz_corp.png"),
  date: [2020 - Heute],
  location: [San Francisco, CA],
  description: list(
    [Leitung eines Teams von Datenwissenschaftlern und -analysten zur Entwicklung und Umsetzung datengesteuerter Strategien, Entwicklung von Prognosemodellen und Algorithmen zur Unterstützung der Entscheidungsfindung im gesamten Unternehmen],
    [Zusammenarbeit mit der Geschäftsleitung, um Geschäftsmöglichkeiten zu ermitteln und das Wachstum voranzutreiben, Umsetzung bewährter Verfahren für Datenverwaltung, -qualität und -sicherheit],
  ),
  tags: ("Tags Example here", "Dataiku", "Snowflake", "SparkSQL"),
)

#cvEntry(
  title: [Datenanalyst],
  society: [ABC Unternehmen],
  logo: image("../src/logos/abc_company.png"),
  date: [2017 - 2020],
  location: [New York, NY],
  description: list(
    [Analyse von großen Datenmengen mit SQL und Python, zusammenarbeit mit Teams, um geschäftliche Erkenntnisse zu gewinnen],
    [Erstellung von Datenvisualisierungen und Dashboards in Tableau, Entwicklung und Pflege von Datenpipelines mit AWS],
  ),
)

#cvEntry(
  title: [Praktikant Datenanalyst],
  society: [PQR Gesellschaft],
  logo: image("../src/logos/pqr_corp.png"),
  date: list(
    [Sommer 2017],
    [Sommer 2016],
  ),
  location: [Chicago, IL],
  description: list([Unterstützung bei der Datenbereinigung, -verarbeitung und -analyse mit Python und Excel, Teilnahme an Teambesprechungen und Mitwirkung bei der Projektplanung und -durchführung]),
)
