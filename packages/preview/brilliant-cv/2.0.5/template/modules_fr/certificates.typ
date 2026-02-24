// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvHonor
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvHonor = cvHonor.with(metadata: metadata)


#cvSection("Certificates")

#cvHonor(
  date: [2022],
  title: [AWS Certified Security],
  issuer: [Amazon Web Services (AWS)],
)

#cvHonor(
  date: [2017],
  title: [Applied Data Science with Python],
  issuer: [Coursera],
)

#cvHonor(
  date: [],
  title: [Bases de données et requêtes SQL],
  issuer: [OpenClassrooms],
)
