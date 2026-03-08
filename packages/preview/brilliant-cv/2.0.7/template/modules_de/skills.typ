// Imports
#import "@preview/brilliant-cv:2.0.6": cvSection, cvSkill, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)


#cvSection("Fähigkeiten")

#cvSkill(
  type: [Sprachen],
  info: [Englisch #hBar() Französisch #hBar() Chinesisch],
)

#cvSkill(
  type: [Technologie Stack],
  info: [Tableau #hBar() Python (Pandas/Numpy) #hBar() PostgreSQL],
)

#cvSkill(
  type: [Persönliche Interessen],
  info: [Schwimmen #hBar() Kochen #hBar() Lesen],
)
