#import "../template/settings/styles.typ": *


#let render-skills(skills: ()) = {
  for skill in skills {
    box(
      rect(
        stroke: skills-style.stroke,
        radius: skills-style.radius, 
        skill
      )
    )
    h(skills-style.margins.between-skill-tags)
  }
}