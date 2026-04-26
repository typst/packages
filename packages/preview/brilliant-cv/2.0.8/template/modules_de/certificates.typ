// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvHonor
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvHonor = cvHonor.with(metadata: metadata)


#cvSection("Zertifikate")

#cvHonor(
  date: [2022],
  title: [AWS: Zertifizierte Sicherheit],
  issuer: [Amazon Web Services (AWS)],
)

#cvHonor(
  date: [2017],
  title: [Angewandte Datenwissenschaft mit Python],
  issuer: [Coursera],
)

#cvHonor(
  date: [],
  title: [SQL-Grundlagenkurs],
  issuer: [Datacamp],
)
