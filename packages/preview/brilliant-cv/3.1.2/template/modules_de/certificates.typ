// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-honor
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-honor = cv-honor.with(metadata: metadata)


#cv-section("Zertifikate")

#cv-honor(
  date: [2022],
  title: [AWS: Zertifizierte Sicherheit],
  issuer: [Amazon Web Services (AWS)],
)

#cv-honor(
  date: [2017],
  title: [Angewandte Datenwissenschaft mit Python],
  issuer: [Coursera],
)

#cv-honor(
  date: [],
  title: [SQL-Grundlagenkurs],
  issuer: [Datacamp],
)
