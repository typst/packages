// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvSkill, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)


#cvSection("Competenze")

#cvSkill(
  type: [Lingue],
  info: [Inglese #hBar() Francese #hBar() Cinese],
)

#cvSkill(
  type: [Tecnologie],
  info: [Tableau #hBar() Python (Pandas/Numpy) #hBar() PostgreSQL],
)

#cvSkill(
  type: [Interessi personali],
  info: [Nuoto #hBar() Cucina #hBar() Lettura],
)
