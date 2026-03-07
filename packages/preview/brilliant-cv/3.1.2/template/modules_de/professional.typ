// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-entry, cv-entry-start, cv-entry-continued
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-entry = cv-entry.with(metadata: metadata)
#let cv-entry-start = cv-entry-start.with(metadata: metadata)
#let cv-entry-continued = cv-entry-continued.with(metadata: metadata)


#cv-section("Berufliche Erfahrung")

#cv-entry-start(
  society: [XYZ Gesellschaft],
  logo: image("../assets/logos/xyz_corp.png"),
  location: [San Francisco, CA],
)

#cv-entry-continued(
  title: [Direktor für Datenwissenschaft],
  date: [2020 - Heute],
  description: list(
    [Leitung eines Teams von Datenwissenschaftlern und -analysten zur Entwicklung und Umsetzung datengesteuerter Strategien, Entwicklung von Prognosemodellen und Algorithmen zur Unterstützung der Entscheidungsfindung im gesamten Unternehmen],
    [Zusammenarbeit mit der Geschäftsleitung, um Geschäftsmöglichkeiten zu ermitteln und das Wachstum voranzutreiben, Umsetzung bewährter Verfahren für Datenverwaltung, -qualität und -sicherheit],
  ),
  tags: ("Dataiku", "Snowflake", "SparkSQL"),
)

#cv-entry(
  title: [Datenanalyst],
  society: [ABC Unternehmen],
  logo: image("../assets/logos/abc_company.png"),
  date: [2017 - 2020],
  location: [New York, NY],
  description: list(
    [Analyse von großen Datenmengen mit SQL und Python, zusammenarbeit mit Teams, um geschäftliche Erkenntnisse zu gewinnen],
    [Erstellung von Datenvisualisierungen und Dashboards in Tableau, Entwicklung und Pflege von Datenpipelines mit AWS],
  ),
)

#cv-entry(
  title: [Praktikant Datenanalyst],
  society: [PQR Gesellschaft],
  logo: image("../assets/logos/pqr_corp.png"),
  date: list(
    [Sommer 2017],
    [Sommer 2016],
  ),
  location: [Chicago, IL],
  description: list([Unterstützung bei der Datenbereinigung, -verarbeitung und -analyse mit Python und Excel, Teilnahme an Teambesprechungen und Mitwirkung bei der Projektplanung und -durchführung]),
)
