// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvHonor
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvHonor = cvHonor.with(metadata: metadata)


#cvSection("Certificazioni")

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
  title: [Fondamenti di SQL],
  issuer: [Datacamp],
)
