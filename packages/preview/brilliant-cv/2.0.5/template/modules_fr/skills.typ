// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvSkill, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)


#cvSection("Compétences")

#cvSkill(
  type: [Langues],
  info: [Anglais #hBar() Français #hBar() Chinois],
)

#cvSkill(
  type: [Tech Stack],
  info: [Tableau #hBar() Python (Pandas/Numpy) #hBar() PostgreSQL],
)

#cvSkill(
  type: [Centres d'intérêt],
  info: [Natation #hBar() Cuisine #hBar() Lecture],
)
