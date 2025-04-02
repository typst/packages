// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvSkill, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)


#cvSection("Skills")

#cvSkill(
  type: [Languages],
  info: [English #hBar() French #hBar() Chinese],
)

#cvSkill(
  type: [Tech Stack],
  info: [Tableau #hBar() Python (Pandas/Numpy) #hBar() PostgreSQL],
)

#cvSkill(
  type: [Personal Interests],
  info: [Swimming #hBar() Cooking #hBar() Reading],
)
